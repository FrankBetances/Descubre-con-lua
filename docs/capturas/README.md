# Las imágenes de pantalla del manual

## Qué son

El **árbol de widgets real** pintado por el motor de Flutter, con la tipografía
real de la app (Nunito y MaterialIcons) y con el contenido real de los JSON. La
disposición es la que la app calcula: no son maquetas ni montajes.

Las genera `test/capturas_test.dart`:

```bash
flutter test --tags capturas --update-goldens test/capturas_test.dart
```

Van fuera de los gates a propósito: no comprueban nada, producen un documento.

## Qué NO son

**No son capturas de un aparato.** Aquí no hay:

- muesca ni barra de gestos;
- la densidad de un teléfono concreto (se fija a 2,0);
- la escala de texto del sistema (se fija a 1,0);
- audio, que no suena en ningún test.

Es la regla 1c de `CLAUDE.md` escrita en forma de aviso: un render de Flutter se
parece mucho más a un Android que una maqueta, pero sigue sin ser un Android.

## Cómo sustituirlas por capturas de verdad

Reemplazar los PNG con el mismo nombre. El manual no se toca:

```bash
flutter run -d <dispositivo>
adb exec-out screencap -p > docs/capturas/aula-unidades-gl.png
```

Cada pantalla va en gallego **y** en castellano. Las dos lenguas no ocupan lo
mismo, y ahí es donde aparecen los cortes de texto. Estas imágenes ya han pagado
su coste: en la primera tanda se vio que el chip «Todas las edades» salía
cortado en castellano y entero en gallego. Ningún test lo había cazado, porque
un chip recorta en vez de desbordar: no hay franjas amarillas ni excepción. Está
arreglado, y ahora lo vigila `test/features/juega/filtro_edad_test.dart`, que
compara el ancho pintado con el que el texto mide de verdad.

## Los ficheros

| Fichero | Pantalla |
| --- | --- |
| `bienvenida-{gl,es}.png` | La pantalla con la que arranca la app |
| `aula-unidades-{gl,es}.png` | Juega con Lúa · Aula: tira de Lúa, formación y unidades |
| `aula-formacion-{gl,es}.png` | Formación · Aula: los seis pasos de la asamblea |
| `academy-bloques-{gl,es}.png` | Academy · Familias: los cinco bloques |
| `academy-lector-{gl,es}.png` | El lector paginado de una cápsula |
| `premios-{gl,es}.png` | Los premios de Lúa: nivel, racha e insignias |
| `creditos-{gl,es}.png` | Créditos |
