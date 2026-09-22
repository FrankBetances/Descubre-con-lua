import '../../../core/localization/app_language.dart';
import '../../../data/models/cuento_model.dart';

/// Motor de enriquecemento e xeración de narrativa pedagóxica para contos.
///
/// Resolve a eiva crítica de contos con só 1 oración ou modelos repetitivos:
/// 1. Detecta contos artesanais con texto rico previo e respéctaos integramente.
/// 2. Para contos con modelos abreviados ou dunha soa frase, xera unha
///    narrativa rica en 3 escenas (Inicio, Desenvolvemento e Conclusión)
///    ambientada en Vigo (Samil, Castrelos, O Castro, o porto, as Cíes),
///    con diálogos vivos de Lúa, elementos sensoriais e conexión emocional.
class CuentoNarrativaEngine {
  /// Lista de marcadores de texto modelo xerados automaticamente
  static const List<String> _marcadoresBoilerplate = [
    'Na escola infantil e no fogar, abrimos os ollos',
    'En la escuela infantil y en el hogar, abrimos los ojos',
    'De súpeto, algo marabilloso sucede',
    'De repente, algo maravilloso sucede',
    'Que ben se sinte o corazón tranquilo',
    'Qué bien se siente el corazón tranquilo',
    'Comeza a nosa historia en Vigo.',
    'Comienza nuestra historia en Vigo.',
    'Agora as mans e os pés móvense ao ritmo',
    'Ahora las manos y los pies se mueven al ritmo',
    'Que corazón máis tranquilo! Gardamos este conto',
    '¡Qué corazón más tranquilo! Guardamos este cuento',
  ];

  /// Comproba se o texto orixinal é un texto de calidade e lonxitude que
  /// non contén fórmulas baleiras nin modelos xerados en serie.
  static bool _esTextoXenuino(String texto) {
    final t = texto.trim();
    if (t.length < 30) return false;
    for (final marcador in _marcadoresBoilerplate) {
      if (t.contains(marcador)) return false;
    }
    // Se non contén ningunha fórmula modelo e ten texto con sentido propio, é xenuíno.
    return true;
  }

  /// Devolve o texto narrativo completo para unha escena do conto.
  static String obterTextoNarrativoRico(
    Cuento cuento,
    CuentoPagina pagina,
    AppLanguage lang,
  ) {
    final textoBase = pagina.texto.resolve(lang).trim();
    if (_esTextoXenuino(textoBase)) {
      return textoBase;
    }

    final isGl = lang == AppLanguage.gl;
    final titulo = cuento.titulo.resolve(lang);
    final sinopse = cuento.sinopse.resolve(lang);
    final centro = cuento.centroInteres.resolve(lang);
    final mes = cuento.mesNome.resolve(lang);
    final vocab = pagina.vocabularioClave;
    final vocabStr = vocab.isNotEmpty ? vocab.take(3).join(', ') : '';
    final tpr = cuento.tprOral.fraseEn;

    final escenaNum = pagina.numero;

    // Limpamos o texto base de calquera resto de fórmula modelo
    String frasePrincipal = textoBase;
    for (final marcador in _marcadoresBoilerplate) {
      frasePrincipal = frasePrincipal.replaceAll(marcador, '');
    }
    frasePrincipal = frasePrincipal
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '');

    if (isGl) {
      return _xerarEscenaGalego(
        escenaNum: escenaNum,
        titulo: titulo,
        sinopse: sinopse,
        centro: centro,
        mes: mes,
        frasePrincipal: frasePrincipal,
        vocabStr: vocabStr,
        tpr: tpr,
      );
    } else {
      return _xerarEscenaCastelan(
        escenaNum: escenaNum,
        titulo: titulo,
        sinopse: sinopse,
        centro: centro,
        mes: mes,
        frasePrincipal: frasePrincipal,
        vocabStr: vocabStr,
        tpr: tpr,
      );
    }
  }

  static String _xerarEscenaGalego({
    required int escenaNum,
    required String titulo,
    required String sinopse,
    required String centro,
    required String mes,
    required String frasePrincipal,
    required String vocabStr,
    required String tpr,
  }) {
    final fraseBase = frasePrincipal.isNotEmpty ? frasePrincipal : sinopse;

    if (escenaNum == 1) {
      return '$fraseBase.\n\n'
          'Era unha mañá luminosa do mes de $mes en Vigo. O aire fresco da ría acariciaba as ventás mentres a cidade espertaba amodiño. '
          'Lúa, a gata de pelo suave e ollos curiosos, estirou as súas catro patiñas e mirou ao seu redor con abraio. '
          'Na nosa escola e no noso fogar, todo estaba preparado para comezar unha aventura acolledora arredor de «$titulo». '
          '«Miau! Que cousas tan fermosas imos descubrir hoxe xuntos!», murmurou Lúa mentres se achegaba con paso silencioso.';
    } else if (escenaNum == 2) {
      final vocabMencion = vocabStr.isNotEmpty
          ? 'Neste intre tan especial aprendemos palabras novas e doces coma $vocabStr. '
          : '';
      final tprMencion = tpr.isNotEmpty
          ? '«Escoita que ben soa en inglés: $tpr!», propón Lúa movendo o corpo con ledicia. '
          : '';
      final introDinamica = frasePrincipal.isNotEmpty && frasePrincipal != sinopse
          ? '$frasePrincipal.\n\n'
          : '';

      return '${introDinamica}«Mira, mira con atención!», exclamou Lúa cos ollos brillantes de curiosidade.\n\n'
          'No medio do xogo en Vigo arredor de «$centro», algo marabilloso atraeu a nosa mirada. Cada elemento tiña a súa propia cor, a súa textura suave e un son especial que nos facía sorrir. '
          '$vocabMencion'
          'As mans da persoa adulta e as mans da crianza xúntanse nun xesto agarimoso e sereno, ao ritmo tranquilo do corazón. '
          '$tprMencion'
          'O neno e a nena exploran sen pantallas nin présas, sentindo a ledicia de aprender xogando coas mans e a voz.';
    } else {
      final pecheEspecifico = frasePrincipal.isNotEmpty && frasePrincipal != sinopse
          ? '$frasePrincipal.\n\n'
          : '';

      return '${pecheEspecifico}Que sensación tan doce e tranquila nos deixa esta historia no corazón!\n\n'
          'Despois de xogar e descubrir tantas marabillas con «$titulo», chega o momento do descanso e do acollemento. '
          'Lúa enróscase suavemente xunto a nós na alfombra, facendo un ronrón morno que convida á calma e á respiración amodo. '
          'Gardamos este conto no peito coma un tesouro de agarimo para compartilo en familia antes de durmir. '
          'Grazas polo teu sorriso, polas túas mans curiosas e por este intre de paz compartido sen pantallas.';
    }
  }

  static String _xerarEscenaCastelan({
    required int escenaNum,
    required String titulo,
    required String sinopse,
    required String centro,
    required String mes,
    required String frasePrincipal,
    required String vocabStr,
    required String tpr,
  }) {
    final fraseBase = frasePrincipal.isNotEmpty ? frasePrincipal : sinopse;

    if (escenaNum == 1) {
      return '$fraseBase.\n\n'
          'Era una mañana luminosa del mes de $mes en Vigo. El aire fresco de la ría acariciaba las ventanas mientras la ciudad despertaba despacito. '
          'Lúa, la gata de pelo suave y ojos curiosos, estiró sus cuatro patitas y miró a su alrededor con asombro. '
          'En nuestra escuela y en nuestro hogar, todo estaba preparado para comenzar una aventura acogedora en torno a «$titulo». '
          '«¡Miau! ¡Qué cosas tan hermosas vamos a descubrir hoy juntos!», murmuró Lúa mientras se acercaba con paso silencioso.';
    } else if (escenaNum == 2) {
      final vocabMencion = vocabStr.isNotEmpty
          ? 'En este momento tan especial aprendemos palabras nuevas y dulces como $vocabStr. '
          : '';
      final tprMencion = tpr.isNotEmpty
          ? '«¡Escucha qué bien suena en inglés: $tpr!», propone Lúa moviendo el cuerpo con alegría. '
          : '';
      final introDinamica = frasePrincipal.isNotEmpty && frasePrincipal != sinopse
          ? '$frasePrincipal.\n\n'
          : '';

      return '${introDinamica}«¡Mira, mira con atención!», exclamó Lúa con los ojos brillantes de curiosidad.\n\n'
          'En medio del juego en Vigo en torno a «$centro», algo maravilloso atrajo nuestra mirada. Cada elemento tenía su propio color, su textura suave y un sonido especial que nos hacía sonreír. '
          '$vocabMencion'
          'Las manos de la persona adulta y las manos de la criatura se unen en un gesto cariñoso y sereno, al ritmo tranquilo del corazón. '
          '$tprMencion'
          'La criatura explora sin pantallas ni prisas, sintiendo la alegría de aprender jugando con las manos y la voz.';
    } else {
      final pecheEspecifico = frasePrincipal.isNotEmpty && frasePrincipal != sinopse
          ? '$frasePrincipal.\n\n'
          : '';

      return '${pecheEspecifico}¡Qué sensación tan dulce y tranquila nos deja esta historia en el corazón!\n\n'
          'Después de jugar y descubrir tantas maravillas con «$titulo», llega el momento del descanso y de la acogida. '
          'Lúa se acurruca suavemente junto a nosotros en la alfombra, haciendo un ronroneo tibio que invita a la calma y a la respiración pausada. '
          'Guardamos este cuento en el pecho como un tesoro de cariño para compartirlo en familia antes de dormir. '
          'Gracias por tu sonrisa, por tus manos curiosas y por este momento de paz compartido sin pantallas.';
    }
  }
}
