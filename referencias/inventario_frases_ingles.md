# Inventario de las frases inglesas de la app

Generado por `tools/xera_rexistro_frases.py`; no se edita a mano. Módulo M3.2
del plan docente.

## Lo que entra en el registro de frases

`assets/content/registro/frases.json`: 150 frases, de ellas
9 propias (`registro/frases_propias.json`). Lo que ya es palabra
del banco no entra: se cita por su id del banco.

| Fuente | Frases | Ya en el banco | En el registro |
| --- | --- | --- | --- |
| `asambleas_primeiro_ciclo` | 43 | 13 | 30 |
| `asambleas_segundo_ciclo` | 90 | 0 | 90 |
| `calendario` | 5 | 0 | 5 |
| `dinamicas_aula.json` | 5 | 0 | 5 |
| `steam` | 10 | 9 | 1 |
| `xogos_fogar.json` | 10 | 0 | 10 |
| `registro/frases_propias.json` | 9 | 0 | 9 |

## Lo que todavía no entra, y dónde se resuelve

| Fuente | Inglés que lleva | Destino |
| --- | --- | --- |
| calendario/curriculo_50_meses.json (léxico, órdenes y frase del mes) | 450 | Se retira como fuente en M3.9: el calendario pasa a leer la unidad |
| cuentos: frase TPR de los cuentos y de las historias | 303 | M5: el cuento de la semana conserva su frase; el microcuento cita el registro |
| laminas/banco200_laminas.json (palabra y acción) | 410 | M7.2: las láminas pasan a citar el registro |
| unidades/juega.* (asamblea de seis pasos) | 10 | Se retira en M4.3 |

Fuera del registro, a propósito: el corpus de 4.000 palabras de uso habitual y
las colocaciones son consulta de la persona adulta, no currículo.
