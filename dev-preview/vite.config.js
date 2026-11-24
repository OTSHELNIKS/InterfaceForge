import { defineConfig } from 'vite';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(here, '..');
const hikariRoot = path.join(repoRoot, 'hikari');
const assetsDir = path.join(hikariRoot, 'assets');

const WRITABLE = new Set([
  'hikari/assets/catalog/catalog.json',
  'dev-preview/src/styles.css',
]);

const EDITABLE = [
  { path: 'hikari/assets/catalog/catalog.json', label: 'Каталог (JSON)', language: 'json' },
  { path: 'dev-preview/src/styles.css', label: 'Стили превью (CSS)', language: 'css' },
];

const TEXT_EXTENSIONS = new Set([
  '.dart', '.json', '.yaml', '.yml', '.md', '.py', '.html', '.css', '.js', '.ts',
  '.kt', '.java', '.cpp', '.h', '.cc', '.c', '.kts', '.gradle', '.xml',
  '.properties', '.txt', '.iml', '.lock', '.cfg', '.cmake', '.rc', '.manifest',
  '.plist', '.gitignore', '.sh', '.bat',
]);
const TEXT_BASENAMES = new Set([
  'LICENSE', 'README.md', 'pubspec.lock', '.metadata', '.gitignore',
  'analysis_options.yaml', 'gradle-wrapper.properties',
]);
const IGNORED_DIRS = new Set([
  '.git', 'node_modules', 'dist', 'build', '__pycache__', 'google_drive',
  '.idea', 'ephemeral', '.plugin_symlinks', '.cache',
]);

const MIME = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.ttf': 'font/ttf',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
};

function isTextFile(normalizedPath) {
  return (
    TEXT_EXTENSIONS.has(path.extname(normalizedPath).toLowerCase()) ||
    TEXT_BASENAMES.has(path.basename(normalizedPath))
  );
}

function collect(dir, out = []) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  for (const entry of entries) {
    if (IGNORED_DIRS.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) collect(full, out);
    else if (entry.isFile()) out.push(full);
  }
  return out;
}

function computeHash() {
  const files = [...collect(hikariRoot), ...collect(here)].sort();
  const hash = crypto.createHash('sha1');
  for (const file of files) {
    try {
      const stat = fs.statSync(file);
      const rel = path.relative(repoRoot, file).split(path.sep).join('/');
      hash.update(`${rel}:${stat.mtimeMs}:${stat.size}\n`);
    } catch {
      // файл исчез между readdir и stat — игнорируем
    }
  }
  return hash.digest('hex').slice(0, 16);
}

function normalizeRel(value) {
  if (typeof value !== 'string' || !value.trim()) throw new Error('Не указан путь к файлу');
  const absolute = path.resolve(repoRoot, value);
  const relative = path.relative(repoRoot, absolute);
  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    throw new Error('Недопустимый путь');
  }
  return relative.split(path.sep).join('/');
}

function readable(value) {
  const normalized = normalizeRel(value);
  if (!(normalized.startsWith('hikari/') || normalized.startsWith('dev-preview/'))) {
    throw new Error('Файл вне проекта');
  }
  if (!isTextFile(normalized)) throw new Error('Бинарный файл нельзя показать в редакторе');
  const absolute = path.join(repoRoot, normalized);
  if (!fs.existsSync(absolute) || !fs.statSync(absolute).isFile()) {
    throw new Error('Файл не найден');
  }
  return { normalized, absolute };
}

function send(res, payload, status = 200) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(payload));
}

function hikariDevApi() {
  return {
    name: 'hikari-dev-api',
    configureServer(server) {
      // 1. Статика из hikari/assets: /wallpapers/*, /fonts/*, /textures/*, /catalog/*
      server.middlewares.use((req, res, next) => {
        let pathname;
        try {
          pathname = decodeURIComponent(new URL(req.url || '/', 'http://localhost').pathname);
        } catch {
          return next();
        }
        const served = ['/wallpapers/', '/fonts/', '/textures/', '/catalog/'];
        if (!served.some((prefix) => pathname.startsWith(prefix))) return next();

        const absolute = path.resolve(assetsDir, pathname.slice(1));
        if (!absolute.startsWith(assetsDir + path.sep)) {
          res.statusCode = 403;
          return res.end('Forbidden');
        }
        if (!fs.existsSync(absolute) || !fs.statSync(absolute).isFile()) return next();

        res.setHeader('Content-Type', MIME[path.extname(absolute).toLowerCase()] || 'application/octet-stream');
        res.setHeader('Cache-Control', 'no-cache');
        fs.createReadStream(absolute).pipe(res);
      });

      // 2. Небольшое API для live-обновлений и встроенного редактора
      server.middlewares.use((req, res, next) => {
        const url = new URL(req.url || '/', 'http://localhost');
        if (!url.pathname.startsWith('/api/')) return next();

        try {
          if (req.method === 'GET' && url.pathname === '/api/live-hash') {
            return send(res, { hash: computeHash() });
          }

          if (req.method === 'GET' && url.pathname === '/api/editable') {
            return send(res, { files: EDITABLE });
          }

          if (req.method === 'GET' && url.pathname === '/api/tree') {
            const files = collect(hikariRoot)
              .map((file) => path.relative(repoRoot, file).split(path.sep).join('/'))
              .filter(isTextFile)
              .sort();
            return send(res, { files });
          }

          if (req.method === 'GET' && url.pathname === '/api/file') {
            const { normalized, absolute } = readable(url.searchParams.get('path'));
            return send(res, {
              path: normalized,
              content: fs.readFileSync(absolute, 'utf8'),
            });
          }

          if (req.method === 'POST' && url.pathname === '/api/file') {
            let body = '';
            req.on('data', (chunk) => {
              body += chunk;
              if (body.length > 2_000_000) req.destroy();
            });
            req.on('end', () => {
              try {
                const payload = JSON.parse(body || '{}');
                const normalized = normalizeRel(payload.path);
                if (!WRITABLE.has(normalized)) {
                  throw new Error('Этот файл нельзя редактировать из превью');
                }
                if (typeof payload.content !== 'string') throw new Error('Нет содержимого');
                if (normalized.endsWith('.json')) JSON.parse(payload.content);
                fs.writeFileSync(path.join(repoRoot, normalized), payload.content, 'utf8');
                return send(res, { ok: true, path: normalized });
              } catch (error) {
                return send(res, { error: error.message }, 400);
              }
            });
            return;
          }

          return send(res, { error: 'Неизвестный endpoint' }, 404);
        } catch (error) {
          return send(res, { error: error.message }, 400);
        }
      });
    },
  };
}

export default defineConfig({
  root: here,
  publicDir: false,
  plugins: [hikariDevApi()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    allowedHosts: true,
    hmr: false,
    fs: { allow: [repoRoot], strict: false },
  },
  preview: {
    host: '0.0.0.0',
    port: 4173,
  },
});
