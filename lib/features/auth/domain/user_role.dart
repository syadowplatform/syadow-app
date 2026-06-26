import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// 4가지 사용자 역할. Firestore에는 enum.name(=문자열) 저장.
enum UserRole {
  player(AppColors.rolePlayer, Icons.golf_course),
  coach(AppColors.roleCoach, Icons.school_outlined),
  fitter(AppColors.roleFitter, Icons.build_outlined),
  trainer(AppColors.roleTrainer, Icons.fitness_center);

  const UserRole(this.color, this.icon);
  final Color color;
  final IconData icon;

  String label(AppLocalizations t) => switch (this) {
    UserRole.player => t.rolePlayer,
    UserRole.coach => t.roleCoach,
    UserRole.fitter => t.roleFitter,
    UserRole.trainer => t.roleTrainer,
  };

  String desc(AppLocalizations t) => switch (this) {
    UserRole.player => t.rolePlayerDesc,
    UserRole.coach => t.roleCoachDesc,
    UserRole.fitter => t.roleFitterDesc,
    UserRole.trainer => t.roleTrainerDesc,
  };

  static UserRole fromName(String? name) =>
      UserRole.values.firstWhere((r) => r.name == name, orElse: () => player);
}
