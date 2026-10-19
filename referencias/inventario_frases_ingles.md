# Inventario de las frases inglesas de la app

Generado por `tools/xera_rexistro_frases.py`; no se edita a mano. Módulo M3.2
del plan docente.

## Lo que entra en el registro de frases

`assets/content/registro/frases.json`: 172 frases, de ellas
9 propias (`registro/frases_propias.json`). Una orden entra
aunque su texto sea también palabra del banco: se lleva el gesto de su fuente,
y comparte la grabación.

| Fuente | Frases | Mismo texto en el banco | En el registro |
| --- | --- | --- | --- |
| `asambleas_primeiro_ciclo` | 43 | 13 | 43 |
| `asambleas_segundo_ciclo` | 90 | 0 | 90 |
| `calendario` | 5 | 0 | 5 |
| `dinamicas_aula.json` | 5 | 0 | 5 |
| `steam` | 10 | 9 | 10 |
| `xogos_fogar.json` | 10 | 0 | 10 |
| `registro/frases_propias.json` | 9 | 0 | 9 |

## Lo que todavía no entra, y dónde se resuelve

| Fuente | Inglés que lleva | Destino |
| --- | --- | --- |
| calendario/curriculo_50_meses.json (léxico, órdenes y frase del mes) | 450 | Desde M3.9 el calendario lee la unidad; lo lee aún el Planificador, hasta M7.3 |
| cuentos: frase TPR de los cuentos y de las historias | 303 | M5: el cuento de la semana conserva su frase; el microcuento cita el registro |
| laminas/banco200_laminas.json (palabra y acción) | 410 | M7.2: las láminas pasan a citar el registro |
| unidades/juega.* (asamblea de seis pasos) | 10 | Se retira en M4.3 |

Fuera del registro, a propósito: el corpus de 4.000 palabras de uso habitual y
las colocaciones son consulta de la persona adulta, no currículo.
