// ============================================================================
// Descubre con Lúa · Imprime el manual a PDF desde el HTML
//
//   CHROMIUM_PATH=/ruta/al/chrome node docs/build-pdf.js
//
// El HTML es la ÚNICA fuente del manual: de él salen el PDF (aquí) y el Word
// (docs/build-docx.py). Portado de Valeria+, y por la razón que está escrita en
// su build-docx.py: allí el texto llegó a estar duplicado y el Word se quedó
// describiendo una versión anterior sin que nada avisara.
//
// printBackground va activado a propósito: la portada, las cabeceras de los
// casos de uso y los recuadros de aviso SON color. Sin él, la cabecera azul sale
// en blanco con el texto blanco encima, es decir, invisible.
// ============================================================================
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const SRC = path.join(__dirname, 'manual-casos-de-uso.html');
const OUT = path.join(__dirname, 'Descubre-con-Lua-Manual-Casos-de-Uso.pdf');

(async () => {
  const browser = await chromium.launch({
    executablePath: process.env.CHROMIUM_PATH || undefined,
  });
  const page = await browser.newPage();
  await page.goto('file://' + SRC, { waitUntil: 'networkidle' });
  // Los márgenes y el tamaño los fija @page en el propio HTML; preferCSSPageSize
  // evita que Chromium imponga los suyos y descuadre la portada.
  await page.pdf({ path: OUT, printBackground: true, preferCSSPageSize: true });
  await browser.close();

  // Sello de qué versión del HTML produjo este PDF; tools/check_manual_build.py
  // lo compara con la fuente para que el documento no se quede atrás en silencio.
  const stampPath = path.join(__dirname, '.manual-build-stamp.json');
  const stamp = fs.existsSync(stampPath)
    ? JSON.parse(fs.readFileSync(stampPath, 'utf8'))
    : {};
  stamp.pdf = crypto.createHash('sha256').update(fs.readFileSync(SRC)).digest('hex');
  fs.writeFileSync(stampPath, JSON.stringify(stamp, Object.keys(stamp).sort(), 1) + '\n');

  console.log('escrito', path.relative(process.cwd(), OUT));
})();
