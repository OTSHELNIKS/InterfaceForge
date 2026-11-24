# InterfaceForge
A cross-platform app for customizing the interface of phones and PCs.

## Проекты

- [`hikari/`](hikari/) — Flutter MVP для Windows и Android: локальный каталог японских тем и обоев. Исходники импортированы из Google Drive (`Hikari/hikari-source.zip`). Описание, запуск и сборка — в [hikari/README.md](hikari/README.md).
- [`dev-preview/`](dev-preview/) — браузерное live-превью Hikari на реальных данных, обоях и шрифтах из `hikari/assets`. Нужно для быстрой доработки интерфейса без Flutter SDK.

## Настоящее Flutter-приложение

Workflow [`.github/workflows/deploy-hikari-web.yml`](.github/workflows/deploy-hikari-web.yml)
на каждом пуше в `main` или в текущую ветку запускает `analyze`, юнит-тесты и
`flutter build web --release --base-href /InterfaceForge/`, всегда выкладывает
результат артефактом `hikari-web` и деплоит его через `actions/deploy-pages`.

**Опубликовано:** https://otshelniks.github.io/InterfaceForge/ — страница отдаёт
`Hikari · 光`, а `go_router` переводит на `#/home`. Последний успешный деплой:
[run 45486530211](https://github.com/OTSHELNIKS/InterfaceForge/actions/runs/45486530211).

Pages в этом репозитории уже включён (**Source: GitHub Actions**). При переносе
workflow в новый репозиторий этот шаг нужно сделать один раз вручную: эндпоинт
`POST /repos/{owner}/{repo}/pages` требует `Administration: write`, которого нет
у `GITHUB_TOKEN` ([документация GitHub](https://docs.github.com/en/rest/pages/pages#create-a-github-pages-site)).
Пока Pages выключен, CI честно пропускает только деплой с подсказкой в step
summary — сборка и артефакт остаются доступны.

Деплой идёт в окружение `hikari-pages`, а не в автоматический `github-pages`:
у последнего по умолчанию branch policy разрешает только `main`, а здесь нужно
публиковать и рабочую ветку. Поэтому пуши в `main` и в
`arena/45285b5c-interfaceforge` деплоятся одинаково.

Скачать и посмотреть сборку локально:

```sh
gh run download <run-id> -n hikari-web -D flutter-web
node dev-preview/serve-flutter-web.cjs flutter-web   # http://localhost:4173/
```

Сервер переписывает `<base href="/InterfaceForge/">` на `/` и поддерживает
SPA-роутинг, поэтому в preview-хосте приложение работает от корня.

> В веб-сборке недоступен системный канал `hikari/system`: темы меняют
> оформление внутри приложения, а установка обоев показывает понятное
> сообщение. Для Windows/Android собирайте нативно по `hikari/README.md`.

## Live-превью для доработки

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

> Flutter SDK и pub.dev недоступны в песочнице Arena, поэтому локальное
> превью — это веб-визуализация, а не скомпилированное Flutter-приложение.
> Настоящая сборка происходит в GitHub Actions (у раннера есть доступ к pub.dev).
