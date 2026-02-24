import 'package:flutter/material.dart';
import '../constants/strings.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode currentThemeMode;
  final Function(String) onLanguageChanged;
  final String currentLangCode;
  
  const SettingsScreen({
    super.key, 
    this.onThemeChanged,
    this.currentThemeMode = ThemeMode.system,
    required this.onLanguageChanged,
    required this.currentLangCode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _currentThemeMode;
  late String _currentLangCode;

  @override
  void initState() {
    super.initState();
    _currentThemeMode = widget.currentThemeMode;
    _currentLangCode = widget.currentLangCode;
  }

  // --- ЛОГИКА СМЕНЫ ТЕМЫ (из вашего кода) ---
  void _changeThemeMode(ThemeMode? themeMode) {
    if (themeMode != null && themeMode != _currentThemeMode) {
      setState(() {
        _currentThemeMode = themeMode;
      });
      
      if (widget.onThemeChanged != null) {
        widget.onThemeChanged!(themeMode);
      }
      
      String themeName;
      switch (themeMode) {
        case ThemeMode.light:
          themeName = 'Светлая';
          break;
        case ThemeMode.dark:
          themeName = 'Темная';
          break;
        case ThemeMode.system:
          themeName = 'Системная';
          break;
      }
      
      // Показываем уведомление о смене темы
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Тема изменена на: $themeName"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Темная';
      case ThemeMode.system:
        return 'Системная';
    }
  }

  // --- ЛОГИКА СМЕНЫ ЯЗЫКА (интегрирована) ---
  void _changeLanguage(String? langCode) {
    if (langCode != null && langCode != _currentLangCode) {
      setState(() {
        _currentLangCode = langCode;
      });
      widget.onLanguageChanged(langCode);
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ru':
        return Strings.russian;
      case 'en':
        return Strings.english;
      default:
        return 'Неизвестный';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // --- РАЗДЕЛ СМЕНЫ ТЕМЫ (ВОССТАНОВЛЕН) ---
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Внешний вид',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Тема приложения'),
          subtitle: Text(_getThemeModeName(_currentThemeMode)),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Выберите тему'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('Системная'),
                      value: ThemeMode.system,
                      groupValue: _currentThemeMode,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _changeThemeMode(value);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Светлая'),
                      value: ThemeMode.light,
                      groupValue: _currentThemeMode,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _changeThemeMode(value);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Темная'),
                      value: ThemeMode.dark,
                      groupValue: _currentThemeMode,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _changeThemeMode(value);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                ],
              ),
            );
          },
        ),
        
        const Divider(),
        
        // --- РАЗДЕЛ СМЕНЫ ЯЗЫКА (РАБОТАЕТ) ---
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Распознавание речи',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text(Strings.recognitionLanguage),
          subtitle: Text(_getLanguageName(_currentLangCode)),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(Strings.languageSelection),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: const Text(Strings.russian),
                      value: 'ru',
                      groupValue: _currentLangCode,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _changeLanguage(value);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text(Strings.english),
                      value: 'en',
                      groupValue: _currentLangCode,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _changeLanguage(value);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                ],
              ),
            );
          },
        ),
        
        const Divider(),
        
        // --- РАЗДЕЛ ИНФОРМАЦИИ (НА МЕСТЕ) ---
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'О приложении',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Версия приложения'),
          subtitle: const Text('1.0.0+2'),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Помощь'),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Как пользоваться'),
                content: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📝 Создание заметки:', 
                           style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('• Нажмите на кнопку микрофона для начала записи.'),
                      Text('• Для остановки нажмите на кнопку стоп.'),
                      SizedBox(height: 12),
                      Text('✏️ Редактирование:', 
                           style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('• Нажмите на карточку заметки, чтобы появились кнопки действий.'),
                      Text('• Кнопка "Изменить" откроет редактор заголовка и текста.'),
                       SizedBox(height: 12),
                      Text('📅 Календарь:', 
                           style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('• Дни с точками содержат заметки.'),
                      Text('• Нажмите на день для просмотра.'),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Понятно'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}