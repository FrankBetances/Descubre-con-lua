# Inventario de las frases inglesas de la app

Generado por `tools/xera_rexistro_frases.py`; no se edita a mano. Módulo M3.2
del plan docente.

## Lo que entra en el registro de frases

`assets/content/registro/frases.json`: 872 frases, de ellas
9 propias (`registro/frases_propias.json`) y 140 de Lúa
(`registro/frases_lua.json`). Una orden entra
aunque su texto sea también palabra del banco: se lleva el gesto de su fuente,
y comparte la grabación.

| Fuente | Frases | Mismo texto en el banco | En el registro |
| --- | --- | --- | --- |
| `asambleas_primeiro_ciclo` | 43 | 13 | 43 |
| `asambleas_segundo_ciclo` | 90 | 0 | 90 |
| `calendario` | 55 | 0 | 55 |
| `dinamicas_aula.json` | 5 | 0 | 5 |
| `laminas` | 410 | 121 | 410 |
| `steam` | 110 | 14 | 110 |
| `xogos_fogar.json` | 10 | 0 | 10 |
| `registro/frases_propias.json` | 9 | 0 | 9 |
| `registro/frases_lua.json` | 140 | 0 | 140 |

## Lo que todavía no entra, y dónde se resuelve

| Fuente | Inglés que lleva | Destino |
| --- | --- | --- |
| calendario/curriculo_50_meses.json (léxico y órdenes) | 400 | Ya no lo pinta ninguna pantalla: el calendario lee la unidad (M3.9) y el Planificador también (M7.3). Su frase del mes sí entra |
| cuentos: frase TPR de los cuentos y de las historias | 303 | M5: el cuento de la semana conserva su frase; el microcuento cita el registro |

Fuera del registro, a propósito: el corpus de 4.000 palabras de uso habitual y
las colocaciones son consulta de la persona adulta, no currículo.
