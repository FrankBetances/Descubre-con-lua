# Dispatch Log

## 2026-09-13T09:05:35Z
You are teamwork_preview_orchestrator_2, the top-level Project Orchestrator for «Descubre con Lúa · Edición Vigo».

Your working directory is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_2

The project workspace root is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Read the authoritative user request at:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md
(Focus on the follow-up request dated 2026-09-13T09:04:47Z).

The objectives and acceptance criteria are:
1. R1. Sincronización intuitiva y a un toque con el calendario escolar (Decreto 150/2022, 10 meses).
   - Iniciar sesión recomendada del día con un solo toque desde la vista de calendario.
   - Actualización reactiva hacia «Doble Estimulación» al completar/marcar sesión en aula o en hogar.
   - Persistencia local soberana con CalendarioStore sin errores e instantánea.
2. R2. Sistema de tarjetas visuales e iconografía vectorial de alto contraste y diseño minimalista.
   - Para cada uno de los 10 meses curriculares y sus momentos de sesión (apertura, fingerplay/concentración, núcleo TPR en inglés con pronunciación LJSpeech, y cierre afectivo).
   - Visibilidad rápida a distancia (alfombra de aula a 2m e interacción cercana en hogar).
   - Acceso directo a pronunciación modelo en inglés (LJSpeech · piper) y en gallego (Celtia · Proxecto Nós).
   - Paleta cromática atlántica cálida (aguamarina, coral suave, ámbar y menta) y armonía con LuaPixel.
   - Cero asunciones de archivos y recursos estáticos: verificar físicamente nombres y extensiones.
3. R3. Flujo Dual «Aula (Asamblea) / Hogar (Academy)» sin fricción.
   - Conmutador de contexto ágil entre docente (asamblea, instrucciones breves, temporizador sutil) y familias (explicación del porqué, guía de atención sin saturación, micro-rutina 3-5 min).
4. Verificación y Calidad Técnica:
   - Todos los recursos gráficos declarados existen físicamente y sus extensiones coinciden al 100%.
   - Compuertas de calidad del repositorio:
     * tools/check_contact_email.py
     * tools/export_voice_corpus.py --check
     * tools/check_voice_coverage.py
     * tools/check_manual_build.py
     * tools/check_legal_urls.py --offline
     Todas deben salir con código 0.
   - Suite de pruebas Flutter/Dart (test/features/calendario/, test/core/, etc.) compilando y pasando al 100%.
