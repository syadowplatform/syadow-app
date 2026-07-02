import 'golf_constants.dart';

/// 단일 샷 (웹 shots[] 원소와 동일).
///
/// Firestore 필드: index, distance(yd), wind, club, position, direction.
class Shot {
  const Shot({
    required this.index,
    this.distance,
    this.wind,
    this.club = '',
    this.position,
    this.direction,
  });

  final int index;
  final double? distance; // yd (웹은 항상 yd로 저장)
  final String? wind; // '1'~'12' or 'X'
  final String club; // 정규화된 클럽 코드 (예: '7I', 'DR')
  final ShotPosition? position;
  final String? direction; // '⇑' 등 방향 or 'B1' 등 그리드

  Shot copyWith({
    int? index,
    double? distance,
    String? wind,
    String? club,
    ShotPosition? position,
    String? direction,
    bool clearDistance = false,
    bool clearWind = false,
    bool clearPosition = false,
    bool clearDirection = false,
  }) => Shot(
    index: index ?? this.index,
    distance: clearDistance ? null : (distance ?? this.distance),
    wind: clearWind ? null : (wind ?? this.wind),
    club: club ?? this.club,
    position: clearPosition ? null : (position ?? this.position),
    direction: clearDirection ? null : (direction ?? this.direction),
  );

  Map<String, dynamic> toFirestore() => {
    'index': index,
    'distance': distance ?? 0,
    'wind': wind ?? '',
    'club': club,
    'position': position?.code ?? '',
    'direction': direction ?? '',
  };

  factory Shot.fromFirestore(Map<String, dynamic> m) => Shot(
    index: (m['index'] as num?)?.toInt() ?? 0,
    distance: (m['distance'] as num?)?.toDouble(),
    wind: (m['wind'] as String?)?.isEmpty == true ? null : m['wind'] as String?,
    club: (m['club'] as String?) ?? '',
    position: ShotPosition.fromCode(m['position'] as String?),
    direction: (m['direction'] as String?)?.isEmpty == true
        ? null
        : m['direction'] as String?,
  );
}

/// 단일 퍼트 (웹 putts[] 원소와 동일).
class Putt {
  const Putt({required this.index, this.step});

  final int index;
  final double? step; // 퍼트 거리(=발수 or ft) — 웹은 자유 숫자

  Putt copyWith({int? index, double? step, bool clearStep = false}) => Putt(
    index: index ?? this.index,
    step: clearStep ? null : (step ?? this.step),
  );

  Map<String, dynamic> toFirestore() => {'index': index, 'step': step ?? 0};

  factory Putt.fromFirestore(Map<String, dynamic> m) => Putt(
    index: (m['index'] as num?)?.toInt() ?? 0,
    step: (m['step'] as num?)?.toDouble(),
  );
}

/// 홀 하나의 전체 데이터 (웹 holes[F1] 등과 동일 구조).
class HoleEntry {
  const HoleEntry({
    required this.holeId,
    this.par = 4,
    this.pin,
    this.tapIn = false,
    this.penalty = 0,
    this.shots = const [],
    this.putts = const [],
  });

  final String holeId; // 'F1' .. 'B9'
  final int par; // 3 | 4 | 5
  final String? pin; // 9-grid 코드 (예: 'B2')
  final bool tapIn;
  final int penalty;
  final List<Shot> shots;
  final List<Putt> putts;

  /// 홀 자동 스코어 (샷 수 + 퍼트 수 + 페널티 + tap-in). 웹과 동일.
  int get autoScore {
    final s = shots.length + putts.length + penalty + (tapIn ? 1 : 0);
    return s;
  }

  /// GIR 계산: par 3=1, par 4=2, par 5=3 이내에 OG/HO 있으면 true.
  bool? get gir {
    final girStroke = switch (par) {
      3 => 1,
      4 => 2,
      5 => 3,
      _ => 0,
    };
    if (girStroke == 0) return null;
    final idx = shots.indexWhere(
      (s) => s.position == ShotPosition.og || s.position == ShotPosition.ho,
    );
    if (idx == -1) return false;
    return (idx + 1) <= girStroke;
  }

  /// 홀 데이터 유효성. null = 미기입(플레이 안 함), true/false = 검증 결과.
  ///
  /// - 완전 빈 홀 → null
  /// - HO 있음 → true (샷이 홀에 들어감)
  /// - OG 있음 + (퍼트 or tapIn) → true
  /// - 샷은 있으나 OG/HO 없음 → false
  bool? get valid {
    if (shots.isEmpty && putts.isEmpty && !tapIn) return null;
    final positions = shots.map((s) => s.position?.code).toSet();
    if (positions.contains('HO')) return true;
    if (positions.contains('OG')) return putts.isNotEmpty || tapIn;
    return false;
  }

  HoleEntry copyWith({
    int? par,
    String? pin,
    bool? tapIn,
    int? penalty,
    List<Shot>? shots,
    List<Putt>? putts,
    bool clearPin = false,
  }) => HoleEntry(
    holeId: holeId,
    par: par ?? this.par,
    pin: clearPin ? null : (pin ?? this.pin),
    tapIn: tapIn ?? this.tapIn,
    penalty: penalty ?? this.penalty,
    shots: shots ?? this.shots,
    putts: putts ?? this.putts,
  );

  Map<String, dynamic> toFirestore() => {
    'par': par,
    'pin': pin ?? '',
    'tapIn': tapIn,
    'penalty': penalty,
    'autoScore': autoScore,
    'gir': gir,
    'valid': valid,
    'shots': shots.map((s) => s.toFirestore()).toList(),
    'putts': putts.map((p) => p.toFirestore()).toList(),
  };

  factory HoleEntry.fromFirestore(String holeId, Map<String, dynamic> m) =>
      HoleEntry(
        holeId: holeId,
        par: (m['par'] as num?)?.toInt() ?? 4,
        pin: (m['pin'] as String?)?.isEmpty == true
            ? null
            : m['pin'] as String?,
        tapIn: m['tapIn'] as bool? ?? false,
        penalty: (m['penalty'] as num?)?.toInt() ?? 0,
        shots: ((m['shots'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(Shot.fromFirestore)
            .toList(),
        putts: ((m['putts'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(Putt.fromFirestore)
            .toList(),
      );

  factory HoleEntry.empty(String holeId, {int par = 4}) =>
      HoleEntry(holeId: holeId, par: par);
}
