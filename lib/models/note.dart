import 'package:logger/logger.dart';

final _logger = Logger();

class Note {
  final String path;
  final String title; // ДОБАВЛЕНО: поле для заголовка
  final String text;
  final DateTime date;

  Note({
    required this.path,
    required this.title, // ДОБАВЛЕНО: в конструктор
    required this.text,
    required this.date,
  });

  static DateTime? dateFromPath(String path) {
    try {
      final fileName = path.split(RegExp(r'[\\/]+')).last;
      final match = RegExp(r"(\d{9,})").firstMatch(fileName);
      if (match == null) {
        throw FormatException('timestamp not found in filename');
      }
      final timestampString = match.group(0)!;
      final timestamp = int.tryParse(timestampString);
      if (timestamp == null) throw FormatException('invalid timestamp: $timestampString');
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      _logger.e('Ошибка парсинга даты из пути: $path', error: e);
      return null;
    }
  }
}