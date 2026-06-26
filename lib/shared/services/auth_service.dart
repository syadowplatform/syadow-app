import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/domain/user_role.dart';
import '../utils/sy_code.dart';

/// Firebase Auth + Firestore user 문서 관리.
///
/// Firestore 스키마는 웹 [pages/signup.js](haru-syadow-platform/pages/signup.js)와
/// 호환되도록 유지. 앱은 가입 시 최소 필드(`profileCompleted: false`)만 쓰고,
/// 프로필 상세(birth/country/phone 등)는 이후 프로필 화면에서 채움.
///
/// 필수 필드 (Firestore Rules가 요구):
///   - `sy_code` ∈ `^SY-[PCFT]-[0-9A-Z]{6}$`
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    await cred.user?.updateDisplayName(name);

    final syCode = SyCode.generate(role);
    final nowIso = DateTime.now().toUtc().toIso8601String();

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'role': role.name,
      'email': email.trim(),
      'sy_code': syCode,
      'profileCompleted': false,
      'profile': {
        'firstName': '',
        'lastName': '',
        'fullName': name.trim(),
        'playingName': '',
        'birth': '',
        'country': '',
        'gender': '',
        'phone': '',
        'phoneCountryCode': '',
        'phoneNumber': '',
      },
      'lang': 'en',
      'createdAt': nowIso,
    });
    return cred;
  }

  Future<void> signOut() => _auth.signOut();
}
