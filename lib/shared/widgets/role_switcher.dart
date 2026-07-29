import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';

/// Compact animated segmented control for switching between Find/Rent.
/// Rewritten from v1's glassmorphic version that mis-measured width using
/// `View.of(context).physicalSize`; this uses a LayoutBuilder so the sliding
/// thumb is always pixel-accurate, and it respects the theme + dark mode.
class RoleSwitcher extends StatelessWidget {
  const RoleSwitcher({
    super.key,
    required this.activeRole,
    required this.onChanged,
  });

  final String activeRole;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final isFind = activeRole == AppConstants.findRoomRole;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
        final width = maxW.clamp(240.0, 360.0);
        final thumbW = (width - 8) / 2;

        return Container(
          width: width,
          height: 56,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: AppDurations.base,
                curve: Curves.easeOutCubic,
                alignment: isFind ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: thumbW,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Row(
                children: [
                  _Segment(
                    label: 'Find',
                    icon: Icons.search_rounded,
                    selected: isFind,
                    onTap: () => _select(AppConstants.findRoomRole),
                  ),
                  _Segment(
                    label: 'Rent',
                    icon: Icons.add_home_outlined,
                    selected: !isFind,
                    onTap: () => _select(AppConstants.rentRoomRole),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _select(String role) {
    if (role == activeRole) return;
    HapticFeedback.selectionClick();
    onChanged(role);
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              style: context.text.labelLarge!.copyWith(color: fg),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}