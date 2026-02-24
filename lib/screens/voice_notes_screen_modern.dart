import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/audio_service.dart';
import '../services/speech_service.dart';
import '../widgets/animated_record_button.dart';
import '../widgets/modern_note_card.dart';
import '../constants/strings.dart';
import 'edit_note_screen.dart';

class VoiceNotesScreen extends StatefulWidget {
  final List<Note> notes;
  final AudioService audioService;
  final SpeechService speechService;
  final Function(Note) onNoteAdded;
  final Function(String) onNoteDeleted;
  final Function(Note) onNoteUpdated;
  final bool areServicesInitialized;

  const VoiceNotesScreen({
    super.key,
    required this.notes,
    required this.audioService,
    required this.speechService,
    required this.onNoteAdded,
    required this.onNoteDeleted,
    required this.onNoteUpdated,
    required this.areServicesInitialized,
  });

  @override
  State<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

class _VoiceNotesScreenState extends State<VoiceNotesScreen> {
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isProcessing = false;

  String? _currentlyPlayingPath;
  StreamSubscription<bool>? _playerStateSubscription;
  StreamSubscription<void>? _playbackCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = widget.audioService.onPlayingChanged.listen((isPlaying) {
      if (!isPlaying && mounted) {
        setState(() => _currentlyPlayingPath = null);
      }
    });

    _playbackCompleteSubscription = widget.audioService.onPlaybackComplete.listen((_) {
      if (mounted) {
        setState(() => _currentlyPlayingPath = null);
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _playbackCompleteSubscription?.cancel();
    super.dispose();
  }

  void _playNote(String path) {
    setState(() => _currentlyPlayingPath = path);
    widget.audioService.playNote(path);
  }

  void _stopPlayback() {
    widget.audioService.stopPlayer();
  }

  Future<void> _toggleRecording() async {
    if (_isProcessing) return;

    if (!widget.areServicesInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Strings.servicesLoading)),
        );
      }
      return;
    }

    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      final resultPath = await widget.audioService.stopRecording();

      if (resultPath == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      final now = DateTime.now();
      final tempNote = Note(
        path: resultPath,
        title: 'Заметка от ${DateFormat('dd.MM.yy HH:mm').format(now)}',
        text: 'Идёт распознавание...',
        date: now,
      );
      widget.onNoteAdded(tempNote);

      try {
        final transcription = await widget.speechService.transcribeAudioFile(resultPath);
        final finalNote = Note(
          path: resultPath,
          title: tempNote.title,
          text: transcription,
          date: tempNote.date,
        );
        widget.onNoteUpdated(finalNote);
      } catch (e) {
        final errorNote = Note(
          path: resultPath,
          title: tempNote.title,
          text: 'Ошибка распознавания',
          date: tempNote.date,
        );
        widget.onNoteUpdated(errorNote);
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    } else {
      final path = await widget.audioService.startRecording();
      if (path != null) {
        setState(() {
          _isRecording = true;
          _isPaused = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(Strings.microphonePermissionRequired)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (widget.notes.isEmpty)
            const Center(child: Text(Strings.noNotes))
          else
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 150),
              itemCount: widget.notes.length,
              itemBuilder: (context, index) {
                final note = widget.notes[index];
                final isPlaying = note.path == _currentlyPlayingPath;

                return ModernNoteCard(
                  key: ValueKey(note.path),
                  title: note.title,
                  text: note.text,
                  date: note.date,
                  index: index,
                  isPlaying: isPlaying,
                  onPlay: () => _playNote(note.path),
                  onStop: _stopPlayback,
                  onEdit: () => _editNote(note),
                  onDelete: () => _deleteNote(note.path),
                  onExport: () =>
                      widget.audioService.exportNote(note.path, note.title, note.text),
                );
              },
            ),

          if (_isRecording)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: SoundWaveVisualizer(
                isActive: _isRecording && !_isPaused,
                height: 60,
              ),
            ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedRecordButton(
                onPressed: _toggleRecording,
                onStop: _toggleRecording,
                isRecording: _isRecording,
                isPaused: _isPaused,
                isProcessing: _isProcessing,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editNote(Note note) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: note),
      ),
    );

    if (updatedNote != null && mounted) {
      widget.onNoteUpdated(updatedNote);
    }
  }

  void _deleteNote(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(Strings.deleteNoteTitle),
        content: const Text(Strings.deleteNoteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.onNoteDeleted(path);
              Navigator.pop(context);
            },
            child: Text(
              Strings.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class SoundWaveVisualizer extends StatelessWidget {
  final bool isActive;
  final double height;
  const SoundWaveVisualizer({super.key, required this.isActive, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Text(
        isActive ? '...Идет запись...' : '',
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}