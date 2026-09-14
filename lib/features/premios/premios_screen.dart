import 'package:flutter/material.dart';

import '../../core/brand/lua_pixel.dart';
import '../../core/brand/pixel_award.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/calendario_model.dart';
import 'medallas_widget.dart';
import 'premios_model.dart';
import 'premios_repository.dart';

/// «Os premios de Lúa», con la estructura de la hoja de premios de Valeria+
/// (`docs/screenshots/26-premios-insignias.png`): cabecera con la gata, nivel y
/// barra de XP; tarjeta de racha y XP total; y la rejilla de insignias, las
/// ganadas en color y las pendientes en gris.
///
/// La diferencia con Valeria+ no es estética, es de fondo: allí estos premios
/// son del niño, que juega. Aquí el niño no toca la pantalla, así que hay dos
/// recorridos de ADULTO —la maestra por asambleas dirigidas, la familia por
/// cápsulas leídas— y un conmutador para pasar de uno a otro.
class PremiosScreen extends StatefulWidget {
  final PremiosRepository repository;
  final AppLanguage currentLanguage;
  final Perfil perfilInicial;

  /// Las tres cuentas del Calendario Escola·Fogar. Sin ellas no se pintan las
  /// medallas: no se enseña una colección cuyo avance no se puede saber.
  final ContadoresCalendario? contadores;

  const PremiosScreen({
    super.key,
    required this.repository,
    required this.currentLanguage,
    this.perfilInicial = Perfil.docente,
    this.contadores,
  });

  static const titulo = LocalizedString(
    gl: 'Os premios de Lúa',
    es: 'Los premios de Lúa',
  );

  @override
  State<PremiosScreen> createState() => _PremiosScreenState();
}

class _PremiosScreenState extends State<PremiosScreen> {
  late Perfil _perfil = widget.perfilInicial;

  static const _medallas = LocalizedString(
    gl: 'Medallas do calendario',
    es: 'Medallas del calendario',
  );

  static const _docente = LocalizedString(gl: 'Mestra', es: 'Maestra');
  static const _familia = LocalizedString(gl: 'Familia', es: 'Familia');

  static const _racha = LocalizedString(
    gl: 'días seguidos',
    es: 'días seguidos',
  );
  static const _xpTotal = LocalizedString(gl: 'XP en total', es: 'XP en total');

  static const _paraSiguiente = LocalizedString(
    gl: 'XP para o seguinte nivel',
    es: 'XP para el siguiente nivel',
  );
  static const _nivelMaximo = LocalizedString(
    gl: 'Chegaches ao último nivel',
    es: 'Llegaste al último nivel',
  );

  static const _insignias = LocalizedString(gl: 'Insignias', es: 'Insignias');

  static const _vacioDocente = LocalizedString(
    gl: 'Aínda non dirixiches ningunha asemblea. A primeira xa dá insignia.',
    es: 'Todavía no dirigiste ninguna asamblea. La primera ya da insignia.',
  );
  static const _vacioFamilia = LocalizedString(
    gl: 'Aínda non liches ningunha cápsula. A primeira xa dá insignia.',
    es: 'Todavía no leíste ninguna cápsula. La primera ya da insignia.',
  );

  static const _sinCatalogo = LocalizedString(
    gl: 'Os premios non están dispoñibles agora mesmo. O resto da app funciona '
        'igual.',
    es: 'Los premios no están disponibles ahora mismo. El resto de la app '
        'funciona igual.',
  );

  static const _nota = LocalizedString(
    gl: 'Estes premios son para a persoa adulta que usa a app. Aquí non se '
        'garda nada de ningunha crianza.',
    es: 'Estos premios son para la persona adulta que usa la app. Aquí no se '
        'guarda nada de ninguna criatura.',
  );

  @override
  void initState() {
    super.initState();
    // Una racha vieja no puede seguir en pantalla como si estuviera viva.
    widget.repository.refrescarRachas();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.currentLanguage;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(PremiosScreen.titulo.resolve(lang))),
      // targetSdk 36 obliga al borde a borde en Android 15+: la ventana
      // ya no reserva la barra de gestos y el final de esta pantalla
      // quedaba por debajo. `top: false` porque el inset de arriba ya lo
      // consume el AppBar; volver a pedirlo aquí no suma nada.
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: widget.repository,
          builder: (context, _) {
            final catalogo = widget.repository.catalogo;
            if (catalogo == null) {
              // Un spinner eterno dice «espera, ya viene» cuando en realidad no
              // viene nada: si el catálogo no está, no va a estar. Se dice lo que
              // pasa, y el resto de la app sigue funcionando igual sin premios.
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceXl),
                  child: Text(
                    _sinCatalogo.resolve(lang),
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: AppTheme.textMuted),
                  ),
                ),
              );
            }
            final progreso = widget.repository.progresoDe(_perfil);
            final insignias = catalogo.insigniasDe(_perfil);
            final ganadas = insignias
                .where((i) => progreso.insignias.contains(i.id))
                .length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceLg,
                AppTheme.spaceLg,
                AppTheme.spaceLg,
                AppTheme.spaceXxl,
              ),
              children: [
                _SelectorPerfil(
                  perfil: _perfil,
                  docente: _docente.resolve(lang),
                  familia: _familia.resolve(lang),
                  onChanged: (p) => setState(() => _perfil = p),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _Cabecera(
                  progreso: progreso,
                  catalogo: catalogo,
                  lang: lang,
                  paraSiguiente: _paraSiguiente.resolve(lang),
                  nivelMaximo: _nivelMaximo.resolve(lang),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _Cifras(
                  racha: progreso.rachaActual,
                  rachaLabel: _racha.resolve(lang),
                  xp: progreso.xp(catalogo),
                  xpLabel: _xpTotal.resolve(lang),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                Text(
                  '${_insignias.resolve(lang)} · $ganadas / ${insignias.length}',
                  style: text.titleSmall,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                if (progreso.eventos == 0)
                  _Aviso(
                    texto: _perfil == Perfil.docente
                        ? _vacioDocente.resolve(lang)
                        : _vacioFamilia.resolve(lang),
                  ),
                ...insignias.map(
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                    child: _TarjetaInsignia(
                      insignia: i,
                      ganada: progreso.insignias.contains(i.id),
                      lang: lang,
                    ),
                  ),
                ),
                if (widget.contadores != null &&
                    catalogo.medallasDe(_perfil).isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spaceXl),
                  MedallasCalendario(
                    medallas: catalogo.medallasDe(_perfil),
                    contadores: widget.contadores!,
                    lang: lang,
                    titulo: _medallas.resolve(lang),
                  ),
                ],
                const SizedBox(height: AppTheme.spaceMd),
                Text(
                  _nota.resolve(lang),
                  style: text.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SelectorPerfil extends StatelessWidget {
  final Perfil perfil;
  final String docente;
  final String familia;
  final ValueChanged<Perfil> onChanged;

  const _SelectorPerfil({
    required this.perfil,
    required this.docente,
    required this.familia,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Perfil>(
      segments: [
        ButtonSegment(value: Perfil.docente, label: Text(docente)),
        ButtonSegment(value: Perfil.familia, label: Text(familia)),
      ],
      selected: {perfil},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final Progreso progreso;
  final CatalogoPremios catalogo;
  final AppLanguage lang;
  final String paraSiguiente;
  final String nivelMaximo;

  const _Cabecera({
    required this.progreso,
    required this.catalogo,
    required this.lang,
    required this.paraSiguiente,
    required this.nivelMaximo,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nivel = progreso.nivelActual(catalogo);
    final falta = progreso.xpParaSiguiente(catalogo);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        // Turquesa profundo: sobre el de marca el texto blanco daría 2,18:1.
        color: AppTheme.primaryInk,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusField),
            ),
            child: const LuaPixel(size: 56),
          ),
          const SizedBox(width: AppTheme.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // El pescado del nivel: el metal sube con él, así que el
                    // nivel se ve sin leer el número.
                    PixelAward(
                      glyph: nivel.glifo,
                      tier: nivel.rango,
                      size: 26,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Text(
                        'Nivel ${nivel.nivel} · ${nivel.titulo.resolve(lang)}',
                        style: text.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.spaceSm),
                  child: LinearProgressIndicator(
                    value: progreso.avanceDeNivel(catalogo),
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  falta > 0 ? '$falta $paraSiguiente' : nivelMaximo,
                  style: text.bodySmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cifras extends StatelessWidget {
  final int racha;
  final String rachaLabel;
  final int xp;
  final String xpLabel;

  const _Cifras({
    required this.racha,
    required this.rachaLabel,
    required this.xp,
    required this.xpLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(child: _Cifra(valor: '$racha', etiqueta: rachaLabel)),
          Container(width: 1, height: 48, color: AppTheme.border),
          Expanded(child: _Cifra(valor: '$xp', etiqueta: xpLabel)),
        ],
      ),
    );
  }
}

class _Cifra extends StatelessWidget {
  final String valor;
  final String etiqueta;

  const _Cifra({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(valor, style: text.headlineMedium),
        const SizedBox(height: AppTheme.spaceXs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
          child: Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _TarjetaInsignia extends StatelessWidget {
  final Insignia insignia;
  final bool ganada;
  final AppLanguage lang;

  const _TarjetaInsignia({
    required this.insignia,
    required this.ganada,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: ganada ? 'Insignia gañada' : 'Insignia pendente',
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: ganada ? AppTheme.primaryTint : AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
            color: ganada ? AppTheme.borderActive : AppTheme.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // El dibujo de la insignia, no un tic genérico. Antes las nueve
            // se veían iguales: un check si estaba ganada y un candado si no,
            // así que la colección no era una colección de nada. Ahora el
            // glifo dice QUÉ se hizo y el metal CUÁNTO, y sin ganar se ve la
            // silueta en gris: la forma se reconoce antes de tenerla.
            PixelAward(
              glyph: insignia.glifo,
              tier: insignia.rango,
              size: 52,
              locked: !ganada,
            ),
            const SizedBox(width: AppTheme.spaceLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insignia.titulo.resolve(lang),
                    style: text.titleSmall?.copyWith(
                      color: ganada ? AppTheme.textPrimary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    insignia.descripcion.resolve(lang),
                    style: text.bodySmall?.copyWith(
                      color:
                          ganada ? AppTheme.textSecondary : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  final String texto;

  const _Aviso({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceLg),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.primaryTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderActive),
      ),
      child: Text(
        texto,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppTheme.primaryInk),
      ),
    );
  }
}
