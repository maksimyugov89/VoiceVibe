// lib/services/audio_service.dart
import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record_platform_interface/record_platform_interface.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:share_plus/share_plus.dart';

class AudioService {
  // Use the platform interface directly — it exposes the create/start/stop API
  final String _recorderId = 'voicevibe_recorder';
  final RecordPlatform _record = RecordPlatform.instance;
  final Logger _logger = Logger();
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioSession? _audioSession;

  String? _currentPath;
  
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  Stream<Duration> get onDurationChanged => _durationController.stream;
  Timer? _durationTimer;

  // Playback streams
  final StreamController<Duration> _playbackPositionController = StreamController<Duration>.broadcast();
  Stream<Duration> get onPlaybackPositionChanged => _playbackPositionController.stream;

  final StreamController<Duration> _playbackDurationController = StreamController<Duration>.broadcast();
  Stream<Duration> get onPlaybackDurationChanged => _playbackDurationController.stream;

  // Expose playing state stream from audio player
  Stream<bool> get onPlayingChanged => _audioPlayer.playingStream;

  final StreamController<void> _playbackCompleteController = StreamController<void>.broadcast();
  Stream<void> get onPlaybackComplete => _playbackCompleteController.stream;

  bool isRecording = false;

  Future<void> init() async {
    _logger.i('AudioService initialized with `record_platform_interface`.');
    try {
      await _record.create(_recorderId);
    } catch (e) {
      _logger.w('RecordPlatform.create() failed: $e');
    }

    // Configure audio session for correct behavior with other apps and background
    try {
      _audioSession = await AudioSession.instance;

      // Listen for interruptions (incoming calls, etc.) and pause/resume playback.
      // Handle event as dynamic to avoid depending on exact event type shape.
        _audioSession?.interruptionEventStream.listen((event) async {
          // event shape may vary between versions; access dynamically and safely
          try {
            final dyn = event as dynamic;
            bool? begin;
            bool? end;
            try {
              begin = dyn.begin as bool?;
            } catch (_) {
              try {
                begin = dyn['begin'] as bool?;
              } catch (_) {}
            }
            try {
              end = dyn.end as bool?;
            } catch (_) {
              try {
                end = dyn['end'] as bool?;
              } catch (_) {}
            }
            if (begin == true) {
              await _audioPlayer.pause();
            }
            if (end == true) {
              await _audioPlayer.play();
            }
          } catch (_) {}
        });
    } catch (e) {
      _logger.w('Не удалось инициализировать AudioSession: $e');
    }

    // Forward just_audio position/duration streams to our controllers
    // just_audio streams are typed as Duration — forward directly
    _audioPlayer.positionStream.listen((Duration pos) {
      try {
        // just_audio provides Duration-typed positions; forward directly
        _playbackPositionController.add(pos);
      } catch (_) {}
    });

    _audioPlayer.durationStream.listen((Duration? dur) {
      try {
        if (dur != null) _playbackDurationController.add(dur);
      } catch (_) {}
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playbackCompleteController.add(null);
      }
    });
  }

  Future<String?> startRecording() async {
    try {
      final hasPerm = await _record.hasPermission(_recorderId);
      if (hasPerm) {
        final dir = await getApplicationDocumentsDirectory();
        // Записываем в WAV/PCM16, 16kHz, моно — это формат, который ожидает Vosk
        _currentPath = '${dir.path}/note_${DateTime.now().millisecondsSinceEpoch}.wav';

        // Determine a supported encoder and fallback if needed
        AudioEncoder preferred = AudioEncoder.wav;
        final supportedWav = await _record.isEncoderSupported(_recorderId, AudioEncoder.wav);
        final supportedPcm = await _record.isEncoderSupported(_recorderId, AudioEncoder.pcm16bits);
        final supportedAac = await _record.isEncoderSupported(_recorderId, AudioEncoder.aacLc);

        AudioEncoder chosen;
        if (supportedWav) {
          chosen = AudioEncoder.wav;
        } else if (supportedPcm) {
          chosen = AudioEncoder.pcm16bits;
        } else if (supportedAac) {
          chosen = AudioEncoder.aacLc;
        } else {
          // If none supported, fallback to wav and let platform decide or fail
          chosen = preferred;
          _logger.w('Нет поддерживаемых энкодеров (wav/pcm/aac) — пытаемся с wav.');
        }

        // adjust extension based on chosen encoder
        String ext = '.wav';
        switch (chosen) {
          case AudioEncoder.wav:
            ext = '.wav';
            break;
          case AudioEncoder.pcm16bits:
            ext = '.s16';
            break;
          case AudioEncoder.aacLc:
            ext = '.m4a';
            break;
          default:
            ext = '.wav';
        }

        _currentPath = '${dir.path}/note_${DateTime.now().millisecondsSinceEpoch}$ext';

        final config = RecordConfig(
          encoder: chosen,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 128000,
        );

        _logger.i('Выбран энкодер: $chosen, путь: $_currentPath');

        await _record.start(
          _recorderId,
          config,
          path: _currentPath!,
        );

        _logger.i('🎤 Начинаем запись: $_currentPath');
        isRecording = true;
        _startDurationTimer();
        return _currentPath;
      } else {
        _logger.e('Нет прав на запись аудио');
        return null;
      }
    } catch (e) {
      _logger.e('Ошибка начала записи: $e');
      return null;
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _durationController.add(Duration(seconds: timer.tick));
    });
  }

  Future<String?> stopRecording() async {
    _durationTimer?.cancel();
    _durationController.add(Duration.zero);
    try {
  final path = await _record.stop(_recorderId);
      _logger.i('✅ Запись остановлена. Путь: $path');
      isRecording = false;
      return path;
    } catch (e) {
      _logger.e('Ошибка остановки записи: $e');
      return null;
    }
  }

  // ИЗМЕНЕНИЕ: Добавлены методы паузы и возобновления
  Future<void> pauseRecording() async {
    try {
      _durationTimer?.cancel();
  await _record.pause(_recorderId);
      _logger.i('Пауза записи.');
    } catch (e) {
      _logger.e('Ошибка паузы: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      _startDurationTimer();
  await _record.resume(_recorderId);
      _logger.i('Возобновление записи.');
    } catch (e) {
      _logger.e('Ошибка возобновления: $e');
    }
  }
  
  // Функции ниже пока не будут работать, так как для проигрывания нужен другой пакет
  Future<void> playNote(String path) async {
    try {
      if (path.isEmpty) return;
      final file = File(path);
      if (!await file.exists()) {
        _logger.w('Файл для проигрывания не найден: $path');
        return;
      }
      _logger.i('Проигрываем заметку: $path');
      // Activate audio session before playback so system knows our intent
      try {
        await _audioSession?.setActive(true);
      } catch (e) {
        _logger.w('Не удалось установить сессию активной: $e');
      }

      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
    } catch (e) {
      _logger.e('Ошибка при проигрывании заметки: $e');
    }
  }

  Future<void> stopPlayer() async {
    try {
      await _audioPlayer.stop();
      try {
        await _audioSession?.setActive(false);
      } catch (_) {}
    } catch (e) {
      _logger.e('Ошибка при остановке плеера: $e');
    }
  }

  Future<void> pausePlayer() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _logger.e('Ошибка при паузе плеера: $e');
    }
  }

  Future<void> resumePlayer() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      _logger.e('Ошибка при возобновлении плеера: $e');
    }
  }

  bool get isPlaying {
    return _audioPlayer.playing;
  }
  
  Future<void> dispose() async {
    try {
  await _record.dispose(_recorderId);
    } catch (_) {
      // Some platform implementations may not require/implement dispose.
    }
    try {
      await _audioPlayer.dispose();
    } catch (_) {}
    _durationController.close();
    _playbackPositionController.close();
    _playbackDurationController.close();
    _playbackCompleteController.close();
    _durationTimer?.cancel();
    _logger.i('AudioService disposed.');
  }

  Future<void> saveText(String audioPath, String title, String text) async {
    final textPath = audioPath.replaceAll(RegExp(r'\.\w+$'), '.txt');
    final file = File(textPath);
    // Сохраняем в формате: первая строка - заголовок, остальные - текст
    await file.writeAsString('$title\n$text');
  }

  Future<void> deleteNote(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
      // Универсально заменяем любое аудио расширение на .txt
      final textPath = audioPath.replaceAll(RegExp(r'\.\w+$'), '.txt');
      final textFile = File(textPath);
      if (await textFile.exists()) {
        await textFile.delete();
      }
    } catch (e) {
      _logger.e('Ошибка удаления файла заметки: $e');
    }
  }
  
  // ИЗМЕНЕНО: Метод теперь принимает заголовок
  Future<void> exportNote(String path, String title, String text) async {
    try {
      final audioFile = XFile(path);
      // Используем заголовок заметки как тему письма
      final subject = title;

      if (text.isNotEmpty) {
        await Share.shareXFiles(
          [audioFile],
          text: 'Текст заметки: \n\n"$text"',
          subject: subject,
        );
      } else {
        await Share.shareXFiles(
          [audioFile],
          subject: subject,
        );
      }
      _logger.i('Заметка "$path" успешно экспортирована.');
    } catch (e) {
      _logger.e('Ошибка экспорта заметки: $e');
    }
  }
}