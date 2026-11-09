import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/storage/calendario_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cabecera.dart';
import '../../data/models/leccion_model.dart';
import '../docentes/widgets/hoxe_na_aula.dart';
import '../premios/medallas_widget.dart';
import '../premios/premios_model.dart';
import '../premios/premios_repository.dart';
import 'criancas_store.dart';
import 'tarxeta_lua.dart';

/// Los resultados de un niño de la casa (O-20261109-1).
///
/// Solo enseña lo que existe: lo que hizo la persona adulta (los días de
/// juego que marcó en el calendario, su racha y sus medallas) y lo que ella
/// misma observó del niño, palabra a palabra. La app no mide al niño, que no
/// toca la pantalla; por eso aquí no hay ni una cifra que no venga de una
/// marca de la persona adulta. Sin marcas, la pantalla lo dice y no dibuja
/// ninguna evolución.
class ResultadosCrianzaScreen extends StatefulWidget {
  const ResultadosCrianzaScreen({
    super.key,
    required this.store,
    required this.language,
    required this.onLanguageChanged,
    this.calendario,
    this.premios,
    this.agora,
  });

  final CriancasStore store;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final CalendarioStore? calendario;
  final PremiosRepository? premios;
  final DateTime? agora;

  @override
  State<ResultadosCrianzaScreen> createState() =>
      _ResultadosCrianzaScreenState();
}

class _ResultadosCrianzaScreenState extends State<ResultadosCrianzaScreen> {
  late final Future<Leccions?> _leccions =
      Leccions.cargar().then<Leccions?>((l) => l, onError: (_) => null);
  late AppLanguage _lang = widget.language;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_cambio);
    widget.calendario?.addListener(_cambio);
    widget.premios?.addListener(_cambio);
    if (widget.calendario case final c? when !c.isCargado) c.cargar();
    if (widget.premios case final p? when !p.cargado) p.cargar();
  }

  @override
  void dispose() {
    widget.store.removeListener(_cambio);
    widget.calendario?.removeListener(_cambio);
    widget.premios?.removeListener(_cambio);
    super.dispose();
  }

  void _cambio() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lang = _lang;
    final isGl = lang == AppLanguage.gl;
    final c = widget.store.activa;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: c == null
            ? (isGl ? 'Resultados' : 'Resultados')
            : (isGl ? 'Resultados de ${c.nome}' : 'Resultados de ${c.nome}'),
        language: lang,
        onLanguageChanged: (l) {
          setState(() => _lang = l);
          widget.onLanguageChanged(l);
        },
      ),
      body: SafeArea(
        child: c == null
            ? const SizedBox.shrink()
            : FutureBuilder<Leccions?>(
                future: _leccions,
                builder: (context, snap) => _corpo(context, c, snap.data, lang),
              ),
      ),
    );
  }

  Widget _corpo(
      BuildContext context, Crianza c, Leccions? l, AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    final store = widget.store;
    final toca = DiaQueToca.para(agora: widget.agora);
    final semanaKey =
        CriancasStore.semana(c.curso, toca.dia.mesCalendario, toca.dia.semana);
    final lec = l?.da(c.curso, toca.dia.mesCalendario, toca.dia.semana)?.$2;
    final palabras = [
      for (final p in lec?.novas ?? const <PezaDaLeccion>[])
        if (p.en.isNotEmpty) p,
    ];
    final totais = store.totais(c.id);
    final evolucion = store.evolucion(c.id);
    final contadores = widget.calendario?.contadores;
    final racha = widget.calendario?.rachaActual ?? 0;
    final medallas =
        widget.premios?.catalogo?.medallasDe(Perfil.familia) ?? const [];

    final mensaxe = _mensaxe(
      isGl: isGl,
      nome: c.nome,
      entende: totais.entende,
      di: totais.di,
      diasCasa: contadores?.diasFogar ?? 0,
      racha: racha,
    );

    Widget tarxeta({required Key key, required List<Widget> children}) =>
        Container(
          key: key,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        );

    Text titulo(String t) => Text(t,
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary));

    Text nota(String t) => Text(t,
        style: const TextStyle(
            fontSize: 14, height: 1.35, color: AppTheme.textSecondary));

    return ListView(
      key: const Key('resultados_crianza'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // O-20261109-3: la tarjeta de Lúa de Valeria, con sus premios.
        TarxetaLua(
          store: store,
          crianza: c,
          language: lang,
          agora: widget.agora,
          semana: semanaKey,
          palabrasDaSemana: [for (final p in palabras) p.en],
        ),
        const SizedBox(height: 12),
        Text(mensaxe,
            key: const Key('resultados_mensaxe'),
            style: const TextStyle(
                fontSize: 15.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 14),
        // Las cuentas grandes.
        Row(
          children: [
            _Cifra(
              key: const Key('resultados_entende'),
              numero: totais.entende,
              texto: isGl ? 'palabras que entende' : 'palabras que entiende',
              icono: Icons.hearing_rounded,
            ),
            const SizedBox(width: 10),
            _Cifra(
              key: const Key('resultados_di'),
              numero: totais.di,
              texto: isGl ? 'palabras que di' : 'palabras que dice',
              icono: Icons.record_voice_over_rounded,
            ),
          ],
        ),
        const SizedBox(height: 14),
        // La observación de esta semana.
        tarxeta(
          key: const Key('resultados_observar'),
          children: [
            titulo(isGl
                ? 'Esta semana, que viches?'
                : 'Esta semana, ¿qué has visto?'),
            const SizedBox(height: 4),
            nota(isGl
                ? 'Marca cada palabra nova cando a entenda (fai o xesto, mira, colle) ou cando a diga. É a túa observación, non un exame.'
                : 'Marca cada palabra nueva cuando la entienda (hace el gesto, mira, coge) o cuando la diga. Es tu observación, no un examen.'),
            const SizedBox(height: 10),
            if (palabras.isEmpty)
              nota(isGl
                  ? 'Esta semana non hai palabras novas: é de repaso.'
                  : 'Esta semana no hay palabras nuevas: es de repaso.')
            else
              for (final p in palabras)
                _FilaObservacion(
                  key: ValueKey('observar_${p.en}'),
                  palabra: p.en,
                  significado: p.significado?.resolve(lang),
                  valor: store.observacion(c.id, semanaKey, p.en),
                  lang: lang,
                  onCambiar: (o) => store.observar(c.id, semanaKey, p.en, o),
                ),
          ],
        ),
        // La evolución: solo semanas con marcas.
        tarxeta(
          key: const Key('resultados_evolucion'),
          children: [
            titulo(isGl ? 'Semana a semana' : 'Semana a semana'),
            const SizedBox(height: 8),
            if (evolucion.isEmpty)
              nota(isGl
                  ? 'Aínda non marcaches ningunha palabra. Cando o fagas, aquí verás como medra semana a semana.'
                  : 'Todavía no has marcado ninguna palabra. Cuando lo hagas, aquí verás cómo crece semana a semana.')
            else ...[
              _Lenda(lang: lang),
              const SizedBox(height: 8),
              for (final e in evolucion)
                _BarraSemana(
                  etiqueta: _etiquetaSemana(e.semana, lang),
                  entende: e.entende,
                  di: e.di,
                  maximo: evolucion
                      .map((x) => x.entende + x.di)
                      .fold<int>(1, (a, b) => a > b ? a : b),
                ),
            ],
          ],
        ),
        // Lo que hizo la persona adulta, con las medallas de premios.
        tarxeta(
          key: const Key('resultados_adulto'),
          children: [
            titulo(
                isGl ? 'O que fixestes xuntos' : 'Lo que habéis hecho juntos'),
            const SizedBox(height: 6),
            nota(isGl
                ? 'Días de xogo en casa marcados no calendario: ${contadores?.diasFogar ?? 0}. Días seguidos agora: $racha.'
                : 'Días de juego en casa marcados en el calendario: ${contadores?.diasFogar ?? 0}. Días seguidos ahora: $racha.'),
            if (contadores != null && medallas.isNotEmpty) ...[
              const SizedBox(height: 12),
              MedallasCalendario(
                medallas: medallas,
                contadores: contadores,
                lang: lang,
                titulo: isGl ? 'Medallas' : 'Medallas',
              ),
            ],
          ],
        ),
        nota(isGl
            ? 'Todo isto gárdase só neste móbil e non é unha avaliación: cada neno leva o seu ritmo.'
            : 'Todo esto se guarda solo en este móvil y no es una evaluación: cada niño lleva su ritmo.'),
      ],
    );
  }

  static String _etiquetaSemana(String clave, AppLanguage lang) {
    final p = clave.split('/');
    if (p.length != 3) return clave;
    final mes = int.tryParse(p[1]) ?? 9;
    const gl = [
      'xan',
      'feb',
      'mar',
      'abr',
      'mai',
      'xuñ',
      'xul',
      'ago',
      'set',
      'out',
      'nov',
      'dec'
    ];
    const es = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    final nome = (lang == AppLanguage.gl ? gl : es)[(mes - 1).clamp(0, 11)];
    return '$nome · s${p[2]}';
  }

  /// El ánimo de Lúa, con los números que hay y ninguno más.
  static String _mensaxe({
    required bool isGl,
    required String nome,
    required int entende,
    required int di,
    required int diasCasa,
    required int racha,
  }) {
    if (entende == 0 && diasCasa == 0) {
      return isGl
          ? 'Empezamos! Xoga cun minuto ao día e marca aquí o que vexas.'
          : '¡Empezamos! Juega un minuto al día y marca aquí lo que veas.';
    }
    if (entende == 0) {
      return isGl
          ? 'Levades $diasCasa ${diasCasa == 1 ? 'día' : 'días'} de xogo. Cando vexas que $nome entende unha palabra, márcaa.'
          : 'Lleváis $diasCasa ${diasCasa == 1 ? 'día' : 'días'} de juego. Cuando veas que $nome entiende una palabra, márcala.';
    }
    final base = isGl
        ? '$nome xa entende $entende ${entende == 1 ? 'palabra' : 'palabras'} en inglés'
        : '$nome ya entiende $entende ${entende == 1 ? 'palabra' : 'palabras'} en inglés';
    final dise = di == 0
        ? (isGl
            ? '. Dicilas chegará despois: primeiro escóitanse.'
            : '. Decirlas llegará después: primero se escuchan.')
        : (isGl ? ' e di $di. Moi ben!' : ' y dice $di. ¡Muy bien!');
    final rachaTxt = racha >= 2
        ? (isGl
            ? ' Levades $racha días seguidos.'
            : ' Lleváis $racha días seguidos.')
        : '';
    return '$base$dise$rachaTxt';
  }
}

class _Cifra extends StatelessWidget {
  const _Cifra({
    super.key,
    required this.numero,
    required this.texto,
    required this.icono,
  });

  final int numero;
  final String texto;
  final IconData icono;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: context.acento, size: 22),
              const SizedBox(height: 4),
              Text('$numero',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: context.acento)),
              Text(texto,
                  style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.25,
                      color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
}

class _FilaObservacion extends StatelessWidget {
  const _FilaObservacion({
    super.key,
    required this.palabra,
    required this.significado,
    required this.valor,
    required this.lang,
    required this.onCambiar,
  });

  final String palabra;
  final String? significado;
  final Observacion valor;
  final AppLanguage lang;
  final ValueChanged<Observacion> onCambiar;

  @override
  Widget build(BuildContext context) {
    final isGl = lang == AppLanguage.gl;
    final acento = context.acento;
    Widget opcion(Observacion o, String texto) {
      final sel = valor == o;
      return ChoiceChip(
        key: ValueKey('observar_${palabra}_${o.name}'),
        label: Text(texto),
        selected: sel,
        showCheckmark: false,
        selectedColor: acento,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: sel ? Colors.white : AppTheme.textPrimary,
        ),
        onSelected: (_) => onCambiar(o),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(children: [
            TextSpan(
                text: palabra,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            if (significado != null && significado!.isNotEmpty)
              TextSpan(
                  text: '  ·  $significado',
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
          ])),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              opcion(Observacion.aindaNon, isGl ? 'Aínda non' : 'Aún no'),
              opcion(Observacion.entende, isGl ? 'Enténdea' : 'La entiende'),
              opcion(Observacion.di, isGl ? 'Dia' : 'La dice'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Lenda extends StatelessWidget {
  const _Lenda({required this.lang});
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final isGl = lang == AppLanguage.gl;
    Widget item(Color cor, String t) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: cor, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 6),
            Text(t,
                style: const TextStyle(
                    fontSize: 13.5, color: AppTheme.textSecondary)),
          ],
        );
    return Wrap(spacing: 16, children: [
      item(context.acento.withAlpha(110), isGl ? 'Entende' : 'Entiende'),
      item(context.acento, isGl ? 'Di' : 'Dice'),
    ]);
  }
}

class _BarraSemana extends StatelessWidget {
  const _BarraSemana({
    required this.etiqueta,
    required this.entende,
    required this.di,
    required this.maximo,
  });

  final String etiqueta;
  final int entende;
  final int di;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    final acento = context.acento;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(etiqueta,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, box) {
              final unidade = box.maxWidth / (maximo < 1 ? 1 : maximo);
              return Row(children: [
                Container(
                    width: unidade * entende,
                    height: 16,
                    color: acento.withAlpha(110)),
                Container(width: unidade * di, height: 16, color: acento),
              ]);
            }),
          ),
          SizedBox(
            width: 44,
            child: Text('${entende + di}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}
