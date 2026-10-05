// XERADO por tools/xera_nomes.py a partir de
// assets/content/nomes/nomes_portais.json. Non se edita a man: cámbiase o
// JSON e vólvese xerar con `python3 tools/xera_nomes.py`.

import '../../core/localization/localized_string.dart';

/// Os textos do inicio: unha pregunta e dúas respostas grandes.
///
/// «Na casa» e «Na escola» din onde se usa a app, non a quen pertence. A
/// resposta non se garda: gardala sería un dato máis que declarar en Play.
class NomesInicio {
  NomesInicio._();

  // ------------------------------------------------------------------ inicio
  static const pregunta =
      LocalizedString(gl: 'Onde vas usala?', es: '¿Dónde la vas a usar?');
  static const casa = LocalizedString(gl: 'Na casa', es: 'En casa');
  static const casaDi = LocalizedString(
      gl: 'Tres minutos ao día coa túa criatura',
      es: 'Tres minutos al día con tu criatura');
  static const escola = LocalizedString(gl: 'Na escola', es: 'En la escuela');
  static const escolaDi = LocalizedString(
      gl: 'A asemblea de cada día', es: 'La asamblea de cada día');
  static const quenFaiIsto =
      LocalizedString(gl: 'Quen fai isto', es: 'Quién hace esto');
  static const privacidade = LocalizedString(
      gl: 'Sen datos, sen contas e sen conexión',
      es: 'Sin datos, sin cuentas y sin conexión');
}
