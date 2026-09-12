# Logotipos institucionales

Marcas de terceros. **No se redibujan ni se improvisan**: un logotipo
institucional tiene normas de uso propias (proporciones, versiones, fondos
permitidos) y usarlo mal es peor que no usarlo.

`LogoInstitucional` (`lib/core/brand/logo_institucional.dart`) pinta cada uno
**solo si el fichero está**. Si falta, no ocupa nada y la fila se cierra: no hay
caja gris ni aviso. El nombre de la entidad va siempre en texto al lado, esté o
no el logotipo.

## Los ficheros

| Fichero | Entidad | Estado |
| --- | --- | --- |
| `dr-betances-crest.png` | Escudo del Dr. Betances | **presente**, portado del repositorio de Valeria+ |
| `startic.png` | Programa StartTIC | **falta** |
| `zona-franca-vigo.png` | Consorcio da Zona Franca de Vigo | **falta** |
| `concello-vigo.png` | Concello de Vigo | **falta** |

Para añadir uno: dejarlo aquí con ese nombre exacto y declararlo en el hueco
que ya existe en `lib/features/creditos/credits_screen.dart`. No hace falta
tocar el código si el hueco ya está puesto: aparece solo.

PNG con fondo transparente, alto mínimo 128 px. Si hay SVG oficial, mejor
convertirlo a PNG a 3× (la app no lleva librería de SVG y meterla por tres
imágenes no compensa).

## Nombres oficiales, pendientes de confirmar

Los créditos dicen hoy «Programa StartTIC» y «Zona Franca de Vigo». **Los
nombres oficiales exactos no están confirmados**, y acreditar a una institución
con el nombre mal escrito es peor que no acreditarla. Frank tiene que
confirmarlos antes de publicar.
