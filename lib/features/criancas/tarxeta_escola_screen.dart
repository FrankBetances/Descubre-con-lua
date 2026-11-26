import 'package:flutter/material.dart';

import '../../core/brand/imaxe_escena.dart';
import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';
import '../familias/nomes_familias.dart';
import 'criancas_store.dart';
import 'proba_entrada.dart';

/// M5 (corrección 26/11/2026): «Tarxeta para a escola / Tarjeta para la escuela».
/// Pantalla pensada para que la familia la enseñe en la escuela infantil:
/// muestra el nombre o apodo, el curso, el peldaño en palabras sencillas y
/// las palabras que ya dice con su lámina. Solo se muestra: ni se envía, ni se
/// comparte, ni se imprime sola, ni lleva porcentajes ni lenguaje clínico.
class TarxetaEscolaScreen extends StatelessWidget {
  const TarxetaEscolaScreen({
    super.key,
    required this.store,
    required this.crianza,
    required this.language,
    this.laminasPorPalabra = const {},
  });

  final CriancasStore store;
  final Crianza crianza;
  final AppLanguage language;
  final Map<String, String> laminasPorPalabra;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final acento = context.acento;
    final cursoNome = NomesFamilias.idade(crianza.curso).resolve(language);
    final peldanoTexto = CatalogoProbaEntrada.textoPeldano(
      crianza.peldano,
      language,
    );
    final palabras = store.palabrasDitas(crianza.id);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: AppTheme.pageBg,
        elevation: 0,
        title: Text(
          isGl ? 'Tarxeta para a escola' : 'Tarjeta para la escuela',
          key: const Key('tarxeta_escola_titulo'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        key: const Key('tarxeta_escola_lista'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
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
                Row(
                  children: [
                    const LuaPixel(pose: LuaPose.sit, size: 64),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crianza.nome,
                            key: const Key('tarxeta_escola_nome'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cursoNome,
                            key: const Key('tarxeta_escola_curso'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: acento,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  peldanoTexto,
                  key: const Key('tarxeta_escola_peldano'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isGl
                      ? 'Esta tarxeta é só para ensinar na escola infantil cando faledes con quen o acompaña.'
                      : 'Esta tarjeta es solo para enseñar en la escuela infantil cuando habléis con quien lo acompaña.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isGl ? 'Palabras que xa di' : 'Palabras que ya dice',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (palabras.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                isGl
                    ? 'Aínda non hai palabras marcadas como ditas na casa.'
                    : 'Todavía no hay palabras marcadas como dichas en casa.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          else
            Wrap(
              key: const Key('tarxeta_escola_palabras'),
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final w in palabras)
                  Container(
                    key: ValueKey(
                      'tarxeta_palabra_${CriancasStore.claveRepaso(w)}',
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (laminasPorPalabra[CriancasStore.claveRepaso(w)]
                            case final lam?) ...[
                          LaminaPalabra(
                            clave: lam,
                            significado: w,
                            lang: language,
                            ancho: 56,
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          w,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
