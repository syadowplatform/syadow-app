import '../domain/player_round.dart';

/// 플레이어 라운드 저장소 (Phase 7에서 Firestore 구현으로 교체 예정).
abstract class PlayerRoundRepository {
  Future<void> save(PlayerRound round);

  /// 로그인한 사용자의 라운드 스트림 (최신순).
  Stream<List<PlayerRound>> watchAll(String uid);
}

/// Phase 5용 mock. 메모리에만 저장.
class MockPlayerRoundRepository implements PlayerRoundRepository {
  final List<PlayerRound> _rounds = [];

  @override
  Future<void> save(PlayerRound round) async {
    _rounds.insert(0, round);
  }

  @override
  Stream<List<PlayerRound>> watchAll(String uid) async* {
    yield List.unmodifiable(_rounds);
  }
}
