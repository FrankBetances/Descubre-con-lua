#!/usr/bin/env python3
"""Genera la progresión DIARIA de la asamblea: 4 semanas x 5 días por tramo.

Por qué existe. Los dos documentos curriculares dan, para cada mes, UNA
microcápsula por grupo: el centro de interés, el material, la canción y hasta
tres órdenes en inglés. Frank lo dijo con estas palabras: «las asambleas deben
ser distintas cada día; es posible que mantengan una misma temática durante
varios días, pero no puede ser la misma un mes completo».

Lo que se hace aquí es escalonar ESE contenido del mes a lo largo de sus
veinte días lectivos. La temática, el material, la canción y las órdenes
siguen siendo las del documento; lo que cambia cada día es QUÉ órdenes se
trabajan, CÓMO se presentan y qué se le pide al grupo:

  Semana 1 · Descubrir   una orden nueva cada vez, con modelado completo
  Semana 2 · Practicar   la tercera orden, y las tres con canción y material
  Semana 3 · Combinar    series, cambio de ritmo, historia, cambio de papel
  Semana 4 · Consolidar  sin modelo (fading), otro espacio, ensayo para casa

Es la progresión clásica del método TPR —escuchar y ver, actuar con modelo,
actuar sin modelo, combinar— que el documento de 2.º ciclo nombra como
«modelado sincrónico, fading y guía entre iguales», y que en 1.º ciclo se
traduce a colo y contacto (0-2) o movimiento en grupo (2-3). Lo que NO viene
del documento es el reparto día a día: eso es una propuesta de escalonamiento
y así se dice en el campo `nota` de cada fichero.

Un fichero por tramo, porque la consigna de «sin modelo» no puede decir lo
mismo a un bebé de un año que a una clase de 6.º. Las consignas se graban con
la voz neuronal como el resto del contenido (tools/voice_corpus.py las lee).

Uso:  python3 tools/gen_progresion_diaria.py
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "content" / "progresion"

SEMANAS = [
    (1, "Descubrir", "Descubrir",
     "Unha orde nova cada vez, con modelado completo.",
     "Una orden nueva cada vez, con modelado completo."),
    (2, "Practicar", "Practicar",
     "As tres ordes do mes, con canción e con material.",
     "Las tres órdenes del mes, con canción y con material."),
    (3, "Combinar", "Combinar",
     "Series, cambio de ritmo, historia e cambio de papel.",
     "Series, cambio de ritmo, historia y cambio de papel."),
    (4, "Consolidar", "Consolidar",
     "Sen modelo, noutro espazo e ensaio para as casas.",
     "Sin modelo, en otro espacio y ensayo para casa."),
]

DIAS = [
    (1, "Luns", "Lunes"),
    (2, "Martes", "Martes"),
    (3, "Mércores", "Miércoles"),
    (4, "Xoves", "Jueves"),
    (5, "Venres", "Viernes"),
]

# El patrón común: (semana, día) -> (índices de orden, modo).
# Los índices apuntan a comandosL3 de la fase núcleo del mes. Si el mes tiene
# menos órdenes, la app recorta los índices que no existan.
PATRON = {
    (1, 1): ([0], "novo"),
    (1, 2): ([0], "material"),
    (1, 3): ([1], "novo"),
    (1, 4): ([0, 1], "combinar"),
    (1, 5): ([0, 1], "cancion"),
    (2, 1): ([2], "novo"),
    (2, 2): ([1, 2], "combinar"),
    (2, 3): ([0, 1, 2], "cancion"),
    (2, 4): ([0, 1, 2], "material"),
    (2, 5): ([0, 1, 2], "elixir"),
    (3, 1): ([0, 1], "serie"),
    (3, 2): ([1, 2], "ritmo"),
    (3, 3): ([0, 1, 2], "historia"),
    (3, 4): ([0, 1, 2], "rol"),
    (3, 5): ([0, 1, 2], "cancion"),
    (4, 1): ([0, 1, 2], "senModelo"),
    (4, 2): ([0, 1, 2], "contexto"),
    (4, 3): ([0, 1, 2], "cancion"),
    (4, 4): ([0, 1, 2], "familias"),
    (4, 5): ([0, 1, 2], "festa"),
}

# Por tramo: (semana, día) -> (foco gl, foco es, consigna gl, consigna es).
TEXTOS: dict[str, dict[tuple[int, int], tuple[str, str, str, str]]] = {}

TEXTOS["primeiro_ciclo.0_2"] = {
    (1, 1): ("A primeira orde, no colo", "La primera orden, en el regazo",
             "Presenta a primeira orde no colo, unha vez por bebé. Di a palabra e fai ti o xesto coas súas mans. Non pidas nada.",
             "Presenta la primera orden en el regazo, una vez por bebé. Di la palabra y haz tú el gesto con sus manos. No pidas nada."),
    (1, 2): ("A mesma orde, co material", "La misma orden, con el material",
             "Repite a orde de onte co material do mes na man. O obxecto atrae a mirada; a palabra vai co xesto.",
             "Repite la orden de ayer con el material del mes en la mano. El objeto atrae la mirada; la palabra va con el gesto."),
    (1, 3): ("A segunda orde, no colo", "La segunda orden, en el regazo",
             "Hoxe só a segunda orde. Mesma calma: palabra, xesto guiado e sorriso. Se un bebé se aparta, para.",
             "Hoy solo la segunda orden. Misma calma: palabra, gesto guiado y sonrisa. Si un bebé se aparta, para."),
    (1, 4): ("As dúas ordes, unha tras outra", "Las dos órdenes, una tras otra",
             "Encadea as dúas ordes con cada bebé, amodo. Deixa un silencio entre unha e outra para que a mirada volva a ti.",
             "Encadena las dos órdenes con cada bebé, despacio. Deja un silencio entre una y otra para que la mirada vuelva a ti."),
    (1, 5): ("As dúas ordes, coa canción", "Las dos órdenes, con la canción",
             "Canta a canción do mes e mete as dúas ordes onde caen no ritmo. O pulso vese na túa man, non se oe.",
             "Canta la canción del mes y mete las dos órdenes donde caen en el ritmo. El pulso se ve en tu mano, no se oye."),
    (2, 1): ("A terceira orde, no colo", "La tercera orden, en el regazo",
             "Presenta a terceira orde igual que as outras: no colo, palabra e xesto guiado. Se o mes só ten dúas, repasa a segunda.",
             "Presenta la tercera orden igual que las otras: en el regazo, palabra y gesto guiado. Si el mes solo tiene dos, repasa la segunda."),
    (2, 2): ("Segunda e terceira, seguidas", "Segunda y tercera, seguidas",
             "Encadea a segunda e a terceira orde. Cambia de bebé cada vez; o grupo mira mentres agarda.",
             "Encadena la segunda y la tercera orden. Cambia de bebé cada vez; el grupo mira mientras espera."),
    (2, 3): ("As tres ordes, coa canción", "Las tres órdenes, con la canción",
             "Canción enteira coas tres ordes dentro. Mantén o contacto corporal: o bebé aprende polo teu movemento, non polo teu pedido.",
             "Canción entera con las tres órdenes dentro. Mantén el contacto corporal: el bebé aprende por tu movimiento, no por tu petición."),
    (2, 4): ("As tres ordes, co material", "Las tres órdenes, con el material",
             "As tres ordes co material do mes. Deixa que o bebé o toque despois de cada orde: é o premio.",
             "Las tres órdenes con el material del mes. Deja que el bebé lo toque después de cada orden: es el premio."),
    (2, 5): ("Segue o que o bebé fai", "Sigue lo que el bebé hace",
             "Hoxe vas detrás do bebé: cando faga un xesto parecido a unha orde, di a palabra e celébrao. Nada de corrixir.",
             "Hoy vas detrás del bebé: cuando haga un gesto parecido a una orden, di la palabra y celébralo. Nada de corregir."),
    (3, 1): ("Dúas ordes nun só xesto", "Dos órdenes en un solo gesto",
             "Une a primeira e a segunda orde nun movemento continuo, sen pausa. Primeiro amodo, logo un pouco máis lixeiro.",
             "Une la primera y la segunda orden en un movimiento continuo, sin pausa. Primero despacio, luego un poco más ligero."),
    (3, 2): ("Amodo e lixeiro", "Despacio y rápido",
             "Segunda e terceira orde: unha vez moi amodo, unha vez lixeira. O contraste é o xogo; a risa di que funciona.",
             "Segunda y tercera orden: una vez muy despacio, una vez rápida. El contraste es el juego; la risa dice que funciona."),
    (3, 3): ("A historia da lámina", "La historia de la lámina",
             "Ensina a lámina do mes e conta en tres frases o que pasa. Cada orde entra na historia como un xesto do protagonista.",
             "Enseña la lámina del mes y cuenta en tres frases lo que pasa. Cada orden entra en la historia como un gesto del protagonista."),
    (3, 4): ("Cambio de par", "Cambio de pareja",
             "Se hai outra persoa adulta, cada bebé pasa dun colo a outro entre orde e orde. Se non, cambia ti de bebé máis a miúdo.",
             "Si hay otra persona adulta, cada bebé pasa de un regazo a otro entre orden y orden. Si no, cambia tú de bebé más a menudo."),
    (3, 5): ("Repaso coa canción", "Repaso con la canción",
             "Canción do mes coas tres ordes. Fíxate en que bebé anticipa o xesto antes da palabra: ese xa a ten.",
             "Canción del mes con las tres órdenes. Fíjate en qué bebé anticipa el gesto antes de la palabra: ese ya la tiene."),
    (4, 1): ("Só a voz e un toque", "Solo la voz y un toque",
             "Di a orde e toca a parte do corpo que se move, sen guiar o xesto enteiro. Se non sae, guía e segue sen comentario.",
             "Di la orden y toca la parte del cuerpo que se mueve, sin guiar el gesto entero. Si no sale, guía y sigue sin comentario."),
    (4, 2): ("Noutro sitio", "En otro sitio",
             "As tres ordes fóra da alfombra: no cambiador, na cadeira ou no patio. A palabra ten que valer en calquera sitio.",
             "Las tres órdenes fuera de la alfombra: en el cambiador, en la silla o en el patio. La palabra tiene que valer en cualquier sitio."),
    (4, 3): ("Canción enteira, ao seu ritmo", "Canción entera, a su ritmo",
             "Canción completa coas tres ordes, ao ritmo do mes. Hoxe non paras entre estrofas: é a sesión enteira seguida.",
             "Canción completa con las tres órdenes, al ritmo del mes. Hoy no paras entre estrofas: es la sesión entera seguida."),
    (4, 4): ("Ensaio para as casas", "Ensayo para casa",
             "Fai a sesión tal e como a farán as familias: sen material especial, en dous minutos. É o que levan na nota.",
             "Haz la sesión tal y como la harán las familias: sin material especial, en dos minutos. Es lo que se llevan en la nota."),
    (4, 5): ("Peche do mes, con calma", "Cierre del mes, con calma",
             "Última vez do mes: as tres ordes, a canción e unha aperta longa a cada bebé. Remata máis amodo do que empezaches.",
             "Última vez del mes: las tres órdenes, la canción y un abrazo largo a cada bebé. Termina más despacio de lo que empezaste."),
}

TEXTOS["primeiro_ciclo.2_3"] = {
    (1, 1): ("A primeira orde, en círculo", "La primera orden, en círculo",
             "Presenta a primeira orde en círculo. Dila e faina ti tres veces; o grupo mira. Ninguén ten que repetila.",
             "Presenta la primera orden en círculo. Dila y hazla tú tres veces; el grupo mira. Nadie tiene que repetirla."),
    (1, 2): ("A mesma orde, co material", "La misma orden, con el material",
             "Repite a orde de onte co material do mes. Cada crianza que quere fai o xesto co obxecto na man; as demais miran.",
             "Repite la orden de ayer con el material del mes. Cada criatura que quiere hace el gesto con el objeto en la mano; las demás miran."),
    (1, 3): ("A segunda orde, en círculo", "La segunda orden, en círculo",
             "Hoxe só a segunda orde. Mesmo esquema: dila, faina, agarda. Se alguén a imita, di a palabra outra vez e sorrí.",
             "Hoy solo la segunda orden. Mismo esquema: dila, hazla, espera. Si alguien la imita, di la palabra otra vez y sonríe."),
    (1, 4): ("As dúas ordes, xuntas", "Las dos órdenes, juntas",
             "Primeira e segunda orde seguidas, con pausa entre elas. Faino ti con todo o corpo; o grupo segue o que pode.",
             "Primera y segunda orden seguidas, con pausa entre ellas. Hazlo tú con todo el cuerpo; el grupo sigue lo que puede."),
    (1, 5): ("As dúas ordes, coa canción", "Las dos órdenes, con la canción",
             "Canta a canción do mes e fai as dúas ordes onde caen no ritmo. O pulso márcase coa man, á vista; non se oe.",
             "Canta la canción del mes y haz las dos órdenes donde caen en el ritmo. El pulso se marca con la mano, a la vista; no se oye."),
    (2, 1): ("A terceira orde, en círculo", "La tercera orden, en círculo",
             "Presenta a terceira orde. Se o mes só ten dúas, hoxe repasa a segunda con outro material.",
             "Presenta la tercera orden. Si el mes solo tiene dos, hoy repasa la segunda con otro material."),
    (2, 2): ("Segunda e terceira, seguidas", "Segunda y tercera, seguidas",
             "Encadea a segunda e a terceira orde. Cambia a orde de aparición unha vez: o grupo escoita, non memoriza.",
             "Encadena la segunda y la tercera orden. Cambia el orden de aparición una vez: el grupo escucha, no memoriza."),
    (2, 3): ("As tres ordes, coa canción", "Las tres órdenes, con la canción",
             "Canción enteira coas tres ordes dentro. Ti segues facendo todo o movemento: aínda non é hora de deixar de modelar.",
             "Canción entera con las tres órdenes dentro. Tú sigues haciendo todo el movimiento: aún no es hora de dejar de modelar."),
    (2, 4): ("As tres ordes, co material", "Las tres órdenes, con el material",
             "As tres ordes co material do mes. O obxecto pasa de man en man: quen o ten, fai; o resto mira.",
             "Las tres órdenes con el material del mes. El objeto pasa de mano en mano: quien lo tiene, hace; el resto mira."),
    (2, 5): ("O grupo elixe", "El grupo elige",
             "Fai as tres ordes e deixa que unha crianza sinale cal repetimos. Non fai falta que a diga: co xesto abonda.",
             "Haz las tres órdenes y deja que una criatura señale cuál repetimos. No hace falta que la diga: con el gesto basta."),
    (3, 1): ("Dúas ordes seguidas, sen pausa", "Dos órdenes seguidas, sin pausa",
             "Une a primeira e a segunda orde nunha soa serie, sen parar entre elas. Primeiro moi amodo; despois ao ritmo normal.",
             "Une la primera y la segunda orden en una sola serie, sin parar entre ellas. Primero muy despacio; después al ritmo normal."),
    (3, 2): ("Amodo e lixeiro", "Despacio y rápido",
             "Segunda e terceira orde: unha rolda moi amodo, outra lixeira. O contraste fai rir e fai escoitar.",
             "Segunda y tercera orden: una ronda muy despacio, otra rápida. El contraste hace reír y hace escuchar."),
    (3, 3): ("A historia da lámina", "La historia de la lámina",
             "Ensina a lámina do mes e conta en tres frases o que pasa. Cada orde é un xesto do protagonista; o grupo fai o xesto.",
             "Enseña la lámina del mes y cuenta en tres frases lo que pasa. Cada orden es un gesto del protagonista; el grupo hace el gesto."),
    (3, 4): ("Unha crianza fai de mestra", "Una criatura hace de maestra",
             "Unha crianza ponse ao teu lado e fai o xesto contigo mentres ti dis a orde. Cambia de crianza en cada orde.",
             "Una criatura se pone a tu lado y hace el gesto contigo mientras tú dices la orden. Cambia de criatura en cada orden."),
    (3, 5): ("Repaso coa canción", "Repaso con la canción",
             "Canción do mes coas tres ordes. Fíxate en quen anticipa o xesto antes da palabra: esas xa a teñen.",
             "Canción del mes con las tres órdenes. Fíjate en quién anticipa el gesto antes de la palabra: esas ya la tienen."),
    (4, 1): ("Só a voz", "Solo la voz",
             "Di a orde e non fagas o xesto. Conta ata tres en silencio. Se ninguén a fai, faina ti e segue sen comentario.",
             "Di la orden y no hagas el gesto. Cuenta hasta tres en silencio. Si nadie la hace, hazla tú y sigue sin comentario."),
    (4, 2): ("Noutro sitio", "En otro sitio",
             "As tres ordes fóra da alfombra: no corredor, no patio ou de camiño ao comedor. A palabra vale en calquera sitio.",
             "Las tres órdenes fuera de la alfombra: en el pasillo, en el patio o de camino al comedor. La palabra vale en cualquier sitio."),
    (4, 3): ("Canción enteira, ao ritmo", "Canción entera, al ritmo",
             "Canción completa coas tres ordes, ao ritmo do mes e sen parar entre estrofas. É a sesión enteira seguida.",
             "Canción completa con las tres órdenes, al ritmo del mes y sin parar entre estrofas. Es la sesión entera seguida."),
    (4, 4): ("Ensaio para as casas", "Ensayo para casa",
             "Fai a sesión como a farán as familias: sen material especial, en dous minutos, na cociña. É o que levan na nota.",
             "Haz la sesión como la harán las familias: sin material especial, en dos minutos, en la cocina. Es lo que se llevan en la nota."),
    (4, 5): ("Peche do mes, con calma", "Cierre del mes, con calma",
             "Última vez do mes: as tres ordes, a canción e a despedida en círculo. Remata máis amodo do que empezaches.",
             "Última vez del mes: las tres órdenes, la canción y la despedida en círculo. Termina más despacio de lo que empezaste."),
}

TEXTOS["segundo_ciclo.4"] = {
    (1, 1): ("A primeira orde, con modelado", "La primera orden, con modelado",
             "Presenta a primeira orde: dila e faina á vez, tres veces. A clase mira. Aínda non lle pidas que a faga.",
             "Presenta la primera orden: dila y hazla a la vez, tres veces. La clase mira. Aún no le pidas que la haga."),
    (1, 2): ("A mesma orde, co material", "La misma orden, con el material",
             "Repite a orde de onte co material do mes. Quen queira faina contigo; quen non, mira. Modelas todo o tempo.",
             "Repite la orden de ayer con el material del mes. Quien quiera la hace contigo; quien no, mira. Modelas todo el tiempo."),
    (1, 3): ("A segunda orde, con modelado", "La segunda orden, con modelado",
             "Hoxe só a segunda orde, co mesmo esquema: dila, faina, agarda. Cada orde nova ten o seu día.",
             "Hoy solo la segunda orden, con el mismo esquema: dila, hazla, espera. Cada orden nueva tiene su día."),
    (1, 4): ("As dúas ordes, xuntas", "Las dos órdenes, juntas",
             "Primeira e segunda orde seguidas, con pausa entre elas. Ti modelas as dúas; a clase fai o que pode.",
             "Primera y segunda orden seguidas, con pausa entre ellas. Tú modelas las dos; la clase hace lo que puede."),
    (1, 5): ("As dúas ordes, coa canción", "Las dos órdenes, con la canción",
             "Canción do mes coas dúas ordes onde caen no ritmo. O pulso vese na túa man; non se oe.",
             "Canción del mes con las dos órdenes donde caen en el ritmo. El pulso se ve en tu mano; no se oye."),
    (2, 1): ("A terceira orde, con modelado", "La tercera orden, con modelado",
             "Presenta a terceira orde igual que as outras. Se o mes só ten dúas, repasa a segunda con outro xesto.",
             "Presenta la tercera orden igual que las otras. Si el mes solo tiene dos, repasa la segunda con otro gesto."),
    (2, 2): ("Segunda e terceira, seguidas", "Segunda y tercera, seguidas",
             "Encadea a segunda e a terceira orde. Cambia a orde de aparición unha vez: escoitan, non memorizan.",
             "Encadena la segunda y la tercera orden. Cambia el orden de aparición una vez: escuchan, no memorizan."),
    (2, 3): ("As tres ordes, coa canción", "Las tres órdenes, con la canción",
             "Canción enteira coas tres ordes dentro, modelando todo o tempo. Aínda non retiras o xesto.",
             "Canción entera con las tres órdenes dentro, modelando todo el tiempo. Aún no retiras el gesto."),
    (2, 4): ("As tres ordes, co material", "Las tres órdenes, con el material",
             "As tres ordes co material do mes. O obxecto pasa de man en man: quen o ten, fai; o resto mira e anticipa.",
             "Las tres órdenes con el material del mes. El objeto pasa de mano en mano: quien lo tiene, hace; el resto mira y anticipa."),
    (2, 5): ("A clase elixe", "La clase elige",
             "Fai as tres ordes e deixa que unha crianza sinale cal repetimos. Non fai falta que a diga en inglés: co xesto abonda.",
             "Haz las tres órdenes y deja que una criatura señale cuál repetimos. No hace falta que la diga en inglés: con el gesto basta."),
    (3, 1): ("Dúas ordes nunha soa serie", "Dos órdenes en una sola serie",
             "Une a primeira e a segunda orde nunha serie, sen parar entre elas. Primeiro moi amodo, despois ao ritmo normal.",
             "Une la primera y la segunda orden en una serie, sin parar entre ellas. Primero muy despacio, después al ritmo normal."),
    (3, 2): ("Amodo e lixeiro", "Despacio y rápido",
             "Segunda e terceira orde: unha rolda moi amodo, outra lixeira. O contraste fai escoitar mellor.",
             "Segunda y tercera orden: una ronda muy despacio, otra rápida. El contraste hace escuchar mejor."),
    (3, 3): ("A historia da lámina", "La historia de la lámina",
             "Ensina a lámina do mes e conta en tres frases o que pasa. Cada orde é un xesto do protagonista; a clase fai o xesto.",
             "Enseña la lámina del mes y cuenta en tres frases lo que pasa. Cada orden es un gesto del protagonista; la clase hace el gesto."),
    (3, 4): ("Unha crianza modela contigo", "Una criatura modela contigo",
             "Unha crianza ponse ao teu lado e fai o xesto contigo mentres ti dis a orde. Cambia de crianza en cada orde.",
             "Una criatura se pone a tu lado y hace el gesto contigo mientras tú dices la orden. Cambia de criatura en cada orden."),
    (3, 5): ("Repaso coa canción", "Repaso con la canción",
             "Canción do mes coas tres ordes. Fíxate en quen anticipa o xesto antes da palabra: esas xa a teñen.",
             "Canción del mes con las tres órdenes. Fíjate en quién anticipa el gesto antes de la palabra: esas ya la tienen."),
    (4, 1): ("Só a voz, sen xesto", "Solo la voz, sin gesto",
             "Di a orde e non fagas o xesto. Conta ata tres en silencio. Se ninguén a fai, modela e segue sen comentario.",
             "Di la orden y no hagas el gesto. Cuenta hasta tres en silencio. Si nadie la hace, modela y sigue sin comentario."),
    (4, 2): ("Noutro sitio", "En otro sitio",
             "As tres ordes fóra da alfombra: no corredor, no patio ou na fila. A palabra ten que valer en calquera sitio.",
             "Las tres órdenes fuera de la alfombra: en el pasillo, en el patio o en la fila. La palabra tiene que valer en cualquier sitio."),
    (4, 3): ("Canción enteira, ao ritmo", "Canción entera, al ritmo",
             "Canción completa coas tres ordes, ao ritmo do mes e sen parar entre estrofas. Ti só marcas o pulso coa man.",
             "Canción completa con las tres órdenes, al ritmo del mes y sin parar entre estrofas. Tú solo marcas el pulso con la mano."),
    (4, 4): ("Ensaio para as casas", "Ensayo para casa",
             "Fai a sesión como a farán as familias: sen material especial, en dous minutos. É o que levan na nota.",
             "Haz la sesión como la harán las familias: sin material especial, en dos minutos. Es lo que se llevan en la nota."),
    (4, 5): ("Peche do mes, con calma", "Cierre del mes, con calma",
             "Última vez do mes: as tres ordes, a canción e a despedida en círculo. Remata máis amodo do que empezaches.",
             "Última vez del mes: las tres órdenes, la canción y la despedida en círculo. Termina más despacio de lo que empezaste."),
}

TEXTOS["segundo_ciclo.5"] = {
    (1, 1): ("A primeira orde, dramatizada", "La primera orden, dramatizada",
             "Presenta a primeira orde cun personaxe: dila coa voz dese personaxe e faina exaxerada. A clase mira e ri.",
             "Presenta la primera orden con un personaje: dila con la voz de ese personaje y hazla exagerada. La clase mira y ríe."),
    (1, 2): ("A mesma orde, co material", "La misma orden, con el material",
             "Repite a orde de onte co material do mes como atrezo. Quen queira entra na escena; quen non, é público.",
             "Repite la orden de ayer con el material del mes como atrezo. Quien quiera entra en la escena; quien no, es público."),
    (1, 3): ("A segunda orde, dramatizada", "La segunda orden, dramatizada",
             "Hoxe só a segunda orde, con outro personaxe. Dila, faina, conxela a postura un segundo, segue.",
             "Hoy solo la segunda orden, con otro personaje. Dila, hazla, congela la postura un segundo, sigue."),
    (1, 4): ("Dúas ordes, dous personaxes", "Dos órdenes, dos personajes",
             "Primeira e segunda orde, cada unha co seu personaxe. Cambia de voz entre unha e outra: é o sinal para escoitar.",
             "Primera y segunda orden, cada una con su personaje. Cambia de voz entre una y otra: es la señal para escuchar."),
    (1, 5): ("As dúas ordes, coa canción", "Las dos órdenes, con la canción",
             "Canción do mes coas dúas ordes onde caen no ritmo. O pulso vese na túa man; non se oe.",
             "Canción del mes con las dos órdenes donde caen en el ritmo. El pulso se ve en tu mano; no se oye."),
    (2, 1): ("A terceira orde, dramatizada", "La tercera orden, dramatizada",
             "Presenta a terceira orde con personaxe. Se o mes só ten dúas, repasa a segunda con outra voz.",
             "Presenta la tercera orden con personaje. Si el mes solo tiene dos, repasa la segunda con otra voz."),
    (2, 2): ("Freeze!", "¡Freeze!",
             "Segunda e terceira orde e, entre elas, «Freeze!»: todo o mundo queda de estatua. Quen se move, ri e volve.",
             "Segunda y tercera orden y, entre ellas, «Freeze!»: todo el mundo se queda de estatua. Quien se mueve, ríe y vuelve."),
    (2, 3): ("As tres ordes, coa canción", "Las tres órdenes, con la canción",
             "Canción enteira coas tres ordes dentro. Ti aínda modelas todo; o freeze vai ao final de cada estrofa.",
             "Canción entera con las tres órdenes dentro. Tú aún modelas todo; el freeze va al final de cada estrofa."),
    (2, 4): ("As tres ordes, co material", "Las tres órdenes, con el material",
             "As tres ordes co material do mes como atrezo. O obxecto pasa de man en man: quen o ten, actúa.",
             "Las tres órdenes con el material del mes como atrezo. El objeto pasa de mano en mano: quien lo tiene, actúa."),
    (2, 5): ("A clase elixe o personaxe", "La clase elige el personaje",
             "Fai as tres ordes e deixa que unha crianza elixa con que personaxe as repetimos. O xesto abonda para elixir.",
             "Haz las tres órdenes y deja que una criatura elija con qué personaje las repetimos. El gesto basta para elegir."),
    (3, 1): ("Dúas ordes nunha escena", "Dos órdenes en una escena",
             "Une a primeira e a segunda orde nunha escena seguida, sen parar. Primeiro moi amodo, despois ao ritmo normal.",
             "Une la primera y la segunda orden en una escena seguida, sin parar. Primero muy despacio, después al ritmo normal."),
    (3, 2): ("Amodo, lixeiro e freeze", "Despacio, rápido y freeze",
             "Segunda e terceira orde: unha rolda moi amodo, outra lixeira, e freeze ao final de cada unha.",
             "Segunda y tercera orden: una ronda muy despacio, otra rápida, y freeze al final de cada una."),
    (3, 3): ("A historia da lámina", "La historia de la lámina",
             "Ensina a lámina do mes e conta o que pasa en tres frases. Cada orde é unha acción do protagonista; a clase actúa.",
             "Enseña la lámina del mes y cuenta lo que pasa en tres frases. Cada orden es una acción del protagonista; la clase actúa."),
    (3, 4): ("Retiras o xesto a medias", "Retiras el gesto a medias",
             "Di a orde e empeza o xesto, pero non o remates. A clase complétao. Se non sae, remátao ti e segue.",
             "Di la orden y empieza el gesto, pero no lo termines. La clase lo completa. Si no sale, termínalo tú y sigue."),
    (3, 5): ("Repaso coa canción", "Repaso con la canción",
             "Canción do mes coas tres ordes. Fíxate en quen anticipa a acción antes da palabra: esas xa a teñen.",
             "Canción del mes con las tres órdenes. Fíjate en quién anticipa la acción antes de la palabra: esas ya la tienen."),
    (4, 1): ("Só a voz, sen xesto", "Solo la voz, sin gesto",
             "Di a orde coa voz do personaxe e non fagas nada. Conta ata tres. Se ninguén actúa, modela e segue sen comentario.",
             "Di la orden con la voz del personaje y no hagas nada. Cuenta hasta tres. Si nadie actúa, modela y sigue sin comentario."),
    (4, 2): ("Noutro sitio", "En otro sitio",
             "As tres ordes fóra da alfombra: no corredor, no patio ou na fila. A escena vale en calquera sitio.",
             "Las tres órdenes fuera de la alfombra: en el pasillo, en el patio o en la fila. La escena vale en cualquier sitio."),
    (4, 3): ("Canción enteira, ao ritmo", "Canción entera, al ritmo",
             "Canción completa coas tres ordes e freeze entre estrofas, ao ritmo do mes. Ti só marcas o pulso coa man.",
             "Canción completa con las tres órdenes y freeze entre estrofas, al ritmo del mes. Tú solo marcas el pulso con la mano."),
    (4, 4): ("Ensaio para as casas", "Ensayo para casa",
             "Fai a sesión como a farán as familias: sen atrezo, en dous minutos. Un personaxe e as tres ordes. É o que levan na nota.",
             "Haz la sesión como la harán las familias: sin atrezo, en dos minutos. Un personaje y las tres órdenes. Es lo que se llevan en la nota."),
    (4, 5): ("Peche do mes, con calma", "Cierre del mes, con calma",
             "Última vez do mes: as tres ordes, a canción e un freeze longo para despedirse. Remata máis amodo do que empezaches.",
             "Última vez del mes: las tres órdenes, la canción y un freeze largo para despedirse. Termina más despacio de lo que empezaste."),
}

TEXTOS["segundo_ciclo.6"] = {
    (1, 1): ("A primeira orde, con modelado", "La primera orden, con modelado",
             "Presenta a primeira orde: dila e faina á vez, tres veces. Logo pídelle a unha crianza que a faga contigo.",
             "Presenta la primera orden: dila y hazla a la vez, tres veces. Luego pídele a una criatura que la haga contigo."),
    (1, 2): ("A mesma orde, en parellas", "La misma orden, en parejas",
             "Repite a orde de onte en parellas: un di a orde en inglés, o outro faina. Cambian de papel á segunda rolda.",
             "Repite la orden de ayer en parejas: uno dice la orden en inglés, el otro la hace. Cambian de papel en la segunda ronda."),
    (1, 3): ("A segunda orde, con modelado", "La segunda orden, con modelado",
             "Hoxe só a segunda orde, co mesmo esquema: dila, faina, unha crianza contigo.",
             "Hoy solo la segunda orden, con el mismo esquema: dila, hazla, una criatura contigo."),
    (1, 4): ("Dúas ordes, en parellas", "Dos órdenes, en parejas",
             "Primeira e segunda orde en parellas. Quen di a orde elixe cal; quen a fai, faina. Cambian de papel.",
             "Primera y segunda orden en parejas. Quien dice la orden elige cuál; quien la hace, la hace. Cambian de papel."),
    (1, 5): ("As dúas ordes, coa canción", "Las dos órdenes, con la canción",
             "Canción do mes coas dúas ordes onde caen no ritmo. O pulso vese na túa man; non se oe.",
             "Canción del mes con las dos órdenes donde caen en el ritmo. El pulso se ve en tu mano; no se oye."),
    (2, 1): ("A terceira orde, con modelado", "La tercera orden, con modelado",
             "Presenta a terceira orde igual que as outras. Se o mes só ten dúas, repasa a segunda en parellas.",
             "Presenta la tercera orden igual que las otras. Si el mes solo tiene dos, repasa la segunda en parejas."),
    (2, 2): ("Segunda e terceira, en parellas", "Segunda y tercera, en parejas",
             "Segunda e terceira orde en parellas. Quen di a orde pode cambiar a secuencia: quen a fai ten que escoitar.",
             "Segunda y tercera orden en parejas. Quien dice la orden puede cambiar la secuencia: quien la hace tiene que escuchar."),
    (2, 3): ("As tres ordes, coa canción", "Las tres órdenes, con la canción",
             "Canción enteira coas tres ordes dentro. Unha crianza marca o pulso coa man ao teu lado.",
             "Canción entera con las tres órdenes dentro. Una criatura marca el pulso con la mano a tu lado."),
    (2, 4): ("As tres ordes, co material", "Las tres órdenes, con el material",
             "As tres ordes co material do mes. Quen ten o obxecto di a orde; a clase faina. Cambia de man cada vez.",
             "Las tres órdenes con el material del mes. Quien tiene el objeto dice la orden; la clase la hace. Cambia de mano cada vez."),
    (2, 5): ("Unha crianza dirixe", "Una criatura dirige",
             "Unha crianza ponse no teu sitio e di as tres ordes á clase. Ti fas de alumna. Cambia de directora a cada orde.",
             "Una criatura se pone en tu sitio y dice las tres órdenes a la clase. Tú haces de alumna. Cambia de directora a cada orden."),
    (3, 1): ("Dúas ordes nunha serie", "Dos órdenes en una serie",
             "Une a primeira e a segunda orde nunha serie seguida, en parellas. Primeiro moi amodo, despois ao ritmo normal.",
             "Une la primera y la segunda orden en una serie seguida, en parejas. Primero muy despacio, después al ritmo normal."),
    (3, 2): ("Amodo e lixeiro", "Despacio y rápido",
             "Segunda e terceira orde: quen dirixe elixe se vai amodo ou lixeiro, e dío en inglés: «slow» ou «fast».",
             "Segunda y tercera orden: quien dirige elige si va despacio o rápido, y lo dice en inglés: «slow» o «fast»."),
    (3, 3): ("A historia da lámina", "La historia de la lámina",
             "Ensina a lámina do mes e que a clase conte o que pasa. Cada orde é unha acción do protagonista; en parellas, un narra e outro actúa.",
             "Enseña la lámina del mes y que la clase cuente lo que pasa. Cada orden es una acción del protagonista; en parejas, uno narra y otro actúa."),
    (3, 4): ("Cadea de ordes", "Cadena de órdenes",
             "En círculo: cada crianza di unha orde á seguinte, que a fai e pasa outra. Ti só arrancas a cadea.",
             "En círculo: cada criatura dice una orden a la siguiente, que la hace y pasa otra. Tú solo arrancas la cadena."),
    (3, 5): ("Repaso coa canción", "Repaso con la canción",
             "Canción do mes coas tres ordes, dirixida por unha crianza. Fíxate en quen di as ordes enteiras en inglés.",
             "Canción del mes con las tres órdenes, dirigida por una criatura. Fíjate en quién dice las órdenes enteras en inglés."),
    (4, 1): ("Só a voz, sen xesto", "Solo la voz, sin gesto",
             "Di as ordes sen xesto e en secuencia distinta á de sempre. Conta ata tres. Se non sae, modela e segue.",
             "Di las órdenes sin gesto y en secuencia distinta a la de siempre. Cuenta hasta tres. Si no sale, modela y sigue."),
    (4, 2): ("Noutro sitio", "En otro sitio",
             "As tres ordes fóra da alfombra, en parellas: no corredor, no patio ou na fila. A palabra vale en calquera sitio.",
             "Las tres órdenes fuera de la alfombra, en parejas: en el pasillo, en el patio o en la fila. La palabra vale en cualquier sitio."),
    (4, 3): ("Canción enteira, dirixida", "Canción entera, dirigida",
             "Canción completa coas tres ordes, ao ritmo do mes, dirixida por parellas que se van relevando. Ti só marcas o pulso.",
             "Canción completa con las tres órdenes, al ritmo del mes, dirigida por parejas que se van relevando. Tú solo marcas el pulso."),
    (4, 4): ("Ensaio para as casas", "Ensayo para casa",
             "Fai a sesión como a farán as familias: a crianza di as ordes e a persoa adulta as fai. É o que levan na nota.",
             "Haz la sesión como la harán las familias: la criatura dice las órdenes y la persona adulta las hace. Es lo que se llevan en la nota."),
    (4, 5): ("Peche do mes, con calma", "Cierre del mes, con calma",
             "Última vez do mes: as tres ordes ditas pola clase, a canción e a despedida en círculo. Remata máis amodo do que empezaches.",
             "Última vez del mes: las tres órdenes dichas por la clase, la canción y la despedida en círculo. Termina más despacio de lo que empezaste."),
}

NOTA = {
    "gl": "A temática, o material, a canción e as ordes de cada mes saen do "
          "documento curricular. O reparto por semanas e días é unha proposta "
          "de escalonamento segundo o método TPR (descubrir, practicar, "
          "combinar, consolidar); non está no documento e pódese cambiar aquí.",
    "es": "La temática, el material, la canción y las órdenes de cada mes salen "
          "del documento curricular. El reparto por semanas y días es una "
          "propuesta de escalonamiento según el método TPR (descubrir, "
          "practicar, combinar, consolidar); no está en el documento y se puede "
          "cambiar aquí.",
}


def build(clave: str) -> dict:
    textos = TEXTOS[clave]
    dias = []
    for (semana, dia), (comandos, modo) in PATRON.items():
        foco_gl, foco_es, cons_gl, cons_es = textos[(semana, dia)]
        _, nome_gl, nome_es = DIAS[dia - 1]
        dias.append({
            "semana": semana,
            "dia": dia,
            "nomeDia": {"gl": nome_gl, "es": nome_es},
            "foco": {"gl": foco_gl, "es": foco_es},
            "consigna": {"gl": cons_gl, "es": cons_es},
            "comandos": comandos,
            "modo": modo,
        })
    return {
        "version": 1,
        "id": f"progresion.{clave}",
        "nota": NOTA,
        "semanas": [
            {"numero": n, "nome": {"gl": gl, "es": es},
             "meta": {"gl": mgl, "es": mes}}
            for n, gl, es, mgl, mes in SEMANAS
        ],
        "dias": dias,
    }


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for clave in TEXTOS:
        assert set(TEXTOS[clave]) == set(PATRON), clave
        path = OUT / f"progresion.{clave}.json"
        path.write_text(
            json.dumps(build(clave), ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(path.relative_to(ROOT))


if __name__ == "__main__":
    main()
