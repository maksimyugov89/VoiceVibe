import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/audio_service.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart' as app_theme;
import 'voice_notes_screen_modern.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../widgets/floating_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  final List<Note> notes;
  final AudioService audioService;
  final SpeechService speechService;
  final Function(Note) onNoteAdded;
  final Function(String) onNoteDeleted;
  final Function(Note) onNoteUpdated;
  final bool areServicesInitialized;
  final Function(ThemeMode)? onThemeChanged;
  final Function(String) onLanguageChanged; // ДОБАВЛЕНО
  final String currentLangCode; // ДОБАВЛЕНО

  const HomeScreen({
    super.key,
    required this.notes,
    required this.audioService,
    required this.speechService,
    required this.onNoteAdded,
    required this.onNoteDeleted,
    required this.onNoteUpdated,
    required this.areServicesInitialized,
    this.onThemeChanged,
    required this.onLanguageChanged, // ДОБАВЛЕНО
    required this.currentLangCode, // ДОБАВЛЕНО
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Определяем текущую тему
    final currentThemeMode = Theme.of(context).brightness == Brightness.dark 
        ? ThemeMode.dark
        : ThemeMode.light;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration( // <--- Можно и здесь добавить const
            gradient: app_theme.VoiceVibeTheme.voiceGradient,
          ),
          child: AppBar(
            // ИСПРАВЛЕНИЕ ЗДЕСЬ: Добавлен 'const' к конструктору Text
            title: const Text('VoiceVibe'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          VoiceNotesScreen(
            notes: widget.notes,
            audioService: widget.audioService,
            speechService: widget.speechService,
            onNoteAdded: widget.onNoteAdded,
            onNoteDeleted: widget.onNoteDeleted,
            onNoteUpdated: widget.onNoteUpdated,
            areServicesInitialized: widget.areServicesInitialized,
          ),
          CalendarScreen(
            audioService: widget.audioService,
            notes: widget.notes,
          ),
          SettingsScreen(
            onThemeChanged: widget.onThemeChanged,
            currentThemeMode: currentThemeMode,
            onLanguageChanged: widget.onLanguageChanged, // ДОБАВЛЕНО
            currentLangCode: widget.currentLangCode, // ДОБАВЛЕНО
          ),
        ],
      ),
      bottomNavigationBar: FloatingBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}