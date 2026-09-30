import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/steam_model.dart';

/// El ámbar del módulo STEAM, el mismo en las dos tarjetas de los portales.
const Color steamTinta = Color(0xFF92400E);
const Color steamFondo = Color(0xFFFEF3C7);

/// Los textos de interfaz del módulo, en las dos lenguas.
class SteamTextos {
  SteamTextos._();

  static const titulo = LocalizedString(
    gl: 'STEAM · Ciencia coas mans',
    es: 'STEAM · Ciencia con las manos',
  );

  static const paraAula =
      LocalizedString(gl: 'Para a aula', es: 'Para el aula');
  static const paraCasa = LocalizedString(gl: 'Para casa', es: 'Para casa');

  static const senPantallas = LocalizedString(
    gl: 'A criatura non mira a pantalla: les ti e falas ti. As mans, os ollos e as orellas son para os materiais.',
    es: 'La criatura no mira la pantalla: lees tú y hablas tú. Las manos, los ojos y los oídos son para los materiales.',
  );

  static const abrirSesion =
      LocalizedString(gl: 'Abrir a sesión', es: 'Abrir la sesión');

  static const todas = LocalizedString(gl: 'Todas', es: 'Todas');

  static LocalizedString audiencia(SteamAudiencia a) =>
      a == SteamAudiencia.aula ? paraAula : paraCasa;
}

/// Una pastilla pequeña con icono. El texto puede partirse en dos líneas: en
/// gallego y con la letra grande del sistema, una pastilla de una sola línea
/// se salía de la tarjeta.
class SteamPastilla extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color tinta;
  final Color fondo;

  const SteamPastilla({
    super.key,
    required this.icono,
    required this.texto,
    this.tinta = AppTheme.primaryInk,
    this.fondo = AppTheme.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: tinta),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: tinta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// El nivel, la edad y la duración de una unidad, en una fila que se parte
/// cuando no cabe.
class SteamDatosUnidad extends StatelessWidget {
  final SteamUnit unidad;
  final AppLanguage language;

  const SteamDatosUnidad({
    super.key,
    required this.unidad,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        SteamPastilla(
          icono: Icons.child_care_rounded,
          texto: unidad.rangoEdad.resolve(language),
          tinta: steamTinta,
          fondo: steamFondo,
        ),
        SteamPastilla(
          icono: Icons.schedule_rounded,
          texto: '${unidad.tiempoEstimadoMin} min',
        ),
      ],
    );
  }
}
