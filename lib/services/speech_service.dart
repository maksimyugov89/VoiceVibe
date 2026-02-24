// lib/services/speech_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:vosk_flutter_2/vosk_flutter_2.dart';

class SpeechService {
  final Logger _logger = Logger();
  final dynamic _vosk = VoskFlutterPlugin.instance;
  Model? _model;
  bool _isModelReady = false;

  Future<void> init(String langCode) async {
    _isModelReady = false;
    try {
      final assetPrefix = 'assets/model_$langCode/';
      _logger.i('Загрузка модели для языка: $langCode из $assetPrefix');

      final deployedPath = await _ensureModelDeployed(assetPrefix, langCode);
      
      dynamic plugin = _vosk;
      if (plugin is Function) plugin = plugin();

      final dynamic modelResult = await (plugin as dynamic).createModel(deployedPath);
      _model = modelResult as Model?;

      if (_model != null) {
        _isModelReady = true;
        _logger.i('✅ Модель Vosk для языка "$langCode" успешно загружена.');
      } else {
        _isModelReady = false;
        _logger.e('⛔ Не удалось создать модель Vosk для "$langCode": модель == null');
      }
    } catch (e, st) {
      _isModelReady = false;
      _logger.e('⛔ Ошибка загрузки модели Vosk: $e', stackTrace: st);
    }
  }

  Future<String> _ensureModelDeployed(String assetPrefix, String langCode) async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/model_$langCode');

    final markerFile = File('${modelDir.path}/.deployed_successfully');
    if (await markerFile.exists()) {
      _logger.i('Модель "$langCode" уже развернута. Пропускаем копирование.');
      return modelDir.path;
    }
    
    if (await modelDir.exists()) {
      await modelDir.delete(recursive: true);
    }
    await modelDir.create(recursive: true);

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      // ИСПРАВЛЕНИЕ ЗДЕСЬ
      final Map<String, dynamic> manifestMap = jsonDecode(manifestContent) as Map<String, dynamic>;
      final assetKeys = manifestMap.keys.where((k) => k.startsWith(assetPrefix));
      
      for (final key in assetKeys) {
          final bytes = await rootBundle.load(key);
          final relative = key.substring(assetPrefix.length);
          if (relative.isEmpty) continue;

          final outFile = File('${modelDir.path}/$relative');
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(bytes.buffer.asUint8List());
      }
      await markerFile.create();
      _logger.i('Модель "$langCode" успешно развернута в локальное хранилище.');
    } catch (e) {
      _logger.w('Не удалось прочитать AssetManifest.json или скопировать файлы: $e');
    }

    return modelDir.path;
  }

  Future<String> transcribeAudioFile(String path) async {
    if (!_isModelReady || _model == null) {
      _logger.e('Модель Vosk не готова к распознаванию.');
      return 'Ошибка: модель не загружена';
    }

    try {
      _logger.i('🗣️ Начинаем распознавание файла: $path');
      
      dynamic plugin = _vosk;
      if (plugin is Function) plugin = plugin();
      
      final recognizer = await (plugin as dynamic).createRecognizer(model: _model!, sampleRate: 16000);

      final rawAudio = await File(path).readAsBytes();
      
      await (recognizer as dynamic).acceptWaveformBytes(rawAudio);
      
      final resultJson = await (recognizer as dynamic).getFinalResult();

      if (resultJson == null || (resultJson is String && resultJson.isEmpty)) {
        _logger.w('Распознавание вернуло пустой результат.');
        return 'Речь не распознана';
      }

      _logger.i('Результат распознавания (JSON): $resultJson');

      // ИСПРАВЛЕНИЕ ЗДЕСЬ
      final Map<String, dynamic> resultData = jsonDecode(resultJson as String) as Map<String, dynamic>;
      final recognizedText = resultData['text'] as String? ?? '';

      if (recognizedText.isEmpty) {
        _logger.w('Распознанный текст пуст.');
        return 'Речь не распознана';
      }

      _logger.i('✅ Файл успешно распознан: "$recognizedText"');
      return recognizedText;

    } catch (e, st) {
      _logger.e('⛔ Ошибка во время распознавания файла: $e', stackTrace: st);
      return 'Ошибка распознавания';
    }
  }

  void dispose() {
    _logger.i('SpeechService disposed.');
  }
}