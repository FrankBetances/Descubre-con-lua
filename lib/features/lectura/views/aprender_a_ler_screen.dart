import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/repositories/content_repository.dart';

/// Hub Integral de Aprender a Ler, Fónica e Alfabetización Temperá Manipulativa.
///
/// Deseñado baixo o paradigma de Cero Pantallas para a Crianza (/tangible-l2-parent-orchestrator):
/// 1. Conciencia Fonolóxica e Sons Iniciais (Rimas e sílabas corporais).
/// 2. Mesa Manipulativa Alphabot Expandida (Letras de madeira, imáns e fonemas).
/// 3. Fónica Combinatoria e Cubos CVC (Phonicubes).
/// 4. Pares Mínimos e Discriminación Auditiva (/b/ vs /p/, /m/ vs /n/).
/// 5. Rexistro Observacional 1-Toque para a persoa adulta.
class AprenderALerScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const AprenderALerScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<AprenderALerScreen> createState() => _AprenderALerScreenState();
}

class _AprenderALerScreenState extends State<AprenderALerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AppLanguage _language;

  // Estado da Mesa Alphabot
  int _alphabotCategoryIndex = 0;
  int _alphabotWordIndex = 0;
  final Set<String> _placedLetters = {};

  // Estado dos Cubos CVC
  int _cvcIndex = 0;

  // Estado de Pares Mínimos
  int _paresIndex = 0;

  // Rexistro Observacional 1-Toque
  final Map<String, String> _observacions = {}; // id -> 'L' | 'A' | 'E'

  static const List<Map<String, dynamic>> _categoriasAlphabot = [
    {
      'id': 'animais',
      'gl': 'Animais',
      'es': 'Animales',
      'words': [
        {
          'word': 'LÚA',
          'letters': ['L', 'Ú', 'A'],
          'gl': 'Mascota e compañeira suave',
          'es': 'Mascota y compañera suave',
          'material': 'Letras de madeira ou feltro',
          'phonemes': ['/l/', '/u/', '/a/'],
          'tpr': 'Acaricia suave coma unha gata',
        },
        {
          'word': 'RÁ',
          'letters': ['R', 'Á'],
          'gl': 'Salta na beira do río Lagares',
          'es': 'Salta en la orilla del río Lagares',
          'material': 'Tacos de madeira verdes',
          'phonemes': ['/r/', '/a/'],
          'tpr': 'Salto pequeno dende o chan',
        },
        {
          'word': 'GATO',
          'letters': ['G', 'A', 'T', 'O'],
          'gl': 'Compañeiro curioso e acolledor',
          'es': 'Compañero curioso y acogedor',
          'material': 'Imáns na neveira',
          'phonemes': ['/g/', '/a/', '/t/', '/o/'],
          'tpr': 'Move as patiñas no aire',
        },
        {
          'word': 'OSO',
          'letters': ['O', 'S', 'O'],
          'gl': 'Pisa forte e abriga no inverno',
          'es': 'Pisa fuerte y abriga en invierno',
          'material': 'Cartolinas grosas recortadas',
          'phonemes': ['/o/', '/s/', '/o/'],
          'tpr': 'Pisa pesado: pum, pum!',
        },
        {
          'word': 'PEIXE',
          'letters': ['P', 'E', 'I', 'X', 'E'],
          'gl': 'Baila nas ondas da ría de Vigo',
          'es': 'Baila en las olas de la ría de Vigo',
          'material': 'Conchas pintadas con letras',
          'phonemes': ['/p/', '/e/', '/i/', '/ʃ/', '/e/'],
          'tpr': 'Xunta as mans e nada coma un peixe',
        },
      ],
    },
    {
      'id': 'fogar',
      'gl': 'Fogar e Cotián',
      'es': 'Hogar y Cotidiano',
      'words': [
        {
          'word': 'PAN',
          'letters': ['P', 'A', 'N'],
          'gl': 'Alimento cotián que se parte e comparte',
          'es': 'Alimento cotidiano que se parte y comparte',
          'material': 'Masa real ou letras de cartón',
          'phonemes': ['/p/', '/a/', '/n/'],
          'tpr': 'Amasa coas dúas mans abertas',
        },
        {
          'word': 'CASA',
          'letters': ['C', 'A', 'S', 'A'],
          'gl': 'O refuxio quentiño onde descansamos',
          'es': 'El refugio calentito donde descansamos',
          'material': 'Pezas de construción de madeira',
          'phonemes': ['/k/', '/a/', '/s/', '/a/'],
          'tpr': 'Fai un tellado cos brazos sobre a cabeza',
        },
        {
          'word': 'SOL',
          'letters': ['S', 'O', 'L'],
          'gl': 'Luz cálida que esperta a mañá',
          'es': 'Luz cálida que despierta la mañana',
          'material': 'Imáns amarelos ou pasta de sal',
          'phonemes': ['/s/', '/o/', '/l/'],
          'tpr': 'Abre as mans coma raios que quentan',
        },
        {
          'word': 'LUZ',
          'letters': ['L', 'U', 'Z'],
          'gl': 'Brilla cando abrimos a ventá',
          'es': 'Brilla cuando abrimos la ventana',
          'material': 'Letras translúcidas con lanterna',
          'phonemes': ['/l/', '/u/', '/θ/'],
          'tpr': 'Pinta un círculo de luz co dedo no aire',
        },
      ],
    },
    {
      'id': 'vigo',
      'gl': 'Vigo e Natureza',
      'es': 'Vigo y Naturaleza',
      'words': [
        {
          'word': 'MAR',
          'letters': ['M', 'A', 'R'],
          'gl': 'As ondas azuis de Samil e da ría',
          'es': 'Las olas azules de Samil y de la ría',
          'material': 'Pedras de praia lisas con rotulador',
          'phonemes': ['/m/', '/a/', '/r/'],
          'tpr': 'Onda suave cos brazos de lado a lado',
        },
        {
          'word': 'RÍA',
          'letters': ['R', 'Í', 'A'],
          'gl': 'A auga mansa onde navegan os barcos',
          'es': 'El agua mansa donde navegan los barcos',
          'material': 'Cintas azuis de tea no chan',
          'phonemes': ['/r/', '/i/', '/a/'],
          'tpr': 'Abre os brazos en vaivén de calma',
        },
        {
          'word': 'BARCO',
          'letters': ['B', 'A', 'R', 'C', 'O'],
          'gl': 'Navega cara ás Illas Cíes',
          'es': 'Navega hacia las Islas Cíes',
          'material': 'Barquiño de papel dobrado con letras',
          'phonemes': ['/b/', '/a/', '/r/', '/k/', '/o/'],
          'tpr': 'Xesto de remar co corpo adiante e atrás',
        },
      ],
    },
    {
      'id': 'corpo',
      'gl': 'Corpo e Afecto',
      'es': 'Cuerpo y Afecto',
      'words': [
        {
          'word': 'MAN',
          'letters': ['M', 'A', 'N'],
          'gl': 'Aperta, saúda e constrúe',
          'es': 'Abraza, saluda y construye',
          'material': 'Silueta da propia man debuxada',
          'phonemes': ['/m/', '/a/', '/n/'],
          'tpr': 'Abre a palma e saúda suavemente',
        },
        {
          'word': 'PÉ',
          'letters': ['P', 'É'],
          'gl': 'Sostén o corpo e dá os primeiros pasos',
          'es': 'Sostiene el cuerpo y da los primeros pasos',
          'material': 'Pegadas recortadas en cartolina',
          'phonemes': ['/p/', '/e/'],
          'tpr': 'Toca os pés coas mans sen dobrar xeonllos',
        },
        {
          'word': 'AMOR',
          'letters': ['A', 'M', 'O', 'R'],
          'gl': 'O acollemento de cada día na casa',
          'es': 'La acogida de cada día en casa',
          'material': 'Corazón de feltro suave',
          'phonemes': ['/a/', '/m/', '/o/', '/r/'],
          'tpr': 'Aperta forte o teu propio peito',
        },
      ],
    },
  ];

  static const List<Map<String, dynamic>> _cubosCvc = [
    {
      'id': 'cvc_cat',
      'c1': 'C',
      'v': 'A',
      'c2': 'T',
      'wordEn': 'CAT',
      'ipa': '/kæt/',
      'meaningGl': 'Gato (Inglés L3)',
      'meaningEs': 'Gato (Inglés L3)',
      'material': '3 cubos de madeira: azul (/k/), vermello (/æ/), verde (/t/)',
      'promptGl': 'Xunta os tres bloques: /k/ + /æ/ + /t/ = CAT!',
      'promptEs': 'Junta los tres bloques: /k/ + /æ/ + /t/ = ¡CAT!',
    },
    {
      'id': 'cvc_bed',
      'c1': 'B',
      'v': 'E',
      'c2': 'D',
      'wordEn': 'BED',
      'ipa': '/bɛd/',
      'meaningGl': 'Cama (Inglés L3)',
      'meaningEs': 'Cama (Inglés L3)',
      'material': '3 cubos de madeira: azul (/b/), vermello (/ɛ/), verde (/d/)',
      'promptGl': 'Xunta os tres bloques: /b/ + /ɛ/ + /d/ = BED!',
      'promptEs': 'Junta los tres bloques: /b/ + /ɛ/ + /d/ = ¡BED!',
    },
    {
      'id': 'cvc_pig',
      'c1': 'P',
      'v': 'I',
      'c2': 'G',
      'wordEn': 'PIG',
      'ipa': '/pɪɡ/',
      'meaningGl': 'Porquiño (Inglés L3)',
      'meaningEs': 'Cerdito (Inglés L3)',
      'material': '3 cubos de madeira: azul (/p/), vermello (/ɪ/), verde (/ɡ/)',
      'promptGl': 'Xunta os tres bloques: /p/ + /ɪ/ + /ɡ/ = PIG!',
      'promptEs': 'Junta los tres bloques: /p/ + /ɪ/ + /ɡ/ = ¡PIG!',
    },
    {
      'id': 'cvc_sun',
      'c1': 'S',
      'v': 'U',
      'c2': 'N',
      'wordEn': 'SUN',
      'ipa': '/sʌn/',
      'meaningGl': 'Sol (Inglés L3)',
      'meaningEs': 'Sol (Inglés L3)',
      'material': '3 cubos de madeira: azul (/s/), vermello (/ʌ/), verde (/n/)',
      'promptGl': 'Xunta os tres bloques: /s/ + /ʌ/ + /n/ = SUN!',
      'promptEs': 'Junta los tres bloques: /s/ + /ʌ/ + /n/ = ¡SUN!',
    },
    {
      'id': 'cvc_pan',
      'c1': 'P',
      'v': 'A',
      'c2': 'N',
      'wordEn': 'PAN',
      'ipa': '/pan/',
      'meaningGl': 'Pan (Galego / Castelán)',
      'meaningEs': 'Pan (Gallego / Castellano)',
      'material': '3 cubos: /p/ + /a/ + /n/',
      'promptGl': 'Sílaba transparente: /p/ + /a/ + /n/ = PAN!',
      'promptEs': 'Sílaba transparente: /p/ + /a/ + /n/ = ¡PAN!',
    },
    {
      'id': 'cvc_sol',
      'c1': 'S',
      'v': 'O',
      'c2': 'L',
      'wordEn': 'SOL',
      'ipa': '/sɔl/',
      'meaningGl': 'Sol (Galego / Castelán)',
      'meaningEs': 'Sol (Gallego / Castellano)',
      'material': '3 cubos: /s/ + /o/ + /l/',
      'promptGl': 'Sílaba transparente: /s/ + /o/ + /l/ = SOL!',
      'promptEs': 'Sílaba transparente: /s/ + /o/ + /l/ = ¡SOL!',
    },
  ];

  static const List<Map<String, dynamic>> _paresMinimos = [
    {
      'id': 'par_b_p',
      'par': '/b/ vs /p/',
      'palabra1En': 'Bear',
      'palabra2En': 'Pig',
      'palabra1Gl': 'Oso',
      'palabra2Gl': 'Porquiño',
      'contrasteGl': 'Bilabial sonora (/b/) vs Bilabial xorda (/p/)',
      'contrasteEs': 'Bilabial sonora (/b/) vs Bilabial sorda (/p/)',
      'instruccionGl': 'Tapa a túa boca cunha folla de papel para que a crianza non lea os teus beizos. Di «Bear» ou «Pig». Pídelle que sinale a tarxeta correcta.',
      'instruccionEs': 'Tapa tu boca con una hoja de papel para que la criatura no lea tus labios. Di «Bear» o «Pig». Pídele que señale la tarjeta correcta.',
    },
    {
      'id': 'par_m_n',
      'par': '/m/ vs /n/',
      'palabra1En': 'Man',
      'palabra2En': 'Net',
      'palabra1Gl': 'Home / Man',
      'palabra2Gl': 'Rede',
      'contrasteGl': 'Nasal bilabial (/m/) vs Nasal alveolar (/n/)',
      'contrasteEs': 'Nasal bilabial (/m/) vs Nasal alveolar (/n/)',
      'instruccionGl': 'Sinte a vibración no nariz ao dicir /m/. Anima á crianza a tocar o seu nariz.',
      'instruccionEs': 'Siente la vibración en la nariz al decir /m/. Anima a la criatura a tocar su nariz.',
    },
    {
      'id': 'par_d_t',
      'par': '/d/ vs /t/',
      'palabra1En': 'Dog',
      'palabra2En': 'Top',
      'palabra1Gl': 'Can',
      'palabra2Gl': 'Peón / Buxaina',
      'contrasteGl': 'Oclusiva alveolar sonora (/d/) vs xorda (/t/)',
      'contrasteEs': 'Oclusiva alveolar sonora (/d/) vs sorda (/t/)',
      'instruccionGl': 'Coloca a man diante da boca: con /t/ sinto aire; con /d/ sinto voz.',
      'instruccionEs': 'Coloca la mano delante de la boca: con /t/ siento aire; con /d/ siento voz.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          isGl ? 'Aprender a Ler · Alfabetización' : 'Aprender a Leer · Alfabetización',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryVigoBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryVigoBlue,
          indicatorWeight: 3,
          tabs: [
            Tab(text: isGl ? '1. Conciencia Fonolóxica' : '1. Conciencia Fonológica'),
            Tab(text: isGl ? '2. Mesa Alphabot' : '2. Mesa Alphabot'),
            Tab(text: isGl ? '3. Cubos CVC' : '3. Cubos CVC'),
            Tab(text: isGl ? '4. Pares Mínimos' : '4. Pares Mínimos'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTabConcienciaFonoloxica(isGl),
            _buildTabMesaAlphabot(isGl),
            _buildTabCubosCvc(isGl),
            _buildTabParesMinimos(isGl),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: CONCIENCIA FONOLÓXICA ---
  Widget _buildTabConcienciaFonoloxica(bool isGl) {
    final actividades = [
      {
        'id': 'cf_01',
        'titulo': isGl ? 'Palmas Silábicas co Corpo' : 'Palmas Silábicas con el Cuerpo',
        'subtitulo': isGl ? 'Segmentación silábica con ritmo corporal' : 'Segmentación silábica con ritmo corporal',
        'desc': isGl
            ? 'Di palabras cotiás da casa (PA-TO, GA-TO, CA-SA) e bate palmas ou toca os pés por cada anaco. A crianza imita o teu movemento sen mirar a pantalla.'
            : 'Di palabras cotidianas de la casa (PA-TO, GA-TO, CA-SA) y da palmadas o toca los pies por cada trozo. La criatura imita tu movimiento sin mirar la pantalla.',
        'tpr': isGl ? '1 golpe de palma por cada sílaba clara' : '1 golpe de palma por cada sílaba clara',
      },
      {
        'id': 'cf_02',
        'titulo': isGl ? 'Caza de Rimas de Vigo' : 'Caza de Rimas de Vigo',
        'subtitulo': isGl ? 'Discriminación do son final' : 'Discriminación del sonido final',
        'desc': isGl
            ? '«Lúa quere unha cuncha na rúa». «O peixe salta e non se mexe». Xoga a rimar con obxectos reais. Riman cando soan igual ao final!'
            : '«Lúa quiere una concha en la calle». «El pez salta y no se mueve». Juega a rimar con objetos reales. ¡Riman cuando suenan igual al final!',
        'tpr': isGl ? 'Salto con xiro cando escoita a rima' : 'Salto con giro cuando escucha la rima',
      },
      {
        'id': 'cf_03',
        'titulo': isGl ? 'O Son Inicial Misterioso' : 'El Sonido Inicial Misterioso',
        'subtitulo': isGl ? 'Illa de fonemas iniciais: /m/, /p/, /s/, /l/' : 'Isla de fonemas iniciales: /m/, /p/, /s/, /l/',
        'desc': isGl
            ? 'Pon varios obxectos diante: mazá, pan, sol. «Que empeza por /m/? /m/... mazá!». Toca a gorxa para sentir como vibra o son.'
            : 'Pon varios objetos delante: manzana, pan, sol. «¿Qué empieza por /m/? /m/... ¡manzana!». Toca la garganta para sentir cómo vibra el sonido.',
        'tpr': isGl ? 'Sinalar o obxecto e imitar o son /m/' : 'Señalar el objeto e imitar el sonido /m/',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGarantiaZeroScreen(
          isGl
              ? 'A conciencia fonolóxica é puramente acústica e táctil. O neno non precisa ver letras escritas aínda: o oído e o corpo son os primeiros lectores.'
              : 'La conciencia fonológica es puramente acústica y táctil. La criatura no necesita ver letras escritas todavía: el oído y el cuerpo son los primeros lectores.',
        ),
        const SizedBox(height: 14),
        ...actividades.map((act) => _buildCardActividadeFonoloxica(act, isGl)),
      ],
    );
  }

  Widget _buildCardActividadeFonoloxica(Map<String, String> act, bool isGl) {
    final obs = _observacions[act['id']!];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hearing_rounded,
                    color: AppTheme.primaryVigoBlue, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    act['titulo']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              act['subtitulo']!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              act['desc']!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_outlined,
                      size: 14, color: Color(0xFF4A5568)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${isGl ? "Acción corporal" : "Acción corporal"}: ${act["tpr"]}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSelector1Tap(act['id']!, obs, isGl),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: MESA MANIPULATIVA ALPHABOT ---
  Widget _buildTabMesaAlphabot(bool isGl) {
    final cat = _categoriasAlphabot[_alphabotCategoryIndex];
    final words = cat['words'] as List<Map<String, dynamic>>;
    final item = words[_alphabotWordIndex % words.length];
    final letters = item['letters'] as List<String>;
    final phonemes = item['phonemes'] as List<String>;
    final isComplete = _placedLetters.length >= letters.length;
    final obs = _observacions[item['word'] as String];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGarantiaZeroScreen(
          isGl
              ? 'Mesa física: coloca letras de madeira, imáns na neveira ou cartolinas recortadas diante da crianza. O adulto guia a articulación fonema a fonema.'
              : 'Mesa física: coloca letras de madera, imanes en la nevera o cartulinas recortadas delante de la criatura. El adulto guía la articulación fonema a fonema.',
        ),
        const SizedBox(height: 14),

        // Selector de Categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_categoriasAlphabot.length, (idx) {
              final c = _categoriasAlphabot[idx];
              final isSel = _alphabotCategoryIndex == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(isGl ? c['gl'] as String : c['es'] as String),
                  selected: isSel,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _alphabotCategoryIndex = idx;
                        _alphabotWordIndex = 0;
                        _placedLetters.clear();
                      });
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
            }),
          ),
        ),
        const SizedBox(height: 14),

        // Tarxeta da Palabra Manipulativa Actual
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${isGl ? "Palabra" : "Palabra"} ${_alphabotWordIndex + 1} / ${words.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () {
                        setState(() {
                          _alphabotWordIndex = (_alphabotWordIndex + 1) % words.length;
                          _placedLetters.clear();
                        });
                      },
                      tooltip: isGl ? 'Seguinte palabra' : 'Siguiente palabra',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Palabra en letras grandes manipulativas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['word'] as String,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryInk,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BotonEscuchar(
                      audioService: widget.audioService,
                      texto: item['word'] as String,
                      language: _language,
                      compacto: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isGl ? item['gl'] as String : item['es'] as String,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),

                // Reixa de Letras Táctiles (Espello do que o neno monta na mesa)
                Wrap(
                  spacing: 10,
                  children: letters.map((l) {
                    final isPlaced = _placedLetters.contains(l);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isPlaced) {
                            _placedLetters.remove(l);
                          } else {
                            _placedLetters.add(l);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 52,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isPlaced
                              ? const Color(0xFFC6F6D5)
                              : const Color(0xFFFFF9EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPlaced
                                ? const Color(0xFF38A169)
                                : const Color(0xFFF6D4A0),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            l,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isPlaced
                                  ? const Color(0xFF22543D)
                                  : const Color(0xFFB7791F),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  isComplete
                      ? (isGl ? 'Palabra montada na mesa!' : '¡Palabra montada en la mesa!')
                      : (isGl ? 'Toca as letras que a crianza coloque na mesa' : 'Toca las letras que la criatura coloque en la mesa'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.green[700] : AppTheme.textSecondary,
                  ),
                ),
                const Divider(height: 28),

                // Fonemas articulados
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.record_voice_over_rounded,
                        size: 16, color: AppTheme.primaryVigoBlue),
                    const SizedBox(width: 6),
                    Text(
                      '${isGl ? "Fonemas" : "Fonemas"}: ${phonemes.join("  +  ")}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryVigoBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Materiais recomendados e reto TPR
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.extension_outlined,
                              size: 14, color: Color(0xFF4A5568)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${isGl ? "Material físico" : "Material físico"}: ${item["material"]}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_run_rounded,
                              size: 14, color: Color(0xFF4A5568)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${isGl ? "Acción corporal" : "Acción corporal"}: ${item["tpr"]}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildSelector1Tap(item['word'] as String, obs, isGl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 3: CUBOS CVC (PHONICUBES) ---
  Widget _buildTabCubosCvc(bool isGl) {
    final item = _cubosCvc[_cvcIndex % _cubosCvc.length];
    final obs = _observacions[item['id'] as String];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGarantiaZeroScreen(
          isGl
              ? 'Phonicubes: bloques físicos de Consonante-Vocal-Consonante. A crianza xunta fisicamente tres tacos de madeira e o adulto pronuncia a síntese acústica inmediata.'
              : 'Phonicubes: bloques físicos de Consonante-Vocal-Consonante. La criatura junta físicamente tres tacos de madera y el adulto pronuncia la síntesis acústica inmediata.',
        ),
        const SizedBox(height: 14),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${isGl ? "Cubo CVC" : "Cubo CVC"} ${_cvcIndex + 1} / ${_cubosCvc.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () {
                        setState(() => _cvcIndex = (_cvcIndex + 1) % _cubosCvc.length);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tres Cubos CVC Visuais
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCvcCube(item['c1'] as String, 'C', const Color(0xFF2B6CB0)),
                    const SizedBox(width: 8),
                    _buildCvcCube(item['v'] as String, 'V', const Color(0xFFC53030)),
                    const SizedBox(width: 8),
                    _buildCvcCube(item['c2'] as String, 'C', const Color(0xFF276749)),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${item["wordEn"]} · ${item["ipa"]}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BotonEscuchar(
                      audioService: widget.audioService,
                      texto: item['wordEn'] as String,
                      language: ((item['id'] as String).contains('pan') ||
                              (item['id'] as String).contains('sol'))
                          ? _language
                          : AppLanguage.en,
                      compacto: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isGl ? item['meaningGl'] as String : item['meaningEs'] as String,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const Divider(height: 24),

                Text(
                  isGl ? item['promptGl'] as String : item['promptEs'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isGl ? "Materiais suxeridos" : "Materiales sugeridos"}: ${item["material"]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                ),
                const SizedBox(height: 16),
                _buildSelector1Tap(item['id'] as String, obs, isGl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCvcCube(String letter, String role, Color color) {
    return Container(
      width: 64,
      height: 70,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            role,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            letter,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: PARES MÍNIMOS ---
  Widget _buildTabParesMinimos(bool isGl) {
    final item = _paresMinimos[_paresIndex % _paresMinimos.length];
    final obs = _observacions[item['id'] as String];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGarantiaZeroScreen(
          isGl
              ? 'Pares Mínimos: adestramento de discriminación auditiva fina. O adulto oculta a boca cunha folla para que a crianza distinga o son exclusivamente polo oído.'
              : 'Pares Mínimos: entrenamiento de discriminación auditiva fina. El adulto oculta la boca con una hoja para que la criatura distinga el sonido exclusivamente por el oído.',
        ),
        const SizedBox(height: 14),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['par'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryVigoBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () {
                        setState(() => _paresIndex = (_paresIndex + 1) % _paresMinimos.length);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isGl ? item['contrasteGl'] as String : item['contrasteEs'] as String,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const Divider(height: 24),

                // Dúas tarxetas físicas de contraste
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF90CDF4)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['palabra1En'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2B6CB0),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                BotonEscuchar(
                                  audioService: widget.audioService,
                                  texto: item['palabra1En'] as String,
                                  language: AppLanguage.en,
                                  compacto: true,
                                ),
                              ],
                            ),
                            Text(
                              item['palabra1Gl'] as String,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('vs', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFEB2B2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['palabra2En'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC53030),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                BotonEscuchar(
                                  audioService: widget.audioService,
                                  texto: item['palabra2En'] as String,
                                  language: AppLanguage.en,
                                  compacto: true,
                                ),
                              ],
                            ),
                            Text(
                              item['palabra2Gl'] as String,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Instrución de facilitación
                Text(
                  isGl ? item['instruccionGl'] as String : item['instruccionEs'] as String,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF2D3748), height: 1.4),
                ),
                const SizedBox(height: 16),
                _buildSelector1Tap(item['id'] as String, obs, isGl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGarantiaZeroScreen(String texto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF6D4A0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFDD6B20), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7B341E), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector1Tap(String id, String? estadoActual, bool isGl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(
            isGl ? 'Rexistro:' : 'Registro:',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
          ),
          const Spacer(),
          _buildTapButton(id, 'L', '[L] Logrado', estadoActual == 'L', Colors.green, isGl),
          const SizedBox(width: 6),
          _buildTapButton(id, 'A', '[A] Asistido', estadoActual == 'A', Colors.blue, isGl),
          const SizedBox(width: 6),
          _buildTapButton(id, 'E', '[E] Explorando', estadoActual == 'E', Colors.orange, isGl),
        ],
      ),
    );
  }

  Widget _buildTapButton(String id, String val, String label, bool isSel, MaterialColor color, bool isGl) {
    return InkWell(
      onTap: () => setState(() => _observacions[id] = val),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? color.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSel ? color.shade700 : const Color(0xFFCBD5E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSel ? color.shade900 : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
