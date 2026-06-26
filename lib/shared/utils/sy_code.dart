import 'dart:math';

import '../../features/auth/domain/user_role.dart';

/// 웹 [pages/signup.js](haru-syadow-platform/pages/signup.js)의
/// `roleToPrefix` + `randomSix` 로직을 그대로 이식.
///
/// 형식: `SY-{P|C|F|T}-{6 chars from 0-9A-Z}`
/// 예: `SY-P-A1B2C3`
class SyCode {
  static const _alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final _rng = Random();

  static String prefix(UserRole role) => switch (role) {
    UserRole.player => 'P',
    UserRole.coach => 'C',
    UserRole.fitter => 'F',
    UserRole.trainer => 'T',
  };

  static String _randomSix() {
    final b = StringBuffer();
    for (var i = 0; i < 6; i++) {
      b.write(_alphabet[_rng.nextInt(_alphabet.length)]);
    }
    return b.toString();
  }

  static String generate(UserRole role) => 'SY-${prefix(role)}-${_randomSix()}';
}
