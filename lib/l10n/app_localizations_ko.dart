// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'SYADOW';

  @override
  String get appTagline => '골프 퍼포먼스 트래킹';

  @override
  String get signIn => '로그인';

  @override
  String get signingIn => '로그인 중...';

  @override
  String get signUp => '회원가입';

  @override
  String get signingUp => '가입 중...';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get passwordHint => '비밀번호 (6자 이상)';

  @override
  String get name => '이름';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get orDivider => '또는';

  @override
  String get continueWithApple => 'Apple로 계속하기';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get noAccountQuestion => '계정이 없으신가요?';

  @override
  String get comingSoon => '준비 중입니다';

  @override
  String get welcomeIHaveAccount => '이미 계정이 있어요';

  @override
  String get welcomeTileGolf => '골프';

  @override
  String get welcomeTileCoach => '코칭';

  @override
  String get welcomeTileFitter => '피팅';

  @override
  String get welcomeTileTrainer => '트레이닝';

  @override
  String get validatorEmailRequired => '이메일을 입력하세요';

  @override
  String get validatorEmailInvalid => '올바른 이메일 형식이 아닙니다';

  @override
  String get validatorPasswordRequired => '비밀번호를 입력하세요';

  @override
  String get validatorPasswordTooShort => '6자 이상 입력하세요';

  @override
  String get validatorNameRequired => '이름을 입력하세요';

  @override
  String get signupTitle => 'SYADOW에 합류';

  @override
  String get signupSubtitle => '역할을 선택하고 계정을 만드세요';

  @override
  String get sectionRole => '역할';

  @override
  String get sectionAccount => '계정 정보';

  @override
  String get rolePlayer => '플레이어';

  @override
  String get rolePlayerDesc => '라운드 기록 & 코칭';

  @override
  String get roleCoach => '코치';

  @override
  String get roleCoachDesc => '스윙·전략 코칭';

  @override
  String get roleFitter => '피터';

  @override
  String get roleFitterDesc => '클럽 피팅 전문';

  @override
  String get roleTrainer => '트레이너';

  @override
  String get roleTrainerDesc => '피지컬 트레이닝';

  @override
  String termsNotice(String terms, String privacy) {
    return '가입 시 $terms 및 $privacy에 동의합니다.';
  }

  @override
  String get termsLink => '이용약관';

  @override
  String get privacyLink => '개인정보 처리방침';

  @override
  String get langEnglish => 'EN';

  @override
  String get langKorean => 'KO';

  @override
  String get signOut => '로그아웃';

  @override
  String get errorInvalidEmail => '올바른 이메일 주소가 아닙니다';

  @override
  String get errorUserNotFound => '해당 이메일로 등록된 계정이 없습니다';

  @override
  String get errorWrongPassword => '비밀번호가 올바르지 않습니다';

  @override
  String get errorInvalidCredentials => '이메일 또는 비밀번호가 올바르지 않습니다';

  @override
  String get errorEmailInUse => '이미 가입된 이메일입니다';

  @override
  String get errorWeakPassword => '비밀번호가 너무 간단합니다';

  @override
  String get errorNetwork => '네트워크 오류입니다. 다시 시도해 주세요.';

  @override
  String get errorUnknown => '문제가 발생했습니다. 다시 시도해 주세요.';
}
