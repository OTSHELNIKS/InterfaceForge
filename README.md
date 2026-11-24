# InterfaceForge
A cross-platform app for customizing the interface of phones and PCs.

## Проекты

- [`hikari/`](hikari/) — Flutter MVP для Windows и Android: локальный каталог японских тем и обоев. Исходники импортированы из Google Drive (`Hikari/hikari-source.zip`). Описание, запуск и сборка — в [hikari/README.md](hikari/README.md).
- [`dev-preview/`](dev-preview/) — браузерное live-превью Hikari на реальных данных, обоях и шрифтах из `hikari/assets`. Нужно для быстрой доработки интерфейса без Flutter SDK.

## Live-превью

```sh
cd dev-preview
npm install
npm run dev
```

Откройте выданный адрес (порт 5173). Превью само обновляется при изменении
`hikari/assets/catalog/catalog.json`, картинок, шрифтов, `dev-preview/src/*`
и любых файлов проекта. В интерфейсе есть кнопка **«Редактор»**: правка
каталога и CSS сохраняется прямо в файлы репозитория, а вкладка
«Исходники» показывает Dart-код.

> Flutter SDK и pub.dev недоступны в песочнице Arena, поэтому превью — это
> веб-визуализация, а не скомпилированное Flutter-приложение. Сам Flutter-проект
> остаётся источником истины и собирается локально по `hikari/README.md`.
