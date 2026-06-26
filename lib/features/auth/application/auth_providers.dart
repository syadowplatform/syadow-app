import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());

/// Firebase Auth 상태 스트림 (null = 로그아웃 상태).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});
