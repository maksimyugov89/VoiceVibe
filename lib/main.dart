import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'services/speech_service.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'models/note.dart';
import 'theme/app_theme.dart' as app_theme;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsService = SettingsService();
  final initialThemeMode = await settingsService.getThemeMode();
  final initialLangCode = await settingsService.getLanguageCode();

  runApp(MyApp(
    initialThemeMode: initialThemeMode,
    initialLangCode: initialLangCode,
  ));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final String initialLangCode;

  const MyApp({
    super.key,
    required this.initialThemeMode,
    required this.initialLangCode,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ИЗМЕНЕНИЕ 1: Добавляем глобальный ключ для навигатора
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final AudioService _audioService = AudioService();
  final SpeechService _speechService = SpeechService();
  final SettingsService _settingsService = SettingsService();
  final _logger = Logger();
  bool _servicesInitialized = false;
  final List<Note> _notes = [];
  late ThemeMode _themeMode;
  late String _langCode;
  bool _themeLoaded = false;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _langCode = widget.initialLangCode;
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await Future.wait([
        _initServices(),
        Future.delayed(const Duration(seconds: 3)),
      ]);
    } catch (e) {
      _logger.e('Ошибка инициализации приложения: $e');
    } finally {
      if (mounted) {
        setState(() {
          _servicesInitialized = true;
          _themeLoaded = true;
        });
      }
    }
  }
  
  Future<void> _initServices() async {
    try {
      await _audioService.init();
      await _speechService.init(_langCode);
      await _loadNotesFromDisk();
    } catch (e) {
      _logger.e('Ошибка инициализации сервисов: $e');
      rethrow;
    }
  }

  Future<void> _loadNotesFromDisk() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      final List<Note> loadedNotes = [];
      for (final fileEntity in files) {
        if (fileEntity is File &&
            (fileEntity.path.endsWith('.wav') ||
                fileEntity.path.endsWith('.aac') ||
                fileEntity.path.endsWith('.m4a'))) {
          final audioPath = fileEntity.path;
          final date = Note.dateFromPath(audioPath);
          if (date != null) {
            String title = 'Заметка от ${DateFormat('dd.MM.yy HH:mm').format(date)}';
            String text = '';
            
            final textPath = audioPath.replaceAll(RegExp(r'\.\w+$'), '.txt');
            final textFile = File(textPath);
            if (await textFile.exists()) {
              final lines = await textFile.readAsLines();
              if (lines.isNotEmpty) {
                title = lines.first;
                text = lines.skip(1).join('\n');
              }
            }
            loadedNotes.add(Note(path: audioPath, title: title, text: text, date: date));
          }
        }
      }
      loadedNotes.sort((a, b) => b.date.compareTo(a.date));
      if (mounted) {
        setState(() {
          _notes.clear();
          _notes.addAll(loadedNotes);
        });
        _logger.i('Загружено заметок: ${_notes.length}');
      }
    } catch (e) {
      _logger.e('Общая ошибка загрузки заметок: $e');
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    _audioService.dispose();
    super.dispose();
  }

  void _onNoteAdded(Note note) {
    setState(() {
      _notes.insert(0, note);
    });
    _audioService.saveText(note.path, note.title, note.text);
    _logger.i('Заметка добавлена и сохранена: ${note.title}');
  }

  void _onNoteDeleted(String path) {
    setState(() {
      _notes.removeWhere((n) => n.path == path);
    });
    _audioService.deleteNote(path);
    _logger.i('Заметка удалена (включая файлы): $path');
  }

  void _onNoteUpdated(Note note) {
    setState(() {
      final idx = _notes.indexWhere((n) => n.path == note.path);
      if (idx >= 0) _notes[idx] = note;
    });
    _audioService.saveText(note.path, note.title, note.text);
    _logger.i('Заметка обновлена и сохранена: ${note.title}');
  }

  void _onThemeChanged(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _settingsService.setThemeMode(themeMode).catchError((e) {
      _logger.e('Ошибка сохранения темы: $e');
    });
  }

  void _onLanguageChanged(String langCode) {
    _settingsService.setLanguageCode(langCode);
    
    // ИЗМЕНЕНИЕ 2: Используем контекст из глобального ключа, а не из BuildContext
    final context = _navigatorKey.currentContext;
    if (context == null) return; // Проверка на случай, если контекст еще не доступен

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Смена языка'),
        content: const Text('Для применения новой модели распознавания речи необходимо перезапустить приложение.'),
        actions: [
          TextButton(
            onPressed: () => exit(0),
            child: const Text('Перезапустить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ИЗМЕНЕНИЕ 3: Присваиваем ключ нашему MaterialApp
      navigatorKey: _navigatorKey,
      title: 'VoiceVibe',
      theme: app_theme.VoiceVibeTheme.lightTheme,
      darkTheme: app_theme.VoiceVibeTheme.darkTheme,
      themeMode: _themeMode,
      home: _themeLoaded && _servicesInitialized
          ? HomeScreen(
              notes: _notes,
              audioService: _audioService,
              speechService: _speechService,
              onNoteAdded: _onNoteAdded,
              onNoteDeleted: _onNoteDeleted,
              onNoteUpdated: _onNoteUpdated,
              areServicesInitialized: _servicesInitialized,
              onThemeChanged: _onThemeChanged,
              onLanguageChanged: _onLanguageChanged,
              currentLangCode: _langCode,
            )
          : const SplashScreen(),
    );
  }
}