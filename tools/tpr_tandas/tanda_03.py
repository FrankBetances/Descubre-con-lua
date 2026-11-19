#!/usr/bin/env python3
"""Tanda 3 TPR (P2.84): cierre de gatear/correr/caminar, palmas/ritmo y primer bloque de abrazos.

Cubre 200 piezas revisadas + 54 auditadas sin base (`SIN_BASE`):
- Resto de `crawl` (6 -> completado), resto de `run` (1 -> completado) y resto de `walk` (90 -> completado).
- Grupo `clap_tap` completo (56: 43 cubiertas + 13 sin base -> completado).
- Primer bloque de `hug_heart` (64 cubiertas + 37 sin base).

Cada pieza ha sido revisada individualmente contra `en`, `es` y `tprAction`.
Las abstractas o sin base visual clara quedan fuera en `SIN_BASE`.
"""
from __future__ import annotations

import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

from tpr_tandas.comun_tpr import (  # noqa: E402
    AGUA,
    AGUA_OSCURO,
    AMARILLO,
    AMARILLO_OSCURO,
    AZUL,
    AZUL_OSCURO,
    BARRO,
    BLANCO,
    DORADO,
    GRIS,
    GRIS_OSCURO,
    HERBA,
    HERBAB,
    MADERA,
    MADERA_OSCURA,
    MAR_PROF,
    MORADO,
    NARANJA,
    NARANJA_OSCURO,
    NEGRO,
    NUBE,
    NUBE_B,
    PEL,
    PELB,
    ROJO,
    ROJO_OSCURO,
    ROSA,
    ROSA_OSCURO,
    TIERRA,
    TIERRA_CLARA,
    TINTA,
    VERDE,
    VERDE_OSCURO,
    E,
    F,
    L,
    P,
    R,
    abrazo_dos,
    arco_giro,
    bebe,
    bebe_sentado,
    caja_prop,
    charco_prop,
    fl,
    fondo_cielo,
    fondo_mar,
    fondo_mesa,
    fondo_noite,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    ico,
    lineas_viento,
    manta_prop,
    mesa_prop,
    nino,
    nino_abrazando,
    nino_aplaudiendo,
    nino_busto,
    nino_caminando,
    nino_corriendo,
    nino_gateando,
    nino_inclinado,
    nino_saltando,
    notas,
    notas_col,
    ondas_sonido,
    pano,
    pelota_prop,
    semilla_prop,
    sol,
    toalla_prop,
)

# ── Directas Fluent Emoji Flat (MIT) ───────────────────────────────────────
DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "a heart with my hands": ("Heart hands", "U", "Dos manos formando un corazón."),
    "applause": ("Clapping hands", "U", "Dos manos aplaudiendo fuerte."),
    "hug a friend": ("People hugging", "U", "Dos amigos dándose un abrazo suave."),
}

# ── Directas Iconify ───────────────────────────────────────────────────────
DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}


def _escenas() -> dict[str, tuple[str, list[dict], str, str | None]]:
    m: dict[str, tuple[str, list[dict], str, str | None]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, lic: str | None = None) -> None:
        m[k] = (cd, formas, porque, lic)

    # ── Resto de gatear (crawl) ────────────────────────────────────────────
    put("be a little seed", "C",
        fondo_prado() + semilla_prop(30, 48, 32) + nino((104, 56), (96, 62), (86, 74), [[(108, 72)], [(90, 74)]], [[(84, 84)], [(96, 84)]]),
        "Semilla pequeña en la tierra y niño encogido en el suelo como ella.")
    put("falling", "C",
        fondo_prado() + fl("Fallen leaf", 28, 12, 34) + [L("M44 48 Q64 60 44 76", NARANJA_OSCURO, 2.2), P([(40, 74), (44, 80), (48, 74)], NARANJA_OSCURO)] + nino((104, 52), (98, 62), (92, 74), [[(116, 58)], [(88, 64)]], [[(84, 86)], [(102, 86)]]),
        "Hoja cayendo suavemente y niño bajando despacio hasta el suelo.")
    put("like a cat", "C",
        fondo_sala() + fl("Cat", 26, 36, 44) + nino_gateando(80, 50, mira=-1),
        "Gato estirando el lomo y niño estirándose en el suelo como él.")
    put("pond", "C",
        fondo_prado() + [E(104, 74, 38, 12, AGUA, AGUA_OSCURO, 2.2), E(104, 74, 20, 5, "#bae6fd")] + nino_gateando(20, 44, mira=1),
        "Estanque azul en el prado con niño agachado al borde mirando su reflejo.")
    put("starfish", "D",
        fondo_mar() + [R(0, 66, 160, 34, 0, "#fde68a", BARRO, 1.5), P([(54, 38), (61, 54), (78, 54), (64, 64), (70, 80), (54, 70), (38, 80), (44, 64), (30, 54), (47, 54)], NARANJA, NARANJA_OSCURO, 2.2)] + nino((112, 34), (112, 46), (112, 64), [[(98, 56)], [(126, 74)]], [[(106, 86)], [(118, 86)]]),
        "Estrella de mar naranja en la arena y niño pegando la mano abierta al suelo.")
    put("when i was a baby, i couldn't walk", "D",
        fondo_sala() + nino_gateando(20, 50, mira=1, col=(AZUL, AZUL_OSCURO)) + frecha((78, 52), (98, 52), ROJO, 2.6) + nino_caminando(124, 34, 1),
        "Bebé gateando antes de aprender y niño ya caminando erguido.")

    # ── Resto de correr (run) ──────────────────────────────────────────────
    put("the robot walks slowly, but the hero runs fast", "C",
        fondo_prado() + fl("Robot", 20, 24, 46) + frecha((68, 48), (84, 48), AZUL_OSCURO, 2.2) + ico("noto", "superhero", 96, 18, 52, NEGRO) + lineas_viento(82, 30, 20, ROJO),
        "Robot caminando rígido y despacio frente al héroe corriendo rápido.", "Apache-2.0")

    # ── Palmas y golpes rítmicos (clap_tap) ────────────────────────────────
    put("bang", "D",
        fondo_sala() + nino((80, 34), (80, 46), (80, 66), [[(66, 66)], [(94, 66)]], [[(72, 88)], [(88, 88)]]) + ondas_sonido(52, 68, ROJO, -1) + ondas_sonido(108, 68, ROJO, 1),
        "Niño golpeando con las palmas las piernas haciendo pum, pum.")
    put("bang the drum", "C",
        fondo_sala() + fl("Drum", 50, 26, 56) + ondas_sonido(36, 42, ROJO, -1) + ondas_sonido(124, 42, ROJO, 1) + frecha((72, 12), (76, 30), AZUL_OSCURO, 2.4),
        "Tambor sonando al golpear encima con las manos.")
    put("beat", "C",
        fondo_sala() + ico("mdi", "metronome", 28, 22, 52, MADERA_OSCURA) + fl("Clapping hands", 86, 24, 48),
        "Metrónomo marcando el compás junto a las palmas.", "Apache-2.0")
    put("beat your chest", "C",
        fondo_prado() + fl("Gorilla", 26, 22, 50) + nino((104, 34), (104, 46), (104, 66), [[(94, 52)], [(114, 52)]], [[(98, 88)], [(110, 88)]]) + ondas_sonido(122, 48, ROJO, 1),
        "Gorila fuerte y niño golpeándose el pecho suavemente como él.")
    put("book", "C",
        fondo_sala() + fl("Open hands", 24, 26, 46) + frecha((72, 48), (88, 48), AZUL_OSCURO, 2.2) + fl("Open book", 92, 24, 48),
        "Manos abiertas juntándose y abriéndose como un libro.")
    put("boom goes the thunder", "C",
        fondo_cielo() + fl("Cloud with lightning", 28, 12, 48) + ondas_sonido(80, 32, AMARILLO_OSCURO, 1) + nino((112, 36), (112, 48), (112, 68), [[(98, 68)], [(126, 68)]], [[(106, 88)], [(118, 88)]]),
        "Nube con rayo de trueno y niño dando una palmada fuerte en las piernas.")
    put("boom-boom, boom-boom", "C",
        fondo_sala() + fl("Beating heart", 28, 22, 46) + nino((102, 34), (102, 46), (102, 66), [[(96, 52)], [(114, 56)]], [[(96, 88)], [(108, 88)]]),
        "Corazón latiendo pum-pum y niño tocando suavemente su pecho.")
    put("booming", "C",
        fondo_sala() + fl("Drum", 50, 20, 56) + ondas_sonido(28, 44, ROJO, -1) + ondas_sonido(132, 44, ROJO, 1) + ondas_sonido(18, 44, NARANJA_OSCURO, -1) + ondas_sonido(142, 44, NARANJA_OSCURO, 1),
        "Tambor retumbando con grandes ondas de sonido al golpear fuerte.")
    put("celebrate", "C",
        fondo_sala() + fl("Party popper", 22, 18, 42) + nino_aplaudiendo(82, 34) + nino_aplaudiendo(122, 34, camisa=(AZUL, AZUL_OSCURO)),
        "Niños celebrando contentos con confeti y palmas.")
    put("celebration", "C",
        fondo_noite() + fl("Confetti ball", 26, 16, 44) + fl("Clapping hands", 82, 22, 52),
        "Bola de confeti brillante y palmas de celebración.")
    put("cheering crowd", "D",
        fondo_sala() + nino_busto(40, 44, brazos_arriba=True) + nino_busto(80, 38, camisa=(AZUL, AZUL_OSCURO), brazos_arriba=True) + nino_busto(120, 44, camisa=(VERDE, VERDE_OSCURO), brazos_arriba=True) + ondas_sonido(22, 24, ROJO, -1) + ondas_sonido(138, 24, ROJO, 1),
        "Varios niños juntos animando y aplaudiendo como un público alegre.")
    put("clap along", "C",
        fondo_sala() + fl("Clapping hands", 34, 22, 52) + notas([(96, 36), (112, 24), (126, 34)]),
        "Manos aplaudiendo al ritmo alegre de las notas musicales.")
    put("clap and stop", "C",
        fondo_sala() + fl("Clapping hands", 24, 24, 48) + fl("Stop sign", 92, 22, 48),
        "Manos dando palmas y señal octogonal de parar de golpe.")
    put("clap flippers", "C",
        fondo_mar() + fl("Seal", 26, 26, 48) + nino_aplaudiendo(104, 34, camisa=(AZUL, AZUL_OSCURO)),
        "Foca marina batiendo aletas y niño dando palmas igual.")
    put("clap pattern", "C",
        fondo_sala() + fl("Clapping hands", 20, 22, 36) + fl("Clapping hands", 62, 22, 36) + fl("Clapping hands", 104, 22, 36) + [E(38, 70, 5, 5, ROJO), E(80, 70, 5, 5, AZUL), E(122, 70, 5, 5, ROJO)],
        "Serie repetida de palmas marcando una secuencia rítmica visual.")
    put("conduct", "D",
        fondo_sala() + nino((52, 34), (52, 46), (52, 66), [[(68, 40)], [(38, 56)]], [[(46, 88)], [(58, 88)]]) + [L("M68 40 L94 22", MADERA_OSCURA, 2.8)] + notas([(108, 32), (124, 22), (136, 34)]),
        "Niño dirigiendo la música moviendo la batuta al compás de las notas.")
    put("drum fingers", "D",
        fondo_sala() + mesa_prop(28, 56, 104, 28) + [E(80, 22, 22, 9, PEL, PELB, 2.0), L("M64 26 L64 52", PELB, 4.2), L("M64 26 L64 52", PEL, 2.2), L("M74 26 L74 52", PELB, 4.2), L("M74 26 L74 52", PEL, 2.2), L("M84 26 L84 52", PELB, 4.2), L("M84 26 L84 52", PEL, 2.2), L("M94 26 L94 52", PELB, 4.2), L("M94 26 L94 52", PEL, 2.2)] + ondas_sonido(48, 46, ROJO, -1) + ondas_sonido(114, 46, ROJO, 1),
        "Mano con dedos tamborileando sobre la superficie de la mesa con ritmo.")
    put("drumbeat", "C",
        fondo_sala() + fl("Drum", 22, 24, 46) + ondas_sonido(74, 44, ROJO, 1) + fl("Stop sign", 94, 24, 44),
        "Golpe fuerte de tambor acompañado de la señal de parar al instante.")
    put("first slow, then fast", "C",
        fondo_prado() + fl("Turtle", 20, 26, 44) + frecha((68, 48), (86, 48), ROJO, 2.4) + fl("Rabbit", 92, 24, 44) + lineas_viento(136, 42, 14, ROJO),
        "Primero ritmo muy despacio como la tortuga y después rápido como el conejo.")
    put("flip", "D",
        fondo_sala() + [E(42, 54, 14, 7, PEL, PELB, 2.0), L("M32 50 L30 34", PELB, 3.0), L("M38 48 L38 30", PELB, 3.0), L("M46 48 L46 30", PELB, 3.0), L("M52 50 L54 34", PELB, 3.0)] + arco_giro(80, 48, 12, ROJO) + [E(118, 42, 14, 7, PEL, PELB, 2.0), L("M108 46 L106 62", PELB, 3.0), L("M114 48 L114 66", PELB, 3.0), L("M122 48 L122 66", PELB, 3.0), L("M128 46 L130 62", PELB, 3.0)],
        "Manos girando arriba y abajo mostrando primero palma y luego dorso.")
    put("floor", "D",
        fondo_sala() + [R(0, 72, 160, 28, 0, MADERA, MADERA_OSCURA, 1.8)] + nino((80, 40), (76, 50), (72, 66), [[(56, 74)], [(92, 74)]], [[(64, 86)], [(84, 86)]]),
        "Niño inclinado tocando con las dos palmas el suelo de madera.")
    put("glad", "C",
        fondo_sala() + nino_aplaudiendo(54, 34, camisa=(AMARILLO, AMARILLO_OSCURO)) + fl("Sun", 104, 20, 38),
        "Niño contento sonriendo y dando palmas despacio.")
    put("ha, ha, ha", "D",
        fondo_sala() + nino_aplaudiendo(80, 34) + [L("M50 22 Q56 14 62 22", ROJO, 2.0), L("M98 22 Q104 14 110 22", ROJO, 2.0)],
        "Niño riéndose alegremente mientras da palmas.")
    put("hard-shelled", "C",
        fondo_mar() + fl("Crab", 48, 24, 54) + frecha((116, 22), (96, 34), ROJO, 2.4),
        "Cangrejo con caparazón duro y flecha señalando su concha rígida.")
    put("here, doggy", "C",
        fondo_prado() + fl("Dog", 26, 26, 48) + nino((104, 38), (104, 50), (104, 68), [[(86, 54)], [(116, 68)]], [[(98, 88)], [(110, 88)]]) + frecha((78, 48), (94, 48), VERDE_OSCURO, 2.2),
        "Perrito viniendo contento mientras el niño le llama y golpea las rodillas.")
    put("i feel happy because we play", "C",
        fondo_prado() + nino_aplaudiendo(48, 34) + pelota_prop(80, 74, 10, VERDE, VERDE_OSCURO) + nino_aplaudiendo(112, 34, camisa=(AZUL, AZUL_OSCURO)),
        "Dos niños felices jugando juntos a la pelota y dando palmas.")
    put("identical", "D",
        fondo_sala() + [R(26, 26, 36, 36, 6, AZUL, AZUL_OSCURO, 2.2), R(98, 26, 36, 36, 6, AZUL, AZUL_OSCURO, 2.2), L("M72 40 L88 40", VERDE_OSCURO, 2.6), L("M72 48 L88 48", VERDE_OSCURO, 2.6)],
        "Dos formas exactamente iguales y simétricas una frente a la otra.")
    put("keep the beat", "C",
        fondo_sala() + ico("mdi", "metronome", 24, 24, 46, MADERA_OSCURA) + nino((104, 34), (104, 46), (104, 66), [[(90, 66)], [(118, 66)]], [[(98, 88)], [(110, 88)]]),
        "Metrónomo y niño golpeando sus piernas al ritmo constante.", "Apache-2.0")
    put("knead", "C",
        fondo_mesa() + [E(80, 56, 28, 12, "#fef3c7", MADERA_OSCURA, 2.0)] + fl("Open hands", 54, 18, 48),
        "Manos apretando y amasando masa blanda encima de la mesa.")
    put("knock on the door", "C",
        fondo_sala() + fl("Door", 48, 16, 64) + ondas_sonido(108, 44, ROJO, 1) + ondas_sonido(36, 44, ROJO, -1),
        "Puerta de madera con ondas de sonido al llamar con los nudillos.")
    put("loud and soft", "D",
        fondo_sala() + [E(34, 48, 14, 14, ROJO, ROJO_OSCURO, 2.0)] + ondas_sonido(52, 48, ROJO, 1) + [E(116, 48, 6, 6, AZUL, AZUL_OSCURO, 1.8), L("M126 44 Q130 48 126 52", AZUL_OSCURO, 1.8)],
        "Golpe fuerte con ondas sonoras grandes frente a toque suave con onda pequeña.")
    put("loud, then quiet", "D",
        fondo_sala() + nino((42, 34), (42, 46), (42, 66), [[(28, 66)], [(56, 66)]], [[(36, 88)], [(48, 88)]]) + ondas_sonido(62, 64, ROJO, 1) + frecha((80, 48), (100, 48), AZUL_OSCURO, 2.4) + nino((124, 34), (124, 46), (124, 66), [[(116, 56)], [(132, 56)]], [[(118, 88)], [(130, 88)]], camisa=(AZUL, AZUL_OSCURO)),
        "Golpe fuerte en las piernas seguido de gesto suave y silencioso.")
    put("mussel", "D",
        fondo_mar() + [F("M80 74 C52 70 40 38 64 24 C74 38 78 56 80 74 Z", "#1e293b", "#0f172a", 2.0), F("M80 74 C108 70 120 38 96 24 C86 38 82 56 80 74 Z", "#334155", "#0f172a", 2.0)] + frecha((54, 18), (66, 18), AMARILLO_OSCURO, 2.0) + frecha((106, 18), (94, 18), AMARILLO_OSCURO, 2.0),
        "Concha bivalva de mejillón azul oscuro abriéndose y cerrándose como dos palmas.")
    put("noisy", "D",
        fondo_sala() + nino((62, 34), (62, 46), (62, 66), [[(48, 56)], [(76, 56)]], [[(56, 86)], [(72, 78)]]) + ondas_sonido(84, 80, ROJO, 1) + ondas_sonido(38, 80, ROJO, -1),
        "Niño golpeando fuerte el suelo haciendo mucho ruido.")
    put("pitter-pat", "D",
        fondo_cielo() + gotas([(36, 22), (62, 16), (98, 24), (124, 18), (52, 48), (82, 44), (112, 50)]) + [R(0, 74, 160, 26, 0, HERBA)],
        "Gotitas de lluvia repiqueteando suavemente sobre el suelo.")
    put("pot lid", "D",
        fondo_mesa() + [E(54, 44, 18, 22, "#cbd5e1", GRIS_OSCURO, 2.2), E(54, 44, 11, 14, None, "#94a3b8", 1.4), R(50, 40, 8, 8, 2, NEGRO), E(106, 44, 18, 22, "#cbd5e1", GRIS_OSCURO, 2.2), E(106, 44, 11, 14, None, "#94a3b8", 1.4), R(102, 40, 8, 8, 2, NEGRO)] + ondas_sonido(80, 18, ROJO, 1) + frecha((73, 72), (87, 72), ROJO, 2.4),
        "Dos tapas metálicas de olla chocando una contra otra con brillo metálico.")
    put("proud parents", "C",
        fondo_sala() + nino_aplaudiendo(54, 24, camisa=(MORADO, "#5b21b6")) + nino_aplaudiendo(106, 24, camisa=(VERDE, VERDE_OSCURO)),
        "Dos personas adultas aplaudiendo sonrientes y orgullosas.")
    put("racing heart", "C",
        fondo_sala() + fl("Beating heart", 32, 20, 48) + ondas_sonido(84, 42, ROJO, 1) + nino((114, 34), (114, 46), (114, 66), [[(106, 52)], [(126, 58)]], [[(108, 88)], [(120, 88)]]),
        "Corazón latiendo acelerado y mano marcando sus latidos rápidos en el pecho.")
    put("rain boots", "C",
        fondo_prado() + fl("Hiking boot", 32, 26, 46) + fl("Hiking boot", 82, 26, 46) + charco_prop(80, 80, 44, 8) + gotas([(52, 18), (108, 18)]),
        "Par de botas pisando alegremente bajo la lluvia en un charco.")
    put("rain on the window", "C",
        fondo_sala() + fl("Window", 32, 16, 58) + gotas([(46, 36), (62, 52), (74, 32)]) + nino((114, 36), (114, 48), (114, 68), [[(90, 44)], [(126, 58)]], [[(108, 88)], [(120, 88)]]),
        "Ventana con gotitas de lluvia y dedo golpeando suave el cristal.")
    put("rhythm", "C",
        fondo_sala() + [L("M24 28 L136 28", GRIS_OSCURO, 1.8), L("M24 38 L136 38", GRIS_OSCURO, 1.8)] + notas_col([(38, 34), (72, 28), (106, 34)], ROJO) + fl("Clapping hands", 58, 48, 42),
        "Pentagrama musical con ritmo y manos acompañando a compás.")
    put("speed up and slow down", "C",
        fondo_prado() + fl("Rabbit", 22, 28, 42) + frecha((30, 18), (62, 18), ROJO, 2.8) + fl("Turtle", 96, 34, 44) + frecha((98, 22), (126, 22), AZUL_OSCURO, 2.0),
        "Conejo veloz acelerando frente a tortuga despacio frenando el ritmo.")
    put("splash about", "D",
        fondo_mar() + [R(24, 54, 112, 28, 6, AZUL, AZUL_OSCURO, 2.2), R(28, 56, 104, 14, 4, AGUA)] + fl("Open hands", 56, 18, 46) + gotas([(42, 46), (118, 46)]),
        "Manos golpeando el agua de la bañera salpicando gotas alrededor.")
    put("steady beat", "C",
        fondo_sala() + fl("Drum", 24, 24, 44) + [E(82, 48, 6, 6, ROJO), E(100, 48, 6, 6, ROJO), E(118, 48, 6, 6, ROJO), E(136, 48, 6, 6, ROJO)],
        "Tambor acompañado de cuatro pulsos constantes y regulares.")
    put("stony", "C",
        fondo_prado() + fl("Rock", 42, 24, 56) + frecha((104, 30), (88, 46), ROJO, 2.4) + ondas_sonido(102, 52, AZUL_OSCURO, 1),
        "Piedra dura gris recibiendo un golpecito que suena firme.")
    put("table", "D",
        fondo_sala() + mesa_prop(34, 42, 92, 42) + nino_busto(80, 18, brazos_arriba=False),
        "Mesa de madera con las dos manos apoyadas con firmeza encima.")
    put("tap along", "D",
        fondo_sala() + [R(26, 52, 56, 16, 4, MADERA, MADERA_OSCURA, 2.2), L("M32 60 L76 60", MADERA_OSCURA, 1.8), L("M54 18 L54 44", PELB, 4.4), L("M54 18 L54 44", PEL, 2.2)] + frecha((66, 20), (62, 44), ROJO, 2.2) + notas([(104, 34), (124, 24)]),
        "Golpecitos suaves con el dedo sobre bloque musical de madera siguiendo la música.")
    put("tap on wood", "C",
        fondo_prado() + fl("Wood", 42, 24, 52) + ondas_sonido(98, 48, ROJO, 1) + frecha((112, 26), (92, 42), AZUL_OSCURO, 2.4),
        "Madera natural y sonido claro al darle golpecitos encima.")
    put("tap shoes", "C",
        fondo_sala() + fl("Flat shoe", 30, 26, 44) + fl("Flat shoe", 86, 26, 44) + ondas_sonido(24, 62, ROJO, -1) + ondas_sonido(136, 62, ROJO, 1),
        "Zapatos dando golpecitos con los talones sobre el suelo.")
    put("tempo", "C",
        fondo_sala() + ico("mdi", "metronome-tick", 32, 20, 56, MADERA_OSCURA) + notas([(100, 30), (118, 22)]) + frecha((94, 62), (132, 62), ROJO, 2.4),
        "Metrónomo en movimiento marcando cambios rápidos y lentos de tempo.", "Apache-2.0")
    put("thin", "D",
        fondo_sala() + [R(77, 14, 6, 70, 2, AZUL, AZUL_OSCURO, 1.8)] + frecha((54, 48), (74, 48), ROJO, 2.2) + frecha((106, 48), (86, 48), ROJO, 2.2),
        "Forma alta y muy estrecha estirada entre las palmas juntas.")
    put("thunder", "C",
        [R(0, 0, 160, 100, 0, "#475569"), R(0, 74, 160, 26, 0, "#334155")] + fl("Cloud with lightning", 48, 12, 62) + ondas_sonido(34, 44, "#fde047", -1) + ondas_sonido(126, 44, "#fde047", 1),
        "Nube de tormenta con relámpago amarillo y estruendo de trueno.")
    put("winning", "C",
        fondo_sala() + fl("Trophy", 26, 22, 46) + nino_aplaudiendo(102, 34),
        "Trofeo brillante dorado y niño sonriendo y aplaudiendo contento.")
    put("wooden", "D",
        fondo_mesa() + [L("M30 62 Q80 56 130 62", MADERA_OSCURA, 1.8), L("M36 74 Q80 68 124 74", MADERA_OSCURA, 1.8)] + frecha((80, 22), (80, 50), ROJO, 2.8) + ondas_sonido(96, 46, ROJO, 1),
        "Superficie de madera con vetas recibiendo un golpe firme.")
    put("wooden spoon", "D",
        fondo_mesa() + [R(36, 42, 48, 30, 4, GRIS, GRIS_OSCURO, 2.2), R(32, 42, 56, 6, 2, GRIS_OSCURO)] + [L("M96 58 L118 24", MADERA_OSCURA, 3.6), E(94, 58, 7, 5, MADERA, MADERA_OSCURA, 2.0)] + ondas_sonido(88, 28, ROJO, 1),
        "Cuchara de madera golpeando el borde de una olla metálica.")
    put("woodpecker", "D",
        fondo_prado() + [R(26, 12, 24, 76, 3, BARRO, MADERA_OSCURA, 2.0), L("M34 20 L34 80", MADERA_OSCURA, 1.6), E(80, 42, 12, 9, NEGRO), E(84, 44, 7, 5, BLANCO), E(74, 28, 7.5, 7.5, NEGRO), E(76, 22, 6, 3, ROJO), E(72, 27, 1.2, 1.2, BLANCO), P([(67, 26), (52, 28), (67, 31)], AMARILLO_OSCURO), L("M74 49 L64 56", MADERA_OSCURA, 2.2)] + ondas_sonido(48, 22, ROJO, -1),
        "Pájaro carpintero de cresta roja y vientre blanco picoteando rápido el tronco.")

    # ── Resto de caminar / pasos (walk) ────────────────────────────────────
    put("boots on, let's go", "C",
        fondo_sala() + fl("Hiking boot", 22, 30, 40) + nino_caminando(84, 34, 1) + frecha((106, 48), (124, 48), ROJO, 2.4) + fl("Door", 118, 22, 36),
        "Botas puestas caminando con paso firme hacia la puerta.")
    put("clap, clap, stamp", "C",
        fondo_sala() + fl("Clapping hands", 24, 22, 42) + nino((102, 34), (102, 46), (102, 66), [[(90, 54)], [(114, 54)]], [[(94, 88)], [(114, 78)]]) + ondas_sonido(122, 82, ROJO, 1),
        "Dar dos palmadas sonoras seguidas de una pisada fuerte.")
    put("cobbles", "D",
        fondo_prado() + [R(0, 68, 160, 32, 0, GRIS)] + [E(28, 80, 12, 6, "#94a3b8", GRIS_OSCURO, 1.8), E(60, 80, 12, 6, "#cbd5e1", GRIS_OSCURO, 1.8), E(92, 80, 12, 6, "#94a3b8", GRIS_OSCURO, 1.8), E(124, 80, 12, 6, "#cbd5e1", GRIS_OSCURO, 1.8)] + nino_caminando(78, 30, 1, paso=6),
        "Suelo empedrado con adoquines redondeados y niño pisando con cuidado.")
    put("crunch", "C",
        fondo_prado() + fl("Fallen leaf", 42, 62, 26) + fl("Maple leaf", 88, 60, 26) + nino((78, 28), (78, 40), (78, 60), [[(66, 48)], [(90, 48)]], [[(68, 76)], [(88, 76)]]) + ondas_sonido(108, 74, NARANJA_OSCURO, 1),
        "Pisar fuerte en el sitio haciendo crujir hojas secas bajo los pies.")
    put("crunchy path", "C",
        fondo_prado() + [F("M20 92 Q80 68 140 92 Z", TIERRA_CLARA, BARRO, 1.8)] + fl("Fallen leaf", 38, 66, 22) + fl("Maple leaf", 72, 68, 22) + fl("Fallen leaf", 104, 66, 22) + nino_caminando(80, 24, 1),
        "Camino cubierto de hojas secas crujientes al pisar.")
    put("feet", "D",
        fondo_sala() + [R(46, 26, 16, 42, 7, PEL, PELB, 2.0), E(54, 24, 3, 3, PEL, PELB, 1.5), R(98, 26, 16, 42, 7, PEL, PELB, 2.0), E(106, 24, 3, 3, PEL, PELB, 1.5)] + notas([(80, 38), (80, 56)]),
        "Dos pies descalzos pisando suave al ritmo del pulso.")
    put("footprints in sand", "C",
        fondo_mar() + [R(0, 62, 160, 38, 0, "#fde68a", BARRO, 1.5)] + fl("Footprints", 46, 56, 36) + nino((104, 26), (104, 38), (104, 58), [[(92, 46)], [(116, 46)]], [[(98, 78)], [(110, 78)]]),
        "Huellas marcadas en la arena de la playa mientras el niño mira sus pisadas.")
    put("footsteps", "C",
        fondo_prado() + fl("Footprints", 34, 48, 34) + fl("Footprints", 88, 48, 34) + frecha((70, 64), (84, 64), ROJO, 2.2),
        "Sucesión de huellas en el suelo mostrando los pasos al caminar.")
    put("heavy steps", "D",
        fondo_prado() + nino((80, 32), (80, 44), (80, 64), [[(62, 54)], [(98, 54)]], [[(70, 86)], [(92, 78)]]) + frecha((94, 64), (94, 86), ROJO, 3.0) + ondas_sonido(104, 84, BARRO, 1),
        "Niño levantando bien la pierna para dar pasos muy pesados.")
    put("keep to the path", "D",
        fondo_prado() + [R(22, 68, 116, 16, 4, TIERRA_CLARA, BARRO, 2.0), L("M26 76 L134 76", VERDE_OSCURO, 2.4)] + nino_caminando(80, 26, 1),
        "Niño caminando con orden justo por encima de la línea del sendero.")
    put("king", "C",
        fondo_sala() + nino_caminando(80, 34, 1, camisa=(MORADO, "#5b21b6")) + fl("Crown", 69, 13, 22),
        "Niño caminando recto y erguido con su corona dorada puesta como un rey.")
    put("lead the way", "D",
        fondo_prado() + nino((52, 34), (52, 46), (52, 66), [[(68, 44)], [(40, 56)]], [[(46, 88)], [(58, 88)]]) + nino_caminando(104, 34, -1, camisa=(AZUL, AZUL_OSCURO)) + frecha((72, 24), (118, 24), VERDE_OSCURO, 2.6),
        "Niño caminando delante guiando el paso mientras señala el camino.")
    put("learn to walk", "D",
        fondo_sala() + bebe_sentado(50, 48) + frecha((68, 54), (92, 54), VERDE_OSCURO, 2.6) + nino((114, 36), (114, 48), (114, 66), [[(98, 44)], [(130, 44)]], [[(108, 88)], [(120, 88)]], r=7.5),
        "Bebé dando sus primeros pasitos inseguros con los brazos abiertos.")
    put("let's go to the beach", "C",
        fondo_mar() + fl("Beach with umbrella", 92, 18, 54) + nino_caminando(44, 34, 1) + fl("Backpack", 20, 42, 28),
        "Niño contento con su mochila caminando hacia la playa con sombrilla.")
    put("let's go to the park", "C",
        fondo_prado() + fl("Deciduous tree", 104, 14, 48) + nino_caminando(46, 34, 1) + nino_caminando(72, 34, 1, camisa=(AZUL, AZUL_OSCURO)),
        "Dos niños caminando juntos cogidos de la mano rumbo al parque.")
    put("let's parade", "D",
        fondo_prado() + nino_caminando(36, 34, 1) + nino_caminando(80, 34, 1, camisa=(AZUL, AZUL_OSCURO)) + nino_caminando(124, 34, 1, camisa=(VERDE, VERDE_OSCURO)),
        "Tres niños en fila marchando alegremente en desfile.")
    put("light steps", "C",
        fondo_sala() + fl("Feather", 28, 22, 38) + fl("Footprints", 92, 48, 36),
        "Pluma ligera indicando pisadas muy suaves sin apenas ruido.")
    put("log", "D",
        fondo_prado() + [R(32, 66, 96, 16, 6, BARRO, MADERA_OSCURA, 2.2), E(34, 74, 5, 8, TIERRA_CLARA, MADERA_OSCURA, 1.8)] + nino((80, 22), (80, 34), (80, 52), [[(60, 38)], [(100, 38)]], [[(74, 68)], [(86, 68)]]),
        "Tronco caído marrón en el suelo con niño caminando por encima en equilibrio.")
    put("march like a knight", "C",
        fondo_sala() + ico("game-icons", "black-knight-helm", 28, 20, 48, GRIS_OSCURO) + nino((104, 32), (104, 44), (104, 64), [[(90, 44)], [(118, 44)]], [[(96, 86)], [(112, 78)]]),
        "Yelmo de caballero y niño marchando muy recto y firme.", "CC-BY-3.0")
    put("mat path", "D",
        fondo_sala() + [R(22, 66, 34, 14, 3, AZUL, AZUL_OSCURO, 1.8), R(62, 66, 34, 14, 3, ROJO, ROJO_OSCURO, 1.8), R(102, 66, 34, 14, 3, VERDE, VERDE_OSCURO, 1.8)] + nino_caminando(79, 24, 1),
        "Camino de tres colchonetas de colores en el suelo con niño andando por encima.")
    put("mud", "D",
        fondo_prado() + [E(80, 76, 44, 12, BARRO, MADERA_OSCURA, 2.2)] + nino_caminando(80, 28, 1, paso=6) + gotas([(50, 68), (110, 68)]),
        "Charco de barro marrón con niño pisando despacio con dificultad.")
    put("muddy bank", "D",
        fondo_mar() + [R(0, 60, 86, 40, 0, BARRO, MADERA_OSCURA, 1.8)] + nino_caminando(48, 26, 1, paso=5),
        "Orilla de barro junto al agua con niño caminando despacio por el borde.")
    put("museum", "C",
        fondo_sala() + fl("Classical building", 24, 18, 52) + nino_caminando(104, 34, -1, paso=6),
        "Edificio clásico de museo y niño paseando despacio observando.")
    put("musical chairs", "C",
        fondo_sala() + fl("Chair", 62, 34, 38) + nino_caminando(26, 34, 1) + notas([(118, 24), (132, 34)]) + arco_giro(81, 52, 34, AZUL_OSCURO),
        "Silla en el centro con notas musicales y niño caminando alrededor.")
    put("old town", "C",
        fondo_sala() + fl("House", 20, 22, 44) + fl("House", 100, 22, 44) + nino_caminando(80, 36, 1, paso=5),
        "Calle estrecha entre casitas antiguas con niño paseando por medio.")
    put("on the ice", "C",
        fondo_cielo() + [R(0, 66, 160, 34, 0, "#e0f2fe", AGUA_OSCURO, 1.8)] + fl("Ice", 22, 56, 28) + nino((96, 26), (96, 38), (96, 56), [[(74, 42)], [(118, 42)]], [[(90, 74)], [(102, 74)]]),
        "Superficie helada azul claro con niño caminando con brazos abiertos para no resbalar.")
    put("on tiptoe", "D",
        fondo_sala() + nino((80, 28), (80, 40), (80, 60), [[(64, 44)], [(96, 44)]], [[(76, 82)], [(84, 82)]]) + frecha((112, 74), (112, 50), AZUL_OSCURO, 2.4),
        "Niño levantando los talones para caminar muy alto de puntillas.")
    put("orbit", "C",
        fondo_noite() + fl("Sun", 60, 28, 40) + [E(80, 48, 46, 24, None, "#fde047", 2.0)] + fl("Globe showing americas", 22, 34, 26),
        "Planeta azul siguiendo su órbita en círculo alrededor del Sol.")
    put("parade around", "D",
        fondo_prado() + nino((60, 34), (60, 46), (60, 66), [[(48, 44)], [(72, 48)]], [[(54, 86)], [(68, 76)]]) + nino((100, 34), (100, 46), (100, 66), [[(88, 44)], [(112, 48)]], [[(94, 86)], [(108, 76)]], camisa=(AZUL, AZUL_OSCURO)) + arco_giro(80, 56, 38, ROJO),
        "Niños desfilando en círculo levantando bien las rodillas.")
    put("path", "D",
        fondo_prado() + [F("M20 90 Q80 62 140 90 L140 98 Q80 72 20 98 Z", TIERRA_CLARA, BARRO, 1.8)] + nino_caminando(60, 26, 1) + nino_caminando(100, 28, 1, camisa=(AZUL, AZUL_OSCURO)),
        "Sendero marcado en el prado con dos niños caminando en fila.")
    put("pavement", "D",
        fondo_prado() + [R(0, 68, 160, 32, 0, GRIS, GRIS_OSCURO, 1.8), L("M0 72 L160 72", BLANCO, 2.0)] + nino_caminando(80, 28, 1),
        "Acera gris elevada por donde camina ordenadamente el niño.")
    put("paws", "C",
        fondo_prado() + fl("Paw prints", 26, 28, 42) + nino_gateando(84, 52, mira=-1),
        "Huellas de zarpas y niño caminando a cuatro patas como un animal.")
    put("pier", "D",
        fondo_mar() + [R(18, 62, 108, 12, 3, MADERA, MADERA_OSCURA, 2.0), R(30, 74, 8, 18, 1, MADERA_OSCURA), R(70, 74, 8, 18, 1, MADERA_OSCURA), R(110, 74, 8, 18, 1, MADERA_OSCURA)] + nino_caminando(84, 18, 1),
        "Muelle de madera sobre el agua con niño caminando hasta el borde.")
    put("pond duck", "C",
        fondo_mar() + fl("Duck", 28, 28, 46) + nino((106, 40), (106, 52), (106, 68), [[(92, 62)], [(120, 62)]], [[(100, 86)], [(112, 86)]]),
        "Pato del estanque y niño caminando balanceándose agachado como él.")
    put("prowl", "C",
        fondo_prado() + fl("Tiger", 26, 28, 46) + nino((104, 42), (100, 52), (96, 68), [[(118, 56)], [(84, 58)]], [[(90, 88)], [(108, 88)]]),
        "Tigre acechando sigiloso y niño caminando agachado y despacio.")
    put("puddle edge", "D",
        fondo_prado() + charco_prop(92, 76, 38, 10) + nino_caminando(34, 28, 1) + [L("M52 72 Q92 58 132 72", ROJO, 2.2)],
        "Borde exterior del charco y niño caminando alrededor sin mojarse.")
    put("puddle ice", "C",
        fondo_prado() + [E(80, 76, 36, 9, "#e0f2fe", AGUA_OSCURO, 2.2)] + fl("Snowflake", 28, 22, 30) + nino((80, 26), (80, 38), (80, 56), [[(60, 44)], [(100, 44)]], [[(74, 74)], [(86, 74)]]),
        "Charco helado y niño pisando muy despacio con cuidado encima.")
    put("quiet as a mouse", "C",
        fondo_sala() + fl("Mouse", 28, 34, 44) + nino((104, 32), (104, 44), (104, 64), [[(98, 36)], [(114, 56)]], [[(100, 84)], [(108, 84)]]),
        "Ratón silencioso y niño andando de puntillas sin hacer ruido.")
    put("return", "D",
        fondo_sala() + [E(34, 76, 18, 6, None, VERDE_OSCURO, 2.4)] + nino_caminando(104, 34, -1) + [L("M118 22 Q80 12 40 24", ROJO, 2.6), P([(44, 18), (36, 25), (46, 28)], ROJO)],
        "Niño dando la vuelta para caminar de regreso hacia el círculo.")
    put("rope bridge", "D",
        fondo_mar() + [L("M16 42 Q80 60 144 42", MADERA_OSCURA, 2.6), L("M16 62 Q80 76 144 62", MADERA, 4.0)] + nino((80, 22), (80, 34), (80, 52), [[(60, 44)], [(100, 44)]], [[(74, 68)], [(86, 68)]]),
        "Puente colgante de cuerdas sobre el río con niño cruzando agarrado.")
    put("round the chair", "C",
        fondo_sala() + fl("Chair", 58, 28, 46) + nino_caminando(32, 34, 1) + arco_giro(80, 54, 36, AZUL_OSCURO),
        "Silla en el centro y niño caminando alrededor dando la vuelta.")
    put("roundabout", "D",
        fondo_prado() + [E(80, 62, 42, 18, GRIS, GRIS_OSCURO, 2.2), E(80, 62, 18, 8, HERBA, HERBAB, 1.8)] + arco_giro(80, 62, 28, ROJO) + nino_caminando(126, 26, -1),
        "Rotonda circular con flechas indicando la vuelta alrededor.")
    put("seals and bears", "C",
        fondo_prado() + fl("Seal", 24, 26, 46) + fl("Bear", 92, 24, 48) + ondas_sonido(74, 48, ROJO, -1),
        "Foca aplaudiendo y oso caminando pesado uno junto al otro.")
    put("spider crab", "C",
        fondo_mar() + fl("Crab", 32, 30, 48) + nino((106, 36), (106, 48), (106, 66), [[(86, 42)], [(126, 42)]], [[(94, 86)], [(118, 86)]]) + frecha((84, 22), (128, 22), ROJO, 2.4),
        "Centolla marina de patas largas y niño caminando de lado con brazos abiertos.")
    put("splash around", "D",
        fondo_prado() + charco_prop(80, 76, 38, 10) + nino((80, 26), (80, 38), (80, 58), [[(64, 46)], [(96, 46)]], [[(72, 76)], [(88, 72)]]) + gotas([(44, 62), (116, 62), (56, 52), (104, 52)]),
        "Niño pisando fuerte en el charco salpicando gotas alrededor.")
    put("spring-like", "C",
        fondo_prado() + fl("Blossom", 26, 54, 28) + fl("Butterfly", 104, 18, 32) + nino_caminando(76, 32, 1),
        "Prado primaveral con flor, mariposa y niño dando pasitos alegres.")
    put("squelchy", "D",
        fondo_prado() + [E(80, 76, 40, 11, BARRO, MADERA_OSCURA, 2.2)] + nino((80, 28), (80, 40), (80, 60), [[(66, 48)], [(94, 48)]], [[(72, 78)], [(88, 74)]]) + [E(44, 66, 4, 3, BARRO), E(116, 66, 4, 3, BARRO)] + ondas_sonido(108, 74, BARRO, 1),
        "Pisadas en el barro blando salpicando con ruido chapoteante.")
    put("step between", "D",
        fondo_sala() + [E(44, 78, 18, 6, None, ROJO, 3.0), E(116, 78, 18, 6, None, AZUL, 3.0)] + nino_caminando(80, 30, 1),
        "Dos aros en el suelo y niño pisando con precisión justo en medio.")
    put("step between the hoops", "D",
        fondo_sala() + [E(34, 78, 16, 6, None, ROJO, 2.8), E(80, 78, 16, 6, None, AMARILLO_OSCURO, 2.8), E(126, 78, 16, 6, None, AZUL, 2.8)] + nino_caminando(57, 28, 1),
        "Tres aros alineados en el suelo y niño pasando entre ellos.")
    put("stomp like a bear", "C",
        fondo_prado() + fl("Bear", 26, 24, 48) + nino((104, 34), (104, 46), (104, 66), [[(88, 56)], [(120, 56)]], [[(96, 86)], [(114, 76)]]) + frecha((122, 66), (122, 86), ROJO, 2.6),
        "Oso grande y niño dando pisadas fuertes y lentas como él.")
    put("stomp your boots", "C",
        fondo_sala() + fl("Hiking boot", 26, 30, 44) + fl("Hiking boot", 86, 30, 44) + frecha((48, 14), (48, 28), ROJO, 2.6) + frecha((108, 14), (108, 28), ROJO, 2.6) + ondas_sonido(132, 66, ROJO, 1),
        "Botas grandes pisando fuerte el suelo pum, pum.")
    put("stomp, stomp, stomp", "D",
        fondo_prado() + nino((80, 32), (80, 44), (80, 64), [[(66, 52)], [(94, 52)]], [[(72, 86)], [(90, 76)]]) + [E(62, 84, 4, 3, ROJO), E(80, 84, 4, 3, ROJO), E(98, 84, 4, 3, ROJO)],
        "Tres pisadas rítmicas bien fuertes marcadas en el suelo.")
    put("stomping", "D",
        fondo_prado() + nino((76, 32), (76, 44), (76, 64), [[(60, 52)], [(92, 52)]], [[(68, 86)], [(88, 74)]]) + ondas_sonido(104, 82, ROJO, 1) + ondas_sonido(48, 82, ROJO, -1),
        "Niño pisando fuerte el suelo al ritmo con los pies alternos.")
    put("stop and go", "C",
        fondo_sala() + fl("Stop sign", 26, 22, 44) + nino_caminando(104, 34, 1) + frecha((74, 48), (92, 48), VERDE_OSCURO, 2.6),
        "Señal roja de parar alternada con el paso adelante al seguir.")
    put("straight on, then right", "D",
        fondo_prado() + nino_caminando(48, 34, 1) + [L("M78 72 L78 36 L124 36", ROJO, 3.6), P([(118, 30), (132, 36), (118, 42)], ROJO)],
        "Niño caminando primero recto y luego doblando hacia la derecha.")
    put("street", "D",
        fondo_prado() + [R(0, 62, 160, 28, 0, GRIS, GRIS_OSCURO, 1.5), L("M18 76 L46 76", BLANCO, 2.6), L("M72 76 L100 76", BLANCO, 2.6), L("M124 76 L150 76", BLANCO, 2.6)] + nino_caminando(58, 28, 1) + nino_caminando(106, 28, 1, camisa=(AZUL, AZUL_OSCURO)),
        "Calle urbana por donde caminan en fila los niños.")
    put("tall like a giraffe", "C",
        fondo_prado() + fl("Giraffe", 24, 16, 56) + nino((106, 26), (106, 38), (106, 58), [[(96, 16)], [(116, 16)]], [[(102, 82)], [(110, 82)]]),
        "Jirafa muy alta y niño estirándose de puntillas todo lo posible.")
    put("the earth goes around the sun", "C",
        fondo_noite() + fl("Sun", 60, 28, 40) + [E(80, 48, 48, 24, None, "#94a3b8", 1.8)] + fl("Globe showing americas", 22, 34, 28) + arco_giro(80, 48, 38, "#fde047"),
        "La Tierra dando la vuelta entera alrededor del Sol.")
    put("through the jungle", "C",
        fondo_prado() + fl("Palm tree", 20, 14, 52) + fl("Deciduous tree", 104, 16, 52) + nino_caminando(78, 34, 1),
        "Niño abriéndose paso entre grandes hojas y árboles de la selva.")
    put("tickle", "D",
        fondo_sala() + nino((52, 34), (52, 46), (52, 66), [[(40, 56)], [(84, 50)]], [[(46, 88)], [(58, 88)]]) + nino((106, 34), (106, 46), (106, 66), [[(92, 54)], [(120, 56)]], [[(100, 88)], [(112, 88)]], camisa=(AZUL, AZUL_OSCURO)) + ondas_sonido(86, 44, ROJO, 1),
        "Dedos caminando suavemente por el brazo haciendo cosquillas alegres.")
    put("tightrope", "D",
        fondo_sala() + [L("M16 78 L144 78", BARRO, 3.6)] + nino((80, 22), (80, 34), (80, 52), [[(56, 36)], [(104, 36)]], [[(76, 76)], [(84, 76)]]),
        "Niño caminando en equilibrio por una línea fina con los brazos en cruz.")
    put("tiptoe through", "D",
        fondo_prado() + [L("M34 86 L28 60", VERDE_OSCURO, 2.4), L("M44 86 L46 58", VERDE_OSCURO, 2.4), L("M116 86 L114 58", VERDE_OSCURO, 2.4), L("M126 86 L132 60", VERDE_OSCURO, 2.4)] + nino((80, 30), (80, 42), (80, 62), [[(68, 48)], [(92, 48)]], [[(76, 84)], [(84, 84)]]),
        "Niño pasando con cuidado de puntillas por entre la hierba alta.")
    put("turn back", "D",
        fondo_prado() + nino_caminando(48, 34, -1) + [L("M84 30 L124 30 Q138 30 138 44 Q138 58 124 58 L84 58", ROJO, 3.0), P([(90, 52), (78, 58), (90, 64)], ROJO)],
        "Flecha de giro en U mostrando cómo darse la vuelta para caminar hacia atrás.")
    put("turn left at the square", "D",
        fondo_prado() + [R(56, 34, 48, 36, 2, "#fef3c7", BARRO, 2.0), R(62, 40, 36, 24, 1, "#fde68a", BARRO, 1.2), E(80, 52, 9, 6, AGUA, AGUA_OSCURO, 1.8)] + [L("M124 72 L124 22 L80 22", AZUL_OSCURO, 3.4), P([(86, 16), (72, 22), (86, 28)], AZUL_OSCURO)] + nino_caminando(34, 34, 1),
        "Plaza cuadrada con fuente central y flecha girando a la izquierda.")
    put("two by two", "D",
        fondo_prado() + nino_caminando(46, 34, 1) + nino_caminando(72, 34, 1, camisa=(AZUL, AZUL_OSCURO)) + nino_caminando(114, 34, 1, camisa=(VERDE, VERDE_OSCURO)),
        "Niños caminando emparejados de dos en dos.")
    put("up to the star", "C",
        fondo_noite() + fl("Star", 62, 8, 36) + nino((80, 44), (80, 54), (80, 72), [[(68, 36)], [(92, 36)]], [[(76, 88)], [(84, 88)]]),
        "Estrella brillante arriba y niño estirándose de puntillas para alcanzarla.")
    put("uphill", "D",
        fondo_prado() + [P([(20, 84), (140, 84), (140, 26)], HERBA, HERBAB, 2.2)] + nino_inclinado(84, 34, 12) + frecha((38, 56), (92, 24), ROJO, 2.8),
        "Subida pronunciada por una cuesta caminando inclinado con esfuerzo.")
    put("very old", "C",
        fondo_sala() + ico("healthicons", "cane", 32, 26, 48, MADERA_OSCURA) + nino_inclinado(94, 34, -10, camisa=(GRIS, GRIS_OSCURO)),
        "Bastón de apoyo y figura caminando muy despacio ligeramente encorvada.", "MIT")
    put("waddle", "C",
        fondo_prado() + fl("Duck", 26, 30, 46) + nino_inclinado(104, 34, 10),
        "Pato caminando y niño anadeando balanceando su cuerpo de un lado a otro.")
    put("walk across", "D",
        fondo_prado() + [R(24, 62, 112, 22, 2, GRIS, GRIS_OSCURO, 1.8)] + nino_caminando(80, 28, 1) + frecha((36, 22), (124, 22), VERDE_OSCURO, 2.6),
        "Niño cruzando caminando de un lado al otro.")
    put("walk along", "D",
        fondo_prado() + [L("M20 82 L140 82", BARRO, 3.0)] + nino_caminando(48, 32, 1) + nino_caminando(96, 32, 1, camisa=(AZUL, AZUL_OSCURO)),
        "Niños caminando en fila a lo largo de todo el recorrido.")
    put("walk backwards", "D",
        fondo_sala() + nino_caminando(92, 34, 1) + frecha((72, 26), (30, 26), ROJO, 2.8),
        "Niño dando pasos hacia atrás con cuidado mirando de frente.")
    put("walk down", "D",
        fondo_prado() + [P([(20, 26), (20, 84), (140, 84)], HERBA, HERBAB, 2.2)] + nino_inclinado(68, 32, -8) + frecha((84, 18), (126, 46), AZUL_OSCURO, 2.8),
        "Niño bajando caminando despacio por la pendiente de la cuesta.")
    put("walk fingers", "D",
        fondo_sala() + [R(28, 56, 86, 15, 7, PEL, PELB, 2.0), E(58, 30, 7, 5, PEL, PELB, 1.8), L("M54 34 L48 56", PELB, 3.6), L("M54 34 L48 56", PEL, 2.0), L("M62 34 L68 56", PELB, 3.6), L("M62 34 L68 56", PEL, 2.0)] + frecha((76, 28), (110, 28), MORADO, 2.4),
        "Dos dedos caminando como patitas a lo largo del antebrazo.")
    put("walk heavily", "C",
        fondo_prado() + fl("Elephant", 24, 20, 52) + nino_caminando(104, 34, 1) + ondas_sonido(126, 82, BARRO, 1),
        "Elefante pesando mucho y niño caminando con pisadas pesadas.")
    put("walk lightly", "C",
        fondo_prado() + fl("Butterfly", 26, 18, 36) + nino((100, 32), (100, 44), (100, 64), [[(86, 48)], [(114, 48)]], [[(96, 84)], [(104, 84)]]),
        "Mariposa suave y niño caminando muy ligero de puntillas.")
    put("walk like a penguin", "C",
        fondo_cielo() + [R(0, 68, 160, 32, 0, BLANCO, "#bae6fd", 1.8)] + fl("Penguin", 28, 24, 48) + nino((104, 32), (104, 44), (104, 64), [[(90, 56)], [(118, 56)]], [[(100, 84)], [(108, 84)]]),
        "Pingüino dando pasitos cortos y niño imitándolo con brazos pegados.")
    put("walk like an elephant", "C",
        fondo_prado() + fl("Elephant", 24, 22, 50) + nino((102, 36), (102, 48), (102, 66), [[(84, 52), (76, 62)], [(114, 58)]], [[(94, 86)], [(110, 86)]]),
        "Elefante con su larga trompa y niño caminando balanceando un brazo como trompa.")
    put("walk on stage", "D",
        fondo_sala() + [R(36, 16, 100, 64, 3, "#fef3c7", MADERA_OSCURA, 2.2), R(22, 16, 16, 64, 2, ROJO, ROJO_OSCURO, 1.8)] + nino_caminando(84, 30, 1),
        "Niño subiendo caminando erguido al escenario con telón rojo.")
    put("walk sideways like a crab", "C",
        fondo_mar() + fl("Crab", 28, 30, 48) + nino_caminando(104, 34, 1) + frecha((84, 22), (128, 22), ROJO, 2.4),
        "Cangrejo andando de lado y niño caminando lateralmente con manos en pinza.")
    put("walk softly", "D",
        fondo_sala() + nino((62, 32), (62, 44), (62, 64), [[(52, 52)], [(72, 52)]], [[(58, 84)], [(66, 84)]]) + [L("M50 88 L74 88", "#94a3b8", 1.8)] + [E(104, 48, 10, 8, BLANCO, GRIS_OSCURO, 1.8), E(122, 48, 10, 8, BLANCO, GRIS_OSCURO, 1.8), E(113, 41, 12, 9, BLANCO, GRIS_OSCURO, 1.8), E(113, 47, 14, 7, BLANCO)],
        "Nube blanda indicando pisadas muy suaves y silenciosas sin ruido.")
    put("walk through", "C",
        fondo_prado() + fl("Evergreen tree", 22, 14, 52) + fl("Evergreen tree", 104, 14, 52) + nino_caminando(78, 34, 1),
        "Niño paseando tranquilo por en medio de dos árboles altos.")
    put("walk to school", "C",
        fondo_prado() + nino_caminando(44, 34, 1) + frecha((66, 48), (88, 48), VERDE_OSCURO, 2.4) + fl("School", 92, 18, 56),
        "Niño caminando contento de camino hacia el colegio.")
    put("walking stick", "C",
        fondo_prado() + ico("healthicons", "cane", 36, 20, 52, MADERA_OSCURA) + nino_caminando(100, 34, 1),
        "Bastón de paseo acompañando al niño al caminar.", "MIT")
    put("with the drum", "C",
        fondo_sala() + fl("Drum", 26, 26, 46) + nino_caminando(102, 34, 1) + notas([(70, 22), (90, 18)]),
        "Tambor marcando el pulso mientras el niño camina al ritmo.")
    put("wobbly bridge", "D",
        fondo_mar() + [L("M18 68 Q50 56 80 68 Q110 80 142 68", MADERA_OSCURA, 4.0)] + nino((80, 22), (80, 34), (80, 52), [[(56, 36)], [(104, 36)]], [[(74, 68)], [(86, 68)]]),
        "Puente ondulado que se mueve y niño cruzando en equilibrio con brazos en cruz.")

    # ── Abrazos, ternura y caricias (hug_heart) ────────────────────────────
    put("apricot", "C",
        fondo_mesa() + fl("Peach", 48, 22, 54) + [L("M34 38 Q42 54 34 68", ROSA_OSCURO, 2.0), L("M118 38 Q110 54 118 68", ROSA_OSCURO, 2.0)],
        "Fruta aterciopelada de albaricoque acariciada suavemente.")
    put("arctic", "C",
        fondo_cielo() + [R(0, 68, 160, 32, 0, BLANCO, "#bae6fd", 1.8)] + fl("Snowflake", 26, 16, 30) + fl("Polar bear", 104, 24, 42) + nino_abrazando(74, 32, camisa=(AZUL, AZUL_OSCURO)),
        "Frío ártico con nieve y oso polar mientras el niño se abraza para calentarse.")
    put("calf", "C",
        fondo_prado() + fl("Cow", 24, 26, 48) + abrazo_dos(102, 34),
        "Vaca con cría tierna mientras dos amigos se acurrucan juntos.")
    put("can you feel your heart", "C",
        fondo_sala() + fl("Beating heart", 28, 22, 46) + nino((102, 34), (102, 46), (102, 66), [[(98, 50)], [(116, 56)]], [[(96, 88)], [(108, 88)]]),
        "Corazón latiendo y niño sintiendo su pecho con la mano.")
    put("care for the sea", "C",
        fondo_mar() + fl("Heart hands", 20, 18, 38) + fl("Whale", 68, 22, 58),
        "Cuidar el mar abrazando y protegiendo la vida marina.")
    put("caring for others", "C",
        fondo_sala() + fl("Teddy bear", 36, 28, 46) + nino_abrazando(102, 34),
        "Peluche cuidado con cariño y niño dando un abrazo tierno.")
    put("chest", "D",
        fondo_sala() + nino((80, 32), (80, 44), (80, 64), [[(80, 48)], [(96, 56)]], [[(74, 88)], [(86, 88)]]) + frecha((116, 48), (92, 48), ROJO, 2.6),
        "Niño con la mano sobre el centro del pecho y flecha señalándolo.")
    put("chilly wind", "C",
        fondo_cielo() + fl("Wind face", 24, 20, 44) + lineas_viento(64, 34, 24, AZUL_OSCURO) + nino_abrazando(108, 34, camisa=(AZUL, AZUL_OSCURO)),
        "Viento frío soplando y niño abrazándose el cuerpo para entrar en calor.")
    put("comfort", "D",
        fondo_sala() + nino((62, 34), (62, 46), (62, 66), [[(50, 56)], [(72, 56)]], [[(56, 88)], [(68, 88)]], camisa=(AZUL, AZUL_OSCURO)) + nino((96, 34), (96, 46), (96, 66), [[(72, 44)], [(108, 56)]], [[(90, 88)], [(102, 88)]]),
        "Niño consolando a su compañero apoyando la mano amable en su hombro.")
    put("cosy", "C",
        fondo_sala() + manta_prop(46, 36, 68, col="#fde68a", h=36) + nino_busto(80, 22),
        "Niño arropado dentro de una manta suave y acogedora.")
    put("cosy nest", "C",
        fondo_prado() + fl("Bird", 60, 18, 36) + [E(80, 64, 36, 12, BARRO, MADERA_OSCURA, 2.2), E(80, 62, 26, 7, TIERRA_CLARA)] + nino_abrazando(124, 34),
        "Nido cálido de pajarito y niño acurrucado recogido en sí mismo.")
    put("cute", "C",
        fondo_sala() + fl("Front-facing baby chick", 28, 26, 44) + nino((102, 34), (102, 46), (102, 66), [[(94, 42)], [(110, 42)]], [[(96, 88)], [(108, 88)]]),
        "Pollito tierno y niño juntando las manos bajo la barbilla con sonrisa dulce.")
    put("farewell hug", "D",
        fondo_sala() + abrazo_dos(68, 34) + [L("M85 48 L112 30", PELB, 4.4), L("M85 48 L112 30", PEL, 2.4), L("M116 22 Q124 18 128 26", ROJO, 2.0)],
        "Dos amigos abrazándose cálidamente mientras uno agita la mano al despedirse.")
    put("favourite", "C",
        fondo_mesa() + fl("Fork and knife with plate", 30, 26, 46) + nino_abrazando(104, 34) + fl("Star", 112, 12, 24),
        "Plato favorito elegido con sonrisa y abrazo alegre.")
    put("feathered", "C",
        fondo_sala() + fl("Feather", 34, 22, 48) + [L("M88 30 Q98 46 88 64", AZUL_OSCURO, 2.2)],
        "Pluma suave acariciada ligeramente con los dedos.")
    put("feathers", "C",
        fondo_sala() + fl("Feather", 24, 20, 36) + fl("Feather", 102, 20, 36) + nino_abrazando(80, 34),
        "Plumas ligeras y niño acariciando suavemente sus propios brazos.")
    put("fleecy", "C",
        fondo_sala() + fl("Coat", 34, 20, 50) + nino((106, 34), (106, 46), (106, 66), [[(90, 48)], [(118, 56)]], [[(100, 88)], [(112, 88)]]),
        "Chaqueta afelpada suave acariciada con la mano.")
    put("fluffy", "C",
        fondo_sala() + fl("Rabbit", 30, 24, 48) + [L("M82 26 Q94 34 86 48", ROSA_OSCURO, 2.2)],
        "Conejito esponjoso y suave acariciado con ternura.")
    put("fluffy chick", "C",
        fondo_prado() + fl("Baby chick", 34, 24, 48) + [L("M86 30 Q98 42 90 54", NARANJA_OSCURO, 2.2)],
        "Pollito amarillo muy esponjoso y suave.")
    put("furry", "C",
        fondo_sala() + fl("Cat", 32, 26, 48) + [L("M82 32 Q94 42 86 56", BARRO, 2.2)],
        "Pelaje muy suave de animal peludo acariciado despacio.")
    put("furry coat", "C",
        fondo_sala() + fl("Bear", 32, 22, 50) + nino_abrazando(104, 34),
        "Abrigo peludo y esponjoso abrazado con cariño.")
    put("fuzzy", "C",
        fondo_sala() + manta_prop(26, 36, 54, col="#fed7aa", h=36) + [L("M34 50 Q38 44 42 50", NARANJA_OSCURO, 1.8), L("M52 54 Q56 48 60 54", NARANJA_OSCURO, 1.8), L("M64 48 Q68 42 72 48", NARANJA_OSCURO, 1.8)] + nino((106, 34), (106, 46), (106, 66), [[(82, 50)], [(118, 56)]], [[(100, 88)], [(112, 88)]]),
        "Manta peludita muy suave acariciada con la mano.")
    put("gentle hands", "C",
        fondo_sala() + fl("Open hands", 46, 24, 56) + [L("M36 46 Q26 56 36 66", AZUL_OSCURO, 2.0), L("M116 46 Q126 56 116 66", AZUL_OSCURO, 2.0)],
        "Manos abiertas moviéndose despacio con máxima suavidad.")
    put("group hug", "D",
        fondo_sala() + abrazo_dos(66, 34) + nino((100, 34), (100, 46), (100, 66), [[(84, 50)], [(110, 56)]], [[(94, 88)], [(106, 88)]], camisa=(VERDE, VERDE_OSCURO)),
        "Tres amigos abrazándose juntos formando un gran abrazo de grupo.")
    put("happy new year", "C",
        fondo_noite() + fl("Confetti ball", 22, 16, 40) + abrazo_dos(86, 34) + fl("Star", 122, 16, 26),
        "Confeti festivo de Año Nuevo con amigos abrazándose sonrientes.")
    put("hatchling", "C",
        fondo_prado() + fl("Hatching chick", 28, 24, 48) + nino((104, 56), (96, 62), (86, 74), [[(108, 72)], [(90, 74)]], [[(84, 84)], [(96, 84)]]),
        "Polluelo saliendo del cascarón y niño acurrucado pequeñito.")
    put("heart shape", "D",
        fondo_sala() + [E(70, 38, 12, 12, ROJO), E(90, 38, 12, 12, ROJO), P([(59, 43), (101, 43), (80, 68)], ROJO)] + [L("M44 48 Q46 72 80 76", PELB, 4.0), L("M44 48 Q46 72 80 76", PEL, 2.2), L("M116 48 Q114 72 80 76", PELB, 4.0), L("M116 48 Q114 72 80 76", PEL, 2.2)],
        "Manos dibujando con cuidado la forma de un corazón rojo.")
    put("hello, little chick", "C",
        fondo_prado() + fl("Baby chick", 30, 26, 46) + nino((104, 34), (104, 46), (104, 66), [[(84, 52)], [(120, 42)]], [[(98, 88)], [(110, 88)]]),
        "Pollito pequeño acariciado mientras se le saluda con ternura.")
    put("huddle", "C",
        fondo_sala() + manta_prop(38, 38, 84, col="#bae6fd", h=38) + nino_busto(64, 24) + nino_busto(96, 24, camisa=(AZUL, AZUL_OSCURO)),
        "Dos niños muy juntitos acurrucados bajo la misma manta cálida.")
    put("hug", "D",
        fondo_sala() + nino_abrazando(80, 32),
        "Niño rodeándose el torso con sus propios brazos en un abrazo.")
    put("hug a fish", "C",
        fondo_mar() + fl("Tropical fish", 34, 26, 46) + nino_abrazando(104, 34, camisa=(AZUL, AZUL_OSCURO)),
        "Pez de peluche abrazado con ternura.")
    put("hug a tree", "C",
        fondo_prado() + fl("Deciduous tree", 36, 14, 62) + nino((96, 36), (90, 48), (88, 66), [[(74, 52)], [(76, 58)]], [[(82, 86)], [(94, 86)]]),
        "Niño abrazando con los brazos el tronco de un árbol grande.")
    put("hug buddy", "C",
        fondo_sala() + fl("Teddy bear", 36, 26, 46) + abrazo_dos(104, 34),
        "Osito compañero de abrazos y niños abrazándose contentos.")
    put("hug goodbye", "C",
        fondo_sala() + abrazo_dos(60, 34) + fl("Door", 104, 18, 54),
        "Niños dándose un abrazo junto a la puerta antes de marcharse.")
    put("hug lúa goodbye", "C",
        fondo_sala() + fl("Wolf", 30, 24, 48) + nino_abrazando(104, 34),
        "Despedida cariñosa abrazando a Lúa el lobito de peluche.")
    put("i feel better after a hug", "C",
        fondo_sala() + nino_abrazando(80, 32) + fl("Sun", 112, 16, 32),
        "Niño sonriendo aliviado y feliz después de darse un abrazo.")
    put("i like apples", "C",
        fondo_mesa() + fl("Red apple", 32, 24, 44) + nino_abrazando(102, 32),
        "Manzana roja brillante y niño abrazándola contento con sonrisa.")
    put("i love you", "C",
        fondo_sala() + fl("Heart hands", 28, 22, 48) + fl("Beating heart", 86, 24, 44),
        "Gesto de corazón con las manos y corazón rojo latiendo de cariño.")
    put("inside is warm", "C",
        fondo_sala() + fl("House", 22, 18, 52) + nino_abrazando(104, 34),
        "Casita protegida por dentro donde hace calorcito al abrazarse.")
    put("let's get cosy", "C",
        fondo_sala() + manta_prop(32, 34, 96, col="#fde68a", h=42) + nino_abrazando(80, 22),
        "Niño abrazándose calentito arropado bajo una manta amarilla.")
    put("newborn", "C",
        fondo_sala() + bebe(54, 48) + nino_busto(106, 38),
        "Bebé recién nacido muy pequeñito envuelto con suavidad.")
    put("nice kitty", "C",
        fondo_sala() + fl("Cat", 28, 26, 48) + nino((104, 36), (104, 48), (104, 66), [[(82, 46)], [(116, 56)]], [[(98, 86)], [(110, 86)]]),
        "Gatito tranquilo recibiendo una caricia suave en el lomo.")
    put("nuzzle", "D",
        fondo_sala() + nino((60, 40), (60, 52), (60, 70), [[(74, 56)], [(48, 58)]], [[(54, 88)], [(66, 88)]], mira=1) + nino((84, 41), (84, 53), (84, 71), [[(70, 56)], [(96, 58)]], [[(78, 88)], [(90, 88)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        "Dos niños acercando suavemente nariz con nariz con ternura.")
    put("safe and sound", "C",
        fondo_sala() + fl("House", 20, 18, 52) + abrazo_dos(104, 34),
        "Dentro de casa sano y salvo dándose un abrazo tranquilo.")
    put("skin", "D",
        fondo_sala() + [R(36, 52, 80, 16, 7, PEL, PELB, 2.0), E(78, 46, 9, 5, PEL, PELB, 1.8), L("M46 32 Q66 36 74 44", ROSA_OSCURO, 2.0), P([(70, 44), (77, 46), (75, 40)], ROSA_OSCURO)],
        "Mano acariciando suavemente la piel lisa del antebrazo.")
    put("sleep tight", "C",
        fondo_noite() + manta_prop(36, 44, 88, col="#bae6fd", h=36) + nino_busto(80, 32, ojos="cerrados"),
        "Noche tranquila arropado fuerte y con los ojos cerrados para dormir bien.")
    put("smooth pebble", "C",
        fondo_prado() + fl("Rock", 34, 26, 48) + [L("M88 34 Q96 48 88 60", AZUL_OSCURO, 2.0)],
        "Piedra lisa redondeada acariciada suavemente con los dedos.")
    put("smooth skin", "D",
        fondo_sala() + nino((72, 34), (72, 46), (72, 66), [[(66, 38)], [(88, 56)]], [[(66, 88)], [(78, 88)]]) + [L("M52 34 Q58 42 64 38", ROSA_OSCURO, 2.0)],
        "Niño acariciándose suavemente la mejilla con el dorso de la mano.")
    return m


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = _escenas()

# ── Piezas auditadas SIN base visual clara (se dejan SIN lámina para Frank) ─
SIN_BASE: dict[str, str] = {
    # clap_tap
    "clap after me": "Consigna verbal de turno («Da palmas después de mí»); indistinguible de aplaudir sin secuencia ni texto.",
    "congratulations, class": "Exclamación colectiva de aula («¡Enhorabuena, clase!»); aplauso indiferenciable de «applause» o «celebrate» sin texto.",
    "echo game": "Dinámica auditiva de repetición («Juego del eco»); exige comparar dos secuencias de sonido en el tiempo.",
    "encourage": "Verbo social genérico («Animar»); gesto idéntico a aplaudir sin marca visual propia.",
    "faint": "Adjetivo de intensidad muy baja («Suave»); indiferenciable en un dibujo estático sin texto de «loud and soft» o «quiet».",
    "find a rhyme": "Tarea lingüística («Rimar»); depende del sonido igual entre palabras habladas.",
    "have fun": "Exclamación genérica («¡Pásalo bien!»); sin referente visual único.",
    "merry and bright": "Par de adjetivos poéticos abstractos («Alegre y brillante»).",
    "regular": "Adjetivo abstracto de cadencia («Regular»); no distinguible sin texto de otros pulsos.",
    "rhyme": "Concepto lingüístico («Rimar»); depende del sonido igual de dos palabras habladas.",
    "solved": "Estado cognitivo abstracto («Resuelto»); aplauso genérico ambiguo sin texto.",
    "verse": "Concepto textual/poético («Verso»); ya señalado en P2.81 sin base visual propia.",
    "we found it": "Exclamación genérica («¡Lo encontramos!»); aplauso ambiguo sin objeto encontrado.",
    # walk
    "if you are the king, walk slowly": "Oración condicional («Si eres el rey...»); redundante con «king» y «go slow».",
    "leave only footprints": "Lema o proverbio ecológico («Deja solo huellas»); no distinguible sin texto de «footsteps».",
    "number line": "Recta numérica con cifras («1, 2, 3...»); prohibido meter texto o dígitos en la lámina.",
    "visit": "Verbo social genérico («Visitar»); sin acción u objeto único distinguible sin texto.",
    # hug_heart
    "apologise": "Acto de habla social («Pedir perdón»); indistinguible sin texto de sentirse mal o tímido.",
    "bittersweet": "Adjetivo emocional complejo («Agridulce»); imposible de expresar sin texto.",
    "compassionate": "Adjetivo moral abstracto («Compasivo»).",
    "emotion": "Sustantivo psicológico abstracto («Emoción»).",
    "emotional": "Adjetivo abstracto («Emocionado»).",
    "feeling": "Sustantivo psicológico abstracto («Sentimiento»).",
    "feelings words": "Concepto metalingüístico («Palabras de los sentimientos»).",
    "gentle-hearted": "Adjetivo moral abstracto («De corazón dulce»).",
    "grateful heart": "Expresión emocional abstracta («Corazón agradecido»).",
    "happy ending": "Concepto narrativo abstracto («Final feliz»).",
    "honest": "Virtud moral abstracta («Sincero»).",
    "i'm sorry": "Expresión conversacional de disculpa («Lo siento»).",
    "keep a promise": "Concepto ético abstracto («Cumplir una promesa»).",
    "kind-hearted": "Adjetivo moral abstracto («De buen corazón»).",
    "kindness": "Virtud abstracta («Bondad»).",
    "lovely": "Adjetivo valorativo genérico («Precioso, preciosa»).",
    "make a resolution": "Propósito mental abstracto («Hacer un propósito»).",
    "miss": "Sentimiento interior abstracto («Echar de menos»).",
    "name": "Concepto lingüístico («Nombre»); ya rechazado en P2.81.",
    "nature reserve": "Categoría administrativa abstracta («Espacio protegido»).",
    "opinion": "Concepto cognitivo/verbal abstracto («Opinión»).",
    "polite": "Cualidad social/verbal («Educado»); depende de decir «gracias».",
    "precious": "Adjetivo valorativo abstracto («Precioso»).",
    "precious sea": "Valoración abstracta («Mar valioso»).",
    "proud of myself": "Sentimiento autoevaluativo abstracto («Orgulloso de mí»).",
    "recite": "Acción verbal («Recitar»); hablar un poema en voz alta.",
    "safe": "Estado abstracto («Seguro, segura»); ambiguo frente a abrazar.",
    "show you care": "Concepto relacional abstracto («Mostrar que te importa»).",
    "tender": "Adjetivo emocional abstracto («Tierno»).",
    "thank the teachers": "Acto de habla de agradecimiento («Agradecer a las maestras»).",
    "thankful": "Sentimiento abstracto («Agradecido»).",
    "they lived happily ever after": "Fórmula narrativa literaria («Vivieron felices para siempre»).",
    "together again": "Expresión relacional temporal («Juntos otra vez»).",
    "treasured": "Adjetivo afectivo abstracto («Querido»).",
    "unforgettable": "Adjetivo temporal/emocional abstracto («Inolvidable»).",
    "warm-hearted": "Adjetivo moral abstracto («De buen corazón»).",
    "what's your name": "Pregunta conversacional («¿Cómo te llamas?»).",
}
