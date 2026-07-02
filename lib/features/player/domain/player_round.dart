import 'golf_constants.dart';
import 'hole_data.dart';

/// 라운드 메타 정보 (웹 payload.meta와 동일).
class RoundMeta {
  const RoundMeta({
    this.mode = RoundMode.practice,
    this.tournamentName = '',
    this.date, // 라운드 날짜 (플레이한 날)
    this.courseName = '',
    this.teeTime = TeeTime.morning,
    this.playOrder = PlayOrder.frontFirst,
    this.holeCount = HoleCount.eighteen,
    this.weather = Weather.sunny,
    this.tempUnit = TempUnit.c,
    this.tempRange, // '0-15C' 등
    this.windSpeedLow, // mph
    this.windSpeedHigh, // mph
    this.windDirection = '',
    this.fairwayGrass,
    this.fairwayMix1,
    this.fairwayMix2,
    this.roughGrass,
    this.roughMix1,
    this.roughMix2,
    this.greenGrass,
    this.greenMix1,
    this.greenMix2,
    this.source = 'app', // 웹은 'player-input'
  });

  final RoundMode mode;
  final String tournamentName;
  final DateTime? date;
  final String courseName;
  final TeeTime teeTime;
  final PlayOrder playOrder;
  final HoleCount holeCount;

  final Weather weather;
  final TempUnit tempUnit;
  final String? tempRange;
  final double? windSpeedLow;
  final double? windSpeedHigh;
  final String windDirection;

  final Grass? fairwayGrass;
  final Grass? fairwayMix1;
  final Grass? fairwayMix2;
  final Grass? roughGrass;
  final Grass? roughMix1;
  final Grass? roughMix2;
  final Grass? greenGrass;
  final Grass? greenMix1;
  final Grass? greenMix2;

  final String source;

  RoundMeta copyWith({
    RoundMode? mode,
    String? tournamentName,
    DateTime? date,
    String? courseName,
    TeeTime? teeTime,
    PlayOrder? playOrder,
    HoleCount? holeCount,
    Weather? weather,
    TempUnit? tempUnit,
    String? tempRange,
    double? windSpeedLow,
    double? windSpeedHigh,
    String? windDirection,
    Grass? fairwayGrass,
    Grass? fairwayMix1,
    Grass? fairwayMix2,
    Grass? roughGrass,
    Grass? roughMix1,
    Grass? roughMix2,
    Grass? greenGrass,
    Grass? greenMix1,
    Grass? greenMix2,
    String? source,
    bool clearDate = false,
    bool clearFairwayGrass = false,
    bool clearRoughGrass = false,
    bool clearGreenGrass = false,
    bool clearTempRange = false,
  }) => RoundMeta(
    mode: mode ?? this.mode,
    tournamentName: tournamentName ?? this.tournamentName,
    date: clearDate ? null : (date ?? this.date),
    courseName: courseName ?? this.courseName,
    teeTime: teeTime ?? this.teeTime,
    playOrder: playOrder ?? this.playOrder,
    holeCount: holeCount ?? this.holeCount,
    weather: weather ?? this.weather,
    tempUnit: tempUnit ?? this.tempUnit,
    tempRange: clearTempRange ? null : (tempRange ?? this.tempRange),
    windSpeedLow: windSpeedLow ?? this.windSpeedLow,
    windSpeedHigh: windSpeedHigh ?? this.windSpeedHigh,
    windDirection: windDirection ?? this.windDirection,
    fairwayGrass: clearFairwayGrass
        ? null
        : (fairwayGrass ?? this.fairwayGrass),
    fairwayMix1: fairwayMix1 ?? this.fairwayMix1,
    fairwayMix2: fairwayMix2 ?? this.fairwayMix2,
    roughGrass: clearRoughGrass ? null : (roughGrass ?? this.roughGrass),
    roughMix1: roughMix1 ?? this.roughMix1,
    roughMix2: roughMix2 ?? this.roughMix2,
    greenGrass: clearGreenGrass ? null : (greenGrass ?? this.greenGrass),
    greenMix1: greenMix1 ?? this.greenMix1,
    greenMix2: greenMix2 ?? this.greenMix2,
    source: source ?? this.source,
  );

  /// 웹 payload.meta 스키마 그대로 직렬화.
  Map<String, dynamic> toFirestore() {
    String noteOf(Grass? g, Grass? mix1, Grass? mix2) => g == Grass.mix
        ? [mix1?.label, mix2?.label].whereType<String>().join(' + ')
        : '';

    return {
      'mode': mode.code,
      'source': source,
      'tournamentName': tournamentName,
      'date': date == null
          ? ''
          : '${date!.year.toString().padLeft(4, '0')}-'
                '${date!.month.toString().padLeft(2, '0')}-'
                '${date!.day.toString().padLeft(2, '0')}',
      'courseName': courseName,
      'teeTime': teeTime.code,
      'playOrder': playOrder.code,
      'holeCount': holeCount.code,
      'tempUnit': tempUnit.code,
      'tempRange': tempRange ?? '',
      'weather': weather.code,
      'windDirection': windDirection,
      'windSpeedLow': windSpeedLow ?? 0,
      'windSpeedHigh': windSpeedHigh ?? 0,
      'fairwayGrass': fairwayGrass?.code ?? '',
      'fairwayGrassNote': noteOf(fairwayGrass, fairwayMix1, fairwayMix2),
      'fairwayMix1': fairwayMix1?.code ?? '',
      'fairwayMix2': fairwayMix2?.code ?? '',
      'roughGrass': roughGrass?.code ?? '',
      'roughGrassNote': noteOf(roughGrass, roughMix1, roughMix2),
      'roughMix1': roughMix1?.code ?? '',
      'roughMix2': roughMix2?.code ?? '',
      'greenGrass': greenGrass?.code ?? '',
      'greenGrassNote': noteOf(greenGrass, greenMix1, greenMix2),
      'greenMix1': greenMix1?.code ?? '',
      'greenMix2': greenMix2?.code ?? '',
    };
  }
}

/// 라운드 노트 (웹 payload.notes와 동일).
class RoundNotes {
  const RoundNotes({
    this.swing = '',
    this.shortGame = '',
    this.putting = '',
    this.mind = '',
  });

  final String swing;
  final String shortGame;
  final String putting;
  final String mind;

  bool get isEmpty =>
      swing.isEmpty && shortGame.isEmpty && putting.isEmpty && mind.isEmpty;

  RoundNotes copyWith({
    String? swing,
    String? shortGame,
    String? putting,
    String? mind,
  }) => RoundNotes(
    swing: swing ?? this.swing,
    shortGame: shortGame ?? this.shortGame,
    putting: putting ?? this.putting,
    mind: mind ?? this.mind,
  );

  Map<String, dynamic> toFirestore() => {
    'swing': swing,
    'shortGame': shortGame,
    'putting': putting,
    'mind': mind,
  };
}

/// 라운드 스코어 요약 (웹 payload.scoreSummary와 동일).
class ScoreSummary {
  const ScoreSummary({this.front9 = 0, this.back9 = 0, this.total = 0});
  final int front9;
  final int back9;
  final int total;

  Map<String, dynamic> toFirestore() => {
    'front9': front9,
    'back9': back9,
    'total': total,
  };
}

/// 완성된 플레이어 라운드 (Firestore `player_rounds/{id}` 문서 스키마).
class PlayerRound {
  const PlayerRound({
    this.id,
    required this.uid,
    required this.meta,
    required this.holes,
    this.notes = const RoundNotes(),
    this.createdAt,
    this.scoreCardPhotoUrl, // 앱 전용 — 나중에 추가
  });

  final String? id;
  final String uid;
  final RoundMeta meta;
  final Map<String, HoleEntry> holes; // key = 'F1'..'B9'
  final RoundNotes notes;
  final DateTime? createdAt;
  final String? scoreCardPhotoUrl;

  ScoreSummary get scoreSummary {
    int f = 0, b = 0;
    for (final id in HoleIds.front) {
      final h = holes[id];
      if (h != null) f += h.autoScore;
    }
    for (final id in HoleIds.back) {
      final h = holes[id];
      if (h != null) b += h.autoScore;
    }
    return ScoreSummary(front9: f, back9: b, total: f + b);
  }

  /// 웹 payload 스키마 그대로 저장.
  Map<String, dynamic> toFirestore() {
    final holeMap = <String, dynamic>{};
    for (final id in HoleIds.all) {
      holeMap[id] =
          holes[id]?.toFirestore() ?? HoleEntry.empty(id).toFirestore();
    }
    return {
      'uid': uid,
      'meta': meta.toFirestore(),
      'notes': notes.toFirestore(),
      'scoreSummary': scoreSummary.toFirestore(),
      'holes': holeMap,
      if (scoreCardPhotoUrl != null) 'scoreCardPhotoUrl': scoreCardPhotoUrl,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }
}
