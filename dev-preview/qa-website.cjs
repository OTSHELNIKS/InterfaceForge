const { chromium } = require('/tmp/hikari-qa/node_modules/playwright');
const sharp = require('/tmp/hikari-qa/node_modules/sharp');
const fs = require('node:fs');
const assert = require('node:assert/strict');

(async () => {
  const errors = [], badResponses = [], requests = [];
  const browser = await chromium.launch({ headless: true, args: ['--no-sandbox', '--disable-dev-shm-usage', '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
  const page = await browser.newPage({ viewport: { width: 1223, height: 900 }, deviceScaleFactor: 1, acceptDownloads: true });
  page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
  page.on('pageerror', e => errors.push(e.message));
  page.on('response', r => { if (r.status() >= 400) badResponses.push(`${r.status()} ${r.url()}`); });
  page.on('requestfailed', r => requests.push(`${r.url()}: ${r.failure()?.errorText}`));
  const url = 'http://127.0.0.1:4173/';
  async function route(path) {
    await page.goto(url + '#' + path, { waitUntil: 'networkidle', timeout: 90000 });
    await page.waitForTimeout(1600);
  }
  async function aria() { return await page.locator('body').ariaSnapshot(); }
  async function shot(file, width, height) {
    const buf = await page.screenshot({ clip: { x: 0, y: 0, width, height }, type: 'png' });
    await sharp(buf).jpeg({ quality: 82 }).toFile('design/qa/' + file);
  }
  fs.mkdirSync('design/qa', { recursive: true });
  await route('/home');
  let tree = await aria();
  assert(tree.includes('Красота') && tree.includes('Коллекции'), 'home content missing');
  await shot('website-desktop-home.jpg', 1223, 900);
  await route('/catalog?tag=Природа');
  tree = await aria();
  assert(tree.includes('Природа') && tree.includes('Каталог'), 'catalog/filter missing');
  await shot('website-desktop-catalog.jpg', 1223, 900);
  await route('/item/akane-no-sora');
  tree = await aria();
  assert(tree.includes('Утро в Киото') && tree.includes('173 × 99') && tree.includes('Скачать превью'), 'detail not deep-linkable or metadata missing');
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(1400);
  assert((await aria()).includes('Утро в Киото'), 'detail not preserved on reload');
  await shot('website-desktop-detail.jpg', 1223, 900);
  await route('/collections');
  tree = await aria();
  assert(tree.includes('Сезоны Японии') && tree.includes('Коллекции'), 'collections missing');
  await route('/about');
  assert((await aria()).includes('Условия повторного'), 'about missing');
  await route('/favorites');
  assert((await aria()).includes('Здесь пока ничего нет'), 'empty favorites missing');
  await page.setViewportSize({ width: 390, height: 844 });
  await route('/home');
  await shot('website-mobile-home.jpg', 390, 844);
  await route('/catalog');
  await shot('website-mobile-catalog.jpg', 390, 844);
  await route('/item/akane-no-sora');
  await shot('website-mobile-detail.jpg', 390, 844);
  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
  assert.equal(overflow, 0, 'mobile horizontal document overflow');
  assert.deepEqual(errors, [], 'browser errors');
  assert.deepEqual(badResponses, [], 'bad HTTP responses');
  assert.deepEqual(requests, [], 'failed requests');
  const report = { desktop: { width: 1223, height: 900 }, mobile: { width: 390, height: 844, overflowX: overflow }, routesChecked: ['/home','/catalog?tag=Природа','/item/akane-no-sora (reload)','/collections','/about','/favorites'], errors, badResponses, requests };
  fs.writeFileSync('design/qa/website-report.json', JSON.stringify(report, null, 2));
  console.log('QA_REPORT ' + JSON.stringify(report));
  await browser.close();
})().catch(err => { console.error(err); process.exit(1); });
