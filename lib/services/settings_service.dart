import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SettingsService {
  static const String _themeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language_code'; // Ключ для языка
  final Logger _logger = Logger();
  
  // --- Тема ---
  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeKey);
      
      if (themeModeIndex != null) {
        return ThemeMode.values[themeModeIndex];
      }
      return ThemeMode.system;
    } catch (e) {
      _logger.e('Ошибка загрузки темы: $e');
      return ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      _logger.e('Ошибка сохранения темы: $e');
    }
  }

  // --- Язык ---
  Future<String> getLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(_languageKey);
      // Русский язык по умолчанию
      return langCode ?? 'ru';
    } catch (e) {
      _logger.e('Ошибка загрузки языка: $e');
      return 'ru';
    }
  }

  Future<void> setLanguageCode(String langCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, langCode);
    } catch (e) {
      _logger.e('Ошибка сохранения языка: $e');
    }
  }
}