import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 언어 상태.
///
/// - `null` : OS 언어를 따름 (Auto, 기본). 지원 외 언어는 영어로 폴백.
/// - `Locale('en')` / `Locale('ja')` / `Locale('ko')` : 사용자가 명시적으로 선택.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void setLocale(Locale? locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

/// 지원 언어 목록. 첫 번째가 fallback (영어).
const supportedLocales = <Locale>[Locale('en'), Locale('ja'), Locale('ko')];
