# Original User Request

## Initial Request — 2026-09-11T08:15:28Z

Construir la aplicación nativa Android «Descubre con Lúa · Edición Vigo» en Flutter (Package ID: com.earlify.descubreconlua), adaptando y portando los módulos pedagógicos desde el repositorio el repositorio del proyecto anterior de la casa (Juega con Lúa · aula y Academy · familias) bajo arquitectura estricta de contenido como datos JSON bilingües (gl/es), privacidad verificable en el binario (sin permisos de internet) y audio offline pregenerado.

Working directory: <documentos locales>/Descubre con Lúa
Integrity mode: development

## Requirements

### R1. Estructura Base del Proyecto Flutter (Solo Android) & Privacidad
- Configurar el proyecto Flutter para Android con identificador `com.earlify.descubreconlua`.
- Arquitectura limpia en `lib/`:
  - `lib/core/`: Temas, constantes tipográficas y utilidades de audio local.
  - `lib/data/`: Modelos fuertemente tipados, cargador de assets JSON y repositorio de contenidos.
  - `lib/features/juega/`: Módulo Juega con Lúa · aula orientado a la docente.
  - `lib/features/academy/`: Módulo Academy · familias orientado a padres y madres.
- Privacidad estricta en binario: el manifiesto release (`android/app/src/main/AndroidManifest.xml`) no debe contener `android.permission.INTERNET` ni permisos no esenciales.
- Cero clientes de red, sockets, telemetría o SDKs analíticos en `pubspec.yaml` ni en `lib/`.

### R2. Capa de Contenido como Datos & Validador de Esquemas (Regla 03)
- Modelos Dart para unidades temáticas (`Unidad`, `Vocabulario`, `Actividad`, `Preguntas`, `Exploracion`, `Matematicas`, `PuenteCasa`, `Revision`).
- Modelos Dart para cápsulas de Academy (`Capsula`, `Bloque`, `Afirmacion`, `Revision`).
- Cargador de recursos locales desde `assets/content/**` con soporte bilingüe en paralelo (Gallego `gl` y Castellano `es`).
- Incorporar como datos base en `assets/content/`:
  - `unidades/juega.mar.01.json` (Unidad de exploración marítima de Vigo).
  - `capsulas/academy.como_se_aprende_a_hablar.01.json` (Cápsula familiar de desarrollo comunicativo).
- Validador automatizado con suite de pruebas unitarias que verifique:
  - Paridad estricta 1:1 entre gallego y castellano.
  - Integridad referencial de recursos de audio y referencias curriculares (Decreto 150/2022).
  - Ausencia de terminología clínica o diagnóstica prohibida (enfoque exclusivamente educativo/familiar 0-3 años).

### R3. Portado y Adaptación de Módulos desde el repositorio del proyecto anterior de la casa
- Consultar los componentes homólogos en el repositorio del proyecto anterior de la casa y adaptarlos al diseño docente/familiar:
  - **Academy (Familias)**:
    - Navegación por los 5 bloques de desarrollo.
    - Vista de cápsula con las 4 partes: idea clave, por qué importa, qué hacer en casa y ejemplo cotidiano.
    - Selector dinámico de lengua (`gl` / `es`), tipografía grande de lectura cómoda para adultos, sin enlaces web externos y sin interacción infantil.
  - **Juega con Lúa (Aula / Docentes)**:
    - Selector de unidades filtrable por tramo etario (0-2 años y 2-3 años).
    - Modo asamblea guiado paso a paso para la docente: canción a pulso con reproductor offline de audio local, cuento, preguntas graduadas por nivel, exploración científica con materiales y aviso de seguridad, matemáticas tempranas y puente a casa.
    - Diseño sobrio y funcional para el uso del docente, eliminando deliberadamente animaciones llamativas, efectos visuales distractores o mecánicas de pantalla táctil pensadas para niños.

## Acceptance Criteria

### Verificación de Privacidad y Binario
- [ ] El archivo `AndroidManifest.xml` no incluye `android.permission.INTERNET`.
- [ ] No existen dependencias de red (HTTP, WebSockets, Firebase, analítica) en `pubspec.yaml`.

### Verificación de Contenido y Tests Automatizados
- [ ] Suite de pruebas unitarias (`flutter test test/data/`) valida al 100% los modelos y la carga de los archivos JSON.
- [ ] El validador automatizado certifica la paridad lingüística `gl`/`es` y rechaza archivos incompletos o con términos prohibidos.

### Verificación Funcional de Pantallas (Widget Tests)
- [ ] Widget tests verifican el flujo completo de Academy (listado de bloques, cápsulas y conmutación de idioma).
- [ ] Widget tests verifican el flujo completo de Juega con Lúa (navegación de unidades y modo asamblea guiada para la docente).
