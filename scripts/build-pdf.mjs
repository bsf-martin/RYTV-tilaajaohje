// Builds the PDF by printing the generated, styled HTML page with headless Chrome.
// The page's print stylesheet (templates/rytv.css, @page and @media print) defines the design:
// navy cover, contents page, running logo and page numbers, with the same self-hosted
// brand fonts as the web page.
//
// Usage: node build-pdf.mjs <path/to/index.html> <output.pdf>
// Chrome is found via $CHROME_PATH, or the usual locations for Linux / macOS.

import puppeteer from 'puppeteer-core';
import { createServer } from 'node:http';
import { createReadStream, existsSync, statSync } from 'node:fs';
import { basename, dirname, extname, join, normalize, resolve, sep } from 'node:path';

const [, , htmlArg, pdfArg] = process.argv;
if (!htmlArg || !pdfArg) {
  console.error('Usage: node build-pdf.mjs <index.html> <output.pdf>');
  process.exit(2);
}

const candidates = [
  process.env.CHROME_PATH,
  '/usr/bin/google-chrome',
  '/usr/bin/google-chrome-stable',
  '/usr/bin/chromium',
  '/usr/bin/chromium-browser',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
].filter(Boolean);
const executablePath = candidates.find((p) => existsSync(p));
if (!executablePath) {
  console.error('No Chrome found. Set CHROME_PATH. Tried:\n  ' + candidates.join('\n  '));
  process.exit(1);
}

const htmlPath = resolve(htmlArg);
const pdfPath = resolve(pdfArg);
if (!existsSync(htmlPath)) {
  console.error('Input not found: ' + htmlPath);
  process.exit(1);
}

// Serve the site folder over http so the page behaves as it does when deployed
// (loading it from file:// makes Chrome reject the font preloads for CORS reasons).
const root = dirname(htmlPath);
const types = {
  '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'text/javascript',
  '.woff2': 'font/woff2', '.svg': 'image/svg+xml', '.png': 'image/png', '.ico': 'image/x-icon',
};
const server = createServer((req, res) => {
  const rel = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  const file = normalize(join(root, rel === '/' ? '/' + basename(htmlPath) : rel));
  if (!file.startsWith(root + sep) || !existsSync(file) || !statSync(file).isFile()) {
    res.writeHead(404).end();
    return;
  }
  res.writeHead(200, { 'Content-Type': types[extname(file)] || 'application/octet-stream' });
  createReadStream(file).pipe(res);
});
await new Promise((ok) => server.listen(0, '127.0.0.1', ok));
const url = `http://127.0.0.1:${server.address().port}/${basename(htmlPath)}`;

const browser = await puppeteer.launch({
  executablePath,
  headless: true,
  args: ['--no-sandbox', '--disable-gpu', '--font-render-hinting=none'],
});

try {
  const page = await browser.newPage();
  const problems = [];
  page.on('requestfailed', (r) => problems.push('request failed: ' + r.url()));
  page.on('pageerror', (e) => problems.push('page error: ' + e.message));

  await page.goto(url, { waitUntil: 'networkidle0' });
  await page.emulateMediaType('print');
  // Fonts must be loaded before printing, otherwise Chrome prints with fallback fonts.
  await page.evaluate(() => document.fonts.ready);
  const fonts = await page.evaluate(() =>
    [...document.fonts].filter((f) => f.status === 'loaded').map((f) => f.family.replace(/"/g, '')),
  );
  if (!fonts.includes('Figtree') || !fonts.includes('Source Sans 3')) {
    problems.push('brand fonts not loaded (loaded: ' + fonts.join(', ') + ')');
  }

  await page.pdf({
    path: pdfPath,
    preferCSSPageSize: true, // use the @page size and margins from the stylesheet
    printBackground: true,
    outline: true, // PDF bookmarks from headings
    tagged: true, // accessible (tagged) PDF
  });

  const size = statSync(pdfPath).size;
  console.log(`PDF written: ${pdfPath} (${(size / 1024).toFixed(0)} KiB), Chrome: ${await browser.version()}`);
  if (problems.length) {
    console.error('Problems while rendering:\n  ' + problems.join('\n  '));
    process.exitCode = 1;
  }
} finally {
  await browser.close();
  server.close();
}
