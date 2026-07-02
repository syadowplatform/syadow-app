import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/player/presentation/player_home_screen.dart';
import '../../features/player/presentation/round_input_holes_screen.dart';
import '../../features/player/presentation/round_input_meta_screen.dart';
import '../../features/player/presentation/round_input_summary_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // splash는 자체적으로 분기 처리하므로 redirect 통과.
      if (loc == '/') return null;

      final authAsync = ref.read(authStateProvider);
      // 인증 상태 로딩 중이면 그대로 둠.
      if (authAsync.isLoading) return null;
      final loggedIn = authAsync.value != null;
      final atAuth =
          loc == '/login' || loc == '/login/email' || loc == '/signup';

      if (!loggedIn && !atAuth) return '/login';
      if (loggedIn && atAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login/email',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const PlayerHomeScreen(),
      ),
      GoRoute(
        path: '/player/input/new',
        builder: (context, state) => const RoundInputMetaScreen(),
      ),
      GoRoute(
        path: '/player/input/holes',
        builder: (context, state) => const RoundInputHolesScreen(),
      ),
      GoRoute(
        path: '/player/input/summary',
        builder: (context, state) => const RoundInputSummaryScreen(),
      ),
    ],
  );
});

/// authStateProvider의 변화에 따라 GoRouter가 redirect를 재평가하도록 만드는 어댑터.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    _sub = ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
