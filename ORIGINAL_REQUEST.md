# Original User Request

## Initial Request — 2026-09-11T08:15:28Z

Construir la aplicación nativa Android «Descubre con Lúa · Edición Vigo» en Flutter (Package ID: com.earlify.descubreconlua), adaptando y portando los módulos pedagógicos desde el repositorio FrankBetances/Valeria (Juega con Lúa · aula y Academy · familias) bajo arquitectura estricta de contenido como datos JSON bilingües (gl/es), privacidad verificable en el binario (sin permisos de internet) y audio offline pregenerado.

Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa
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

### R3. Portado y Adaptación de Módulos desde Valeria (GitHub: FrankBetances/Valeria)
- Consultar los componentes homólogos en `FrankBetances/Valeria` y adaptarlos al diseño docente/familiar:
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

## Follow-up — 2026-09-13T09:04:47Z

Mejora integral de la experiencia de usuario (UX/UI) y del sistema visual en «Descubre con Lúa · Edición Vigo», optimizando la sincronización entre las sesiones de aula (asamblea matinal) y las micro-rutinas del hogar con el calendario escolar de 10 meses (Decreto 150/2022), e incorporando tarjetas visuales e iconografía vectorial de alto contraste y diseño minimalista pensadas para visibilidad rápida a distancia.

Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa
Integrity mode: development

## Requirements

### R1. Sincronización Intuitiva y a Un Toque con el Calendario Escolar
Diseñar e implementar una experiencia fluida donde tanto educadores en la asamblea como familias en el hogar puedan lanzar y sincronizar la sesión diaria correspondiente con el mes curricular activo con un solo toque, actualizando de forma transparente el registro de estimulación (aula, hogar o doble estimulación) con retroalimentación visual clara.

### R2. Sistema de Tarjetas Visuales e Iconografía Vectorial de Alto Contraste
Desarrollar e integrar tarjetas visuales minimalistas e iconografía vectorial de alto contraste para cada uno de los 10 meses curriculares y sus momentos de sesión (apertura, fingerplay/concentración, núcleo TPR en inglés con pronunciación LJSpeech, y cierre afectivo), optimizadas para lectura inmediata y clara tanto a 2 metros en el aula como en la interacción cercana con el menor en el hogar.

### R3. Flujo Dual "Aula (Asamblea) / Hogar (Academy)" sin Fricción
Proporcionar un conmutador de contexto ágil entre la perspectiva del docente (asamblea matinal, instrucciones breves, temporizador sutil) y de las familias (explicación del porqué, guía de atención sin saturación, rutina breve de 3-5 min), garantizando que ambas partes puedan coordinar la estimulación sin recargar tareas administrativas.

## Acceptance Criteria

### Sincronización y Registro
- [ ] Desde la vista del calendario es posible iniciar directamente la sesión recomendada del día con un solo toque.
- [ ] Al completar o marcar una sesión en el aula o en el hogar, la fecha actualiza de forma reactiva el estado hacia «Doble Estimulación» en la interfaz compartida.
- [ ] La persistencia local soberana (`CalendarioStore`) refleja los cambios sin errores y de forma instantánea.

### Diseño Visual y Usabilidad
- [ ] Las tarjetas visuales e iconos vectoriales mantienen una relación de contraste y legibilidad óptima para visualización a distancia en la alfombra del aula.
- [ ] La interfaz preserva y extiende la paleta cromática atlántica cálida (aguamarina, coral suave, ámbar y menta) y la armonía con la mascota Lúa (`LuaPixel`).
- [ ] Cada tarjeta curricular ofrece acceso directo a la pronunciación modelo en inglés (`LJSpeech · piper`) y en gallego (`Celtia · Proxecto Nós`).

### Calidad Técnica y Verificación
- [ ] Todos los recursos gráficos declarados existen físicamente y sus extensiones coinciden al 100% con los archivos del repositorio.
- [ ] Las compuertas de calidad del repositorio (`tools/check_contact_email.py`, `tools/export_voice_corpus.py --check`, `tools/check_voice_coverage.py`, `tools/check_manual_build.py`, `tools/check_legal_urls.py --offline`) pasan con código de salida 0.
- [ ] La suite de pruebas de Flutter/Dart (`test/features/calendario/`, `test/core/`) compila y ejecuta todas las aserciones con éxito.

## Follow-up — 2026-09-14T13:15:17Z

Módulo específico de Asambleas de Infantil para colegios (Segundo Ciclo: 4.º, 5.º y 6.º de Educación Infantil, 3 a 6 años) en «Descubre con Lúa», fundamentado en Respuesta Física Total (TPR) en L3 (inglés) dentro del contexto trilingüe de Galicia (Decreto 150/2022), manteniendo estricta continuidad arquitectónica (Clean Architecture), diseño sobrio para el docente (cero pantallas para el alumnado), progresión curricular escalonada (vertical slice centrado en Septiembre para los tres niveles) y transferencia ecológica al hogar.

Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa
Integrity mode: development

### Referencia Metodológica y Curricular
- Marco normativo: Decreto 150/2022 de Galicia (Áreas: Comunicación e Representación da Realidade, Crecemento en Harmonía, Descubrimento e Exploración da Contorna).
- Arquitectura de la sesión matinal (8-10 minutos): 4 fases rítmicas (Opening / Greeting, Movement & Rhythmic Focus, Core TPR Challenge, Calm & Transition Out).
- Progresión neurocognitiva del TPR:
  - 4.º de Infantil (3-4 años): TPR de Acción Expandida (comandos de dos fases con "and", andamiaje decreciente con modelado y fading, respeto estricto al periodo de silencio fónico).
  - 5.º de Infantil (4-5 años): TPR Dramatizado y Narrativo (micro-narrativas de causa/efecto, juegos de inhibición selectiva stop-signal/freeze ante claves sintácticas/semánticas, praxias orofaciales ligadas a rimas dactilares).
  - 6.º de Infantil (5-6 años): TPR Transaccional y Juegos Pragmáticos (intercambio entre iguales peer-to-peer con tarjetas icónicas cue cards sin texto, categorización espacial y resolución cinestésica de problemas).
- Módulo Academy / Hogar: Principio Time and Place (nichos de 3-5 minutos) y modelado correctivo indirecto (recast), erradicando la evaluación frontal inhibitoria.

---

## Requirements

### R1. Modelo de Datos y Esquemas JSON para el Segundo Ciclo (4.º, 5.º y 6.º de Infantil)
Diseñar e implementar las estructuras de datos inmutables y esquemas JSON para el Segundo Ciclo de Educación Infantil, desacoplados y compatibles con la arquitectura de datos existente.
- Soportar la tipología metodológica TPR diferenciada por nivel (Acción Expandida, Dramatizado/Narrativo, Transaccional/Pragmático).
- Estructurar cada unidad de asamblea en las 4 fases canónicas: Opening/Greeting (1:30 min), Movement & Rhythmic Focus (2:00 min), Core TPR Challenge (4:30 min) y Calm & Transition Out (2:00 min).
- Incluir metadatos de vinculación curricular con el Decreto 150/2022, repertorio analógico no estructurado (materiales naturales del entorno gallego: mimbre, castañas, conchas, gasas) y el enlace a la micro-rutina doméstica.

### R2. Asistente de Aula para el Docente (Morning Circle / Asamblea Guiada 3-6 años)
Desarrollar la pantalla y componentes del flujo guiado de asamblea matinal orientados exclusivamente al docente (herramienta de trastienda / backstage, garantizando cero exposición de pantallas a los escolares).
- Interfaz de un vistazo (glanceable UI) en modo oscuro con tipografía de alto contraste (textos clave >= 24sp) legible a dos metros de distancia.
- Controles táctiles de gran formato (objetivos táctiles amplios) para avance de fases, temporizador discreto por fase y gestión de audio ambiental/pulsos con fundidos suaves (fade-in / fade-out automáticos).
- Selector de nivel (4.º, 5.º, 6.º de Infantil) integrado de manera continuista en la navegación principal sin romper el flujo del primer ciclo (0-3 años).

### R3. Vertical Slice Curricular (Mes Piloto: Septiembre) y Micro-rutinas para el Hogar
Crear los contenidos completos del mes piloto de inicio de curso ("Septiembre: Acollida, espazos escolares e novas rutinas") con diferenciación rigurosa para los 3 niveles:
- 4.º Infantil: Mandatos coordinados de bienvenida y rutinas de aula con modelado simultáneo.
- 5.º Infantil: Micro-narrativa física de la mochila y dinámicas de inhibición motriz con señales acústicas.
- 6.º Infantil: Dinámica peer-to-peer con tarjetas de apoyo icónico para acompañar a compañeros a sus perchas.
- Integrar en la sección de familias (Academy) la micro-rutina matinal doméstica asociada (autonomía en vestirse/colgar abrigos) con la guía pedagógica de modelado indirecto (recast).

### R4. Suite de Validación Curricular, Privacidad y Tests Automatizados
Extender la infraestructura de tests automatizados para blindar la calidad pedagógica y técnica:
- Validador curricular que compruebe la alineación con las 3 áreas del Decreto 150/2022 de Galicia y la ausencia total de términos patológicos o diagnósticos (lista negra clínica).
- Verificación de la integridad estructural de las 4 fases de la asamblea y paridad de contenidos.
- Tests de widgets que comprueben la navegación por fases de la asamblea y verifiquen la ausencia de elementos lúdicos o interactivos dirigidos a niños en la UI docente.
- Mantenimiento estricto del principio de cero dependencias de red y funcionamiento 100% offline.

---

## Acceptance Criteria

### Integridad de Modelos y Contenido
- [ ] Los modelos de datos del 2º ciclo compilan y cargan limpiamente las unidades de Septiembre para 4.º, 5.º y 6.º desde los assets JSON sin alterar ni romper los modelos y unidades del 1.er ciclo (0-3 años).
- [ ] El validador de contenido confirma la presencia de las 4 fases temporizadas en cada unidad de asamblea y la referencia explícita a las competencias y áreas del Decreto 150/2022 de Galicia.
- [ ] Cero apariciones de términos de la lista negra clínica en los nuevos textos curriculares y familiares.

### Experiencia Docente (UI/UX)
- [ ] La pantalla de asamblea guiada permite transitar fluidamente por las 4 fases (Opening, Rhythm, Core TPR, Calm) mostrando la guía textual concisa, los comandos en L3 y las acciones motrices sugeridas.
- [ ] Los controles de audio integran comandos de reproducción y parada compatibles con el servicio de audio offline de la aplicación.
- [ ] La interfaz utiliza el tema sobrio de la aplicación y pasa los tests de widgets sin presentar elementos de gamificación infantil.

### Integración en Navegación y Hogar
- [ ] La navegación de la app permite acceder de forma intuitiva tanto a las escuelas infantiles (1.er ciclo) como a los colegios / segundo ciclo (4.º, 5.º, 6.º).
- [ ] La micro-rutina familiar de Septiembre es accesible desde la sección correspondiente con sus pautas de recast claramente expuestas.

### Calidad de Código y Verificación
- [ ] La suite de tests automatizados (flutter test) se ejecuta con código de salida 0, incluyendo los nuevos tests de modelos, validación curricular y widgets de asamblea.
- [ ] Cero permisos de internet y cero llamadas de red introducidas en el proyecto.
