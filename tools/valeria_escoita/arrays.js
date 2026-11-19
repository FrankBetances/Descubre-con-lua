// Saca los arrays de datos `export const NOMBRE: Tipo[] = [ ... ];` de un .ts
// de Valeria, emparejando corchetes, y los evalúa como literales.
const fs = require('fs'), vm = require('vm');
const [,, file, ...names] = process.argv;
const src = fs.readFileSync(file, 'utf8');
const out = {};
for (const n of names) {
  const m = new RegExp(`export const ${n}\\s*:[^=]*=\\s*\\[`).exec(src);
  if (!m) { console.error('falta', n); process.exit(1); }
  let i = m.index + m[0].length - 1, depth = 0, str = null;
  const start = i;
  for (; i < src.length; i++) {
    const c = src[i];
    if (str) { if (c === '\\') { i++; continue; } if (c === str) str = null; continue; }
    if (c === '/' && src[i + 1] === '/') { i = src.indexOf('\n', i); continue; }
    if (c === "'" || c === '"' || c === '`') { str = c; continue; }
    if (c === '[' || c === '{') depth++;
    if (c === ']' || c === '}') { depth--; if (depth === 0) break; }
  }
  const lit = src.slice(start, i + 1).replace(/\bas const\b/g, '');
  const ctx = { DEVELOPMENTAL: { verdict: 'developmental' } };
  out[n] = vm.runInNewContext('(' + lit + ')', ctx);
}
process.stdout.write(JSON.stringify(out));
