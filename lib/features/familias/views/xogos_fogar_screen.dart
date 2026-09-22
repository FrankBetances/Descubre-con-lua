import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';

/// Modelo dun xogo ou dinámica física no fogar sen pantallas infantís.
class XogoFogarItem {
  final String id;
  final String tituloGl;
  final String tituloEs;
  final String idade;
  final int duracionMin;
  final String materiaisGl;
  final String materiaisEs;
  final String obxectivoGl;
  final String obxectivoEs;
  final String fraseEn;
  final String guionAdultoGl;
  final String guionAdultoEs;
  final String accionKinestesicaGl;
  final String accionKinestesicaEs;
  final String criterioExitoGl;
  final String criterioExitoEs;

  const XogoFogarItem({
    required this.id,
    required this.tituloGl,
    required this.tituloEs,
    required this.idade,
    required this.duracionMin,
    required this.materiaisGl,
    required this.materiaisEs,
    required this.obxectivoGl,
    required this.obxectivoEs,
    required this.fraseEn,
    required this.guionAdultoGl,
    required this.guionAdultoEs,
    required this.accionKinestesicaGl,
    required this.accionKinestesicaEs,
    required this.criterioExitoGl,
    required this.criterioExitoEs,
  });
}

/// Pantalla de Dinámicas e Xogos Físicos no Fogar.
///
/// Baseada en `/tangible-l2-parent-orchestrator`:
/// 1. Espazo Físico do Neno: manipulativo, cinestésico e puramente acústico (Cero Pantallas).
/// 2. Espazo Dixital do Adulto: partitura de facilitación, comando TPR e rexistro de 1 toque.
class XogosFogarScreen extends StatefulWidget {
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const XogosFogarScreen({
    super.key,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<XogosFogarScreen> createState() => _XogosFogarScreenState();
}

class _XogosFogarScreenState extends State<XogosFogarScreen> {
  late AppLanguage _language;
  String _filtroIdade = 'todas';
  final Map<String, String> _rexistroObservacional =
      {}; // id -> 'L' | 'A' | 'E'

  static const List<XogoFogarItem> _xogos = [
    XogoFogarItem(
      id: 'xogo_01_caza_tesouro',
      tituloGl: 'A Caza do Tesouro dos Sons',
      tituloEs: 'La Caza del Tesoro de los Sonidos',
      idade: '2-4 anos',
      duracionMin: 4,
      materiaisGl: '3 obxectos da casa: culler, mazá e almofada',
      materiaisEs: '3 objetos de la casa: cuchara, manzana y almohada',
      obxectivoGl: 'Discriminación auditiva e discriminación do son inicial',
      obxectivoEs:
          'Discriminación auditiva y discriminación del sonido inicial',
      fraseEn: 'Find the red apple, quick and gentle!',
      guionAdultoGl:
          'Esconde a mazá á vista. Di: «Onde está a mazá? Find the apple!». Agarda 5 segundos en silencio.',
      guionAdultoEs:
          'Esconde la manzana a la vista. Di: «¿Dónde está la manzana? Find the apple!». Espera 5 segundos en silencio.',
      accionKinestesicaGl:
          'A crianza camiña ou gatea polo cuarto ata coller o obxecto e traelo nas mans.',
      accionKinestesicaEs:
          'La criatura camina o gatea por la habitación hasta coger el objeto y traerlo en las manos.',
      criterioExitoGl:
          'Localiza o obxecto e sorrí ao entregalo sen necesidade de indicacións adicionais.',
      criterioExitoEs:
          'Localiza el objeto y sonríe al entregarlo sin necesidad de indicaciones adicionales.',
    ),
    XogoFogarItem(
      id: 'xogo_02_barco_samil',
      tituloGl: 'O Barquiño de Samil na Ría',
      tituloEs: 'El Barquito de Samil en la Ría',
      idade: '0-3 anos',
      duracionMin: 3,
      materiaisGl: 'Colo da persoa adulta ou manta no chan',
      materiaisEs: 'Regazo de la persona adulta o manta en el suelo',
      obxectivoGl: 'Equilibrio vestibular, contacto afectivo e ritmo a 72 bpm',
      obxectivoEs: 'Equilibrio vestibular, contacto afectivo y ritmo a 72 bpm',
      fraseEn: 'Row, row your little boat!',
      guionAdultoGl:
          'Crianza sentada no teu colo mirando cara a ti. Vaivén suave de remo adiante e atrás entoando o ritmo.',
      guionAdultoEs:
          'Criatura sentada en tu regazo mirándote de frente. Vaivén suave de remo adelante y atrás entonando el ritmo.',
      accionKinestesicaGl:
          'Balanzo do torso sincronizado co adulto e parada na calma mariña.',
      accionKinestesicaEs:
          'Balanceo del torso sincronizado con el adulto y parada en la calma marina.',
      criterioExitoGl:
          'Anticipa a parada do movemento mantendo a mirada e o riso compartido.',
      criterioExitoEs:
          'Anticipa la parada del movimiento manteniendo la mirada y la risa compartida.',
    ),
    XogoFogarItem(
      id: 'xogo_03_xigante_formiga',
      tituloGl: 'O Xigante e a Formiguiña',
      tituloEs: 'El Gigante y la Hormiguita',
      idade: '2-5 anos',
      duracionMin: 4,
      materiaisGl: 'Espazo despexado na sala ou corredor',
      materiaisEs: 'Espacio despejado en el salón o pasillo',
      obxectivoGl: 'Contraste acústico forte/feble e inhibición motriz',
      obxectivoEs: 'Contraste acústico fuerte/débil e inhibición motriz',
      fraseEn: 'Big giant stomps! Tiny ant tiptoes!',
      guionAdultoGl:
          'Di con voz grosa: «Stomp like a giant!», pisando forte. Logo susurra: «Tiptoe like an ant», de puntillas.',
      guionAdultoEs:
          'Di con voz grave: «Stomp like a giant!», pisando fuerte. Luego susurra: «Tiptoe like an ant», de puntillas.',
      accionKinestesicaGl:
          'Pisa con forza no chan con todo o corpo e logo camiña en silencio absoluto de puntillas.',
      accionKinestesicaEs:
          'Pisa con fuerza en el suelo con todo el cuerpo y luego camina en silencio absoluto de puntillas.',
      criterioExitoGl:
          'Modula o volume do paso adaptándose ao comando sen precipitación.',
      criterioExitoEs:
          'Modula el volumen del paso adaptándose al comando sin precipitación.',
    ),
    XogoFogarItem(
      id: 'xogo_04_cuncha_escoita',
      tituloGl: 'A Cuncha que Escoita o Mar',
      tituloEs: 'La Concha que Escucha el Mar',
      idade: '1-4 anos',
      duracionMin: 3,
      materiaisGl: 'Unha cuncha grande de Samil ou un vaso de plástico limpo',
      materiaisEs: 'Una concha grande de Samil o un vaso de plástico limpio',
      obxectivoGl:
          'Atención auditiva focalizada e silencio clínico tranquilizador',
      obxectivoEs:
          'Atención auditiva focalizada y silencio clínico tranquilizador',
      fraseEn: 'Listen close, hear the gentle sea!',
      guionAdultoGl:
          'Achega a cuncha á orella do neno/a. Respira amodiño: «Shhh... Escoitas o mar de Vigo?».',
      guionAdultoEs:
          'Acerca la concha a la oreja del niño/a. Respira despacio: «Shhh... ¿Escuchas el mar de Vigo?».',
      accionKinestesicaGl:
          'Inclina a cabeza, pecha os ollos ou pousa a man sobre a cuncha con curiosidade.',
      accionKinestesicaEs:
          'Inclina la cabeza, cierra los ojos o posa la mano sobre la concha con curiosidad.',
      criterioExitoGl:
          'Permanece en escoita tranquila polo menos 5 segundos sen retirar a cabeza.',
      criterioExitoEs:
          'Permanece en escucha tranquila al menos 5 segundos sin retirar la cabeza.',
    ),
    XogoFogarItem(
      id: 'xogo_05_espello_corpo',
      tituloGl: 'O Espello do Corpo e as Emocións',
      tituloEs: 'El Espejo del Cuerpo y las Emociones',
      idade: '2-6 anos',
      duracionMin: 5,
      materiaisGl: 'Espello da casa ou xogo de fronte cara a cara',
      materiaisEs: 'Espejo de la casa o juego de frente cara a cara',
      obxectivoGl: 'Esquema corporal, propiocepción e denominación anatómica',
      obxectivoEs: 'Esquema corporal, propiocepción y denominación anatómica',
      fraseEn: 'Touch your nose, touch your toes!',
      guionAdultoGl:
          'Pon as mans no teu propio nariz e canta a orde en inglés. Despois agarda sen tocar para que o faga el/ela.',
      guionAdultoEs:
          'Pon las manos en tu propia nariz y canta la orden en inglés. Después espera sin tocar para que lo haga él/ella.',
      accionKinestesicaGl:
          'Localiza as partes do corpo nomeadas (nariz, orellas, xeonllos, pés) no seu propio corpo.',
      accionKinestesicaEs:
          'Localiza las partes del cuerpo nombradas (nariz, orejas, rodillas, pies) en su propio cuerpo.',
      criterioExitoGl:
          'Toca a parte correcta sen espello tras o modelado inicial do adulto.',
      criterioExitoEs:
          'Toca la parte correcta sin espejo tras el modelado inicial del adulto.',
    ),
    XogoFogarItem(
      id: 'xogo_06_masaxe_72bpm',
      tituloGl: 'A Masaxe Suave a 72 bpm',
      tituloEs: 'El Masaje Suave a 72 bpm',
      idade: '0-2 anos',
      duracionMin: 4,
      materiaisGl: 'Crema hidratante ou aceite suave, toalla tépeda',
      materiaisEs: 'Crema hidratante o aceite suave, toalla tibia',
      obxectivoGl: 'Regulación do ton muscular, calma parasimpática e vínculo',
      obxectivoEs:
          'Regulación del tono muscular, calma parasimpática y vínculo',
      fraseEn: 'Soft and warm, gentle little arms!',
      guionAdultoGl:
          'Acaricia as costas ou as pernas ao compás dun pulso de corazón tranquilo (un toque por segundo).',
      guionAdultoEs:
          'Acaricia la espalda o las piernas al compás de un pulso de corazón tranquilo (un toque por segundo).',
      accionKinestesicaGl:
          'O bebé relaxa os puños, estira as pernas e sorrí relaxado.',
      accionKinestesicaEs:
          'El bebé relaja los puños, estira las piernas y sonríe relajado.',
      criterioExitoGl:
          'Desaparece a tensión nos membros e mantén contacto visual pracenteiro.',
      criterioExitoEs:
          'Desaparece la tensión en los miembros y mantiene contacto visual placentero.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;

    final xogosFiltrados = _xogos.where((x) {
      if (_filtroIdade == 'todas') return true;
      return x.idade.contains(_filtroIdade);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        leading: const BotonAtras(),
        title: Text(
          isGl
              ? 'Xogos e Dinámicas no Fogar'
              : 'Juegos y Dinámicas en el Hogar',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner de Garantía Zero-Screen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9EE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF6D4A0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.volunteer_activism_rounded,
                    color: Color(0xFFDD6B20),
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGl
                              ? 'XOGO 100% CORPORAL E FÍSICO'
                              : 'JUEGO 100% CORPORAL Y FÍSICO',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFDD6B20),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isGl
                              ? 'A pantalla é a túa partitura. A crianza xoga con obxectos reais da casa, movemento corporal e a túa voz viva.'
                              : 'La pantalla es tu partitura. La criatura juega con objetos reales de la casa, movimiento corporal y tu voz viva.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filtro por idades
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFiltroChip(
                      'todas', isGl ? 'Todas as idades' : 'Todas las edades'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('0-2', '0 a 2 anos'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('2-4', '2 a 4 anos'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('2-6', '3 a 6 anos'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Lista de Xogos
            ...xogosFiltrados.map((xogo) => _buildCardXogo(xogo, isGl)),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String id, String label) {
    final isSelected = _filtroIdade == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filtroIdade = id),
      selectedColor: AppTheme.primaryVigoBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildCardXogo(XogoFogarItem xogo, bool isGl) {
    final estadoObservacional = _rexistroObservacional[xogo.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            // Cabeceira do xogo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sports_gymnastics_rounded,
                    color: AppTheme.primaryVigoBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGl ? xogo.tituloGl : xogo.tituloEs,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              xogo.idade,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${xogo.duracionMin} min',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Materiais reais da casa
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 16, color: Color(0xFF4A5568)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${isGl ? "Materiais" : "Materiales"}: ${isGl ? xogo.materiaisGl : xogo.materiaisEs}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Orde física en inglés (L3 TPR)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBEE3F8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.record_voice_over_outlined,
                          size: 16, color: Color(0xFF2B6CB0)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Comando Oral (Inglés L3)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B6CB0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '«${xogo.fraseEn}»',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Guión verbal para o adulto (Partitura)
            Text(
              isGl ? 'A túa guía verbal:' : 'Tu guía verbal:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isGl ? xogo.guionAdultoGl : xogo.guionAdultoEs,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF2D3748), height: 1.35),
            ),
            const SizedBox(height: 10),

            // Acción kinestésica
            Text(
              isGl ? 'Movemento da crianza:' : 'Movimiento de la criatura:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isGl ? xogo.accionKinestesicaGl : xogo.accionKinestesicaEs,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF4A5568), height: 1.35),
            ),
            const SizedBox(height: 14),

            // Rexistro Observacional de 1 Toque (Pilar 5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Observación 1-Toque:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (estadoObservacional != null)
                        Text(
                          estadoObservacional == 'L'
                              ? (isGl ? 'Logrado' : 'Logrado')
                              : estadoObservacional == 'A'
                                  ? (isGl ? 'Asistido' : 'Asistido')
                                  : (isGl ? 'Explorando' : 'Explorando'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: estadoObservacional == 'L'
                                ? Colors.green[700]
                                : estadoObservacional == 'A'
                                    ? Colors.blue[700]
                                    : Colors.orange[700],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(
                              () => _rexistroObservacional[xogo.id] = 'L'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: estadoObservacional == 'L'
                                ? const Color(0xFFC6F6D5)
                                : Colors.white,
                            side: BorderSide(
                              color: estadoObservacional == 'L'
                                  ? const Color(0xFF38A169)
                                  : const Color(0xFFCBD5E0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            isGl ? '[L] Logrado' : '[L] Logrado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: estadoObservacional == 'L'
                                  ? const Color(0xFF22543D)
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(
                              () => _rexistroObservacional[xogo.id] = 'A'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: estadoObservacional == 'A'
                                ? const Color(0xFFBEE3F8)
                                : Colors.white,
                            side: BorderSide(
                              color: estadoObservacional == 'A'
                                  ? const Color(0xFF3182CE)
                                  : const Color(0xFFCBD5E0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            isGl ? '[A] Asistido' : '[A] Asistido',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: estadoObservacional == 'A'
                                  ? const Color(0xFF2A4365)
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(
                              () => _rexistroObservacional[xogo.id] = 'E'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: estadoObservacional == 'E'
                                ? const Color(0xFFFEEBC8)
                                : Colors.white,
                            side: BorderSide(
                              color: estadoObservacional == 'E'
                                  ? const Color(0xFFDD6B20)
                                  : const Color(0xFFCBD5E0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            isGl ? '[E] Explorando' : '[E] Explorando',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: estadoObservacional == 'E'
                                  ? const Color(0xFF7B341E)
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
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
