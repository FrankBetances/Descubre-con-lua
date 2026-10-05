// XERADO por tools/xera_nomes.py a partir de
// assets/content/nomes/nomes_portais.json. Non se edita a man: cámbiase o
// JSON e vólvese xerar con `python3 tools/xera_nomes.py`.

import '../../core/localization/localized_string.dart';

/// Los nombres llanos del Portal Docentes, en un solo sitio.
///
/// Salen del diccionario de la revisión de interfaz. Antes los grupos del
/// portal se llamaban «1. ASEMBLEA E AULA ACTIVA (72 BPM)» o «3. INMERSIÓN L3
/// E ESTRATEXIAS DOCENTES»: la numeración no marcaba un orden de uso, y «72
/// bpm» o «L3» no decían nada a quien llegaba.
class NomesDocentes {
  NomesDocentes._();

  // ---------------------------------------------------------------- pestañas
  static const hoxe = LocalizedString(gl: 'Hoxe', es: 'Hoy');
  static const calendario = LocalizedString(gl: 'Calendario', es: 'Calendario');
  static const recursos = LocalizedString(gl: 'Recursos', es: 'Recursos');
  static const eu = LocalizedString(gl: 'Eu', es: 'Yo');

  // ---------------------------------------------------------------- recursos
  static const paraAsemblea =
      LocalizedString(gl: 'Para a asemblea', es: 'Para la asamblea');
  static const paraPlanificar =
      LocalizedString(gl: 'Para planificar', es: 'Para planificar');
  static const ingles = LocalizedString(gl: 'Inglés', es: 'Inglés');
  static const paraSaberMais =
      LocalizedString(gl: 'Para saber máis', es: 'Para saber más');

  /// «Modo Aula» se queda: es el nombre con que se conoce ese sitio.
  static const asembleas = LocalizedString(
      gl: 'Xoga con Lúa · Modo Aula', es: 'Juega con Lúa · Modo Aula');

  /// En la cabecera de su pantalla: «Xoga con Lúa · Modo Aula» y «Juega con Lúa
  /// · Modo Aula» no caben enteros a 360 px.
  static const asembleasCabeceira =
      LocalizedString(gl: 'Xoga con Lúa', es: 'Juega con Lúa');
  static const asembleasDi = LocalizedString(
      gl: 'Todas as asembleas do 1.º e o 2.º ciclo, mes a mes.',
      es: 'Todas las asambleas del 1.º y el 2.º ciclo, mes a mes.');
  static const dinamicas =
      LocalizedString(gl: 'Dinámicas de aula', es: 'Dinámicas de aula');
  static const dinamicasDi = LocalizedString(
      gl: 'Unha para cada día, de luns a venres.',
      es: 'Una para cada día, de lunes a viernes.');
  static const ciencia =
      LocalizedString(gl: 'Ciencia coas mans', es: 'Ciencia con las manos');

  /// «Ciencia con las manos» no cabe a 360 px. La cabecera conserva «STEAM», el
  /// nombre con que se pidió el módulo.
  static const cienciaCabeceira =
      LocalizedString(gl: 'Ciencia · STEAM', es: 'Ciencia · STEAM');
  static const cienciaDi = LocalizedString(
      gl: 'STEAM: unha sesión por curso, o día que lle toca.',
      es: 'STEAM: una sesión por curso, el día que le toca.');

  /// Frank: «solo deja planificador curricular».
  static const programacion = LocalizedString(
      gl: 'Planificador curricular', es: 'Planificador curricular');

  /// En la cabecera de su pantalla: «Planificador curricular» no cabe entero a
  /// 360 px.
  static const programacionCabeceira =
      LocalizedString(gl: 'Planificador', es: 'Planificador');
  static const programacionDi = LocalizedString(
      gl: 'Obxectivos e actividades dos 5 cursos, segundo o Decreto 150/2022.',
      es: 'Objetivos y actividades de los 5 cursos, según el Decreto 150/2022.');
  static const palabrasCurso =
      LocalizedString(gl: 'Palabras do curso', es: 'Palabras del curso');
  static const palabrasCursoDi = LocalizedString(
      gl: '5 ao día, 800 por curso, con voz e xesto.',
      es: '5 al día, 800 por curso, con voz y gesto.');

  /// O inglés vai por partes, unha porta para cada unha. Antes estaban detrás
  /// de «Inglés na aula», que repetía as palabras do curso e o vocabulario.
  static const repaso = LocalizedString(gl: 'O repaso', es: 'El repaso');
  static const repasoDi = LocalizedString(
      gl: 'As palabras de hoxe e as que xa saíron, cada unha cando toca. Gárdase no aparello.',
      es: 'Las palabras de hoy y las que ya salieron, cada una cuando toca. Se guarda en el aparato.');
  static const escoita =
      LocalizedString(gl: 'Frases do curso', es: 'Frases del curso');
  static const escoitaDi = LocalizedString(
      gl: 'As frases e ordes de cada mes: escoitar, entender e facer o xesto.',
      es: 'Las frases y órdenes de cada mes: escuchar, entender y hacer el gesto.');
  static const colocacions =
      LocalizedString(gl: 'Colocacións', es: 'Colocaciones');
  static const colocacionsDi = LocalizedString(
      gl: 'Combinacións fixas do día a día, como «wash your hands», co seu son.',
      es: 'Combinaciones fijas del día a día, como «wash your hands», con su sonido.');
  static const sons =
      LocalizedString(gl: 'Sons do inglés', es: 'Sonidos del inglés');
  static const sonsDi = LocalizedString(
      gl: 'Os 44 fonemas, con palabra de exemplo, son e como se articulan.',
      es: 'Los 44 fonemas, con palabra de ejemplo, sonido y cómo se articulan.');
  static const vocabulario = LocalizedString(
      gl: 'Vocabulario de uso habitual', es: 'Vocabulario de uso habitual');

  /// En la cabecera de su pantalla: «Vocabulario de uso habitual» no cabe
  /// entero a 360 px.
  static const vocabularioCabeceira =
      LocalizedString(gl: 'Vocabulario', es: 'Vocabulario');
  static const vocabularioDi = LocalizedString(
      gl: '3.995 palabras do inglés, con definición e exemplo.',
      es: '3.995 palabras del inglés, con definición y ejemplo.');
  static const estratexias =
      LocalizedString(gl: 'Estratexias de aula', es: 'Estrategias de aula');

  /// «Estratexias de aula» y «Estrategias de aula» quedan justo en el borde de
  /// la cabecera a 360 px: con la letra del sistema un poco mayor ya se
  /// cortarían.
  static const estratexiasCabeceira =
      LocalizedString(gl: 'Estratexias', es: 'Estrategias');
  static const estratexiasDi = LocalizedString(
      gl: 'Cinco estratexias, cada unha cun diálogo de exemplo.',
      es: 'Cinco estrategias, cada una con un diálogo de ejemplo.');

  // ---------------------------------------------------------------------- eu
  static const antesDeEntrar = LocalizedString(
      gl: 'Antes de entrar na aula', es: 'Antes de entrar en el aula');

  /// En la cabecera de su pantalla: «Antes de entrar na aula» y «Antes de
  /// entrar en el aula» no caben enteros a 360 px.
  static const antesDeEntrarCabeceira =
      LocalizedString(gl: 'Antes de entrar', es: 'Antes de entrar');
  static const antesDeEntrarDi = LocalizedString(
      gl: 'Como usar a app na asemblea, en dous minutos.',
      es: 'Cómo usar la app en la asamblea, en dos minutos.');
  static const formacion =
      LocalizedString(gl: 'Formación na aula', es: 'Formación en el aula');

  /// «Formación en el aula» no cabe a 360 px; las dos lenguas llevan la misma
  /// forma corta.
  static const formacionCabeceira =
      LocalizedString(gl: 'Formación', es: 'Formación');
  static const formacionDi = LocalizedString(
      gl: 'Os seis pasos da asemblea, unha lectura curta por paso.',
      es: 'Los seis pasos de la asamblea, una lectura corta por paso.');

  /// El título de los premios de la docente, que abre su nivel en «Eu».
  static const premios =
      LocalizedString(gl: 'Os teus premios', es: 'Tus premios');
}
