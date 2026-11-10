// O-20261109-3: copia de Valeria las rejillas de Lúa (gestos, cuerpo, cola y
// accesorios) y su paleta, sin redibujar nada. Uso:
//   node --experimental-strip-types tools/port_lua_valeria.mjs <ruta-a-valeria>
// Escribe assets/brand/lua_valeria.json.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';

const v = process.argv[2];
if (!v) { console.error('falta la ruta a Valeria'); process.exit(1); }
const cat = readFileSync(join(v, 'src/ValeriaCatPixel.tsx'), 'utf8').split('\n');
const ini = cat.findIndex((l) => l.startsWith('export type PixelMap'));
const fin = cat.findIndex((l) => l.startsWith('export const CatPixel'));
const dir = join(tmpdir(), 'lua_valeria_port');
mkdirSync(dir, { recursive: true });
writeFileSync(join(dir, 'cat.ts'), cat.slice(ini, fin).join('\n').replace(/^interface Props[\s\S]*?\n}\n/m, ''));
writeFileSync(join(dir, 'seg.ts'), readFileSync(join(v, 'src/components/lua/luaPixelSegments.ts'), 'utf8')
  .replace("import { SIT, CAT_TUXEDO, mergeRuns, Run, PixelMap } from '../../ValeriaCatPixel'", "import { SIT, CAT_TUXEDO, mergeRuns, type Run, type PixelMap } from './cat.ts'"));
const s = await import(join(dir, 'seg.ts'));
const out = {
  fuente: 'FrankBetances/Valeria:src/ValeriaCatPixel.tsx y src/components/lua/luaPixelSegments.ts',
  cols: 32, rows: 38,
  palette: s.ITEM_PALETTE,
  head: { neutral: s.LUA_HEAD_NEUTRAL, blink: s.LUA_HEAD_BLINK, love: s.LUA_HEAD_LOVE, eat: s.LUA_HEAD_EAT_OPEN },
  body: s.LUA_BODY_BASE,
  tail: s.LUA_TAIL_TIP,
  items: Object.fromEntries(Object.entries(s.ITEM_SPRITES).map(([k, x]) => [k, { row: x.row, col: x.col, art: x.art }])),
};
writeFileSync('assets/brand/lua_valeria.json', JSON.stringify(out, null, 1) + '\n');
console.log('escrito assets/brand/lua_valeria.json:', Object.keys(out.items).join(', '));
