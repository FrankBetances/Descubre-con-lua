// ATENCIÓN: este script NO corre desde un clon de este repositorio.
//
// Importa de `.studio_ref/`, que es la copia local del proyecto de Studio AI del
// que salió este contenido, y `.studio_ref/` está en `.gitignore`: no viaja, y
// no va a viajar. Lo que sí está en el repositorio es su RESULTADO, en
// `assets/content/`, que es lo que la app lee y lo que vigilan los gates.
//
// Entonces, ¿para qué sigue aquí? Para dejar escrito de dónde salió cada
// fichero de contenido y con qué nombre se llamaba en el origen. Sin esto, los
// 9 MB de JSON de `assets/content/` no tienen procedencia ninguna.
//
// Para volver a correrlo hace falta la copia de Studio AI en `.studio_ref/` y
// `npx tsx tools/extract_all_data.ts`. Y ojo: ya NO reproduce el estado actual
// del repositorio. Después de la extracción se corrigieron cosas que el
// original traía mal —el `zipf_score` inventado del corpus, el `pos` inventado,
// el `rfidTag` de otro producto, el banco de contos duplicado— y este script
// las devolvería. Si algún día se vuelve a extraer, hay que revisar ese
// historial antes de sobrescribir nada.

import fs from 'fs';
import path from 'path';

// Import from .studio_ref
import { BANCO_200_CUENTOS } from '../.studio_ref/src/data/banco200CuentosData.ts';
import { BANCO_100_CUENTOS } from '../.studio_ref/src/data/banco100CuentosData.ts';
import { HISTORIAS_PROGRESIVAS } from '../.studio_ref/src/data/historiasProgresivasData.ts';
import { BANCO_200_LAMINAS } from '../.studio_ref/src/data/banco200LaminasData.ts';
import { MESES_50_CURRICULO } from '../.studio_ref/src/data/curriculo50Meses.ts';
import { getDiasMesDual } from '../.studio_ref/src/data/calendarDaysData.ts';
import { INITIAL_HIGH_FREQUENCY_LEXICON, ENGLISH_CONVERSATION_SCENARIOS } from '../.studio_ref/src/data/englishCorpus.ts';
import { COMMON_COLLOCATION_PATTERNS, INTERACTIVE_SCENARIOS } from '../.studio_ref/src/data/collocationsAndGrammar.ts';
import { PHONEMES_44_TAXONOMY, DECODABLE_WORDS_CATALOG, WORD_FAMILIES_MATRIX, PHONICS_MISSIONS } from '../.studio_ref/src/data/phonicsTaxonomyData.ts';
import { ESTRATEGIAS_PEDAGOGICAS } from '../.studio_ref/src/data/estrategiasPedagogicasData.ts';
import { DINAMICAS_AULA } from '../.studio_ref/src/data/dinamicasPedagogicasData.ts';
import { LUA_PALETTE, LUA_SIT_ART, LUA_HEAD_ART, AWARDS_PALETTE, AWARDS_GLYPHS } from '../.studio_ref/src/data/luaArt.ts';

const baseDir = path.resolve(__dirname, '..');

function ensureDir(dirPath: string) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

function writeJson(relPath: string, data: any) {
  const fullPath = path.join(baseDir, relPath);
  ensureDir(path.dirname(fullPath));
  fs.writeFileSync(fullPath, JSON.stringify(data, null, 2), 'utf-8');
  console.log(`[OK] Generated: ${relPath} (${Array.isArray(data) ? data.length + ' items' : 'object'})`);
}

function copyFile(srcRel: string, destRel: string) {
  const src = path.join(baseDir, srcRel);
  const dest = path.join(baseDir, destRel);
  ensureDir(path.dirname(dest));
  fs.copyFileSync(src, dest);
  console.log(`[OK] Copied: ${srcRel} -> ${destRel}`);
}

async function main() {
  console.log('=== EXTRACTING ALL PEDAGOGICAL ASSETS TO FLUTTER JSON ===\n');

  // 1. Cuentos
  writeJson('assets/content/cuentos/banco200_cuentos.json', BANCO_200_CUENTOS);
  writeJson('assets/content/cuentos/banco100_cuentos.json', BANCO_100_CUENTOS);
  writeJson('assets/content/cuentos/historias_progresivas.json', HISTORIAS_PROGRESIVAS);

  // 2. Láminas
  writeJson('assets/content/laminas/banco200_laminas.json', BANCO_200_LAMINAS);

  // 3. Calendario 50 Meses y 1000 Días
  writeJson('assets/content/calendario/curriculo_50_meses.json', MESES_50_CURRICULO);

  const cursos = ['curso_0_2', 'curso_2_3', 'curso_3_4', 'curso_4_5', 'curso_5_6'] as const;
  const todosLosDias: any[] = [];
  for (const curso of cursos) {
    for (let m = 0; m < 10; m++) {
      const dias = getDiasMesDual(m, curso);
      todosLosDias.push(...dias);
    }
  }
  writeJson('assets/content/calendario/calendario_dias.json', todosLosDias);
  copyFile('.studio_ref/calendario-3-6-anos.json', 'assets/content/calendario/calendario_3_6_anos.json');

  // 4. English Immersion & Phonics
  writeJson('assets/content/english/english_corpus.json', {
    words: INITIAL_HIGH_FREQUENCY_LEXICON,
    scenarios: ENGLISH_CONVERSATION_SCENARIOS,
  });

  writeJson('assets/content/english/collocations_grammar.json', {
    collocations: COMMON_COLLOCATION_PATTERNS,
    scenarios: INTERACTIVE_SCENARIOS,
  });

  writeJson('assets/content/english/phonics_taxonomy.json', {
    phonemes: PHONEMES_44_TAXONOMY,
    decodableWords: DECODABLE_WORDS_CATALOG,
    wordFamilies: WORD_FAMILIES_MATRIX,
    missions: PHONICS_MISSIONS,
  });

  // 5. Estrategias, Dinámicas y Arte
  writeJson('assets/content/estrategias_pedagogicas.json', ESTRATEGIAS_PEDAGOGICAS);
  writeJson('assets/content/dinamicas_aula.json', DINAMICAS_AULA);
  writeJson('assets/content/lua_art.json', {
    luaPalette: LUA_PALETTE,
    luaSitArt: LUA_SIT_ART,
    luaHeadArt: LUA_HEAD_ART,
    awardsPalette: AWARDS_PALETTE,
    awardsGlyphs: AWARDS_GLYPHS,
  });

  // 6. Corpus 8000 Palabras
  copyFile('.studio_ref/src/data/bncCoca8000.json', 'assets/content/corpus/bnc_coca_8000.json');
  copyFile('.studio_ref/src/data/bncCoca8000Cefr.json', 'assets/content/corpus/bnc_coca_8000_cefr.json');

  console.log('\n=== ALL ASSETS EXTRACTED SUCCESSFULLY! ===');
}

main().catch(err => {
  console.error('Fatal error during extraction:', err);
  process.exit(1);
});
