# SYADOW App 워킹노트

> **이 파일이 SYADOW 앱 개발의 단일 출처**
> 다음 세션 시작 시 반드시 이 파일을 먼저 읽을 것
> 웹 정책/원칙은 별도 레포 참조: `/Users/harumoon/haru-syadow-platform/WORKING_NOTE_2026-02-20.md`

---

## 📌 프로젝트 개요

### 기본 정보
- **이름**: SYADOW (앱)
- **레포 위치**: `~/syadow-app/syadow` (별도 레포, 웹과 분리)
- **웹 레포**: `~/haru-syadow-platform` (참조용, 코드 공유 안 함)
- **Firebase 프로젝트**: `syadow-pro` (웹과 **공유** — Auth/Firestore/Storage 동일)
- **번들 ID**: `com.syadow.syadow` (iOS), `com.syadow.syadow` (Android)
- **플랫폼**: iOS + Android (웹 빌드는 V2 이후 고려)

### 기술 스택
- **Framework**: Flutter 3.44.2 (stable)
- **언어**: Dart 3.12.2
- **상태관리**: 미정 (Phase 2에서 결정 — Riverpod vs Provider)
- **Backend**: Firebase (syadow-pro 공유)
  - Auth, Firestore, Storage, Messaging
- **로컬 캐시**: shared_preferences + persistentLocalCache (Firestore 자체)

### 디자인 토큰 (웹과 동일)
- **테마**: Dark + Glassmorphism
- **브랜드 폰트**: Orbitron (weights 700/900)
- **본문 폰트**: 시스템 폰트 스택 (iOS=SF Pro, Android=Roboto). 웹과 동일.
  - ⚠️ 이전 기록의 "Pretendard"는 오류 (웹 실제 미사용) — 2026-06-19 정정
- **애니메이션**: 0.2s spring micro-animations
- **색 팔레트**: 웹 [css/syadow-ui.css](../../haru-syadow-platform/css/syadow-ui.css) 토큰 그대로
  - `--midnight: #0B132B`, `--gun1: #2C2F33`, `--gun2: #3A506B`
  - `--rose1: #D4A373`, `--rose2: #E4B48E`
  - `--bg0: #070D1F`, `--text: #EAF0FA`, `--muted: #93A6BD`

---

## 🎯 역할/구조 (웹 정책 그대로)

### 역할
- **Player** (선수)
- **Coach** (코치)
- **Fitter** (피터)
- **Trainer** (운동 트레이너) — 🆕 앱부터 추가

### 연결 모델
- Player ↔ Coach (월 $4.99, 양쪽 과금)
- Player ↔ Fitter (월 $4.99, 양쪽 과금)
- Player ↔ Trainer (월 $4.99, 양쪽 과금) — 🆕
- Coach ↔ Trainer = **V2로 미룸**

### Trainer V1 범위
- Fitter 복사판 + 운동 메뉴 (클럽 대신)
- Firestore 컬렉션:
  - `trainer_workout_sessions` (Fitter의 `fitter_club_replacements` 대응)
  - `trainer_injury_notes` (선택)
- Player 캘린더에 **4번째 다트(orange)** = workouts
- Trainer Stats 페이지 = V2

### V2로 미룬 것 (재논의 X)
- Coach ↔ Trainer 연결
- Trainer Stats 페이지
- 슬로모션/드로잉/AR 카메라 기능
- 웹 빌드 (Flutter Web)

---

## 💰 구독/결제 (웹 정책 동일)

- 기본료: $11.99/mo
- 연결당: $4.99/mo (양쪽 모두 과금)
- 무료체험: 5일 (전화번호 SHA-256 해시로 1회 제한)
- 결제: **Lemon Squeezy** (Merchant of Record, 한국 개인사업자 대응)
- 앱 결제는 In-App Purchase **사용 안 함** (Lemon Squeezy 외부 결제 유도)
  - ⚠️ Apple Guideline 3.1.1 위반 가능 — 베타에서 검증 필요

---

## 🛣 로드맵

| Phase | 내용 | 상태 | 예상 |
|---|---|---|---|
| 0 | Flutter/Xcode/CocoaPods 환경 설치 | ✅ **완료** (2026-06-18) | - |
| 1 | 프로젝트 생성 + iPhone 17 시뮬레이터 빌드 성공 | ✅ **완료** (2026-06-18) | - |
| 2 | Firebase 연결 + Riverpod/go_router 배선 | ✅ **완료** (2026-06-19) | - |
| 3 | 디자인 토큰 (색/폰트/테마) 셋업 | ✅ **완료** (2026-06-25) | - |
| 4 | 인증 화면 (로그인/회원가입) 포팅 + 실 검증 | ✅ **완료** (2026-06-28) | - |
| 4.5 | Splash 화면 + 진짜 SVG 워드마크 도입 | ✅ **완료** (2026-06-28) | - |
| **5** | **UI 일괄 (mockup)**: Dashboard / Player Input / Stats / Chat / Coach / Fitter / Trainer 화면을 mock 데이터로 디자인까지 완성 | 🟡 진행 중 (Welcome 완료, 회원가입 재구성 예정) | ~20h |
| **6** | **데이터 모델 정의**: Firestore 스키마 그대로 Dart 모델 클래스 (`PlayerRound`, `CalendarEvent`, `CoachLesson`, ...) | ⏳ | ~3h |
| **7** | **Firestore Repository 일괄 배선**: `currentUserProvider`, 각 도메인 `StreamProvider` → 화면의 mock 데이터를 `ref.watch()` 결과로 교체 | ⏳ | ~6h |
| 8 | 디바이스 기능: GPS 자동입력 + 카메라 녹화/업로드 + 푸시 알림 | ⏳ | ~6h |
| 9 | TestFlight 베타 → App Store / Play Store 제출 | ⏳ | ~?? |

> **전략 변경 (2026-06-28)**: 화면별로 mockup→연결을 1세트씩 가는 대신, **UI를 먼저 일괄로 끝내고 데이터 레이어를 한 번에 배선**.
> 이유:
> - Firestore 스키마가 웹과 100% 공유돼서 데이터 리스크가 거의 없음. 디자인/UX 리스크가 훨씬 큼
> - 화면을 한 번에 만들면 공용 위젯·디자인 톤 통일성 잘 잡힘
> - 빠른 hot reload 루프로 디자인 반복이 효율적
>
> **핵심 비결**: mockup 데이터를 화면에 하드코딩하지 말고 `lib/features/{feature}/data/mock_*_repository.dart`로 분리하고, **모델 클래스는 처음부터 실제 Firestore 스키마 그대로** 정의. 그러면 Phase 7의 교체가 trivial해짐.

---

# 📅 작업 이력

## 2026-06-18 — Phase 0 + Phase 1 완료 🎉

### 환경 설치 (Phase 0)

#### 시작 환경
```
macOS 26.5.1 (Build 25F80) Apple Silicon (darwin-arm64)
Homebrew 5.1.6 ✅
Flutter ❌
Xcode CLI tools만 (Full Xcode 없음)
CocoaPods ❌
Android Studio ❌
```

#### 진행 순서
1. **Flutter SDK 설치**
   ```bash
   brew install --cask flutter
   ```
   → Flutter 3.44.2 (stable) / Dart 3.12.2 설치됨

2. **Xcode (Full) 설치**
   - App Store에서 Xcode 26.5 설치
   - `sudo xcodebuild -runFirstLaunch`
   - 라이선스 동의

3. **CocoaPods 설치** ⚠️ 첫 시도 실패
   - ❌ `sudo gem install cocoapods` → 시스템 Ruby 2.6.10 너무 오래됨, ffi 패키지가 Ruby 3.0+ 요구
   - ✅ `brew install cocoapods` 로 해결 → **CocoaPods 1.16.2** 설치 성공
   - **교훈**: macOS에서 CocoaPods 설치는 무조건 Homebrew 방식 (`gem install` 더 이상 X)

4. **flutter doctor 결과**
   ```
   [✓] Flutter 3.44.2
   [✗] Android toolchain — 미설치 (V1 후반에 설치 예정, 지금 OK)
   [✓] Xcode 26.5
   [✓] Chrome
   [✓] Connected device (2 available)
   [✓] Network resources
   ```
   → iOS 개발 환경 100% 준비됨. Android는 나중에.

### 프로젝트 생성 (Phase 1)

#### 명령
```bash
mkdir -p ~/syadow-app && cd ~/syadow-app
flutter create syadow --org com.syadow --platforms ios,android
```

#### 결과
- 75개 파일 생성됨
- 경로: `~/syadow-app/syadow/`
- 핵심 파일:
  - `lib/main.dart` — 진입점 (현재는 기본 카운터 앱)
  - `pubspec.yaml` — 의존성 관리
  - `ios/Runner.xcworkspace` — Xcode 작업파일 (`xcodeproj` 아님)
  - `android/` — 안드 프로젝트

#### VS Code `code` 명령 PATH 등록
- 처음에 `code` 명령어가 없어서 (`command not found`)
- VS Code 명령 팔레트 → "Shell Command: Install 'code' command in PATH" 실행

### 첫 빌드 시도 (Phase 1 검증)

#### 1차 시도 — 실패
```bash
flutter run
# → Failed to build iOS app
# → Uncategorized (Xcode): xcodebuild encountered an error (74)
```
**원인**: `ios/Podfile` 이 없어서 (Flutter는 첫 빌드 시 자동 생성하는데 어느 단계서 누락된 듯)

#### 2차 시도 — 성공 ✅
```bash
cd ~/syadow-app/syadow
flutter run
```
→ Flutter가 자동으로:
1. `Podfile` 생성
2. `pod install` 자동 실행
3. iOS 빌드
4. iPhone 17 시뮬레이터에 앱 설치
5. 실행 → Dart VM Service 연결

**결과**: 시뮬레이터 홈 화면에 **`Syadow` 앱 아이콘** (Flutter 로고) 정상 설치 확인 ✅

### 확인된 기능
- ✅ Flutter 카운터 앱 실행 (Hot Reload 가능)
- ✅ Dart VM Service 디버거 연결
- ✅ DevTools 사용 가능
- ✅ iPhone 17 시뮬레이터 정상 동작

### 알게 된 것 / 트러블슈팅 기록

1. **iOS 26 + Xcode 26.5 + Flutter 3.44.2 조합 정상 작동** — 처음에 호환성 의심했지만 OK
2. **CocoaPods는 brew로** — `sudo gem install` 절대 사용 X (시스템 Ruby 너무 오래됨)
3. **iOS 빌드 첫 실패 → 그냥 `flutter run` 한 번 더 하면 자동 복구** — Podfile 생성 + pod install 알아서 함
4. **iOS 시뮬레이터는 한국어 환경** (locale ko-KR 자동 적용)

---

## 2026-06-19 — Phase 2 완료 🎉 (Firebase + Riverpod + go_router 배선)

### 아키텍처 결정 (코드 쓰기 전 확정)
- **상태관리**: Riverpod 3.3.2 (`ProviderScope` + `ConsumerWidget`)
- **라우팅**: go_router 17.3.0 (`MaterialApp.router` + `routerConfig`)
- **차트**: fl_chart 1.2.0 (Phase 7에서 사용)

### 폴더 스켈레톤 생성
```
lib/
├── core/{theme, utils, router}/
├── features/{auth, dashboard, player, coach, fitter, trainer}/
└── shared/{widgets, services}/
```
각 폴더에 `.gitkeep` (실제 파일 생기면 제거)

### FlutterFire 셋업
1. `dart pub global activate flutterfire_cli` → flutterfire 1.4.0
2. `~/.zshrc`에 `export PATH="$PATH:$HOME/.pub-cache/bin"` 추가
3. `flutterfire configure --project=syadow-pro --platforms=ios,android --ios-bundle-id=com.syadow.syadow --android-package-name=com.syadow.syadow --yes`
   - ⚠️ 첫 시도 실패: `cannot load such file -- xcodeproj` → `gem install xcodeproj`로 해결
   - 성공 → `lib/firebase_options.dart` 생성
   - Firebase Console에 iOS/Android 앱 자동 등록됨

### 의존성 일괄 추가 (`flutter pub add`)
```yaml
firebase_core: ^4.11.0
firebase_auth: ^6.5.3
cloud_firestore: ^6.6.0
firebase_storage: ^13.4.3
firebase_messaging: ^16.4.0
flutter_riverpod: ^3.3.2
go_router: ^17.3.0
shared_preferences: ^2.5.5
intl: ^0.20.2
http: ^1.6.0
fl_chart: ^1.2.0
```

### 작성한 코드
- [lib/main.dart](lib/main.dart) — `WidgetsFlutterBinding.ensureInitialized()` → `Firebase.initializeApp()` → `ProviderScope` → `MaterialApp.router`
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart) — `routerProvider` (GoRouter Provider) + `_PlaceholderHome` (스모크 테스트용)
- [test/widget_test.dart](test/widget_test.dart) — 기본 카운터 테스트 제거, 라우터 placeholder 렌더 스모크 테스트로 교체
- [analysis_options.yaml](analysis_options.yaml) — `build/**`, `ios/Pods/**`, `*.g.dart`, `*.freezed.dart` 분석 제외

### 트러블슈팅 기록

#### 1. xcodeproj gem 누락
- 증상: `flutterfire configure` 실행 시 `cannot load such file -- xcodeproj`
- 원인: brew Ruby 4.0.5 환경에 xcodeproj gem 미설치
- 해결: `gem install xcodeproj` (sudo 불필요, brew Ruby라서)

#### 2. iOS deployment target 13.0 → 15.0
- 증상: `Target Integrity (Xcode): The package product 'firebase-core' requires minimum platform version 15.0 for the iOS platform, but this target supports 13.0`
- 원인: Flutter 기본 iOS 최소 버전 13.0, Firebase 6.x는 iOS 15.0+ 요구
- 해결: `ios/Runner.xcodeproj/project.pbxproj` 3곳의 `IPHONEOS_DEPLOYMENT_TARGET = 13.0;` → `15.0;`
  ```bash
  sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 13.0;/IPHONEOS_DEPLOYMENT_TARGET = 15.0;/g' ios/Runner.xcodeproj/project.pbxproj
  ```

#### 3. flutter analyze가 build/SourcePackages 안의 패키지 테스트까지 스캔 (711개 오류)
- 원인: Flutter 3.44는 iOS 플러그인을 Swift Package Manager로 받는데, 다운받은 패키지의 test/ 폴더도 분석함
- 해결: `analysis_options.yaml`에 `exclude: [build/**, ios/Pods/**]` 추가

#### 4. APS entitlement 경고 (무시)
- 증상: 실행 시 `유효한 'aps-environment' 인타이틀먼트 문자열을 찾을 수 없습니다`
- 원인: `firebase_messaging` 추가했지만 푸시 알림 entitlement 미설정
- 대응: Phase 11에서 푸시 알림 셋업할 때 같이 처리. **현재는 무시 OK** (앱 크래시 X)

### 검증 결과
- ✅ `flutter analyze` → No issues found
- ✅ `flutter build ios --simulator --debug` → 47.6초만에 빌드 성공
- ✅ `xcrun simctl launch` → 앱 정상 실행 (Firebase 초기화 에러 없음)
- ✅ iPhone 17 시뮬레이터에서 `SYADOW` AppBar + "Phase 2 ready" 메시지 렌더 확인

### 다음 (Phase 3 — 디자인 토큰)
1. `assets/fonts/`에 Orbitron, Pretendard ttf 추가
2. `pubspec.yaml` flutter.fonts 등록
3. `lib/core/theme/` 안에:
   - `app_colors.dart` — 웹 `syadow-ui.css` 색 변수 포팅
   - `app_text_styles.dart` — Orbitron(브랜드) + Pretendard(본문) TextStyle
   - `app_theme.dart` — 다크 + 글래스모피즘 `ThemeData`
4. `main.dart`의 임시 deepPurple seed → `app_theme.dart`의 정식 테마로 교체

---

## 2026-06-25 — Phase 3 완료 🎉 (디자인 토큰)

### 결정 사항
- **폰트 로딩 방식**: `google_fonts` 패키지 (런타임 다운로드/캐시)
  - 이유: Orbitron ttf를 직접 받아서 `assets/fonts/`에 넣을 필요 없음, 사용자 손댈 게 없음
  - 트레이드오프: 첫 실행 시 인터넷 필요 (이후 캐시)

### 추가 의존성
```bash
flutter pub add google_fonts  # → google_fonts 8.1.0
```

### 작성한 코드
- [lib/core/theme/app_colors.dart](lib/core/theme/app_colors.dart) — 웹 `syadow-ui.css` 색 토큰을 Dart 상수로 포팅
  - Base: `midnight`, `bg0`
  - Surfaces: `gun1`, `gun2`
  - Accents: `rose1`, `rose2`
  - Text: `text`, `muted`
  - Glass: `glassFill` (white 10%), `glassStroke` (white 20%)
  - Roles: `rolePlayer`(rose1), `roleCoach`(blue), `roleFitter`(teal), `roleTrainer`(orange) — 캘린더 다트 색
- [lib/core/theme/app_text_styles.dart](lib/core/theme/app_text_styles.dart) — Orbitron(브랜드) + 시스템 폰트(본문)
  - `AppTextStyles.brand()` — Orbitron 900, 워드마크용
  - `AppTextStyles.sectionTitle()` — Orbitron 700, 섹션 타이틀
  - `AppTextStyles.textTheme` — Material `TextTheme` (본문은 시스템 폰트)
- [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) — 다크 `ThemeData` 통합
  - `AppTheme.dark` — Material3 다크, rose1 primary, gun1 surface
  - `appBarTheme` — midnight 60% 반투명, Orbitron 타이틀
  - `elevatedButtonTheme`, `inputDecorationTheme`, `cardTheme` 통일
  - `GlassCard` 위젯 — `BackdropFilter` 18px blur + glass border 헬퍼
- [lib/main.dart](lib/main.dart) — 임시 `ColorScheme.fromSeed(deepPurple)` → `AppTheme.dark`
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart) — Placeholder를 디자인 토큰 데모로 교체 (브랜드 폰트, GlassCard, 4개 역할 칩, 그라데이션 배경)

### 트러블슈팅 기록

#### 1. `CupertinoPageTransitionsBuilder` 미정의
- 증상: app_theme.dart 컴파일 에러 — `The method 'CupertinoPageTransitionsBuilder' isn't defined`
- 원인: `package:flutter/cupertino.dart` import 누락
- 해결: cupertino import 추가

#### 2. `objective_c.dylib` 경고 (무시)
- 증상: 빌드 시 `Code asset "package:objective_c/objective_c.dylib" has different framework names for different architectures`
- 원인: `google_fonts` → `path_provider` 의존성 체인의 objective_c 패키지 이슈
- 대응: **무시 OK** (빌드 성공, 런타임 문제 없음)

### 검증 결과
- ✅ `flutter analyze` → No issues found (1.1s)
- ✅ `flutter build ios --simulator --debug` → 22.4초 빌드 성공
- ✅ iPhone 17 시뮬레이터에서 다크 배경 + Orbitron "SYADOW" 워드마크 + GlassCard + 4개 역할 칩 렌더 확인

### 다음 (Phase 4 — 인증 화면)
1. `lib/features/auth/` 안에:
   - `presentation/login_screen.dart` — 이메일/비밀번호 로그인
   - `presentation/signup_screen.dart` — 이메일/비밀번호 회원가입 + 역할 선택 (Player/Coach/Fitter/Trainer)
   - `data/auth_repository.dart` — Firebase Auth 래퍼
   - `application/auth_providers.dart` — `authStateProvider` (StreamProvider)
2. `app_router.dart`에 `/login`, `/signup`, `/` (auth-aware redirect) 라우트 추가
3. Firebase Console에서 Auth → Email/Password 활성화 확인 (웹과 공유 중이라 이미 활성화돼있을 가능성 큼)
4. 웹 로그인 화면 디자인 참조: [haru-syadow-platform/pages/login.html](../../haru-syadow-platform/pages/login.html)

---

## 2026-06-25 (오후) — Player Home + 앱 아이콘 + i18n + Phase 4 인증 완료 🎉

> 한 날에 Phase 3 → 5 mockup → 4 까지 진행. 사용자 요청 따라 우선순위 재배치 (UI 먼저 보고 싶다 → Auth 실 연동 마지막).

### 1. Player Home 화면 mockup (Phase 5 일부)
**의도**: Phase 4 가기 전에 "앱이 어떻게 생겼는지" 먼저 확인하고 싶다는 요청

작성:
- [lib/shared/widgets/sparkline.dart](lib/shared/widgets/sparkline.dart) — CustomPainter 기반 스파크라인 + `GradientProgressBar`
- [lib/shared/widgets/metric_card.dart](lib/shared/widgets/metric_card.dart) — 큰 숫자 + 스파크라인 카드
- [lib/shared/widgets/gradient_border_card.dart](lib/shared/widgets/gradient_border_card.dart) — 네온 그라데이션 보더 카드 (AI 제안용)
- [lib/shared/widgets/bottom_nav.dart](lib/shared/widgets/bottom_nav.dart) — `SyadowBottomNav` 글래스 플로팅 바, 골드 액티브 pill, 5개 아이템
- [lib/features/player/presentation/player_home_screen.dart](lib/features/player/presentation/player_home_screen.dart) — 골프 메트릭 데모
  - Header: 오늘 날짜 + 아바타 (→ 나중에 로그아웃 메뉴 부착)
  - SuggestionCard: 네온 보더 AI 제안
  - MetricsGrid 2x2: 최근 스코어 -2 / 핸디캡 12.4 / 드라이빙 245y / GIR 64%
  - RoundCard: Pro 배지 + 그라데이션 진행바 + 총타수/페어웨이/퍼팅
  - CoachCommentCard

⚠️ **앱이 야구 → 골프임을 확정**. 메트릭과 아이콘 모두 골프 기준.

### 2. 앱 아이콘 디자인 (사용자 다회 피드백)
**최종 디자인**: midnight 그라데이션 배경 + 메탈릭 골드 S 로고 (보더 없음, 풀블리드)

작성:
- [tools/build_icon.sh](tools/build_icon.sh) — SVG → librsvg(rsvg-convert)로 1024x1024 PNG 생성
  - SIZE=1024, LOGO_W_PCT=58
  - 배경: 풀블리드 vertical gradient `#1A2342` → `#0B132B` → `#050813`
  - 상단 광택: white 10% → transparent
  - S 로고: metallic gold gradient `#8B6B4A` → `#D4A373` → `#F4D29F` → `#D4A373`
- [assets/icon/source_s.svg](assets/icon/source_s.svg) — S 단독 SVG
- [assets/icon/app_icon.png](assets/icon/app_icon.png) — 최종 1024x1024 PNG
- `pubspec.yaml`에 `flutter_launcher_icons` dev_dep + 설정 추가 (adaptive icon background `#0B132B`)
- `dart run flutter_launcher_icons` → iOS/Android 전 사이즈 자동 생성

### 트러블슈팅 — 아이콘
1. **Python Pillow 부재** → ImageMagick (`brew install imagemagick librsvg`)로 전환
2. **ImageMagick 둥근사각형 모서리 미세 어긋남** → SVG 템플릿 + rsvg-convert로 quarter-circle arc 정확도 확보
3. **시뮬레이터에서 아이콘 흰 테두리** → `remove_alpha_ios: true`가 SVG 둥근 모서리 바깥 투명을 흰색으로 채움 → SVG 배경을 **풀블리드 사각형**으로 변경, iOS 자동 squircle 마스크에 위임
4. **아이콘 캐시** → `xcrun simctl uninstall booted` 후 재설치 필수

### 3. i18n 인프라 (영어 메인, 일본어/한국어 + Auto)
**정책**: 처음 진입 시 OS 언어를 자동 따름. 지원: 영어/일본어/한국어 3개. 지원 외 → 영어 폴백. 로그인 화면 토글 없음 (Whoop/Spotify 등 글로벌 앱 표준).

작성:
- [l10n.yaml](l10n.yaml) — `flutter gen-l10n` 설정
- [lib/l10n/app_en.arb](lib/l10n/app_en.arb), [app_ja.arb](lib/l10n/app_ja.arb), [app_ko.arb](lib/l10n/app_ko.arb)
- [lib/l10n/app_localizations.dart](lib/l10n/app_localizations.dart) — 자동 생성됨 (gen-l10n)
- [lib/core/i18n/locale_provider.dart](lib/core/i18n/locale_provider.dart) — `LocaleNotifier` (Riverpod), `null = OS 따름`, `supportedLocales = [en, ja, ko]` (첫 번째가 폴백)
- [lib/main.dart](lib/main.dart) — `locale` + `AppLocalizations.delegate` 연결, `initializeDateFormatting()` 전 locale 로드 (`'ko_KR'` 하드코딩 제거)
- `pubspec.yaml` `flutter: generate: true`

### 트러블슈팅 — i18n
1. **UX 결정 4번 뒤집힘** (Auto 기본 → 영어 기본 + 토글 → 토글 제거) → 최종: OS 따름이 기본, 토글 없음, 설정 화면에서만 변경 (설정 화면은 추후)
2. **`flutter gen-l10n` 수동 실행 거부** → `Because l10n.yaml exists, the options defined there will be used instead` → `flutter pub get` 만 돌리면 자동 재생성됨

### 4. Phase 4 — Firebase Auth 실 연동 ✅
**결과**: 이메일/비밀번호 로그인·가입 → 자동 라우팅, 다국어 에러, 로그아웃까지 동작

작성:
- [lib/features/auth/domain/user_role.dart](lib/features/auth/domain/user_role.dart) — `UserRole` enum (player/coach/fitter/trainer) + label/desc i18n + `fromName()` Firestore 역직렬화
- [lib/shared/services/auth_service.dart](lib/shared/services/auth_service.dart) — `signIn`, `signUp`(Auth + Firestore `users/{uid}` doc 생성 + displayName), `signOut`, `authStateChanges`
- [lib/features/auth/application/auth_providers.dart](lib/features/auth/application/auth_providers.dart) — `authServiceProvider` + `authStateProvider` (StreamProvider<User?>)
- [lib/core/utils/auth_errors.dart](lib/core/utils/auth_errors.dart) — `FirebaseAuthException.code` → 다국어 메시지 매핑
- [lib/features/auth/presentation/login_screen.dart](lib/features/auth/presentation/login_screen.dart) — `ConsumerStatefulWidget`, 실제 `signIn`, 에러 시 SnackBar
- [lib/features/auth/presentation/signup_screen.dart](lib/features/auth/presentation/signup_screen.dart) — `ConsumerStatefulWidget`, 실제 `signUp`, 역할 카드 그리드 (2x2)
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart) — `redirect`로 auth-aware 라우팅 (`!loggedIn && !atAuth → /login`, `loggedIn && atAuth → /home`) + `_AuthRefresh ChangeNotifier`로 `authStateProvider` 변화 시 GoRouter 재평가
- [lib/features/player/presentation/player_home_screen.dart](lib/features/player/presentation/player_home_screen.dart) `_Header` → `ConsumerWidget`, 아바타 `PopupMenuButton`으로 로그아웃 메뉴 추가

### Firebase Console 사전 설정 (테스트 전 필수)
1. **Authentication** → Sign-in method → **Email/Password 활성화**
2. **Firestore Database** Rules:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{db}/documents {
       match /users/{uid} {
         allow read, write: if request.auth != null && request.auth.uid == uid;
       }
     }
   }
   ```

### 검증 결과
- ✅ `flutter analyze` → No issues
- ✅ iPhone 17 시뮬레이터 빌드 + 실행 성공 (15.3s)
- ✅ 라우터 redirect 정상 동작 (로그아웃 시 자동 /login)
- ⏳ 실제 가입/로그인 — Firebase Console 설정 후 사용자 직접 테스트 예정

### 미완료 / 알려진 이슈
- **Firebase Console 설정** (Auth 활성화 + Firestore rules) — 사용자가 직접 진행
- **Locale 영구 저장 안 함** — 앱 재시작 시 항상 OS 언어로 돌아감. 설정 화면 만들 때 `shared_preferences`로 저장 추가 예정
- **Auth 화면 i18n에 일본어 미적용 부분 0개 확인됨** — 모든 키 3언어 모두 채워짐
- **`flutter_launcher_icons` adaptive_icon_foreground**가 풀블리드 아이콘과 동일 — 안드로이드 일부 런처에서 S 로고가 너무 작게 보일 수 있음. 출시 전 별도 foreground SVG 제작 권장

---

## 2026-06-26 — Git 저장소 초기화 + GitHub 연결 완료 🎉

### 결과
- ✅ `git init -b main` → 로컬 저장소 생성
- ✅ 첫 커밋: `"Initial commit: Phase 0-4 complete (Firebase auth, i18n, home mockup, app icon)"` (132 파일)
- ✅ Remote: **`https://github.com/syadowplatform/syadow-app.git`** (Private)
- ✅ `git push -u origin main` 성공 → `main` 트래킹 설정됨
- ✅ GitHub Org: `syadowplatform` (기존 계정에 신규 private repo)

### `.gitignore` 보강 내역
Flutter 3.44 기본 `.gitignore`에 누락된 표준 항목 추가:
- `android/local.properties` — **로컬 SDK 경로 (`/opt/homebrew/share/flutter`) 누출 방지 핵심**
- `android/.gradle/`, `android/captures/`, `android/key.properties`
- `ios/Pods/`, `ios/.symlinks/`, `ios/Flutter/Generated.xcconfig` (로컬 경로 포함됨)
- `ios/Flutter/ephemeral/`, `flutter_export_environment.sh`
- `ios/Flutter/App.framework`, `Flutter.framework`, `Flutter.podspec`
- `**/GeneratedPluginRegistrant.*`, `**/Pods/`, `.DS_Store`

### 커밋된 민감/공개 파일 정책
- ✅ **커밋함** (Private repo이므로 OK):
  - `lib/firebase_options.dart` — Firebase 식별자 (어차피 클라이언트 노출됨)
  - `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` — 동일 사유
- 🚫 **커밋 안 함**:
  - 머신별 로컬 경로 파일 (`local.properties`, `Generated.xcconfig`)
  - 빌드 산출물 (`build/`, `.dart_tool/`, `Pods/`)
  - IDE 메타 (`.idea/`, `*.iml`)

### 일상 사용 흐름 (앞으로)
```bash
git add .
git commit -m "메시지"
git push
```

### 트러블슈팅
- 없음. SSH 키 이슈 회피 차원에서 HTTPS URL 사용. 추후 push 시 자격증명 만료되면 GitHub PAT(개인 액세스 토큰) 또는 SSH 키로 전환 권장.

---

## 2026-06-26 (오후) — 웹 Firestore 스키마 동기화 + iOS 빌드 재정비 🎉

> "결국 웹 사용자가 앱으로 옮겨올 거니까 처음부터 같은 Firebase 공유" 라는 사용자 결정에 따라, 앱의 가입 로직을 웹 스키마에 100% 맞춤.

### 1. 발견 — 웹 Firestore Rules가 `sy_code` 강제
사용자가 Firebase Console에서 복사해준 기존 Rules 분석 결과:
- `users/{userId}` create 시 **`sy_code` 필드 필수**, 패턴 `^SY-[PCF]-[0-9A-Z]{6}$` 매칭 강제
- `sy_code`는 immutable (update 시 변경 불가)
- 인증된 사용자는 다른 유저 프로필을 read 가능 (Connection 화면용)
- 추가로 `connection_requests`, `accepted_connections`, `coach_lessons`, `player_rounds`, `fitter_club_setups`, `trial_history` 등 도메인별 정밀 rule 다수

**문제**: 앱의 [auth_service.dart](lib/shared/services/auth_service.dart)는 `{email, name, role, createdAt}` 만 썼음 → `sy_code` 없어서 가입 시 PERMISSION_DENIED 발생할 상태.

### 2. 웹 가입 로직 분석
[~/haru-syadow-platform/pages/signup.js](/Users/harumoon/haru-syadow-platform/pages/signup.js) 의 `roleToPrefix` + `randomSix` + Firestore write 로직 정독:
- sy_code 생성: `"SY-" + (P|C|F) + 6자리 랜덤(0-9A-Z)`
- `Math.random()` 사용, 중복체크 없음 (충돌 확률 21억분의 1)
- 풀 user doc 스키마: `{uid, role, email, sy_code, profileCompleted, profile{firstName,lastName,fullName,playingName,birth,country,gender,phone,phoneCountryCode,phoneNumber}, lang, consents, trial, createdAt}`

### 3. 작성/수정한 코드
- [lib/shared/utils/sy_code.dart](lib/shared/utils/sy_code.dart) **신규** — 웹 `roleToPrefix` + `randomSix` 그대로 Dart 이식
  - `SyCode.prefix(UserRole)` → `P`/`C`/`F`/`T` (Trainer는 `T`)
  - `SyCode.generate(UserRole)` → `SY-X-XXXXXX`
- [lib/shared/services/auth_service.dart](lib/shared/services/auth_service.dart) — `signUp`을 웹 호환 스키마로 변경
  - `uid`, `sy_code`, `profileCompleted: false`, `profile{}` (minimal, 빈 문자열), `lang: 'en'`, `createdAt` (ISO 문자열)
  - 앱이 birth/country/phone/gender를 아직 안 받으므로 profile 필드는 빈값 + `fullName`만 채움
  - `trial`, `consents`는 일단 생략 (앱은 동의 화면 아직 없음, 프로필 완성 화면에서 채울 예정)
  - Firestore 저장 시 `request.auth.uid == userId` 만 확인하므로 안전

### 4. iOS 빌드 재발생 이슈 — Package.swift platform mismatch
- 증상: `flutter run` 시
  > Target Integrity (Xcode): The package product 'cloud-firestore' requires minimum platform version 15.0 for the iOS platform, but this target supports 13.0
- Phase 2에서 `project.pbxproj`의 `IPHONEOS_DEPLOYMENT_TARGET = 15.0`은 그대로 유지돼있었음 (3곳 모두)
- 진짜 원인: [ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift](ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift) 가 **자동 생성될 때 `.iOS("13.0")` 으로 하드코딩됨**
- Flutter 3.44 알려진 이슈 — SPM 플러그인 통합 Package에서 platform을 pbxproj 값과 동기화 못 함
- **해결**: Package.swift의 `.iOS("13.0")` → `.iOS("15.0")` 직접 편집
- ⚠️ 주의: 이 파일은 `flutter pub get` 또는 `flutter clean` 후 재생성됨. 다음 세션에서 `Package.swift` 다시 13.0으로 돌아갔으면 재수정 필요. 영구 해결은 Flutter 3.45+ 업데이트 또는 [project.pbxproj](ios/Runner.xcodeproj/project.pbxproj)에 SPM platform override 추가.

### 5. 검증 결과
- ✅ `flutter analyze` → No issues found
- ✅ `flutter run -d <iPhone17>` → 31.8초 빌드 성공
- ✅ Dart VM Service 연결, 앱 시뮬레이터 실행 중
- ⚠️ `Plugin FLTFirebaseAuthPlugin uses deprecated UIScene lifecycle` 경고 — 무시 OK (Firebase 플러그인 업데이트 시 자동 해결)
- ⏳ **실제 가입 → 로그인 → 로그아웃 검증 미완** (다음 세션)

### 6. Git 작업
- 커밋 1: `feat(auth): generate sy_code on signup to match web Firestore schema` → push 완료
- Package.swift 변경분은 의도적으로 미커밋 (ephemeral 디렉토리, .gitignore에 들어있음)

---

---

## 2026-06-28 — Phase 4 완전 종료 🎉 (Trainer 지원 추가 + 가입 흐름 실 검증)

### 1. Firestore Rules에 Trainer (`T`) 패턴 추가
**배경**: 웹은 P/C/F만 사용하지만 Trainer는 앱부터 시작이 정책 (워킹노트 정책 그대로). Rules는 프로젝트당 1개라서 웹/앱 공유 — 추가해도 웹에 영향 없음.

수정 파일: [~/haru-syadow-platform/firestore.rules](../../haru-syadow-platform/firestore.rules) — `[PCF]` → `[PCFT]` **4곳**:
- line 11: `users/create` — `sy_code`
- line 34: `connection_requests/create` — `targetSyCode`
- line 78: `accepted_connections/create` — `requesterSyCode`
- line 79: `accepted_connections/create` — `targetSyCode`

⚠️ 워킹노트 원래 "3곳"이라 했는데 실제 4곳. accepted_connections에 2번 들어있음.

배포:
```bash
cd ~/haru-syadow-platform && firebase deploy --only firestore:rules
# → ✔ released rules firestore.rules to cloud.firestore
```
웹 레포에 커밋 `feat(rules): allow Trainer (T) sy_code pattern for app` push 완료.

### 2. Package.swift 13.0 회귀 재발 (예고된 이슈)
**증상**: `flutter run` 시 `Missing package product 'cloud-firestore'` 외 7개 — SPM 패키지 해결 실패

**원인 진단**:
- `ios/Flutter/ephemeral/.packages/` 디렉토리 자체가 없음 (Flutter 빌드 시점에 생성됨)
- `ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift`가 `.iOS("13.0")`으로 다시 생성됨 (지난 세션에서 15.0으로 패치한 게 회귀)

**해결 절차** (다음에도 동일하게 적용):
```bash
cd ~/syadow-app/syadow
flutter clean && flutter pub get   # ephemeral 재생성
sed -i '' 's/.iOS("13.0")/.iOS("15.0")/g' ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift
flutter build ios --simulator --debug   # 48초 소요, .packages 생성됨
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted com.syadow.syadow
```

⚠️ **`flutter run`을 바로 쓰면 Package.swift가 13.0 상태로 빌드 시도 → 실패**. 반드시 pub get → sed → build ios 순서.

### 3. Trainer 가입 실 검증 ✅
- `apptest_trainer@syadow.com` / `test1234` / **Trainer** 역할로 가입
- Firebase Console:
  - Authentication → Users에 계정 생성 확인
  - Firestore `users/{uid}`에 `sy_code: "SY-T-XXXXXX"` 확인
- 로그아웃 → 재로그인 → Home 진입 흐름 정상

### 4. 미정리 (사용자 직접 진행)
- **테스트 계정 정리**: Firebase Console → Authentication → Users에서 `apptest_*` 계정 삭제 권장 (놔둬도 무방)

### 다음 (Phase 5 — Player Home Firestore 연결)
1. `lib/features/player/data/` 폴더 생성
2. `currentUserProvider` (현재 로그인 user + `sy_code` 노출) 추가
3. Firestore `player_rounds/`, `calendar_events/` 스트림 `StreamProvider`로 연결
4. Player Home mockup의 하드코딩 데이터를 실데이터로 교체

---

## 2026-06-28 (오후) — Splash 화면 + SVG 워드마크 도입 🎨

> "앱 들어가면 SYADOW가 떠 있는 로딩 화면이 있으면 좋겠다" 요청에서 출발해, 스플래시 디자인과 진짜 워드마크 SVG 적용까지.

### 1. flutter_svg 패키지 + 에셋 등록
- `flutter pub add flutter_svg` → flutter_svg 2.x (+ vector_graphics 등)
- [pubspec.yaml](pubspec.yaml)에 `flutter.assets: - assets/icon/` 추가

### 2. 진짜 SYADOW 워드마크 SVG 발견 및 채택
**기존 문제**: 모든 SYADOW 표시가 Orbitron 폰트 텍스트로 그려지고 있었음. 사용자가 직접 디자인한 진짜 워드마크가 따로 있음.
- 정본: [assets/icon/source_wordmark.svg](assets/icon/source_wordmark.svg) (path 기반, viewBox 397.63×69.29, fill `#D4A373`)
- 웹 레포에도 동일 파일 존재: `~/haru-syadow-platform/assets/SYADOW.svg`

### 3. SplashScreen 신규 작성
파일: [lib/features/auth/presentation/splash_screen.dart](lib/features/auth/presentation/splash_screen.dart)

**디자인 결정 (사용자 지시 → 반영)**:
- 배경: `#050813` (가장 짙은 남색, `AppColors.bg0`)
- 워드마크: SVG 사용 (가로 260px)
- **shimmer reveal 효과**: 골드 빛이 좌→우로 1회 가로지르며 글자가 "차곡차곡" 켜짐
  - 빛이 지나간 부분 = 베이스 골드 `#D4A373`로 유지
  - 빛 정점 = `#FFE9C8` (밝은 골드 하이라이트)
  - 아직 안 닿은 부분 = 배경색에 묻힘
- shimmer 종료 후 hold 구간 (~0.7s) 동안 풀 워드마크 유지 → 다음 화면 전환

**구현 포인트**:
- `AnimationController.forward()` 1회만 (repeat 안 함)
- `LinearGradient` stops를 `t-halfBand / t / t+halfBand`로 동적 계산
- `ShaderMask(blendMode: srcIn)` + `SvgPicture.asset` 조합 — SVG path가 마스크 모양으로 잘려서 그라데이션이 입혀짐
- SVG는 `colorFilter: ColorFilter.mode(Colors.white, srcIn)`으로 색을 흰색으로 강제

**조정 가능한 상수** (파일 상단):
```dart
static const Duration _splashDuration = Duration(milliseconds: 2200);  // 전체 노출
static const Duration _shimmerDuration = Duration(milliseconds: 1500); // 빛 통과 시간
static const double _wordmarkWidth = 260;
const halfBand = 0.08;  // 빛 좌우 폭
```

**Auth-aware 분기**:
- `Future.wait([Future.delayed(_splashDuration), ref.read(authStateProvider.future)])`
- 둘 다 끝나면 user 유무에 따라 `/home` 또는 `/login`으로 `context.go`

### 4. 라우터 수정
[lib/core/router/app_router.dart](lib/core/router/app_router.dart):
- `initialLocation: '/login'` → `'/'`
- `GoRoute('/', SplashScreen)` 추가
- redirect 첫 줄에 `if (loc == '/') return null;` — splash는 자체 분기

### 5. 로그인 화면 _Logo 위젯 SVG 교체
[lib/features/auth/presentation/login_screen.dart](lib/features/auth/presentation/login_screen.dart):
- Orbitron 텍스트 "SYADOW" → `SvgPicture.asset(width: 240)` + 동일 그라데이션(`#8B6B4A → rose1 → #F4D29F`) ShaderMask
- `app_text_styles.dart` import 제거 (더 이상 미사용)

### 6. iOS 빌드 — Package.swift 13.0 회귀 패치
또 재발. 워킹노트의 워크어라운드 그대로 적용:
```bash
sed -i '' 's/.iOS("13.0")/.iOS("15.0")/g' ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift
flutter build ios --simulator --debug
xcrun simctl uninstall booted com.syadow.syadow
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted com.syadow.syadow
```

### 7. 검증
- ✅ 시뮬레이터에서 splash → 로그인 화면 전환 시각 확인
- ✅ shimmer 1회 통과 + hold + 자동 분기 정상
- ✅ 로그인 화면의 워드마크가 진짜 SVG로 표시됨

### 트러블슈팅 기록 — 디자인 협업 흐름
- 초기에 디자인 듣기 전 임의로 splash를 만들었다가 사용자가 "직접 지시할게"라고 함 → 변경분 5개 파일 `git checkout`으로 원복 후 처음부터 재진행.
- **교훈**: 디자인 요청은 사용자 지시를 끝까지 듣고 시작. 임의 구현 X.

---

## 2026-07-01 — 브랜드 톤 전환 (검정+골드) + Welcome 화면 🎨

> "스플래시가 검정+골드라 훨씬 차분·고급스러워 보인다"는 관찰에서 시작 → 앱 전체 톤을 검정+골드로 통일 → 로그인 진입 화면을 Netflix/Airbnb 스타일 풀블리드 Welcome으로 재구성.

### 1. 컬러 토큰 검정+골드 전환
[lib/core/theme/app_colors.dart](lib/core/theme/app_colors.dart) — 골드(rose1/rose2), text, glass, role accents 유지. 어두운 뉴트럴 톤으로 재조정:
- `midnight`: `#0B132B` → `#0D0D10`
- `bg0`: `#050813` → `#050505`
- `bg1`: `#0E1322` → `#101014`
- `gun1`: `#2C2F33` → `#16161A` (뉴트럴 다크)
- `gun2`: `#3A506B` → `#22222A`
- `cardFill`: `#CC0E1322` → `#CC101014` (bg1@80% 갱신)

배경 그라데이션(`bgGradient = midnight → bg0`)은 자동으로 새 톤 반영됨.

### 2. 앱 아이콘 재생성 (검정+골드)
- [tools/build_icon.sh](tools/build_icon.sh) — 배경 그라데이션 재정의:
  - `BG_TOP: #16161A` → `MIDNIGHT: #0D0D10` → `BG_BOTTOM: #050505` (위 살짝 밝고 아래 순검정)
  - 로고 메탈릭 골드 그라데이션은 유지
- [pubspec.yaml](pubspec.yaml) `adaptive_icon_background`: `#0B132B` → `#050505`
- 실행: `bash tools/build_icon.sh && dart run flutter_launcher_icons` → iOS/Android 전 사이즈 자동 재생성

### 3. Welcome 화면 신규 작성 (풀블리드 4분할)
파일: [lib/features/auth/presentation/welcome_screen.dart](lib/features/auth/presentation/welcome_screen.dart)

**구조** (Stack 오버레이):
1. **풀블리드 4분할 그리드** (edge-to-edge, 마진 없음)
   - 좌상: Golf(rolePlayer) / 우상: Coach(roleCoach)
   - 좌하: Fitter(roleFitter) / 우하: Trainer(roleTrainer)
   - 각 quadrant: 역할 색 tint 그라데이션 + 반대편 코너에 큰 배경 아이콘(투명 12%) + 바깥쪽 코너 라벨
   - **플레이스홀더 상태** — 사용자가 나중에 실사진 4장 주면 `DecoratedBox` → `Image.asset(fit: BoxFit.cover)`로 교체 예정
2. **Radial vignette** — 화면 가장자리 어둡게 (로고/버튼 가독성)
3. **중앙 SYADOW 골드 워드마크** — 4개 seam 정확히 정중앙, radial dark backdrop으로 이미지 위에서도 살아남
4. **하단 CTA 오버레이** — 아래로 갈수록 검정 그라데이션 + SafeArea + 버튼 2개
   - Primary: **"계정 만들기"** (골드 gradient + glow) → `/signup`
   - Secondary: **"이미 계정이 있어요"** (glass outlined) → `/login/email`

### 4. 라우터 개편
[lib/core/router/app_router.dart](lib/core/router/app_router.dart):
- `/login` → **WelcomeScreen** (신규)
- `/login/email` → **LoginScreen** (기존 이메일 폼, 재활용)
- `/signup` → SignupScreen (기존)
- `atAuth` 검사에 `/login/email` 추가
- redirect 로직 그대로 (loggedIn ↔ atAuth 스위칭)

### 5. i18n 신규 키 (en/ja/ko 3언어 동시)
- `welcomeIHaveAccount` — "이미 계정이 있어요" / "I already have an account" / "すでにアカウントをお持ちの方"
- `welcomeTileGolf` — "골프" / "Golf" / "ゴルフ"
- `welcomeTileCoach` — "코칭" / "Coaching" / "コーチング"
- `welcomeTileFitter` — "피팅" / "Fitting" / "フィッティング"
- `welcomeTileTrainer` — "트레이닝" / "Training" / "トレーニング"

### 6. Repo Memory 신규 (2개)
- `/memories/repo/web-app-parity.md` — 웹(`~/haru-syadow-platform`)↔앱 로직/구조 이식 원칙
  - 웹 페이지 참조, Firestore 스키마 공유, Rules 공유 주의(프로젝트당 1개 → 웹 레포에서 수정·배포), sy_code 이미 이식됨
- `/memories/repo/subscription-policy.md` — **Netflix 패턴**: 앱 내 결제 UI/버튼 없음
  - 결제는 웹에서만 (Lemon Squeezy), Apple IAP 미사용, "구독 필요" 안내만, Apple Guideline 3.1.1 회피, TestFlight 심사에서 검증

### 7. iOS 빌드 — Package.swift 13.0 회귀 재발 (매번 반복)
매 세션 반복되는 이슈. 워크어라운드:
```bash
sed -i '' 's/.iOS("13.0")/.iOS("15.0")/g' ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift
flutter build ios --simulator --debug
```

### 검증
- ✅ `flutter analyze` → No issues
- ✅ iOS 시뮬레이터 빌드 성공 (16.1s)
- ✅ 스플래시 → Welcome(검정 배경 + 4분할 + 중앙 골드 로고 + 하단 골드/glass 버튼) 정상 렌더
- ✅ "계정 만들기" → /signup, "이미 계정이 있어요" → /login/email 라우팅 정상
- ⏳ 실사진 4장 (Golf/Coaching/Fitting/Training) — 사용자가 나중에 제공, 오면 `_RoleQuadrant` 교체

### 결정 사항 (내일 회원가입 화면에 반영)
- **소셜 로그인 우선** (Apple + Google) — 웹처럼 이메일/비번을 primary로 두지 않음
- **Apple Guideline 4.8**: iOS에 Google 있으면 Apple Sign-In **필수**
- **2단계 온보딩**: Step 1 인증(소셜) → Step 2 SYADOW 프로필(역할 + 이름 최소만) → Home
- Firestore 스키마의 `profileCompleted` 필드 활용 (false → true 전환)
- 이메일/비번은 fallback으로 유지 (웹 유저 앱 로그인용), UI에서 작게만 노출

### 다음 (2026-07-02 — 회원가입 화면 재구성)
1. Firebase Console — Apple/Google Auth 프로바이더 활성화 (사용자 직접)
2. Apple Developer — Sign in with Apple capability 추가
3. `flutter pub add sign_in_with_apple google_sign_in`
4. `auth_service.dart`에 `signInWithApple` / `signInWithGoogle` 추가
5. Welcome 화면 하단 버튼 재구성 (Apple + Google + 이메일 텍스트 링크)
6. Step 2 프로필 화면 신규 — 역할 카드 4개 + 이름(pre-fill) + `sy_code` 생성 + `profileCompleted: true`
7. 기존 [signup_screen.dart](lib/features/auth/presentation/signup_screen.dart)는 이메일 가입 폼으로 축소 (또는 Step 2와 통합)

---

## 📋 다음 세션 시작 시 할 일 (Phase 5 — UI 일괄)

### 🔴 우선순위 1 — UI-first 전략으로 화면 일괄 작성
웹 [pages/](../../haru-syadow-platform/pages/) 의 HTML/JS 디자인을 참조해서 다음 화면들을 mock 데이터로 디자인 완성:

| 순서 | 화면 | 웹 참조 | 비고 |
|---|---|---|---|
| 1 | Player Home (Dashboard) | `pages/player.html` | 일부 mockup 이미 있음, 정리 필요 |
| 2 | Player Input (라운드 입력) | `pages/player-input.html` | |
| 3 | Player Stats | `pages/player-stats.html` | `fl_chart` 사용 |
| 4 | Player Chat (AI 분석) | `pages/player-chat.html` | UI만, 서버 호출은 Phase 7 |
| 5 | Coach Home + Input | `pages/coach.html`, `pages/coach-input.html` | |
| 6 | Fitter Home + Input | `pages/fitter.html`, `pages/fitter-input.html` | |
| 7 | Trainer Home + Input | (신규, Fitter 복사판 + 운동 메뉴) | 🆕 앱부터 시작 |
| 8 | Connections (연결 관리) | `pages/connections.html` | |
| 9 | Profile / Settings | `pages/profile.html`, `pages/settings.html` | locale 영구 저장도 여기서 |

### 🟡 우선순위 2 — 작업 규칙 (Phase 7 연결을 trivial하게 만들기 위함)
1. **모델 클래스 먼저**: 각 화면에서 쓰는 데이터는 반드시 Dart 모델 클래스 (`PlayerRound`, `CalendarEvent` 등)로 받음. 화면에 raw Map 하드코딩 X.
   - 모델은 처음부터 **실제 Firestore 스키마 그대로** 정의 (필드명/타입 동일)
   - 위치: `lib/features/{feature}/domain/{model}.dart`
2. **mockup 데이터 분리**: `lib/features/{feature}/data/mock_{xxx}_repository.dart`에 모음. 화면 안에 const list 하드코딩 X.
   - 인터페이스 (`abstract class XxxRepository`)를 먼저 정의해두면 Phase 7에서 `FirestoreXxxRepository`로 교체만 하면 됨
3. **공용 위젯 적극 추출**: 두 번째 화면 만들 때 반복되는 패턴은 즉시 `lib/shared/widgets/`로 빼기
4. **디자인 토큰만 사용**: `AppColors.*`, `AppTextStyles.*` 외 직접 hex/font 쓰지 말 것
5. **i18n 키 추가는 그때그때**: `app_en.arb` → 한국어/일본어 동시에 채움

### 🟢 우선순위 3 — 테스트 계정 정리 (선택, 사용자 직접)
Firebase Console → Authentication → Users에서 `apptest_*` 계정 삭제. 안 지워도 동작엔 영향 없음.

### 🟢 우선순위 4 — Package.swift 13.0 회귀 영구 해결 (선택)
임시 수정한 `Package.swift`가 `flutter clean`/`pub get` 후 재생성되며 13.0으로 회귀. 영구 해결 옵션:
1. **(권장)** Flutter 3.45+ 업그레이드 시 자동 해결 여부 확인
2. 빌드 pre-script로 자동 sed 변환 추가 (`ios/Podfile` post_install 또는 별도 스크립트)
3. Flutter SDK 내부 템플릿에 패치 (비추천 — SDK 업데이트 시 사라짐)

**임시 워크어라운드** (회귀 발생 시 반드시 이 순서):
```bash
cd ~/syadow-app/syadow
flutter clean && flutter pub get
sed -i '' 's/.iOS("13.0")/.iOS("15.0")/g' ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift
flutter build ios --simulator --debug
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted com.syadow.syadow
```
⚠️ `flutter run`을 바로 쓰면 13.0 상태로 빌드 시도 → 실패. 위 순서 엄수.

---

### 🟢 Phase 5 이후 — 화면 포팅 시작
- 로그인 → Dashboard → Player Input 순으로 단순한 것부터
- 웹 [pages/](../../haru-syadow-platform/pages/) 의 HTML/JS 로직을 Dart로 옮김
- Firestore 컬렉션 구조는 **그대로** (앱/웹 데이터 100% 호환 목표)

---

## ⚠️ 주의사항 / 결정 사항

### 절대 변경 X (이미 결정됨)
- ✅ 별도 레포 (`syadow-app`)
- ✅ Firebase 공유 (`syadow-pro`)
- ✅ Trainer V1 = Fitter 복사 + 운동
- ✅ Coach↔Trainer 연결, Trainer Stats = V2
- ✅ 카메라 V1 = 기본 녹화/업로드만, 슬로모션/AR = V2

### 결정됨 (2026-06-19)
- **상태관리: Riverpod 2.x** — 컴파일 타임 안전, Firebase 스트림 궁합 좋음 (`StreamProvider`)
- **라우팅: go_router** — 딥링크/푸시알림 핸들링에 필수 (Phase 11)
- **차트: fl_chart** — 무료/경량. syncfusion은 상업용 라이선스 비쌈

### 웹쪽 평행 작업 (이 앱과 별개로 진행 중)
- 🔴 사업자 등록증 정정 (사용자 외부 진행 중)
- 🔴 Lemon Squeezy 결제 연동 (사업자 정정 후)
- 🟡 로그인 후 `#plans` 섹션 숨김
- 🟢 Render Free → Starter $7/mo (D-1)

---

## 🔗 자주 쓰는 명령어 모음

```bash
# 위치 이동
cd ~/syadow-app/syadow

# 실행
flutter run                    # 디버그 빌드 + 시뮬레이터
flutter run --release          # 릴리즈 빌드 (느림)

# Hot reload/restart (앱 실행 중 터미널에서)
r       # Hot reload (1초)
R       # Hot restart (앱 처음부터)
q       # 종료

# 클린 / 재빌드
flutter clean
flutter pub get
cd ios && pod install && cd ..

# doctor
flutter doctor -v

# 디바이스 목록
flutter devices

# 빌드 (배포용)
flutter build ios              # iOS Archive
flutter build apk              # Android APK
flutter build appbundle        # Android AAB (스토어 배포용)
```

---

## 📞 참조 링크

- **웹 워킹노트**: `/Users/harumoon/haru-syadow-platform/WORKING_NOTE_2026-02-20.md`
- **웹 라이브**: https://syadow-pro.web.app
- **Flutter 공식 문서**: https://docs.flutter.dev/
- **FlutterFire 문서**: https://firebase.flutter.dev/
- **Firebase Console**: https://console.firebase.google.com/project/syadow-pro
