import 'package:flutter/material.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/selector_idioma_widget.dart';

/// Tramo de edad con su capacidad de atención y micro-rutina recomendada.
class TramoAtencion {
  final LocalizedString rangoEdad;
  final int minutosMaximos;
  final LocalizedString momentoDomestico;
  final LocalizedString queFacer;
  final LocalizedString queEvitar;
  final LocalizedString exemploFraseIngles;
  final IconData icono;

  const TramoAtencion({
    required this.rangoEdad,
    required this.minutosMaximos,
    required this.momentoDomestico,
    required this.queFacer,
    required this.queEvitar,
    required this.exemploFraseIngles,
    required this.icono,
  });
}

/// Pantalla formativa para familias en Academy:
/// Cómo se aprende un segundo idioma en casa sin saturar, respetando la capacidad de atención por edad.
class GuiaAtencionScreen extends StatefulWidget {
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const GuiaAtencionScreen({
    super.key,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
  });

  @override
  State<GuiaAtencionScreen> createState() => _GuiaAtencionScreenState();
}

class _GuiaAtencionScreenState extends State<GuiaAtencionScreen> {
  late AppLanguage _language;
  int _tramoSeleccionado = 0;

  static const _titulo = LocalizedString(
    gl: 'Guía de Atención e Inglés na Casa',
    es: 'Guía de Atención e Inglés en Casa',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Aprender un segundo idioma sen saturar: micro-rutinas, respecto aos tempos e cero pantallas para a crianza.',
    es: 'Aprender un segundo idioma sin saturar: micro-rutinas, respeto a los tiempos y cero pantallas para los peques.',
  );

  static const _principiosKicker = LocalizedString(
    gl: 'TRES REGRAS DE OURO NEUROBIOLÓXICAS',
    es: 'TRES REGLAS DE ORO NEUROBIOLÓGICAS',
  );

  static const _regla1Titulo = LocalizedString(
    gl: '1. O cerebro non se confunde',
    es: '1. El cerebro no se confunde',
  );
  static const _regla1Texto = LocalizedString(
    gl: 'O cerebro infantil pode etiquetar a realidade en galego, castelán e inglés sen interferencias se cada lingua se asocia a emocións e rutinas claras.',
    es: 'El cerebro infantil puede etiquetar la realidad en gallego, castellano e inglés sin interferencias si cada lengua se asocia a emociones y rutinas claras.',
  );

  static const _regla2Titulo = LocalizedString(
    gl: '2. Respecta o "Período de Silencio"',
    es: '2. Respeta el "Período de Silencio"',
  );
  static const _regla2Texto = LocalizedString(
    gl: 'O bebé entende co corpo moitos meses antes de falar en inglés. Non o obrigues nin o examines dicindo "¿Cómo se dice?". O corpo é o seu primeiro tradutor.',
    es: 'El bebé entiende con el cuerpo muchos meses antes de hablar en inglés. No lo obligues ni lo examines diciendo "¿Cómo se dice?". El cuerpo es su primer traductor.',
  );

  static const _regla3Titulo = LocalizedString(
    gl: '3. A app é para ti, non para a crianza',
    es: '3. La app es para ti, no para el peque',
  );
  static const _regla3Texto = LocalizedString(
    gl: 'Escoita o audio ou le o xogo previamente. Cando interactúes con el ou ela, garda o móbil no peto: a linguaxe apréndese cos ollos, a voz e o tacto.',
    es: 'Escucha el audio o lee el juego previamente. Cuando interactúes con él o ella, guarda el móvil en el bolsillo: el lenguaje se aprende con la mirada, la voz y el tacto.',
  );

  static const _selectorEdadKicker = LocalizedString(
    gl: 'CAPACIDADE DE ATENCIÓN SEGUNDO A IDADE',
    es: 'CAPACIDAD DE ATENCIÓN SEGÚN LA EDAD',
  );

  static const List<TramoAtencion> _tramos = [
    TramoAtencion(
      rangoEdad: LocalizedString(gl: '0 a 6 meses', es: '0 a 6 meses'),
      minutosMaximos: 2,
      momentoDomestico: LocalizedString(
        gl: 'Masaxe suave tras o baño ou cambio de cueiro.',
        es: 'Masaje suave tras el baño o cambio de pañal.',
      ),
      queFacer: LocalizedString(
        gl: 'Contacto visual directo, entoación cantadeira ("motherese") e agarimos corporais.',
        es: 'Contacto visual directo, entonación cantarina ("motherese") y caricias corporales.',
      ),
      queEvitar: LocalizedString(
        gl: 'Luces estridentes, pantallas ou sons fortes.',
        es: 'Luces estridentes, pantallas o sonidos fuertes.',
      ),
      exemploFraseIngles: LocalizedString(
        gl: '"Gentle touch... Soft tummy, warm and sweet!"',
        es: '"Gentle touch... Soft tummy, warm and sweet!"',
      ),
      icono: Icons.child_care_rounded,
    ),
    TramoAtencion(
      rangoEdad: LocalizedString(gl: '6 a 12 meses', es: '6 a 12 meses'),
      minutosMaximos: 3,
      momentoDomestico: LocalizedString(
        gl: 'Xogo de ocultación na alfombra (Peek-a-boo).',
        es: 'Juego de ocultación en la alfombra (Peek-a-boo).',
      ),
      queFacer: LocalizedString(
        gl: 'Ocultar a cara tras un pano suave e reaparecer con sorpresa sonriente.',
        es: 'Ocultar el rostro tras un pañuelo suave y reaparecer con sorpresa sonriente.',
      ),
      queEvitar: LocalizedString(
        gl: 'Xogos de máis de 3 minutos que causen irritabilidade.',
        es: 'Juegos de más de 3 minutos que causen irritabilidad.',
      ),
      exemploFraseIngles: LocalizedString(
        gl: '"Peek-a-boo! I see you! Happy baby, smile!"',
        es: '"Peek-a-boo! I see you! Happy baby, smile!"',
      ),
      icono: Icons.visibility_rounded,
    ),
    TramoAtencion(
      rangoEdad: LocalizedString(gl: '12 a 18 meses', es: '12 a 18 meses'),
      minutosMaximos: 5,
      momentoDomestico: LocalizedString(
        gl: 'Ao calzar os zapatos ou mudar a roupa pola mañá.',
        es: 'Al calzar los zapatos o cambiar la ropa por la mañana.',
      ),
      queFacer: LocalizedString(
        gl: 'Mover as extremidades acompañando a palabra: subir mans en "Up" e pés en "Push!".',
        es: 'Mover las extremidades acompañando la palabra: subir manos en "Up" y pies en "Push!".',
      ),
      queEvitar: LocalizedString(
        gl: 'Interrogar ao neno para que repita a palabra.',
        es: 'Interrogar al niño para que repita la palabra.',
      ),
      exemploFraseIngles: LocalizedString(
        gl: '"One foot, two feet. Push, push! Hands up! All done!"',
        es: '"One foot, two feet. Push, push! Hands up! All done!"',
      ),
      icono: Icons.directions_walk_rounded,
    ),
    TramoAtencion(
      rangoEdad: LocalizedString(gl: '18 a 24 meses', es: '18 a 24 meses'),
      minutosMaximos: 6,
      momentoDomestico: LocalizedString(
        gl: 'No lavabo ao lavar as mans ou tomar o baño.',
        es: 'En el lavabo al lavarse las manos o tomar el baño.',
      ),
      queFacer: LocalizedString(
        gl: 'Contraste sensorial: sentir a auga tépeda ("Warm") e fría ("Cold, brrr!").',
        es: 'Contraste sensorial: sentir el agua templada ("Warm") y fría ("Cold, brrr!").',
      ),
      queEvitar: LocalizedString(
        gl: 'Corrixir se mestura galego e inglés (facer reformulación natural).',
        es: 'Corregir si mezcla gallego e inglés (hacer reformulación natural).',
      ),
      exemploFraseIngles: LocalizedString(
        gl: '"Warm water! Rub soap, splash, splash! Clean hands!"',
        es: '"Warm water! Rub soap, splash, splash! Clean hands!"',
      ),
      icono: Icons.water_drop_rounded,
    ),
    TramoAtencion(
      rangoEdad: LocalizedString(gl: '24 a 36 meses', es: '24 a 36 meses'),
      minutosMaximos: 8,
      momentoDomestico: LocalizedString(
        gl: 'Xogo de desprazamento na alfombra do salón.',
        es: 'Juego de desplazamiento en la alfombra del salón.',
      ),
      queFacer: LocalizedString(
        gl: 'Imitar animais (saltar como ras, voar como paxaros) e parar en seco en "FREEZE!".',
        es: 'Imitar animales (saltar como ranas, volar como pájaros) y parar en seco en "FREEZE!".',
      ),
      queEvitar: LocalizedString(
        gl: 'Sesións sedentarias de fichas ou traballo escolarizado.',
        es: 'Sesiones sedentarias de fichas o trabajo escolarizado.',
      ),
      exemploFraseIngles: LocalizedString(
        gl: '"Jump like a frog! Ribbit! Fly like a bird... FREEZE!"',
        es: '"Jump like a frog! Ribbit! Fly like a bird... FREEZE!"',
      ),
      icono: Icons.sports_gymnastics_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tramo = _tramos[_tramoSeleccionado];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        title: Text(
          _titulo.resolve(_language),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _subtitulo.resolve(_language),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Selector horizontal de tramos de edad
            Text(
              _selectorEdadKicker.resolve(_language),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tramos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _tramos[index];
                  final isSelected = index == _tramoSeleccionado;

                  return ChoiceChip(
                    label: Text(item.rangoEdad.resolve(_language)),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _tramoSeleccionado = index);
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Tarjeta del tramo seleccionado
            _buildTramoDetailCard(tramo, theme),
            const SizedBox(height: AppTheme.spaceXl),

            // Tres reglas de oro
            Text(
              _principiosKicker.resolve(_language),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            _buildPrincipioCard(
              title: _regla1Titulo.resolve(_language),
              text: _regla1Texto.resolve(_language),
              icon: Icons.psychology_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            _buildPrincipioCard(
              title: _regla2Titulo.resolve(_language),
              text: _regla2Texto.resolve(_language),
              icon: Icons.volume_off_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            _buildPrincipioCard(
              title: _regla3Titulo.resolve(_language),
              text: _regla3Texto.resolve(_language),
              icon: Icons.phonelink_erase_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppTheme.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildTramoDetailCard(TramoAtencion tramo, ThemeData theme) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  radius: 22,
                  child: Icon(tramo.icono, color: AppTheme.primaryDark, size: 24),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tramo.rangoEdad.resolve(_language),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        _language == AppLanguage.gl
                            ? 'Atención sostida: ata ${tramo.minutosMaximos} minutos'
                            : 'Atención sostenida: hasta ${tramo.minutosMaximos} minutos',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.star),
                  ),
                  child: Text(
                    '${tramo.minutosMaximos} min máx',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            _buildDetailRow(
              label: _language == AppLanguage.gl ? 'Momento da casa:' : 'Momento en casa:',
              content: tramo.momentoDomestico.resolve(_language),
              icon: Icons.alarm_on_rounded,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              label: _language == AppLanguage.gl ? 'Que facer (TPR):' : 'Qué hacer (TPR):',
              content: tramo.queFacer.resolve(_language),
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppTheme.success,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              label: _language == AppLanguage.gl ? 'Que evitar:' : 'Qué evitar:',
              content: tramo.queEvitar.resolve(_language),
              icon: Icons.highlight_off_rounded,
              iconColor: AppTheme.error,
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Frase de ejemplo
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
              ),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over_rounded, color: AppTheme.primaryDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tramo.exemploFraseIngles.resolve(_language),
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
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

  Widget _buildDetailRow({
    required String label,
    required String content,
    required IconData icon,
    Color iconColor = AppTheme.primaryDark,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrincipioCard({
    required String title,
    required String text,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.pageBg,
              radius: 18,
              child: Icon(icon, size: 20, color: AppTheme.primaryDark),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.35,
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
