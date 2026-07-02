/// 골프 라운드 입력 관련 상수/enum.
/// 웹(`~/haru-syadow-platform/pages/player-input.*`)과 스키마 100% 호환.
///
/// **주의**: Firestore에 저장되는 값(코드)은 웹과 반드시 동일해야 함.
/// UI 표시용 라벨만 앱에서 자유롭게 바꿔도 됨.
library;

/// 라운드 모드.
enum RoundMode {
  tournament,
  practice;

  String get code => name; // Firestore 저장값 = enum.name
  static RoundMode fromCode(String? c) =>
      values.firstWhere((e) => e.code == c, orElse: () => practice);

  String get label => switch (this) {
    RoundMode.tournament => '대회',
    RoundMode.practice => '연습 라운드',
  };
}

/// 티오프 시간대.
enum TeeTime {
  morning,
  afternoon;

  String get code => name;
  static TeeTime fromCode(String? c) =>
      values.firstWhere((e) => e.code == c, orElse: () => morning);

  String get label => switch (this) {
    TeeTime.morning => '오전',
    TeeTime.afternoon => '오후',
  };
}

/// 플레이 순서 (18홀 시 전9/후9 순서). 9홀 시에도 어느 9홀인지 결정.
enum PlayOrder {
  frontFirst('front-first'),
  backFirst('back-first');

  const PlayOrder(this.code);
  final String code; // Firestore 저장값 (하이픈 유지)

  static PlayOrder? fromCode(String? c) {
    if (c == null || c.isEmpty) return null;
    return values.cast<PlayOrder?>().firstWhere(
      (e) => e!.code == c,
      orElse: () => null,
    );
  }

  String get label => switch (this) {
    PlayOrder.frontFirst => 'Front 9 먼저',
    PlayOrder.backFirst => 'Back 9 먼저',
  };
}

/// 홀 수.
enum HoleCount {
  eighteen('18', 18),
  nine('9', 9);

  const HoleCount(this.code, this.count);
  final String code;
  final int count;

  static HoleCount fromCode(String? c) =>
      values.firstWhere((e) => e.code == c, orElse: () => eighteen);

  String get label => '$count 홀';
}

/// 날씨.
enum Weather {
  sunny,
  cloudy,
  rain,
  wind;

  String get code => name;
  static Weather fromCode(String? c) =>
      values.firstWhere((e) => e.code == c, orElse: () => sunny);

  String get label => switch (this) {
    Weather.sunny => '맑음',
    Weather.cloudy => '흐림',
    Weather.rain => '비',
    Weather.wind => '바람',
  };

  String get emoji => switch (this) {
    Weather.sunny => '☀️',
    Weather.cloudy => '☁️',
    Weather.rain => '🌧',
    Weather.wind => '💨',
  };
}

/// 온도 단위.
enum TempUnit {
  c,
  f;

  String get code => name;
  static TempUnit fromCode(String? s) =>
      values.firstWhere((e) => e.code == s, orElse: () => TempUnit.c);

  String get label => switch (this) {
    TempUnit.c => '°C',
    TempUnit.f => '°F',
  };
}

/// 온도 범위 옵션 (단위별로 다름). Firestore 값은 웹과 동일한 문자열.
class TempRangeOptions {
  const TempRangeOptions._();

  static List<({String code, String label})> forUnit(TempUnit unit) {
    if (unit == TempUnit.f) {
      return const [
        (code: '32-59F', label: '32~59 °F (≈ 0~15 °C)'),
        (code: '59-86F', label: '59~86 °F (≈ 15~30 °C)'),
        (code: '77-95F', label: '77~95 °F (≈ 25~35 °C)'),
        (code: 'more', label: 'More High'),
      ];
    }
    return const [
      (code: '0-15C', label: '0~15 °C'),
      (code: '15-30C', label: '15~30 °C'),
      (code: '25-35C', label: '25~35 °C'),
      (code: 'more', label: 'More High'),
    ];
  }
}

/// 잔디 종류. `mix`는 두 개 조합.
enum Grass {
  bent,
  poa,
  bermuda,
  rye,
  zoysia,
  kikuyu,
  kentucky,
  mix;

  String get code => name;
  static Grass? fromCode(String? c) {
    if (c == null || c.isEmpty) return null;
    return values.cast<Grass?>().firstWhere(
      (e) => e!.code == c,
      orElse: () => null,
    );
  }

  String get label => switch (this) {
    Grass.bent => 'Bentgrass',
    Grass.poa => 'Poa annua',
    Grass.bermuda => 'Bermuda',
    Grass.rye => 'Ryegrass',
    Grass.zoysia => 'Zoysia',
    Grass.kikuyu => 'Kikuyu',
    Grass.kentucky => 'Kentucky Bluegrass',
    Grass.mix => 'Mixed',
  };
}

/// 홀별 볼 위치 코드.
///
/// 웹의 shot.position 값(11종). Firestore 값 = 코드.
enum ShotPosition {
  fw('FW', '페어웨이'),
  og('OG', '그린 위'),
  ho('HO', '홀아웃'),
  rh('RH', '러프(우)'),
  sh('SH', '러프(좌)'),
  bk('BK', '벙커'),
  wh('WH', '워터해저드'),
  ts('TS', '트리샷'),
  dz('DZ', '드롭존'),
  ob('OB', 'OB'),
  lb('LB', '로스트볼');

  const ShotPosition(this.code, this.label);
  final String code;
  final String label;

  static ShotPosition? fromCode(String? c) {
    if (c == null || c.isEmpty) return null;
    return values.cast<ShotPosition?>().firstWhere(
      (e) => e!.code == c,
      orElse: () => null,
    );
  }
}

/// 핀 9-grid 위치 코드 (그린 격자).
/// 웹: 3×3 그리드, 행 상→하 = Back/Middle/Front, 열 = 좌/중/우.
/// 코드 형식: B1/B2/B3 (뒤), M1/M2/M3 (중), F1/F2/F3 (앞).
class PinGridCodes {
  const PinGridCodes._();
  static const rows = [
    ['B1', 'B2', 'B3'],
    ['M1', 'M2', 'M3'],
    ['F1', 'F2', 'F3'],
  ];
  static const all = ['B1', 'B2', 'B3', 'M1', 'M2', 'M3', 'F1', 'F2', 'F3'];
}

/// 샷 방향 (Direction) 팝업 모드.
enum DirectionMode {
  /// 9방향 화살표 (기본 — 그린 도착 아닌 샷).
  nine,

  /// 3방향 (좌/중/우) — 파4·파5의 첫 샷.
  three,

  /// 9-그리드 (OG 포지션일 때 — 핀 그리드와 같음).
  grid,
}

/// 9방향 화살표 (기본).
class DirectionArrows {
  const DirectionArrows._();

  static const nine = [
    ['⇖', '⇑', '⇗'],
    ['⇐', '◉', '⇒'],
    ['⇙', '⇓', '⇘'],
  ];

  static const three = [
    ['⇐', '◉', '⇒'],
  ];
}

/// 바람 방향 (12시 방향).
/// 값: '1'~'12' 또는 'X' (무풍).
class WindClock {
  const WindClock._();
  static const hours = <String>[
    '12',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
  ];
  static const noWind = 'X';
}

/// 클럽 목록 (자동완성용).
class Clubs {
  const Clubs._();

  static const all = <String>[
    // Driver
    'DR',
    // Woods
    '3WD', '4WD', '5WD', '7WD', '9WD',
    // Hybrids / Driving Iron
    '2HYB', '3HYB', '4HYB', '5HYB',
    '2DI', '3DI', '4DI',
    // Irons
    '2I', '3I', '4I', '5I', '6I', '7I', '8I', '9I',
    // Wedges
    'PW', 'GW', 'SW', 'LW', 'AW',
    // Putter
    'PUTT',
  ];

  /// 웹 `normalizeClub` 이식.
  /// - 'p' → 'PW'
  /// - '3w' → '3WD'
  /// - '4ut' → '4HYB'
  /// - '7'  → '7I'
  /// - '52'/'56'/'60' → 'W52'/'W56'/'W60'
  static String normalize(String raw) {
    final v = raw.trim().toUpperCase();
    if (v.isEmpty) return '';

    const known = {'DR', 'PW', 'PUTT', 'SW', 'AW', 'LW', 'GW'};
    if (known.contains(v)) return v;

    if (v == 'P') return 'PW';

    // "3I", "4WD", "5HYB", "2DI"
    if (RegExp(r'^\d+\s*(I|WD|HYB|DI)$', caseSensitive: false).hasMatch(v)) {
      return v.replaceAll(RegExp(r'\s+'), '');
    }

    final wMatch = RegExp(r'^(\d+)\s*W$').firstMatch(v);
    if (wMatch != null) return '${wMatch.group(1)}WD';

    final utMatch = RegExp(r'^(\d+)\s*UT$').firstMatch(v);
    if (utMatch != null) return '${utMatch.group(1)}HYB';

    if (RegExp(r'^[2-9]$').hasMatch(v)) return '${v}I';

    final loftMatch = RegExp(r'^(\d{2})°?$').firstMatch(v);
    if (loftMatch != null) {
      final n = int.tryParse(loftMatch.group(1)!) ?? 0;
      if (n >= 40 && n <= 70) return 'W$n';
    }

    return v;
  }
}

/// 홀 ID 헬퍼.
class HoleIds {
  const HoleIds._();

  static const front = <String>[
    'F1',
    'F2',
    'F3',
    'F4',
    'F5',
    'F6',
    'F7',
    'F8',
    'F9',
  ];
  static const back = <String>[
    'B1',
    'B2',
    'B3',
    'B4',
    'B5',
    'B6',
    'B7',
    'B8',
    'B9',
  ];
  static const all = <String>[...front, ...back];

  static bool isFront(String id) => id.startsWith('F');
  static int numberOf(String id) => int.parse(id.substring(1));

  /// 홀 카운트/플레이 순서에 따른 실제 진행 홀 목록.
  static List<String> ordered({
    required HoleCount holeCount,
    PlayOrder? playOrder,
  }) {
    if (holeCount == HoleCount.nine) {
      if (playOrder == PlayOrder.backFirst) return back;
      return front;
    }
    // 18홀
    if (playOrder == PlayOrder.backFirst) return [...back, ...front];
    return [...front, ...back];
  }
}
