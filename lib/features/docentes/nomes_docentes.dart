import '../../core/localization/localized_string.dart';

/// Los nombres llanos del Portal Docentes, en un solo sitio.
///
/// Salen del diccionario de la revisión de interfaz. Antes los grupos del
/// portal se llamaban «1. ASEMBLEA E AULA ACTIVA (72 BPM)» o «3. INMERSIÓN L3
/// E ESTRATEXIAS DOCENTES»: la numeración no marcaba un orden de uso, y «72
/// bpm» o «L3» no decían nada a quien llegaba.
class NomesDocentes {
  NomesDocentes._();

  // ------------------------------------------------------------ pestañas
  static const hoxe = LocalizedString(gl: 'Hoxe', es: 'Hoy');
  static const calendario = LocalizedString(gl: 'Calendario', es: 'Calendario');
  static const recursos = LocalizedString(gl: 'Recursos', es: 'Recursos');
  static const eu = LocalizedString(gl: 'Eu', es: 'Yo');

  // ------------------------------------------------------------ recursos
  static const paraAsemblea =
      LocalizedString(gl: 'Para a asemblea', es: 'Para la asamblea');
  static const paraPlanificar =
      LocalizedString(gl: 'Para planificar', es: 'Para planificar');
  static const ingles = LocalizedString(gl: 'Inglés', es: 'Inglés');
  static const paraSaberMais =
      LocalizedString(gl: 'Para saber máis', es: 'Para saber más');

  // «Modo Aula» se queda: es el nombre con que se conoce ese sitio.
  static const asembleas = LocalizedString(
      gl: 'Xoga con Lúa · Modo Aula', es: 'Juega con Lúa · Modo Aula');
  static const asembleasDi = LocalizedString(
    gl: 'Todas as asembleas do 1.º e o 2.º ciclo, mes a mes.',
    es: 'Todas las asambleas del 1.º y el 2.º ciclo, mes a mes.',
  );
  static const dinamicas =
      LocalizedString(gl: 'Dinámicas de aula', es: 'Dinámicas de aula');
  static const dinamicasDi = LocalizedString(
    gl: 'Unha para cada día, de luns a venres.',
    es: 'Una para cada día, de lunes a viernes.',
  );
  static const ciencia =
      LocalizedString(gl: 'Ciencia coas mans', es: 'Ciencia con las manos');
  static const cienciaDi = LocalizedString(
    gl: 'STEAM: unha sesión por curso, o día que lle toca.',
    es: 'STEAM: una sesión por curso, el día que le toca.',
  );
  // Frank: «solo deja planificador curricular».
  static const programacion = LocalizedString(
    gl: 'Planificador curricular',
    es: 'Planificador curricular',
  );
  static const programacionDi = LocalizedString(
    gl: 'Obxectivos e actividades dos 5 cursos, segundo o Decreto 150/2022.',
    es: 'Objetivos y actividades de los 5 cursos, según el Decreto 150/2022.',
  );
  static const palabrasCurso =
      LocalizedString(gl: 'Palabras do curso', es: 'Palabras del curso');
  static const palabrasCursoDi = LocalizedString(
    gl: '5 ao día, 800 por curso, con voz e xesto.',
    es: '5 al día, 800 por curso, con voz y gesto.',
  );
  static const inglesAula =
      LocalizedString(gl: 'Inglés na aula', es: 'Inglés en el aula');
  static const inglesAulaDi = LocalizedString(
    gl: 'O repaso, as frases do mes, as colocacións e os 44 sons.',
    es: 'El repaso, las frases del mes, las colocaciones y los 44 sonidos.',
  );
  static const vocabulario = LocalizedString(
    gl: 'Vocabulario de uso habitual',
    es: 'Vocabulario de uso habitual',
  );
  static const vocabularioDi = LocalizedString(
    gl: '3.995 palabras do inglés, con definición e exemplo.',
    es: '3.995 palabras del inglés, con definición y ejemplo.',
  );
  static const estratexias =
      LocalizedString(gl: 'Estratexias de aula', es: 'Estrategias de aula');
  static const estratexiasDi = LocalizedString(
    gl: 'Cinco estratexias, cada unha cun diálogo de exemplo.',
    es: 'Cinco estrategias, cada una con un diálogo de ejemplo.',
  );

  // ------------------------------------------------------------------ eu
  static const antesDeEntrar = LocalizedString(
      gl: 'Antes de entrar na aula', es: 'Antes de entrar en el aula');
  static const antesDeEntrarDi = LocalizedString(
    gl: 'Como usar a app na asemblea, en dous minutos.',
    es: 'Cómo usar la app en la asamblea, en dos minutos.',
  );
  static const formacion =
      LocalizedString(gl: 'Formación na aula', es: 'Formación en el aula');
  static const formacionDi = LocalizedString(
    gl: 'Os seis pasos da asemblea, unha lectura curta por paso.',
    es: 'Los seis pasos de la asamblea, una lectura corta por paso.',
  );
}
