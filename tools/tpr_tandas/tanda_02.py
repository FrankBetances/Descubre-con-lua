#!/usr/bin/env python3
"""Tanda 2 TPR (P2.83): Locomoción y movimiento corporal.

Incluye equilibrio/inclinarse (`balance_sway`), gatear (`crawl`), saltar (`jump`),
correr (`run`), girar/rodar (`spin`) y primer bloque de caminar/pasos (`walk`).
Cada pieza ha sido revisada individualmente contra `en`, `es` y `tprAction`.
Las abstractas o verbales sin base visual clara quedan fuera en `SIN_BASE`.
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
    arco_giro,
    bebe,
    cara_dormida,
    charco_prop,
    copos_nieve,
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
    nino_busto,
    nino_corriendo,
    nino_gateando,
    nino_inclinado,
    nino_saltando,
    notas,
    ondas_calor,
    ondas_sonido,
    pano,
    pelota_prop,
    pina_prop,
    pompas,
    sol,
    tubo,
)

# ── Directas Fluent Emoji Flat (MIT) ───────────────────────────────────────
DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "big wheel": ("Ferris wheel", "U", "Noria de feria con radios girando."),
    "merry-go-round": ("Carousel horse", "U", "Caballito giratorio de tiovivo."),
}

# ── Directas Iconify (MIT / Apache-2.0 / CC-BY-3.0) ────────────────────────
# k -> (set, name, U/R, color, autor, porque)
DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {
    "spinning top": ("game-icons", "spinning-top", "U", MORADO, "GameIcons contributors", "Peonza tradicional girando sobre su punta."),
    "washing machine": ("tabler", "wash-machine", "U", AZUL_OSCURO, "", "Lavadora con tambor redondo giratorio."),
    "watering can": ("mdi", "watering-can", "U", VERDE_OSCURO, "", "Regadera inclinada para regar."),
    "wind turbine": ("mdi", "wind-turbine", "U", AZUL_OSCURO, "", "Aerogenerador de aspas giratorias."),
    "windmill": ("tabler", "windmill", "U", NARANJA_OSCURO, "", "Molino de viento con aspas que giran."),
}


def _escenas() -> dict[str, tuple[str, list[dict], str, str | None]]:
    m: dict[str, tuple[str, list[dict], str, str | None]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, lic: str | None = None) -> None:
        m[k] = (cd, formas, porque, lic)

    # ── Equilibrio, inclinarse y balanceo (balance_sway) ───────────────────
    put("bend in the wind", "C",
        fondo_prado() + fl("Evergreen tree", 24, 22, 46) + lineas_viento(16, 22, 34, AZUL_OSCURO) + nino_inclinado(94, 34, 14) + [L("M110 22 Q122 26 126 38", AZUL_OSCURO, 2.2)],
        "Niño inclinándose de lado igual que los árboles doblados por el viento.")
    put("boat trip", "C",
        fondo_mar() + fl("Sailboat", 42, 16, 62) + [L("M24 72 Q52 64 80 72 Q108 80 136 72", AZUL_OSCURO, 2.2)],
        "Barco de vela balanceándose sobre las olas en viaje por el mar.")
    put("bow", "D",
        fondo_sala() + nino((74, 38), (64, 46), (56, 66), [[(80, 52)], [(50, 56)]], [[(52, 88)], [(64, 88)]]) + [L("M90 22 Q104 34 94 48", ROJO, 2.4), P([(90, 44), (96, 50), (98, 42)], ROJO)],
        "Niño inclinando el tronco hacia delante haciendo una reverencia.")
    put("bow to the audience", "D",
        fondo_sala() + [R(20, 68, 120, 14, 3, MADERA, MADERA_OSCURA, 2.0)] + nino((72, 34), (62, 42), (54, 58), [[(80, 48)], [(48, 52)]], [[(50, 72)], [(60, 72)]]) + [E(114, 72, 7, 7, AZUL, AZUL_OSCURO), E(130, 72, 7, 7, VERDE, VERDE_OSCURO)],
        "Actor inclinándose en el escenario saludando al público.")
    put("drowsy", "D",
        fondo_sala() + nino((78, 36), (76, 48), (76, 68), [[(64, 58)], [(88, 58)]], [[(70, 88)], [(82, 88)]], ollos="pechados") + [L("M94 26 Q104 34 98 46", MORADO, 2.2), P([(94, 42), (98, 48), (102, 42)], MORADO)],
        "Niño adormilado inclinando la cabeza hacia un lado con ojos pesados.")
    put("everyone, take a bow", "D",
        fondo_sala() + nino((52, 38), (44, 46), (38, 66), [[(56, 52)], [(32, 56)]], [[(34, 88)], [(44, 88)]]) + nino((112, 38), (104, 46), (98, 66), [[(116, 52)], [(92, 56)]], [[(94, 88)], [(104, 88)]], camisa=(AZUL, AZUL_OSCURO)),
        "Dos niños inclinándose a la vez haciendo reverencia juntos.")
    put("floating raft", "D",
        fondo_mar() + [R(34, 48, 92, 9, 4, MADERA, MADERA_OSCURA, 2.0), R(38, 56, 84, 8, 4, BARRO, MADERA_OSCURA, 2.0), L("M50 46 L50 64", ROJO, 2.4), L("M110 46 L110 64", ROJO, 2.4), L("M24 72 Q52 64 80 72 Q108 80 136 72", AZUL_OSCURO, 2.4), L("M32 34 Q46 28 60 34", AZUL_OSCURO, 2.0), L("M100 34 Q114 28 128 34", AZUL_OSCURO, 2.0)],
        "Balsa de troncos de madera atados balanceándose suavemente sobre el agua.")
    put("lean forward", "D",
        fondo_sala() + nino((78, 36), (66, 46), (54, 66), [[(98, 46)], [(92, 54)]], [[(48, 88)], [(62, 88)]]) + frecha((86, 22), (118, 28), ROJO, 2.8),
        "Niño inclinándose hacia delante con las manos estiradas.")
    put("lopsided", "D",
        fondo_mesa() + [R(66, 56, 32, 16, 3, AZUL, AZUL_OSCURO, 2.0), R(72, 40, 28, 16, 3, VERDE, VERDE_OSCURO, 2.0), P([(78, 40), (106, 40), (112, 24), (84, 24)], ROJO, ROJO_OSCURO, 2.0)] + [L("M116 20 L124 44", ROJO, 2.4)],
        "Torre de bloques claramente torcida e inclinada hacia un lado.")
    put("pour tea", "C",
        fondo_mesa() + fl("Teapot", 34, 18, 52) + gotas([(84, 52), (88, 62)]) + fl("Teacup without handle", 94, 42, 36),
        "Tetera inclinada sirviendo té caliente dentro de la taza.")
    put("rock", "D",
        fondo_sala() + nino_inclinado(80, 34, -10) + frecha((54, 22), (34, 22), AZUL_OSCURO, 2.4) + frecha((104, 22), (124, 22), AZUL_OSCURO, 2.4),
        "Niño meciéndose suavemente de un lado a otro con flechas laterales.")
    put("rock the boat", "C",
        fondo_mar() + fl("Canoe", 34, 34, 72) + nino_busto(70, 36) + [L("M24 58 Q18 68 26 78", ROJO, 2.2), L("M120 58 Q126 68 118 78", ROJO, 2.2)],
        "Barca balanceándose de lado a lado sobre las olas con niño sentado.")
    put("rock-a-bye, baby", "C",
        fondo_noite() + bebe(68, 52) + [L("M44 70 Q72 82 102 70", MADERA_OSCURA, 2.6)] + notas([(110, 36), (126, 26)]),
        "Bebé mecéndose tranquilo mientras suena la canción de cuna.")
    put("rocking chair", "C",
        fondo_sala() + ico("tabler", "armchair", 36, 26, 62, MADERA_OSCURA) + [L("M34 86 Q68 94 102 86", MADERA_OSCURA, 3.0)] + bebe(96, 46),
        "Mecedora curva con el bebé descansando en brazos.", "MIT")
    put("sailing along", "C",
        fondo_mar() + fl("Sailboat", 36, 18, 64) + lineas_viento(104, 32, 30, AZUL_OSCURO),
        "Velero navegando con el viento impulsando la vela.")
    put("sailing ship", "C",
        fondo_mar() + fl("Ship", 42, 16, 68) + [L("M24 72 Q52 66 80 72 Q108 78 136 72", AZUL_OSCURO, 2.2)],
        "Barco grande surcando el océano con balanceo suave.")
    put("side to side", "D",
        fondo_sala() + bebe(80, 50) + frecha((46, 26), (22, 26), MORADO, 2.8) + frecha((114, 26), (138, 26), MORADO, 2.8),
        "Movimiento de balanceo de un lado a otro indicado por flechas opuestas.")
    put("sink", "C",
        fondo_sala() + [R(82, 48, 48, 18, 4, BLANCO, GRIS_OSCURO, 2.2), R(98, 66, 16, 22, 2, "#e2e8f0", GRIS_OSCURO, 2.0), L("M106 32 L106 46", GRIS_OSCURO, 3.5)] + gotas([(106, 48)]) + nino_inclinado(44, 34, 10),
        "Lavabo con grifo y niño inclinándose hacia él para lavarse.")
    put("slope", "D",
        fondo_prado() + [P([(20, 80), (140, 80), (140, 24)], TIERRA_CLARA, BARRO, 2.4)] + pelota_prop(92, 42, 10, ROJO, ROJO_OSCURO) + frecha((86, 26), (48, 52), AZUL_OSCURO, 2.8),
        "Cuesta inclinada con pendiente descendente señalada con flecha.")
    put("surf", "C",
        fondo_mar() + fl("Water wave", 22, 34, 48) + [R(66, 64, 58, 9, 4, AMARILLO, NARANJA_OSCURO, 2.0)] + nino((94, 22), (94, 34), (94, 50), [[(74, 32)], [(114, 32)]], [[(86, 64)], [(104, 64)]]),
        "Niño haciendo equilibrio con los brazos en cruz sobre la tabla encima de la ola.")
    put("sway", "D",
        fondo_sala() + nino_inclinado(52, 34, 8) + bebe(88, 50) + notas([(116, 30), (130, 22)]),
        "Balancearse suavemente meciendo al bebé al son de la música.")
    put("sway like an oak", "C",
        fondo_prado() + fl("Deciduous tree", 24, 14, 64) + nino_inclinado(104, 34, 10) + [L("M90 18 Q106 10 122 18", VERDE_OSCURO, 2.4)],
        "Roble frondoso y niño meciendo los brazos despacio como sus ramas.")
    put("sway with the current", "C",
        fondo_mar() + [F("M34 86 Q44 56 32 32", VERDE_OSCURO, VERDE_OSCURO, 4.5), F("M58 86 Q72 54 56 26", VERDE, VERDE, 4.5), L("M82 40 Q102 34 122 40", AZUL_OSCURO, 2.4), P([(118, 36), (126, 40), (118, 44)], AZUL_OSCURO)],
        "Algas marinas balanceándose al ritmo de la corriente del mar.")
    put("swing", "D",
        fondo_prado() + [L("M48 14 L112 14", MADERA_OSCURA, 4.0), L("M64 14 L56 62", GRIS_OSCURO, 2.0), L("M96 14 L88 62", GRIS_OSCURO, 2.0), R(50, 62, 44, 7, 3, ROJO, ROJO_OSCURO, 1.8)] + nino_busto(72, 40) + frecha((98, 56), (126, 42), VERDE_OSCURO, 2.6),
        "Columpio balanceándose hacia delante y arriba.")
    put("swing from a vine", "C",
        fondo_prado() + [L("M72 6 Q82 34 78 58", VERDE_OSCURO, 3.8)] + nino((78, 32), (78, 44), (78, 60), [[(78, 22)], [(94, 48)]], [[(72, 74)], [(86, 74)]]) + fl("Palm tree", 16, 12, 54) + frecha((94, 28), (122, 22), ROJO, 2.6),
        "Niño agarrado de una liana balanceándose como un mono.")
    put("take a bow", "D",
        fondo_sala() + [R(24, 14, 18, 66, 3, ROJO, ROJO_OSCURO, 2.0), R(118, 14, 18, 66, 3, ROJO, ROJO_OSCURO, 2.0)] + nino((86, 36), (76, 44), (68, 64), [[(92, 50)], [(62, 54)]], [[(64, 86)], [(74, 86)]]),
        "Niño inclinando el cuerpo entre cortinas rojas al terminar la función.")
    put("travel by boat", "C",
        fondo_mar() + fl("Ferry", 34, 20, 68) + frecha((104, 46), (134, 46), AZUL_OSCURO, 2.8),
        "Barco de pasajeros viajando sobre el mar.")
    put("up and down the city", "C",
        fondo_cielo() + [R(0, 68, 160, 32, 0, GRIS, GRIS_OSCURO, 1.5)] + fl("Bus", 26, 30, 56) + ico("tabler", "steering-wheel", 96, 26, 44, NEGRO),
        "Autobús recorriendo la ciudad y volante moviéndose arriba y abajo.", "MIT")
    put("wobble board", "D",
        fondo_sala() + [L("M40 72 Q80 88 120 72", MADERA_OSCURA, 4.5), R(42, 66, 76, 7, 3, MADERA, MADERA_OSCURA, 2.0)] + nino((80, 22), (80, 34), (80, 52), [[(58, 34)], [(102, 34)]], [[(70, 66)], [(90, 66)]]),
        "Tabla curva de equilibrio con niño encima abriendo los brazos.")

    # ── Gatear / arrastrarse (crawl) ───────────────────────────────────────
    put("crawl through", "D",
        fondo_sala() + [E(104, 58, 22, 22, ROJO, ROJO_OSCURO, 2.2), R(64, 36, 40, 44, 0, AZUL, AZUL_OSCURO, 2.0), E(64, 58, 14, 22, "#1e293b", AZUL_OSCURO, 2.0)] + nino_gateando(18, 52, mira=1) + frecha((46, 26), (92, 26), VERDE_OSCURO, 2.8),
        "Niño gateando para atravesar el túnel de juego infantil.")
    put("crawl under", "D",
        fondo_sala() + mesa_prop(46, 30, 74, 52) + nino_gateando(52, 52, mira=1) + frecha((26, 36), (26, 68), ROJO, 2.8),
        "Niño gateando agachado por debajo de una mesa.")
    put("crawl under the table", "D",
        fondo_sala() + mesa_prop(40, 32, 84, 50) + nino_gateando(50, 52, mira=1, col=(AZUL, AZUL_OSCURO)),
        "Niño gateando directamente debajo de la mesa.")
    put("explore the seabed", "C",
        fondo_mar() + [R(0, 66, 160, 34, 0, "#fde68a", BARRO, 1.5)] + fl("Spiral shell", 104, 58, 26) + fl("Coral", 124, 50, 28) + nino_gateando(28, 48, mira=1),
        "Niño gateando mirando de cerca conchas y corales en el suelo.")
    put("sea slug", "D",
        fondo_mar() + [E(76, 66, 26, 11, MORADO, "#5b21b6", 2.2), E(96, 62, 9, 8, ROSA, ROSA_OSCURO, 1.8), L("M100 54 L106 46", ROSA_OSCURO, 2.0), L("M94 54 L96 46", ROSA_OSCURO, 2.0), E(64, 66, 4, 4, AMARILLO), E(78, 65, 4, 4, AMARILLO)] + frecha((44, 44), (112, 44), AZUL_OSCURO, 2.4),
        "Babosa de mar colorida avanzando despacio por el fondo marino.")

    # ── Saltar / brincar (jump) ────────────────────────────────────────────
    put("blast off", "C",
        fondo_noite() + fl("Rocket", 28, 16, 56) + nino_saltando(108, 30, True) + frecha((132, 74), (132, 24), "#fde047", 3.0),
        "Cohete despegando hacia el espacio y niño saltando con los brazos arriba.")
    put("cushion jump", "C",
        fondo_sala() + ico("tabler", "pillow", 54, 58, 52, MORADO) + nino_saltando(80, 18, True) + frecha((36, 54), (36, 26), VERDE_OSCURO, 2.8),
        "Niño saltando alegre encima de un cojín blando.", "MIT")
    put("grasshopper", "C",
        fondo_prado() + fl("Cricket", 34, 42, 44) + [L("M72 48 Q98 16 124 54", VERDE_OSCURO, 2.6), P([(120, 52), (126, 56), (126, 48)], VERDE_OSCURO)],
        "Saltamontes dando un gran salto en arco sobre la hierba.")
    put("hare", "C",
        fondo_prado() + fl("Rabbit", 32, 34, 48) + [L("M74 42 Q102 12 128 48", NARANJA_OSCURO, 2.6), P([(124, 46), (130, 50), (130, 42)], NARANJA_OSCURO)],
        "Liebre saltando largo sobre el prado.")
    put("hop around", "D",
        fondo_prado() + nino_saltando(80, 26, False, pata_coja=True) + arco_giro(80, 56, 30, VERDE_OSCURO),
        "Niño saltando a la pata coja mientras gira alrededor.")
    put("hop like a kangaroo", "C",
        fondo_prado() + fl("Kangaroo", 24, 24, 54) + nino_saltando(106, 26, False) + [L("M96 74 Q106 60 116 74", ROJO, 2.4)],
        "Canguro y niño saltando juntos con los pies juntos.")
    put("hop on one foot", "D",
        fondo_prado() + [E(80, 78, 16, 4, HERBAB)] + nino_saltando(80, 26, False, pata_coja=True) + frecha((50, 62), (50, 32), AZUL_OSCURO, 2.8),
        "Niño saltando en equilibrio sobre un solo pie.")
    put("hop to number three, then turn around", "D",
        fondo_prado() + [R(22, 66, 20, 14, 3, AMARILLO, NARANJA_OSCURO, 1.8), E(32, 73, 2, 2, TINTA), R(52, 66, 20, 14, 3, VERDE, VERDE_OSCURO, 1.8), E(58, 73, 2, 2, TINTA), E(66, 73, 2, 2, TINTA), R(82, 66, 20, 14, 3, AZUL, AZUL_OSCURO, 1.8), E(87, 73, 2, 2, TINTA), E(92, 73, 2, 2, TINTA), E(97, 73, 2, 2, TINTA)] + nino_saltando(92, 22, False, pata_coja=True) + arco_giro(126, 56, 14, ROJO),
        "Tres casillas de salto (1, 2, 3 puntos), salto encima y flecha de dar la vuelta.")
    put("hopping", "D",
        fondo_prado() + nino_saltando(52, 26, False, pata_coja=True) + [L("M52 76 Q72 52 92 76 Q110 52 128 76", VERDE_OSCURO, 2.4)],
        "Niño dando saltos sucesivos con arcos de bote en el prado.")
    put("hopscotch", "D",
        fondo_prado() + [R(38, 72, 16, 12, 2, ROJO, TINTA, 1.5), R(56, 66, 16, 12, 2, AMARILLO, TINTA, 1.5), R(56, 80, 16, 12, 2, AZUL, TINTA, 1.5), R(74, 72, 16, 12, 2, VERDE, TINTA, 1.5), R(92, 66, 16, 12, 2, MORADO, TINTA, 1.5), R(92, 80, 16, 12, 2, NARANJA, TINTA, 1.5)] + nino_saltando(80, 20, False, pata_coja=True),
        "Cuadros de rayuela en el suelo con niño saltando encima a la pata coja.")
    put("in the puddle", "D",
        fondo_prado() + charco_prop(80, 78, 34, 9) + nino_saltando(80, 26, False) + gotas([(46, 62), (114, 62)]),
        "Niño con las botas justo dentro de un charco azul salpicando agua.")
    put("jump and land", "D",
        fondo_prado() + nino_saltando(48, 22, True) + [L("M56 36 Q84 12 108 56", ROJO, 2.4)] + nino((110, 42), (110, 54), (110, 68), [[(98, 62)], [(122, 62)]], [[(102, 78), (104, 86)], [(118, 78), (116, 86)]]),
        "Trayectoria de salto alto seguido de aterrizaje suave flexionando rodillas.")
    put("jump for joy", "C",
        fondo_cielo() + nino_saltando(80, 26, True) + fl("Sparkler", 26, 22, 34) + fl("Star", 108, 20, 28),
        "Niño saltando muy alto con los brazos abiertos de pura alegría.")
    put("jump in the puddle", "D",
        fondo_prado() + charco_prop(92, 78, 32, 9) + [L("M44 50 Q68 20 92 64", AZUL_OSCURO, 2.6), P([(88, 62), (94, 66), (96, 58)], AZUL_OSCURO)] + nino_saltando(46, 24, True),
        "Niño saltando en arco directo hacia dentro del charco.")
    put("jump like a frog", "C",
        fondo_prado() + fl("Frog", 28, 34, 46) + nino_saltando(104, 28, False) + [L("M76 58 Q90 22 104 42", VERDE_OSCURO, 2.4)],
        "Rana verde y niño saltando en arco desde posición agachada.")
    put("jump out", "D",
        fondo_prado() + charco_prop(54, 78, 28, 8) + [L("M54 64 Q82 20 112 66", VERDE_OSCURO, 2.6), P([(108, 64), (114, 68), (116, 60)], VERDE_OSCURO)] + nino_saltando(112, 26, True),
        "Niño saltando hacia fuera para salir del charco.")
    put("jump up high", "D",
        fondo_cielo() + [R(0, 78, 160, 22, 0, HERBA)] + nino_saltando(76, 18, True) + frecha((116, 74), (116, 16), ROJO, 3.2),
        "Niño saltando muy arriba con flecha vertical alta.")
    put("leap out of the water", "C",
        fondo_mar() + fl("Dolphin", 52, 18, 54) + gotas([(46, 52), (110, 52)]) + [L("M42 62 Q80 14 118 62", AZUL_OSCURO, 2.2)],
        "Delfín dando un gran salto fuera del mar entre gotas de agua.")
    put("new year", "C",
        fondo_noite() + fl("Twelve oclock", 22, 14, 38) + fl("Confetti ball", 104, 14, 38) + nino_saltando(78, 28, True),
        "Reloj en medianoche, confeti de celebración y niño saltando de alegría.")
    put("out of the puddle", "D",
        fondo_prado() + charco_prop(52, 78, 26, 8) + frecha((66, 66), (112, 58), ROJO, 2.8) + nino_saltando(114, 28, False),
        "Niño saltando desde el charco hasta quedar seco fuera.")
    put("pile of leaves", "C",
        fondo_prado() + [E(80, 74, 38, 12, NARANJA, NARANJA_OSCURO, 2.0)] + fl("Fallen leaf", 48, 54, 24) + fl("Maple leaf", 84, 52, 26) + nino_saltando(80, 18, True),
        "Montón de hojas secas de otoño con niño saltando encima.")
    put("pounce", "C",
        fondo_prado() + fl("Cat", 32, 34, 46) + [L("M74 44 Q98 20 120 56", NARANJA_OSCURO, 2.6), P([(116, 54), (122, 58), (124, 50)], NARANJA_OSCURO)],
        "Gato agazapado abalanzándose hacia delante con las patas.")
    put("puddle jump", "D",
        fondo_prado() + charco_prop(80, 78, 34, 8) + nino_saltando(80, 22, True) + frecha((80, 66), (80, 52), AZUL_OSCURO, 2.4) + gotas([(46, 66), (114, 66)]),
        "Salto vertical justo sobre un charco de agua salpicando gotas.")
    put("skip", "C",
        fondo_prado() + ico("game-icons", "jumping-rope", 48, 16, 64, ROJO_OSCURO),
        "Figura saltando a la comba con cuerda por encima de la cabeza.", "CC-BY-3.0")
    put("skipping rope", "C",
        fondo_prado() + [L("M24 72 Q80 94 136 72", ROJO, 3.2)] + nino_saltando(60, 26, False) + nino_saltando(100, 26, False, camisa=(AZUL, AZUL_OSCURO)),
        "Cuerda larga de comba y dos niños saltando a la vez con pies juntos.")
    put("sparrow", "C",
        fondo_prado() + fl("Bird", 32, 38, 44) + [L("M74 62 Q88 46 102 62 Q116 46 130 62", BARRO, 2.2)],
        "Pajarito pequeño dando saltitos cortos por el suelo.")
    put("speed bump", "D",
        fondo_prado() + [R(0, 74, 160, 26, 0, GRIS, GRIS_OSCURO, 1.5), F("M58 74 Q80 54 102 74 Z", AMARILLO, NARANJA_OSCURO, 2.2)] + nino_saltando(80, 20, False),
        "Resalto amarillo en la calzada con niño dando un botecito encima.")
    put("splash, splash", "D",
        fondo_prado() + charco_prop(80, 78, 38, 9) + gotas([(44, 52), (56, 44), (104, 44), (116, 52)]) + nino_saltando(80, 24, False),
        "Salpicaduras de gotas por los aires al saltar dos veces en el charco.")
    put("stepping stones", "D",
        fondo_mar() + [E(34, 78, 14, 7, GRIS, GRIS_OSCURO, 2.0), E(78, 76, 15, 7, GRIS, GRIS_OSCURO, 2.0), E(124, 78, 14, 7, GRIS, GRIS_OSCURO, 2.0)] + [L("M36 66 Q56 44 76 64", ROJO, 2.2), L("M82 64 Q102 44 122 66", ROJO, 2.2)] + nino_saltando(78, 22, False),
        "Piedras de paso en el río con niño saltando de una piedra a otra.")
    put("stone to stone", "D",
        fondo_prado() + [E(44, 78, 18, 8, GRIS, GRIS_OSCURO, 2.0), E(116, 78, 18, 8, GRIS, GRIS_OSCURO, 2.0)] + [L("M48 64 Q80 28 112 64", AZUL_OSCURO, 2.8), P([(108, 62), (114, 66), (116, 58)], AZUL_OSCURO)] + nino_saltando(80, 22, False),
        "Salto claro de una piedra grande hasta la siguiente.")
    put("swim like a dolphin", "C",
        fondo_mar() + fl("Dolphin", 28, 26, 48) + nino_saltando(104, 28, True),
        "Delfín arqueado fuera del agua y niño imitando su salto.")
    put("trampoline", "D",
        fondo_prado() + [E(80, 74, 42, 10, NEGRO, GRIS_OSCURO, 2.4), L("M46 78 L42 88", GRIS_OSCURO, 3.0), L("M114 78 L118 88", GRIS_OSCURO, 3.0), L("M80 78 L80 88", GRIS_OSCURO, 3.0)] + nino_saltando(80, 18, True) + frecha((132, 66), (132, 24), ROJO, 2.6),
        "Cama elástica con patas y niño rebotando alto encima.")

    # ── Correr (run) ───────────────────────────────────────────────────────
    put("after running, the heart beats faster", "C",
        fondo_sala() + nino_corriendo(44, 34, 1) + frecha((68, 48), (88, 48), AZUL_OSCURO, 2.4) + fl("Beating heart", 96, 22, 46),
        "Niño corriendo y corazón latiendo rápido tras el ejercicio.")
    put("all hands on deck", "C",
        fondo_mar() + fl("Ship", 86, 20, 62) + nino_corriendo(40, 34, 1) + frecha((56, 22), (88, 22), ROJO, 2.6),
        "Niños corriendo hacia la cubierta del barco.")
    put("catch up", "D",
        fondo_prado() + nino_corriendo(42, 34, 1) + nino_corriendo(106, 34, 1, camisa=(AZUL, AZUL_OSCURO)) + frecha((58, 22), (96, 22), VERDE_OSCURO, 2.6),
        "Niño corriendo detrás para alcanzar a su compañero.")
    put("escape", "C",
        fondo_prado() + fl("Hut", 96, 24, 52) + nino_corriendo(44, 34, 1) + lineas_viento(16, 44, 22, ROJO),
        "Niño corriendo rápido hacia el refugio seguro.")
    put("fastest", "C",
        fondo_prado() + nino_corriendo(84, 34, 1) + lineas_viento(22, 38, 36, ROJO) + lineas_viento(20, 56, 38, AZUL_OSCURO) + fl("Chequered flag", 118, 16, 34),
        "Corredor velocísimo cruzando primero la bandera a cuadros.")
    put("fly off", "D",
        fondo_cielo() + [R(0, 76, 160, 24, 0, HERBA)] + nino((80, 34), (78, 46), (76, 64), [[(54, 42)], [(104, 42)]], [[(90, 76), (96, 86)], [(64, 74), (56, 82)]]) + frecha((104, 24), (136, 16), ROJO, 2.6),
        "Niño corriendo rápido con los brazos bien abiertos como alas.")
    put("fly to the rescue", "C",
        fondo_cielo() + ico("noto", "superhero", 30, 18, 56, NEGRO) + frecha((90, 44), (132, 32), ROJO, 3.0),
        "Superhéroe corriendo con brazos extendidos acudiendo al rescate.", "Apache-2.0")
    put("go fast", "D",
        fondo_prado() + nino_corriendo(86, 34, 1) + lineas_viento(22, 44, 42, ROJO) + frecha((114, 26), (142, 26), ROJO, 2.8),
        "Niño corriendo veloz hacia delante con ráfagas de velocidad.")
    put("green card", "D",
        fondo_prado() + [R(24, 22, 32, 46, 4, VERDE, VERDE_OSCURO, 2.4)] + nino_corriendo(96, 34, 1) + frecha((62, 44), (80, 44), VERDE_OSCURO, 2.6),
        "Tarjeta verde dando paso libre y niño echando a correr.")
    put("jog", "D",
        fondo_prado() + nino_corriendo(80, 34, 1, camisa=(VERDE, VERDE_OSCURO)) + [L("M48 84 L112 84", GRIS_OSCURO, 2.2)],
        "Niño trotando suavemente con zancada tranquila.")
    put("late", "C",
        fondo_sala() + fl("Alarm clock", 22, 24, 44) + nino_corriendo(96, 34, 1) + frecha((72, 24), (124, 24), ROJO, 2.6),
        "Reloj despertador y niño corriendo deprisa porque llega tarde.")
    put("nee-naw, nee-naw", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, GRIS)] + fl("Police car light", 28, 20, 44) + nino_corriendo(96, 34, 1),
        "Sirena luminosa de emergencia y niño corriendo haciendo de coche de bomberos.")
    put("out of breath", "D",
        fondo_prado() + nino((62, 42), (52, 50), (46, 68), [[(68, 66)], [(44, 68)]], [[(42, 88)], [(56, 88)]]) + lineas_viento(76, 42, 26, AZUL_OSCURO) + [E(74, 34, 2.5, 3.5, AGUA)],
        "Niño apoyado en las rodillas resoplando fuerte después de correr.")
    put("race track", "D",
        fondo_prado() + [E(80, 70, 56, 18, GRIS, GRIS_OSCURO, 6.0), E(80, 70, 38, 10, HERBA, HERBAB, 1.8)] + nino_corriendo(78, 22, 1),
        "Pista ovalada de carreras con niño corriendo por el circuito.")
    put("run home", "C",
        fondo_prado() + nino_corriendo(44, 34, 1) + frecha((66, 24), (94, 24), ROJO, 2.6) + fl("House", 96, 22, 52),
        "Niño corriendo directo hacia su casa.")
    put("run like a fox", "C",
        fondo_prado() + fl("Fox", 28, 30, 48) + nino_corriendo(98, 34, 1, camisa=(NARANJA, NARANJA_OSCURO)),
        "Zorro rápido y niño corriendo ligero.")
    put("run through the sprinkler", "C",
        fondo_prado() + ico("mdi", "sprinkler", 28, 44, 44, AZUL_OSCURO) + gotas([(32, 28), (48, 20), (66, 28)]) + nino_corriendo(104, 34, 1),
        "Aspersor soltando chorros de agua fresca y niño corriendo por debajo.", "Apache-2.0")
    put("run to the cone", "D",
        fondo_prado() + nino_corriendo(44, 34, 1) + frecha((66, 24), (96, 24), VERDE_OSCURO, 2.6) + [P([(104, 82), (128, 82), (118, 44), (114, 44)], NARANJA, NARANJA_OSCURO, 2.2), R(100, 82, 32, 5, 2, NARANJA_OSCURO)],
        "Niño corriendo en dirección al cono naranja de entrenamiento.")
    put("run to the den", "D",
        fondo_prado() + nino_corriendo(42, 34, 1) + frecha((64, 24), (92, 24), ROJO, 2.6) + [F("M88 78 Q116 32 144 78 Z", TIERRA, BARRO, 2.0), F("M104 78 Q116 48 128 78 Z", "#1e293b")],
        "Niño corriendo rápido hacia el refugio o madriguera.")
    put("run, run, run", "D",
        fondo_prado() + nino_corriendo(46, 34, 1) + nino_corriendo(104, 34, 1, camisa=(AZUL, AZUL_OSCURO)) + lineas_viento(16, 46, 20, ROJO),
        "Niños corriendo sin parar uno tras otro.")
    put("scuttle", "C",
        fondo_mar() + fl("Crab", 32, 28, 50) + nino_corriendo(104, 34, 1),
        "Cangrejo corriendo de lado y niño imitándolo.")
    put("sprint fast", "D",
        fondo_prado() + nino_corriendo(92, 34, 1) + lineas_viento(22, 36, 46, ROJO) + lineas_viento(18, 52, 50, NARANJA_OSCURO) + frecha((114, 22), (144, 22), ROJO, 3.0),
        "Niño esprintando a toda velocidad hacia la derecha.")
    put("traffic light game", "C",
        fondo_sala() + fl("Vertical traffic light", 28, 16, 56) + nino_corriendo(102, 34, 1) + frecha((78, 60), (96, 60), VERDE_OSCURO, 2.8),
        "Semáforo con luz verde y niño echando a correr.")
    put("trot", "C",
        fondo_prado() + fl("Horse", 26, 22, 54) + nino_corriendo(104, 34, 1),
        "Caballo trotando y niño imitando su trote.")
    put("whoosh around", "D",
        fondo_prado() + nino_corriendo(80, 34, 1) + arco_giro(80, 52, 34, AZUL_OSCURO) + lineas_viento(24, 30, 26, AZUL_OSCURO),
        "Niño corriendo rápido en círculo con líneas de viento.")
    put("wild and free", "C",
        fondo_prado() + nino((84, 34), (82, 46), (80, 64), [[(56, 40)], [(110, 40)]], [[(94, 76), (100, 86)], [(68, 74), (60, 82)]]) + fl("Bird", 26, 14, 30),
        "Niño corriendo libre con los brazos bien abiertos en el campo.")
    put("with the wind", "C",
        fondo_prado() + fl("Wind face", 22, 22, 46) + lineas_viento(64, 34, 26, AZUL_OSCURO) + nino((112, 34), (110, 46), (108, 64), [[(88, 42)], [(134, 42)]], [[(120, 76), (126, 86)], [(96, 74), (88, 82)]]),
        "Viento soplando fuerte empujando al niño que corre con brazos abiertos.")
    put("zoom through space", "C",
        fondo_noite() + fl("Rocket", 24, 18, 48) + fl("Star", 118, 16, 24) + nino((98, 34), (96, 46), (94, 64), [[(74, 42)], [(120, 42)]], [[(106, 76), (112, 86)], [(82, 74), (74, 82)]]),
        "Niño corriendo con los brazos extendidos volando entre estrellas y cohete.")

    # ── Girar / rodar / ruedas (spin) ──────────────────────────────────────
    put("acrobatic", "D",
        fondo_sala() + nino((80, 34), (80, 46), (80, 64), [[(58, 34)], [(102, 34)]], [[(74, 88)], [(86, 88)]]) + arco_giro(80, 48, 32, MORADO),
        "Niño haciendo acrobacias y girando sobre sí mismo.")
    put("ankle", "D",
        fondo_sala() + [R(66, 16, 16, 52, 6, PEL, PELB, 2.0), R(66, 62, 38, 16, 7, PEL, PELB, 2.0), E(74, 62, 11, 11, None, ROJO, 2.6)] + arco_giro(74, 62, 18, ROJO),
        "Pierna y pie descalzo con flechas circulares girando el tobillo.")
    put("ball to baby", "D",
        fondo_sala() + pelota_prop(38, 66, 13, ROJO, ROJO_OSCURO) + frecha((54, 64), (88, 64), AZUL_OSCURO, 2.8) + bebe(114, 54),
        "Pelota rodando suave por el suelo hacia el bebé.")
    put("bumpy walnut", "C",
        fondo_mesa() + fl("Chestnut", 48, 26, 48) + arco_giro(72, 50, 30, BARRO),
        "Nuez rugosa rodando entre flechas circulares.")
    put("cape", "C",
        fondo_sala() + ico("game-icons", "cape", 44, 18, 68, ROJO_OSCURO) + arco_giro(78, 54, 34, AZUL_OSCURO),
        "Capa ondeando al girar dando vueltas.", "CC-BY-3.0")
    put("colour wheel", "D",
        fondo_sala() + [E(80, 48, 30, 30, BLANCO, NEGRO, 2.4), P([(80, 48), (80, 18), (110, 48)], ROJO), P([(80, 48), (110, 48), (80, 78)], AMARILLO), P([(80, 48), (80, 78), (50, 48)], AZUL), P([(80, 48), (50, 48), (80, 18)], VERDE), E(80, 48, 5, 5, BLANCO, NEGRO, 1.8)] + arco_giro(80, 48, 36, NEGRO),
        "Rueda dividida en sectores rojo, amarillo, azul y verde girando.")
    put("cylinder", "D",
        fondo_mesa() + [R(44, 42, 66, 28, 6, AZUL, AZUL_OSCURO, 2.2), E(46, 56, 7, 14, "#93c5fd", AZUL_OSCURO, 2.0), E(110, 56, 7, 14, "#1d4ed8", AZUL_OSCURO, 2.0)] + arco_giro(110, 56, 18, ROJO),
        "Cilindro tumbado rodando por encima de la mesa.")
    put("dizzy", "D",
        fondo_sala() + nino((80, 38), (80, 50), (80, 70), [[(64, 56)], [(96, 56)]], [[(74, 88)], [(86, 88)]]) + [L("M58 14 C64 8 76 12 70 18 C64 22 60 16 68 12", MORADO, 2.0), L("M92 14 C98 8 110 12 104 18 C98 22 94 16 102 12", MORADO, 2.0)],
        "Niño sonriente un poco mareadito con espirales encima después de girar.")
    put("driver", "C",
        fondo_sala() + ico("tabler", "steering-wheel", 34, 24, 56, NEGRO) + nino_busto(110, 42) + arco_giro(62, 52, 32, ROJO),
        "Conductor sujetando y girando el volante.", "MIT")
    put("easy to roll", "D",
        fondo_mesa() + pelota_prop(78, 54, 18, VERDE, VERDE_OSCURO) + arco_giro(78, 54, 26, AZUL_OSCURO) + frecha((104, 62), (132, 62), AZUL_OSCURO, 2.4),
        "Esfera verde girando y rodando con facilidad sobre la mesa.")
    put("hands", "C",
        fondo_sala() + fl("Open hands", 46, 22, 68) + arco_giro(80, 56, 36, AZUL_OSCURO),
        "Dos manos abiertas girando suavemente.")
    put("mobile", "D",
        fondo_sala() + [L("M80 10 L80 26", MADERA_OSCURA, 2.6), L("M46 26 L114 26", MADERA_OSCURA, 3.0), L("M48 26 L48 44", GRIS_OSCURO, 1.5), L("M80 26 L80 48", GRIS_OSCURO, 1.5), L("M112 26 L112 44", GRIS_OSCURO, 1.5), E(48, 50, 7, 7, AMARILLO, NARANJA_OSCURO, 1.6), E(80, 54, 8, 8, ROJO, ROJO_OSCURO, 1.6), E(112, 50, 7, 7, AZUL, AZUL_OSCURO, 1.6)] + arco_giro(80, 38, 36, MORADO),
        "Móvil infantil de cuna con colgantes de colores girando arriba.")
    put("panorama", "C",
        fondo_prado() + fl("Mountain", 20, 26, 44) + fl("Sun", 66, 12, 26) + fl("Deciduous tree", 104, 26, 44) + arco_giro(80, 62, 28, AZUL_OSCURO),
        "Paisaje amplio todo alrededor girando la vista en panorámica.")
    put("pinecone", "D",
        fondo_prado() + pina_prop(80, 48, 16, 22) + arco_giro(80, 48, 30, VERDE_OSCURO),
        "Piña marrón de pino girando como al hacerla rodar entre las manos.")
    put("planet", "C",
        fondo_noite() + fl("Ringed planet", 46, 20, 68) + arco_giro(80, 54, 38, "#fde047"),
        "Planeta con anillos girando en su órbita.")
    put("rain stick", "D",
        fondo_sala() + [R(64, 16, 16, 68, 8, MADERA, MADERA_OSCURA, 2.2), L("M64 32 L80 32", NARANJA_OSCURO, 1.8), L("M64 48 L80 48", ROJO, 1.8), L("M64 64 L80 64", VERDE_OSCURO, 1.8)] + gotas([(98, 40), (112, 52), (104, 66)]) + arco_giro(72, 50, 24, AZUL_OSCURO),
        "Palo de lluvia decorado girando mientras suena como agua cayendo.")
    put("roll along", "D",
        fondo_mesa() + [R(36, 48, 48, 22, 8, VERDE, VERDE_OSCURO, 2.0), E(84, 59, 6, 11, HERBA, VERDE_OSCURO, 1.8)] + frecha((94, 58), (130, 58), ROJO, 2.8) + arco_giro(60, 59, 18, ROJO),
        "Cilindro verde rodando a lo largo de la mesa hacia delante.")
    put("roll back", "D",
        fondo_sala() + bebe(34, 52) + pelota_prop(86, 66, 12, ROJO, ROJO_OSCURO) + frecha((118, 50), (62, 50), AZUL_OSCURO, 2.8) + arco_giro(86, 66, 17, VERDE_OSCURO),
        "Pelota rodando de vuelta hacia el bebé.")
    put("roll down", "D",
        fondo_prado() + [P([(20, 32), (20, 84), (136, 84)], HERBA, HERBAB, 2.2)] + pelota_prop(74, 44, 12, AMARILLO, NARANJA_OSCURO) + frecha((44, 24), (108, 60), ROJO, 2.8),
        "Rodando cuesta abajo por la ladera verde.")
    put("roll on the floor", "D",
        fondo_sala() + [R(20, 68, 120, 12, 5, "#bae6fd", AZUL_OSCURO, 2.0)] + nino((52, 56), (70, 56), (92, 58), [[(66, 44)], [(78, 44)]], [[(108, 54)], [(108, 62)]]) + arco_giro(80, 56, 28, MORADO),
        "Niño tumbado de lado rodando sobre la alfombra.")
    put("roll over", "D",
        fondo_sala() + [R(22, 68, 116, 12, 5, "#fde68a", NARANJA_OSCURO, 1.8)] + bebe(76, 56) + [L("M56 36 Q80 18 104 36", ROJO, 2.6), P([(100, 32), (106, 38), (98, 40)], ROJO)],
        "Bebé girando de espaldas para darse la vuelta sobre la colchoneta.")
    put("roll the hoop", "D",
        fondo_prado() + [E(96, 54, 22, 22, None, ROJO, 4.5)] + nino_corriendo(44, 34, 1) + frecha((96, 24), (132, 24), AZUL_OSCURO, 2.6),
        "Niño haciendo rodar un aro rojo grande por el suelo.")
    put("rolling", "D",
        fondo_sala() + [R(46, 44, 18, 8, 4, PEL, PELB, 1.8), R(96, 44, 18, 8, 4, PEL, PELB, 1.8), E(64, 48, 9, 8, PEL, PELB, 2.0), E(96, 48, 9, 8, PEL, PELB, 2.0)] + arco_giro(80, 48, 28, ROJO),
        "Puños rodando uno alrededor del otro en movimiento circular.")
    put("rolling pin", "D",
        fondo_mesa() + [R(44, 38, 72, 18, 6, MADERA, MADERA_OSCURA, 2.2), R(26, 43, 18, 8, 3, BARRO, MADERA_OSCURA, 1.8), R(116, 43, 18, 8, 3, BARRO, MADERA_OSCURA, 1.8)] + arco_giro(80, 47, 26, ROJO),
        "Rodillo de cocina de madera rodando hacia delante y atrás.")
    put("rotate", "C",
        fondo_sala() + fl("Gear", 48, 18, 62) + arco_giro(79, 49, 36, AZUL_OSCURO),
        "Engranaje rotando suavemente sobre su eje.")
    put("rotate a piece", "C",
        fondo_sala() + fl("Puzzle piece", 48, 18, 62) + arco_giro(79, 49, 36, VERDE_OSCURO),
        "Pieza de puzle girándose hasta encajar en su orientación.")
    put("round and round", "D",
        fondo_sala() + arco_giro(80, 48, 30, ROJO) + arco_giro(80, 48, 16, AZUL_OSCURO),
        "Doble círculo concéntrico girando vueltas y más vueltas.")
    put("show off", "C",
        fondo_sala() + nino((78, 36), (78, 48), (78, 68), [[(60, 42)], [(96, 42)]], [[(72, 88)], [(84, 88)]]) + fl("Crown", 66, 6, 26) + arco_giro(78, 56, 34, MORADO),
        "Niño luciendo su corona de disfraz mientras da vueltas.")
    put("soar", "C",
        fondo_cielo() + fl("Bird", 26, 16, 46) + nino((100, 36), (100, 48), (100, 68), [[(74, 42)], [(126, 42)]], [[(94, 88)], [(106, 88)]]) + arco_giro(100, 56, 30, AZUL_OSCURO),
        "Pájaro planeando alto y niño girando despacio con brazos abiertos.")
    put("solar system", "C",
        fondo_noite() + fl("Sun", 58, 28, 44) + [E(80, 50, 48, 24, None, "#94a3b8", 1.8), E(36, 44, 6, 6, AZUL), E(122, 58, 7, 7, NARANJA)],
        "Sol en el centro con planetas orbitando alrededor en el sistema solar.")
    put("sparkling costume", "C",
        fondo_sala() + nino((78, 38), (78, 50), (78, 68), [[(60, 44)], [(96, 44)]], [[(72, 88)], [(84, 88)]], camisa=(MORADO, "#5b21b6")) + fl("Star", 34, 22, 24) + fl("Star", 104, 24, 24) + arco_giro(78, 56, 32, AMARILLO_OSCURO),
        "Niño con traje brillante girando entre destellos estrellados.")
    put("sphere", "D",
        fondo_mesa() + pelota_prop(80, 48, 26, AZUL, AZUL_OSCURO) + arco_giro(80, 48, 34, ROJO),
        "Esfera tridimensional azul girando sobre su centro.")
    put("spin", "D",
        fondo_sala() + nino((80, 34), (80, 46), (80, 66), [[(64, 52)], [(96, 52)]], [[(74, 88)], [(86, 88)]]) + [E(80, 58, 26, 7, None, ROJO, 3.0)] + arco_giro(80, 58, 34, AZUL_OSCURO),
        "Niño haciendo girar un hula-hoop alrededor de la cintura.")
    put("spin like a top", "C",
        fondo_sala() + ico("game-icons", "spinning-top", 24, 22, 46, MORADO) + nino((102, 34), (102, 46), (102, 66), [[(94, 58)], [(110, 58)]], [[(98, 88)], [(106, 88)]]) + arco_giro(102, 54, 26, ROJO),
        "Peonza girando y niño girando con los brazos pegados al cuerpo.", "CC-BY-3.0")
    put("spin like the earth", "C",
        fondo_noite() + fl("Globe showing americas", 30, 22, 46) + nino((106, 34), (106, 46), (106, 66), [[(94, 54)], [(118, 54)]], [[(100, 88)], [(112, 88)]]) + arco_giro(106, 54, 28, "#fde047"),
        "Planeta Tierra girando sobre su eje y niño imitando la rotación.")
    put("spinning", "D",
        fondo_sala() + pelota_prop(80, 48, 22, NARANJA, NARANJA_OSCURO) + [L("M62 40 Q80 48 98 40", BLANCO, 2.0), L("M62 56 Q80 48 98 56", BLANCO, 2.0)] + arco_giro(80, 48, 32, MORADO),
        "Pelota girando rápidamente sobre sí misma.")
    put("spinning earth", "C",
        fondo_noite() + fl("Globe showing americas", 46, 16, 66) + arco_giro(79, 49, 40, "#fde047"),
        "Globo terráqueo girando continuamente en el espacio.")
    put("spiralling", "D",
        fondo_cielo() + [L("M80 50 C88 50 90 38 80 36 C68 36 66 56 80 62 C98 66 108 40 94 24 C74 10 46 32 54 62 C62 84 106 86 122 52", MORADO, 3.0)] + frecha((116, 62), (126, 46), ROJO, 2.4),
        "Espiral continua girando hacia fuera.")
    put("sprinkler", "C",
        fondo_prado() + ico("mdi", "sprinkler", 58, 42, 44, VERDE_OSCURO) + gotas([(38, 22), (56, 14), (104, 14), (122, 22)]) + arco_giro(80, 26, 20, AZUL_OSCURO),
        "Aspersor girando mientras riega el césped con agua.", "Apache-2.0")
    put("steer", "C",
        fondo_sala() + ico("tabler", "steering-wheel", 46, 18, 64, NEGRO) + arco_giro(78, 50, 36, ROJO),
        "Volante de coche girando a izquierda y derecha.", "MIT")
    put("steer the boat", "D",
        fondo_mar() + [R(0, 74, 160, 26, 0, MADERA, MADERA_OSCURA, 1.8), R(76, 56, 8, 20, 2, BARRO, MADERA_OSCURA, 1.8), E(80, 44, 20, 20, None, MADERA_OSCURA, 4.2), L("M80 18 L80 70", MADERA_OSCURA, 2.8), L("M54 44 L106 44", MADERA_OSCURA, 2.8), L("M61 25 L99 63", MADERA_OSCURA, 2.6), L("M99 25 L61 63", MADERA_OSCURA, 2.6), E(80, 44, 5.5, 5.5, MADERA, MADERA_OSCURA, 2.0)] + arco_giro(80, 44, 30, ROJO),
        "Timón de barco de madera girando para dirigir la embarcación.")
    put("swivel chair", "C",
        fondo_sala() + ico("mdi", "chair-rolling", 48, 18, 62, AZUL_OSCURO) + arco_giro(79, 52, 34, ROJO),
        "Silla giratoria dando vueltas despacio sobre su base.", "Apache-2.0")
    put("the big wheel goes round and round", "C",
        fondo_cielo() + fl("Ferris wheel", 46, 12, 66) + arco_giro(79, 45, 38, ROJO),
        "Noria grande girando sin parar en redondo.")
    put("the wheels go round", "C",
        fondo_cielo() + [R(0, 76, 160, 24, 0, GRIS, GRIS_OSCURO, 1.5)] + fl("Bus", 44, 12, 72) + arco_giro(62, 72, 12, ROJO) + arco_giro(98, 72, 12, ROJO),
        "Autobús con sus dos ruedas girando en círculos.")
    put("toy car", "C",
        fondo_mesa() + fl("Automobile", 44, 22, 64) + frecha((26, 64), (134, 64), ROJO, 2.6),
        "Cochecito de juguete rodando sobre la mesa.")
    put("turn off the tap", "D",
        fondo_sala() + [L("M56 36 L86 36 Q96 36 96 52", GRIS_OSCURO, 7.0), R(62, 22, 24, 6, 2, ROJO, ROJO_OSCURO, 1.8), L("M88 54 L104 70", ROJO, 3.0), L("M104 54 L88 70", ROJO, 3.0)] + arco_giro(74, 24, 16, AZUL_OSCURO),
        "Grifo girado para cerrarlo cortando el chorro de agua.")
    put("turn right", "D",
        fondo_prado() + nino((58, 34), (58, 46), (58, 66), [[(46, 56)], [(70, 56)]], [[(52, 88)], [(64, 88)]]) + [L("M86 68 L86 36 L124 36", ROJO, 3.8), P([(118, 30), (130, 36), (118, 42)], ROJO)],
        "Niño y flecha grande girando hacia la derecha.")
    put("turn the tap", "D",
        fondo_sala() + [L("M56 36 L86 36 Q96 36 96 52", GRIS_OSCURO, 7.0), R(62, 22, 24, 6, 2, AZUL, AZUL_OSCURO, 1.8)] + gotas([(96, 58), (96, 72)]) + arco_giro(74, 24, 16, VERDE_OSCURO),
        "Grifo girando suavemente para dejar caer agua.")
    put("turn to the door", "C",
        fondo_sala() + nino((50, 34), (50, 46), (50, 66), [[(40, 56)], [(64, 52)]], [[(44, 88)], [(56, 88)]]) + arco_giro(50, 54, 24, AZUL_OSCURO) + fl("Door", 96, 20, 56),
        "Niño girando su cuerpo en dirección a la puerta cerrada.")
    put("twirl", "C",
        fondo_sala() + nino((62, 34), (62, 46), (62, 66), [[(78, 28)], [(48, 54)]], [[(56, 88)], [(68, 88)]]) + pano(82, 20, 32, 22, ROSA, ROSA_OSCURO) + arco_giro(98, 30, 20, MORADO),
        "Niño haciendo girar un pañuelo colorido en el aire.")
    put("weather vane", "D",
        fondo_cielo() + [L("M80 28 L80 86", NEGRO, 3.2), L("M46 32 L114 32", ROJO_OSCURO, 3.0), P([(114, 26), (124, 32), (114, 38)], ROJO), P([(40, 26), (50, 32), (40, 38), (48, 32)], AMARILLO_OSCURO)] + arco_giro(80, 32, 22, AZUL_OSCURO),
        "Veleta arriba del mástil girando para indicar la dirección del viento.")
    put("whirling", "D",
        fondo_cielo() + nino((80, 36), (80, 48), (80, 68), [[(68, 56)], [(92, 20)]], [[(74, 88)], [(86, 88)]]) + arco_giro(92, 20, 14, MORADO),
        "Dedo dibujando círculos rápidos girando en el aire.")
    put("wheels", "C",
        fondo_sala() + fl("Wheel", 24, 24, 48) + fl("Wheel", 88, 24, 48) + arco_giro(48, 48, 26, ROJO) + arco_giro(112, 48, 26, AZUL_OSCURO),
        "Dos ruedas girando a la vez en círculos.")
    put("wooden top", "D",
        fondo_mesa() + [P([(62, 28), (98, 28), (80, 68)], MADERA, MADERA_OSCURA, 2.2), R(76, 18, 8, 10, 2, BARRO, MADERA_OSCURA, 1.8), L("M68 42 L92 42", ROJO, 2.5)] + arco_giro(80, 46, 26, AZUL_OSCURO),
        "Trompo clásico de madera con raya roja girando en la mesa.")

    # ── Caminar y pasos (walk — bloque 1 de 41 piezas) ─────────────────────
    put("across the road", "D",
        fondo_prado() + [R(0, 60, 160, 26, 0, GRIS, GRIS_OSCURO, 1.5), R(22, 64, 16, 18, 1, BLANCO), R(52, 64, 16, 18, 1, BLANCO), R(82, 64, 16, 18, 1, BLANCO), R(112, 64, 16, 18, 1, BLANCO)] + nino_corriendo(78, 30, 1) + frecha((36, 22), (124, 22), VERDE_OSCURO, 2.6),
        "Niño cruzando de un lado al otro de la calle por las rayas.")
    put("along the path", "D",
        fondo_prado() + [F("M20 88 Q76 72 140 82 L140 94 Q76 84 20 96 Z", TIERRA_CLARA, BARRO, 1.8)] + nino((50, 34), (50, 46), (50, 66), [[(62, 54)], [(38, 56)]], [[(44, 86)], [(56, 86)]]) + nino((98, 34), (98, 46), (98, 66), [[(110, 54)], [(86, 56)]], [[(92, 86)], [(104, 86)]], camisa=(AZUL, AZUL_OSCURO)),
        "Niños caminando uno detrás de otro por el sendero marcado.")
    put("ancient town", "C",
        fondo_prado() + fl("Castle", 26, 16, 54) + nino((106, 34), (106, 46), (106, 66), [[(96, 56)], [(116, 56)]], [[(100, 88)], [(112, 88)]]),
        "Niño paseando despacio frente a las murallas de una villa antigua.")
    put("ant steps", "C",
        fondo_prado() + fl("Ant", 24, 34, 42) + nino((102, 34), (102, 46), (102, 66), [[(92, 56)], [(112, 56)]], [[(99, 88)], [(105, 88)]]) + frecha((84, 78), (118, 78), ROJO, 2.0),
        "Hormiga pequeña y niño dando pasos diminutos.")
    put("around the fire", "C",
        fondo_noite() + fl("Fire", 58, 30, 44) + nino((32, 34), (32, 46), (32, 66), [[(24, 56)], [(40, 56)]], [[(28, 86)], [(36, 86)]]) + nino((128, 34), (128, 46), (128, 66), [[(120, 56)], [(136, 56)]], [[(124, 86)], [(132, 86)]], camisa=(AZUL, AZUL_OSCURO)) + arco_giro(80, 54, 36, "#fde047"),
        "Niños caminando en círculo alrededor de la hoguera cálida.")
    put("around the square", "D",
        fondo_sala() + [R(46, 36, 68, 44, 2, "#fef3c7", ROJO, 3.0)] + nino((36, 34), (36, 46), (36, 66), [[(28, 56)], [(44, 56)]], [[(32, 86)], [(40, 86)]]) + frecha((54, 26), (108, 26), AZUL_OSCURO, 2.4) + frecha((122, 38), (122, 76), AZUL_OSCURO, 2.4),
        "Recorrido siguiendo los cuatro lados de un cuadrado en el suelo.")
    put("autumn walk", "C",
        fondo_prado() + fl("Maple leaf", 22, 16, 28) + fl("Fallen leaf", 112, 56, 28) + nino((74, 34), (74, 46), (74, 66), [[(62, 54)], [(86, 54)]], [[(68, 88)], [(80, 88)]]) + bebe(48, 52),
        "Paseo otoñal acunando al bebé entre hojas caídas.")
    put("backwards", "D",
        fondo_sala() + nino((88, 34), (88, 46), (88, 66), [[(98, 56)], [(78, 56)]], [[(82, 88)], [(94, 88)]], mira=1) + frecha((74, 24), (34, 24), ROJO, 3.0),
        "Niño mirando al frente mientras camina pasos hacia atrás.")
    put("beachcomb", "C",
        fondo_mar() + [R(0, 62, 160, 38, 0, "#fde68a")] + fl("Spiral shell", 104, 62, 26) + nino((58, 34), (58, 46), (58, 66), [[(70, 54)], [(46, 56)]], [[(52, 84)], [(64, 84)]]),
        "Niño caminando por la arena buscando conchas y tesoros del mar.")
    put("beanbag balance", "D",
        fondo_sala() + nino((80, 36), (80, 48), (80, 68), [[(62, 50)], [(98, 50)]], [[(74, 88)], [(86, 88)]]) + [R(70, 18, 20, 9, 4, ROJO, ROJO_OSCURO, 1.8)] + frecha((54, 78), (106, 78), VERDE_OSCURO, 2.4),
        "Niño caminando equilibrando un saquito rojo sobre la cabeza.")
    put("big drum", "C",
        fondo_sala() + fl("Drum", 28, 26, 48) + nino_corriendo(104, 34, 1) + notas([(68, 20), (88, 16)]),
        "Bombo sonando al paso de marcha del niño.")
    put("big like a giant", "D",
        fondo_prado() + nino((80, 22), (80, 38), (80, 60), [[(56, 20)], [(104, 20)]], [[(62, 88)], [(98, 88)]], r=10) + frecha((36, 74), (36, 20), ROJO, 3.0),
        "Niño muy estirado dando zancadas enormes como un gigante.")
    put("big steps and little steps", "D",
        fondo_prado() + nino((42, 34), (42, 46), (42, 66), [[(30, 52)], [(54, 52)]], [[(24, 88)], [(60, 88)]]) + nino((114, 34), (114, 46), (114, 66), [[(106, 56)], [(122, 56)]], [[(111, 88)], [(117, 88)]], camisa=(AZUL, AZUL_OSCURO)),
        "Niño dando un paso muy largo frente a otro dando pasos cortos.")
    put("big, bigger, biggest", "D",
        fondo_prado() + [E(34, 62, 10, 10, AMARILLO, NARANJA_OSCURO, 2.0), E(72, 54, 18, 18, VERDE, VERDE_OSCURO, 2.0), E(122, 44, 26, 26, ROJO, ROJO_OSCURO, 2.2)],
        "Tres formas creciendo progresivamente: grande, más grande y el más grande.")
    put("blow kisses", "C",
        fondo_sala() + nino((52, 34), (52, 46), (52, 66), [[(64, 38)], [(38, 56)]], [[(46, 88)], [(58, 88)]]) + fl("Kiss mark", 92, 24, 34) + frecha((72, 40), (92, 40), ROSA_OSCURO, 2.2),
        "Niño llevándose la mano a la boca para mandar besos.")
    put("castle wall", "C",
        fondo_prado() + [R(18, 16, 44, 68, 2, GRIS, GRIS_OSCURO, 2.2), R(18, 10, 12, 8, 1, GRIS_OSCURO), R(34, 10, 12, 8, 1, GRIS_OSCURO), R(50, 10, 12, 8, 1, GRIS_OSCURO)] + nino((94, 34), (94, 46), (94, 66), [[(66, 48)], [(108, 56)]], [[(88, 88)], [(100, 88)]]),
        "Niño caminando rozando con la mano la muralla de piedra.")
    put("chase", "D",
        fondo_prado() + nino_corriendo(44, 34, 1) + nino_corriendo(108, 34, 1, camisa=(AZUL, AZUL_OSCURO)),
        "Dos niños persiguiéndose a paso rápido uno detrás del otro.")
    put("circle around", "D",
        fondo_prado() + nino((80, 34), (80, 46), (80, 66), [[(70, 56)], [(90, 56)]], [[(74, 88)], [(86, 88)]], camisa=(AZUL, AZUL_OSCURO)) + arco_giro(80, 56, 34, ROJO),
        "Caminar dando toda la vuelta alrededor de un compañero.")
    put("climb up the hill", "D",
        fondo_prado() + [P([(20, 84), (140, 84), (140, 26)], HERBA, HERBAB, 2.2)] + nino_inclinado(82, 34, 12) + frecha((36, 56), (96, 22), ROJO, 2.8),
        "Niño inclinado hacia delante subiendo caminando la colina.")
    put("corner", "D",
        fondo_sala() + [R(22, 22, 60, 60, 2, None, AZUL_OSCURO, 3.0), E(82, 22, 6, 6, ROJO, ROJO_OSCURO, 2.0)] + nino((112, 34), (112, 46), (112, 66), [[(98, 40)], [(124, 56)]], [[(106, 88)], [(118, 88)]]),
        "Esquina en ángulo recto y niño caminando hasta ella.")
    put("crossing", "D",
        fondo_prado() + [R(0, 62, 160, 28, 0, GRIS, GRIS_OSCURO, 1.5), R(24, 66, 18, 20, 1, BLANCO), R(56, 66, 18, 20, 1, BLANCO), R(88, 66, 18, 20, 1, BLANCO), R(120, 66, 18, 20, 1, BLANCO)] + nino((50, 32), (50, 44), (50, 64), [[(62, 52)], [(38, 54)]], [[(44, 84)], [(56, 84)]]),
        "Paso de peatones con franjas blancas y niño cruzando por encima.")
    put("enter on the left and exit on the right", "D",
        fondo_sala() + [R(28, 18, 104, 62, 3, "#fef3c7", MADERA_OSCURA, 2.2)] + frecha((10, 48), (46, 48), VERDE_OSCURO, 2.8) + nino((80, 34), (80, 46), (80, 66), [[(92, 54)], [(68, 54)]], [[(74, 86)], [(86, 86)]]) + frecha((114, 48), (150, 48), ROJO, 2.8),
        "Entrada por la izquierda al escenario y salida por la derecha.")
    put("enter the stage", "D",
        fondo_sala() + [R(46, 16, 94, 66, 3, "#fef3c7", MADERA_OSCURA, 2.2)] + frecha((14, 48), (64, 48), VERDE_OSCURO, 3.0) + nino((84, 34), (84, 46), (84, 64), [[(96, 54)], [(72, 54)]], [[(78, 84)], [(90, 84)]]),
        "Niño caminando hacia el centro para entrar en el escenario.")
    put("exit the stage", "D",
        fondo_sala() + [R(18, 16, 94, 66, 3, "#fef3c7", MADERA_OSCURA, 2.2)] + nino((74, 34), (74, 46), (74, 64), [[(86, 54)], [(62, 54)]], [[(68, 84)], [(80, 84)]]) + frecha((98, 48), (146, 48), ROJO, 3.0),
        "Niño caminando hacia el borde para salir del escenario.")
    put("fast and slow", "C",
        fondo_prado() + fl("Turtle", 22, 36, 44) + nino_corriendo(106, 34, 1) + frecha((26, 22), (56, 22), AZUL_OSCURO, 2.2) + frecha((96, 20), (142, 20), ROJO, 3.0),
        "Tortuga lenta comparada con niño caminando y corriendo muy rápido.")
    put("faster and faster", "D",
        fondo_prado() + nino_corriendo(106, 34, 1) + frecha((18, 48), (44, 48), AMARILLO_OSCURO, 2.4) + frecha((42, 48), (74, 48), NARANJA_OSCURO, 2.8) + frecha((70, 48), (94, 48), ROJO, 3.2),
        "Tres flechas sucesivas indicando ritmo cada vez más rápido.")
    put("follow the map", "C",
        fondo_prado() + fl("World map", 24, 18, 54) + nino((104, 34), (104, 46), (104, 66), [[(84, 42)], [(116, 56)]], [[(98, 88)], [(110, 88)]]) + frecha((40, 62), (72, 40), ROJO, 2.4),
        "Mapa del camino y niño siguiendo la ruta marcada.")
    put("follow the rules", "D",
        fondo_sala() + [L("M24 78 L136 78", VERDE_OSCURO, 4.0)] + nino((52, 34), (52, 46), (52, 66), [[(64, 54)], [(40, 56)]], [[(46, 86)], [(58, 86)]]) + nino((104, 34), (104, 46), (104, 66), [[(116, 54)], [(92, 56)]], [[(98, 86)], [(110, 86)]], camisa=(AZUL, AZUL_OSCURO)),
        "Niños caminando ordenados por encima de la línea verde marcada.")
    put("footpath", "C",
        fondo_prado() + [F("M30 92 Q78 66 130 92 Z", TIERRA_CLARA, BARRO, 1.8)] + fl("Footprints", 56, 22, 46),
        "Sendero natural de tierra marcado con huellas de pisadas.")
    put("fox cub", "C",
        fondo_prado() + fl("Fox", 28, 30, 46) + nino_corriendo(102, 36, 1, camisa=(NARANJA, NARANJA_OSCURO)),
        "Cachorro de zorro ligero junto al niño caminando rápido de puntillas.")
    put("giant", "D",
        fondo_prado() + nino((80, 18), (80, 34), (80, 58), [[(56, 44)], [(104, 44)]], [[(64, 88)], [(96, 88)]], r=11, camisa=(AZUL, AZUL_OSCURO)) + [L("M48 92 L72 92", BARRO, 3.0), L("M88 92 L112 92", BARRO, 3.0)],
        "Figura muy alta dando pisadas enormes y pesadas como un gigante.")
    put("giant steps", "C",
        fondo_prado() + fl("Footprints", 22, 46, 36) + frecha((60, 62), (96, 62), ROJO, 2.8) + fl("Footprints", 100, 46, 36),
        "Dos pares de huellas muy separadas mostrando pasos gigantes.")
    put("go around", "D",
        fondo_prado() + [P([(70, 78), (90, 78), (82, 42), (78, 42)], NARANJA, NARANJA_OSCURO, 2.2), R(66, 78, 28, 5, 2, NARANJA_OSCURO)] + arco_giro(80, 60, 34, AZUL_OSCURO),
        "Cono naranja rodeado por un giro completo en círculo.")
    put("go slow", "C",
        fondo_prado() + fl("Turtle", 28, 32, 48) + nino((106, 34), (106, 46), (106, 66), [[(96, 56)], [(116, 56)]], [[(102, 88)], [(110, 88)]]) + frecha((84, 24), (124, 24), AZUL_OSCURO, 2.0),
        "Niño caminando muy despacio al ritmo tranquilo de la tortuga.")
    put("go straight on", "D",
        fondo_prado() + nino((42, 34), (42, 46), (42, 66), [[(54, 54)], [(30, 56)]], [[(36, 88)], [(48, 88)]]) + frecha((64, 48), (138, 48), VERDE_OSCURO, 4.0),
        "Niño caminando todo recto siguiendo la flecha sin girar.")
    put("graceful steps", "D",
        fondo_sala() + nino((80, 32), (80, 44), (80, 64), [[(58, 36)], [(102, 36)]], [[(75, 84)], [(85, 80)]], camisa=(ROSA, ROSA_OSCURO)) + [L("M73 88 L77 84", PELB, 2.0), L("M83 84 L87 80", PELB, 2.0)],
        "Niño andando suave de puntillas con brazos arqueados elegantes.")
    put("grow taller", "C",
        fondo_prado() + fl("Seedling", 24, 50, 30) + frecha((60, 64), (60, 26), VERDE_OSCURO, 2.8) + nino((104, 28), (104, 42), (104, 62), [[(92, 22)], [(116, 22)]], [[(98, 84)], [(110, 84)]]),
        "Brote pequeño creciendo hacia arriba junto a niño estirándose alto de puntillas.")
    put("grown-up now", "D",
        fondo_sala() + nino((44, 52), (44, 62), (44, 76), [[(36, 68)], [(52, 68)]], [[(40, 88)], [(48, 88)]], r=7) + frecha((62, 62), (86, 42), VERDE_OSCURO, 2.6) + nino((112, 22), (112, 36), (112, 60), [[(98, 48)], [(126, 48)]], [[(106, 88)], [(118, 88)]], r=10, camisa=(AZUL, AZUL_OSCURO)),
        "Niño pequeño que ha crecido mucho hasta hacerse mayor y alto.")
    put("hike", "C",
        fondo_prado() + fl("Hiking boot", 24, 30, 44) + fl("Mountain", 84, 22, 54),
        "Bota de montaña subiendo por sendero hacia la cumbre.")
    put("hurry", "D",
        fondo_cielo() + gotas([(32, 16), (56, 24), (104, 16), (128, 24)]) + nino_corriendo(80, 36, 1) + [R(68, 22, 24, 10, 4, AMARILLO, NARANJA_OSCURO, 1.8)],
        "Niño tapándose la cabeza y caminando rápido bajo la lluvia.")
    put("boot print", "C",
        fondo_prado() + [R(20, 68, 120, 14, 4, TIERRA_CLARA, BARRO, 1.8)] + fl("Hiking boot", 28, 20, 46) + fl("Footprints", 92, 54, 34),
        "Bota de campo pisando la tierra y dejando la huella marcada.")
    put("crunch leaves", "C",
        fondo_prado() + fl("Fallen leaf", 28, 56, 30) + fl("Maple leaf", 104, 56, 30) + nino((76, 26), (76, 38), (76, 56), [[(64, 48)], [(88, 48)]], [[(68, 72)], [(84, 72)]]),
        "Niño pisando hojas secas caídas en el suelo.")
    put("i'm taller than you", "D",
        fondo_sala() + nino((52, 46), (52, 56), (52, 72), [[(42, 64)], [(62, 64)]], [[(48, 88)], [(56, 88)]], r=8, camisa=(AZUL, AZUL_OSCURO)) + nino((104, 24), (104, 38), (104, 60), [[(90, 48)], [(118, 48)]], [[(99, 86)], [(109, 86)]], r=9) + [L("M44 36 L116 14", ROJO, 2.4)],
        "Niño estirado más alto que su compañero con línea comparativa de altura.")
    put("in the snow", "C",
        fondo_cielo() + [R(0, 68, 160, 32, 0, BLANCO, "#bae6fd", 1.8)] + copos_nieve([(26, 20), (132, 22), (48, 40)]) + nino((80, 26), (80, 38), (80, 56), [[(66, 46)], [(94, 46)]], [[(68, 70), (74, 78)], [(92, 66), (92, 74)]]),
        "Niño caminando por la nieve levantando bien los pies.")
    put("march", "D",
        fondo_prado() + nino((80, 30), (80, 42), (80, 62), [[(64, 42)], [(96, 46)]], [[(70, 74), (72, 86)], [(92, 70), (88, 78)]]) + frecha((98, 74), (98, 56), ROJO, 2.6),
        "Niño marchando en el sitio levantando con ritmo las rodillas.")
    return m


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = _escenas()

# ── Piezas auditadas SIN base visual clara (se dejan SIN lámina para Frank) ─
SIN_BASE: dict[str, str] = {
    "are you ok": "Pregunta conversacional («¿Estás bien?»); inclinación ambigua sin texto.",
    "grateful": "Sentimiento abstracto («Agradecido»); difícil de distinguir sin texto de rezar o abrazar.",
    "sustainable": "Concepto abstracto («Sostenible»); gesto de manos en equilibrio ambiguo sin texto.",
    "carefree": "Adjetivo anímico abstracto («Despreocupado»); indistinguible de saltar alegre sin texto.",
    "eager": "Adjetivo emocional abstracto («Con ganas»); indistinguible de saltar en el sitio.",
    "energetic": "Adjetivo abstracto («Con energía»); sin objeto distinto de saltar.",
    "energy": "Concepto físico abstracto («Energía»).",
    "excited for next year": "Expectativa temporal futura abstracta («Con ganas del año que viene»).",
    "excited for summer": "Expectativa emocional abstracta («Con ganas de verano»).",
    "happiest": "Grado superlativo abstracto («El más feliz»).",
    "how high can you jump": "Pregunta cuantitativa abierta («¿Cuánto saltas?»).",
    "joyous": "Adjetivo emocional abstracto («Gozoso»).",
    "ten, nine, eight... blast off": "Consigna verbal de cuenta atrás («¡Diez, nueve, ocho...!»); depende de números hablados.",
    "three, two, one, happy new year": "Consigna verbal de cuenta atrás («¡Tres, dos, uno...!»); depende de números hablados.",
    "two, four, six, eight": "Serie numérica hablada («Dos, cuatro, seis, ocho»); no conviene meter texto/dígitos en la lámina.",
    "can you catch me": "Pregunta de juego verbal («¿Puedes pillarme?»); indistinguible de perseguir sin texto.",
    "unstoppable": "Adjetivo abstracto («Imparable»).",
    "change the ending": "Concepto narrativo abstracto («Cambiar el final»).",
    "i see it differently": "Expresión cognitiva abstracta («Yo lo veo de otra manera»).",
    "let's try another way": "Consigna metacognitiva abstracta («Probemos de otra manera»).",
    "plot twist": "Concepto narrativo abstracto («Giro en la historia»).",
    "the pattern repeats again and again": "Regla abstracta de repetición sin objeto único.",
    "turn it around and try again": "Consigna procesal abstracta («Dale la vuelta y prueba otra vez»).",
    "here it comes": "Exclamación situacional («¡Ahí va!»); redundante con «roll back»/«ball to baby» sin texto.",
    "adventurous": "Adjetivo de carácter abstracto («Aventurero»).",
    "ceremony": "Sustantivo institucional abstracto («Ceremonia»); ambiguo frente a desfilar o caminar erguido.",
    "first the hero was lost, then she found her way home": "Oración narrativa de dos tiempos demasiado compleja para un solo dibujo sin texto.",
    "let's play": "Consigna genérica («¡Vamos a jugar!»); rechazada en revisión P2.81 por no tener objeto único.",
    "most crabs walk sideways, but the spider crab walks forwards": "Comparación biológica entre dos especies imposible de distinguir sin texto.",
    "next year we will be the oldest": "Comparación temporal abstracta («El año que viene seremos los mayores»).",
    "quietly, quietly": "Adverbio repetido abstracto («Bajito, bajito»).",
    "walking is better than driving for short trips": "Juicio comparativo de movilidad imposible de expresar fielmente sin texto.",
    "we walk on the path so the plants can grow": "Oración causal normativa demasiado larga para un pictograma sin texto.",
    "proud": "Sentimiento abstracto («Orgulloso»).",
}
