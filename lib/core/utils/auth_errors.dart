import 'package:firebase_auth/firebase_auth.dart';

import '../../l10n/app_localizations.dart';

/// Firebase Auth 에러 코드를 다국어 메시지로 매핑.
String mapAuthError(Object e, AppLocalizations t) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-email':
        return t.errorInvalidEmail;
      case 'user-not-found':
        return t.errorUserNotFound;
      case 'wrong-password':
        return t.errorWrongPassword;
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return t.errorInvalidCredentials;
      case 'email-already-in-use':
        return t.errorEmailInUse;
      case 'weak-password':
        return t.errorWeakPassword;
      case 'network-request-failed':
        return t.errorNetwork;
    }
  }
  return t.errorUnknown;
}
