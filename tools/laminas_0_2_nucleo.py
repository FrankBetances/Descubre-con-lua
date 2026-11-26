"""As 23 láminas vectoriais novas do núcleo de 60 pezas de 0-2 anos (P11.6, D4)."""
from __future__ import annotations

import banco_comun as bc
from banco_comun import (
    AGUA,
    AGUA_OSCURO,
    AMARILLO,
    AMARILLO_OSCURO,
    AZUL,
    AZUL_OSCURO,
    BARRO,
    BLANCO,
    E,
    F,
    GRIS,
    GRIS_OSCURO,
    HERBA,
    HERBAB,
    L,
    MADERA,
    MADERA_OSCURA,
    MAR_PROF,
    MORADO,
    NUBE,
    NUBE_B,
    P,
    PEL,
    PELB,
    R,
    ROJO,
    ROJO_OSCURO,
    TIERRA,
    TIERRA_CLARA,
    TINTA,
    VERDE,
    VERDE_OSCURO,
    escribir_cd,
    frecha,
    nino,
    sol,
)


def _ondas(cx: float, cy: float, col: str, n: int = 2) -> list[dict]:
    return [
        L(f"M{cx + i * 7:.1f} {cy - 7 - i * 3:.1f} Q{cx + 6 + i * 7:.1f} {cy:.1f} {cx + i * 7:.1f} {cy + 7 + i * 3:.1f}", col, 2.2)
        for i in range(n)
    ]


def _cara(cx: float, cy: float, pelo_col: str, r: float = 15) -> list[dict]:
    return [
        E(cx, cy - 2, r + 2, r + 2, pelo_col, TINTA, 2.0),
        E(cx, cy, r, r, PEL, PELB, 2.0),
        E(cx - 5, cy - 2, 1.8, 1.8, TINTA),
        E(cx + 5, cy - 2, 1.8, 1.8, TINTA),
        L(f"M{cx - 4:.1f} {cy + 4:.1f} Q{cx:.1f} {cy + 8:.1f} {cx + 4:.1f} {cy + 4:.1f}", ROJO_OSCURO, 2.0),
    ]


DEBUXOS_0_2: dict[str, tuple[str, list[dict], str]] = {
    "mama": (
        "02_mama",
        [R(0, 0, 160, 100, 0, "#fef3c7")]
        + _cara(80, 42, "#92400e", 17)
        + [
            F("M56 26 Q80 12 104 26 Q108 50 100 58 Q96 42 80 34 Q64 42 60 58 Q52 50 56 26 Z", "#92400e", TINTA, 2.0),
            F("M56 62 Q80 54 104 62 L112 96 L48 96 Z", "#ec4899", "#be185d", 2.2),
            E(80, 74, 4, 4, BLANCO),
        ],
        "Muller sorrinte cos brazos abertos representando a mamá.",
    ),
    "papa": (
        "02_papa",
        [R(0, 0, 160, 100, 0, "#dbeafe")]
        + _cara(80, 42, "#451a03", 17)
        + [
            F("M62 28 Q80 18 98 28 Q98 20 80 19 Q62 20 62 28 Z", "#451a03", TINTA, 2.0),
            R(65, 36, 12, 8, 3, "#ffffff", TINTA, 1.6),
            R(83, 36, 12, 8, 3, "#ffffff", TINTA, 1.6),
            L("M77 40 L83 40", TINTA, 1.6),
            F("M54 62 Q80 54 106 62 L114 96 L46 96 Z", AZUL, AZUL_OSCURO, 2.2),
        ],
        "Home sorrinte con lentes representando a papá.",
    ),
    "baa, lamb": (
        "02_baa_lamb",
        bc.fondo_prado()
        + [
            E(72, 60, 26, 18, BLANCO, GRIS_OSCURO, 2.2),
            E(56, 52, 12, 12, BLANCO, GRIS_OSCURO, 2.0),
            E(88, 52, 12, 12, BLANCO, GRIS_OSCURO, 2.0),
            E(72, 46, 14, 12, BLANCO, GRIS_OSCURO, 2.0),
            E(100, 52, 12, 11, "#1e293b", TINTA, 2.0),
            E(92, 44, 5, 3, BLANCO, TINTA, 1.6),
            E(108, 44, 5, 3, BLANCO, TINTA, 1.6),
            E(102, 50, 1.8, 1.8, BLANCO),
            L("M58 76 L58 88 M68 78 L68 88 M82 78 L82 88 M90 76 L90 88", "#1e293b", 3.2),
            *_ondas(120, 44, ROJO, 2),
        ],
        "Año branco no prado con ondas de son para Baa, lamb!",
    ),
    "woof, dog": (
        "02_woof_dog",
        bc.fondo_prado()
        + [
            R(44, 52, 52, 24, 10, TIERRA_CLARA, BARRO, 2.2),
            E(100, 46, 15, 14, TIERRA_CLARA, BARRO, 2.2),
            E(90, 46, 6, 11, BARRO, TINTA, 1.8),
            E(106, 43, 2, 2, TINTA),
            E(114, 48, 3, 2.5, TINTA),
            L("M52 74 L52 88 M62 74 L62 88 M80 74 L80 88 M88 74 L88 88", BARRO, 4.0),
            L("M44 58 Q32 46 38 40", BARRO, 3.6),
            *_ondas(122, 42, ROJO, 2),
        ],
        "Can de cor marrón ladrando con ondas de son para Woof, dog!",
    ),
    "meow, cat": (
        "02_meow_cat",
        [R(0, 0, 160, 100, 0, "#fef9c3")]
        + [
            E(72, 64, 24, 16, "#fb923c", "#9a3412", 2.2),
            E(100, 48, 15, 14, "#fb923c", "#9a3412", 2.2),
            F("M88 37 L92 22 L99 35 Z", "#fb923c", "#9a3412", 2.0),
            F("M101 35 L108 22 L112 37 Z", "#fb923c", "#9a3412", 2.0),
            E(95, 47, 2, 2, TINTA),
            E(105, 47, 2, 2, TINTA),
            F("M98 51 L102 51 L100 54 Z", "#f43f5e", TINTA, 1.4),
            L("M48 64 Q30 50 38 36", "#ea580c", 4.0),
            *_ondas(122, 42, VERDE, 2),
        ],
        "Gato laranxa coas orellas dereitas e ondas de son para Meow, cat!",
    ),
    "quack, duck": (
        "02_quack_duck",
        bc.fondo_mar()
        + [
            E(74, 62, 24, 15, AMARILLO, AMARILLO_OSCURO, 2.2),
            E(98, 44, 13, 12, AMARILLO, AMARILLO_OSCURO, 2.2),
            F("M108 42 L124 46 L108 50 Z", "#f97316", "#9a3412", 2.0),
            E(100, 41, 2, 2, TINTA),
            *_ondas(126, 38, AZUL_OSCURO, 2),
        ],
        "Pato amarelo na auga co peteiro aberto e ondas de son para Quack, duck!",
    ),
    "splash, water": (
        "02_splash_water",
        bc.fondo_mar()
        + [
            L("M24 68 Q52 54 80 68 Q108 54 136 68", BLANCO, 3.2),
            E(60, 44, 5, 8, AGUA, AGUA_OSCURO, 2.0),
            E(80, 32, 6, 10, AGUA, AGUA_OSCURO, 2.0),
            E(100, 42, 5, 8, AGUA, AGUA_OSCURO, 2.0),
            E(48, 52, 4, 6, BLANCO, AGUA_OSCURO, 1.8),
            E(112, 52, 4, 6, BLANCO, AGUA_OSCURO, 1.8),
        ],
        "Salpicadura con pingas de auga saltando para Splash, water!",
    ),
    "pop, bubble": (
        "02_pop_bubble",
        [R(0, 0, 160, 100, 0, "#e0f2fe")]
        + bc.pompas([(46, 60, 12), (82, 44, 18), (118, 32, 9)])
        + [
            L("M96 28 L108 20 M102 44 L116 44 M94 58 L106 66", ROJO, 2.8),
            L("M64 28 L52 20", ROJO, 2.8),
        ],
        "Burbulla grande estoupando con raios arredor para Pop, bubble!",
    ),
    "tap, spoon": (
        "02_tap_spoon",
        [R(0, 0, 160, 100, 0, "#fef3c7")]
        + [
            R(44, 38, 46, 48, 5, "#bae6fd", AGUA_OSCURO, 2.2),
            R(48, 54, 38, 28, 3, AGUA),
            L("M94 24 L118 46", GRIS_OSCURO, 4.2),
            E(92, 24, 9, 6, GRIS, GRIS_OSCURO, 2.0),
            *_ondas(74, 30, ROJO, 2),
        ],
        "Culler petando nun vaso de cristal con ondas de son para Tap, spoon!",
    ),
    "tick-tock, clock": (
        "02_tick_tock",
        [R(0, 0, 160, 100, 0, "#f1f5f9")]
        + [
            E(80, 50, 32, 32, ROJO, ROJO_OSCURO, 2.4),
            E(80, 50, 25, 25, BLANCO, TINTA, 1.8),
            L("M80 50 L80 32", TINTA, 3.0),
            L("M80 50 L96 54", TINTA, 2.6),
            E(80, 50, 3, 3, TINTA),
            *_ondas(116, 46, AZUL_OSCURO, 2),
        ],
        "Reloxo de agullas con ondas de son para Tick-tock, clock!",
    ),
    "all done": (
        "02_all_done",
        [R(0, 0, 160, 100, 0, "#dcfce7")]
        + [
            R(46, 52, 68, 30, 8, BLANCO, VERDE_OSCURO, 2.4),
            E(80, 50, 28, 8, "#f1f5f9", VERDE_OSCURO, 1.8),
            L("M58 28 L72 40 L102 20", VERDE_OSCURO, 4.8),
        ],
        "Cesta baleira e sinal verde indicando todo feito para All done.",
    ),
    "night night": (
        "02_night_night",
        bc.fondo_noite()
        + [
            F("M60 18 C38 22 40 56 66 56 C50 48 50 26 60 18 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            E(116, 26, 2.5, 2.5, BLANCO),
            E(132, 42, 2.0, 2.0, BLANCO),
            E(34, 34, 2.0, 2.0, BLANCO),
            R(46, 64, 68, 22, 6, AZUL, AZUL_OSCURO, 2.2),
            R(48, 56, 22, 12, 4, BLANCO, GRIS_OSCURO, 1.8),
        ],
        "Lúa, estrelas e cama arroupada para Night night.",
    ),
    "peek-a-boo": (
        "02_peek_a_boo",
        [R(0, 0, 160, 100, 0, "#fce7f3")]
        + _cara(80, 48, "#92400e", 19)
        + [
            R(50, 52, 26, 30, 8, PEL, PELB, 2.0),
            R(84, 52, 26, 30, 8, PEL, PELB, 2.0),
            E(72, 40, 2.5, 2.5, TINTA),
            E(88, 40, 2.5, 2.5, TINTA),
        ],
        "Cara sorrinte asomándose entre as mans para Peek-a-boo.",
    ),
    "wash hands": (
        "02_wash_hands",
        [R(0, 0, 160, 100, 0, "#e0f2fe")]
        + [
            E(64, 58, 22, 14, PEL, PELB, 2.2),
            E(96, 58, 22, 14, PEL, PELB, 2.2),
        ]
        + bc.pompas([(68, 38, 6), (82, 30, 8), (94, 40, 6), (76, 54, 7)]),
        "Dúas mans xuntas con escuma e pompas de xabón para Wash hands.",
    ),
    "hold me": (
        "02_hold_me",
        [R(0, 0, 160, 100, 0, "#fee2e2")]
        + nino((62, 34), (62, 46), (62, 70), [[(74, 48)], [(90, 50)]], [[(56, 88)], [(68, 88)]], mira=1, r=10, camisa=(AZUL, AZUL_OSCURO))
        + nino((96, 44), (96, 54), (96, 74), [[(68, 54)], [(84, 52)]], [[(90, 88)], [(102, 88)]], mira=-1, r=8.5, camisa=(ROJO, ROJO_OSCURO)),
        "Dúas figuras abrazándose para Hold me.",
    ),
    "clean up": (
        "02_clean_up",
        [R(0, 0, 160, 100, 0, "#fef3c7")]
        + [
            R(46, 52, 68, 34, 6, TIERRA_CLARA, BARRO, 2.4),
            E(68, 30, 10, 10, ROJO, ROJO_OSCURO, 2.0),
            R(86, 22, 16, 16, 3, AZUL, AZUL_OSCURO, 2.0),
        ]
        + frecha((72, 40), (76, 52), VERDE_OSCURO, 3.0),
        "Xoguetes entrando nunha caixa ordenada para Clean up.",
    ),
    "one, two, three": (
        "02_one_two_three",
        [R(0, 0, 160, 100, 0, "#f0fdf4")]
        + [
            R(24, 60, 26, 22, 4, ROJO, ROJO_OSCURO, 2.0),
            R(66, 44, 26, 38, 4, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(108, 28, 26, 54, 4, AZUL, AZUL_OSCURO, 2.0),
            E(37, 50, 5, 5, ROJO, ROJO_OSCURO, 1.5),
            E(72, 34, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.5),
            E(86, 34, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.5),
            E(112, 18, 4, 4, AZUL, AZUL_OSCURO, 1.5),
            E(121, 18, 4, 4, AZUL, AZUL_OSCURO, 1.5),
            E(130, 18, 4, 4, AZUL, AZUL_OSCURO, 1.5),
        ],
        "Tres torres en escaleira con 1, 2 e 3 puntos para One, two, three.",
    ),
    "big, small, big": (
        "02_big_small_big",
        [R(0, 0, 160, 100, 0, "#f1f5f9")]
        + [
            E(36, 50, 22, 22, ROJO, ROJO_OSCURO, 2.2),
            E(80, 50, 9, 9, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(124, 50, 22, 22, ROJO, ROJO_OSCURO, 2.2),
        ],
        "Círculo grande, pequeno e grande en serie para Big, small, big.",
    ),
    "up, down, up": (
        "02_up_down_up",
        [R(0, 0, 160, 100, 0, "#eff6ff")]
        + frecha((36, 74), (36, 26), VERDE_OSCURO, 3.6)
        + frecha((80, 26), (80, 74), ROJO_OSCURO, 3.6)
        + frecha((124, 74), (124, 26), VERDE_OSCURO, 3.6),
        "Tres frechas arriba, abaixo e arriba en serie para Up, down, up.",
    ),
    "wet, dry, wet": (
        "02_wet_dry_wet",
        [R(0, 0, 160, 100, 0, "#e0f2fe")]
        + [
            E(34, 48, 12, 18, AGUA, AGUA_OSCURO, 2.2),
            R(66, 36, 28, 28, 4, "#fef08a", AMARILLO_OSCURO, 2.2),
            E(126, 48, 12, 18, AGUA, AGUA_OSCURO, 2.2),
        ],
        "Serie auga, esponxa seca e auga para Wet, dry, wet.",
    ),
    "cold, warm, cold": (
        "02_cold_warm_cold",
        [R(0, 0, 160, 100, 0, "#f8fafc")]
        + [
            R(20, 36, 26, 28, 4, "#bae6fd", AZUL_OSCURO, 2.2),
            E(80, 50, 18, 18, "#fb923c", ROJO_OSCURO, 2.2),
            R(114, 36, 26, 28, 4, "#bae6fd", AZUL_OSCURO, 2.2),
        ],
        "Serie bloque frío azul, sol morno laranxa e bloque frío para Cold, warm, cold.",
    ),
    "in, out, in": (
        "02_in_out_in",
        [R(0, 0, 160, 100, 0, "#fef3c7")]
        + [
            R(16, 46, 32, 26, 4, TIERRA_CLARA, BARRO, 2.0),
            E(32, 54, 8, 8, ROJO, ROJO_OSCURO, 1.8),
            R(64, 46, 32, 26, 4, TIERRA_CLARA, BARRO, 2.0),
            E(80, 24, 8, 8, ROJO, ROJO_OSCURO, 1.8),
            R(112, 46, 32, 26, 4, TIERRA_CLARA, BARRO, 2.0),
            E(128, 54, 8, 8, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Pelota dentro, fóra e dentro da caixa en serie para In, out, in.",
    ),
    "open and close": (
        "02_open_close",
        [R(0, 0, 160, 100, 0, "#dcfce7")]
        + [
            R(24, 42, 40, 36, 4, TIERRA_CLARA, BARRO, 2.2),
            L("M24 42 L14 22 L54 22 L64 42", BARRO, 2.4),
            R(96, 42, 40, 36, 4, TIERRA_CLARA, BARRO, 2.2),
            R(96, 36, 40, 8, 2, BARRO, TINTA, 2.0),
        ],
        "Unha caixa aberta á esquerda e pechada á dereita para Open and close.",
    ),
}


def xerar_laminas_nucleo_0_2(pezas: dict) -> int:
    for k, (slug, formas, porque) in DEBUXOS_0_2.items():
        escribir_cd(pezas, k, slug, "D", formas, porque, "tools/laminas_0_2_nucleo.py", k)
    return len(DEBUXOS_0_2)
