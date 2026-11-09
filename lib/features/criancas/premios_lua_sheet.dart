import 'package:flutter/material.dart';

import '../../core/brand/lua_valeria.dart';
import '../../core/brand/pixel_award.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';
import 'criancas_store.dart';
import 'xogo_lua.dart';

/// La colección de premios de Lúa, copiada de
/// FrankBetances/Valeria:src/ValeriaAwardsSheet.tsx (O-20261109-3): el
/// nivel con su barra, la racha y el XP; la escalera de los 12 niveles; las 18
/// insignias, las ganadas en color y las que faltan en gris con su condición
/// escrita; y el armario de Lúa, donde se pone lo desbloqueado.
Future<void> abrirPremiosLua(
  BuildContext context, {
  required CriancasStore store,
  required Crianza crianza,
  required CatalogoLua catalogo,
  required AppLanguage language,
  required DateTime agora,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        builder: (ctx, scroll) => ListenableBuilder(
          listenable: store,
          builder: (ctx, _) => _Coleccion(
            scroll: scroll,
            store: store,
            crianza: crianza,
            c: catalogo,
            lang: language,
            agora: agora,
          ),
        ),
      ),
    );

class _Coleccion extends StatelessWidget {
  final ScrollController scroll;
  final CriancasStore store;
  final Crianza crianza;
  final CatalogoLua c;
  final AppLanguage lang;
  final DateTime agora;

  const _Coleccion({
    required this.scroll,
    required this.store,
    required this.crianza,
    required this.c,
    required this.lang,
    required this.agora,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = lang == AppLanguage.gl;
    final acento = context.acento;
    final g = store.xogo(crianza.id);
    final nivel = c.nivel(g.xp);
    final maximo = nivel >= c.nivelMaximo;
    final racha = g.rachaViva(agora);
    final ganadas = c.insignias.where((i) => g.insignias.contains(i.id));

    Text seccion(String t) => Text(t,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
            color: AppTheme.textSecondary));

    return ListView(
      key: const Key('premios_lua'),
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        Row(
          children: [
            LuaValeria(ancho: 56, cabeza: g.cabeza, pescozo: g.pescozo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.textos['titulo']!.resolve(lang),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary)),
                  Text(
                      '${crianza.nome} · Nivel $nivel · ${c.nomeNivel(nivel).resolve(lang)}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: acento)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: maximo ? 1 : c.progreso(g.xp),
            minHeight: 10,
            backgroundColor: const Color(0xFFE3ECEC),
            color: acento,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          maximo
              ? c.textos['maxNivel']!.resolve(lang)
              : (isGl
                  ? '${c.xpParaSeguinte(g.xp)} XP para o seguinte nivel'
                  : '${c.xpParaSeguinte(g.xp)} XP para el siguiente nivel'),
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Dato(
              icono: PixelAward(
                  glyph: AwardGlyph.flame,
                  tier: tierDeRacha(racha),
                  size: 26,
                  locked: racha == 0),
              valor: '$racha',
              texto: racha == 0
                  ? (isGl ? 'Empeza hoxe a racha' : 'Empieza hoy la racha')
                  : (isGl
                      ? (racha == 1 ? '1 día de racha' : '$racha días de racha')
                      : (racha == 1
                          ? '1 día de racha'
                          : '$racha días de racha')),
            ),
            const SizedBox(width: 10),
            _Dato(
              icono: const PixelAward(
                  glyph: AwardGlyph.star, tier: AwardTier.gold, size: 26),
              valor: '${g.xp}',
              texto: isGl ? 'XP en total' : 'XP en total',
            ),
          ],
        ),
        const SizedBox(height: 18),
        seccion(c.textos['escaleira']!.resolve(lang).toUpperCase()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var n = 1; n <= c.nivelMaximo; n++)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: n <= nivel ? context.acentoTint : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: n == nivel ? acento : AppTheme.border,
                      width: n == nivel ? 1.5 : 1),
                ),
                child: Text('$n · ${c.nomeNivel(n).resolve(lang)}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            n == nivel ? FontWeight.w900 : FontWeight.w600,
                        color: n <= nivel ? acento : AppTheme.textSecondary)),
              ),
          ],
        ),
        const SizedBox(height: 18),
        seccion(isGl
            ? 'INSIGNIAS · ${ganadas.length} DE ${c.insignias.length}'
            : 'INSIGNIAS · ${ganadas.length} DE ${c.insignias.length}'),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, box) {
          final ancho = (box.maxWidth - 16) / 3;
          return Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              for (final i in c.insignias)
                SizedBox(
                  width: ancho,
                  child: Semantics(
                    label:
                        '${i.nome.resolve(lang)}. ${g.insignias.contains(i.id) ? (isGl ? 'Conseguida' : 'Conseguida') : (isGl ? 'Aínda non conseguida' : 'Todavía no conseguida')}.',
                    excludeSemantics: true,
                    child: Column(
                      key: ValueKey('insignia_${i.id}'),
                      children: [
                        PixelAward(
                            glyph: i.glyph,
                            tier: i.tier,
                            size: 44,
                            locked: !g.insignias.contains(i.id)),
                        const SizedBox(height: 4),
                        Text(i.nome.resolve(lang),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: g.insignias.contains(i.id)
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted)),
                        Text(i.di.resolve(lang),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.25,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 6),
        Text(
            isGl
                ? 'As insignias en gris aínda non están conseguidas.'
                : 'Las insignias en gris todavía no están conseguidas.',
            style:
                const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 18),
        seccion(c.textos['armario']!.resolve(lang).toUpperCase()),
        const SizedBox(height: 8),
        for (final o in c.obxectos)
          _Obxecto(
            o: o,
            lang: lang,
            desbloqueado: g.obxectos.contains(o.id),
            posto: g.cabeza == o.id || g.pescozo == o.id,
            textoPosto: c.textos['posto']!.resolve(lang),
            textoPor: c.textos['poñer']!.resolve(lang),
            onTap: o.slot == 'snack' || !g.obxectos.contains(o.id)
                ? null
                : () => store.porObxecto(crianza.id, o),
          ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  final Widget icono;
  final String valor;
  final String texto;
  const _Dato({required this.icono, required this.valor, required this.texto});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              icono,
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(valor,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary)),
                    Text(texto,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _Obxecto extends StatelessWidget {
  final ObxectoLua o;
  final AppLanguage lang;
  final bool desbloqueado;
  final bool posto;
  final String textoPosto;
  final String textoPor;
  final VoidCallback? onTap;
  const _Obxecto({
    required this.o,
    required this.lang,
    required this.desbloqueado,
    required this.posto,
    required this.textoPosto,
    required this.textoPor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final acento = context.acento;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: posto ? context.acentoTint : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
              color: posto ? acento : AppTheme.border, width: posto ? 1.5 : 1),
        ),
        child: InkWell(
          key: ValueKey('obxecto_${o.id}'),
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Opacity(
                  opacity: desbloqueado ? 1 : 0.35,
                  child: SizedBox(
                      width: 44,
                      height: 28,
                      child:
                          Center(child: ObxectoLuaIcona(id: o.id, alto: 24))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.nome.resolve(lang),
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: desbloqueado
                                  ? AppTheme.textPrimary
                                  : AppTheme.textMuted)),
                      Text(
                          desbloqueado
                              ? (o.slot == 'snack'
                                  ? (lang == AppLanguage.gl
                                      ? 'Dispoñible para premiar'
                                      : 'Disponible para premiar')
                                  : (posto ? textoPosto : textoPor))
                              : o.condicion.resolve(lang),
                          style: const TextStyle(
                              fontSize: 12.5, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                if (posto) Icon(Icons.check_rounded, color: acento),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lo que sale al marcar el juego del día: el XP, si sube de nivel, las
/// insignias y los accesorios nuevos. Es la pantalla de fin de sesión de
/// Valeria, para quien lo ha hecho: el niño.
Future<void> mostrarRecompensa(
  BuildContext context,
  RecompensaLua r,
  CatalogoLua c,
  AppLanguage lang, {
  required String nome,
}) {
  final isGl = lang == AppLanguage.gl;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      key: const Key('recompensa_lua'),
      title: Text(
        r.xaXogouHoxe
            ? (isGl ? 'Xa xogastes hoxe' : 'Ya jugasteis hoy')
            : (isGl ? 'Moi ben, $nome!' : '¡Muy bien, $nome!'),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LuaValeria(ancho: 80, cara: CaraLua.love),
          const SizedBox(height: 8),
          if (!r.xaXogouHoxe)
            Text('+${r.xpGanado} XP',
                key: const Key('recompensa_xp'),
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: ctx.acento)),
          if (r.subeNivel)
            Text(
                '${isGl ? 'Novo nivel' : 'Nuevo nivel'}: ${r.nivel} · ${c.nomeNivel(r.nivel).resolve(lang)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          for (final i in r.insigniasNovas) ...[
            const SizedBox(height: 8),
            PixelAward(glyph: i.glyph, tier: i.tier, size: 44),
            Text(i.nome.resolve(lang),
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
          for (final o in r.obxectosNovos) ...[
            const SizedBox(height: 8),
            ObxectoLuaIcona(id: o.id, alto: 24),
            Text(
                '${isGl ? 'Novo para Lúa' : 'Nuevo para Lúa'}: ${o.nome.resolve(lang)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
          if (r.xaXogouHoxe)
            Text(
                isGl
                    ? 'O xogo do día cóntase unha vez. Mañá máis!'
                    : 'El juego del día cuenta una vez. ¡Mañana más!',
                textAlign: TextAlign.center),
        ],
      ),
      actions: [
        FilledButton(
          key: const Key('recompensa_continuar'),
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(isGl ? 'Continuar' : 'Continuar'),
        ),
      ],
    ),
  );
}
