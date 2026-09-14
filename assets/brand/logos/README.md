# Logotipos institucionales

Marcas de terceros. **No se redibujan ni se improvisan**: un logotipo
institucional tiene normas de uso propias (proporciones, versiones, fondos
permitidos) y usarlo mal es peor que no usarlo.

`LogoInstitucional` (`lib/core/brand/logo_institucional.dart`) pinta cada uno
**solo si el fichero está**. Si falta, no ocupa nada y la fila se cierra: no hay
caja gris ni aviso. El nombre de la entidad va siempre en texto al lado, esté o
no el logotipo.

## Los ficheros

| Fichero | Entidad | Dónde se pinta |
| --- | --- | --- |
| `dr-betances-crest.png` | Escudo del Dr. Betances | Créditos (sobre placa oscura) · portada del manual · cabecera del README |
| `earlify-health.jpg` | Earlify Health S.L. | Créditos, bajo el escudo |
| `startic.png` | Incubadora de Alta Tecnoloxía startTIC | Créditos, «con el apoyo de» · portada del manual · cabecera del README |
| `zona-franca-vigo.png` | Consorcio da Zona Franca de Vigo | Créditos, «con el apoyo de» · portada del manual · cabecera del README |

## Dónde se ven, además de en la app

Los tres —el escudo del Dr. Betances, startTIC y el Consorcio da Zona Franca—
van también en la **portada del manual** (`docs/manual-casos-de-uso.html`, y por
tanto en su PDF y su Word) y en la **cabecera del README**. El del Concello no:
Frank pidió retirarlo.

## Lo que sigue mal en dos de los ficheros

Está medido, no es una impresión:

| Fichero | Defecto | Cómo se midió |
| --- | --- | --- |
| `startic.png` | **Está recortado.** El dibujo toca los bordes izquierdo, derecho e inferior de la imagen: no hay margen, es un recorte de algo mayor | El canal alfa tiene contenido en `x=0`, `x=509` e `y=101`, que son los propios bordes |
| `zona-franca-vigo.png` | **Venía de una captura de pantalla**, con un fondo gris degradado y unos arcos de otra web pegados a la izquierda | 55 colores distintos en la fila superior y 77 en la columna izquierda; una exportación limpia tendría uno |

Lo que se ha hecho con el de la Zona Franca: **recortarlo** a la caja
`(190, 10, 590, 176)` para tirar los arcos ajenos y el sobrante. **No se ha
tocado un solo píxel del dibujo**: recortar lo que no es de la marca no es lo
mismo que retocar la marca. El de startTIC no tiene arreglo por recorte —lo que
falta, falta— y se queda como está.

**Para dejarlos bien hace falta el fichero oficial de cada entidad**: PNG con
fondo transparente, al menos 128 px de alto, con el nombre exacto de la tabla de
arriba. Si solo hay SVG, se convierte a PNG a 3×.

## El que se retiró, y por qué

El hueco de cada uno **sigue en el código**: en cuanto vuelva el fichero con su
nombre exacto, el logotipo reaparece sin tocar una línea. Mientras tanto el
nombre de la entidad se sigue leyendo en texto, que es lo que acredita.

| Fichero retirado | Entidad | Motivo |
| --- | --- | --- |
| `concello-vigo.png` | Concello de Vigo | **Retirado por orden de Frank.** |

Un logotipo ajeno mal puesto —cortado, recortado de una web, con el fondo de
otra página pegado— es peor que no ponerlo: acredita mal a quien intentas
acreditar. Y no se arregla retocándolo, porque retocar la marca de un tercero
es exactamente lo que no se puede hacer.

**Para que vuelvan**: el fichero oficial de cada entidad, PNG con fondo
transparente y al menos 128 px de alto, con su nombre exacto de la tabla. Si la
entidad solo da SVG, se convierte a PNG a 3×.

**Un fichero que no se pinta no se queda aquí.** `pubspec.yaml` empaqueta la
carpeta entera, así que un logotipo sin hueco en los créditos viaja en el APK
sin que nadie lo vea: había dos duplicados en `.jpg` del escudo y de la Zona
Franca —el mismo dibujo que ya estaba en `.png`— y el de Earlify entró a 992 px
y 335 KB para pintarse a 56 dp. Entre los tres, casi medio mega de APK que no
se veía. Borrados los duplicados; el de Earlify, reempaquetado a 512 px (47 KB),
que es la misma imagen, sin retocar.

Los originales sin canal alfa (`earlify-health.jpg`, `zona-franca-vigo.png`)
traen su propio fondo blanco. Sobre la tarjeta tintada de los créditos se
apoyan en una placa blanca (`sobrePlaca: true`), que es la forma de colocar un
logotipo ajeno sin tocarlo. **No se recorta el fondo a mano**: eso es retocar
una marca de un tercero.

Para añadir uno: dejarlo aquí con ese nombre exacto y declararlo en el hueco
que ya existe en `lib/features/creditos/credits_screen.dart`. No hace falta
tocar el código si el hueco ya está puesto: aparece solo.

PNG con fondo transparente, alto mínimo 128 px. Si hay SVG oficial, mejor
convertirlo a PNG a 3× (la app no lleva librería de SVG y meterla por tres
imágenes no compensa).

## El escudo del Dr. Betances va sobre placa oscura

Está dibujado para fondo OSCURO: tiene un cuervo blanco y un círculo blanco.
Sobre la tarjeta clara de los créditos esas dos piezas desaparecían y quedaba
medio escudo —el cuervo negro suelto, sin círculo—. Ahora se apoya en una placa
`AppTheme.dark`, que es la forma de colocarlo sin retocar el dibujo.

## Pendiente de Frank, antes de publicar

Ninguna la puede resolver el código:

1. **Los ficheros oficiales** de startTIC y del Consorcio da Zona Franca, si se
   quieren acreditar con logotipo y no solo con el nombre.
2. **Los nombres oficiales exactos.** Los créditos dicen hoy «Programa StartTIC»
   y «Zona Franca de Vigo». No están confirmados, y acreditar a una institución
   con el nombre mal escrito es peor que no acreditarla.
3. **El permiso de uso**, para cualquier marca de tercero que vuelva a ponerse:
   en una ficha de Google Play un logotipo institucional sugiere respaldo, y eso
   hace falta por escrito.
