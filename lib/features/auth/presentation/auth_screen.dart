import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import 'auth_provider.dart';

/// v2 onboarding: brand-forward hero, animated value props, and a single clear
/// CTA. Adapts to light/dark and to wide screens (centered max-width column).
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.primary.withValues(alpha: 0.85),
              scheme.surface,
            ],
            stops: const [0, 0.35, 0.9],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    _Logo(color: scheme.onPrimary),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Find your next room',
                        style: context.text.displaySmall
                            ?.copyWith(color: scheme.onPrimary)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Browse verified rooms, book in a tap, or list your own space.',
                      style: context.text.bodyLarge?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.85)),
                    ),
                    const Spacer(),
                    const _ValueProps(),
                    const SizedBox(height: AppSpacing.xl),
                    _SignInCard(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.holiday_village_rounded, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('KothaKhoj',
              style: context.text.titleLarge?.copyWith(color: color)),
        ],
      );
}

class _ValueProps extends StatelessWidget {
  const _ValueProps();
  @override
  Widget build(BuildContext context) {
    final color = context.scheme.onPrimary;
    const items = [
      (Icons.verified_rounded, 'Verified listings'),
      (Icons.bolt_rounded, 'Instant booking'),
      (Icons.place_rounded, 'Local to KTM'),
    ];
    return Row(
      children: [
        for (final (icon, label) in items)
          Expanded(
            child: Column(
              children: [
                Icon(icon, color: color, size: AppIconSize.md),
                const SizedBox(height: AppSpacing.xs),
                Text(label,
                    textAlign: TextAlign.center,
                    style: context.text.labelSmall
                        ?.copyWith(color: color.withValues(alpha: 0.9))),
              ],
            ),
          ),
      ],
    );
  }
}

class _SignInCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final loading = auth.state == AuthState.loading;
        return Column(
          children: [
            Material(
              color: context.scheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AppButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                variant: AppButtonVariant.filled,
                isLoading: loading,
                backgroundColor: context.scheme.surface,
                foregroundColor: context.scheme.onSurface,
                onPressed: loading ? null : auth.signInWithGoogle,
              ),
            ),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              _ErrorBanner(message: auth.errorMessage!),
            ],
            const SizedBox(height: AppSpacing.md),
            Text('By continuing you agree to our Terms & Privacy Policy.',
                textAlign: TextAlign.center,
                style: context.text.labelSmall?.copyWith(
                    color: context.scheme.onPrimary.withValues(alpha: 0.75))),
          ],
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.scheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: context.scheme.onErrorContainer, size: AppIconSize.sm),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.scheme.onErrorContainer)),
            ),
          ],
        ),
      );
}