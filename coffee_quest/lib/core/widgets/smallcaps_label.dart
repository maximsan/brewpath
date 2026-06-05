import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// IBM Plex Mono uppercase label used for screen breadcrumbs and section
/// dividers throughout onboarding. Matches the `.smallcaps` style in the
/// design bundle.
class SmallcapsLabel extends StatelessWidget {
  const SmallcapsLabel(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.smallcaps(
        color: color ?? AppColors.darkRoastInkMute,
      ),
    );
  }
}
