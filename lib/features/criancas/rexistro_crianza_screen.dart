import 'package:flutter/material.dart';

import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';
import '../familias/nomes_familias.dart';
import 'criancas_store.dart';

/// El registro de un niño de la casa (O-20261109-1): Lúa, el nombre, la
/// edad y el curso. Se rellena una vez; después la app abre con él.
///
/// Sirve para dar de alta y para editar: con [crianza] viene relleno.
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
  });

  final CriancasStore store;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final Crianza? crianza;
  final String? cursoInicial;

  /// Sin él, la pantalla se cierra al guardar.
  final ValueChanged<Crianza>? onGardado;

  /// La primera vez que se entra en casa: sin flecha de volver a la casa.
  final bool primeira;

  @override
  State<RexistroCrianzaScreen> createState() => _RexistroCrianzaScreenState();
}

class _RexistroCrianzaScreenState extends State<RexistroCrianzaScreen> {
  late final TextEditingController _nome =
      TextEditingController(text: widget.crianza?.nome ?? '');
  late int? _idade = widget.crianza?.idade;
  late String? _curso = widget.crianza?.curso ?? widget.cursoInicial;
  bool _gardando = false;

  /// El curso que suele ir con cada edad. Se propone, no se impone: un niño
  /// nacido en diciembre puede ir con los de un año menos.
  static String _cursoDe(int idade) => switch (idade) {
        0 || 1 => 'curso_0_2',
        2 => 'curso_2_3',
        3 => 'curso_3_4',
        4 => 'curso_4_5',
        _ => 'curso_5_6',
      };

  bool get _valido =>
      _nome.text.trim().isNotEmpty && _idade != null && _curso != null;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _gardar() async {
    if (!_valido || _gardando) return;
    setState(() => _gardando = true);
    final store = widget.store;
    final Crianza c;
    if (widget.crianza case final orixe?) {
      await store.actualizar(orixe.id,
          nome: _nome.text, idade: _idade, curso: _curso);
      c = store.criancas.firstWhere((x) => x.id == orixe.id);
    } else {
      c = await store.engadir(nome: _nome.text, idade: _idade!, curso: _curso!);
    }
    if (!mounted) return;
    if (widget.onGardado case final f?) {
      f(c);
    } else {
      Navigator.of(context).pop(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final acento = context.acento;
    final editar = widget.crianza != null;

    Widget etiqueta(String t) => Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(t,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
        );

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
        title: Text(editar
            ? (isGl ? 'Editar' : 'Editar')
            : (isGl ? 'Quen vai aprender?' : '¿Quién va a aprender?')),
        actions: [
          TextButton(
            key: const Key('rexistro_lingua'),
            onPressed: () => widget
                .onLanguageChanged(isGl ? AppLanguage.es : AppLanguage.gl),
            child: Text(isGl ? 'ES' : 'GL',
                style: const TextStyle(fontWeight: FontWeight.w800)),
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
                          color: AppTheme.textPrimary),
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
            etiqueta(isGl ? 'Idade' : 'Edad'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i <= 6; i++)
                  ChoiceChip(
                    key: ValueKey('rexistro_idade_$i'),
                    label: Text(i == 1
                        ? (isGl ? '1 ano' : '1 año')
                        : '$i ${isGl ? 'anos' : 'años'}'),
                    selected: _idade == i,
                    showCheckmark: false,
                    selectedColor: acento,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _idade == i ? Colors.white : AppTheme.textPrimary,
                    ),
                    onSelected: (_) => setState(() {
                      _idade = i;
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
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const Key('rexistro_gardar'),
              style: FilledButton.styleFrom(
                backgroundColor: acento,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.check_rounded),
              label: Text(isGl ? 'Gardar' : 'Guardar',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              onPressed: _valido && !_gardando ? _gardar : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isGl
                        ? 'O nome, a idade e o curso gárdanse só neste móbil. Non saen de aquí: a app non ten internet. Pódese borrar cando queiras.'
                        : 'El nombre, la edad y el curso se guardan solo en este móvil. No salen de aquí: la app no tiene internet. Se puede borrar cuando quieras.',
                    key: const Key('rexistro_privacidade'),
                    style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: AppTheme.textSecondary),
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
