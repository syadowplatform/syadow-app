// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'SYADOW';

  @override
  String get appTagline => 'ゴルフ パフォーマンス トラッキング';

  @override
  String get signIn => 'ログイン';

  @override
  String get signingIn => 'ログイン中...';

  @override
  String get signUp => '新規登録';

  @override
  String get signingUp => '登録中...';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get passwordHint => 'パスワード (6文字以上)';

  @override
  String get name => 'お名前';

  @override
  String get forgotPassword => 'パスワードをお忘れですか?';

  @override
  String get orDivider => 'または';

  @override
  String get continueWithApple => 'Appleで続ける';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get noAccountQuestion => 'アカウントをお持ちでない方';

  @override
  String get comingSoon => '近日対応予定';

  @override
  String get welcomeIHaveAccount => 'すでにアカウントをお持ちの方';

  @override
  String get welcomeTileGolf => 'ゴルフ';

  @override
  String get welcomeTileCoach => 'コーチング';

  @override
  String get welcomeTileFitter => 'フィッティング';

  @override
  String get welcomeTileTrainer => 'トレーニング';

  @override
  String get validatorEmailRequired => 'メールアドレスを入力してください';

  @override
  String get validatorEmailInvalid => 'メールアドレスの形式が正しくありません';

  @override
  String get validatorPasswordRequired => 'パスワードを入力してください';

  @override
  String get validatorPasswordTooShort => '6文字以上で入力してください';

  @override
  String get validatorNameRequired => 'お名前を入力してください';

  @override
  String get signupTitle => 'SYADOW に参加';

  @override
  String get signupSubtitle => 'ロールを選んでアカウントを作成';

  @override
  String get sectionRole => 'ロール';

  @override
  String get sectionAccount => 'アカウント情報';

  @override
  String get rolePlayer => 'プレーヤー';

  @override
  String get rolePlayerDesc => 'ラウンド記録とコーチング';

  @override
  String get roleCoach => 'コーチ';

  @override
  String get roleCoachDesc => 'スイング・戦略コーチング';

  @override
  String get roleFitter => 'フィッター';

  @override
  String get roleFitterDesc => 'クラブフィッティング';

  @override
  String get roleTrainer => 'トレーナー';

  @override
  String get roleTrainerDesc => 'フィジカルトレーニング';

  @override
  String termsNotice(String terms, String privacy) {
    return '登録すると$termsおよび$privacyに同意したものとみなされます。';
  }

  @override
  String get termsLink => '利用規約';

  @override
  String get privacyLink => 'プライバシーポリシー';

  @override
  String get langEnglish => 'EN';

  @override
  String get langKorean => 'KO';

  @override
  String get signOut => 'ログアウト';

  @override
  String get errorInvalidEmail => 'メールアドレスの形式が正しくありません';

  @override
  String get errorUserNotFound => 'このメールで登録されたアカウントはありません';

  @override
  String get errorWrongPassword => 'パスワードが違います';

  @override
  String get errorInvalidCredentials => 'メールまたはパスワードが違います';

  @override
  String get errorEmailInUse => 'このメールはすでに登録されています';

  @override
  String get errorWeakPassword => 'パスワードが脆弱です';

  @override
  String get errorNetwork => 'ネットワークエラー。もう一度お試しください。';

  @override
  String get errorUnknown => '問題が発生しました。もう一度お試しください。';
}
