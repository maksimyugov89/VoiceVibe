# VoiceVibe

VoiceVibe — это кроссплатформенное Flutter‑приложение для **голосовых заметок с распознаванием речи**.  
Оно позволяет быстро записывать голос, автоматически превращать его в текст, просматривать заметки в ленте и календаре, редактировать и экспортировать.

## Основные возможности

- **Запись голосовых заметок**
  - Запись с микрофона с использованием `record_platform_interface`.
  - Поддержка нескольких форматов (предпочтительно WAV/PCM16, при необходимости AAC).
  - Сохранение аудиофайлов в локальное хранилище (`ApplicationDocumentsDirectory`).

- **Автораспознавание речи (speech‑to‑text)**
  - Локальное распознавание речи на базе `vosk_flutter_2`.
  - Поддержка как минимум **двух языков** моделей: `ru` и `en` (директории `assets/model_ru` и `assets/model_en`).
  - При завершении записи создаётся заметка с временным текстом «Идёт распознавание…», затем подставляется итоговая расшифровка или сообщение об ошибке.

- **Управление заметками**
  - Список всех заметок на экране `VoiceNotesScreen` с современными карточками (`ModernNoteCard`).
  - Сохранение текста заметки в `.txt` рядом с аудио (первая строка — заголовок, далее — текст).
  - Редактирование заметок на отдельном экране `EditNoteScreen`.
  - Удаление заметок вместе с аудио и текстом.
  - Экспорт заметки (аудио + текст) через системный шаринг (`share_plus`).

- **Календарь**
  - Экран `CalendarScreen` с интеграцией `table_calendar`.
  - Просмотр заметок по дате.

- **Настройки и персонализация**
  - Экран `SettingsScreen`:
    - Переключение светлой / тёмной темы (`ThemeMode`) с сохранением через `SharedPreferences` (`SettingsService`).
    - Выбор языка распознавания речи (например, ru/en) с перезапуском приложения для подгрузки нужной модели.
  - Темы и стили в `app_theme.VoiceVibeTheme` с градиентами, кастомной палитрой и анимациями.

- **UI/UX**
  - Современный интерфейс с плавными анимациями:
    - Анимированная кнопка записи (`AnimatedRecordButton`).
    - Плавающая нижняя навигация (`FloatingBottomNavigation`) с тремя вкладками: Заметки / Календарь / Настройки.
    - Экран загрузки (`SplashScreen`) с Lottie‑анимацией (`assets/lottie/splash_animation.json`).

- **Логирование и диагностика**
  - Логи через `logger` для инициализации сервисов, работы аудио и распознавания.
  - Обработка ошибок загрузки моделей Vosk и чтения `AssetManifest.json`.
 
## Скриншоты

<div align="center">

<img src="https://github.com/user-attachments/assets/1557feb7-54cc-4e06-811c-2244eb7e78dd" alt="screenshot 1" width="260" />
<img src="https://github.com/user-attachments/assets/990d0a51-cc17-40bd-9ec7-0d586217abd0" alt="screenshot 2" width="260" />
<img src="https://github.com/user-attachments/assets/4fb876cf-8404-4f9e-acb4-7d2a94347a66" alt="screenshot 3" width="260" />

<img src="https://github.com/user-attachments/assets/4897d670-5412-438c-acc5-04aec43e348d" alt="screenshot 4" width="260" />
<img src="https://github.com/user-attachments/assets/8ba99fb5-6478-4b07-bd3a-3859816eda12" alt="screenshot 5" width="260" />
<img src="https://github.com/user-attachments/assets/75064a58-9e15-4eb4-afbe-f7fd912e47b2" alt="screenshot 6" width="260" />

<img src="https://github.com/user-attachments/assets/78434254-7de0-4ad9-9035-8872748f5b36" alt="screenshot 7" width="260" />
<img src="https://github.com/user-attachments/assets/e541aa4d-8a71-449e-92df-6e8a73453c76" alt="screenshot 8" width="260" />
<img src="https://github.com/user-attachments/assets/f31a47eb-6df5-445d-956d-02964a796707" alt="screenshot 9" width="260" />

<img src="https://github.com/user-attachments/assets/0b5c2ef9-0c6c-4b77-be66-aecef092f532" alt="screenshot 10" width="260" />
<img src="https://github.com/user-attachments/assets/91bab22a-1e87-46f6-b4e7-f784ad45948f" alt="screenshot 11" width="260" />
<img src="https://github.com/user-attachments/assets/3357dc08-5c4e-4ba9-96b3-51f5cdbb3e5e" alt="screenshot 12" width="260" />

<img src="https://github.com/user-attachments/assets/e315cc54-151d-4575-9694-ad72adea4023" alt="screenshot 13" width="260" />
<img src="https://github.com/user-attachments/assets/9f7a60f5-06f3-4463-8c10-0ce7dec9023a" alt="screenshot 14" width="260" />
<img src="https://github.com/user-attachments/assets/9b30e77a-e956-4fbe-8c37-ee19737e5688" alt="screenshot 15" width="260" />

<img src="https://github.com/user-attachments/assets/8d63b028-fa47-4c2b-8418-4c1d6b53db95" alt="screenshot 16" width="260" />
<img src="https://github.com/user-attachments/assets/62f35f15-c702-4154-aec7-b6a9c2954e89" alt="screenshot 17" width="260" />
<img src="https://github.com/user-attachments/assets/c59818c2-d22b-47b1-9f58-e49c6972c620" alt="screenshot 18" width="260" />

</div>
## Архитектура

- `lib/main.dart`
  - Точка входа, инициализация `SettingsService`, загрузка сохранённых настроек темы и языка.
  - Создание и инициализация сервисов:
    - `AudioService` — запись/проигрывание/экспорт аудио.
    - `SpeechService` — распознавание аудиофайлов в текст.
    - `SettingsService` — сохранение пользовательских настроек (тема, язык).
  - Загрузка заметок с диска (по аудио + связанный `.txt`).
  - Передача состояния и колбэков в `HomeScreen`.

- `lib/screens/home_screen.dart`
  - Корневой экран с `IndexedStack` и нижней навигацией:
    - `VoiceNotesScreen` — список голосовых заметок.
    - `CalendarScreen` — календарный просмотр.
    - `SettingsScreen` — настройки.

- `lib/screens/voice_notes_screen_modern.dart`
  - Управление записью:
    - `AudioService.startRecording()` / `stopRecording()` / пауза / продолжение.
    - Визуальный индикатор записи (`SoundWaveVisualizer`).
  - Добавление, редактирование, удаление и экспорт заметок.
  - Воспроизведение аудио заметок через `AudioService.playNote()`.

- `lib/services/audio_service.dart`
  - Запись аудио:
    - Создание рекордера через `RecordPlatform.instance`.
    - Выбор поддерживаемого энкодера (`wav` / `pcm16bits` / `aacLc`).
    - Сохранение файла с уникальным именем в `ApplicationDocumentsDirectory`.
  - Воспроизведение и управление плеером через `just_audio` + `audio_session`.
  - Экспорт заметок через `share_plus`.
  - Сохранение и удаление связанного текстового файла.

- `lib/services/speech_service.dart`
  - Развёртывание моделей Vosk из ассетов в локальное хранилище.
  - Загрузка нужной модели по языковому коду (`model_ru`, `model_en`).
  - Распознавание аудиофайлов целиком (`acceptWaveformBytes`) и разбор JSON‑результата (`text`).

- `lib/theme/app_theme.dart`
  - Оформление светлой и тёмной темы, цветовые схемы, градиенты, стили для карточек и кнопок.

## Требования к окружению

- **Flutter**: SDK `>=3.2.0 <4.0.0`
- **Поддерживаемые платформы**:
  - Android
  - iOS
  - Web
  - Windows
  - macOS
  - Linux

## Основные зависимости

Из `pubspec.yaml`:

- `record`, `record_platform_interface` — запись аудио.
- `just_audio`, `audio_session` — воспроизведение и управление аудиосессией.
- `vosk_flutter_2` — офлайн‑распознавание речи.
- `path_provider` — доступ к локальному хранилищу.
- `permission_handler` — разрешения на микрофон.
- `table_calendar` — календарный вид.
- `share_plus` — экспорт файлов и текста.
- `lottie` — анимация сплэша.
- `logger` — логирование.
- `intl` — форматирование дат.
- `shared_preferences` — хранение настроек.

## Установка и запуск

1. **Клонировать репозиторий**

```bash
git clone https://github.com/maksimyugov89/VoiceVibe.git
cd VoiceVibe
```

2. **Установить зависимости**

```bash
flutter pub get
```

3. **Запуск приложения**

- Android/iOS:

```bash
flutter run
```

- Web:

```bash
flutter run -d chrome
```

4. **Сборка релиза (пример для Android)**

```bash
flutter build apk --release
```

## Ассеты и модели Vosk

Модели распознавания хранятся в:

- `assets/model_ru/` — русская модель.
- `assets/model_en/` — английская модель.

Пути к ассетам задекларированы в `pubspec.yaml` в секции `flutter/assets`.  
При первом запуске для каждого языка модель разворачивается во внутреннюю директорию приложения (`ApplicationDocumentsDirectory/model_<lang>`), затем `SpeechService` использует её для распознавания.

## Настройки языка и темы

- Тема (light/dark) и язык (`ru` / `en`) сохраняются через `SettingsService` в `SharedPreferences`.
- При смене языка приложение запрашивает перезапуск, чтобы прогрузить новую модель Vosk.

## Права и ограничения

Для корректной работы приложению требуются:

- Доступ к **микрофону** (запись звука).
- Доступ к **локальному хранилищу** для сохранения аудио и текста заметок.

Если разрешения не выданы, приложение уведомит пользователя (через `SnackBar`) и запись не начнётся.

## Планы по развитию (идеи)

- Добавить теги и категории для заметок.
- Синхронизацию с облаком.
- Фильтры/поиск по тексту и дате.
- Более продвинутую визуализацию звука и прогресса распознавания.
