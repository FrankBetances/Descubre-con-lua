#!/usr/bin/env python3
"""Que el cuento de cada semana lleve las veinte palabras inglesas de su semana.

    python3 tools/check_contos_palabras.py

Nace de un encargo de Frank: «no tiene sentido un cuento que no tenga las
palabras del día». Las cinco palabras del día salen de la semana TPR
(`assets/content/tpr/`) y el cuento de esa semana se lee esos mismos días, así
que el cuento tiene que traerlas. Antes no traía ninguna.

Por cada cuento semanal de `historias_progresivas.json` comprueba:

- que la semana TPR existe y que el cuento lleva sus 20 palabras, ni una más;
- que cada página declara de 1 a 4 (el visor no pinta más de cuatro);
- que todo lo que va entre “…” en el texto gallego y en el castellano es una
  palabra declarada en esa página, y que cada declarada está entre “…” en las
  dos lenguas: el inglés va entre esas comillas porque es lo que la voz lee
  con la voz inglesa;
- que `vocabularioClave` y `vocabularioClaveEs` son el significado de esas
  palabras, en el mismo orden;
- que la frase TPR del cuento es una de las veinte.

Escribe una línea por fallo y sale con 1 si hay alguno.
"""
from __future__ import annotations

import glob
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CONTOS = RAIZ / 'assets/content/cuentos/historias_progresivas.json'
TPR = RAIZ / 'assets/content/tpr'
MAX_POR_PAXINA = 4


def clave(texto: str) -> str:
    """La misma clave que el visor (`PalabrasNoConto.clave`)."""
    texto = texto.strip().lower()
    texto = re.sub(r'[\s.!?,;:…]+$', '', texto)
    return re.sub(r'\s+', ' ', texto)


def entre_comiñas(texto: str) -> list[str]:
    return re.findall(r'“([^”]*)”', texto)


def main() -> int:
    semanas = {}
    for f in sorted(glob.glob(str(TPR / 'curso_*/tpr.*.json'))):
        t = json.loads(Path(f).read_text(encoding='utf-8'))
        for s in t['semanas']:
            semanas[(t['curso'], t['orden'], s['semana'])] = s['palabras']

    contos = json.loads(CONTOS.read_text(encoding='utf-8'))
    semanais = [c for c in contos if c.get('semanaSugerida')]
    erros: list[str] = []
    for c in semanais:
        k = (c['cursoId'], c['mesNumero'], c['semanaSugerida'])
        tag = f"{c['id']} ({c['cursoId']} m{c['mesNumero']} s{c['semanaSugerida']})"
        palabras = semanas.get(k)
        if palabras is None:
            erros.append(f'{tag}: non hai semana TPR')
            continue
        por_clave = {clave(p['en']): p for p in palabras}
        usadas: list[str] = []
        for p in c['paginas']:
            pt = f"{tag} p{p.get('numero')}"
            declaradas = p.get('palabras') or []
            if not 1 <= len(declaradas) <= MAX_POR_PAXINA:
                erros.append(f'{pt}: {len(declaradas)} palabras; van de 1 a {MAX_POR_PAXINA}')
            claves = [clave(d) for d in declaradas]
            for d, kd in zip(declaradas, claves):
                if kd not in por_clave:
                    erros.append(f'{pt}: «{d}» non é da semana')
            for lang in ('gl', 'es'):
                texto = p['texto'].get(lang, '')
                no_texto = [clave(x) for x in entre_comiñas(texto)]
                for x in no_texto:
                    if x not in claves:
                        erros.append(f'{pt} {lang}: “{x}” vai entre comiñas e non está declarada')
                for d, kd in zip(declaradas, claves):
                    if kd not in no_texto:
                        erros.append(f'{pt} {lang}: «{d}» está declarada e non vai entre “…”')
            for campo, lang in (('vocabularioClave', 'gl'), ('vocabularioClaveEs', 'es')):
                esperado = [por_clave[kd][lang] for kd in claves if kd in por_clave]
                if p.get(campo) != esperado:
                    erros.append(f'{pt}: {campo} {p.get(campo)} non é {esperado}')
            usadas += claves
        faltan = [por_clave[k2]['en'] for k2 in por_clave if k2 not in usadas]
        if faltan:
            erros.append(f'{tag}: faltan {len(faltan)} palabras da semana: {faltan}')
        frase = (c.get('tprOral') or {}).get('fraseEn', '')
        if clave(frase) not in por_clave:
            erros.append(f'{tag}: a frase TPR «{frase}» non é da semana')

    for e in erros:
        print(e)
    if erros:
        print(f'FAIL: {len(erros)} fallos en {len(semanais)} contos semanais')
        return 1
    print(f'OK: os {len(semanais)} contos semanais levan as 20 palabras da súa semana')
    return 0


if __name__ == '__main__':
    sys.exit(main())
