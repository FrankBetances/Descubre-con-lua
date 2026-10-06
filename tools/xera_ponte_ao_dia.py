#!/usr/bin/env python3
"""Escribe o que cada orde da asemblea dá por sabido.

Por que existe. Unha crianza que chega nova a 4-5 ou a 5-6 anos atopa unhas
asembleas feitas sobre palabras que o curso ensinou antes: a orde de 4-5 «Hop
like a squirrel and collect the chestnuts» supón que xa se saben «squirrel»,
«chestnut» e «collect», que son de 3-4. Frank escolleu ensinarllas xusto antes
de que fagan falta: no reprodutor, nunha pantalla «Antes da orde», e na casa,
en «Ponte ao día». Ningunha das dúas garda nada da crianza.

A regra, unha soa: unha palabra da orde dáse por sabida se o traxecto TPR a
ensinou ANTES do mes da asemblea, nun curso anterior ou nun mes anterior do
mesmo curso. As do propio mes non: ese mes ensínanse.

O cruce é automático —frases do curso primeiro, despois palabras soltas, con
plurais, tempos verbais e adverbios en -ly— e por iso se revisa a man. O que a
revisión decide vive no mesmo JSON, en «revision», cada decisión co seu
motivo: en «excluir», o que coincide na letra pero non no sentido («ring» é
facer soar unha campá no curso e un aro na orde); en «engadir», o que o cruce
non ve; en «adaptar», un xesto do curso que non serve na aula, como os de 0-2,
que se fan co bebé. Unha decisión que xa non fai falta pon o gate en vermello,
para que non quede ningunha morta. O resto do ficheiro escríbeo este script:

    assets/content/ponte_ao_dia.json
      textos     ← a man: o que se le na pantalla, en galego e castelán
      revision   ← a man: as decisións da revisión
      palabras   ← XERADO: cada palabra, copiada do curso TPR
      ordes      ← XERADO: o que dá por sabido cada orde, pola súa id
      meses      ← XERADO: o de todas as ordes do mes, por curso

    python3 tools/xera_ponte_ao_dia.py            # escribe o ficheiro
    python3 tools/xera_ponte_ao_dia.py --check    # gate: falla se non coincide
    python3 tools/xera_ponte_ao_dia.py --revisar  # listado para revisar a man

As palabras cópianse do curso, co seu xesto: se un xesto cambia no curso e
non se volve xerar, o gate pon o vermello.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CONTIDO = RAIZ / 'assets' / 'content'
DESTINO = CONTIDO / 'ponte_ao_dia.json'

CURSOS = ['curso_0_2', 'curso_2_3', 'curso_3_4', 'curso_4_5', 'curso_5_6']

# O curso do traxecto de cada asemblea: o tramo do 1.º ciclo ou a clase do
# 2.º (4.º de infantil é a clase de 3-4 anos).
CURSO_DA_ASEMBLEA = {
    '0_2': 'curso_0_2',
    '2_3': 'curso_2_3',
    '4_infantil': 'curso_3_4',
    '5_infantil': 'curso_4_5',
    '6_infantil': 'curso_5_6',
}

# A orde dos meses no curso escolar.
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]

# Plurais e tempos irregulares que aparecen nas ordes. Só se usan se a forma
# base é unha palabra do curso.
IRREGULARES = {
    'leaves': 'leaf',
    'feet': 'foot',
    'teeth': 'tooth',
    'children': 'child',
    'mice': 'mouse',
    'geese': 'goose',
    'wolves': 'wolf',
    'knives': 'knife',
    'shelves': 'shelf',
    'halves': 'half',
    'loaves': 'loaf',
    'men': 'man',
    'women': 'woman',
    'ran': 'run',
    'sat': 'sit',
    'stood': 'stand',
    'went': 'go',
    'came': 'come',
    'gave': 'give',
    'took': 'take',
    'found': 'find',
    'flew': 'fly',
    'fell': 'fall',
    'held': 'hold',
    'hid': 'hide',
}

PALABRA = re.compile(r"[^\W\d_]+(?:'[^\W\d_]+)*")


def tokens(texto: str) -> list[str]:
    """As palabras do texto, en minúsculas e sen puntuación."""
    return PALABRA.findall(texto.replace('’', "'").lower())


def formas_base(t: str) -> list[str]:
    """As formas de que pode vir unha palabra da orde, de máis a menos literal."""
    saida = [t]
    if t.endswith("'s"):
        saida.append(t[:-2])
    if t in IRREGULARES:
        saida.append(IRREGULARES[t])
    if t.endswith('ies') and len(t) > 4:
        saida.append(t[:-3] + 'y')
    if t.endswith('es') and len(t) > 3:
        saida.append(t[:-2])
    if t.endswith('s') and not t.endswith('ss') and len(t) > 2:
        saida.append(t[:-1])
    if t.endswith('ing') and len(t) > 5:
        raiz = t[:-3]
        saida += [raiz, raiz + 'e']
        if len(raiz) > 2 and raiz[-1] == raiz[-2]:
            saida.append(raiz[:-1])
    if t.endswith('ed') and len(t) > 4:
        raiz = t[:-2]
        saida += [raiz, t[:-1]]
        if len(raiz) > 2 and raiz[-1] == raiz[-2]:
            saida.append(raiz[:-1])
    # O adverbio vén do adxectivo: quen sabe «slow» co seu xesto entende
    # «slowly».
    if t.endswith('ily') and len(t) > 5:
        saida.append(t[:-3] + 'y')
    elif t.endswith('ly') and len(t) > 4:
        saida.append(t[:-2])
    # A orde en singular e o curso en plural: «hand» e «Hands». Só en palabras
    # de catro letras ou máis: «to» + «es» daba «Toes».
    if len(t) >= 4:
        saida.append(t + 'es' if t.endswith(('s', 'x', 'z', 'ch', 'sh'))
                     else t + 's')
    return saida


def le_json(ruta: Path):
    with ruta.open(encoding='utf-8') as f:
        return json.load(f)


def cargar_traxecto():
    """As 4.000 palabras, cada unha co seu curso e o seu mes."""
    palabras = {}
    for ci, curso in enumerate(CURSOS):
        for ruta in sorted((CONTIDO / 'tpr' / curso).glob('tpr.*.json')):
            mes = le_json(ruta)
            for semana in mes['semanas']:
                for p in semana['palabras']:
                    palabras[p['id']] = {
                        'id': p['id'],
                        'curso': curso,
                        'orde_curso': ci,
                        'mes': mes['mesCalendario'],
                        'orde_mes': MESES.index(mes['mesCalendario']),
                        'semana': semana['semana'],
                        'en': p['en'],
                        'gl': p['gl'],
                        'es': p['es'],
                        'xesto': {
                            'gl': p['tprAction']['gl'],
                            'es': p['tprAction']['es'],
                        },
                    }
    soltas, frases = {}, []
    for p in palabras.values():
        t = tokens(p['en'])
        if len(t) == 1:
            soltas.setdefault(t[0], p)
        elif len(t) > 1:
            frases.append((t, p))
    # As frases máis longas primeiro: «stand up» antes que «up».
    frases.sort(key=lambda x: -len(x[0]))
    return palabras, soltas, frases


def cargar_asembleas():
    """Cada asemblea co seu curso, o seu mes e as súas ordes en inglés."""
    saida = []
    for ruta in sorted(CONTIDO.glob('asambleas_*_ciclo/*.json')):
        a = le_json(ruta)
        clave = a.get('tramo') or a.get('nivel')
        curso = CURSO_DA_ASEMBLEA[clave]
        ordes = [c for f in a['fases'] for c in f.get('comandosL3', [])]
        saida.append({
            'id': a['id'],
            'curso': curso,
            'orde_curso': CURSOS.index(curso),
            'mes': a['mes'],
            'orde_mes': MESES.index(a['mes']),
            'ordes': ordes,
        })
    saida.sort(key=lambda a: (a['orde_curso'], a['orde_mes']))
    return saida


def cruzar(texto: str, soltas, frases) -> list[dict]:
    """As palabras do curso que saen nunha orde, na orde en que se din."""
    t = tokens(texto)
    usado = [False] * len(t)
    atopadas = []  # (posición, palabra)
    formas = [formas_base(x) for x in t]
    for frase, p in frases:
        n = len(frase)
        for i in range(len(t) - n + 1):
            # «The hedgehog wakes up» é a frase «Wake up» do curso.
            casa = all(frase[k] in formas[i + k] for k in range(n))
            if casa and not any(usado[i:i + n]):
                atopadas.append((i, p))
                for k in range(i, i + n):
                    usado[k] = True
                break
    for i, palabra in enumerate(t):
        if usado[i]:
            continue
        for forma in formas_base(palabra):
            if forma in soltas:
                atopadas.append((i, soltas[forma]))
                break
    atopadas.sort(key=lambda x: x[0])
    vistos, saida = set(), []
    for _, p in atopadas:
        if p['id'] not in vistos:
            vistos.add(p['id'])
            saida.append(p)
    return saida


def antes(p, asemblea) -> bool:
    """Ensinouse antes do mes da asemblea?"""
    return (p['orde_curso'], p['orde_mes']) < (
        asemblea['orde_curso'], asemblea['orde_mes'])


def xerar(fonte: dict):
    """O ficheiro enteiro: o escrito a man máis o xerado."""
    palabras, soltas, frases = cargar_traxecto()
    asembleas = cargar_asembleas()
    revision = fonte.get('revision', {})
    ids_das_ordes = {c['id'] for a in asembleas for c in a['ordes']}

    fallos = []
    excluir = set()
    for e in revision.get('excluir', []):
        if e['orde'] not in ids_das_ordes:
            fallos.append(f"revision.excluir: non hai ningunha orde «{e['orde']}»")
        if e['palabra'] not in palabras:
            fallos.append(
                f"revision.excluir: «{e['palabra']}» non é unha palabra do curso")
        if not e.get('motivo', '').strip():
            fallos.append(
                f"revision.excluir: {e['orde']}/{e['palabra']} sen motivo")
        excluir.add((e['orde'], e['palabra']))
    engadir = {}
    for e in revision.get('engadir', []):
        if e['orde'] not in ids_das_ordes:
            fallos.append(f"revision.engadir: non hai ningunha orde «{e['orde']}»")
        if e['palabra'] not in palabras:
            fallos.append(
                f"revision.engadir: «{e['palabra']}» non é unha palabra do curso")
        if not e.get('motivo', '').strip():
            fallos.append(
                f"revision.engadir: {e['orde']}/{e['palabra']} sen motivo")
        engadir.setdefault(e['orde'], []).append(e['palabra'])
    # Un xesto do curso que non serve aquí —os de 0-2 fanse co bebé— cámbiase
    # só neste ficheiro: o curso queda como está.
    adaptar = {}
    for e in revision.get('adaptar', []):
        if e['palabra'] not in palabras:
            fallos.append(
                f"revision.adaptar: «{e['palabra']}» non é unha palabra do curso")
        xesto = e.get('xesto', {})
        if not (xesto.get('gl', '').strip() and xesto.get('es', '').strip()):
            fallos.append(
                f"revision.adaptar: {e['palabra']} sen xesto en galego e castelán")
        if not e.get('motivo', '').strip():
            fallos.append(f"revision.adaptar: {e['palabra']} sen motivo")
        adaptar[e['palabra']] = {'gl': xesto.get('gl', ''),
                                 'es': xesto.get('es', '')}

    usadas_excluir = set()
    ordes, meses, usadas = {}, {}, set()
    for a in asembleas:
        do_mes = []
        for c in a['ordes']:
            lista = []
            for p in cruzar(c['textoIngles'], soltas, frases):
                if not antes(p, a):
                    continue
                if (c['id'], p['id']) in excluir:
                    usadas_excluir.add((c['id'], p['id']))
                    continue
                lista.append(p['id'])
            for pid in engadir.get(c['id'], []):
                p = palabras.get(pid)
                if p is None:
                    continue
                if not antes(p, a):
                    fallos.append(
                        f"revision.engadir: {c['id']}/{pid} non se ensinou "
                        'antes do mes da asemblea')
                    continue
                if pid not in lista:
                    lista.append(pid)
            if lista:
                ordes[c['id']] = lista
                usadas.update(lista)
                for pid in lista:
                    if pid not in do_mes:
                        do_mes.append(pid)
        if do_mes:
            meses.setdefault(a['curso'], {})[str(a['mes'])] = do_mes

    for e in excluir - usadas_excluir:
        fallos.append(
            f'revision.excluir: {e[0]}/{e[1]} xa non sae do cruce; '
            'sobra esta decisión')
    for pid in set(adaptar) - usadas:
        fallos.append(
            f'revision.adaptar: {pid} non está en ningunha lista; '
            'sobra esta decisión')

    saida = {}
    for clave in ('_doc', 'version', 'textos', 'revision'):
        if clave in fonte:
            saida[clave] = fonte[clave]
    saida['palabras'] = {
        pid: {
            'curso': palabras[pid]['curso'],
            'mes': palabras[pid]['mes'],
            'en': palabras[pid]['en'],
            'gl': palabras[pid]['gl'],
            'es': palabras[pid]['es'],
            'xesto': adaptar.get(pid, palabras[pid]['xesto']),
        }
        for pid in sorted(usadas, key=lambda i: (
            palabras[i]['orde_curso'], palabras[i]['orde_mes'],
            palabras[i]['semana'], palabras[i]['en'].lower()))
    }
    saida['ordes'] = ordes
    saida['meses'] = {
        curso: meses[curso] for curso in CURSOS if curso in meses
    }
    return saida, fallos, (palabras, soltas, frases, asembleas)


def texto_canonico(obj) -> str:
    return json.dumps(obj, ensure_ascii=False, indent=2) + '\n'


def revisar(fonte: dict) -> None:
    """Todas as ordes, co que o cruce atopa e o que se queda."""
    _, _, (palabras, soltas, frases, asembleas) = xerar(fonte)
    excluir = {(e['orde'], e['palabra'])
               for e in fonte.get('revision', {}).get('excluir', [])}
    for a in asembleas:
        print(f"\n## {a['id']}  ({a['curso']}, mes {a['mes']})")
        for c in a['ordes']:
            print(f"  [{c['id']}] {c['textoIngles']}")
            for p in cruzar(c['textoIngles'], soltas, frases):
                if not antes(p, a):
                    continue
                marca = 'FÓRA' if (c['id'], p['id']) in excluir else '    '
                print(f"    {marca} {p['en']:<18} [{p['id']}] {p['curso']} m{p['mes']:<2} "
                      f"gl «{p['gl']}» · xesto «{p['xesto']['gl']}»")


def main(argv: list[str]) -> int:
    fonte = le_json(DESTINO)
    if '--revisar' in argv:
        revisar(fonte)
        return 0
    saida, fallos, _ = xerar(fonte)
    if fallos:
        print('A revisión de ponte_ao_dia.json non cadra:', file=sys.stderr)
        for f in fallos:
            print(f'  - {f}', file=sys.stderr)
        return 1
    novo = texto_canonico(saida)
    if '--check' in argv:
        actual = DESTINO.read_text(encoding='utf-8')
        if actual != novo:
            print('assets/content/ponte_ao_dia.json non é o que sae do curso e '
                  'das asembleas. Executa: python3 tools/xera_ponte_ao_dia.py',
                  file=sys.stderr)
            return 1
        print(f"ponte_ao_dia.json ao día: {len(saida['ordes'])} ordes, "
              f"{len(saida['palabras'])} palabras.")
        return 0
    DESTINO.write_text(novo, encoding='utf-8')
    print(f"Escrito: {len(saida['ordes'])} ordes, "
          f"{len(saida['palabras'])} palabras.")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
