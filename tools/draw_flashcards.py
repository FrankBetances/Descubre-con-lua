#!/usr/bin/env python3
"""Cada lámina del banco tiene un dibujo, y el que le toca.

Por qué existe. El banco de 205 láminas llegó con un campo `simbolo` vacío en
las 205: en el original era un emoji, y aquí los emoji no entran (regla 5 del
CLAUDE.md). La galería enseñaba 205 iconos grises de «imagen rota», uno igual
que otro, bajo un rótulo que prometía láminas ilustradas.

Lo que hace este script, en dos pasos y por ese orden:

  1. **Reutiliza el dibujo que ya existe.** El repositorio tiene 80 láminas
     vectoriales dibujadas —objetos y escenas— en `assets/brand/laminas/`.
     `MAPA` dice, lámina a lámina, cuál de ellas es. Eso no se adivina: se
     escribe aquí a mano, y lo que no tiene dibujo propio no se fuerza.

  2. **Dibuja el resto como tarjeta tipográfica**, en el mismo formato
     vectorial y con los colores que la propia lámina ya traía (`corHex` y
     `bgHex`): fondo de color, halo suave y la inicial de la palabra trazada
     con el mismo pincel redondo del resto del set. No es una ilustración y no
     pretende serlo: es una tarjeta de vocabulario legible, coherente y propia,
     que es lo que se puede sostener sin inventar 205 dibujos.

El resultado se escribe en el campo `lamina` de cada entrada de
`assets/content/laminas/banco200_laminas.json`, y las tarjetas generadas en
`assets/brand/laminas/<id>.json`. Lo valida `tools/check_laminas.py` como
cualquier otra lámina.

    python3 tools/draw_flashcards.py            # escribe
    python3 tools/draw_flashcards.py --check    # solo comprueba que está al día
"""

from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LAMINAS_DIR = ROOT / "assets" / "brand" / "laminas"
BANCO = ROOT / "assets" / "content" / "laminas" / "banco200_laminas.json"

# --------------------------------------------------------------------------
# 1. El dibujo que YA existe
#
# Solo entra aquí lo que de verdad es lo mismo. «Vaso de auga» no es la lámina
# `auga`, y «Caixa de tesouros» no es `cesta`: esas se quedan sin dibujo propio
# y salen como tarjeta tipográfica, que es honesto, en vez de enseñar un dibujo
# que no corresponde.
# --------------------------------------------------------------------------
MAPA = {
    # --- alfabeto -------------------------------------------------------
    "flashcard_a_apple": "mazan",
    "flashcard_b_boat": "barco",
    "flashcard_c_cat": "gato",
    "flashcard_f_fish": "peixe",
    "flashcard_h_hat": "gorro",
    "flashcard_j_juice": "laranxa",
    "flashcard_l_leaf": "folla",
    "flashcard_r_rain": "choiva",
    "flashcard_s_sun": "sol",
    "flashcard_t_tree": "arbore",
    "flashcard_u_umbrella": "paraugas",
    "flashcard_w_water": "auga",
    "flashcard_y_yellow": "amarelo",
    # --- vocabulario ----------------------------------------------------
    "vocab_36": "mochila",
    "vocab_37": "zapato",
    "vocab_38": "abrigo",
    "vocab_39": "xabon",
    "vocab_40": "toalla",
    "vocab_59": "manta",
    "vocab_64": "aperta",
    "vocab_65": "barriga",
    # --- animais --------------------------------------------------------
    "animais_68": "gato",
    "animais_69": "paxaro",
    "animais_70": "ra",
    "animais_71": "peixe",
    "animais_72": "gaivota",
    "animais_88": "oso",
    "animais_96": "mexillon",
    # --- vigo · natureza -------------------------------------------------
    "vigo_nat_104": "sol",
    "vigo_nat_106": "charco",
    "vigo_nat_107": "vento",
    "vigo_nat_113": "arbore",
    "vigo_nat_114": "flor",
    "vigo_nat_115": "folla",
    "vigo_nat_116": "castana",
    "vigo_nat_117": "terra",
    "vigo_nat_119": "espuma",
    "vigo_nat_120": "semente",
    "vigo_nat_121": "mexillon",
    # --- escola · rutinas -------------------------------------------------
    "escola_rut_122": "aro",
    "escola_rut_123": "aperta",
    "escola_rut_124": "xabon",
    "escola_rut_130": "cascabel",
    "escola_rut_134": "abrigo",
    "escola_rut_139": "auga",
    "escola_rut_143": "aperta",
    "escola_rut_144": "ollos",
    # --- emocións · corpo --------------------------------------------------
    "emocions_corp_153": "aperta",
    "emocions_corp_156": "cabeza",
    "emocions_corp_157": "ollos",
    "emocions_corp_159": "nariz",
    "emocions_corp_161": "man",
    "emocions_corp_162": "pes",
    "emocions_corp_163": "barriga",
    "emocions_corp_166": "pes",
    "emocions_corp_169": "cascabel",
    "emocions_corp_170": "quente",
    "emocions_corp_171": "frio",
    # --- contos ilustrados: son escenas, y las escenas ya están dibujadas ---
    "cuento_ilus_172": "conto_mar_1",
    "cuento_ilus_173": "conto_mar_2",
    "cuento_ilus_174": "conto_mar_3",
    "cuento_ilus_175": "conto_benvida_1",
    "cuento_ilus_176": "conto_benvida_2",
    "cuento_ilus_177": "conto_benvida_3",
    "cuento_ilus_178": "conto_corpo_2",
    "cuento_ilus_179": "conto_follas_2",
    "cuento_ilus_180": "conto_follas_3",
    "cuento_ilus_181": "conto_choiva_2",
    "cuento_ilus_182": "conto_inverno_1",
    "cuento_ilus_183": "conto_animais_3",
    "cuento_ilus_184": "conto_animais_1",
    "cuento_ilus_185": "conto_cores_1",
    "cuento_ilus_186": "conto_choiva_3",
    "cuento_ilus_187": "conto_primavera_2",
    "cuento_ilus_188": "conto_auga_2",
    "cuento_ilus_189": "conto_mar_1",
    "cuento_ilus_190": "conto_inverno_2",
    "cuento_ilus_191": "conto_follas_1",
    "cuento_ilus_192": "conto_animais_2",
    "cuento_ilus_193": "conto_animais_2",
    "cuento_ilus_194": "conto_primavera_1",
    "cuento_ilus_195": "conto_animais_2",
    "cuento_ilus_196": "conto_corpo_3",
    "cuento_ilus_198": "conto_primavera_2",
    "cuento_ilus_199": "conto_inverno_3",
    "cuento_ilus_200": "conto_mar_1",
    "cuento_ilus_202": "conto_benvida_3",
    "cuento_ilus_205": "conto_mar_2",
}

# --------------------------------------------------------------------------
# 2. La tarjeta tipográfica
#
# Un alfabeto de trazo, en una caja 0..1. Cada letra es una lista de rutas; el
# pincel redondo del painter hace el resto. No es una tipografía: son los
# mismos trazos con los que está dibujado el resto del set.
# --------------------------------------------------------------------------
TRAZOS = {
    "A": ["M0 1 L0.5 0 L1 1", "M0.18 0.66 L0.82 0.66"],
    "B": [
        "M0.08 0 L0.08 1",
        "M0.08 0 L0.58 0 Q0.95 0.25 0.58 0.48 L0.08 0.48",
        "M0.08 0.52 L0.62 0.52 Q1 0.76 0.62 1 L0.08 1",
    ],
    "C": ["M0.95 0.2 Q0.5 -0.1 0.14 0.3 Q-0.04 0.7 0.22 0.88 Q0.6 1.1 0.95 0.8"],
    "D": ["M0.08 0 L0.08 1", "M0.08 0 L0.48 0 Q1 0.5 0.48 1 L0.08 1"],
    "E": ["M0.9 0 L0.12 0 L0.12 1 L0.9 1", "M0.12 0.5 L0.68 0.5"],
    "F": ["M0.9 0 L0.12 0 L0.12 1", "M0.12 0.5 L0.68 0.5"],
    "G": [
        "M0.95 0.2 Q0.5 -0.1 0.14 0.3 Q-0.04 0.7 0.22 0.88 Q0.64 1.1 0.95 0.74",
        "M0.95 0.74 L0.95 0.56 L0.6 0.56",
    ],
    "H": ["M0.12 0 L0.12 1", "M0.88 0 L0.88 1", "M0.12 0.5 L0.88 0.5"],
    "I": ["M0.5 0 L0.5 1", "M0.26 0 L0.74 0", "M0.26 1 L0.74 1"],
    "J": ["M0.78 0 L0.78 0.74 Q0.78 1.08 0.34 0.94"],
    "K": ["M0.14 0 L0.14 1", "M0.88 0 L0.14 0.52", "M0.36 0.36 L0.9 1"],
    "L": ["M0.16 0 L0.16 1 L0.88 1"],
    "M": ["M0.06 1 L0.06 0 L0.5 0.6 L0.94 0 L0.94 1"],
    "N": ["M0.12 1 L0.12 0 L0.88 1 L0.88 0"],
    "O": ["M0.5 0 Q1.02 0.5 0.5 1 Q-0.02 0.5 0.5 0"],
    "P": ["M0.12 1 L0.12 0 L0.58 0 Q0.98 0.28 0.58 0.55 L0.12 0.55"],
    "Q": ["M0.5 0 Q1.02 0.5 0.5 1 Q-0.02 0.5 0.5 0", "M0.6 0.72 L0.96 1.02"],
    "R": [
        "M0.12 1 L0.12 0 L0.58 0 Q0.98 0.28 0.58 0.55 L0.12 0.55",
        "M0.5 0.55 L0.92 1",
    ],
    "S": [
        "M0.9 0.18 Q0.46 -0.12 0.2 0.24 Q0.04 0.5 0.5 0.55 "
        "Q0.98 0.62 0.8 0.86 Q0.5 1.1 0.1 0.8"
    ],
    "T": ["M0.5 0 L0.5 1", "M0.08 0 L0.92 0"],
    "U": ["M0.12 0 L0.12 0.64 Q0.5 1.16 0.88 0.64 L0.88 0"],
    "V": ["M0.08 0 L0.5 1 L0.92 0"],
    "W": ["M0.02 0 L0.26 1 L0.5 0.44 L0.74 1 L0.98 0"],
    "X": ["M0.1 0 L0.9 1", "M0.9 0 L0.1 1"],
    "Y": ["M0.1 0 L0.5 0.5 L0.9 0", "M0.5 0.5 L0.5 1"],
    "Z": ["M0.1 0 L0.9 0 L0.1 1 L0.9 1"],
}

# La caja de la letra dentro del lienzo de 100×100.
CAJA_X, CAJA_Y, CAJA_W, CAJA_H = 32.0, 24.0, 36.0, 48.0


def inicial(texto: str) -> str:
    """La primera letra de la palabra, sin tilde y en mayúscula."""
    for ch in texto:
        base = unicodedata.normalize("NFD", ch)[0].upper()
        if base in TRAZOS:
            return base
    return "A"


# Una orden es UNA letra; los números van pegados a ella («M0.08 0») porque así
# se escribe una ruta SVG. Partir por espacios dejaba «M0.08» como si fuese una
# orden entera y se tragaba la primera coordenada: las letras salían sin dibujo
# y la tarjeta quedaba en blanco. Se tokeniza como lo hace el parser de Dart.
_TOKEN = re.compile(r"[MLQCZ]|-?\d*\.?\d+")


def _escala(ruta: str) -> str:
    """Pasa una ruta de la caja 0..1 al lienzo de 100×100."""
    salida: list[str] = []
    numeros: list[float] = []
    for pieza in _TOKEN.findall(ruta):
        if pieza.isalpha():
            if numeros:
                raise ValueError(f"coordenada suelta en {ruta!r}")
            salida.append(pieza)
            continue
        numeros.append(float(pieza))
        if len(numeros) == 2:
            x = CAJA_X + numeros[0] * CAJA_W
            y = CAJA_Y + numeros[1] * CAJA_H
            salida.append(f"{round(x, 2):g} {round(y, 2):g}")
            numeros.clear()
    if numeros:
        raise ValueError(f"coordenada impar en {ruta!r}")
    return " ".join(salida)


def tarjeta(entrada: dict) -> dict:
    """La lámina vectorial de una entrada que no tiene dibujo propio."""
    cor = entrada.get("corHex") or "#127a75"
    fondo = entrada.get("bgHex") or "#f6fafa"
    letra = inicial(entrada.get("gl", ""))

    formas = [
        {"t": "rrect", "x": 0, "y": 0, "w": 100, "h": 100, "r": 0, "f": fondo},
        {"t": "elipse", "cx": 50, "cy": 48, "rx": 33, "ry": 33, "f": cor + "1a"},
    ]
    for ruta in TRAZOS[letra]:
        formas.append({"t": "ruta", "d": _escala(ruta), "s": cor, "sw": 7})
    # La barra de base cierra la tarjeta y le da peso abajo, como el resto del
    # set, que nunca deja la figura flotando en el centro exacto.
    formas.append(
        {"t": "rrect", "x": 34, "y": 84, "w": 32, "h": 5, "r": 2.5, "f": cor}
    )

    return {
        "vb": 100,
        "vh": 100,
        "nota": f"Tarxeta de vocabulario: {entrada.get('gl', '')}.",
        "generado": "tools/draw_flashcards.py",
        "formas": formas,
    }


def main() -> int:
    comprobar = "--check" in sys.argv

    banco = json.loads(BANCO.read_text(encoding="utf-8"))
    generadas = 0
    reutilizadas = 0
    pendientes = []

    for entrada in banco:
        clave_id = entrada["id"]
        if clave_id in MAPA:
            destino = MAPA[clave_id]
            if not (LAMINAS_DIR / f"{destino}.json").exists():
                print(f"ERROR: {clave_id} apunta a {destino}, que no existe.")
                return 1
            reutilizadas += 1
        else:
            destino = clave_id
            fichero = LAMINAS_DIR / f"{destino}.json"
            nueva = tarjeta(entrada)
            texto = json.dumps(nueva, ensure_ascii=False, indent=2) + "\n"
            if comprobar:
                if not fichero.exists() or fichero.read_text(
                    encoding="utf-8"
                ) != texto:
                    pendientes.append(str(fichero.relative_to(ROOT)))
            else:
                fichero.write_text(texto, encoding="utf-8")
            generadas += 1

        if entrada.get("lamina") != destino:
            if comprobar:
                pendientes.append(f"{clave_id}: falta lamina={destino}")
            else:
                entrada["lamina"] = destino

    if not comprobar:
        BANCO.write_text(
            json.dumps(banco, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    if comprobar and pendientes:
        print("Las láminas del banco no están al día. Corre:")
        print("  python3 tools/draw_flashcards.py")
        for p in pendientes[:10]:
            print(f"  - {p}")
        if len(pendientes) > 10:
            print(f"  ... y {len(pendientes) - 10} más")
        return 1

    print(
        f"OK: {len(banco)} láminas del banco · "
        f"{reutilizadas} reutilizan un dibujo del repositorio · "
        f"{generadas} son tarjeta tipográfica."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
