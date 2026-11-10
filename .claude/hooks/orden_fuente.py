#!/usr/bin/env python3
"""Hook UserPromptSubmit (Frank, 9/11/2026, O-20261109-2).

Nació de un fallo de Claude Code: Frank pidió «incorporar la mascota Lúa y
el diseño de premios» queriendo los de Valeria, y Claude Code usó lo que ya
había en este repositorio sin abrir Valeria ni preguntar de dónde copiar.

En CADA mensaje de Frank recuerda la regla R∞ y, si el mensaje pide copiar,
traer o imitar algo (o nombra otro producto o un diseño), obliga a abrir la
fuente antes de programar y a escribirla en docs/ORDENES.md («Fuente:»)."""
import json
import re
import sys

try:
    datos = json.load(sys.stdin)
except Exception:
    datos = {}
texto = str(datos.get("prompt", ""))

PISTAS = re.compile(
    r"cop(ia|ie|iar|ies|iá)|cópia|igual que|como en|como el de|como la de|"
    r"diseño de|dise[ñn]o del|el de valeria|valeria|via\+|earlify|"
    r"otro producto|otra app|del otro|trae(r)? |imita|clona|porta(r)? |"
    r"sistema de premios|mascota|duolingo|ux|ui|repositorio|repo",
    re.IGNORECASE,
)

base = (
    "REGLA R∞ (hook de Frank): antes de tocar nada, la orden se copia LITERAL "
    "en docs/ORDENES.md con sus criterios y una línea «Fuente:». Informe "
    "empieza por lo que falta."
)
mensaje = base
if PISTAS.search(texto):
    mensaje += (
        "\nESTA ORDEN PIDE COPIAR, TRAER O IMITAR ALGO (o nombra otro "
        "producto, un diseño, la mascota o los premios). OBLIGATORIO antes "
        "de programar: 1) identificar la fuente exacta (repositorio, fichero, "
        "pantalla); si es otro repositorio (p. ej. FrankBetances/Valeria), "
        "añadirlo y LEERLO; 2) escribir en ORDENES.md «Fuente: <repo>/<ruta>» "
        "y qué se copia de ella; 3) si la fuente no está clara, PREGUNTAR a "
        "Frank en la primera línea, sin sustituirla por lo que ya hay en este "
        "repositorio. Usar lo que ya existe aquí en lugar de la fuente pedida "
        "es incumplir la orden. Si es UX o diseño: antes de darlo por bueno, "
        "captura de la FUENTE al lado de la captura propia, en el mismo "
        "documento, para que Frank compare."
    )
QUEJA = re.compile(
    r"falso|mentira|engañ|traicion|no (lo )?has hecho|no hiciste|no está|"
    r"no esta|no veo|otra vez|no cumples|no haces|no lo haces|fall(o|ó|aste)|"
    r"está mal|esta mal|todo mal|viejo",
    re.IGNORECASE,
)
if QUEJA.search(texto):
    mensaje += (
        "\nFRANK SEÑALA UN FALLO. PROTOCOLO DE AUTOMEJORA (O-20261109-2), "
        "obligatorio y en el mismo cambio: 1) comprobar el hecho antes de "
        "contestar; 2) añadir una entrada a docs/FALLOS.md con lo que pasó, "
        "la causa raíz y la guarda nueva (hook en .claude/hooks/ o gate en "
        "tools/ o un test) que lo habría parado; 3) crear esa guarda; "
        "4) corregir el fallo; 5) mergear. tools/check_fallos.py tumba CI si "
        "una entrada no tiene guarda existente."
    )
if re.search(r"manual", texto, re.IGNORECASE):
    mensaje += (
        "\nSI TOCA EL MANUAL: regenerar TODAS las capturas (flutter test --tags "
        "capturas --update-goldens test/capturas_test.dart), mirar las que "
        "cambian, comprobar que cada pantalla nueva tiene captura, reconstruir "
        "PDF y Word y mirar el PDF página a página."
    )
print(json.dumps({"hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": mensaje,
}}, ensure_ascii=False))
