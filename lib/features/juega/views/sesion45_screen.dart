import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../data/models/sesion45_model.dart';
import '../../../data/models/steam_do_mes_model.dart';
import '../../../data/models/unidade_do_mes_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../cuentos/views/microcuento_screen.dart';
import '../../cuentos/widgets/boton_microcuento.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../steam/views/steam_do_mes_screen.dart';

/// La sesión de 45 minutos (F3): acogida y pulso, cuento dialogado, taller
/// TPR y despedida con la bolsa misteriosa. Lo fijo de cada fase sale de
/// `assets/content/sesion45/`; lo del mes (núcleo, órdenes, material y
/// microcuento), de la unidad del curso. Para una sola adulta (P3).
class Sesion45Screen extends StatefulWidget {
  final ContentRepository repository;
  final String cursoId;
  final int mesCalendario;
  final bool segundoCiclo;
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const Sesion45Screen({
    super.key,
    required this.repository,
    required this.cursoId,
    required this.mesCalendario,
    required this.segundoCiclo,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
  });

  @override
  State<Sesion45Screen> createState() => _Sesion45ScreenState();
}

class _DatosDoMes {
  final Sesion45 sesion;
  final UnidadeDoMes? unidade;
  final List<PezaDaUnidade> nucleo;
  final List<PezaDaUnidade> ordes;
  final ExperimentoSteam? steam;

  const _DatosDoMes(this.sesion, this.unidade, this.nucleo, this.ordes,
      [this.steam]);
}

class _Sesion45ScreenState extends State<Sesion45Screen> {
  late AppLanguage _lang = widget.language;
  late final Future<_DatosDoMes> _datos = _cargar();

  Future<_DatosDoMes> _cargar() async {
    final repo = widget.repository;
    final sesion = await Sesion45.cargar();
    await Future.wait([repo.loadProgramaTpr(), repo.loadRexistroFrases()]);
    final u = await repo.loadUnidadeDoMes(widget.cursoId, widget.mesCalendario);
    ExperimentoSteam? steam;
    try {
      steam = (await SteamDoMes.cargar())
          .para(widget.cursoId, widget.mesCalendario);
    } catch (_) {}
    if (u == null) return _DatosDoMes(sesion, null, const [], const [], steam);
    return _DatosDoMes(
        sesion,
        u,
        repo.nucleoSync(u),
        [
          for (final o in u.ordenes)
            if (repo.pezaSync(o.ref) case final p?) p,
        ],
        steam);
  }

  void _cambiar(AppLanguage l) {
    setState(() => _lang = l);
    widget.onLanguageChanged?.call(l);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: const LocalizedString(
                gl: 'Sesión de 45 min', es: 'Sesión de 45 min')
            .resolve(_lang),
        language: _lang,
        onLanguageChanged: _cambiar,
      ),
      body: SafeArea(
        child: FutureBuilder<_DatosDoMes>(
          future: _datos,
          builder: (context, snap) {
            final d = snap.data;
            if (d == null) {
              return Center(
                child: snap.hasError
                    ? Text(_lang == AppLanguage.gl
                        ? 'Non se puido abrir a sesión.'
                        : 'No se pudo abrir la sesión.')
                    : const CircularProgressIndicator(),
              );
            }
            return ListView(
              key: const Key('sesion45'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _Cabeceira(datos: d, lang: _lang, segundo: widget.segundoCiclo),
                for (final (i, f) in d.sesion.fases.indexed) ...[
                  const SizedBox(height: 14),
                  _Fase(
                    numero: i + 1,
                    fase: f,
                    lang: _lang,
                    audio: widget.audioService,
                    doMes: _doMes(f.clave, d),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// Lo que pone la unidad del mes en cada fase.
  List<Widget> _doMes(String clave, _DatosDoMes d) {
    final isGl = _lang == AppLanguage.gl;
    final u = d.unidade;
    if (u == null) return const [];
    Widget pezas(List<PezaDaUnidade> ps) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in ps)
              BotonEscuchar(
                audioService: widget.audioService,
                texto: p.en,
                language: AppLanguage.en,
                interfaz: _lang,
                comoChip: true,
                significado: p.significado,
              ),
          ],
        );
    switch (clave) {
      case 'conto':
        return [
          _Rotulo(isGl ? 'O CONTO DESTE MES' : 'EL CUENTO DE ESTE MES'),
          if (u.microcuento case final mc? when mc.debuxado)
            BotonMicrocuento(
              repository: widget.repository,
              cursoId: widget.cursoId,
              mesCalendario: widget.mesCalendario,
              modo: ModoMicrocuento.aula,
              language: _lang,
              onLanguageChanged: widget.onLanguageChanged,
              audioService: widget.audioService,
            )
          else
            _Texto(isGl
                ? 'Neste curso non hai microconto: usa o conto da semana, en Hoxe.'
                : 'En este curso no hay microcuento: usa el cuento de la semana, en Hoy.'),
        ];
      case 'taller':
        return [
          // F8: el experimento STEAM del mes cabe en el taller TPR.
          if (d.steam case final e?) ...[
            _Rotulo(isGl ? 'STEAM DESTE MES' : 'STEAM DE ESTE MES'),
            OutlinedButton.icon(
              key: ValueKey('sesion45_steam_${e.id}'),
              onPressed: () => Navigator.of(context).push(RutaLua(
                de: context,
                builder: (_) => SteamDoMesScreen(
                  experimento: e,
                  language: _lang,
                  audioService: widget.audioService,
                ),
              )),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppTheme.touchMin),
                alignment: Alignment.centerLeft,
              ),
              icon: const Icon(Icons.science_rounded),
              label: Text(
                '${e.nomeFenomeno.resolve(_lang)}: ${e.titulo.resolve(_lang)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          if (u.realia.isNotEmpty) ...[
            _Rotulo(isGl ? 'MATERIAL' : 'MATERIAL'),
            for (final r in u.realia) _Texto('· ${r.resolve(_lang)}'),
          ],
          if (d.ordes.isNotEmpty) ...[
            _Rotulo(isGl ? 'AS ORDES DO MES' : 'LAS ÓRDENES DEL MES'),
            pezas(d.ordes),
          ],
          if (d.nucleo.isNotEmpty) ...[
            _Rotulo(
                isGl ? 'O NÚCLEO, CO SEU OBXECTO' : 'EL NÚCLEO, CON SU OBJETO'),
            pezas(d.nucleo),
            for (final p in d.nucleo)
              if (p.objeto case final o?)
                _Texto('${p.en}: ${o.resolve(_lang)}'),
          ],
        ];
      case 'despedida':
        final obxectos = [
          for (final p in d.nucleo)
            if (p.objeto case final o?) o.resolve(_lang),
          for (final r in u.realia) r.resolve(_lang),
        ];
        return [
          _Rotulo(isGl ? 'NA BOLSA' : 'EN LA BOLSA'),
          _Texto(obxectos.isEmpty
              ? (isGl
                  ? 'Dous ou tres obxectos do obradoiro.'
                  : 'Dos o tres objetos del taller.')
              : obxectos.take(3).join(' · ')),
          _Rotulo(isGl
              ? 'PARA NOMEALOS E DESPEDILOS'
              : 'PARA NOMBRARLOS Y DESPEDIRLOS'),
          pezas(d.nucleo),
        ];
      default:
        return const [];
    }
  }
}

class _Cabeceira extends StatelessWidget {
  final _DatosDoMes datos;
  final AppLanguage lang;
  final bool segundo;

  const _Cabeceira(
      {required this.datos, required this.lang, required this.segundo});

  @override
  Widget build(BuildContext context) {
    final u = datos.unidade;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            datos.sesion.titulo.resolve(lang).toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: context.acento,
            ),
          ),
          if (u != null) ...[
            const SizedBox(height: 6),
            Text(
              u.centroInteres.resolve(lang),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          _Texto(
              (segundo ? datos.sesion.segundoCiclo : datos.sesion.primeiroCiclo)
                  .resolve(lang)),
        ],
      ),
    );
  }
}

class _Fase extends StatelessWidget {
  final int numero;
  final FaseSesion45 fase;
  final AppLanguage lang;
  final OfflineAudioService? audio;
  final List<Widget> doMes;

  const _Fase({
    required this.numero,
    required this.fase,
    required this.lang,
    required this.audio,
    required this.doMes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('sesion45_${fase.clave}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.acento,
                child: Text('$numero',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fase.nome.resolve(lang),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${fase.minutos} min',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: context.acento,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Texto(fase.para.resolve(lang)),
          _Rotulo(lang == AppLanguage.gl ? 'COMO SE FAI' : 'CÓMO SE HACE'),
          for (final p in fase.pasos) _Texto('· ${p.resolve(lang)}'),
          _Rotulo(lang == AppLanguage.gl ? 'EN INGLÉS' : 'EN INGLÉS'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in fase.ingles)
                BotonEscuchar(
                  audioService: audio,
                  texto: e,
                  language: AppLanguage.en,
                  interfaz: lang,
                  comoChip: true,
                ),
            ],
          ),
          ...doMes,
        ],
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: context.acento,
          ),
        ),
      );
}

class _Texto extends StatelessWidget {
  final String texto;
  const _Texto(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
      );
}
