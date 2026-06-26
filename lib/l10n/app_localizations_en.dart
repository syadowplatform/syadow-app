// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SYADOW';

  @override
  String get appTagline => 'Golf Performance Tracking';

  @override
  String get signIn => 'Sign In';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signingUp => 'Creating account...';

  @override
  String get createAccount => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Password (6+ characters)';

  @override
  String get name => 'Name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccountQuestion => 'Don\'t have an account?';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get validatorEmailRequired => 'Please enter your email';

  @override
  String get validatorEmailInvalid => 'Invalid email format';

  @override
  String get validatorPasswordRequired => 'Please enter your password';

  @override
  String get validatorPasswordTooShort => 'Must be at least 6 characters';

  @override
  String get validatorNameRequired => 'Please enter your name';

  @override
  String get signupTitle => 'Join SYADOW';

  @override
  String get signupSubtitle => 'Pick your role and create an account';

  @override
  String get sectionRole => 'Role';

  @override
  String get sectionAccount => 'Account';

  @override
  String get rolePlayer => 'Player';

  @override
  String get rolePlayerDesc => 'Track rounds & get coached';

  @override
  String get roleCoach => 'Coach';

  @override
  String get roleCoachDesc => 'Swing & strategy coaching';

  @override
  String get roleFitter => 'Fitter';

  @override
  String get roleFitterDesc => 'Club fitting specialist';

  @override
  String get roleTrainer => 'Trainer';

  @override
  String get roleTrainerDesc => 'Physical training';

  @override
  String termsNotice(String terms, String privacy) {
    return 'By signing up you agree to our $terms and $privacy.';
  }

  @override
  String get termsLink => 'Terms of Service';

  @override
  String get privacyLink => 'Privacy Policy';

  @override
  String get langEnglish => 'EN';

  @override
  String get langKorean => 'KO';

  @override
  String get signOut => 'Sign Out';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorUserNotFound => 'No account found with this email';

  @override
  String get errorWrongPassword => 'Incorrect password';

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String get errorEmailInUse => 'This email is already registered';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get errorNetwork => 'Network error. Please try again.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';
}
