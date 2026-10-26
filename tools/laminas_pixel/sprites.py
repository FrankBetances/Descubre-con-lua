"""Sprites de las láminas, en rejilla de caracteres (contorno automático).
Cada uno: (filas, paleta). Letras de paleta por sprite; '.' es vacío."""
from motor import de_reixa

# Paletas compartidas
BR = {"w": "#ffffff", "l": "#eef3f8", "s": "#c9d3de"}            # branco
MA = {"m": "#a8763f", "M": "#7a5232", "d": "#5a3a20", "c": "#d29d55"}  # madeira
VE = {"v": "#e2483d", "V": "#b02e2a", "h": "#ff8a7a"}             # vermello

S = {}


def def_(nome, filas, pal):
    S[nome] = (filas, pal)


# --- Animais ------------------------------------------------------------------
def_("peixe", [
    "....oooo........",
    "...oLLLLo...oo..",
    "..oLssssbo.oLo..",
    ".oLswKsssbboLso.",
    "oLsswKKssxsbbsbo",
    "oPssssssxsxsbbbo",
    ".oPsssssssbbbbo.",
    "..ooPbbbbddoLbo.",
    "....oodddoo.oo..",
], {"o": "#16324f", "L": "#d6f6ff", "s": "#7fd3f0", "x": "#5cbde2", "b": "#3f9fd0",
    "d": "#2a73a8", "w": "#ffffff", "K": "#141220", "P": "#ffb3b3"})
def_("peixe_laranxa", S["peixe"][0], {**S["peixe"][1], "L": "#ffe2b8", "s": "#ffa24a", "x": "#ff8a2a",
                                         "b": "#e8701e", "d": "#b9531a"})
def_("polbo", [
    "....RRRRRR....",
    "..RRrrrrrrRR..",
    ".RrrrrrrrrrrR.",
    ".RrwwKrrwwKrR.",
    ".RrwwKrrwwKrR.",
    ".RrrrrPPrrrrR.",
    "..RrrrrrrrrR..",
    ".RrRrRrRrRrRr.",
    "Rr.Rr.Rr.Rr.Rr",
    "r..r..r..r...r",
], {"R": "#b8322e", "r": "#e2574a", "w": "#ffffff", "K": "#141220", "P": "#ff9a8a"})
def_("caracola", [
    "...pp...",
    "..pPPp..",
    ".pPwpPp.",
    "pPpppPPp",
    ".pPPPPp.",
    "..pppp..",
], {"p": "#ff9ec0", "P": "#e46a96", "w": "#ffffff"})
def_("can", [
    "..MM.......",
    ".MmmM......",
    ".mKmmm.....",
    ".mmmmNm..m.",
    "..mmmmmmmmm",
    "..mmmmmmmm.",
    "..mmmmmmmm.",
    "..m.m..m.m.",
    "..d.d..d.d.",
], {"m": "#b9834e", "M": "#7a5232", "d": "#5a3a20", "K": "#141220", "N": "#2a2028"})
def_("can_manchas", S["can"][0], {**S["can"][1], "m": "#f6f6f6", "M": "#2a2a2a", "d": "#3a3a3a"})
def_("can_trapo", S["can"][0], {**S["can"][1], "m": "#6aa9e0", "M": "#3f7cc0", "d": "#2f5c90"})
def_("gato", [
    ".g...g....",
    ".gg.gg....",
    ".gKggKg...",
    ".ggpggg...",
    "..ggggg..g",
    "..gggggg.g",
    "..ggggggg.",
    "..g.g.gg..",
], {"g": "#9aa3ad", "K": "#141220", "p": "#ff9ec0"})
def_("gato_negro", S["gato"][0], {**S["gato"][1], "g": "#2e2a36", "K": "#ffd23a"})
def_("gato_laranxa", S["gato"][0], {**S["gato"][1], "g": "#f2a04a"})
def_("vaca", [
    "B.............B.",
    "BwwwwwwwwwwwwwB.",
    ".wwBBwwwwwwBBww.",
    ".wBBBwwwwwBBBwwp",
    ".wwBwwwwwwwBwwKp",
    ".wwwwwwwwwwwwwpp",
    ".www.ww..ww.www.",
    ".BB..BB..BB..BB.",
], {"w": "#f6f6f6", "B": "#2a2a2a", "K": "#141220", "p": "#f4a6b6"})
def_("ovella", [
    "..wwwwww..",
    ".wwwwwwwwk",
    "wwwwwwwwKk",
    "wwwwwwwwkk",
    ".wwwwwwww.",
    "..k.k.k.k.",
], {"w": "#f7f3ea", "k": "#3a3440", "K": "#ffffff"})
def_("cabra", [
    "........hh",
    "..wwwwwwwK",
    ".wwwwwwwww",
    ".wwwwwwww.",
    ".w.w..w.w.",
    ".k.k..k.k.",
], {"w": "#f7f3ea", "k": "#6a5a50", "K": "#141220", "h": "#b89a70"})
def_("cabalo", [
    "...........MM.",
    "..........MmmK",
    "..........mmmm",
    ".mmmmmmmmmmm..",
    "Mmmmmmmmmmmm..",
    "M.mmmmmmmmm...",
    "..m.m...m.m...",
    "..d.d...d.d...",
], {"m": "#9a5e34", "M": "#5a3418", "d": "#3a2210", "K": "#141220"})
def_("pato", [
    "..yyy..",
    ".yyKy..",
    ".yyyyoo",
    "yyyyy..",
    "yyyyyy.",
    ".yyyy..",
], {"y": "#ffd23a", "K": "#141220", "o": "#ff8a2a"})
def_("pata_branca", S["pato"][0], {**S["pato"][1], "y": "#f6f6f6"})
def_("ra", [
    ".gg..gg.",
    "gwKggwKg",
    "gggggggg",
    ".gppppg.",
    "gg.gg.gg",
], {"g": "#5cb84a", "w": "#ffffff", "K": "#141220", "p": "#a6dc6a"})
def_("paxaro", [
    "..yyy..",
    ".yKyyo.",
    "yyyyy..",
    ".yYYy..",
    "..yy...",
], {"y": "#ffd23a", "Y": "#e6a91a", "K": "#141220", "o": "#ff8a2a"})
def_("paporrubio", S["paxaro"][0], {**S["paxaro"][1], "y": "#8a6a4a", "Y": "#ff7a3a"})
def_("esquío", [
    "......ttt.",
    ".m...ttttt",
    "mKm..tt.tt",
    "mmm...t.t.",
    ".mmm..tt..",
    ".mmmmtt...",
    "..m.m.....",
], {"m": "#b9663a", "t": "#d98a4a", "K": "#141220"})
def_("ourizo", [
    "..sSsSs..",
    ".SsSsSsS.",
    "SsSsSsSmm",
    "SSsSsSmKm",
    ".mmmmmmmn",
    "..m...m..",
], {"s": "#7a5a3a", "S": "#4a3420", "m": "#d9b48a", "K": "#141220", "n": "#2a2028"})
def_("rato", [
    ".pp....",
    "pggg...",
    ".gKgg..",
    ".ggggg.",
    "..g.g.p",
], {"g": "#a0a0aa", "p": "#ffb6c8", "K": "#141220"})
def_("formiga", [
    "k.k..",
    ".kk.k",
    "kkkkk",
    "k.k.k",
], {"k": "#1e1a24"})
def_("caracol", [
    "....yyy.",
    "...yYyYy",
    "...yyYyy",
    "ccccyyy.",
    "cccccc..",
], {"y": "#ffd23a", "Y": "#c9921a", "c": "#d9c49a"})
def_("lobo", [
    "g.........",
    "gg........",
    "ggKgg.....",
    "ggggggggg.",
    ".gggggggggg",
    ".gggggggg.",
    ".g.g..g.g.",
], {"g": "#8a929c", "K": "#141220"})
def_("raposo", [
    "o.o.......",
    "ooo.......",
    "oKoo......",
    "wooooooo..",
    ".ooooooooo",
    ".oooooow.w",
    ".k.k..k.k.",
], {"o": "#e8782a", "w": "#ffffff", "K": "#141220", "k": "#3a2a20"})
def_("osito", [
    "M....M",
    "MmmmmM",
    "mKmmKm",
    "mmnnmm",
    ".mmmm.",
    "mmmmmm",
    "mmmmmm",
    ".m..m.",
], {"m": "#b9834e", "M": "#7a5232", "K": "#141220", "n": "#e9c9a0"})
def_("bebé", [
    ".nnnn.",
    "nKnnKn",
    "nbnnbn",
    ".nnnn.",
    "wwwwww",
    "wwwwww",
    ".n..n.",
], {"n": "#f6d2b8", "K": "#141220", "b": "#6aa9e0", "w": "#ffffff"})
def_("pinguín", [
    ".kkk.",
    "kwKwk",
    "kwwwo",
    "kwwwk",
    "kwwwk",
    ".o.o.",
], {"k": "#24202e", "w": "#ffffff", "K": "#141220", "o": "#ff9a2a"})

# --- Obxectos -----------------------------------------------------------------
def_("mazá", [".gM..", "..M..", ".vvv.", "vvhvv", "vvvvv", ".vvv."], {**VE, "g": "#5cb84a", "M": "#7a5232"})
def_("mazá_cuartos", ["vh.vh", "ww.ww", "....", "vh.vh", "ww.ww"], {**VE, "w": "#fff2d6"})
def_("pera", ["..M..", ".ggg.", ".ggg.", "ggggg", "ggggg", ".ggg."], {"g": "#c4d94a", "M": "#7a5232"})
def_("prato", [".wwwwwww.", "wwlllllww", ".wwwwwww."], BR)
def_("prato_metal", [".ssssssss.", "sSSSSSSSSs", ".ssssssss."], {"s": "#c9d3de", "S": "#e6edf3"})
def_("mesa", [
    "cccccccccccccccccccccccccccccc",
    "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm",
    ".M........................M.",
    ".M........................M.",
    ".M........................M.",
    ".M........................M.",
], MA)
def_("cama", [
    "Mwwwwww.....................",
    "Mwwwwwwlllllllllllllllllllll",
    "Mbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    "Mbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    "MMMMMMMMMMMMMMMMMMMMMMMMMMMM",
    "M..........................M",
], {**BR, "M": "#7a5232", "b": "#9ec8f0"})
def_("manta", ["bbbbbbbbbbbbbbbb", "bBbbBbbBbbBbbBbb", "bbbbbbbbbbbbbbbb"], {"b": "#9ec8f0", "B": "#bfe0fb"})
def_("manta_vermella", S["manta"][0], {"b": "#e2483d", "B": "#ff7a6a"})
def_("manta_lila", S["manta"][0], {"b": "#b48ad9", "B": "#cfaeef"})
def_("manta_cadros", ["vwvwvwvwvwvwvwvwvw", "wvwvwvwvwvwvwvwvwv", "vwvwvwvwvwvwvwvwvw", "wvwvwvwvwvwvwvwvwv"],
     {"v": "#e2483d", "w": "#ffffff"})
def_("pelota", [".vvvv.", "vhvvvv", "vvvvVv", "vvvVVv", ".vvvv."], VE)
def_("pelota_amarela", S["pelota"][0], {"v": "#ffd23a", "h": "#fff2a0", "V": "#d9a51a"})
def_("pelota_azul", S["pelota"][0], {"v": "#4f9ee0", "h": "#a6d6ff", "V": "#2f6cb0"})
def_("pelota_verde", S["pelota"][0], {"v": "#5cb84a", "h": "#a6dc6a", "V": "#3a8a2a"})
def_("caixa", ["cccccccccccc", "mmmmmmmmmmmm", "mmmmmmmmmmmm", "mMmmmmmmmmMm", "mmmmmmmmmmmm", "MMMMMMMMMMMM"], MA)
def_("caixa_cartón", ["cccccccccccc", "kkkkkkkkkkkk", "kkkkKKkkkkkk", "kkkkkkkkkkkk", "kkkkkkkkkkkk"],
     {"c": "#e2c08a", "k": "#c9a06a", "K": "#a67c4a"})
def_("caixa_azul", ["...vv...", "bbbvvbbb", "bbbvvbbb", "bbbbbbbb", "bbbbbbbb"], {"b": "#4f7ee0", "v": "#e2483d"})
def_("cesta", [".mmmmmmmm.", "mcmcmcmcmm", "mmcmcmcmcm", "mcmcmcmcmm", ".mmmmmmmm."], {"m": "#c08a4a", "c": "#9a6a34"})
def_("rocha", ["...ssss...", ".sSSsssss.", "sSSssssss.", "ssssssssss", "sssssssssk"], {"s": "#8a8494", "S": "#a9a3b4", "k": "#5d566b"})
def_("pedra", [".sss.", "sSsss", "sssss"], {"s": "#9a94a4", "S": "#c2bdc9"})
def_("pedra_branca", [".ww.", "wwww", ".ww."], BR)
def_("folla", ["...g", ".ggg", "gGgg", "ggg.", "g..."], {"g": "#5cb84a", "G": "#8fd46a"})
def_("folla_laranxa", S["folla"][0], {"g": "#e8822a", "G": "#ffb35a"})
def_("folla_vermella", S["folla"][0], {"g": "#d23a32", "G": "#ff6a5a"})
def_("folla_marrón", S["folla"][0], {"g": "#9a6a34", "G": "#c08a4a"})
def_("árbore", [
    "...ggggg...",
    ".gggGgggg..",
    "gggGGgggggg",
    "gggggggGggg",
    ".gggggggg..",
    "....mm.....",
    "....mm.....",
    "....mm.....",
    "...mmmm....",
], {"g": "#3f8a3a", "G": "#6ab84a", "m": "#7a5232"})
def_("gorro", ["..vv..", ".vvvv.", "vvvvvv", "wwwwww"], {"v": "#e2483d", "w": "#ffffff"})
def_("banco", ["mmmmmmmmmmmm", "cccccccccccc", "mmmmmmmmmmmm", "M..........M", "M..........M"], MA)
def_("castaña", [".mm.", "mcmm", "mmmm", ".mm."], {"m": "#7a4a2a", "c": "#b97a4a"})
def_("ola", [
    ".............",
    "..sssssssss..",
    ".sSSSSSSSSSs.",
    "sSSSSSSSSSSSs",
    "sSSSSSSSSSSSs",
    ".sssssssssss.",
], {"s": "#4a4a54", "S": "#7a7a86"})
def_("cullerón", ["mm", "mm", ".m", ".m", ".m", ".m"], MA)
def_("cenoria", [".gg", "oog", "oo.", "o.."], {"o": "#ff8a2a", "g": "#5cb84a"})
def_("tomate", [".g.", "vvv", "vhv", "vvv"], {**VE, "g": "#5cb84a"})
def_("chícharos", ["gg.gg", "gGggG"], {"g": "#5cb84a", "G": "#8fd46a"})
def_("bañeira", [
    "ssssssssssssssssssssssssssssss",
    "swwwwwwwwwwwwwwwwwwwwwwwwwwwws",
    "swwwwwwwwwwwwwwwwwwwwwwwwwwwws",
    ".swwwwwwwwwwwwwwwwwwwwwwwwwws.",
    "..swwwwwwwwwwwwwwwwwwwwwwwws..",
    "...ss....................ss...",
], {**BR})
def_("auga_bañeira", ["aaaaaaaaaaaaaaaaaaaaaaaaaaaa", "aAaaaaAaaaaaAaaaaaAaaaaAaaaa"], {"a": "#9fdcf5", "A": "#d4f2fc"})
def_("espuma", [".ww..ww..ww.", "wwwwwwwwwwww", "wllwwllwwllw", ".wwwwwwwwww."], BR)
def_("columpio", [
    "MMMMMMMMMMMMMMMM",
    "M....k....k....M",
    "M....k....k....M",
    "M....k....k....M",
    "M....mmmmmm....M",
    "M..............M",
    "M..............M",
], {"M": "#4a6a8a", "k": "#8a8a8a", "m": "#c08a4a"})
def_("paraugas", [
    "....yyyy....",
    "..yyyyyyyy..",
    ".yyYyyyyYyy.",
    "yyyyyyyyyyyy",
    "Y.....k....Y",
    "......k.....",
    "......k.....",
    ".....kk.....",
], {"y": "#ffd23a", "Y": "#d9a51a", "k": "#5a4a3a"})
def_("paraugas_verde", S["paraugas"][0], {"y": "#5cb84a", "Y": "#3a8a2a", "k": "#5a4a3a"})
def_("cubeta", ["s................s", "saaaaaaaaaaaaaaaas", "saaaaAaaaaaAaaaaas", "saaaaaaaaaaaaaaaas", "ssssssssssssssssss"],
     {"s": "#cfe8f6", "a": "#7cc1e4", "A": "#bfe6fb"})
def_("barco", ["....w....", "....ww...", "....www..", "....k....", "vvvvvvvvv", ".vvvvvvv."], {**VE, "w": "#ffffff", "k": "#5a4a3a"})
def_("barco_papel", ["...w...", "..www..", "wwwwwww", ".wwwww."], {"w": "#ffffff"})
def_("vala", ["m...m...m...m...m", "mmmmmmmmmmmmmmmmm", "m...m...m...m...m", "mmmmmmmmmmmmmmmmm", "m...m...m...m...m"], {"m": "#c79562"})
def_("sol", ["..y.y..", ".yyyyy.", "yyYYYyy", ".yYYYy.", "yyYYYyy", ".yyyyy.", "..y.y.."], {"y": "#ffd23a", "Y": "#fff08a"})
def_("lúa_ceo", [".yyy", "yyy.", "yy..", "yyy.", ".yyy"], {"y": "#ffe58a"})
def_("bebedoiro", ["m............m", "maaaaaaaaaaaam", "mmmmmmmmmmmmmm", ".M..........M."], {**MA, "a": "#7cc1e4"})
def_("vaso", ["s...s", "saaas", "saaas", ".sss."], {"s": "#cfe8f6", "a": "#4f9ee0"})
def_("vaso_caído", ["sssss.", "saaaas", "sssss."], {"s": "#4f7ee0", "a": "#9fdcf5"})
def_("charco", [".aaaaaaa.", "aaAaaaaaa", "aaaaaAaaa", ".aaaaaaa."], {"a": "#6ab7e4", "A": "#bfe6fb"})
def_("charco_grande", [".aaaaaaaaaaaaaaaa.", "aaaAaaaaaaaaaAaaaa", "aaaaaaaAaaaaaaaaaa", ".aaaaaaaaaaaaaaaa."],
     {"a": "#6ab7e4", "A": "#bfe6fb"})
def_("lama", [".bbbbbbb.", "bbBbbbbbb", ".bbbbbbb."], {"b": "#7a5232", "B": "#9a6a42"})
def_("toalla", ["oooooo", "oOoOoO", "oooooo", "oOoOoO", "oooooo"], {"o": "#ff9a3a", "O": "#ffc07a"})
def_("toalla_amarela", S["toalla"][0], {"o": "#ffd23a", "O": "#fff08a"})
def_("toalla_verde", S["toalla"][0], {"o": "#5cb84a", "O": "#8fd46a"})
def_("toalla_rosa", S["toalla"][0], {"o": "#ff9ec0", "O": "#ffd0e0"})
def_("toalla_branca", S["toalla"][0], {"o": "#f6f6f6", "O": "#ffffff"})
def_("gancho", ["kk", ".k", "kk"], {"k": "#5a5a64"})
def_("billa", ["ssss.", "...s.", "...s."], {"s": "#8a929c"})
def_("regato", ["aa.........", ".aaa.......", "...aaaa....", "......aaaa.", ".........aa"], {"a": "#6ab7e4"})
def_("palla", [".yyyyyyyyy.", "yYyyYyyYyyy", "yyyyyyyyyyy", "yyYyyyYyyYy", "yyyyyyyyyyy"], {"y": "#f2d27a", "Y": "#d9ae4f"})
def_("tren", [
    "kk................",
    "gg................",
    "gggggg..wwwwww....",
    "gggggg..wwwwww....",
    "gggggggggggggggggg",
    ".k...k.....k...k..",
], {"g": "#4caf50", "w": "#e2c08a", "k": "#2a2a2a"})
def_("tren_vermello", S["tren"][0], {"g": "#e2483d", "w": "#f2c14e", "k": "#2a2a2a"})
def_("vía", ["kkkkkkkkkkkkkkkkkkkkkkkkkkkkkk", "m...m...m...m...m...m...m...m.", "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkk"],
     {"k": "#8a6a4a", "m": "#c08a4a"})
def_("bloque", ["vvvv", "vhvv", "vvvv", "vvvv"], VE)
def_("bloque_azul", S["bloque"][0], {"v": "#4f7ee0", "h": "#8fb6ff"})
def_("bloque_amarelo", S["bloque"][0], {"v": "#ffd23a", "h": "#fff08a"})
def_("bloque_madeira", S["bloque"][0], {"v": "#d29d55", "h": "#ecc27a"})
def_("forno", ["ssssssssss", "skkkkkkkks", "skooooooks", "skooppooks", "skkkkkkkks", "ssssssssss"],
     {"s": "#f2f2f2", "k": "#3a3a44", "o": "#5a4a3a", "p": "#e9b050"})
def_("pan", [".pppppp.", "pPpPpPpp", "pppppppp", ".pppppp."], {"p": "#e0a24a", "P": "#f6c87a"})
def_("xabón", ["yyyyy", "yYyyy", "yyyyy"], {"y": "#ffd23a", "Y": "#fff08a"})
def_("esponxa", ["yyyyy", "yYyYy", "yyyyy"], {"y": "#ffd23a", "Y": "#d9a51a"})
def_("esponxa_vermella", S["esponxa"][0], {"y": "#e2483d", "Y": "#b02e2a"})
def_("mel", [".kkk.", "yyyyy", "yYyyy", "yyyyy", ".yyy."], {"y": "#f2a72a", "Y": "#ffd27a", "k": "#c08a4a"})
def_("lavabo", ["sssssssss", "swwwwwwws", ".swwwwws.", "...sss...", "...sss..."], BR)
def_("tobogán", [
    "k.............",
    "kyy...........",
    "k.yy..........",
    "k..yy.........",
    "k...yyy.......",
    "k.....yyyy....",
    "k........yyyyy",
], {"k": "#4a6a8a", "y": "#ffd23a"})
def_("fonte", ["..a..", ".a.a.", "..s..", ".sss.", "sssss"], {"a": "#6ab7e4", "s": "#a9a3b4"})
def_("cepillo", ["kkkkkk", "mmmmmm"], {"k": "#e9c46a", "m": "#7a5232"})
def_("cunca", ["wwwwww", "lwwwwl", ".llll."], {"w": "#ffffff", "l": "#cfe8f6"})
def_("taza", ["vvvv", "vhvv", ".vv."], VE)
def_("taza_azul", S["taza"][0], {"v": "#4f7ee0", "h": "#8fb6ff"})
def_("xerra", [".ss.", "saas", "saas", "saas", ".ss."], {"s": "#cfe8f6", "a": "#7cc1e4"})
def_("poste", ["mm", "mm", "mm", "mm", "mm", "mm", "mm", "mm"], {"m": "#7a5232"})
def_("casiña_paxaros", ["..vv..", ".vvvv.", "vvvvvv", "mmmmmm", "mmkkmm", "mmkkmm", "mmmmmm"],
     {"v": "#e2483d", "m": "#c0503a", "k": "#3a2420"})
def_("cochiño", [".vvv..", "vvhvvv", "vvvvvv", ".k..k."], {**VE, "k": "#2a2a2a"})
def_("castelo_area", [".y.y.", "yyyyy", "yYyyy", "yyyyy"], {"y": "#ecc27a", "Y": "#d29d55"})
def_("estanque", [".aaaaaaaaaaaa.", "aaAaaaaaaaaaaa", "aaaaaaaAaaaaaa", ".aaaaaaaaaaaa."], {"a": "#4f9ee0", "A": "#a6d6ff"})
def_("pota", [".kkkkkkkk.", "kssssssssk", "kssssssssk", "kssssssssk", ".kkkkkkkk."], {"k": "#5a5a64", "s": "#8a929c"})
def_("sopa", ["oooovvvv"], {"o": "#ff9a3a", "v": "#5cb84a"})
def_("lupa", [".kkk.", "kaaak", "kaaak", ".kkk.", "...mm", "....m"], {"k": "#3a3a44", "a": "#d8f4ff", "m": "#7a5232"})
def_("ventá_peq", ["wwwww", "wbwbw", "wwwww", "wbwbw", "wwwww"], {"w": "#f4f4f4", "b": "#8fd0f2"})
def_("porta_establo", ["mmmmmm", "mMmmMm", "mmMMmm", "mMmmMm", "mmmmmm"], {"m": "#9a5e34", "M": "#6a3a18"})
def_("palliña", ["y"], {"y": "#f2d27a"})
def_("estrela", ["..y..", ".yyy.", "yyyyy", ".y.y."], {"y": "#ffd23a"})
def_("flor", [".v.", "vyv", ".v.", ".g.", ".g."], {"v": "#ff6f91", "y": "#ffd23a", "g": "#5cb84a"})
def_("flor_vermella", S["flor"][0], {"v": "#e2483d", "y": "#ffd23a", "g": "#5cb84a"})
def_("abella", ["..ww.", "ykyky", ".kKk."], {"y": "#ffd23a", "k": "#1e1a24", "K": "#141220", "w": "#e8f6ff"})
def_("nube", [".wwww..", "wwwwwww", ".wwwww."], {"w": "#ffffff"})
def_("nube_gris", S["nube"][0], {"w": "#a9b3bd"})
def_("mochila", [".yy.", "yyyy", "yYyy", "yyyy"], {"y": "#ffd23a", "Y": "#d9a51a"})
def_("botas", ["vv.vv", "vv.vv", "vvvvv"], VE)
def_("abrigo", [".gg.", "gggg", "gGgg", "gggg"], {"g": "#4caf50", "G": "#7fca5a"})
def_("disfrace", ["g.gg.g", "gggggg", "gGgggg", ".gggg."], {"g": "#4caf50", "G": "#ffd23a"})
def_("aro", [".mmmm.", "m....m", "m....m", ".mmmm."], {"m": "#c08a4a"})
def_("filloa", [".yyyy.", "yYyyYy", ".yyyy."], {"y": "#f2c14e", "Y": "#d99a2a"})
def_("testo", ["mmmmmm", ".mMmm.", ".mmmm."], {"m": "#c0603a", "M": "#e0804a"})
def_("brote", [".g.g", "..g.", "..g."], {"g": "#5cb84a"})
def_("serpe", ["....gg", "...gKg", "g..gg.", "gg.g..", ".ggg.."], {"g": "#5cb84a", "K": "#141220"})
def_("cova", ["..ssssss..", ".ssKKKKss.", "ssKKKKKKss", "sKKKKKKKKs"], {"s": "#8a8494", "K": "#2a2430"})
def_("clave", ["mmmmmm"], {"m": "#c08a4a"})
def_("vela", [".y.", ".o.", "www", "www", "www"], {"y": "#ffe36b", "o": "#ff8a2a", "w": "#f6f0e0"})
def_("farol", [".k.", "kyk", "kyk", "kkk"], {"k": "#3a3a44", "y": "#ffe36b"})
def_("corda", ["vvvvvvvvvvvvvvvv"], {"v": "#e2483d"})
def_("ponte", ["mmmmmmmmmmmm", "m.m.m.m.m.m.", "mmmmmmmmmmmm"], {"m": "#c08a4a"})
def_("tronco", ["mmmmmmmmmmmmmm", "mMmmmmMmmmmmMm", "mmmmmmmmmmmmmm"], {"m": "#9a6a34", "M": "#7a4a2a"})
def_("arbusto", [".gggg.", "gGgggg", "gggGgg", ".gggg."], {"g": "#3f8a3a", "G": "#6ab84a"})
def_("máscara", ["y.yy.y", "yyyyyy", "yKyyKy", ".yyyy."], {"y": "#f2a72a", "K": "#141220"})
def_("cono_papel", ["wwww", ".ww.", ".w.."], {"w": "#f6f0e0"})
def_("campá", [".y.", "yyy", "yyy", "yyy", ".k."], {"y": "#ffd23a", "k": "#5a4a3a"})
def_("tambor", ["vvvvvv", "wwwwww", "vwvwvw", "vvvvvv"], {"v": "#e2483d", "w": "#f6f0e0"})
def_("zapatilla", ["....b", "bbbbb"], {"b": "#4f7ee0"})
def_("mesiña", ["wwwwww", ".w..w.", ".w..w."], BR)
def_("cesta_manta", [".mmmmmmmm.", "mbbbbbbbbm", "mcmcmcmcmm", ".mmmmmmmm."], {"m": "#c08a4a", "c": "#9a6a34", "b": "#9ec8f0"})
def_("bolsa", [".kk.", "kkkk", "kKkk", "kkkk"], {"k": "#6a4a8a", "K": "#8a6aaa"})

# --- Engadidos para HIS-066…100 --------------------------------------------
def_("coello", [".gg.gg.", ".gg.gg.", ".ggggg.", "ggKggKg", "gggpggg", ".ggggg.", "ggggggg", ".g...g."],
     {"g": "#b9bfc7", "K": "#141220", "p": "#ff9ec0"})
def_("coello_branco", S["coello"][0], {"g": "#f6f6f6", "K": "#141220", "p": "#ff9ec0"})
def_("naranxa", [".g.", "ooo", "oOo", "ooo"], {"o": "#ff9a2a", "O": "#ffc07a", "g": "#5cb84a"})
def_("regadeira", ["b....", "bbbbb", ".bbbbb", ".bbbb."], {"b": "#4f9ee0"})
def_("cabaliño_mar", [".oo.", "oKo.", ".oo.", "..oo", "..o.", ".oo.", "o.o."], {"o": "#ff9a2a", "K": "#141220"})
def_("cangrexo", ["v.....v", "vv...vv", ".vvvvv.", "vKvvvKv", "vvvvvvv", "v.v.v.v"], {"v": "#e2483d", "K": "#141220"})
def_("tartaruga", ["...gg...", ".GGGGGG.", "GgGgGgGgg", ".GGGGGGK.", "g.g..g.g"], {"g": "#5cb84a", "G": "#2f7a3a", "K": "#141220"})
def_("coral", ["p.p.p", "ppppp", ".ppp.", "..p.."], {"p": "#ff7aa8"})
def_("botella", [".k.", ".g.", "ggg", "gGg", "ggg"], {"g": "#5cb84a", "G": "#a6dc6a", "k": "#c08a4a"})
def_("mapa", ["wwwwww", "wvwwbw", "wwgwww", "wbwwvw"], {"w": "#f6f0e0", "v": "#e2483d", "b": "#4f9ee0", "g": "#5cb84a"})
def_("xoaniña", [".kk.", "vkvv", "vvkv", ".vv."], {"v": "#e2483d", "k": "#1e1a24"})
def_("bolboreta", ["bb.bb", "bBbBb", ".bkb.", "bb.bb"], {"b": "#4f9ee0", "B": "#a6d6ff", "k": "#1e1a24"})
def_("porquiño", [".pp..", "ppppp", "pKpPp", "ppppp", ".p.p."], {"p": "#ffb6c8", "P": "#ff8aa8", "K": "#141220"})
def_("galiña", [".v..", "www.", "wKwo", "wwww", ".www", "..o."], {"w": "#f6f6f6", "v": "#e2483d", "K": "#141220", "o": "#ff9a2a"})
def_("burro", ["g.g.......", "g.g.......", "gggg......", "gKgggggggg", ".ggggggggg", ".g.g...g.g"], {"g": "#8a8a94", "K": "#141220"})
def_("maleta", [".kk.", "vvvv", "vVvv", "vvvv"], {"v": "#e2483d", "V": "#ff7a6a", "k": "#5a4a3a"})
def_("maleta_marrón", S["maleta"][0], {"v": "#9a6a34", "V": "#c08a4a", "k": "#5a4a3a"})
def_("billete", ["yyyyy", "ykkyy", "yyyyy"], {"y": "#ffd23a", "k": "#5a4a3a"})
def_("pasaporte", ["bbbb", "byyb", "bbbb"], {"b": "#3f5cc0", "y": "#ffd23a"})
def_("casa_pedra", ["...ss...", ".ssssss.", "ssssssss", "sswwyyss", "sswwyyss", "ssssyyss"],
     {"s": "#8a8494", "w": "#ffe36b", "y": "#7a4a2a"})
def_("tractor", ["..vvv....", "..vwv....", "vvvvvvvv.", "vvvvvvvvv", ".KK....KK", ".KK....KK"], {"v": "#e2483d", "w": "#cfe8f6", "K": "#2a2a2a"})
def_("caldeiro", ["s....s", "ssssss", "sSssss", ".ssss."], {"s": "#8a929c", "S": "#c9d3de"})
def_("cadeira", ["m...", "m...", "mmmm", "m..m", "m..m"], MA)
def_("colmea", [".yyy.", "yYyYy", "yyyyy", "yYKYy", "yyyyy"], {"y": "#e9b050", "Y": "#c08a3a", "K": "#3a2420"})
def_("avión_papel", ["w.....", "www...", "wwwww.", "www...", "w....."], {"w": "#ffffff"})
def_("nenúfar", [".gggg.", "gGggGg", ".gggg."], {"g": "#5cb84a", "G": "#8fd46a"})
def_("papel", ["wwwwwwww", "wwwwwwww", "wwwwwwww", "wwwwwwww", "wwwwwwww"], {"w": "#fdfaf2"})
def_("pincel", ["kmmmmm"], {"k": "#ff9ec0", "m": "#c08a4a"})
def_("botes_pintura", ["yy.gg.vv.bb", "yy.gg.vv.bb"], {"y": "#ffd23a", "g": "#5cb84a", "v": "#e2483d", "b": "#4f9ee0"})
def_("tesoiras", ["b.b", ".k.", "k.k"], {"b": "#4f9ee0", "k": "#8a929c"})
def_("sombreiro", ["..mm..", ".mmmm.", "vvvvvv", "mmmmmm"], {"m": "#e2c08a", "v": "#e2483d"})
def_("sombreiro_explorador", ["..mm..", ".mmmm.", "MMMMMM"], {"m": "#9a6a34", "M": "#7a4a2a"})
def_("coxín", ["vvvvvv", "vVvvVv", "vvvvvv"], {"v": "#ff9ec0", "V": "#ffd0e0"})
def_("cortina", ["bbbb", "bBbb", "bbbb", "bBbb", "bbbb", "bBbb"], {"b": "#4f7ee0", "B": "#8fb6ff"})
def_("lechuga", [".gg.", "gGGg", "gggg"], {"g": "#5cb84a", "G": "#a6dc6a"})
def_("col", [".gggg.", "gGggGg", "gggggg", ".gggg."], {"g": "#4f9e5a", "G": "#8fd49a"})
def_("estación", ["mmmmmmmm", "m......m", "m......m", "mmmmmmmm"], {"m": "#9a6a34"})
def_("farola", [".yy.", ".kk.", "..k.", "..k.", "..k.", "..k.", ".kkk"], {"y": "#ffe36b", "k": "#3a3a44"})
def_("tren_azul", S["tren"][0], {"g": "#3f5cc0", "w": "#ffe36b", "k": "#2a2a2a"})
def_("lanterna", ["yy", "yy", "kk"], {"y": "#ffe36b", "k": "#3a3a44"})
def_("peixe_luz", [".bb.", "bKbb", ".bb."], {"b": "#6ff0d0", "K": "#141220"})


def img(nome, escala=1, espello=False):
    from PIL import Image
    filas, pal = S[nome]
    im = de_reixa(filas, pal, escala)
    return im.transpose(Image.FLIP_LEFT_RIGHT) if espello else im
