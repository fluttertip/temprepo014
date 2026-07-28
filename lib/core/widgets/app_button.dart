import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

enum AppButtonVariant { filled, tonal, outlined, text }
enum AppButtonSize { small, medium, large }

/// The single button component for the whole app. Replaces v1's `CustomButton`
/// with variants, sizes, an inline loading spinner that preserves width (no
/// layout jump), and full theme integration (no hardcoded colors).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.expand = true,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool expand;
  final Color? foregroundColor;
  final Color? backgroundColor;

  double get _height => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => 48,
        AppButtonSize.large => 52,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = onPressed == null || isLoading;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(
                variant == AppButtonVariant.filled
                    ? scheme.onPrimary
                    : scheme.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppIconSize.sm + 2),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(expand ? double.infinity : 0, _height),
      ),
      backgroundColor: backgroundColor == null
          ? null
          : WidgetStatePropertyAll(backgroundColor),
      foregroundColor: foregroundColor == null
          ? null
          : WidgetStatePropertyAll(foregroundColor),
    );

    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: disabled ? null : onPressed, style: style, child: child),
      AppButtonVariant.tonal => FilledButton.tonal(
          onPressed: disabled ? null : onPressed, style: style, child: child),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: disabled ? null : onPressed, style: style, child: child),
      AppButtonVariant.text => TextButton(
          onPressed: disabled ? null : onPressed, style: style, child: child),
    };

    return Semantics(button: true, enabled: !disabled, label: label, child: button);
  }
}