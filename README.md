#  <img width="1024" height="1024" alt="app_icon" src="https://github.com/user-attachments/assets/1fc85214-3e02-426f-ba3b-a8efbf7f6bfc" />
VoiceVibe

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
<p align="center">
  <img src="https://github.com/user-attachments/assets/c27b955b-f91f-4e95-9757-f3067d743678" width="250" />
  <img src="https://github.com/user-attachments/assets/80f2fbdf-4364-4a41-89a7-21d807bf4c44" width="250" />
  <img src="https://github.com/user-attachments/assets/879e11d8-6235-4be6-bbf2-d90a5adbfae3" width="250" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/58481839-acf5-4989-84c2-357041c31f8f" width="250" />
  <img src="https://github.com/user-attachments/assets/76d9113f-265c-4b27-9eaf-91ac6e6d44c0" width="250" />
  <img src="https://github.com/user-attachments/assets/ab192383-d829-4173-b6fa-0133d4f9f699" width="250" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/78322c57-7bbc-4dc4-a789-f652dbd10d31" width="250" />
  <img src="https://github.com/user-attachments/assets/5d150b22-c69a-454d-afb9-1c84a59eaf16" width="250" />
</p>

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
