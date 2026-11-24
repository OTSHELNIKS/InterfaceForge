# Hikari · 光

Flutter MVP для Windows и Android: локальный каталог тем и обоев в японской эстетике.

## Возможности

- 16 работ и 4 коллекции из `assets/catalog/catalog.json`; поиск, фильтрация и сортировка.
- Избранное и настройки сохраняются локально через SharedPreferences.
- Обои дня, экран работы с палитрой и применение через канал `hikari/system`.
- Адаптивная навигация для компьютера и телефона.

## Запуск и сборка

Нужен Flutter 3.50.1 (Dart 3.14), инструменты соответствующей платформы и доступ к pub.dev.

```sh
python3 tools/check_assets.py   # пути к ассетам из catalog.json существуют
flutter pub get
flutter analyze
flutter test test/catalog_test.dart test/providers_test.dart test/assets_test.dart
flutter run -d windows   # на Windows с Visual Studio и workload Desktop development with C++
flutter run -d android   # с Android SDK и совместимой версией JDK
flutter build windows
flutter build apk --release
```

При выпуске Android APK настройте собственный ключ подписи. Проверяйте работу на реальном устройстве и на целевой версии Windows: нативные интеграции в текущем окружении не собирались и не проверялись на устройствах.

## Live-превью в браузере

В репозитории есть [`../dev-preview/`](../dev-preview/) — веб-визуализация на реальных
`assets/catalog/catalog.json`, обоях и шрифтах. Она поднимается через Vite и сама
обновляется при правке файлов; внутри есть редактор каталога и CSS.

```sh
cd ../dev-preview
npm install
npm run dev
```

Это не скомпилированное Flutter-приложение (в песочнице Arena нет Flutter SDK и
доступа к pub.dev), а способ дорабатывать интерфейс и сразу видеть изменения.

## Веб-сборка и GitHub Pages

Настоящая веб-версия собирается в CI — у раннера GitHub Actions есть Flutter SDK
и доступ к pub.dev. Workflow
[`../.github/workflows/deploy-hikari-web.yml`](../.github/workflows/deploy-hikari-web.yml)
запускает `analyze`, юнит-тесты, `flutter build web`, всегда сохраняет результат
артефактом `hikari-web` и деплоит на Pages:
**https://otshelniks.github.io/InterfaceForge/**

Pages нужно один раз включить в
[Settings → Pages](https://github.com/OTSHELNIKS/InterfaceForge/settings/pages)
(Source: GitHub Actions): создание Pages-сайта через API требует
`Administration: write`, которого нет у `GITHUB_TOKEN`, поэтому workflow
проверяет сайт, пропускает деплой с подсказкой и остаётся зелёным. Артефакт
при этом доступен всегда:

```sh
gh run download <run-id> -n hikari-web -D ../flutter-web
node ../dev-preview/serve-flutter-web.cjs ../flutter-web
```

Локально то же самое:

```sh
flutter pub get
flutter build web --release --base-href /InterfaceForge/
# результат: build/web/
```

Для веба `SystemService` использует условный импорт вместо `dart:io`:
`lib/core/services/system_service_staging_io.dart` (Windows/Android) и
`system_service_staging.dart` (web). Канал `hikari/system` на вебе отсутствует,
поэтому темы применяются только внутри приложения, а установка обоев возвращает
`MissingPluginException` с понятным сообщением.

## Ограничения платформ

- Android: установка обоев требует системного разрешения; тема меняет оформление приложения, но не общесистемный режим Android. Поддержка установки экрана блокировки и поведение зависят от устройства.
- Windows: обои рабочего стола и светлый/тёмный режим системы применяются через Win32. Windows не предоставляет этому MVP механизм установки полноценных сторонних системных тем или акцентного цвета через канал.
- Web: системные обои и системная тема недоступны; `DeviceInfo` возвращает заглушку «Web / Браузер». Всё остальное (каталог, избранное, палитры, темы оформления, адаптивная навигация) работает.
- Ресурсы каталога встроены в приложение; сервер и загрузка новых пакетов не предусмотрены.

## Ресурсы

Шрифты Inter, Playfair Display, Caveat Brush, Yuji Syuku и Shippori Mincho распространяются по SIL Open Font License; тексты лицензий находятся в `assets/fonts/licenses/`. Изображения и текстуры генерируются локальными скриптами в `tools/`.
