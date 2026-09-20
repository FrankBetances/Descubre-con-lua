import 'dart:math' as math;
import '../data/models/fsrs_card_model.dart';
import 'fsrs_service.dart';
import 'storage/local_store.dart';

/// Service managing user progress, gamification XP, daily streaks, completed
/// pedagogical assemblies (docentes), Academy capsules (familias), dual-track
/// activity logs (aula vs fogar), and FSRS spaced repetition card states.
///
/// Fully offline: persisted atomically into application private files via [LocalStore].
/// Strictly zero network, zero analytics, zero external dependencies.
class ProgressService {
  static const String defaultStoreFileName = 'user_progress.json';

  final LocalStore _store;
  final FsrsService _fsrsService;

  int _xp = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  String? _lastActiveDate; // Format: YYYY-MM-DD
  final Set<String> _asambleasCompletadas = {};
  final Set<String> _capsulasCompletadas = {};
  final Map<String, bool> _registrosAula = {};
  final Map<String, bool> _registrosFogar = {};
  final Map<int, FSRSCard> _fsrsCards = {};
  bool _soundEnabled = true;
  bool _isInitialized = false;

  ProgressService({
    LocalStore? store,
    FsrsService? fsrsService,
    String? overrideDirectory,
  })  : _store = store ??
            LocalStore(
              fileName: defaultStoreFileName,
              overrideDirectory: overrideDirectory,
            ),
        _fsrsService = fsrsService ?? const FsrsService();

  bool get isInitialized => _isInitialized;
  int get xp => _xp;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  String? get lastActiveDate => _lastActiveDate;
  List<String> get asambleasCompletadas =>
      List.unmodifiable(_asambleasCompletadas);
  List<String> get capsulasCompletadas =>
      List.unmodifiable(_capsulasCompletadas);
  Map<String, bool> get registrosAula => Map.unmodifiable(_registrosAula);
  Map<String, bool> get registrosFogar => Map.unmodifiable(_registrosFogar);
  Map<int, FSRSCard> get fsrsCards => Map.unmodifiable(_fsrsCards);
  bool get soundEnabled => _soundEnabled;

  /// Loads saved progress state from [LocalStore].
  Future<void> initialize() async {
    final data = await _store.read();
    if (data != null) {
      _xp = (data['xp'] as num?)?.toInt() ?? 0;
      _currentStreak = (data['currentStreak'] as num?)?.toInt() ??
          (data['current_streak'] as num?)?.toInt() ??
          0;
      _bestStreak = (data['bestStreak'] as num?)?.toInt() ??
          (data['best_streak'] as num?)?.toInt() ??
          0;
      _lastActiveDate = data['lastActiveDate']?.toString() ??
          data['last_active_date']?.toString();

      _asambleasCompletadas.clear();
      final rawAsambleas = data['asambleasCompletadas'] ??
          data['asambleas_completadas'] ??
          data['asambleas'];
      if (rawAsambleas is List) {
        _asambleasCompletadas.addAll(rawAsambleas.map((e) => e.toString()));
      }

      _capsulasCompletadas.clear();
      final rawCapsulas = data['capsulasCompletadas'] ??
          data['capsulas_completadas'] ??
          data['capsulas'];
      if (rawCapsulas is List) {
        _capsulasCompletadas.addAll(rawCapsulas.map((e) => e.toString()));
      }

      _registrosAula.clear();
      final rawAula = data['registrosAula'] ?? data['registros_aula'];
      if (rawAula is Map) {
        rawAula.forEach((k, v) {
          _registrosAula[k.toString()] = v == true;
        });
      }

      _registrosFogar.clear();
      final rawFogar = data['registrosFogar'] ?? data['registros_fogar'];
      if (rawFogar is Map) {
        rawFogar.forEach((k, v) {
          _registrosFogar[k.toString()] = v == true;
        });
      }

      _fsrsCards.clear();
      final rawCards = data['fsrsCards'] ?? data['fsrs_cards'];
      if (rawCards is List) {
        for (final item in rawCards) {
          if (item is Map<String, dynamic>) {
            final card = FSRSCard.fromJson(item);
            _fsrsCards[card.id] = card;
          } else if (item is Map) {
            final card = FSRSCard.fromJson(Map<String, dynamic>.from(item));
            _fsrsCards[card.id] = card;
          }
        }
      }

      _soundEnabled = data['soundEnabled'] as bool? ??
          data['sound_enabled'] as bool? ??
          true;
    }
    _isInitialized = true;
  }

  /// Serializes and writes state to disk atomically.
  Future<bool> save() async {
    final cardsList = _fsrsCards.values.map((c) => c.toJson()).toList();
    final data = <String, dynamic>{
      'xp': _xp,
      'currentStreak': _currentStreak,
      'bestStreak': _bestStreak,
      'lastActiveDate': _lastActiveDate,
      'asambleasCompletadas': _asambleasCompletadas.toList(),
      'capsulasCompletadas': _capsulasCompletadas.toList(),
      'registrosAula': _registrosAula,
      'registrosFogar': _registrosFogar,
      'fsrsCards': cardsList,
      'soundEnabled': _soundEnabled,
    };
    return _store.write(data);
  }

  /// Adds experience points (XP).
  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    _xp += amount;
    await save();
  }

  /// Records that a classroom assembly was completed by a teacher.
  Future<void> recordAssemblyCompleted(
    String assemblyId, {
    DateTime? date,
    int xpReward = 50,
  }) async {
    final cleanId = assemblyId.trim();
    if (cleanId.isEmpty) return;

    _asambleasCompletadas.add(cleanId);
    _xp += xpReward;

    final targetDate = date ?? DateTime.now();
    final dateKey = _formatDateKey(targetDate);
    _registrosAula[dateKey] = true;
    _updateStreak(targetDate);

    await save();
  }

  /// Records that an Academy capsule was read/completed by a family.
  Future<void> recordCapsulaCompleted(
    String capsulaId, {
    DateTime? date,
    int xpReward = 30,
  }) async {
    final cleanId = capsulaId.trim();
    if (cleanId.isEmpty) return;

    _capsulasCompletadas.add(cleanId);
    _xp += xpReward;

    final targetDate = date ?? DateTime.now();
    final dateKey = _formatDateKey(targetDate);
    _registrosFogar[dateKey] = true;
    _updateStreak(targetDate);

    await save();
  }

  /// Logs a daily classroom activity marker.
  Future<void> recordRegistroAula(String dateIso) async {
    final key = dateIso.trim();
    if (key.isEmpty) return;
    _registrosAula[key] = true;
    final parsed = DateTime.tryParse(key) ?? DateTime.now();
    _updateStreak(parsed);
    await save();
  }

  /// Logs a daily home activity marker.
  Future<void> recordRegistroFogar(String dateIso) async {
    final key = dateIso.trim();
    if (key.isEmpty) return;
    _registrosFogar[key] = true;
    final parsed = DateTime.tryParse(key) ?? DateTime.now();
    _updateStreak(parsed);
    await save();
  }

  /// Reviews an FSRS card and stores the updated state.
  Future<FSRSCard> recordFsrsReview(
    FSRSCard card,
    int rating, {
    DateTime? now,
    int xpReward = 10,
  }) async {
    final current = now ?? DateTime.now();
    final updated =
        _fsrsService.repeat(card: card, rating: rating, now: current);
    _fsrsCards[updated.id] = updated;
    _xp += xpReward;
    _updateStreak(current);
    await save();
    return updated;
  }

  /// Retrieves an FSRS card by its ID.
  FSRSCard? getCard(int id) => _fsrsCards[id];

  /// Retrieves all known FSRS cards.
  List<FSRSCard> getAllCards() => List.unmodifiable(_fsrsCards.values);

  /// Retrieves all FSRS cards that are due for review.
  List<FSRSCard> getDueCards({DateTime? now}) {
    final current = now ?? DateTime.now();
    final due = _fsrsCards.values.where((c) {
      return c.state == FSRSCardState.newCard ||
          !c.nextDueDate.isAfter(current);
    }).toList();
    due.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return List.unmodifiable(due);
  }

  /// Saves or updates a card directly.
  Future<void> saveCard(FSRSCard card) async {
    _fsrsCards[card.id] = card;
    await save();
  }

  /// Toggles sound effects.
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await save();
  }

  /// Resets all stored user progress to clean initial defaults.
  Future<void> resetProgress() async {
    _xp = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _lastActiveDate = null;
    _asambleasCompletadas.clear();
    _capsulasCompletadas.clear();
    _registrosAula.clear();
    _registrosFogar.clear();
    _fsrsCards.clear();
    _soundEnabled = true;
    await _store.clear();
  }

  // --- PRIVATE HELPERS ---

  String _formatDateKey(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _updateStreak(DateTime current) {
    final todayKey = _formatDateKey(current);
    if (_lastActiveDate == todayKey) {
      // Activity already counted today; maintain current streak
      return;
    }

    if (_lastActiveDate != null) {
      final lastDate = DateTime.tryParse(_lastActiveDate!);
      if (lastDate != null) {
        final diffDays = current
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        if (diffDays == 1) {
          _currentStreak += 1;
        } else if (diffDays > 1) {
          _currentStreak = 1;
        }
      } else {
        _currentStreak = 1;
      }
    } else {
      _currentStreak = 1;
    }

    _bestStreak = math.max(_bestStreak, _currentStreak);
    _lastActiveDate = todayKey;
  }
}
