# InterfaceForge
A cross-platform app for customizing the interface of phones and PCs.

## Проекты

- [`hikari/`](hikari/) — Flutter MVP для Windows и Android: локальный каталог японских тем и обоев. Исходники импортированы из Google Drive (`Hikari/hikari-source.zip`). Описание, запуск и сборка — в [hikari/README.md](hikari/README.md).
- [`dev-preview/`](dev-preview/) — браузерное live-превью Hikari на реальных данных, обоях и шрифтах из `hikari/assets`. Нужно для быстрой доработки интерфейса без Flutter SDK.

## Настоящее Flutter-приложение

Workflow [`.github/workflows/deploy-hikari-web.yml`](.github/workflows/deploy-hikari-web.yml)
на каждом пуше в `main` или в текущую ветку запускает `analyze`, юнит-тесты и
`flutter build web --release --base-href /InterfaceForge/`, после чего всегда
выкладывает результат артефактом `hikari-web` и — если Pages включён — деплоит
его через `actions/deploy-pages`.

**Адрес после включения Pages:** https://otshelniks.github.io/InterfaceForge/

> Создать Pages-сайт из workflow или токеном интеграции нельзя: REST-эндпоинт
> `POST /repos/{owner}/{repo}/pages` требует `Administration: write`, которого
> нет у `GITHUB_TOKEN` ни при каких `permissions` ([документация GitHub](https://docs.github.com/en/rest/pages/pages#create-a-github-pages-site)).
> Один раз зайдите в
> [Settings → Pages](https://github.com/OTSHELNIKS/InterfaceForge/settings/pages)
> и выберите **Source: GitHub Actions** ([инструкция](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow)) —
> следующий пуш (или **Run workflow**) задеплоит автоматически. Пока этого не
> сделано, CI проверяет наличие Pages, пропускает деплой с понятной подсказкой
> в step summary, но сборка остаётся зелёной и артефакт доступен.

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
