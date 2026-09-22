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
import '../../../data/models/calendario_model.dart';
import '../../../data/models/dia_calendario_dual_model.dart';
import '../../../data/models/progresion_model.dart';
import '../../../data/repositories/calendario_repository.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/widgets/selector_idioma_widget.dart';

/// Calendario Escolar Completo para o Fogar (Familias).
///
/// Ofrece ás familias unha experiencia curricular análoga e simétrica á do profesorado:
/// - 5 cursos escolares diferenciados (0-2, 2-3, 3-4, 4-5, 5-6 anos).
/// - 10 meses escolares (Setembro a Xuño).
/// - Reixa de calendario escolar mensual de 20 días lectivos (4 semanas x 5 días).
/// - Selección directa por día, con rutina de 3 min, momento do día, frase de conexión
///   coa asemblea de aula e reto TPR oral en inglés con reprodución de son nativo.
/// - Rexistro 1-toque no CalendarioStore e seguimento de racha.
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
  CalendarioContenido? _contenido;
  bool _isLoading = true;
  bool _amosarReixaCompleta = true;

  static const List<Map<String, String>> _cursos = [
    {'id': 'curso_0_2', 'gl': '0-2 anos (Nido)', 'es': '0-2 años (Nido)'},
    {
      'id': 'curso_2_3',
      'gl': '2-3 anos (Maternal)',
      'es': '2-3 años (Maternal)'
    },
    {
      'id': 'curso_3_4',
      'gl': '3-4 anos (4.º Infantil)',
      'es': '3-4 años (4.º Infantil)'
    },
    {
      'id': 'curso_4_5',
      'gl': '4-5 anos (5.º Infantil)',
      'es': '4-5 años (5.º Infantil)'
    },
    {
      'id': 'curso_5_6',
      'gl': '5-6 anos (6.º Infantil)',
      'es': '5-6 años (6.º Infantil)'
    },
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

    CalendarioContenido.cargar().then((c) {
      if (mounted) {
        setState(() => _contenido = c);
      }
    });

    _cargarDias();
  }

  Future<void> _cargarDias() async {
    setState(() => _isLoading = true);
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

  MesCurricular? get _mesCurricularActual {
    final meses = _contenido?.meses;
    if (meses == null || _mesIndex >= meses.length) return null;
    return meses[_mesIndex];
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;
    final dia = _diaActual;
    final mesCurricular = _mesCurricularActual;
    final estadoHoy = widget.store.estadoParaFecha(DateTime.now());
    final bool feitoHoxe = estadoHoy == EstadoEstimulacion.soloHogar ||
        estadoHoy == EstadoEstimulacion.dobleEstimulacion;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          isGl
              ? 'Calendario Escolar no Fogar'
              : 'Calendario Escolar en el Hogar',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isGl
                ? 'Cambiar vista de calendario'
                : 'Cambiar vista de calendario',
            icon: Icon(
              _amosarReixaCompleta
                  ? Icons.calendar_view_month_rounded
                  : Icons.view_day_rounded,
              color: AppTheme.primaryVigoBlue,
            ),
            onPressed: () {
              setState(() => _amosarReixaCompleta = !_amosarReixaCompleta);
            },
          ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // 1. Selector Horizontal de Curso Escolar
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
                              color:
                                  isSel ? Colors.white : AppTheme.textPrimary,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Selector Horizontal dos 10 Meses Lectivos
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
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel
                                ? AppTheme.primaryInk
                                : AppTheme.textSecondary,
                            fontWeight:
                                isSel ? FontWeight.w800 : FontWeight.w500,
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
                  const SizedBox(height: 14),

                  // 3. Cadro Resumo do Mes Escolar
                  if (mesCurricular != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppTheme.primaryTint,
                                child: Icon(
                                  iconoDeContenido(mesCurricular.icono),
                                  color: AppTheme.primaryDark,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${isGl ? _mesesNomes[_mesIndex]["gl"] : _mesesNomes[_mesIndex]["es"]} · ${mesCurricular.centroInteres.resolve(lang)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryInk,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mesCurricular.objetivoPedagogico
                                          .resolve(lang),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (mesCurricular.ingles.frase.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF8FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.volume_up_rounded,
                                      size: 16, color: Color(0xFF2B6CB0)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'English (L3): «${mesCurricular.ingles.frase}»',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A365D),
                                      ),
                                    ),
                                  ),
                                  BotonEscuchar(
                                    audioService: widget.audioService,
                                    texto: mesCurricular.ingles.frase,
                                    language: AppLanguage.en,
                                    compacto: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 4. Reixa de Calendario Escolar Mensual (20 Días Lectivos: 4 Semanas x 5 Días)
                  if (_amosarReixaCompleta) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isGl
                                    ? 'REIXA ESCOLAR · 20 DÍAS LECTIVOS'
                                    : 'CUADRÍCULA ESCOLAR · 20 DÍAS LECTIVOS',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                isGl
                                    ? 'Toca un día para abrilo'
                                    : 'Toca un día para abrirlo',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Cabeceira L, M, M, X, V
                          Row(
                            children: _diasSemanaNomes.map((d) {
                              return Expanded(
                                child: Text(
                                  (isGl ? d['gl']! : d['es']!)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),
                          const Divider(height: 1),
                          const SizedBox(height: 8),

                          // As 4 semanas do mes
                          ...List.generate(4, (semanaIdx) {
                            final semanaNum = semanaIdx + 1;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: List.generate(5, (diaIdx) {
                                  final diaSemanaNum = diaIdx + 1;
                                  final diaGlobalIdx = semanaIdx * 5 + diaIdx;
                                  final DiaCalendarioDual? diaItem =
                                      diaGlobalIdx < _diasDoMes.length
                                          ? _diasDoMes[diaGlobalIdx]
                                          : null;
                                  final isSelected = _semana == semanaNum &&
                                      _diaSemana == diaSemanaNum;

                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _semana = semanaNum;
                                            _diaSemana = diaSemanaNum;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppTheme.primaryVigoBlue
                                                : const Color(0xFFF7FAFC),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppTheme.primaryVigoBlue
                                                  : const Color(0xFFE2E8F0),
                                              width: isSelected ? 1.5 : 1.0,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '${diaGlobalIdx + 1}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Icon(
                                                Icons.circle,
                                                size: 5,
                                                color: isSelected
                                                    ? Colors.white
                                                    : (diaItem != null
                                                        ? AppTheme.primaryDark
                                                        : Colors.transparent),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    // Selector de Semanas e Días en modo pastillas
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: List.generate(4, (index) {
                              final s = index + 1;
                              final isSel = _semana == s;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: index < 3 ? 6.0 : 0.0),
                                  child: ChoiceChip(
                                    label: Text(
                                        '${isGl ? "Semana" : "Semana"} $s'),
                                    selected: isSel,
                                    onSelected: (selected) {
                                      if (selected) setState(() => _semana = s);
                                    },
                                    selectedColor: AppTheme.primaryVigoBlue,
                                    labelStyle: TextStyle(
                                      color: isSel
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
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
                                  child: ChoiceChip(
                                    label: Text(diaNome.substring(0, 3)),
                                    selected: isSel,
                                    onSelected: (selected) {
                                      if (selected)
                                        setState(() => _diaSemana = d);
                                    },
                                    selectedColor: AppTheme.primaryVigoBlue,
                                    labelStyle: TextStyle(
                                      color: isSel
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 5. Contido Detallado do Día Seleccionado
                  if (dia != null) ...[
                    _buildDetalleDoDia(dia, isGl, feitoHoxe),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Text(
                        isGl
                            ? 'Non hai actividades dispoñibles para este día.'
                            : 'No hay actividades disponibles para este día.',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 6. Cadro de Seguimento do Fogar e Racha
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
                                isGl
                                    ? 'O teu seguimento no fogar'
                                    : 'Tu seguimiento en el hogar',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isGl
                                    ? 'Total sesións na casa: ${widget.store.totalSesionesHogar} · Racha: ${widget.store.rachaActual} días'
                                    : 'Total sesiones en casa: ${widget.store.totalSesionesHogar} · Racha: ${widget.store.rachaActual} días',
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
      ),
    );
  }

  Widget _buildDetalleDoDia(DiaCalendarioDual dia, bool isGl, bool feitoHoxe) {
    final fam = dia.familias;
    final prof = dia.profesorado;
    final diaSemanaNome = isGl
        ? _diasSemanaNomes[dia.diaSemanaNumero - 1]['gl']!
        : _diasSemanaNomes[dia.diaSemanaNumero - 1]['es']!;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera do Día
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryVigoBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$diaSemanaNome · ${isGl ? "Semana" : "Semana"} ${dia.semanaNumero}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Día ${dia.diaCursoNumero} do curso',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tema do Día
            Text(
              dia.temaDia.resolve(_language),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryInk,
              ),
            ),
            const SizedBox(height: 10),

            // Momento Suxerido do Día no Fogar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 15, color: Color(0xFF4A5568)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${isGl ? "Momento suxerido" : "Momento sugerido"}: ${fam.momento.resolve(_language)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Actividade Concreta no Fogar (3 min)
            Text(
              isGl
                  ? 'Xogo de 3 minutos na casa:'
                  : 'Juego de 3 minutos en casa:',
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

            // Reto TPR en Inglés (L3) con BotonEscuchar
            if ((prof.tprIngles ?? '').isNotEmpty) ...[
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
                          isGl
                              ? 'Acción TPR en Inglés'
                              : 'Acción TPR en Inglés',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B6CB0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '«${prof.tprIngles}»',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A365D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BotonEscuchar(
                          audioService: widget.audioService,
                          texto: prof.tprIngles!,
                          language: AppLanguage.en,
                          compacto: true,
                        ),
                      ],
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
                            ? 'Conexión coa Escola Infantil'
                            : 'Conexión con la Escuela Infantil',
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
              isGl
                  ? 'Pauta para a persoa adulta:'
                  : 'Pauta para la persona adulta:',
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
                  widget.store.registrarHogar(DateTime.now());
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
                      ? (isGl
                          ? 'Xogo Feito Hoxe no Fogar'
                          : 'Juego Hecho Hoy en el Hogar')
                      : (isGl
                          ? 'Marcar como Feito Hoxe'
                          : 'Marcar como Hecho Hoy'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: feitoHoxe
                      ? const Color(0xFF2F855A)
                      : AppTheme.primaryVigoBlue,
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
    );
  }
}
