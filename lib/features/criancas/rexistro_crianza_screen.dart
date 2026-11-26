import 'package:flutter/material.dart';

import '../../core/audio/offline_audio_service.dart';
import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';
import '../docentes/widgets/hoxe_na_aula.dart' show DiaQueToca;
import '../familias/nomes_familias.dart';
import 'criancas_store.dart';
import 'proba_entrada.dart';
import 'proba_entrada_screen.dart';

/// El registro de un niño de la casa (O-20261109-1, P11.1, Alta única 26/11):
/// Lúa, datos, rutinas de casa (M2), prueba de entrada (>=2 años) y «Hai outro neno?».
///
/// Sirve para dar de alta (incluyendo varios niños seguidos) y para editar:
/// con [crianza] viene relleno y cambiar de curso pide confirmación.
class RexistroCrianzaScreen extends StatefulWidget {
  const RexistroCrianzaScreen({
    super.key,
    required this.store,
    required this.language,
    required this.onLanguageChanged,
    this.crianza,
    this.cursoInicial,
    this.onGardado,
    this.primeira = false,
    this.agora,
    this.audioService,
  });

  final CriancasStore store;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final Crianza? crianza;
  final String? cursoInicial;

  /// Sin él, la pantalla se cierra al guardar.
  final ValueChanged<Crianza>? onGardado;

  /// La primera vez que se entra en casa: pregunta se hai outro neno na casa.
  final bool primeira;

  final DateTime? agora;
  final OfflineAudioService? audioService;

  @override
  State<RexistroCrianzaScreen> createState() => _RexistroCrianzaScreenState();
}

class _RexistroCrianzaScreenState extends State<RexistroCrianzaScreen> {
  late final TextEditingController _nome = TextEditingController(
    text: widget.crianza?.nome ?? '',
  );
  late int? _idade = widget.crianza?.idade;
  late int? _mesNacemento = widget.crianza?.mesNacemento;
  late int? _anoNacemento = widget.crianza?.anoNacemento;
  late String? _curso = widget.crianza?.curso ?? widget.cursoInicial;
  late List<String> _rutinas = List.of(
    widget.crianza?.rutinas ?? const ['bano'],
  );
  bool _gardando = false;
  bool _enProba = false;
  bool _preguntandoOutro = false;
  Crianza? _ultimoGardado;

  DateTime get _agora => widget.agora ?? DateTime.now();

  /// El curso que suele ir con cada edad. Se propone, no se impone: un niño
  /// nacido en diciembre puede ir con los de un año menos.
  static String _cursoDe(int idade) => CriancasStore.cursoParaIdade(idade);

  static const _mesesGl = [
    'Xaneiro',
    'Febreiro',
    'Marzo',
    'Abril',
    'Maio',
    'Xuño',
    'Xullo',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Decembro',
  ];

  static const _mesesEs = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  bool get _valido =>
      _nome.text.trim().isNotEmpty && _idade != null && _curso != null;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _actualizarDesdeNacemento(int? mes, int? ano) {
    setState(() {
      _mesNacemento = mes;
      _anoNacemento = ano;
      if (mes != null && ano != null) {
        var anos = _agora.year - ano;
        if (_agora.month < mes) anos--;
        final cl = anos.clamp(0, 6);
        _idade = cl;
        if (widget.crianza == null) _curso = _cursoDe(cl);
      }
    });
  }

  Future<bool> _confirmarCambioCurso(
    String nome,
    String antes,
    String novo,
  ) async {
    final isGl = widget.language == AppLanguage.gl;
    final nomeAntes = NomesFamilias.idade(antes).resolve(widget.language);
    final nomeNovo = NomesFamilias.idade(novo).resolve(widget.language);
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('rexistro_confirmar_curso'),
        title: Text(
          isGl ? 'Cambiar de curso a $nome?' : '¿Cambiar de curso a $nome?',
        ),
        content: Text(
          isGl
              ? 'Pasará de $nomeAntes a $nomeNovo. O historial previo consérvase.'
              : 'Pasará de $nomeAntes a $nomeNovo. El historial previo se conserva.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('rexistro_confirmar_curso_si'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return res == true;
  }

  Future<void> _gardar() async {
    if (!_valido || _gardando) return;
    if (widget.crianza case final orixe?) {
      if (_curso != orixe.curso) {
        final ok = await _confirmarCambioCurso(
          _nome.text.trim(),
          orixe.curso,
          _curso!,
        );
        if (!ok || !mounted) return;
      }
    }
    setState(() => _gardando = true);
    final store = widget.store;
    final Crianza c;
    if (widget.crianza case final orixe?) {
      await store.actualizar(
        orixe.id,
        nome: _nome.text,
        idade: _idade,
        curso: _curso,
        mesNacemento: _mesNacemento,
        anoNacemento: _anoNacemento,
        rutinas: _rutinas,
      );
      c = store.criancas.firstWhere((x) => x.id == orixe.id);
    } else {
      final toca = DiaQueToca.para(agora: _agora);
      c = await store.engadir(
        nome: _nome.text,
        idade: _idade!,
        curso: _curso!,
        mesNacemento: _mesNacemento,
        anoNacemento: _anoNacemento,
        rutinas: _rutinas,
        semanaAlta: CriancasStore.semana(
          _curso!,
          toca.dia.mesCalendario,
          toca.dia.semana,
        ),
      );
    }
    if (!mounted) return;
    if (widget.crianza == null && CatalogoProbaEntrada.debeFacerProba(c)) {
      setState(() {
        _gardando = false;
        _ultimoGardado = c;
        _enProba = true;
      });
      return;
    }
    if (widget.primeira && widget.crianza == null) {
      setState(() {
        _gardando = false;
        _ultimoGardado = c;
        _preguntandoOutro = true;
      });
      return;
    }
    if (widget.onGardado case final f?) {
      f(c);
    } else {
      Navigator.of(context).pop(c);
    }
  }

  void _prepararOutro() {
    setState(() {
      _nome.clear();
      _idade = null;
      _mesNacemento = null;
      _anoNacemento = null;
      _curso = null;
      _rutinas = ['bano'];
      _enProba = false;
      _preguntandoOutro = false;
      _gardando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final acento = context.acento;
    final editar = widget.crianza != null;

    if (_enProba && _ultimoGardado != null) {
      return ProbaEntradaScreen(
        key: const Key('rexistro_proba_entrada'),
        store: widget.store,
        crianza: _ultimoGardado!,
        language: lang,
        audioService: widget.audioService,
        agora: widget.agora,
        embutido: widget.primeira,
        onRematada: (_) {
          if (!mounted) return;
          if (widget.primeira) {
            setState(() {
              _enProba = false;
              _preguntandoOutro = true;
            });
          } else if (widget.onGardado case final f?) {
            f(_ultimoGardado!);
          } else {
            Navigator.of(context).pop(_ultimoGardado!);
          }
        },
      );
    }

    if (_preguntandoOutro) {
      final nenos = widget.store.criancas;
      return Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: AppBar(
          title: Text(isGl ? 'Na casa' : 'En casa'),
          actions: [
            TextButton(
              key: const Key('rexistro_lingua'),
              onPressed: () => widget.onLanguageChanged(
                isGl ? AppLanguage.es : AppLanguage.gl,
              ),
              child: Text(
                isGl ? 'ES' : 'GL',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('rexistro_outro_neno'),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const LuaPixel(pose: LuaPose.sit, size: 88),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusCard,
                        ),
                        border: Border.all(color: acento.withAlpha(90)),
                      ),
                      child: Text(
                        isGl
                            ? 'Hai outro neno ou nena na casa?'
                            : '¿Hay otro niño o niña en casa?',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final n in nenos)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: acento, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${n.nome} · ${NomesFamilias.idade(n.curso).resolve(lang)}',
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              FilledButton.icon(
                key: const Key('rexistro_outro_si'),
                style: FilledButton.styleFrom(
                  backgroundColor: acento,
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(
                  isGl
                      ? 'Si, engadir outro neno ou nena'
                      : 'Sí, añadir otro niño o niña',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: _prepararOutro,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const Key('rexistro_outro_non'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: acento, width: 1.5),
                  foregroundColor: acento,
                ),
                icon: const Icon(Icons.home_rounded),
                label: Text(
                  isGl ? 'Non, entrar na casa' : 'No, entrar en casa',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: () {
                  final fin = _ultimoGardado ?? widget.store.activa;
                  if (fin != null) {
                    if (widget.onGardado case final f?) {
                      f(fin);
                    } else {
                      Navigator.of(context).pop(fin);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    Widget etiqueta(String t) => Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(
            t,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        );

    final anoActual = _agora.year;
    final anos = [for (var y = anoActual; y >= anoActual - 7; y--) y];
    final meses = isGl ? _mesesGl : _mesesEs;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.primeira || editar,
        leading: widget.primeira && !editar
            ? IconButton(
                tooltip: isGl ? 'Volver ao inicio' : 'Volver al inicio',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          editar
              ? (isGl ? 'Editar' : 'Editar')
              : (isGl ? 'Quen vai aprender?' : '¿Quién va a aprender?'),
        ),
        actions: [
          TextButton(
            key: const Key('rexistro_lingua'),
            onPressed: () => widget.onLanguageChanged(
              isGl ? AppLanguage.es : AppLanguage.gl,
            ),
            child: Text(
              isGl ? 'ES' : 'GL',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('rexistro_crianza'),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const LuaPixel(pose: LuaPose.sit, size: 88),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: acento.withAlpha(90)),
                    ),
                    child: Text(
                      editar
                          ? (isGl
                              ? 'Cambia o que faga falta. O resto queda igual.'
                              : 'Cambia lo que haga falta. El resto queda igual.')
                          : (isGl
                              ? 'Ola, son Lúa. Dime quen vai aprender inglés contigo e non cho volvo preguntar.'
                              : 'Hola, soy Lúa. Dime quién va a aprender inglés contigo y no te lo vuelvo a preguntar.'),
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            etiqueta(isGl ? 'Nome' : 'Nombre'),
            TextField(
              key: const Key('rexistro_nome'),
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              maxLength: 24,
              decoration: InputDecoration(
                hintText: isGl ? 'Nome ou alcume' : 'Nombre o apodo',
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            etiqueta(
              isGl
                  ? 'Mes e ano de nacemento (sen día)'
                  : 'Mes y año de nacimiento (sin día)',
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: const Key('rexistro_mes_nacemento'),
                    initialValue: _mesNacemento,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: isGl ? 'Mes' : 'Mes',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusField,
                        ),
                      ),
                    ),
                    items: [
                      for (var m = 1; m <= 12; m++)
                        DropdownMenuItem<int>(
                          value: m,
                          child: Text(meses[m - 1]),
                        ),
                    ],
                    onChanged: (m) =>
                        _actualizarDesdeNacemento(m, _anoNacemento),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: const Key('rexistro_ano_nacemento'),
                    initialValue:
                        _anoNacemento != null && anos.contains(_anoNacemento)
                            ? _anoNacemento
                            : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: isGl ? 'Ano' : 'Año',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusField,
                        ),
                      ),
                    ),
                    items: [
                      for (final y in anos)
                        DropdownMenuItem<int>(value: y, child: Text('$y')),
                    ],
                    onChanged: (y) =>
                        _actualizarDesdeNacemento(_mesNacemento, y),
                  ),
                ),
              ],
            ),
            etiqueta(isGl ? 'Idade' : 'Edad'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i <= 6; i++)
                  ChoiceChip(
                    key: ValueKey('rexistro_idade_$i'),
                    label: Text(
                      i == 1
                          ? (isGl ? '1 ano' : '1 año')
                          : '$i ${isGl ? 'anos' : 'años'}',
                    ),
                    selected: _idade == i,
                    showCheckmark: false,
                    selectedColor: acento,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _idade == i ? Colors.white : AppTheme.textPrimary,
                    ),
                    onSelected: (_) => setState(() {
                      _idade = i;
                      _mesNacemento ??= _agora.month;
                      _anoNacemento = _agora.year - i;
                      if (widget.crianza == null) _curso = _cursoDe(i);
                    }),
                  ),
              ],
            ),
            etiqueta(isGl ? 'Curso' : 'Curso'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (id, nome) in NomesFamilias.idades)
                  ChoiceChip(
                    key: ValueKey('rexistro_curso_$id'),
                    label: Text(nome.resolve(lang)),
                    selected: _curso == id,
                    showCheckmark: false,
                    selectedColor: acento,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _curso == id ? Colors.white : AppTheme.textPrimary,
                    ),
                    onSelected: (_) => setState(() => _curso = id),
                  ),
              ],
            ),
            etiqueta(isGl ? 'Rutinas da casa' : 'Rutinas de casa'),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                isGl
                    ? 'Elixe unha ou dúas rutinas onde dicir as palabras:'
                    : 'Elige una o dos rutinas donde decir las palabras:',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (clave, gl, es) in const [
                  ('bano', 'Baño', 'Baño'),
                  ('comida', 'Comida', 'Comida'),
                  ('coche', 'Coche', 'Coche'),
                  ('vestirse', 'Vestirse', 'Vestirse'),
                  ('durmir', 'Ir a durmir', 'Ir a dormir'),
                  ('parque', 'Parque', 'Parque'),
                ])
                  FilterChip(
                    key: ValueKey('rexistro_rutina_$clave'),
                    label: Text(isGl ? gl : es),
                    selected: _rutinas.contains(clave),
                    showCheckmark: false,
                    selectedColor: acento,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _rutinas.contains(clave)
                          ? Colors.white
                          : AppTheme.textPrimary,
                    ),
                    onSelected: (_) => setState(() {
                      if (_rutinas.contains(clave)) {
                        if (_rutinas.length > 1) {
                          _rutinas.remove(clave);
                        }
                      } else {
                        if (_rutinas.length >= 2) {
                          _rutinas.removeAt(0);
                        }
                        _rutinas.add(clave);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const Key('rexistro_gardar'),
              style: FilledButton.styleFrom(
                backgroundColor: acento,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.check_rounded),
              label: Text(
                isGl ? 'Gardar' : 'Guardar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: _valido && !_gardando ? _gardar : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isGl
                        ? 'O nome, o mes e o ano de nacemento (sen día) e o curso gárdanse só neste móbil. Non saen de aquí: a app non ten internet. Pódese borrar cando queiras.'
                        : 'El nombre, el mes y el año de nacimiento (sin día) y el curso se guardan solo en este móvil. No salen de aquí: la app no tiene internet. Se puede borrar cuando quieras.',
                    key: const Key('rexistro_privacidade'),
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
