# Fuentes que no van en la app

Ficheros de datos que la app no carga. Estaban en `assets/`, y todo lo que hay
en `assets/content/` se empaqueta en el APK; aquí no.

| Fichero | Para qué sirve |
| --- | --- |
| `bnc_coca_8000.json` | Las bandas de frecuencia de la lista BNC/COCA. Es la entrada de `tools/build_corpus_ingles.py`, que escribe `assets/content/corpus/ingles_4000_uso_habitual.json` |
| `calendario_3_6_anos.json` | Calendario del 2.º ciclo heredado de la primera versión. Ninguna pantalla lo lee; se guarda como referencia |
