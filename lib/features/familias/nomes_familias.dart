// XERADO por tools/xera_nomes.py a partir de
// assets/content/nomes/nomes_portais.json. Non se edita a man: cámbiase o
// JSON e vólvese xerar con `python3 tools/xera_nomes.py`.

import '../../core/localization/localized_string.dart';

/// Los nombres de casa del Portal Familias, en un solo sitio.
///
/// Salen del diccionario de la revisión de interfaz: un nombre que diría una
/// familia y una frase de menos de quince palabras. Antes eran «Biblioteca de
/// Contos Dialóxicos», «Aprender a Ler · Fónica Manipulativa» o «Academy ·
/// Pautas de Crianza», y la teoría iba delante de lo que hay que hacer.
class NomesFamilias {
  NomesFamilias._();

  // ---------------------------------------------------------------- pestañas
  static const hoxe = LocalizedString(gl: 'Hoxe', es: 'Hoy');
  static const calendario = LocalizedString(gl: 'Calendario', es: 'Calendario');
  static const explorar = LocalizedString(gl: 'Explorar', es: 'Explorar');
  static const guias = LocalizedString(gl: 'Guías', es: 'Guías');

  // ---------------------------------------------------------------- explorar
  static const contos = LocalizedString(gl: 'Contos', es: 'Cuentos');
  static const contosDi = LocalizedString(
      gl: 'O da semana, primeiro', es: 'El de la semana, primero');
  static const ingles =
      LocalizedString(gl: 'Palabras en inglés', es: 'Palabras en inglés');
  static const inglesDi = LocalizedString(
      gl: 'As de cada día, con voz', es: 'Las de cada día, con voz');
  static const movemento =
      LocalizedString(gl: 'Xogos de movemento', es: 'Juegos de movimiento');

  /// En la cabecera de su pantalla: «Xogos de movemento» y «Juegos de
  /// movimiento» no caben enteros a 360 px.
  static const movementoCabeceira = LocalizedString(gl: 'Xogos', es: 'Juegos');
  static const movementoDi =
      LocalizedString(gl: 'Curtos e sen pantalla', es: 'Cortos y sin pantalla');
  static const ler = LocalizedString(gl: 'Ler xogando', es: 'Leer jugando');
  static const lerDi = LocalizedString(
      gl: 'Sons e letras coas mans', es: 'Sonidos y letras con las manos');
  static const laminas = LocalizedString(gl: 'Láminas', es: 'Láminas');
  static const laminasDi = LocalizedString(
      gl: 'Para mirar xuntos e falar', es: 'Para mirar juntos y hablar');
  static const ciencia =
      LocalizedString(gl: 'Ciencia coas mans', es: 'Ciencia con las manos');

  /// «Ciencia con las manos» no cabe a 360 px. La cabecera conserva «STEAM», el
  /// nombre con que se pidió el módulo.
  static const cienciaCabeceira =
      LocalizedString(gl: 'Ciencia · STEAM', es: 'Ciencia · STEAM');

  /// «STEAM» a la vista: es el nombre con que se pidió el módulo.
  static const cienciaDi = LocalizedString(
      gl: 'STEAM: un xogo por idade', es: 'STEAM: un juego por edad');

  // ------------------------------------------------------------------- guías
  static const antesDeEmpezar =
      LocalizedString(gl: 'Antes de empezar', es: 'Antes de empezar');
  static const antesDeEmpezarDi = LocalizedString(
      gl: 'Como usar a app na casa, en dous minutos.',
      es: 'Cómo usar la app en casa, en dos minutos.');
  static const guiasFamilia =
      LocalizedString(gl: 'Guías para a familia', es: 'Guías para la familia');

  /// En la cabecera de su pantalla: «Guías para a familia» y «Guías para la
  /// familia» no caben enteros a 360 px.
  static const guiasFamiliaCabeceira =
      LocalizedString(gl: 'Guías', es: 'Guías');
  static const guiasFamiliaDi = LocalizedString(
      gl: 'Lecturas curtas para ti: como falar e xogar coa túa criatura.',
      es: 'Lecturas cortas para ti: cómo hablar y jugar con tu criatura.');
  static const inglesNaCasa =
      LocalizedString(gl: 'O inglés na casa', es: 'El inglés en casa');
  static const inglesNaCasaDi = LocalizedString(
      gl: 'Canto dura o xogo segundo a idade e como se di cada frase.',
      es: 'Cuánto dura el juego según la edad y cómo se dice cada frase.');
  static const premios =
      LocalizedString(gl: 'Os teus premios', es: 'Tus premios');
  static const premiosDi = LocalizedString(
      gl: 'Lúa celebra a túa constancia: días seguidos e lecturas feitas.',
      es: 'Lúa celebra tu constancia: días seguidos y lecturas hechas.');

  // ------------------------------------------------------------- ler xogando
  static const lerPestanaSons = LocalizedString(
      gl: '1. Conciencia fonolóxica', es: '1. Conciencia fonológica');
  static const lerPestanaLetras =
      LocalizedString(gl: '2. Colocar letras', es: '2. Colocar letras');
  static const lerPestanaCubos =
      LocalizedString(gl: '3. Xuntar cubos', es: '3. Juntar cubos');
  static const lerPestanaPares =
      LocalizedString(gl: '4. Pares mínimos', es: '4. Pares mínimos');

  // ------------------------------------------------------------------ idades
  /// Las cinco edades, con la clave de su curso. La elegida vive mientras la
  /// app está abierta: la app no guarda nada de ninguna criatura.
  static const idades = <(String, LocalizedString)>[
    ('curso_0_2', LocalizedString(gl: '0-2 anos', es: '0-2 años')),
    ('curso_2_3', LocalizedString(gl: '2-3 anos', es: '2-3 años')),
    ('curso_3_4', LocalizedString(gl: '3-4 anos', es: '3-4 años')),
    ('curso_4_5', LocalizedString(gl: '4-5 anos', es: '4-5 años')),
    ('curso_5_6', LocalizedString(gl: '5-6 anos', es: '5-6 años')),
  ];

  static LocalizedString idade(String cursoId) =>
      idades.firstWhere((e) => e.$1 == cursoId, orElse: () => idades.first).$2;
}
