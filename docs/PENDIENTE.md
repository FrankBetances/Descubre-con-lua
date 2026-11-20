# Lo que queda pendiente (lista para la semana del 23/11/2026)

Actualizada por Claude Code el 20/11/2026, después de mergear P9 (Estimulación del lenguaje y el pensamiento). Cada punto dice quién lo hace.

## Decisiones de Frank (nadie puede avanzarlas sin él)

1. **Realidad aumentada con Lúa y los sets de Valeria (O-20261120-1, P9.4).** ¿Sí o no al permiso de cámara? El informe está en `docs/estimulacion-ar-informe.md`: ARCore, Filament y MediaPipe (Apache-2.0), sin red en uso, pero hoy la app no pide ningún permiso. Con el sí: Antigravity lo implementa y en el mismo cambio se actualizan la política de privacidad, la ficha de Seguridad de los datos de Play y el gate de permisos.
2. **Entrada de Estimulación duplicada en Hoxe.** Está arriba (la principal) y también abajo, al final de la lección. Si Frank dice «quita la entrada de abajo», se quita.
3. **Revisión de la logopeda** de los 40 pares, las 40 progresiones, el modelo del adulto y los 160 momentos de pensamiento (`docs/estimulacion-control.md` y `docs/escoita-control.md`). Seis pares saltan la regla de edad con permiso de Frank: pan/pat, light/night, cheek/peek, blow/slow, seed/see y drink/shrink.
4. **Velocidad de la voz.** Que la logopeda escuche en un móvil la voz de niño (1.05) y la lenta (1.6) de las frases, y diga si vale.
5. **Probar en la app** (Na casa → Hoxe → Estimulación) tres meses de edades distintas y darlo por bueno (O-20261118-3).

## Trabajo de Claude Code

6. **Ver en un móvil Android real** la sección nueva: nada de esto se ha visto en un aparato, solo en la app de escritorio. Sobre todo el texto en gallego con letra grande.
7. **Botón «Oír despacio».** En escritorio no se ve porque los audios nuevos aún no estaban generados; comprobar en el APK de main que sale al lado de cada frase.
8. **Freno de borrado.** Proponer a Frank que el hook `sin_borrar.py` bloquee también `mv` y `git mv` de ficheros del repositorio (fallo del 20/11 con `test/failures`). Solo Frank puede cambiar los hooks.

## Trabajo de Antigravity

9. **P9.4, si Frank dice sí a la cámara:** realidad aumentada en Flutter con los sets de Valeria orientados al STEAM del mes, Lúa como guía, gl y es.
10. **Revisión de inglés** de las frases «frase» de cada palabra (las que suenan en voz de niño) con el mismo criterio con que Claude Code corrigió los momentos de pensamiento: frases cortas, gramaticales y del experimento.
