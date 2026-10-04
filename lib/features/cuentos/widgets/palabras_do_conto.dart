import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../calendario/widgets/palabras_do_dia.dart';

/// Un trozo del texto de una página: o es texto de la lengua de la app, o es
/// una palabra inglesa (lo que va entre “…”).
typedef TrozoDoTexto = ({String texto, bool ingles});

/// Las palabras inglesas de la semana dentro de su cuento.
///
/// **Por qué existe.** Las cinco palabras del día y el cuento de la semana
/// llegaban por caminos separados: la docente decía cinco palabras en la
/// asamblea y leía un cuento que no traía ninguna. Ahora el cuento de cada
/// semana lleva sus veinte palabras —en el texto, entre “…”, y declaradas en
/// la página donde salen— y esta clase dice cuáles son, en qué página está
/// cada una y cuáles son las de hoy.
///
/// Las palabras salen del curso TPR (`assets/content/tpr/`), no de aquí.
class PalabrasNoConto {
  final Cuento cuento;

  /// La semana del curso a la que pertenece el cuento. Sin ella, las
  /// palabras se pintan con el significado que trae la propia página.
  final SemanaTpr? semana;

  /// 1 (lunes) a 5 (viernes) cuando el cuento se abre desde el día; `null`
  /// desde la biblioteca, donde no hay «hoy».
  final int? dia;

  final Map<String, TprWord> _porClave;

  PalabrasNoConto({required this.cuento, this.semana, this.dia})
      : _porClave = {
          for (final p in semana?.palabras ?? const <TprWord>[]) clave(p.en): p,
        };

  /// La misma clave con la que el cuento y el curso se casan: minúsculas,
  /// sin la puntuación del final y con los espacios simples. «Bee rhymes
  /// with tree!» en el texto es «Bee rhymes with tree» en el curso.
  static String clave(String texto) => texto
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\s.!?,;:…]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  /// El texto partido en trozos: lo que va entre “…” es inglés, con las
  /// comillas dentro, que son lo que la docente ve en el papel.
  static List<TrozoDoTexto> trozos(String texto) {
    final saida = <TrozoDoTexto>[];
    var desde = 0;
    for (final m in RegExp(r'“[^”]*”').allMatches(texto)) {
      if (m.start > desde) {
        saida.add((texto: texto.substring(desde, m.start), ingles: false));
      }
      saida.add((texto: m.group(0)!, ingles: true));
      desde = m.end;
    }
    if (desde < texto.length) {
      saida.add((texto: texto.substring(desde), ingles: false));
    }
    return saida;
  }

  /// El plan del día, si el cuento se abrió desde un día.
  DailyTprPlan? get plan {
    final s = semana;
    final d = dia;
    if (s == null || d == null) return null;
    return s.planDoDia(d);
  }

  /// Las claves de las palabras de hoy: las cinco nuevas de lunes a jueves y
  /// las veinte el viernes, que es el día del reto. Vacío sin día.
  Set<String> get _clavesDeHoxe {
    final p = plan;
    if (p == null) return const {};
    final palabras = p.eReto ? p.reviewWords : p.newWords;
    return {for (final w in palabras) clave(w.en)};
  }

  bool eDeHoxe(String en) => _clavesDeHoxe.contains(clave(en));

  /// ¿Hay alguna palabra de la semana en el cuento? Los cuentos del banco no
  /// llevan ninguna, y entonces nada de esto se pinta.
  bool get levaPalabras => cuento.paginas.any((p) => p.palabras.isNotEmpty);

  /// La palabra del curso para un inglés de la página. Si la semana no está
  /// cargada, una palabra hecha con lo que trae la propia página: el inglés
  /// y su significado, sin gesto.
  TprWord palabraDaPaxina(CuentoPagina pagina, String en) {
    final doCurso = _porClave[clave(en)];
    if (doCurso != null) return doCurso;
    final i = pagina.palabras.indexOf(en);
    String glosa(List<String> lista) =>
        i >= 0 && i < lista.length ? lista[i] : '';
    return TprWord(
      id: '',
      en: en,
      gl: glosa(pagina.vocabularioClave),
      es: glosa(pagina.vocabularioClaveEs.isEmpty
          ? pagina.vocabularioClave
          : pagina.vocabularioClaveEs),
      tprAction: const LocalizedString(gl: '', es: ''),
      category: '',
    );
  }

  /// Las palabras que se buscan en el cuento, cada una con la página (1..n)
  /// en que sale por primera vez: las de hoy si hay día, las veinte de la
  /// semana si no. En el orden del curso, que es el de los días.
  List<({TprWord palabra, int paxina})> conPaxina() {
    final p = plan;
    final buscadas = p == null
        ? (semana?.palabras ?? const <TprWord>[])
        : (p.eReto ? p.reviewWords : p.newWords);
    final saida = <({TprWord palabra, int paxina})>[];
    for (final w in buscadas) {
      final c = clave(w.en);
      for (var i = 0; i < cuento.paginas.length; i++) {
        if (cuento.paginas[i].palabras.any((e) => clave(e) == c)) {
          saida.add((palabra: w, paxina: i + 1));
          break;
        }
      }
    }
    return saida;
  }
}

/// El texto de la página con el inglés resaltado: en el acento del portal, y
/// además con fondo si es una palabra de hoy.
TextSpan textoConPalabras({
  required String texto,
  required TextStyle estilo,
  required PalabrasNoConto palabras,
  required Color acento,
}) {
  return TextSpan(
    style: estilo,
    children: [
      for (final t in PalabrasNoConto.trozos(texto))
        if (!t.ingles)
          TextSpan(text: t.texto)
        else
          TextSpan(
            text: t.texto,
            style: TextStyle(
              color: acento,
              fontWeight: FontWeight.w800,
              backgroundColor:
                  palabras.eDeHoxe(t.texto.substring(1, t.texto.length - 1))
                      ? acento.withAlpha(36)
                      : null,
            ),
          ),
    ],
  );
}

/// La cabecera del cuento abierto desde un día: qué palabras de hoy trae y en
/// qué página está cada una. Tocar una lleva a su página.
class CabeceiraPalabrasDoConto extends StatefulWidget {
  final PalabrasNoConto palabras;
  final AppLanguage language;
  final ValueChanged<int> onIrAPaxina;

  const CabeceiraPalabrasDoConto({
    super.key,
    required this.palabras,
    required this.language,
    required this.onIrAPaxina,
  });

  @override
  State<CabeceiraPalabrasDoConto> createState() =>
      _CabeceiraPalabrasDoContoState();
}

class _CabeceiraPalabrasDoContoState extends State<CabeceiraPalabrasDoConto> {
  /// Cinco palabras caben a la vista; veinte, no: el viernes y en la
  /// biblioteca la lista empieza cerrada para no tapar el cuento.
  late bool _aberta =
      widget.palabras.conPaxina().length <= WeeklyTprScheduler.palabrasPorDia;

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final lista = widget.palabras.conPaxina();
    if (lista.isEmpty) return const SizedBox.shrink();
    final plan = widget.palabras.plan;

    final String rotulo;
    if (plan == null) {
      rotulo = isGl
          ? 'AS ${lista.length} PALABRAS DA SEMANA ESTÁN NESTE CONTO'
          : 'LAS ${lista.length} PALABRAS DE LA SEMANA ESTÁN EN ESTE CUENTO';
    } else if (plan.eReto) {
      rotulo = isGl
          ? 'RETO DO VENRES: AS ${lista.length} PALABRAS DA SEMANA ESTÁN NESTE CONTO'
          : 'RETO DEL VIERNES: LAS ${lista.length} PALABRAS DE LA SEMANA ESTÁN EN ESTE CUENTO';
    } else {
      rotulo = isGl
          ? 'AS ${lista.length} PALABRAS DE HOXE ESTÁN NESTE CONTO'
          : 'LAS ${lista.length} PALABRAS DE HOY ESTÁN EN ESTE CUENTO';
    }

    return Container(
      key: const Key('palabras_do_conto'),
      margin: const EdgeInsets.only(bottom: AppTheme.spaceLg),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: context.acento.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: const Key('palabras_do_conto_abrir'),
            onTap: () => setState(() => _aberta = !_aberta),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rotulo,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: context.acento,
                      ),
                    ),
                  ),
                  Icon(
                    _aberta
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: context.acento,
                  ),
                ],
              ),
            ),
          ),
          if (plan != null)
            Text(
              PalabrasDoDia.resumo(plan, lang),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: context.acento,
                height: 1.3,
              ),
            ),
          if (_aberta) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              isGl
                  ? 'Van entre comiñas e resaltadas no texto. Toca unha para ir á súa páxina.'
                  : 'Van entre comillas y resaltadas en el texto. Toca una para ir a su página.',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final item in lista)
                  _PastillaDePaxina(
                    key: ValueKey('ir_a_paxina_${item.palabra.en}'),
                    texto:
                        '${item.palabra.en} · ${isGl ? 'páx.' : 'pág.'} ${item.paxina}',
                    onTap: () => widget.onIrAPaxina(item.paxina - 1),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Las palabras de la semana que salen en la página, con su significado, su
/// gesto y su voz. Las de hoy llevan la marca «Hoxe».
class PalabrasDaPaxina extends StatelessWidget {
  final CuentoPagina pagina;
  final PalabrasNoConto palabras;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const PalabrasDaPaxina({
    super.key,
    required this.pagina,
    required this.palabras,
    required this.language,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    if (pagina.palabras.isEmpty) return const SizedBox.shrink();
    final isGl = language == AppLanguage.gl;
    return Column(
      key: const Key('palabras_da_paxina'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppTheme.spaceLg),
        Text(
          isGl ? 'EN INGLÉS NESTA PÁXINA' : 'EN INGLÉS EN ESTA PÁGINA',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: context.acento,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        for (final en in pagina.palabras)
          PalabraConXesto(
            palabra: palabras.palabraDaPaxina(pagina, en),
            language: language,
            audioService: audioService,
            marca: palabras.eDeHoxe(en) ? (isGl ? 'Hoxe' : 'Hoy') : null,
          ),
      ],
    );
  }
}

/// Una palabra de la cabecera con su página. No es un `ActionChip`: el chip
/// pinta su texto en una sola línea y lo corta, y en 5-6 años hay frases de
/// nueve palabras («We smell with our nose and taste with our tongue»). Aquí
/// el texto baja de línea.
class _PastillaDePaxina extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _PastillaDePaxina({
    super.key,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: context.acento.withAlpha(90)),
    );
    return Material(
      color: Colors.white,
      shape: forma,
      child: InkWell(
        customBorder: forma,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              texto,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: context.acento,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
