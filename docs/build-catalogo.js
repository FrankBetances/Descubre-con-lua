// El PDF del catálogo por edades, del HTML que escribe tools/gen_catalogo.py.
const path = require('path');
const { chromium } = require('playwright');

const SRC = path.join(__dirname, 'catalogo-por-idades.html');
const OUT = path.join(__dirname, 'Descubre-con-Lua-Material-por-edades.pdf');

(async () => {
  const browser = await chromium.launch({
    executablePath: process.env.CHROMIUM_PATH || undefined,
  });
  const page = await browser.newPage();
  await page.goto('file://' + SRC, { waitUntil: 'networkidle' });
  await page.pdf({ path: OUT, printBackground: true, preferCSSPageSize: true });
  await browser.close();
  console.log('escrito ' + path.relative(path.join(__dirname, '..'), OUT));
})();
