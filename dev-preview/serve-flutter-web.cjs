/**
 * Статический сервер для скомпилированного Flutter web-приложения Hikari.
 *
 *   node dev-preview/serve-flutter-web.cjs flutter-web
 *
 * Сборка делается с --base-href /InterfaceForge/ (для GitHub Pages), а здесь
 * <base> на лету переписывается на /, поэтому приложение работает от корня
 * preview-хоста. Неизвестные пути отдаются index.html (SPA-роутинг go_router).
 */
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(process.argv[2] || path.join(__dirname, '..', 'flutter-web'));
const port = Number(process.env.PORT || 4173);

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.map': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.wasm': 'application/wasm',
  '.txt': 'text/plain; charset=utf-8',
};

function indexHtml() {
  const file = path.join(root, 'index.html');
  if (!fs.existsSync(file)) return null;
  return fs
    .readFileSync(file, 'utf8')
    .replace(/<base\s+href="[^"]*"\s*\/?>/i, '<base href="/">');
}

const server = http.createServer((req, res) => {
  let pathname;
  try {
    pathname = decodeURIComponent(new URL(req.url || '/', 'http://localhost').pathname);
  } catch {
    res.writeHead(400);
    return res.end('Bad request');
  }

  const html = indexHtml();
  const isRoot = pathname === '/' || pathname === '/index.html';
  const relative = pathname.replace(/^\/+/, '');
  const candidate = path.resolve(root, relative);

  if (candidate.startsWith(root + path.sep) && fs.existsSync(candidate) && fs.statSync(candidate).isFile()) {
    const ext = path.extname(candidate).toLowerCase();
    res.setHeader('Content-Type', MIME[ext] || 'application/octet-stream');
    res.setHeader('Cache-Control', 'no-cache');
    return fs.createReadStream(candidate).pipe(res);
  }

  // SPA fallback + корень: отдаём index.html с переписанным base href.
  if (html && (isRoot || !path.extname(pathname))) {
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.setHeader('Cache-Control', 'no-store');
    return res.end(html);
  }

  res.writeHead(404);
  res.end('Not found');
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Hikari Flutter web served from ${root}`);
  console.log(`Listening on http://0.0.0.0:${port}/`);
});
