import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/iconos_contenido.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/dia_calendario_dual_model.dart';
import '../../../data/models/progresion_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/widgets/selector_idioma_widget.dart';

/// Calendario Escolar Completo para o Fogar (Familias).
///
/// Ofrece ás familias unha experiencia curricular análoga á do profesorado:
/// - 5 cursos escolares diferenciados (0-2, 2-3, 3-4, 4-5, 5-6 anos).
/// - 10 meses escolares (Setembro a Xuño).
/// - 4 semanas lectivas por mes.
/// - 5 días por semana (Luns a Venres) con actividades concretas para o fogar.
/// - Sincronización coa asemblea escolar, momento cotián e reto TPR oral.
class CalendarioFogarScreen extends StatefulWidget {
  final ContentRepository repository;
  final CalendarioStore store;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final String? initialCursoId;

  const CalendarioFogarScreen({
    super.key,
    required this.repository,
    required this.store,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
    this.onLanguageChanged,
    this.initialCursoId,
  });

  @override
  State<CalendarioFogarScreen> createState() => _CalendarioFogarScreenState();
}

class _CalendarioFogarScreenState extends State<CalendarioFogarScreen> {
  late AppLanguage _language;
  late String _cursoSeleccionado;
  int _mesIndex = 0; // 0..9 (Setembro=0..Xuño=9)
  int _semana = 1; // 1..4
  int _diaSemana = 1; // 1..5 (Luns a Venres)
  List<DiaCalendarioDual> _diasDoMes = const [];
  bool _isLoading = true;

  static const List<Map<String, String>> _cursos = [
    {'id': 'curso_0_2', 'gl': '0-2 anos (Nido)', 'es': '0-2 años (Nido)'},
    {'id': 'curso_2_3', 'gl': '2-3 anos (Maternal)', 'es': '2-3 años (Maternal)'},
    {'id': 'curso_3_4', 'gl': '3-4 anos (4.º Infantil)', 'es': '3-4 años (4.º Infantil)'},
    {'id': 'curso_4_5', 'gl': '4-5 anos (5.º Infantil)', 'es': '4-5 años (5.º Infantil)'},
    {'id': 'curso_5_6', 'gl': '5-6 anos (6.º Infantil)', 'es': '5-6 años (6.º Infantil)'},
  ];

  static const List<Map<String, String>> _mesesNomes = [
    {'gl': 'Setembro', 'es': 'Septiembre'},
    {'gl': 'Outubro', 'es': 'Octubre'},
    {'gl': 'Novembro', 'es': 'Noviembre'},
    {'gl': 'Decembro', 'es': 'Diciembre'},
    {'gl': 'Xaneiro', 'es': 'Enero'},
    {'gl': 'Febreiro', 'es': 'Febrero'},
    {'gl': 'Marzo', 'es': 'Marzo'},
    {'gl': 'Abril', 'es': 'Abril'},
    {'gl': 'Maio', 'es': 'Mayo'},
    {'gl': 'Xuño', 'es': 'Junio'},
  ];

  static const List<Map<String, String>> _diasSemanaNomes = [
    {'gl': 'Luns', 'es': 'Lunes'},
    {'gl': 'Martes', 'es': 'Martes'},
    {'gl': 'Mércores', 'es': 'Miércoles'},
    {'gl': 'Xoves', 'es': 'Jueves'},
    {'gl': 'Venres', 'es': 'Viernes'},
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _cursoSeleccionado = widget.initialCursoId ?? _cursos.first['id']!;
    final hoxe = ProgresionDoMes.hoxe();
    _semana = hoxe.semana;
    _diaSemana = hoxe.dia;
    _cargarDias();
  }

  Future<void> _cargarDias() async {
    setState(() => _isLoading = true);
    // El orden del curso escolar: Setembro é mes 1, Xuño é mes 10
    final mesNumero = _mesIndex + 1;
    final dias = await widget.repository.loadCalendarioDias(
      cursoId: _cursoSeleccionado,
      mes: mesNumero,
    );
    if (!mounted) return;
    setState(() {
      _diasDoMes = dias;
      _isLoading = false;
    });
  }

  DiaCalendarioDual? get _diaActual {
    for (final d in _diasDoMes) {
      if (d.semanaNumero == _semana && d.diaSemanaNumero == _diaSemana) {
        return d;
      }
    }
    return _diasDoMes.isNotEmpty ? _diasDoMes.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;
    final dia = _diaActual;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          isGl ? 'Calendario Escolar no Fogar' : 'Calendario Escolar en el Hogar',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: (newLang) {
                setState(() => _language = newLang);
                widget.onLanguageChanged?.call(newLang);
              },
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de Selección de Curso e Mes
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de Curso da Crianza
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _cursos.map((c) {
                        final isSel = _cursoSeleccionado == c['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(isGl ? c['gl']! : c['es']!),
                            selected: isSel,
                            onSelected: (selected) {
                              if (selected && _cursoSeleccionado != c['id']) {
                                setState(() => _cursoSeleccionado = c['id']!);
                                _cargarDias();
                              }
                            },
                            selectedColor: AppTheme.primaryVigoBlue,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppTheme.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Selector Horizontal de Meses (10 Meses)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mesesNomes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final isSel = _mesIndex == index;
                        final mesNome = isGl
                            ? _mesesNomes[index]['gl']!
                            : _mesesNomes[index]['es']!;
                        return ChoiceChip(
                          label: Text(mesNome),
                          selected: isSel,
                          onSelected: (selected) {
                            if (selected && _mesIndex != index) {
                              setState(() => _mesIndex = index);
                              _cargarDias();
                            }
                          },
                          selectedColor: const Color(0xFFE2E8F0),
                          backgroundColor: Colors.transparent,
                          labelStyle: TextStyle(
                            color: isSel
                                ? AppTheme.primaryInk
                                : AppTheme.textSecondary,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSel
                                  ? AppTheme.primaryVigoBlue
                                  : const Color(0xFFCBD5E0),
                              width: isSel ? 1.5 : 1.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Selector de Semanas e Días Lectivos
            Container(
              color: const Color(0xFFF7FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // Selector de Semana (1 a 4)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      final s = index + 1;
                      final isSel = _semana == s;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: index < 3 ? 6.0 : 0.0),
                          child: InkWell(
                            onTap: () => setState(() => _semana = s),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSel
                                      ? AppTheme.primaryVigoBlue
                                      : const Color(0xFFE2E8F0),
                                  width: isSel ? 1.5 : 1.0,
                                ),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                '${isGl ? "Semana" : "Semana"} $s',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel
                                      ? AppTheme.primaryInk
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),

                  // Selector de Día (Luns a Venres)
                  Row(
                    children: List.generate(5, (index) {
                      final d = index + 1;
                      final isSel = _diaSemana == d;
                      final diaNome = isGl
                          ? _diasSemanaNomes[index]['gl']!
                          : _diasSemanaNomes[index]['es']!;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: index < 4 ? 6.0 : 0.0),
                          child: InkWell(
                            onTap: () => setState(() => _diaSemana = d),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppTheme.primaryVigoBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSel
                                      ? AppTheme.primaryVigoBlue
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                diaNome.substring(0, 3).toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Contido Detallado do Día
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dia == null
                      ? Center(
                          child: Text(
                            isGl
                                ? 'Non hai actividades dispoñibles para este día.'
                                : 'No hay actividades disponibles para este día.',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : _buildDetalleDia(dia, isGl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleDia(DiaCalendarioDual dia, bool isGl) {
    final fam = dia.familias;
    final prof = dia.profesorado;
    final estadoHoy = widget.store.estadoParaFecha(DateTime.now());
    final bool feitoHoxe = estadoHoy == EstadoEstimulacion.soloHogar ||
        estadoHoy == EstadoEstimulacion.dobleEstimulacion;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarxeta Principal do Día
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.border),
            ),
            elevation: 0.5,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rótulo do día e tema
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFFFF9EE),
                        child: Icon(
                          Icons.home_rounded,
                          color: Color(0xFFDD6B20),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dia.nombreDiaSemana.resolve(_language)} · ${isGl ? "Semana" : "Semana"} ${dia.semanaNumero}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDD6B20),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dia.temaDia.resolve(_language),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Momento Suxerido do Día
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF2F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: Color(0xFF4A5568)),
                        const SizedBox(width: 6),
                        Text(
                          '${isGl ? "Momento suxerido" : "Momento sugerido"}: ${fam.momento.resolve(_language)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Actividade Concreta no Fogar (3 min)
                  Text(
                    isGl ? 'Xogo de 3 minutos na casa:' : 'Juego de 3 minutos en casa:',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fam.rutinaFogar.resolve(_language),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3748),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Reto TPR en Inglés (L3)
                  if (prof.tprIngles.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF8FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBEE3F8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sports_gymnastics_rounded,
                                  size: 16, color: Color(0xFF2B6CB0)),
                              const SizedBox(width: 6),
                              Text(
                                isGl ? 'Acción TPR en Inglés' : 'Acción TPR en Inglés',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2B6CB0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '«${prof.tprIngles}»',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A365D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Conexión coa Escola Infantil
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF6D4A0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.school_outlined,
                                size: 16, color: Color(0xFFC05621)),
                            const SizedBox(width: 6),
                            Text(
                              isGl
                                  ? 'Conexión coa Escola'
                                  : 'Conexión con la Escuela',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC05621),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fam.fraseConexion.resolve(_language),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A5568),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Consello Pedagóxico para a Familia
                  Text(
                    isGl ? 'Pauta para a persoa adulta:' : 'Pauta para la persona adulta:',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fam.consignaFamilia.resolve(_language),
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Botón 1-Tap para Marcar como Feito Hoxe
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.touchMin,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.store.marcarDiaHogar(DateTime.now());
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isGl
                                  ? 'Xogo do fogar rexistrado. Moitas grazas polo teu tempo!'
                                  : 'Juego del hogar registrado. ¡Muchas gracias por tu tiempo!',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(
                        feitoHoxe ? Icons.check_circle : Icons.check_circle_outline,
                        size: 20,
                      ),
                      label: Text(
                        feitoHoxe
                            ? (isGl ? 'Xogo Feito Hoxe no Fogar' : 'Juego Hecho Hoy en el Hogar')
                            : (isGl ? 'Marcar como Feito Hoxe' : 'Marcar como Hecho Hoy'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            feitoHoxe ? const Color(0xFF2F855A) : AppTheme.primaryVigoBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cadro de Total de Días e Racha
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const LuaPixel(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGl ? 'O teu seguimento no fogar' : 'Tu seguimiento en el hogar',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${isGl ? "Días xogados" : "Días jugados"}: ${widget.store.totalSesionesHogar} · ${isGl ? "Racha actual" : "Racha actual"}: ${widget.store.rachaActual} ${isGl ? "días" : "días"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
