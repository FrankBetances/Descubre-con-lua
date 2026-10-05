#!/usr/bin/env python3
"""Escribe os ficheiros Dart de nomes desde o seu JSON.

Por que existe. A regra de produto pide o contido en JSON e nunca escrito nos
widgets. Os nomes dos portais —pestanas, grupos, módulos e a liña que di que
hai dentro— son contido: se cambian, cambian para quen le, e non deberían
depender de tocar código. Pero a app ten que telos ao momento, sen ler disco
ao abrir cada pantalla. Así que o JSON é a fonte e este script escribe con el
as clases de constantes que usa a app:

    assets/content/nomes/nomes_portais.json  ->  NomesInicio
                                                  NomesFamilias
                                                  NomesDocentes

    python3 tools/xera_nomes.py           # escribe os ficheiros
    python3 tools/xera_nomes.py --check   # gate: falla se non coinciden

O --check xera noutra carpeta dentro do proxecto e pásaa polo mesmo
`dart format` que o resto: así un nome cambiado no Dart a man, ou no JSON sen
volver xerar, pon o gate en vermello.
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONTE = os.path.join(RAIZ, 'assets', 'content', 'nomes', 'nomes_portais.json')
LOCALIZED = os.path.join('lib', 'core', 'localization', 'localized_string.dart')

CABECEIRA = (
    '// XERADO por tools/xera_nomes.py a partir de\n'
    '// assets/content/nomes/nomes_portais.json. Non se edita a man: cámbiase o\n'
    '// JSON e vólvese xerar con `python3 tools/xera_nomes.py`.\n'
)


def cadea(texto):
    """Un literal de Dart entre comiñas simples."""
    return "'" + texto.replace('\\', '\\\\').replace("'", "\\'").replace(
        '$', '\\$') + "'"


def comentario(texto, sangria='  '):
    """Un comentario de documentación partido a 80 columnas."""
    liñas = []
    for parágrafo in texto.split('\n'):
        if not parágrafo.strip():
            liñas.append(f'{sangria}///')
            continue
        actual = ''
        for palabra in parágrafo.split():
            proba = f'{actual} {palabra}' if actual else palabra
            if len(sangria) + 4 + len(proba) > 80 and actual:
                liñas.append(f'{sangria}/// {actual}')
                actual = palabra
            else:
                actual = proba
        if actual:
            liñas.append(f'{sangria}/// {actual}')
    return '\n'.join(liñas)


def separador(titulo):
    return '  // ' + '-' * (72 - len(titulo)) + ' ' + titulo


def xerar_clase(clase):
    destino = clase['ficheiro']
    importacion = os.path.relpath(
        LOCALIZED, os.path.dirname(destino)).replace(os.sep, '/')
    partes = [CABECEIRA, f"import '{importacion}';", '']
    partes.append(comentario('\n'.join(clase['doc']), sangria=''))
    nome = clase['clase']
    partes.append(f'class {nome} {{')
    partes.append(f'  {nome}._();')
    for grupo in clase['grupos']:
        partes.append('')
        partes.append(separador(grupo['titulo']))
        for e in grupo['entradas']:
            if e.get('nota'):
                partes.append(comentario(e['nota']))
            partes.append(
                f"  static const {e['id']} = LocalizedString("
                f"gl: {cadea(e['gl'])}, es: {cadea(e['es'])});")
            if 'cabeceira' in e:
                enteiro = (f"«{e['gl']}» no cabe entero"
                           if e['gl'] == e['es'] else
                           f"«{e['gl']}» y «{e['es']}» no caben enteros")
                partes.append(comentario(e.get(
                    'notaCabeceira',
                    f"En la cabecera de su pantalla: {enteiro} a 360 px.")))
                c = e['cabeceira']
                partes.append(
                    f"  static const {e['id']}Cabeceira = LocalizedString("
                    f"gl: {cadea(c['gl'])}, es: {cadea(c['es'])});")
    if 'idades' in clase:
        idades = clase['idades']
        partes.append('')
        partes.append(separador('idades'))
        if idades.get('nota'):
            partes.append(comentario(idades['nota']))
        partes.append('  static const idades = <(String, LocalizedString)>[')
        for i in idades['lista']:
            partes.append(
                f"    ({cadea(i['id'])}, LocalizedString("
                f"gl: {cadea(i['gl'])}, es: {cadea(i['es'])})),")
        partes.append('  ];')
        partes.append('')
        partes.append('  static LocalizedString idade(String cursoId) =>')
        partes.append('      idades.firstWhere((e) => e.$1 == cursoId,')
        partes.append('          orElse: () => idades.first).$2;')
    partes.append('}')
    return destino, '\n'.join(partes) + '\n'


def xerar_en(raiz_destino):
    with open(FONTE, encoding='utf-8') as f:
        datos = json.load(f)
    escritos = []
    for clase in datos['clases']:
        destino, texto = xerar_clase(clase)
        ruta = os.path.join(raiz_destino, destino)
        os.makedirs(os.path.dirname(ruta), exist_ok=True)
        with open(ruta, 'w', encoding='utf-8') as f:
            f.write(texto)
        escritos.append((destino, ruta))
    subprocess.run(['dart', 'format', '--output=write'] +
                   [r for _, r in escritos],
                   check=True, capture_output=True)
    return escritos


def main():
    if '--check' not in sys.argv:
        for destino, _ in xerar_en(RAIZ):
            print(f'escrito {destino}')
        return 0
    # Dentro do proxecto, para que `dart format` use a mesma versión da
    # linguaxe que o resto do código.
    os.makedirs(os.path.join(RAIZ, 'build'), exist_ok=True)
    temporal = tempfile.mkdtemp(prefix='xera_nomes_',
                                dir=os.path.join(RAIZ, 'build'))
    try:
        mal = []
        for destino, ruta in xerar_en(temporal):
            real = os.path.join(RAIZ, destino)
            if not os.path.exists(real):
                mal.append(f'{destino}: non existe')
                continue
            with open(ruta, encoding='utf-8') as a, \
                    open(real, encoding='utf-8') as b:
                if a.read() != b.read():
                    mal.append(f'{destino}: non coincide co JSON')
        if mal:
            print('Os nomes do Dart non saen do seu JSON:')
            for m in mal:
                print(f'  {m}')
            print('Cámbiase o JSON e vólvese xerar: '
                  'python3 tools/xera_nomes.py')
            return 1
        print('OK: os nomes do inicio e dos dous portais saen do seu JSON.')
        return 0
    finally:
        shutil.rmtree(temporal, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
