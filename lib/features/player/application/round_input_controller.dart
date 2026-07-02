import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_round_repository.dart';
import '../domain/golf_constants.dart';
import '../domain/hole_data.dart';
import '../domain/player_round.dart';

/// 라운드 입력 드래프트.
class RoundDraft {
  const RoundDraft({
    required this.meta,
    required this.holes,
    required this.notes,
    this.scoreCardPhotoPath,
  });

  final RoundMeta meta;
  final Map<String, HoleEntry> holes;
  final RoundNotes notes;
  final String? scoreCardPhotoPath;

  ScoreSummary get scoreSummary {
    int f = 0, b = 0;
    for (final id in HoleIds.front) {
      f += holes[id]?.autoScore ?? 0;
    }
    for (final id in HoleIds.back) {
      b += holes[id]?.autoScore ?? 0;
    }
    return ScoreSummary(front9: f, back9: b, total: f + b);
  }

  RoundDraft copyWith({
    RoundMeta? meta,
    Map<String, HoleEntry>? holes,
    RoundNotes? notes,
    String? scoreCardPhotoPath,
    bool clearScoreCardPhoto = false,
  }) => RoundDraft(
    meta: meta ?? this.meta,
    holes: holes ?? this.holes,
    notes: notes ?? this.notes,
    scoreCardPhotoPath: clearScoreCardPhoto
        ? null
        : (scoreCardPhotoPath ?? this.scoreCardPhotoPath),
  );

  factory RoundDraft.blank() {
    final holes = <String, HoleEntry>{
      for (final id in HoleIds.all) id: HoleEntry.empty(id),
    };
    return RoundDraft(
      meta: RoundMeta(date: DateTime.now()),
      holes: holes,
      notes: const RoundNotes(),
    );
  }
}

/// 라운드 입력 상태 컨트롤러.
///
/// 화면 3개(Meta/Holes/Summary)가 모두 이 provider를 읽고 씀.
class RoundInputController extends Notifier<RoundDraft> {
  @override
  RoundDraft build() => RoundDraft.blank();

  // -------- Meta --------
  void reset() => state = RoundDraft.blank();
  void setMeta(RoundMeta meta) => state = state.copyWith(meta: meta);

  // -------- Holes --------
  HoleEntry hole(String id) => state.holes[id] ?? HoleEntry.empty(id);

  void _updateHole(String id, HoleEntry Function(HoleEntry) f) {
    final current = hole(id);
    final next = f(current);
    state = state.copyWith(holes: {...state.holes, id: next});
  }

  void setPar(String holeId, int par) {
    _updateHole(holeId, (h) => h.copyWith(par: par));
  }

  void setPin(String holeId, String? pin) {
    _updateHole(
      holeId,
      (h) => pin == null ? h.copyWith(clearPin: true) : h.copyWith(pin: pin),
    );
  }

  void setTapIn(String holeId, bool v) {
    _updateHole(holeId, (h) => h.copyWith(tapIn: v));
  }

  void setPenalty(String holeId, int v) {
    _updateHole(holeId, (h) => h.copyWith(penalty: v));
  }

  // -------- Shots --------
  void addShot(String holeId) {
    _updateHole(holeId, (h) {
      final next = [...h.shots, Shot(index: h.shots.length + 1)];
      return h.copyWith(shots: next);
    });
  }

  void removeShot(String holeId, int index) {
    _updateHole(holeId, (h) {
      final list = [...h.shots]..removeAt(index);
      // reindex
      final reindexed = <Shot>[
        for (var i = 0; i < list.length; i++) list[i].copyWith(index: i + 1),
      ];
      return h.copyWith(shots: reindexed);
    });
  }

  void updateShot(String holeId, int index, Shot Function(Shot) f) {
    _updateHole(holeId, (h) {
      final list = [...h.shots];
      list[index] = f(list[index]);
      return h.copyWith(shots: list);
    });
  }

  // -------- Putts --------
  void addPutt(String holeId) {
    _updateHole(holeId, (h) {
      final next = [...h.putts, Putt(index: h.putts.length + 1)];
      return h.copyWith(putts: next);
    });
  }

  void removePutt(String holeId, int index) {
    _updateHole(holeId, (h) {
      final list = [...h.putts]..removeAt(index);
      final reindexed = <Putt>[
        for (var i = 0; i < list.length; i++) list[i].copyWith(index: i + 1),
      ];
      return h.copyWith(putts: reindexed);
    });
  }

  void updatePutt(String holeId, int index, Putt Function(Putt) f) {
    _updateHole(holeId, (h) {
      final list = [...h.putts];
      list[index] = f(list[index]);
      return h.copyWith(putts: list);
    });
  }

  // -------- Notes --------
  void setNotes(RoundNotes notes) => state = state.copyWith(notes: notes);

  // -------- Photo --------
  void setPhoto(String? path) {
    if (path == null) {
      state = state.copyWith(clearScoreCardPhoto: true);
    } else {
      state = state.copyWith(scoreCardPhotoPath: path);
    }
  }

  // -------- Save --------
  Future<void> save({
    required String uid,
    required PlayerRoundRepository repo,
  }) async {
    final draft = state;
    final round = PlayerRound(
      uid: uid,
      meta: draft.meta,
      holes: draft.holes,
      notes: draft.notes,
      createdAt: DateTime.now(),
    );
    await repo.save(round);
  }
}

final roundInputProvider = NotifierProvider<RoundInputController, RoundDraft>(
  RoundInputController.new,
);

/// Mock repository provider (Phase 7에서 Firestore로 교체).
final playerRoundRepositoryProvider = Provider<PlayerRoundRepository>((ref) {
  return MockPlayerRoundRepository();
});
