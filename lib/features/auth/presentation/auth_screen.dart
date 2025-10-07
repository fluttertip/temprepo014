import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/constants/app_theme.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home,
                  size: AppSizes.iconXL * 2,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // App Name
              Text(
                'Room Rental\nKathmandu',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.paddingM),

              // Subtitle
              Text(
                'Find your perfect room or rent out your space\nin the heart of Kathmandu',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.paddingXL * 2),

              // Sign In Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    children: [
                      CustomButton(
                        text: 'Continue with Google',
                        icon: Icons.login,
                        isLoading: authProvider.state == AuthState.loading,
                        onPressed: authProvider.state == AuthState.loading
                            ? null
                            : () => authProvider.signInWithGoogle(),
                      ),

                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: AppSizes.paddingM),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusS,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.errorColor,
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Features preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FeatureItem(
                    icon: Icons.search,
                    title: 'Find Rooms',
                    subtitle: 'Browse & book',
                  ),
                  _FeatureItem(
                    icon: Icons.home_work,
                    title: 'Rent Rooms',
                    subtitle: 'List & manage',
                  ),
                  _FeatureItem(
                    icon: Icons.location_on,
                    title: 'Kathmandu',
                    subtitle: 'Local focus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.primaryColorLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconL,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
