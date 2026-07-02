import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/auth_errors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_providers.dart';

/// 진입 흐름 단계.
enum _Stage {
  /// 초기 — "계정 만들기 / 이미 계정 있어요" 두 CTA.
  initial,

  /// 가입/로그인 의도 확정 후 방식 선택 — Apple / Google / 이메일.
  authMethods,

  /// (로그인 흐름에서만) 이메일 폼 인라인.
  signinEmail,
}

enum _Mode { signUp, signIn }

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  _Stage _stage = _Stage.initial;
  _Mode? _mode;

  void _pickMode(_Mode m) => setState(() {
    _mode = m;
    _stage = _Stage.authMethods;
  });

  void _openSigninEmail() => setState(() => _stage = _Stage.signinEmail);

  void _back() {
    FocusScope.of(context).unfocus();
    setState(() {
      switch (_stage) {
        case _Stage.initial:
          break;
        case _Stage.authMethods:
          _stage = _Stage.initial;
          _mode = null;
        case _Stage.signinEmail:
          _stage = _Stage.authMethods;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isCompact = _stage != _Stage.initial;
    return Scaffold(
      backgroundColor: AppColors.bg0,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 4분할 풀블리드 배경
          const _FullBleedRoleGrid(),

          // 2. Vignette (진행 단계 깊어질수록 약간 어둡게)
          _Vignette(darker: isCompact),

          // 3. 중앙 로고 (진행 시 위로 살짝 이동)
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: isCompact
                  ? const Alignment(0, -0.55)
                  : Alignment.center,
              child: _CenterLogo(compact: isCompact),
            ),
          ),

          // 4. 하단 액션 영역 — 스테이지에 따라 morph.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActions(
              t: t,
              stage: _stage,
              mode: _mode,
              onSignUp: () => _pickMode(_Mode.signUp),
              onSignIn: () => _pickMode(_Mode.signIn),
              onOpenSigninEmail: _openSigninEmail,
              onBack: _back,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullBleedRoleGrid extends StatelessWidget {
  const _FullBleedRoleGrid();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _RoleQuadrant(
                  label: t.welcomeTileGolf,
                  icon: Icons.sports_golf,
                  color: AppColors.rolePlayer,
                  labelAlign: Alignment.topLeft,
                ),
              ),
              Expanded(
                child: _RoleQuadrant(
                  label: t.welcomeTileCoach,
                  icon: Icons.psychology_alt_outlined,
                  color: AppColors.roleCoach,
                  labelAlign: Alignment.topRight,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _RoleQuadrant(
                  label: t.welcomeTileFitter,
                  icon: Icons.tune_rounded,
                  color: AppColors.roleFitter,
                  labelAlign: Alignment.bottomLeft,
                ),
              ),
              Expanded(
                child: _RoleQuadrant(
                  label: t.welcomeTileTrainer,
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.roleTrainer,
                  labelAlign: Alignment.bottomRight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 플레이스홀더 quadrant. 나중에 `Image.asset(fit: BoxFit.cover)`로 교체.
class _RoleQuadrant extends StatelessWidget {
  const _RoleQuadrant({
    required this.label,
    required this.icon,
    required this.color,
    required this.labelAlign,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Alignment labelAlign;

  @override
  Widget build(BuildContext context) {
    // 배경 아이콘을 라벨 반대편 코너 쪽으로 밀어 사진 느낌 흉내
    final iconAlign = Alignment(-labelAlign.x * 0.7, -labelAlign.y * 0.7);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppColors.gun1, color, 0.35)!,
            AppColors.gun1,
            const Color(0xFF0A0A0D),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: iconAlign,
              child: Icon(
                icon,
                size: 140,
                color: color.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: labelAlign,
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette({this.darker = false});
  final bool darker;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              Colors.black.withValues(alpha: darker ? 0.35 : 0.0),
              Colors.black.withValues(alpha: darker ? 0.6 : 0.35),
              Colors.black.withValues(alpha: darker ? 0.85 : 0.65),
            ],
            stops: const [0.35, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

class _CenterLogo extends StatelessWidget {
  const _CenterLogo({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 170.0 : 220.0;
    final logoWidth = compact ? 140.0 : 170.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.bg0.withValues(alpha: 0.9),
            AppColors.bg0.withValues(alpha: 0.6),
            AppColors.bg0.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFF8B6B4A), AppColors.rose1, Color(0xFFF4D29F)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.srcIn,
          child: SvgPicture.asset(
            'assets/icon/source_wordmark.svg',
            width: logoWidth,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends ConsumerStatefulWidget {
  const _BottomActions({
    required this.t,
    required this.stage,
    required this.mode,
    required this.onSignUp,
    required this.onSignIn,
    required this.onOpenSigninEmail,
    required this.onBack,
  });
  final AppLocalizations t;
  final _Stage stage;
  final _Mode? mode;
  final VoidCallback onSignUp;
  final VoidCallback onSignIn;
  final VoidCallback onOpenSigninEmail;
  final VoidCallback onBack;

  @override
  ConsumerState<_BottomActions> createState() => _BottomActionsState();
}

class _BottomActionsState extends ConsumerState<_BottomActions> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _pwFocus = FocusNode();
  bool _obscure = true;
  bool _loading = false;

  @override
  void didUpdateWidget(covariant _BottomActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // signinEmail 스테이지 진입 시 이메일 필드 자동 포커스.
    if (oldWidget.stage != _Stage.signinEmail &&
        widget.stage == _Stage.signinEmail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _emailFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _emailFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _submitSignin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final t = widget.t;
    try {
      await ref
          .read(authServiceProvider)
          .signIn(email: _emailCtrl.text.trim(), password: _pwCtrl.text);
      // 성공 시 라우터 redirect가 /home으로.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapAuthError(e, t))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bg0.withValues(alpha: 0.0),
            AppColors.bg0.withValues(alpha: 0.75),
            AppColors.bg0.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 12),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: child,
                ),
              ),
              child: _content(widget.t),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(AppLocalizations t) {
    switch (widget.stage) {
      case _Stage.initial:
        return _initialView(t);
      case _Stage.authMethods:
        return _authMethodsView(t);
      case _Stage.signinEmail:
        return _signinEmailView(t);
    }
  }

  // ------------------------------
  // Stage 1: initial CTAs
  // ------------------------------
  Widget _initialView(AppLocalizations t) {
    return Column(
      key: const ValueKey('initial'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _GoldButton(label: '계정 만들기', onPressed: widget.onSignUp),
        const SizedBox(height: 10),
        _GlassButton(label: '이미 계정이 있어요', onPressed: widget.onSignIn),
      ],
    );
  }

  // ------------------------------
  // Stage 2: auth methods (Apple / Google / Email)
  // ------------------------------
  Widget _authMethodsView(AppLocalizations t) {
    final isSignUp = widget.mode == _Mode.signUp;
    final title = isSignUp ? '가입 방식 선택' : '로그인 방식 선택';
    final emailLabel = isSignUp ? '이메일로 가입' : '이메일로 로그인';
    return Column(
      key: ValueKey('methods-${widget.mode?.name}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _BackLink(onPressed: widget.onBack, label: '다른 선택으로'),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _AppleButton(
          label: t.continueWithApple,
          onPressed: () {
            // TODO: signInWithApple (Phase 6에서 배선)
          },
        ),
        const SizedBox(height: 10),
        _GoogleButton(
          label: t.continueWithGoogle,
          onPressed: () {
            // TODO: signInWithGoogle (Phase 6에서 배선)
          },
        ),
        const SizedBox(height: 14),
        _EmailTextLink(
          label: emailLabel,
          onPressed: () {
            if (isSignUp) {
              context.push('/signup');
            } else {
              widget.onOpenSigninEmail();
            }
          },
        ),
      ],
    );
  }

  // ------------------------------
  // Stage 3: signin email form (inline)
  // ------------------------------
  Widget _signinEmailView(AppLocalizations t) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('signinEmail'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackLink(
            onPressed: _loading ? null : widget.onBack,
            label: '다른 방법으로',
          ),
          const SizedBox(height: 8),
          const Text(
            '이메일로 로그인',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: t.email,
              prefixIcon: const Icon(
                Icons.mail_outline,
                color: AppColors.muted,
              ),
              filled: true,
              fillColor: AppColors.bg0.withValues(alpha: 0.6),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return t.validatorEmailRequired;
              if (!v.contains('@')) return t.validatorEmailInvalid;
              return null;
            },
            onFieldSubmitted: (_) => _pwFocus.requestFocus(),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _pwCtrl,
            focusNode: _pwFocus,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: t.password,
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.muted,
              ),
              filled: true,
              fillColor: AppColors.bg0.withValues(alpha: 0.6),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.muted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return t.validatorPasswordRequired;
              if (v.length < 6) return t.validatorPasswordTooShort;
              return null;
            },
            onFieldSubmitted: (_) => _submitSignin(),
          ),
          const SizedBox(height: 12),
          _GoldButton(
            label: _loading ? t.signingIn : t.signIn,
            onPressed: _loading ? null : _submitSignin,
          ),
        ],
      ),
    );
  }
}

/// 뒤로가기 링크 (좌상단, 소형).
class _BackLink extends StatelessWidget {
  const _BackLink({required this.onPressed, required this.label});
  final VoidCallback? onPressed;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.muted,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.chevron_left_rounded, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

/// 골드 그라데이션 primary 버튼 (계정 만들기 / 로그인 제출 등).
class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? const [Color(0xFFD4A373), Color(0xFFF4D29F)]
                : [AppColors.gun1, AppColors.gun2],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.rose1.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.midnight,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass 스타일 secondary 버튼 ("이미 계정 있어요").
class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassStroke),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GoogleGLogo(size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Google G 로고 플레이스홀더. 실제 SDK 배선 시 공식 SVG로 교체.
class _GoogleGLogo extends StatelessWidget {
  const _GoogleGLogo({this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFF4285F4), // blue
            Color(0xFF34A853), // green
            Color(0xFFFBBC05), // yellow
            Color(0xFFEA4335), // red
            Color(0xFF4285F4),
          ],
        ),
      ),
      child: Container(
        width: size - 6,
        height: size - 6,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Text(
          'G',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4285F4),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _EmailTextLink extends StatelessWidget {
  const _EmailTextLink({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.muted,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.muted,
        ),
      ),
    );
  }
}
