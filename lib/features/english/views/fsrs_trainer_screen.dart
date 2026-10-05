import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/progress_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/fsrs_card_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../calendario/widgets/palabras_do_dia.dart';
import '../../docentes/widgets/hoxe_na_aula.dart';
import '../../../core/widgets/cabecera.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;
import '../../docentes/nomes_docentes.dart';

/// Repaso espaciado de las palabras del CURSO: las cinco de hoy y todas las
/// que ya salieron antes, en el curso que se elija.
///
/// Antes eran seis palabras escritas en este fichero —hello, water, apple…—,
/// las mismas para todos los cursos y sin relación con las que la clase
/// trabajaba ese día. Y las tarjetas no se guardaban: al cerrar la pantalla se
/// perdía el repaso, que es justo lo que un repaso espaciado no puede perder.
///
/// Ahora las palabras salen de `assets/content/tpr/` y cada tarjeta se guarda
/// en `user_progress.json`: la palabra del catálogo, los números del repaso y
/// dos fechas sin hora. Es lo que la política de privacidad ya declara; el
/// gate `test/core/progreso_privacidad_test.dart` vigila que no entre nada más.
///
/// El motor es `FsrsService`: los pesos por defecto son los de FSRS-4 y la
/// curva de olvido, la de 4.5. Por eso la pantalla no pone número de versión.
class FsrsTrainerScreen extends StatefulWidget {
  final ProgramaTpr? programa;

  /// Dónde se guardan las tarjetas. Por defecto, el fichero de la app.
  final ProgressService? progreso;
  final String cursoInicial;
  final AppLanguage language;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  /// Para los tests: el día que se quiere ver. Por defecto, hoy.
  final DateTime? agora;

  const FsrsTrainerScreen({
    super.key,
    required this.programa,
    this.progreso,
    this.cursoInicial = 'curso_0_2',
    this.language = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
    this.agora,
  });

  /// Cuántas tarjetas trae una ronda. Las cinco de hoy entran siempre.
  static const int tarxetasPorRolda = 20;

  /// Cuántas palabras nunca vistas entran por ronda, contando las de hoy: si
  /// alguien empieza en marzo, no se le echan encima cuatrocientas de golpe.
  static const int novasPorRolda = 10;

  @override
  State<FsrsTrainerScreen> createState() => _FsrsTrainerScreenState();
}

/// Una tarjeta de la ronda: la palabra, cuándo salió y por qué entra hoy.
class _TarxetaDaRolda {
  final PalabraNoCurso palabra;
  final FSRSCard? gardada;
  final bool deHoxe;

  const _TarxetaDaRolda(this.palabra, this.gardada, {required this.deHoxe});
}

class _FsrsTrainerScreenState extends State<FsrsTrainerScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language = widget.language;

  // Si quien la abrió la vuelve a pintar en otra lengua, se cambia; si no,
  // se quedaba en la de la primera vez.
  @override
  void didUpdateWidget(covariant FsrsTrainerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) _language = widget.language;
  }

  late final ProgressService _progreso = widget.progreso ?? ProgressService();
  late String _curso = widget.cursoInicial;
  bool _listo = false;

  List<_TarxetaDaRolda> _rolda = const [];
  final Set<String> _repetidas = {};
  int _indice = 0;
  bool _revelada = false;
  int _repasosFeitos = 0;
  int _introducidas = 0;
  int _xaVistas = 0;

  DateTime get _agora => widget.agora ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    if (_progreso.isInitialized) {
      _armarRolda();
      _listo = true;
    } else {
      _progreso.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _armarRolda();
          _listo = true;
        });
      });
    }
  }

  CursoTpr? get _cursoTpr => widget.programa?.curso(_curso);

  /// La ronda de hoy: primero las cinco nuevas de hoy, después las que ya
  /// toca repasar y, si queda sitio, las que salieron antes y nunca se vieron.
  void _armarRolda() {
    final curso = _cursoTpr;
    _indice = 0;
    _revelada = false;
    _repetidas.clear();
    if (curso == null) {
      _rolda = const [];
      return;
    }
    final hoxe = diaDoCursoParaHoxe(agora: _agora).dia;
    final introducidas = curso.introducidasAta(hoxe);
    final deHoxe = <_TarxetaDaRolda>[];
    final debidas = <_TarxetaDaRolda>[];
    final senVer = <_TarxetaDaRolda>[];
    var vistas = 0;
    for (final p in introducidas) {
      final gardada = _gardadaDe(p.palabra);
      final eDeHoxe = p.mesCalendario == hoxe.mesCalendario &&
          p.semana == hoxe.semana &&
          p.dia == hoxe.dia;
      if (gardada != null) vistas++;
      if (gardada == null) {
        (eDeHoxe ? deHoxe : senVer)
            .add(_TarxetaDaRolda(p, null, deHoxe: eDeHoxe));
      } else if (!gardada.nextDueDate.isAfter(_agora)) {
        debidas.add(_TarxetaDaRolda(p, gardada, deHoxe: eDeHoxe));
      }
    }
    debidas.sort(
        (a, b) => a.gardada!.nextDueDate.compareTo(b.gardada!.nextDueDate));
    // Las de hoy primero; las antiguas sin ver, de la más reciente hacia
    // atrás: es la que la clase tiene más fresca.
    final sitioNovas =
        (FsrsTrainerScreen.novasPorRolda - deHoxe.length).clamp(0, 999);
    _rolda = [
      ...deHoxe,
      ...debidas,
      ...senVer.reversed.take(sitioNovas),
    ].take(FsrsTrainerScreen.tarxetasPorRolda).toList();
    _introducidas = introducidas.length;
    _xaVistas = vistas;
  }

  FSRSCard? _gardadaDe(TprWord palabra) {
    final c = _progreso.getCard(idDaTarxetaDeRepaso(palabra.id));
    // Si el número coincidiera con el de otra palabra, la tarjeta guardada no
    // es de esta: mejor empezarla de cero que repasar con números ajenos.
    if (c == null || c.lemma != palabra.en) return null;
    return c;
  }

  Future<void> _puntuar(int nota) async {
    if (_indice >= _rolda.length) return;
    final actual = _rolda[_indice];
    final p = actual.palabra.palabra;
    final tarxeta = _gardadaDe(p) ??
        FSRSCard.initial(
          id: idDaTarxetaDeRepaso(p.id),
          lemma: p.en,
          now: _agora,
        );
    await _progreso.recordFsrsReview(tarxeta, nota, now: _agora);
    if (!mounted) return;
    setState(() {
      _repasosFeitos++;
      // «Outra vez» la devuelve al final de la ronda, una sola vez: se vuelve
      // a ver hoy, que es lo que pide una palabra que no salió.
      if (nota == 1 && _repetidas.add(p.id)) {
        _rolda = [..._rolda, actual];
      }
      _indice++;
      _revelada = false;
    });
  }

  void _cambiarCurso(String curso) {
    setState(() {
      _curso = curso;
      _armarRolda();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;
    final programa = widget.programa;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.repaso.resolve(lang),
        language: _language,
        onLanguageChanged: _cambiarLingua,
      ),
      body: SafeArea(
        child: programa == null || !_listo
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                key: const Key('fsrs_lista'),
                padding: const EdgeInsets.all(16),
                children: [
                  SelectorDeCursoTpr(
                    programa: programa,
                    seleccionado: _curso,
                    language: lang,
                    prefixoClave: 'fsrs_curso',
                    onCambiar: _cambiarCurso,
                  ),
                  const SizedBox(height: 12),
                  _resumo(isGl),
                  const SizedBox(height: 16),
                  if (_indice < _rolda.length)
                    ..._tarxeta(lang)
                  else
                    _fin(isGl),
                ],
              ),
      ),
    );
  }

  Widget _resumo(bool isGl) {
    final hoxe = diaDoCursoParaHoxe(agora: _agora);
    final d = hoxe.dia;
    // A media frase: «Hoxe: luns, semana 1 de outubro», en minúscula.
    final mes =
        (nomeDoMes[d.mesCalendario]?.resolve(_language) ?? '').toLowerCase();
    final dia =
        PalabrasDoDia.nomesDosDias[d.dia - 1].resolve(_language).toLowerCase();
    final quedan = (_rolda.length - _indice).clamp(0, 999);
    return Container(
      key: const Key('fsrs_resumo'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hoxe.prevista
                ? (isGl
                    ? 'O curso aínda non empezou: repásase o primeiro día.'
                    : 'El curso aún no ha empezado: se repasa el primer día.')
                : (isGl
                    ? 'Hoxe: $dia, semana ${d.semana} de $mes'
                    : 'Hoy: $dia, semana ${d.semana} de $mes'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: context.acento,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isGl
                ? '$_introducidas palabras xa saíron neste curso · $_xaVistas xa repasadas · $quedan nesta rolda · $_repasosFeitos repasos feitos'
                : '$_introducidas palabras ya salieron en este curso · $_xaVistas ya repasadas · $quedan en esta ronda · $_repasosFeitos repasos hechos',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _tarxeta(AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    final t = _rolda[_indice];
    final p = t.palabra.palabra;
    final categoria = _cursoTpr?.modelo.categorias
        .where((c) => c.clave == p.category)
        .firstOrNull;
    final cando =
        '${PalabrasDoDia.nomesDosDias[t.palabra.dia - 1].resolve(lang)}'
        ' · semana ${t.palabra.semana} · '
        '${nomeDoMes[t.palabra.mesCalendario]?.resolve(lang) ?? ''}';
    final motivo = t.deHoxe
        ? (isGl ? 'NOVA HOXE' : 'NUEVA HOY')
        : t.gardada == null
            ? (isGl ? 'AÍNDA SEN REPASAR' : 'AÚN SIN REPASAR')
            : (isGl ? 'TOCA REPASALA' : 'TOCA REPASARLA');

    return [
      // La tarjeta del tema: plana, con borde y radio 16, como todas.
      Card(
        key: const Key('fsrs_tarxeta'),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          onTap: () => setState(() => _revelada = !_revelada),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '$motivo · ${_indice + 1}/${_rolda.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: context.acento,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  p.en,
                  key: const Key('fsrs_palabra'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                // Un repaso en el que la palabra no suena obliga a la persona
                // adulta a adivinar la pronunciación justo antes de modelarla
                // delante de la criatura.
                BotonEscuchar(
                  audioService: widget.audioService,
                  texto: p.en,
                  language: AppLanguage.en,
                  interfaz: lang,
                  style: estiloIngles(p.en),
                ),
                const SizedBox(height: 8),
                Text(
                  isGl ? 'Saíu o $cando' : 'Salió el $cando',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                if (_revelada) ...[
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    p.significado(lang),
                    key: const Key('fsrs_significado'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.acento,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.acentoTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${isGl ? 'Xesto' : 'Gesto'}: ${p.tprAction.resolve(lang)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.acento,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (categoria != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      categoria.nome.resolve(lang),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ] else
                  Text(
                    isGl
                        ? 'Di a palabra en voz alta co xesto e despois mira o significado.'
                        : 'Di la palabra en voz alta con el gesto y después mira el significado.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      if (_revelada)
        // Wrap y no fila: con texto grande los cuatro botones no caben en
        // una fila y bajan de línea en vez de cortarse.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _nota(1, isGl ? 'Outra vez' : 'Otra vez', AppTheme.errorInk),
            _nota(2, isGl ? 'Custoume' : 'Me costó', AppTheme.warning),
            _nota(3, isGl ? 'Ben' : 'Bien', AppTheme.info),
            _nota(4, isGl ? 'Doado' : 'Fácil', AppTheme.successInk),
          ],
        )
      else
        ElevatedButton(
          key: const Key('fsrs_amosar'),
          onPressed: () => setState(() => _revelada = true),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, AppTheme.touchMin),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            isGl ? 'Amosar o significado' : 'Mostrar el significado',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ];
  }

  Widget _fin(bool isGl) {
    final baleira = _rolda.isEmpty;
    return Container(
      key: const Key('fsrs_fin'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.success, size: 40),
          const SizedBox(height: 10),
          Text(
            baleira
                ? (isGl
                    ? 'Nada pendente hoxe neste curso.'
                    : 'Nada pendiente hoy en este curso.')
                : (isGl ? 'Rolda feita.' : 'Ronda hecha.'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isGl
                ? 'Cada palabra volve cando o repaso di que toca: mañá, nuns días ou dentro de semanas.'
                : 'Cada palabra vuelve cuando el repaso dice que toca: mañana, en unos días o dentro de semanas.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            key: const Key('fsrs_outra_rolda'),
            onPressed: () => setState(_armarRolda),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, AppTheme.touchMin),
            ),
            child: Text(isGl ? 'Mirar se queda algo' : 'Mirar si queda algo'),
          ),
        ],
      ),
    );
  }

  /// Cuatro respuestas del mismo peso, cada una con su color en el borde y
  /// la letra. Eran cuatro botones principales iguales, rellenos del acento,
  /// y el color de cada una se recibía y no se usaba.
  Widget _nota(int nota, String rotulo, Color cor) {
    return OutlinedButton(
      key: ValueKey('fsrs_nota_$nota'),
      onPressed: () => _puntuar(nota),
      style: OutlinedButton.styleFrom(
        foregroundColor: cor,
        backgroundColor: Colors.white,
        side: BorderSide(color: cor, width: 1.5),
        minimumSize: const Size(120, AppTheme.touchMin),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        rotulo,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }
}
