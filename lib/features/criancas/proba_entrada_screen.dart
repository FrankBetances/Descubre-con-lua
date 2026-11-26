import 'package:flutter/material.dart';

import '../../core/audio/offline_audio_service.dart';
import '../../core/audio/widgets/boton_escuchar.dart';
import '../../core/brand/imaxe_escena.dart';
import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';
import 'criancas_store.dart';
import 'proba_entrada.dart';

/// Juego de Lúa para saber por dónde empezar (P11.3 + Alta única 26/11/2026).
///
/// Lo ejecuta la persona adulta una única vez al registrar a un niño de 2 años
/// o más, y se reanuda exactamente donde quedó si se interrumpe antes de
/// acabar. No se repite ni se ofrece después desde la ficha.
class ProbaEntradaScreen extends StatefulWidget {
  const ProbaEntradaScreen({
    super.key,
    required this.store,
    required this.crianza,
    required this.language,
    this.audioService,
    this.agora,
    this.embutido = false,
    this.onRematada,
  });

  final CriancasStore store;
  final Crianza crianza;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final DateTime? agora;
  final bool embutido;
  final ValueChanged<ResultadoProbaEntrada>? onRematada;

  @override
  State<ProbaEntradaScreen> createState() => _ProbaEntradaScreenState();
}

class _ProbaEntradaScreenState extends State<ProbaEntradaScreen> {
  late List<Observacion> _respostas = [
    for (final code in widget.crianza.probaRespostas)
      Observacion.values[code.clamp(0, Observacion.values.length - 1)],
  ];
  ResultadoProbaEntrada? _resultado;
  bool _ocupado = false;

  Crianza get _actual => widget.store.criancas.firstWhere(
        (c) => c.id == widget.crianza.id,
        orElse: () => widget.crianza,
      );

  Future<void> _responder(List<ItemProba> items, Observacion o) async {
    if (_ocupado || _respostas.length >= items.length) return;
    setState(() => _ocupado = true);
    final item = items[_respostas.length];
    final novas = [..._respostas, o];
    await widget.store.gardarRespostaProba(
      _actual.id,
      o,
      palabrasSemente: item.palabrasSemente,
      agora: widget.agora,
    );
    final ev = CatalogoProbaEntrada.avaliar(items, novas);
    if (ev.terminada) {
      await widget.store.completarProba(
        _actual.id,
        peldano: ev.peldano,
        semente: ev.semente,
        agora: widget.agora,
      );
      if (mounted) {
        setState(() {
          _respostas = novas;
          _resultado = ev;
          _ocupado = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _respostas = novas;
        _ocupado = false;
      });
    }
  }

  Future<void> _saltar() async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    const ev = ResultadoProbaEntrada(
      peldano: 1,
      terminada: true,
      parouPorTresFallos: false,
      acertosPorPeldano: {},
      semente: {},
    );
    await widget.store.completarProba(
      _actual.id,
      peldano: 1,
      semente: const {},
      agora: widget.agora,
    );
    if (!mounted) return;
    if (widget.onRematada case final f?) {
      f(ev);
    } else {
      Navigator.of(context).pop(ev);
    }
  }

  void _pecharFinal() {
    final res = _resultado ??
        const ResultadoProbaEntrada(
          peldano: 1,
          terminada: true,
          parouPorTresFallos: false,
          acertosPorPeldano: {},
          semente: {},
        );
    if (widget.onRematada case final f?) {
      f(res);
    } else {
      Navigator.of(context).pop(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final acento = context.acento;
    final nome = _actual.nome;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: AppTheme.pageBg,
        elevation: 0,
        automaticallyImplyLeading: !widget.embutido,
        title: Text(
          isGl ? 'Xogo de Lúa · $nome' : 'Juego de Lúa · $nome',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (_resultado == null)
            TextButton(
              key: const Key('proba_saltar'),
              onPressed: _ocupado ? null : _saltar,
              child: Text(
                isGl ? 'Saltar' : 'Saltar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: FutureBuilder<CatalogoProbaEntrada>(
        future: CatalogoProbaEntrada.cargar(),
        initialData: CatalogoProbaEntrada.lido,
        builder: (context, snap) {
          final cat = snap.data;
          if (cat == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = cat.itemsDoCurso(_actual.curso);
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }

          if (_resultado case final res?) {
            final desc = CatalogoProbaEntrada.textoPeldano(res.peldano, lang);
            final cantas = res.semente.length;
            return ListView(
              key: const Key('proba_resumo'),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                const Center(child: LuaPixel(pose: LuaPose.sit, size: 96)),
                const SizedBox(height: 16),
                Text(
                  isGl
                      ? 'Xa sabemos por onde empezar con $nome'
                      : 'Ya sabemos por dónde empezar con $nome',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        desc,
                        key: const Key('proba_resumo_peldano'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: acento,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cantas == 0
                            ? (isGl
                                ? '$nome comeza polas primeiras palabras do seu curso.'
                                : '$nome empieza por las primeras palabras de su curso.')
                            : (isGl
                                ? 'Lúa gardou $cantas palabras que xa coñece para repartilas no repaso.'
                                : 'Lúa guardó $cantas palabras que ya conoce para repartirlas en el repaso.'),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    key: const Key('proba_rematar'),
                    style: FilledButton.styleFrom(backgroundColor: acento),
                    onPressed: _pecharFinal,
                    child: Text(
                      isGl ? 'Continuar' : 'Continuar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final idx = _respostas.length.clamp(0, items.length - 1);
          final item = items[idx];
          final pelDesc = cat.descricionDe(item.peldano);

          Widget boton(Observacion o, String texto, String sufixo) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Semantics(
                  button: true,
                  label: '${item.en}: $texto',
                  child: Material(
                    key: Key('proba_$sufixo'),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _ocupado ? null : () => _responder(items, o),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 54),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 10,
                            ),
                            child: Text(
                              texto,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return ListView(
            key: const Key('proba_entrada_vista'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                isGl
                    ? 'Xogo de Lúa para saber por onde empezar'
                    : 'Juego de Lúa para saber por dónde empezar',
                key: const Key('proba_titulo'),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isGl
                    ? 'Paso ${item.peldano} de 6 · ${pelDesc?.titulo.resolve(lang) ?? ''} (${idx + 1}/${items.length})'
                    : 'Paso ${item.peldano} de 6 · ${pelDesc?.titulo.resolve(lang) ?? ''} (${idx + 1}/${items.length})',
                key: const Key('proba_progreso'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: acento,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isGl
                          ? 'STEAM: ${item.steamTitulo.resolve(lang)} · ${item.experimentoParte.resolve(lang)}'
                          : 'STEAM: ${item.steamTitulo.resolve(lang)} · ${item.experimentoParte.resolve(lang)}',
                      key: const Key('proba_steam'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: LaminaPalabra(
                        clave: item.lamina,
                        significado: item.enSignificado.resolve(lang),
                        lang: lang,
                        ancho: 120,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: BotonEscuchar(
                        audioService: widget.audioService,
                        texto: item.en,
                        language: AppLanguage.en,
                        interfaz: lang,
                        comoChip: true,
                        colorChip: acento,
                        descripcion: item.en,
                        significado: item.enSignificado,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.instrucion.resolve(lang),
                      key: const Key('proba_instrucion'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (item.obxectoCasa.resolve(lang).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        isGl
                            ? 'Con cousas da casa: ${item.obxectoCasa.resolve(lang)}'
                            : 'Con cosas de casa: ${item.obxectoCasa.resolve(lang)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isGl ? 'Que ves en $nome?' : '¿Qué ves en $nome?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  boton(
                    Observacion.aindaNon,
                    isGl ? 'Aínda non' : 'Aún no',
                    'aindaNon',
                  ),
                  boton(
                    Observacion.entende,
                    isGl ? 'Enténdea' : 'La entiende',
                    'entende',
                  ),
                  boton(
                    Observacion.di,
                    isGl ? 'Dia' : 'La dice',
                    'di',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
