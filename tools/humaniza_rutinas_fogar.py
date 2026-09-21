#!/usr/bin/env python3
"""Reescribe las 1.000 rutinas de familia para que suenen a casa, no a folleto.

Frank: «quita eso de que las 1.000 rutinas de familia empiezan por Dr.
Betances, necesito que las rutinas suenen naturales, que empiecen como
empezarían en la casa, calle o escuela de forma habitual».

**Qué había.** Mil rutinas que en realidad eran CINCO, repetidas doscientas
veces cada una, y las cinco idénticas para todas las edades:

    [Hogar · 1.º Curso (0-2 años · 12 a 24 meses)] En la hora del baño:
    Conectar con el cuento "X". Dr. Betances: El agua tibia es el mejor
    espacio sensoriomotriz sin pantallas para liberar tensiones. Sin
    pantallas ni prisas.

Tres cosas mal, y la tercera es la peor: empieza por un corchete de máquina;
lleva una firma personal delante del consejo; y a una criatura de seis años le
dice lo mismo que a una de doce meses —«piel con piel», «canto de cuna»—.

**Qué hay ahora.** Veinticinco rutinas escritas a mano, una por cada cruce de
CINCO MOMENTOS del día con los CINCO CURSOS, en gallego y en castellano. Cada
una empieza donde empieza de verdad —«Antes de salir de casa», «De camino al
cole», «Mientras se prepara la cena»— y el consejo va en la lengua de quien
cría, sin firma. El cuento del día se teje dentro, así que dos rutinas del
mismo momento y el mismo curso no dicen lo mismo en dos semanas distintas.

Se escribe sobre `assets/content/calendario/calendario_dias.json`, que es el
fichero de contenido. El gate `--check` comprueba que no vuelva el corchete ni
la firma y que cada día diga lo que esta tabla dice.

    python3 tools/humaniza_rutinas_fogar.py           # escribe
    python3 tools/humaniza_rutinas_fogar.py --check   # comprueba
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DIAS = ROOT / "assets" / "content" / "calendario" / "calendario_dias.json"

# Los cinco momentos del día. Están los textos que traía el fichero Y los que
# escribe esta herramienta: si solo estuvieran los viejos, la segunda corrida
# no reconocería su propio trabajo y el gate daría rojo para siempre.
MOMENTOS = {
    "Al despertar y antes de salir": "sair",
    "En el momento de la merienda": "merenda",
    "En la hora del baño": "bano",
    "En la preparación de la cena": "cea",
    "Antes de dormir / Canto de cuna": "durmir",
    "Al despertar, antes de salir": "sair",
    "A la hora de la merienda": "merenda",
    "En el baño": "bano",
    "Mientras se prepara la cena": "cea",
    "Antes de dormir": "durmir",
}

# El rótulo del momento, también reescrito: «Antes de dormir / Canto de cuna»
# lleva una barra que nadie dice en voz alta.
ROTULO = {
    "sair": ("Ao espertar, antes de saír", "Al despertar, antes de salir"),
    "merenda": ("Á hora da merenda", "A la hora de la merienda"),
    "bano": ("No baño", "En el baño"),
    "cea": ("Mentres se prepara a cea", "Mientras se prepara la cena"),
    "durmir": ("Antes de durmir", "Antes de dormir"),
}

CURSOS = ["curso_0_2", "curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"]

# Las veinticinco. Cada una: apertura, gesto y porqué, en galego e castelán.
# El «{conto}» se sustituye por el título del cuento de ese día.
#
# El registro sube con la edad a propósito: a los doce meses se nombra y se
# sostiene; a los seis años se explica, se negocia y se inventa un final. Antes
# las cinco edades recibían la misma frase.
RUTINAS: dict[tuple[str, str], dict[str, tuple[str, str, str]]] = {}


def _r(curso, momento, gl, es):
    RUTINAS[(curso, momento)] = {"gl": gl, "es": es}


# ---------------------------------------------------------- 0-2 anos (12-24 m)
_r("curso_0_2", "sair",
   ("Antes de saír da casa, co neno ou a nena en brazos,",
    "nomea o que ides tocando —o abrigo, a porta, a rúa— e repite o saúdo de «{conto}».",
    "A esta idade o contacto e a túa voz calman a despedida moito máis ca calquera explicación."),
   ("Antes de salir de casa, con la criatura en brazos,",
    "nombra lo que vais tocando —el abrigo, la puerta, la calle— y repite el saludo de «{conto}».",
    "A esta edad el contacto y tu voz calman la despedida mucho más que cualquier explicación."))
_r("curso_0_2", "merenda",
   ("Cando sentedes a merendar,",
    "pon o que vai comer diante e di o seu nome mirándoo: «pan», «mazá», como en «{conto}».",
    "Nomear o que está mirando é o que fai que a palabra quede."),
   ("Cuando os sentéis a merendar,",
    "pon delante lo que va a comer y di su nombre mirándolo: «pan», «manzana», como en «{conto}».",
    "Nombrar lo que está mirando es lo que hace que la palabra se quede."))
_r("curso_0_2", "bano",
   ("Na bañeira, coa auga morna,",
    "deixa que chapuza e pon palabra ao que fai: «auga», «pés», «arriba», coas de «{conto}».",
    "A auga solta a tensión do día e deixa as mans libres para tocar e para escoitarte."),
   ("En la bañera, con el agua templada,",
    "deja que chapotee y pon palabra a lo que hace: «agua», «pies», «arriba», con las de «{conto}».",
    "El agua suelta la tensión del día y deja las manos libres para tocar y para escucharte."))
_r("curso_0_2", "cea",
   ("Mentres preparas a cea, co pequeno ou a pequena preto,",
    "vaille contando o que fas e déixalle tocar unha culler mentres repites unha palabra de «{conto}».",
    "Oír a fala do adulto mentres pasa algo diante é o que máis vocabulario deixa a esta idade."),
   ("Mientras preparas la cena, con la criatura cerca,",
    "ve contándole lo que haces y déjale tocar una cuchara mientras repites una palabra de «{conto}».",
    "Oír hablar al adulto mientras pasa algo delante es lo que más vocabulario deja a esta edad."))
_r("curso_0_2", "durmir",
   ("Coa luz baixa e xa no colo,",
    "cántalle sempre a mesma canción e remata nomeando o de «{conto}».",
    "A mesma canción todas as noites avisa ao corpo de que chega o sono, e iso axuda a durmir mellor."),
   ("Con la luz baja y ya en brazos,",
    "cántale siempre la misma canción y termina nombrando lo de «{conto}».",
    "La misma canción todas las noches avisa al cuerpo de que llega el sueño, y eso ayuda a dormir mejor."))

# ------------------------------------------------------------------- 2-3 anos
_r("curso_2_3", "sair",
   ("De camiño á escola,",
    "pregúntalle que ve pola rúa e agarda: coche, can, porta. Se aparece algo de «{conto}», nomeádeo xuntos.",
    "Agardar tres segundos despois de preguntar é o que lle dá tempo a dicir a palabra."),
   ("De camino a la escuela,",
    "pregúntale qué ve por la calle y espera: coche, perro, puerta. Si aparece algo de «{conto}», nombradlo juntos.",
    "Esperar tres segundos después de preguntar es lo que le da tiempo a decir la palabra."))
_r("curso_2_3", "merenda",
   ("Á hora da merenda,",
    "ofrécelle dúas cousas e que escolla dicindo o nome: «mazá ou pan?». Despois, unha palabra de «{conto}».",
    "Escoller entre dúas obriga a falar, e falar por algo que quere é o que mellor funciona."),
   ("A la hora de la merienda,",
    "ofrécele dos cosas y que elija diciendo el nombre: «¿manzana o pan?». Después, una palabra de «{conto}».",
    "Elegir entre dos obliga a hablar, y hablar por algo que quiere es lo que mejor funciona."))
_r("curso_2_3", "bano",
   ("No baño,",
    "xogade a esconder e atopar un boneco debaixo da escuma e dicide «aquí está!», como en «{conto}».",
    "Repetir a mesma frase nun xogo que se repite é como se aprende unha expresión enteira."),
   ("En el baño,",
    "jugad a esconder y encontrar un muñeco debajo de la espuma y decid «¡aquí está!», como en «{conto}».",
    "Repetir la misma frase en un juego que se repite es como se aprende una expresión entera."))
_r("curso_2_3", "cea",
   ("Mentres se prepara a cea,",
    "dálle unha tarefa de verdade —levar os pratos, contar as culleres— e nomeade o que hai, coma en «{conto}».",
    "Contar cousas reais mentres se colocan crea a idea de número sen que pareza unha lección."),
   ("Mientras se prepara la cena,",
    "dale una tarea de verdad —llevar los platos, contar las cucharas— y nombrad lo que hay, como en «{conto}».",
    "Contar cosas reales mientras se colocan crea la idea de número sin que parezca una lección."))
_r("curso_2_3", "durmir",
   ("Xa na cama,",
    "conta «{conto}» coas mesmas palabras de sempre e deixa que remate el ou ela as últimas.",
    "Deixar o final da frase sen dicir é un convite a falar que case nunca se rexeita."),
   ("Ya en la cama,",
    "cuenta «{conto}» con las mismas palabras de siempre y deja que termine ella las últimas.",
    "Dejar el final de la frase sin decir es una invitación a hablar que casi nunca se rechaza."))

# ------------------------------------------------------------------- 3-4 anos
_r("curso_3_4", "sair",
   ("Camiño da escola,",
    "pídelle que che conte que vai facer hoxe, e recórdalle unha cousa de «{conto}».",
    "Poñer en palabras o que aínda non pasou é o primeiro paso para falar de algo que non está diante."),
   ("Camino de la escuela,",
    "pídele que te cuente qué va a hacer hoy, y recuérdale una cosa de «{conto}».",
    "Poner en palabras lo que todavía no ha pasado es el primer paso para hablar de algo que no está delante."))
_r("curso_3_4", "merenda",
   ("Sentados a merendar,",
    "pregúntalle «que pasou primeiro?» sobre «{conto}» e escoita sen corrixir.",
    "Ordenar dous feitos seguidos é o que sostén despois calquera relato máis longo."),
   ("Sentados a merendar,",
    "pregúntale «¿qué pasó primero?» sobre «{conto}» y escucha sin corregir.",
    "Ordenar dos hechos seguidos es lo que sostiene después cualquier relato más largo."))
_r("curso_3_4", "bano",
   ("No baño,",
    "que che explique o que fai mentres o fai: «lavo os pés», «aclaro o pelo», coas palabras de «{conto}».",
    "Falar do que fan as mans mentres as mans o fan é o xeito máis fácil de alongar unha frase."),
   ("En el baño,",
    "que te explique lo que hace mientras lo hace: «me lavo los pies», «me aclaro el pelo», con las palabras de «{conto}».",
    "Hablar de lo que hacen las manos mientras las manos lo hacen es la forma más fácil de alargar una frase."))
_r("curso_3_4", "cea",
   ("Mentres poñedes a mesa,",
    "repartide as tarefas en voz alta e comparade: «cantos pratos faltan?», como fixestes con «{conto}».",
    "Comparar cantidades con cousas que se tocan vale máis ca calquera ficha de números."),
   ("Mientras ponéis la mesa,",
    "repartid las tareas en voz alta y comparad: «¿cuántos platos faltan?», como hicisteis con «{conto}».",
    "Comparar cantidades con cosas que se tocan vale más que cualquier ficha de números."))
_r("curso_3_4", "durmir",
   ("Coa luz xa baixa,",
    "volvede contar «{conto}», pero que o conte el ou ela, e ti só preguntas «e despois?».",
    "Contar a historia coas súas palabras é o que mostra de verdade o que entendeu."),
   ("Con la luz ya baja,",
    "volved a contar «{conto}», pero que lo cuente ella, y tú solo preguntas «¿y después?».",
    "Contar la historia con sus palabras es lo que muestra de verdad lo que ha entendido."))

# ------------------------------------------------------------------- 4-5 anos
_r("curso_4_5", "sair",
   ("Na porta, antes de saír,",
    "acordade unha cousa para contar á volta, e que teña que ver con «{conto}».",
    "Saber que despois haberá que contalo é o que fai que se fixe no que pasa."),
   ("En la puerta, antes de salir,",
    "acordad una cosa para contar a la vuelta, y que tenga que ver con «{conto}».",
    "Saber que después habrá que contarlo es lo que hace que se fije en lo que pasa."))
_r("curso_4_5", "merenda",
   ("Á volta, merendando,",
    "que che conte o día enteiro por orde: primeiro, despois e ao final, coma en «{conto}».",
    "Contar o día en orde é exactamente o que despois lle vai pedir a escola ao escribir."),
   ("A la vuelta, merendando,",
    "que te cuente el día entero por orden: primero, después y al final, como en «{conto}».",
    "Contar el día en orden es exactamente lo que después le va a pedir la escuela al escribir."))
_r("curso_4_5", "bano",
   ("No baño,",
    "xogade a adiviñar: describes algo de «{conto}» sen nomealo e ten que acertar, e despois ao revés.",
    "Describir sen nomear obriga a buscar palabras novas, que é como medra o vocabulario."),
   ("En el baño,",
    "jugad a adivinar: describes algo de «{conto}» sin nombrarlo y tiene que acertar, y luego al revés.",
    "Describir sin nombrar obliga a buscar palabras nuevas, que es como crece el vocabulario."))
_r("curso_4_5", "cea",
   ("Mentres se fai a cea,",
    "que che dite a receita paso a paso como se ti non soubeses, e usade o vocabulario de «{conto}».",
    "Explicarlle algo a alguén que «non sabe» é o exercicio de linguaxe máis completo que hai na casa."),
   ("Mientras se hace la cena,",
    "que te dicte la receta paso a paso como si tú no supieras, y usad el vocabulario de «{conto}».",
    "Explicarle algo a alguien que «no sabe» es el ejercicio de lenguaje más completo que hay en casa."))
_r("curso_4_5", "durmir",
   ("Antes de apagar a luz,",
    "inventade outro final para «{conto}» e que o conte el ou ela enteiro.",
    "Inventar un final obriga a manter a historia na cabeza mentres se lle cambia unha peza."),
   ("Antes de apagar la luz,",
    "inventad otro final para «{conto}» y que lo cuente ella entero.",
    "Inventar un final obliga a mantener la historia en la cabeza mientras se le cambia una pieza."))

# ------------------------------------------------------------------- 5-6 anos
_r("curso_5_6", "sair",
   ("De camiño ao colexio,",
    "pregúntalle que pensa que vai pasar hoxe e por que, e liga algo con «{conto}».",
    "Dicir «por que» en voz alta é o paso que separa contar do explicar."),
   ("De camino al colegio,",
    "pregúntale qué cree que va a pasar hoy y por qué, y liga algo con «{conto}».",
    "Decir «por qué» en voz alta es el paso que separa contar de explicar."))
_r("curso_5_6", "merenda",
   ("Merendando, á volta,",
    "que che conte algo que pasou entre compañeiros e como o resolveron, e comparádeo con «{conto}».",
    "Poñer nome ao que sentiu outra persoa é a base de entenderse na clase e fóra dela."),
   ("Merendando, a la vuelta,",
    "que te cuente algo que pasó entre compañeros y cómo lo resolvieron, y comparadlo con «{conto}».",
    "Poner nombre a lo que sintió otra persona es la base de entenderse en clase y fuera de ella."))
_r("curso_5_6", "bano",
   ("No baño,",
    "xogade coas palabras de «{conto}»: buscade outra que empece igual, ou unha que rime.",
    "Xogar co son das palabras, sen papel, é o que prepara a lectura de verdade."),
   ("En el baño,",
    "jugad con las palabras de «{conto}»: buscad otra que empiece igual, o una que rime.",
    "Jugar con el sonido de las palabras, sin papel, es lo que prepara la lectura de verdad."))
_r("curso_5_6", "cea",
   ("Mentres se prepara a cea,",
    "que organice el ou ela a mesa e explique en voz alta como o repartiu, usando o de «{conto}».",
    "Decidir e xustificar unha decisión é o que máis se parece ao traballo por proxectos da escola."),
   ("Mientras se prepara la cena,",
    "que organice ella la mesa y explique en voz alta cómo lo ha repartido, usando lo de «{conto}».",
    "Decidir y justificar una decisión es lo que más se parece al trabajo por proyectos de la escuela."))
_r("curso_5_6", "durmir",
   ("Xa na cama,",
    "lede xuntos un anaco de «{conto}»: unha liña ti e outra el ou ela.",
    "Ler por quendas mantén o gusto pola historia mentres se practica sen que pese."),
   ("Ya en la cama,",
    "leed juntos un trozo de «{conto}»: una línea tú y otra ella.",
    "Leer por turnos mantiene el gusto por la historia mientras se practica sin que pese."))

# La frase que explica por qué esto enlaza con la escuela. Una por curso: es lo
# que cambia de verdad entre los cinco, no el momento del día.
CONEXION = {
    "curso_0_2": (
        "Na escola hoxe traballouse «{conto}» na asemblea. Repetir na casa o "
        "mesmo saúdo e as mesmas palabras fai que a criatura recoñeza mañá o "
        "que xa coñece, e iso é o que dá seguridade a esta idade.",
        "En la escuela hoy se ha trabajado «{conto}» en la asamblea. Repetir "
        "en casa el mismo saludo y las mismas palabras hace que reconozca "
        "mañana lo que ya conoce, y eso es lo que da seguridad a esta edad."),
    "curso_2_3": (
        "«{conto}» é o conto desta semana na escola. Se as palabras volven "
        "aparecer na casa, deixan de ser da aula e pasan a ser súas.",
        "«{conto}» es el cuento de esta semana en la escuela. Si las palabras "
        "vuelven a aparecer en casa, dejan de ser del aula y pasan a ser "
        "suyas."),
    "curso_3_4": (
        "Na escola contouse «{conto}» e pediuse que o contasen de volta. "
        "Facelo tamén na casa, sen présa e sen corrixir, é o que máis alonga "
        "as frases a esta idade.",
        "En la escuela se ha contado «{conto}» y se ha pedido que lo contaran "
        "de vuelta. Hacerlo también en casa, sin prisa y sin corregir, es lo "
        "que más alarga las frases a esta edad."),
    "curso_4_5": (
        "«{conto}» traballouse hoxe na aula ordenando o que pasa primeiro e "
        "despois. Contar o día na casa coa mesma orde é a mesma competencia, "
        "practicada onde non hai que levantar a man.",
        "«{conto}» se ha trabajado hoy en el aula ordenando lo que pasa "
        "primero y después. Contar el día en casa con el mismo orden es la "
        "misma competencia, practicada donde no hay que levantar la mano."),
    "curso_5_6": (
        "Na escola usouse «{conto}» para escoitarse e chegar a acordos. Na "
        "casa iso mesmo faise explicando por que, e é o que máis vai servir "
        "no primeiro curso de primaria.",
        "En la escuela se ha usado «{conto}» para escucharse y llegar a "
        "acuerdos. En casa eso mismo se hace explicando por qué, y es lo que "
        "más va a servir en el primer curso de primaria."),
}

_TITULO = re.compile(r'"([^"]+)"')


def titulo_do_conto(dia: dict, lingua: str) -> str:
    """El título del cuento del día, EN SU LENGUA.

    Sale de `profesorado.actividadAula`, que es el campo que lo trae entre
    comillas en gallego y en castellano. Leerlo siempre del castellano dejaba
    la rutina gallega citando un título en castellano, que es justo el tipo de
    mezcla que una familia de Vigo nota a la primera.
    """
    for lado, campo in (("profesorado", "actividadAula"),
                        ("familias", "rutinaFogar")):
        texto = ((dia.get(lado) or {}).get(campo) or {}).get(lingua, "")
        m = _TITULO.search(texto)
        if m:
            return m.group(1).strip()
    tema = (dia.get("temaDia") or {}).get(lingua, "")
    return tema.split("·")[0].strip()


def curso_do_dia(dia: dict) -> str:
    clave = str(dia.get("fechaClave", ""))
    for c in CURSOS:
        if clave.startswith(c):
            return c
    return CURSOS[0]


def textos(dia: dict) -> dict[str, dict[str, str]]:
    """Los cuatro textos de familia de ese día, en las dos lenguas."""
    curso = curso_do_dia(dia)
    momento_es = ((dia.get("familias") or {}).get("momento") or {}).get("es", "")
    clave = MOMENTOS.get(momento_es)
    if clave is None:
        return {}

    fila = RUTINAS[(curso, clave)]
    saida: dict[str, dict[str, str]] = {
        "rutinaFogar": {}, "consignaFamilia": {}, "momento": {},
        "fraseConexion": {},
    }
    for i, lingua in enumerate(("gl", "es")):
        conto = titulo_do_conto(dia, lingua)
        apertura, gesto, porque = fila[lingua]
        gesto = gesto.replace("{conto}", conto)
        saida["rutinaFogar"][lingua] = f"{apertura} {gesto} {porque}"
        saida["consignaFamilia"][lingua] = porque
        saida["momento"][lingua] = ROTULO[clave][i]
        saida["fraseConexion"][lingua] = (
            CONEXION[curso][i].replace("{conto}", conto))
    return saida


def aplicar(dias: list[dict]) -> int:
    cambios = 0
    for dia in dias:
        novo = textos(dia)
        if not novo:
            continue
        familias = dia.setdefault("familias", {})
        for campo, valores in novo.items():
            if familias.get(campo) != valores:
                cambios += 1
            familias[campo] = valores
    return cambios


def main() -> int:
    dias = json.loads(DIAS.read_text(encoding="utf-8"))
    comprobar = "--check" in sys.argv

    fallos = []
    if comprobar:
        for dia in dias:
            novo = textos(dia)
            familias = dia.get("familias") or {}
            if not novo:
                fallos.append(
                    f"{dia.get('fechaClave')}: momento descoñecido "
                    f"«{(familias.get('momento') or {}).get('es', '')}»")
                continue
            for campo, valores in novo.items():
                if familias.get(campo) != valores:
                    fallos.append(f"{dia.get('fechaClave')}: {campo} non está ao día")
        # Lo que nunca puede volver.
        cru = DIAS.read_text(encoding="utf-8")
        if "Dr. Betances" in cru:
            fallos.append("segue habendo «Dr. Betances» no ficheiro")
        for dia in dias:
            for lingua in ("gl", "es"):
                t = ((dia.get("familias") or {}).get("rutinaFogar") or {}).get(lingua, "")
                if t.startswith("["):
                    fallos.append(f"{dia.get('fechaClave')}: a rutina aínda empeza por [")
        if fallos:
            print(f"As rutinas de familia non están ao día ({len(fallos)} problemas). "
                  f"Os cinco primeiros:")
            for f in fallos[:5]:
                print("  ·", f)
            print("Corre: python3 tools/humaniza_rutinas_fogar.py")
            return 1
        print(f"OK: {len(dias)} días, as rutinas de familia din o que ten que dicir "
              f"a táboa de 25 e ningunha leva sinatura nin corchete.")
        return 0

    cambios = aplicar(dias)
    DIAS.write_text(
        json.dumps(dias, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"OK: {len(dias)} días · {cambios} textos reescritos "
          f"({len(RUTINAS)} rutinas a man × 2 linguas).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
