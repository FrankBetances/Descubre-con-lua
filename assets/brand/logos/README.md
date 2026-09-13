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
| `dr-betances-crest.png` | Escudo del Dr. Betances | Créditos, cabecera de autoría |
| `earlify-health.jpg` | Earlify Health S.L. | Créditos, bajo el escudo |
| `startic.png` | Programa startTIC | Créditos, «con el apoyo de» |
| `zona-franca-vigo.png` | Consorcio da Zona Franca de Vigo | Créditos, «con el apoyo de» |
| `concello-vigo.png` | Concello de Vigo | Créditos, «con el apoyo de» |

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

## Pendiente de Frank, antes de publicar

Dos cosas, y ninguna la puede resolver el código:

1. **Los nombres oficiales exactos.** Los créditos dicen hoy «Programa StartTIC»
   y «Zona Franca de Vigo». No están confirmados, y acreditar a una institución
   con el nombre mal escrito es peor que no acreditarla.
2. **El permiso de uso.** Los logotipos del Concello de Vigo, del Consorcio da
   Zona Franca y de startTIC son marcas de terceros, y en una ficha de Google
   Play sugieren respaldo institucional. Hace falta autorización escrita de las
   tres. Sin ella, lo correcto es dejar el nombre en texto y quitar el fichero:
   el widget se cierra solo y la pantalla sigue estando bien.
