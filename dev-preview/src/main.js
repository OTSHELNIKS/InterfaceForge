import './styles.css';

/**
 * Hikari · браузерное live-превью.
 * Использует реальные данные и ассеты из ../hikari/assets, поэтому любое
 * изменение catalog.json, картинок, шрифтов, CSS или исходников сразу видно.
 */

const API = {
  liveHash: '/api/live-hash',
  editable: '/api/editable',
  tree: '/api/tree',
  file: (p) => `/api/file?path=${encodeURIComponent(p)}`,
  save: '/api/file',
};

const NAV = [
  { route: 'home', label: 'Обзор', icon: 'sparkle' },
  { route: 'catalog', label: 'Каталог', icon: 'grid' },
  { route: 'favorites', label: 'Избранное', icon: 'heart' },
  { route: 'settings', label: 'Настройки', icon: 'sliders' },
];

const TOP_NAV = [
  { route: 'home', label: 'Обзор' },
  { route: 'catalog', label: 'Каталог' },
  { route: 'favorites', label: 'Избранное' },
  { route: 'settings', label: 'Настройки' },
];

const COLLECTION_IMAGES = {
  akane: 'assets/wallpapers/generated-collection-akane.jpg',
  sakura: 'assets/wallpapers/generated-collection-sakura.jpg',
  sumi: 'assets/wallpapers/generated-collection-sumi.jpg',
  aoi: 'assets/wallpapers/generated-collection-aoi.jpg',
};

const HERO_IMAGE = 'assets/wallpapers/generated-hero.jpg';

const ICON_PATHS = {
  sparkle:
    '<path d="M12 3l1.7 4.8L18.5 9.5l-4.8 1.7L12 16l-1.7-4.8L5.5 9.5l4.8-1.7L12 3z"/><path d="M19 15l.7 2 2 .7-2 .7-.7 2-.7-2-2-.7 2-.7.7-2z"/>',
  grid:
    '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
  heart:
    '<path d="M20.8 5.6a5.2 5.2 0 00-7.4 0L12 7l-1.4-1.4a5.2 5.2 0 00-7.4 7.4L12 21l8.8-8a5.2 5.2 0 000-7.4z"/>',
  heartFill:
    '<path d="M20.8 5.6a5.2 5.2 0 00-7.4 0L12 7l-1.4-1.4a5.2 5.2 0 00-7.4 7.4L12 21l8.8-8a5.2 5.2 0 000-7.4z" fill="currentColor" stroke="none"/>',
  sliders:
    '<path d="M4 7h10M18 7h2M4 17h2M10 17h10"/><circle cx="16" cy="7" r="2"/><circle cx="8" cy="17" r="2"/>',
  back: '<path d="M19 12H5M11 6l-6 6 6 6"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/>',
  sun:
    '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
  moon: '<path d="M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z"/>',
  monitor: '<rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/>',
  pencil:
    '<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/>',
  x: '<path d="M18 6L6 18M6 6l12 12"/>',
  check: '<path d="M20 6L9 17l-5-5"/>',
  copy:
    '<rect x="9" y="9" width="12" height="12" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/>',
  expand: '<path d="M8 3H3v5M16 3h5v5M8 21H3v-5M16 21h5v-5"/>',
  refresh:
    '<path d="M3 12a9 9 0 0115.5-6.2L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 01-15.5 6.2L3 16"/><path d="M3 21v-5h5"/>',
  palette:
    '<path d="M12 3a9 9 0 000 18c1.1 0 1.8-.9 1.8-1.8 0-.5-.2-.9-.5-1.2-.3-.3-.5-.7-.5-1.2 0-1 .8-1.8 1.8-1.8H16a5 5 0 005-5c0-4-4-7-9-7z"/><circle cx="7.5" cy="11" r="1" fill="currentColor"/><circle cx="10" cy="7.5" r="1" fill="currentColor"/><circle cx="15" cy="7.5" r="1" fill="currentColor"/>',
  info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
  close: '<path d="M18 6L6 18M6 6l12 12"/>',
};

const MONTHS = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

const state = {
  route: 'home',
  lastRoute: 'home',
  detail: null,
  theme: localStorage.getItem('hikari.theme') || 'light',
  favorites: new Set(JSON.parse(localStorage.getItem('hikari.favorites') || '[]')),
  filters: { query: '', type: null, collection: null, sort: 'newest' },
  activeThemeId: localStorage.getItem('hikari.activeTheme') || null,
  editorOpen: false,
  editorTab: 'hikari/assets/catalog/catalog.json',
  fileView: 'hikari/README.md',
};

let catalog = null;
let liveHash = null;
let toastTimer = null;

/* ---------------------------------------------------------------- helpers */

function h(tag, attrs = {}, ...children) {
  const node = document.createElement(tag);
  for (const [key, value] of Object.entries(attrs)) {
    if (value === null || value === undefined || value === false) continue;
    if (key === 'class') node.className = value;
    else if (key === 'style') node.style.cssText = value;
    else if (key === 'html') node.innerHTML = value;
    else if (key.startsWith('on') && typeof value === 'function') {
      node.addEventListener(key.slice(2).toLowerCase(), value);
    } else node.setAttribute(key, value === true ? '' : String(value));
  }
  for (const child of children.flat()) {
    if (child === null || child === undefined || child === false) continue;
    node.append(child instanceof Node ? child : document.createTextNode(String(child)));
  }
  return node;
}

function icon(name, size = 20) {
  return `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${ICON_PATHS[name] || ''}</svg>`;
}

function assetUrl(relative) {
  return '/' + String(relative).replace(/^assets\//, '');
}

function collectionById(id) {
  return catalog?.collections.find((c) => c.id === id) || null;
}

function itemById(id) {
  return catalog?.items.find((i) => i.id === id) || null;
}

function formatDate(iso) {
  const d = new Date(iso);
  return `${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

function plural(n, forms) {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return forms[0];
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return forms[1];
  return forms[2];
}

function hexToRgba(hex, alpha) {
  const clean = hex.replace('#', '');
  const full = clean.length === 3
    ? clean.split('').map((c) => c + c).join('')
    : clean.slice(0, 6);
  const num = parseInt(full, 16);
  return `rgba(${(num >> 16) & 255}, ${(num >> 8) & 255}, ${num & 255}, ${alpha})`;
}

function accentOf() {
  const item = state.activeThemeId ? itemById(state.activeThemeId) : null;
  return item ? (item.colors[1] || item.colors[0] || '#C9362B') : '#C9362B';
}

function isLight(hex) {
  const clean = hex.replace('#', '');
  const full = clean.length === 3
    ? clean.split('').map((c) => c + c).join('')
    : clean.slice(0, 6);
  const num = parseInt(full, 16);
  const r = (num >> 16) & 255;
  const g = (num >> 8) & 255;
  const b = num & 255;
  return 0.299 * r + 0.587 * g + 0.114 * b > 160;
}

function applyTheme() {
  // Светлая бумага — базовый образ Hikari. Тёмную тему включают вручную.
  if (state.theme === 'system') state.theme = 'light';
  const dark = state.theme === 'dark';
  const accent = accentOf();
  const root = document.documentElement;
  root.dataset.theme = dark ? 'dark' : 'light';
  root.style.setProperty('--accent', accent);
  root.style.setProperty('--accent-soft', hexToRgba(accent, 0.14));
  root.style.setProperty('--accent-strong', hexToRgba(accent, 0.3));
  root.style.setProperty('--on-accent', isLight(accent) ? '#1E1917' : '#FFFCF8');
}

function toast(message) {
  const node = document.querySelector('#toast');
  if (!node) return;
  node.textContent = message;
  node.classList.add('is-visible');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => node.classList.remove('is-visible'), 2800);
}

function assetError(message) {
  document.querySelector('#app').innerHTML = '';
  document.querySelector('#app').append(
    h('div', { class: 'fatal' },
      h('div', { class: 'fatal__mark' }, '光'),
      h('h1', {}, 'Не удалось прочитать каталог'),
      h('p', {}, message),
      h('button', { class: 'btn btn--primary', onclick: () => location.reload() }, 'Повторить'),
    ),
  );
}

/* ------------------------------------------------------------- navigation */

function parseHash() {
  const raw = location.hash.replace(/^#\/?/, '');
  if (raw.startsWith('item/')) {
    return { route: state.lastRoute || 'catalog', detail: decodeURIComponent(raw.slice(5)) };
  }
  const route = NAV.some((n) => n.route === raw) ? raw : 'home';
  return { route, detail: null };
}

function navigate(route) {
  location.hash = '/' + route;
}

function openDetail(id) {
  state.lastRoute = state.route;
  location.hash = '/item/' + encodeURIComponent(id);
}

function closeDetail() {
  location.hash = '/' + (state.lastRoute || 'catalog');
}

window.addEventListener('hashchange', () => {
  const parsed = parseHash();
  state.route = parsed.route;
  state.detail = parsed.detail;
  renderNav();
  renderContent();
  renderDetail();
});

/* -------------------------------------------------------------- filtering */

function normalize(value) {
  return String(value).trim().toLowerCase();
}

function matches(item, query) {
  if (item.title.toLowerCase().includes(query)) return true;
  if (item.titleJa.toLowerCase().includes(query)) return true;
  if (item.description.toLowerCase().includes(query)) return true;
  if ((item.type === 'theme' ? 'тема' : 'обои').includes(query)) return true;
  const col = collectionById(item.collection);
  if (col && (col.name.toLowerCase().includes(query) || col.nameJa.toLowerCase().includes(query))) return true;
  if (item.tags.some((tag) => tag.toLowerCase().includes(query))) return true;
  const hexQuery = query.replace('#', '').trim();
  if (hexQuery.length >= 2 && /^[0-9a-f]+$/.test(hexQuery)) {
    if (item.colors.some((c) => c.replace('#', '').toLowerCase().includes(hexQuery))) return true;
  }
  return false;
}

function filteredItems() {
  const query = normalize(state.filters.query);
  let result = catalog.items.filter((item) => {
    if (state.filters.type && item.type !== state.filters.type) return false;
    if (state.filters.collection && item.collection !== state.filters.collection) return false;
    return query === '' || matches(item, query);
  });
  result = [...result];
  if (state.filters.sort === 'newest') {
    result.sort((a, b) => b.date.localeCompare(a.date));
  } else if (state.filters.sort === 'popular') {
    result.sort((a, b) => b.popularity - a.popularity);
  } else {
    result.sort((a, b) => a.title.toLowerCase().localeCompare(b.title.toLowerCase()));
  }
  return result;
}

function wallpaperOfDay() {
  const list = catalog.items.filter((i) => i.type === 'wallpaper');
  if (!list.length) return null;
  const now = new Date();
  const day = Math.floor((now - new Date(now.getFullYear(), 0, 1)) / 86400000);
  return list[day % list.length];
}

/* ------------------------------------------------------------------ cards */

function sectionHead(eyebrow, title, trailing = null) {
  return h('div', { class: 'section__head' },
    h('div', {},
      h('div', { class: 'eyebrow' }, eyebrow),
      h('h2', { class: 'section__title' }, title),
    ),
    trailing,
  );
}

function paletteRow(colors) {
  return h('div', { class: 'palette' },
    ...colors.slice(0, 5).map((color) =>
      h('span', { class: 'swatch', style: `background:${color}`, title: color }),
    ),
  );
}

function itemCard(item) {
  const col = collectionById(item.collection);
  const fav = state.favorites.has(item.id);
  return h('article', {
    class: 'card work-card',
    onclick: () => openDetail(item.id),
    tabindex: '0',
    onkeydown: (e) => { if (e.key === 'Enter') openDetail(item.id); },
  },
    h('div', { class: 'work-card__media' },
      h('img', { src: assetUrl(item.assetLandscape || item.asset), alt: item.title, loading: 'lazy' }),
      h('div', { class: 'work-card__top' },
        h('span', {
          class: 'badge',
          style: `--badge:${item.type === 'theme' ? '#C9A227' : '#C9362B'}`,
        }, item.type === 'theme' ? 'Тема' : 'Обои'),
        h('button', {
          class: 'fav-btn' + (fav ? ' is-fav' : ''),
          'data-fav': item.id,
          title: fav ? 'Убрать из избранного' : 'В избранное',
          html: icon(fav ? 'heartFill' : 'heart', 18),
          onclick: (e) => { e.stopPropagation(); toggleFavorite(item.id); },
        }),
      ),
    ),
    h('div', { class: 'work-card__body' },
      h('div', { class: 'work-card__ja' }, item.titleJa),
      h('h3', { class: 'work-card__title' }, item.title),
      h('div', { class: 'work-card__meta' },
        h('span', {}, col ? col.name : item.collection),
        h('span', { class: 'dot' }, '·'),
        h('span', {}, '3840 × 2160'),
      ),
      paletteRow(item.colors),
    ),
  );
}

function itemGrid(items) {
  return h('div', { class: 'grid' }, ...items.map(itemCard));
}

function toggleFavorite(id) {
  if (state.favorites.has(id)) state.favorites.delete(id);
  else state.favorites.add(id);
  localStorage.setItem('hikari.favorites', JSON.stringify([...state.favorites]));

  document.querySelectorAll(`[data-fav="${CSS.escape(id)}"]`).forEach((button) => {
    const active = state.favorites.has(id);
    button.classList.toggle('is-fav', active);
    button.innerHTML = icon(active ? 'heartFill' : 'heart', 18);
    button.title = active ? 'Убрать из избранного' : 'В избранное';
  });

  if (state.route === 'favorites') renderContent();
  if (state.detail === id) renderDetail();
  toast(state.favorites.has(id) ? 'Добавлено в избранное' : 'Убрано из избранного');
}

/* ---------------------------------------------------------------- screens */

function renderHome() {
  const wotd = wallpaperOfDay();
  const items = [...catalog.items].sort((a, b) => b.popularity - a.popularity);
  const featured = items[0];
  const similar = items.slice(1, 4);

  return h('div', { class: 'screen screen--home' },
    h('section', { class: 'hero' },
      h('img', { class: 'hero__img', src: assetUrl(HERO_IMAGE), alt: '' }),
      h('div', { class: 'hero__fade' }),
      h('span', { class: 'hero__kanji' }, '光'),
      h('div', { class: 'hero__inner' },
        h('div', { class: 'hero__eyebrow' }, 'HIKARI · 光 · 2026'),
        h('h1', { class: 'hero__title' }, 'Красота', h('br'), 'в простых вещах'),
        h('p', { class: 'hero__desc' },
          'Японские обои и темы, которые наполняют ваш день атмосферой гармонии.'),
        h('div', { class: 'hero__buttons' },
          h('button', { class: 'btn btn--primary', onclick: () => navigate('catalog') },
            'Открыть коллекции →'),
          wotd
            ? h('button', { class: 'btn btn--light', onclick: () => openDetail(wotd.id) }, 'Обои дня')
            : null,
        ),
        h('div', { class: 'hero__foot' }, 'ЯПОНСКАЯ ЭСТЕТИКА · v1.0 · 光'),
      ),
    ),

    h('section', { class: 'section' },
      sectionHead('ОБЗОР', 'Четыре настроения',
        h('button', { class: 'text-btn', onclick: () => navigate('catalog') }, 'Смотреть все →')),
      h('div', { class: 'collections' },
        ...catalog.collections.map((col) => {
          const count = catalog.items.filter((i) => i.collection === col.id).length;
          return h('button', {
            class: 'collection',
            style: `--collection:${col.color}`,
            onclick: () => {
              state.filters = { query: '', type: null, collection: col.id, sort: 'newest' };
              navigate('catalog');
            },
          },
            h('span', { class: 'collection__media' },
              h('img', { src: assetUrl(COLLECTION_IMAGES[col.id] || HERO_IMAGE), alt: col.name, loading: 'lazy' }),
            ),
            h('span', { class: 'collection__body' },
              h('span', { class: 'collection__name' }, col.name),
              h('span', { class: 'collection__desc' }, col.description),
              h('span', { class: 'collection__count' },
                `${count} ${plural(count, ['обоев', 'обоев', 'обоев'])} →`),
            ),
          );
        }),
      ),
    ),

    h('section', { class: 'section' },
      sectionHead('КАТАЛОГ', 'Все работы',
        h('button', { class: 'text-btn', onclick: () => navigate('catalog') }, 'Фильтры →')),
      h('div', { class: 'home-catalog' },
        h('div', { class: 'grid home-catalog__grid' }, ...items.map(itemCard)),
        h('aside', { class: 'home-detail' },
          h('div', { class: 'home-detail__media' },
            h('img', { src: assetUrl(featured.assetLandscape || featured.asset), alt: featured.title }),
            h('button', {
              class: 'fav-btn' + (state.favorites.has(featured.id) ? ' is-fav' : ''),
              'data-fav': featured.id,
              title: 'В избранное',
              html: icon(state.favorites.has(featured.id) ? 'heartFill' : 'heart', 18),
              onclick: (e) => { e.stopPropagation(); toggleFavorite(featured.id); },
            }),
          ),
          h('div', { class: 'home-detail__body' },
            h('div', { class: 'home-detail__ja' }, featured.titleJa),
            h('h3', {}, featured.title),
            h('p', {}, featured.description),
            h('div', { class: 'tag-row' },
              ...featured.tags.slice(0, 3).map((tag) => h('span', { class: 'tag' }, tag)),
            ),
            paletteRow(featured.colors),
            h('div', { class: 'home-detail__res' }, '3840 × 2160 · 2560 × 1440 · Mobile'),
            h('button', {
              class: 'btn btn--primary btn--block',
              onclick: () => openDetail(featured.id),
            }, 'Открыть работу →'),
            h('div', { class: 'home-detail__similar' },
              h('span', { class: 'settings-label' }, 'Похожие обои'),
              h('div', { class: 'similar-grid' },
                ...similar.map((item) => h('button', {
                  class: 'similar-thumb',
                  onclick: () => openDetail(item.id),
                }, h('img', { src: assetUrl(item.assetLandscape || item.asset), alt: item.title }))),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

function renderCatalogScreen() {
  const results = filteredItems();

  const search = h('label', { class: 'search' },
    h('span', { class: 'search__icon', html: icon('search', 18) }),
    h('input', {
      id: 'search-input',
      type: 'search',
      placeholder: 'Название, тег, коллекция или HEX-цвет…',
      value: state.filters.query,
      oninput: (e) => { state.filters.query = e.target.value; renderCatalogResults(); },
    }),
  );

  const chips = h('div', { class: 'chips' },
    ...[
      { value: null, label: 'Все' },
      { value: 'theme', label: 'Темы' },
      { value: 'wallpaper', label: 'Обои' },
    ].map((option) => h('button', {
      class: 'chip' + (state.filters.type === option.value ? ' is-active' : ''),
      'data-type': option.value === null ? '' : option.value,
      onclick: (e) => {
        state.filters.type = option.value;
        document.querySelectorAll('.chip[data-type]').forEach((c) => {
          c.classList.toggle('is-active', c.dataset.type === (option.value || ''));
        });
        renderCatalogResults();
        e.currentTarget.blur();
      },
    }, option.label)),
  );

  const collectionSelect = h('select', {
    id: 'collection-select',
    class: 'select',
    onchange: (e) => { state.filters.collection = e.target.value || null; renderCatalogResults(); },
  },
    h('option', { value: '' }, 'Все коллекции'),
    ...catalog.collections.map((col) => h('option', {
      value: col.id,
      selected: state.filters.collection === col.id ? 'selected' : null,
    }, `${col.name} · ${col.nameJa}`)),
  );

  const sortSelect = h('select', {
    id: 'sort-select',
    class: 'select',
    onchange: (e) => { state.filters.sort = e.target.value; renderCatalogResults(); },
  },
    ...[
      { value: 'newest', label: 'Сначала новые' },
      { value: 'popular', label: 'По популярности' },
      { value: 'alphabetical', label: 'По алфавиту' },
    ].map((option) => h('option', {
      value: option.value,
      selected: state.filters.sort === option.value ? 'selected' : null,
    }, option.label)),
  );

  const reset = h('button', {
    class: 'text-btn text-btn--muted',
    onclick: () => {
      state.filters = { query: '', type: null, collection: null, sort: 'newest' };
      const input = document.querySelector('#search-input');
      if (input) input.value = '';
      document.querySelector('#collection-select').value = '';
      document.querySelector('#sort-select').value = 'newest';
      document.querySelectorAll('.chip[data-type]').forEach((c) => {
        c.classList.toggle('is-active', c.dataset.type === '');
      });
      renderCatalogResults();
    },
  }, h('span', { html: icon('refresh', 15) }), 'Сбросить');

  return h('div', { class: 'screen' },
    h('div', { class: 'page-head' },
      h('div', { class: 'eyebrow' }, 'КАТАЛОГ · 光'),
      h('h1', { class: 'page-title' }, 'Каталог'),
      h('p', { class: 'page-sub' }, `${catalog.items.length} ${plural(catalog.items.length, ['работа', 'работы', 'работ'])} · 4 коллекции · темы и обои`),
    ),
    h('div', { class: 'card controls' },
      search,
      h('div', { class: 'controls__row' },
        chips,
        h('div', { class: 'controls__selects' }, collectionSelect, sortSelect, reset),
      ),
    ),
    h('div', { class: 'results' },
      h('div', { class: 'results__label', id: 'catalog-count' }),
      h('div', { class: 'grid', id: 'catalog-grid' }),
    ),
  );
}

function renderCatalogResults() {
  const grid = document.querySelector('#catalog-grid');
  const count = document.querySelector('#catalog-count');
  if (!grid || !count) return;
  const results = filteredItems();
  const n = results.length;
  count.textContent = `${n} ${plural(n, ['работа', 'работы', 'работ'])} · ${catalog.collections.length} коллекции`;
  grid.innerHTML = '';
  if (!n) {
    grid.append(h('div', { class: 'empty' },
      h('span', { class: 'empty__mark' }, '光'),
      h('h3', {}, 'Ничего не нашлось'),
      h('p', {}, 'Попробуйте другой запрос или сбросьте фильтры.'),
    ));
    grid.classList.add('grid--empty');
  } else {
    grid.classList.remove('grid--empty');
    results.forEach((item) => grid.append(itemCard(item)));
  }
}

function renderFavorites() {
  const items = catalog.items.filter((i) => state.favorites.has(i.id));
  return h('div', { class: 'screen' },
    h('div', { class: 'page-head' },
      h('div', { class: 'eyebrow' }, 'ИЗБРАННОЕ · お気に入り'),
      h('h1', { class: 'page-title' }, 'Избранное'),
      h('p', { class: 'page-sub' }, `${items.length} ${plural(items.length, ['работа', 'работы', 'работ'])} сохранено на этом устройстве`),
    ),
    items.length
      ? itemGrid(items)
      : h('div', { class: 'card empty empty--big' },
          h('span', { class: 'empty__mark' }, '♡'),
          h('h3', {}, 'Пока пусто'),
          h('p', {}, 'Нажмите на сердечко на карточке работы — она появится здесь.'),
          h('button', { class: 'btn btn--primary', onclick: () => navigate('catalog') }, 'Открыть каталог'),
        ),
  );
}

function themeModeChip(value, label, iconName) {
  return h('button', {
    class: 'mode-chip' + (state.theme === value ? ' is-active' : ''),
    onclick: () => {
      state.theme = value;
      localStorage.setItem('hikari.theme', value);
      applyTheme();
      updateThemeButton();
      renderContent();
    },
  }, h('span', { html: icon(iconName, 18) }), label);
}

function renderSettings() {
  const active = state.activeThemeId ? itemById(state.activeThemeId) : null;
  return h('div', { class: 'screen' },
    h('div', { class: 'page-head' },
      h('div', { class: 'eyebrow' }, 'НАСТРОЙКИ · 設定'),
      h('h1', { class: 'page-title' }, 'Настройки'),
    ),

    h('section', { class: 'card settings-card' },
      h('div', { class: 'settings-card__head' },
        h('div', {},
          h('h2', {}, 'Оформление'),
          h('p', {}, 'Как приложение выглядит на этом устройстве'),
        ),
        h('span', { class: 'settings-card__icon', html: icon('palette', 20) }),
      ),
      h('div', { class: 'settings-label' }, 'Активная тема'),
      h('div', { class: 'mode-row' },
        themeModeChip('light', 'Светлый', 'sun'),
        themeModeChip('dark', 'Тёмный', 'moon'),
      ),
      h('div', { class: 'settings-label' }, 'Акцент'),
      h('div', { class: 'accent-row' },
        h('span', { class: 'accent-dot', style: `background:${accentOf()}` }),
        h('span', {}, active ? `${active.title} · ${active.colors[1] || active.colors[0]}` : 'Hikari · киноварь и бумага'),
      ),
    ),

    h('section', { class: 'card settings-card' },
      h('div', { class: 'settings-card__head' },
        h('div', {}, h('h2', {}, 'Устройство'), h('p', {}, 'Платформа и сведения о системе')),
        h('span', { class: 'settings-card__icon', html: icon('monitor', 20) }),
      ),
      h('div', { class: 'kv' },
        h('span', {}, 'Платформа'), h('strong', {}, 'Браузер · live-превью'),
        h('span', {}, 'Версия'), h('strong', {}, '1.0.0 (1)'),
        h('span', {}, 'Модель'), h('strong', {}, navigator.platform || 'Браузер'),
        h('span', {}, 'Системные обои'), h('strong', {}, 'Недоступны'),
      ),
    ),

    h('section', { class: 'card settings-card' },
      h('div', { class: 'settings-card__head' },
        h('div', {}, h('h2', {}, 'О приложении'), h('p', {}, 'Hikari — темы и обои в духе японской эстетики')),
        h('span', { class: 'settings-card__icon', html: icon('info', 20) }),
      ),
      h('div', { class: 'kv' },
        h('span', {}, 'Шрифты'), h('strong', {}, 'Yuji Syuku · Caveat Brush · Shippori Mincho · Playfair'),
        h('span', {}, 'Лицензии'), h('strong', {}, 'OFL 1.1 · шрифты Google Fonts'),
        h('span', {}, 'Данные'), h('strong', {}, 'hikari/assets/catalog/catalog.json'),
      ),
      h('button', {
        class: 'btn btn--ghost',
        onclick: () => {
          state.activeThemeId = null;
          localStorage.removeItem('hikari.activeTheme');
          applyTheme();
          renderContent();
          toast('Настройки оформления сброшены');
        },
      }, 'Сбросить оформление'),
    ),

    h('div', { class: 'note' },
      h('span', { html: icon('info', 18) }),
      h('p', {}, 'Это браузерная визуализация Flutter-проекта: реальные обои, шрифты и каталог, но без системного канала hikari/system. Для сборки на Windows/Android нужен Flutter 3.50.1 — см. hikari/README.md.'),
    ),
  );
}

/* ------------------------------------------------------------------ detail */

function detailSection(title, ...children) {
  return h('section', { class: 'detail__section' },
    h('div', { class: 'settings-label' }, title),
    ...children,
  );
}

function renderDetail() {
  const layer = document.querySelector('#detail-layer');
  if (!layer) return;
  layer.innerHTML = '';
  if (!state.detail) return;

  const item = itemById(state.detail);
  if (!item) {
    layer.append(h('div', { class: 'detail' },
      h('div', { class: 'detail__backdrop', onclick: closeDetail }),
      h('div', { class: 'card detail__missing' },
        h('h2', {}, 'Работа не найдена'),
        h('button', { class: 'btn btn--primary', onclick: () => navigate('catalog') }, 'В каталог'),
      ),
    ));
    return;
  }

  const col = collectionById(item.collection);
  const fav = state.favorites.has(item.id);
  const applied = state.activeThemeId === item.id;
  const applyLabel = applied
    ? 'Применено'
    : item.type === 'theme' ? 'Применить тему' : 'Установить обои';

  layer.append(h('div', { class: 'detail' },
    h('div', { class: 'detail__backdrop', onclick: closeDetail }),
    h('div', { class: 'detail__panel' },
      h('div', { class: 'detail__media' },
        h('img', { src: assetUrl(item.assetLandscape), alt: item.title }),
        h('div', { class: 'detail__media-actions' },
          h('button', { class: 'icon-btn icon-btn--light', title: 'Назад', onclick: closeDetail, html: icon('back', 20) }),
          h('button', {
            class: 'icon-btn icon-btn--light',
            title: 'Полный экран',
            onclick: () => window.open(assetUrl(item.assetLandscape), '_blank', 'noopener'),
            html: icon('expand', 18),
          }),
        ),
      ),
      h('div', { class: 'detail__info' },
        h('div', { class: 'eyebrow' }, `РАБОТА · ${col ? `${col.name} · ${col.nameJa}` : item.collection}`),
        h('div', { class: 'detail__title-row' },
          h('h2', { class: 'detail__title' }, item.title),
          h('span', { class: 'detail__ja' }, item.titleJa),
        ),
        h('div', { class: 'detail__badges' },
          h('span', {
            class: 'badge',
            style: `--badge:${item.type === 'theme' ? '#C9A227' : '#C9362B'}`,
          }, item.type === 'theme' ? 'Тема' : 'Обои'),
          h('span', {}, formatDate(item.date)),
          h('span', { class: 'dot' }, '·'),
          h('span', {}, `${item.popularity} / 100`),
        ),
        h('p', { class: 'detail__desc' }, item.description),
        detailSection('Палитра',
          h('div', { class: 'palette-large' },
            ...item.colors.map((color) => h('button', {
              class: 'palette-large__item',
              title: `Скопировать ${color}`,
              onclick: async () => {
                try {
                  await navigator.clipboard.writeText(color);
                  toast(`${color} скопирован`);
                } catch {
                  toast(color);
                }
              },
            },
              h('span', { class: 'palette-large__swatch', style: `background:${color}` }),
              h('span', { class: 'palette-large__hex' }, color),
            )),
          ),
        ),
        detailSection('Теги',
          h('div', { class: 'tags' }, ...item.tags.map((tag) => h('span', { class: 'tag' }, `#${tag}`))),
        ),
        h('div', { class: 'detail__actions' },
          h('button', { class: 'btn btn--primary', onclick: () => applyItem(item) }, applyLabel),
          h('button', { class: 'btn btn--ghost', onclick: () => toggleFavorite(item.id) },
            fav ? 'Убрать из избранного' : 'В избранное'),
        ),
        h('p', { class: 'detail__note' },
          'В браузерном превью «применение» меняет акцент интерфейса; на устройстве вызвало бы системный канал hikari/system.',
        ),
      ),
    ),
    h('button', { class: 'detail__close', title: 'Закрыть', onclick: closeDetail, html: icon('close', 20) }),
  ));
}

function applyItem(item) {
  state.activeThemeId = item.id;
  localStorage.setItem('hikari.activeTheme', item.id);
  applyTheme();
  renderDetail();
  renderContent();
  toast(item.type === 'theme'
    ? `Тема «${item.title}» применена`
    : `Обои «${item.title}» установлены`);
}

/* ------------------------------------------------------------------ editor */

const EDITOR_TABS = [
  { id: 'hikari/assets/catalog/catalog.json', label: 'Данные' },
  { id: 'dev-preview/src/styles.css', label: 'Стили' },
  { id: 'files', label: 'Исходники' },
];

function editorShell() {
  return [
    h('div', { class: 'editor__head' },
      h('div', {},
        h('div', { class: 'eyebrow' }, 'ДОРАБОТКА'),
        h('h3', {}, 'Редактор'),
      ),
      h('button', {
        class: 'icon-btn',
        title: 'Закрыть',
        onclick: () => { state.editorOpen = false; renderEditor(); },
        html: icon('x', 20),
      }),
    ),
    h('div', { class: 'editor__tabs' },
      ...EDITOR_TABS.map((tab) => h('button', {
        class: 'tab' + (state.editorTab === tab.id ? ' is-active' : ''),
        onclick: () => { state.editorTab = tab.id; renderEditor(); },
      }, tab.label)),
    ),
    h('div', { class: 'editor__body', id: 'editor-body' }),
    h('p', { class: 'editor__hint' },
      'Сохранённое пишется прямо в файлы репозитория; превью обновляется автоматически (~1–2 с).',
    ),
  ];
}

async function renderEditableEditor(body, path) {
  body.append(h('div', { class: 'editor__loading' }, 'Загружаю файл…'));
  try {
    const response = await fetch(API.file(path), { cache: 'no-store' });
    const data = await response.json();
    if (!response.ok) throw new Error(data.error || 'Ошибка чтения');
    body.innerHTML = '';

    const textarea = h('textarea', { class: 'editor__code', spellcheck: 'false', wrap: 'off' });
    textarea.value = data.content;
    const status = h('div', { class: 'editor__status' }, 'Файл: ', h('code', {}, path));
    const save = h('button', {
      class: 'btn btn--primary',
      onclick: async () => {
        status.textContent = 'Проверяю…';
        if (path.endsWith('.json')) {
          try {
            JSON.parse(textarea.value);
          } catch (error) {
            status.textContent = `Ошибка JSON: ${error.message}`;
            status.classList.add('is-error');
            return;
          }
        }
        try {
          const result = await fetch(API.save, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ path, content: textarea.value }),
          });
          const payload = await result.json();
          if (!result.ok) throw new Error(payload.error || 'Не удалось сохранить');
          status.classList.remove('is-error');
          status.textContent = 'Сохранено · превью обновится само';
          toast('Сохранено — обновляю превью…');
        } catch (error) {
          status.textContent = `Ошибка: ${error.message}`;
          status.classList.add('is-error');
        }
      },
    }, h('span', { html: icon('check', 16) }), 'Сохранить');

    body.append(
      h('div', { class: 'editor__filebar' },
        h('span', { class: 'editor__filename' }, path),
        save,
      ),
      textarea,
      status,
    );
  } catch (error) {
    body.innerHTML = '';
    body.append(h('div', { class: 'editor__status is-error' }, error.message));
  }
}

async function renderFileViewer(body) {
  body.append(h('div', { class: 'editor__loading' }, 'Читаю дерево проекта…'));
  try {
    const response = await fetch(API.tree, { cache: 'no-store' });
    const { files } = await response.json();
    body.innerHTML = '';

    const select = h('select', { class: 'editor__select' });
    files.forEach((file) => select.append(h('option', { value: file }, file)));
    const preferred = files.includes(state.fileView) ? state.fileView : 'hikari/README.md';
    select.value = preferred;
    state.fileView = preferred;

    const pre = h('pre', { class: 'editor__pre' }, 'Выберите файл…');
    let token = 0;
    async function load(file) {
      const current = ++token;
      pre.textContent = 'Загружаю…';
      try {
        const result = await fetch(API.file(file), { cache: 'no-store' });
        const payload = await result.json();
        if (current !== token) return;
        pre.textContent = result.ok ? payload.content : `Ошибка: ${payload.error}`;
      } catch (error) {
        pre.textContent = error.message;
      }
    }
    select.addEventListener('change', () => {
      state.fileView = select.value;
      load(select.value);
    });
    load(preferred);

    body.append(
      h('div', { class: 'editor__filebar' },
        h('span', { class: 'editor__filename' }, `${files.length} текстовых файлов`),
      ),
      select,
      pre,
      h('p', { class: 'editor__readonly' }, 'Просмотр исходников только для чтения. Данные и стили можно править на соседних вкладках.'),
    );
  } catch (error) {
    body.innerHTML = '';
    body.append(h('div', { class: 'editor__status is-error' }, error.message));
  }
}

function renderEditor() {
  const panel = document.querySelector('#editor');
  if (!panel) return;
  panel.classList.toggle('is-open', state.editorOpen);
  const body = panel.querySelector('#editor-body');
  if (!state.editorOpen) return;
  body.innerHTML = '';
  panel.querySelectorAll('.tab').forEach((tab, index) => {
    tab.classList.toggle('is-active', EDITOR_TABS[index].id === state.editorTab);
  });
  if (state.editorTab === 'files') renderFileViewer(body);
  else renderEditableEditor(body, state.editorTab);
}

/* ------------------------------------------------------------------- shell */

function navButton(item, compact = false) {
  return h('button', {
    class: 'nav__item' + (compact ? ' nav__item--compact' : ''),
    'data-route': item.route,
    title: item.label,
    onclick: () => navigate(item.route),
  },
    h('span', { class: 'nav__icon', html: icon(item.icon, 20) }),
    h('span', { class: 'nav__label' }, item.label),
  );
}

function renderNav() {
  document.querySelectorAll('[data-route]').forEach((button) => {
    button.classList.toggle('is-active', button.dataset.route === state.route);
  });
}

function updateThemeButton() {
  const button = document.querySelector('#theme-btn');
  if (button) button.innerHTML = icon(state.theme === 'dark' ? 'sun' : 'moon', 18);
}

function renderShell() {
  const root = document.querySelector('#app');
  root.innerHTML = '';
  root.append(h('div', { class: 'app' },
    h('aside', { class: 'rail' },
      h('button', { class: 'brand', onclick: () => navigate('home') },
        h('span', { class: 'brand__mark' }, '光'),
        h('span', { class: 'brand__text' },
          h('span', { class: 'brand__name' }, 'Hikari'),
          h('span', { class: 'brand__sub' }, '光 · 2026'),
        ),
      ),
      h('div', { class: 'rail__nav' }, ...NAV.map((item) => navButton(item))),
      h('div', { class: 'rail__foot' },
        h('div', { class: 'live-pill' }, h('span', { class: 'live-dot' }), 'LIVE превью'),
        h('p', {}, 'Визуализация проекта из hikari/. Данные и картинки — настоящие.'),
      ),
    ),

    h('div', { class: 'main' },
      h('header', { class: 'topbar' },
        h('div', { class: 'topbar__left' },
          h('button', { class: 'topbar__mobile-brand', onclick: () => navigate('home') }, '光 Hikari'),
          h('label', { class: 'topbar__search' },
            h('span', { class: 'search__icon', html: icon('search', 18) }),
            h('input', {
              type: 'search',
              placeholder: 'Поиск обоев, тем, тегов…',
              onkeydown: (e) => {
                if (e.key === 'Enter') {
                  state.filters.query = e.target.value;
                  navigate('catalog');
                }
              },
            }),
          ),
        ),
        h('nav', { class: 'topbar__nav' },
          ...TOP_NAV.map((item) => h('button', {
            class: 'topbar__pill' + (state.route === item.route ? ' is-active' : ''),
            'data-route': item.route,
            onclick: () => navigate(item.route),
          }, item.label)),
        ),
        h('div', { class: 'topbar__right' },
          h('span', { class: 'live-pill' }, h('span', { class: 'live-dot' }), 'LIVE'),
          h('span', { class: 'topbar__lang' }, 'RU'),
          h('button', {
            id: 'theme-btn',
            class: 'icon-btn',
            title: 'Переключить тему',
            html: icon(state.theme === 'dark' ? 'sun' : 'moon', 18),
            onclick: () => {
              state.theme = state.theme === 'dark' ? 'light' : 'dark';
              localStorage.setItem('hikari.theme', state.theme);
              applyTheme();
              updateThemeButton();
              renderContent();
            },
          }),
          h('button', {
            class: 'btn btn--ghost btn--small',
            onclick: () => { state.editorOpen = !state.editorOpen; renderEditor(); },
          }, h('span', { html: icon('pencil', 16) }), 'Редактор'),
        ),
      ),
      h('main', { class: 'content', id: 'content' }),
    ),

    h('nav', { class: 'bottom-nav' }, ...NAV.map((item) => navButton(item, true))),
    h('div', { class: 'detail-layer', id: 'detail-layer' }),
    h('aside', { class: 'editor', id: 'editor' }, ...editorShell()),
    h('div', { class: 'toast', id: 'toast' }),
  ));

  renderNav();
  renderContent();
  renderDetail();
  renderEditor();
}

function renderContent() {
  const content = document.querySelector('#content');
  if (!content || !catalog) return;
  content.innerHTML = '';
  let screen;
  if (state.route === 'catalog') screen = renderCatalogScreen();
  else if (state.route === 'favorites') screen = renderFavorites();
  else if (state.route === 'settings') screen = renderSettings();
  else screen = renderHome();
  content.append(screen);
  if (state.route === 'catalog') renderCatalogResults();
  window.scrollTo({ top: 0, behavior: 'auto' });
}

/* -------------------------------------------------------------- live reload */

async function startPolling() {
  async function tick() {
    try {
      const response = await fetch(API.liveHash, { cache: 'no-store' });
      const { hash } = await response.json();
      if (liveHash === null) liveHash = hash;
      else if (hash !== liveHash) {
        location.reload();
        return;
      }
    } catch {
      // сервер перезапускается — просто попробуем ещё раз
    }
    setTimeout(tick, 1500);
  }
  tick();
}

async function boot() {
  applyTheme();
  try {
    const response = await fetch('/catalog/catalog.json', { cache: 'no-store' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    catalog = await response.json();
    if (!Array.isArray(catalog.items) || !Array.isArray(catalog.collections)) {
      throw new Error('Неожиданная структура catalog.json');
    }
  } catch (error) {
    assetError(error.message);
    return;
  }
  const parsed = parseHash();
  state.route = parsed.route;
  state.detail = parsed.detail;
  renderShell();
  startPolling();
}

boot();
