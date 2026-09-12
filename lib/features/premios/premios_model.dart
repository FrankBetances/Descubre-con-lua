import '../../core/localization/localized_string.dart';

/// Quién gana los premios.
///
/// El adulto, siempre. En Valeria+ los gana quien juega, que es la criatura;
/// aquí la criatura no toca la pantalla, así que premiar su «progreso» sería
/// inventarse un dato que nadie ha medido. Lo que sí se mide es lo que hace el
/// adulto con la app: dirigir asambleas y leer cápsulas.
enum Perfil {
  /// La maestra, en la asamblea.
  docente,

  /// La familia, en casa.
  familia;

  String get clave => name;

  static Perfil desdeClave(String valor) => Perfil.values.firstWhere(
        (p) => p.clave == valor,
        orElse: () => Perfil.docente,
      );
}

/// Un nivel de la escalera: a partir de cuánto XP, y cómo se llama.
class Nivel {
  final int nivel;
  final int xpMinimo;
  final LocalizedString titulo;

  const Nivel({
    required this.nivel,
    required this.xpMinimo,
    required this.titulo,
  });

  factory Nivel.fromJson(Map<String, dynamic> json) => Nivel(
        nivel: (json['nivel'] as num).toInt(),
        xpMinimo: (json['xpMinimo'] as num).toInt(),
        titulo: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['titulo'] as Map),
        ),
      );
}

/// Qué hay que hacer para ganar una insignia.
enum TipoCriterio { asambleas, capsulas, racha }

class Insignia {
  final String id;

  /// `docente`, `familia`, o `null` si la puede ganar cualquiera de los dos.
  final Perfil? perfil;
  final TipoCriterio tipo;
  final int valor;
  final LocalizedString titulo;
  final LocalizedString descripcion;

  const Insignia({
    required this.id,
    required this.perfil,
    required this.tipo,
    required this.valor,
    required this.titulo,
    required this.descripcion,
  });

  factory Insignia.fromJson(Map<String, dynamic> json) {
    final criterio = Map<String, dynamic>.from(json['criterio'] as Map);
    final perfilTexto = json['perfil']?.toString() ?? 'ambos';
    return Insignia(
      id: json['id'].toString(),
      perfil: perfilTexto == 'ambos' ? null : Perfil.desdeClave(perfilTexto),
      tipo: TipoCriterio.values.firstWhere(
        (t) => t.name == criterio['tipo'].toString(),
        orElse: () => TipoCriterio.asambleas,
      ),
      valor: (criterio['valor'] as num).toInt(),
      titulo: LocalizedString.fromJson(
        Map<String, dynamic>.from(json['titulo'] as Map),
      ),
      descripcion: LocalizedString.fromJson(
        Map<String, dynamic>.from(json['descripcion'] as Map),
      ),
    );
  }

  /// Si este perfil puede aspirar a ella.
  bool aplicaA(Perfil p) => perfil == null || perfil == p;
}

/// El catálogo entero, leído de `assets/content/premios/premios.json`.
class CatalogoPremios {
  final int xpPorAsamblea;
  final int xpPorCapsula;
  final List<Nivel> niveles;
  final List<Insignia> insignias;

  const CatalogoPremios({
    required this.xpPorAsamblea,
    required this.xpPorCapsula,
    required this.niveles,
    required this.insignias,
  });

  factory CatalogoPremios.fromJson(Map<String, dynamic> json) {
    final xp = Map<String, dynamic>.from(json['xp'] as Map);
    return CatalogoPremios(
      xpPorAsamblea: (xp['porAsamblea'] as num).toInt(),
      xpPorCapsula: (xp['porCapsula'] as num).toInt(),
      niveles: (json['niveles'] as List)
          .map((e) => Nivel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => a.xpMinimo.compareTo(b.xpMinimo)),
      insignias: (json['insignias'] as List)
          .map((e) => Insignia.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  /// Las insignias que este perfil puede ganar, en el orden del catálogo.
  List<Insignia> insigniasDe(Perfil perfil) =>
      insignias.where((i) => i.aplicaA(perfil)).toList();
}

/// Lo que se guarda de un perfil. Números y fechas, nada más.
///
/// No hay nombre, ni edad, ni identificador de aparato, ni nada de ninguna
/// criatura. Con esto se sabe cuánto se usó la app, nunca quién la usó.
class Progreso {
  final int asambleas;
  final int capsulas;
  final int rachaActual;
  final int mejorRacha;

  /// Último día con actividad, en `aaaa-mm-dd`. Solo la fecha: la hora diría
  /// a qué hora trabaja una persona concreta, y eso no hace falta para nada.
  final String? ultimoDia;

  final Set<String> insignias;

  const Progreso({
    this.asambleas = 0,
    this.capsulas = 0,
    this.rachaActual = 0,
    this.mejorRacha = 0,
    this.ultimoDia,
    this.insignias = const {},
  });

  int get eventos => asambleas + capsulas;

  factory Progreso.fromJson(Map<String, dynamic> json) => Progreso(
        asambleas: (json['asambleas'] as num?)?.toInt() ?? 0,
        capsulas: (json['capsulas'] as num?)?.toInt() ?? 0,
        rachaActual: (json['rachaActual'] as num?)?.toInt() ?? 0,
        mejorRacha: (json['mejorRacha'] as num?)?.toInt() ?? 0,
        ultimoDia: json['ultimoDia'] as String?,
        insignias: ((json['insignias'] as List?) ?? const [])
            .map((e) => e.toString())
            .toSet(),
      );

  Map<String, dynamic> toJson() => {
        'asambleas': asambleas,
        'capsulas': capsulas,
        'rachaActual': rachaActual,
        'mejorRacha': mejorRacha,
        if (ultimoDia != null) 'ultimoDia': ultimoDia,
        'insignias': insignias.toList()..sort(),
      };

  Progreso copyWith({
    int? asambleas,
    int? capsulas,
    int? rachaActual,
    int? mejorRacha,
    String? ultimoDia,
    Set<String>? insignias,
  }) =>
      Progreso(
        asambleas: asambleas ?? this.asambleas,
        capsulas: capsulas ?? this.capsulas,
        rachaActual: rachaActual ?? this.rachaActual,
        mejorRacha: mejorRacha ?? this.mejorRacha,
        ultimoDia: ultimoDia ?? this.ultimoDia,
        insignias: insignias ?? this.insignias,
      );

  /// XP total, derivado de los contadores y no guardado aparte.
  ///
  /// Guardarlo por separado permitiría que el XP y los contadores dijeran cosas
  /// distintas, que es exactamente el defecto que este proyecto ya tuvo con el
  /// tempo: el JSON decía 80 BPM y el audio sonaba a 72.
  int xp(CatalogoPremios catalogo) =>
      asambleas * catalogo.xpPorAsamblea + capsulas * catalogo.xpPorCapsula;

  /// El nivel que corresponde a ese XP.
  Nivel nivelActual(CatalogoPremios catalogo) {
    final puntos = xp(catalogo);
    var actual = catalogo.niveles.first;
    for (final n in catalogo.niveles) {
      if (puntos >= n.xpMinimo) actual = n;
    }
    return actual;
  }

  /// El siguiente nivel, o `null` si ya está en el último.
  Nivel? siguienteNivel(CatalogoPremios catalogo) {
    final puntos = xp(catalogo);
    for (final n in catalogo.niveles) {
      if (n.xpMinimo > puntos) return n;
    }
    return null;
  }

  /// Cuánto falta para el siguiente nivel. Cero si ya está en el último.
  int xpParaSiguiente(CatalogoPremios catalogo) {
    final siguiente = siguienteNivel(catalogo);
    return siguiente == null ? 0 : siguiente.xpMinimo - xp(catalogo);
  }

  /// Avance dentro del nivel actual, de 0 a 1. En el último nivel, 1.
  double avanceDeNivel(CatalogoPremios catalogo) {
    final siguiente = siguienteNivel(catalogo);
    if (siguiente == null) return 1.0;
    final base = nivelActual(catalogo).xpMinimo;
    final tramo = siguiente.xpMinimo - base;
    if (tramo <= 0) return 1.0;
    return ((xp(catalogo) - base) / tramo).clamp(0.0, 1.0);
  }
}
