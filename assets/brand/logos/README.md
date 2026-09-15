# Logotipos institucionales

Marcas de terceros. **No se redibujan ni se improvisan**: un logotipo
institucional tiene normas de uso propias (proporciones, versiones, fondos
permitidos) y usarlo mal es peor que no usarlo.

`LogoInstitucional` (`lib/core/brand/logo_institucional.dart`) pinta cada uno
**solo si el fichero está**. Si falta, no ocupa nada y la fila se cierra: no hay
caja gris ni aviso. El nombre de la entidad va siempre en texto al lado, esté o
no el logotipo.

## Los ficheros

Los cinco los trajo Frank en la rama `logo`, el 15/9/2026.

| Fichero | Entidad | Formato y tamaño | Dónde se pinta |
| --- | --- | --- | --- |
| `dr-betances-crest.jpg` | Escudo del Dr. Betances | JPEG 1024 × 1024, fondo turquesa propio | Créditos · portada del manual · cabecera del README |
| `earlify-health.jpg` | Earlify Health S.L. | JPEG 992 × 1024, fondo claro propio | Créditos, bajo el escudo · portada del manual · cabecera del README |
| `startic.png` | Incubadora de Alta Tecnoloxía startTIC | PNG 510 × 102, RGBA | Créditos, «en colaboración con» · portada del manual · cabecera del README |
| `zona-franca-vigo.png` | Consorcio da Zona Franca de Vigo | PNG 702 × 280, RGBA | Créditos, «en colaboración con» · portada del manual · cabecera del README |
| `concello-vigo.png` | Concello de Vigo | PNG 600 × 207, RGBA | Créditos, bajo startTIC y Zona Franca · portada del manual · cabecera del README |

La rama traía además `starttic.png`, con dos tes. **No se ha copiado**: es byte
a byte el mismo fichero que `startic.png` —mismo SHA-256— y dos nombres para la
misma imagen es una forma segura de que algún día se actualice solo uno.

## Las alturas no son iguales, y es a propósito

Las proporciones no se parecen: el escudo y Earlify son cuadrados, startTIC es
5:1, la Zona Franca 2,5:1 y el Concello 2,9:1. Igualarlos por altura de caja
hace que los apaisados se coman la pantalla y los cuadrados se vean diminutos.
Se igualan por **peso óptico**: 72-76 px los cuadrados, 48 los apaisados medios
y 32 el de startTIC, que es el más alargado.

El escudo ya **no** va sobre placa oscura. La llevaba porque la versión anterior
estaba dibujada para fondo oscuro y sobre la tarjeta clara se perdían el cuervo
blanco y el círculo; la de la rama `logo` trae su propio fondo turquesa sólido,
así que la placa solo le añadiría un marco negro.

## Lo que mejoró, y lo que no · medido, no supuesto

| Fichero | Antes | Ahora |
| --- | --- | --- |
| `zona-franca-vigo.png` | 400 × 166 RGB. Venía de una captura de web y hubo que **recortarlo** a `(190, 10, 590, 176)` para tirar unos arcos ajenos | **Resuelto.** 702 × 280 RGBA y el canal alfa **no toca ningún borde**: tiene margen propio. Es una exportación limpia, no un recorte |
| `concello-vigo.png` | No estaba: se había retirado | **Vuelve.** Se pinta en créditos, manual y README |
| `dr-betances-crest` | PNG para fondo oscuro | JPEG 1024 × 1024 con fondo turquesa propio |
| `earlify-health.jpg` | 47 KB | 335 KB, bastante más resolución |
| `startic.png` | Recortado: el dibujo toca los bordes izquierdo, derecho e inferior | **Sigue igual.** El fichero de la rama `logo` es **byte a byte el mismo** que ya había: mismo SHA-256. El alfa sigue con contenido en `x=0`, `x=509` e `y=101` |

Cómo se midió: se abre el PNG, se lee el canal alfa y se comprueba si hay algún
píxel opaco en la primera y la última fila y columna. Si lo hay, el dibujo llega
al borde y por tanto falta margen.

**El de startTIC sigue pendiente.** Lo que falta, falta: no se arregla por
recorte ni retocando la marca, que es justo lo que no se puede hacer con el
logotipo de un tercero. Para cerrarlo hace falta **el fichero oficial de
startTIC**: PNG con fondo transparente, al menos 128 px de alto y con margen,
guardado con ese mismo nombre. En cuanto esté, la app lo pinta sin tocar código.
