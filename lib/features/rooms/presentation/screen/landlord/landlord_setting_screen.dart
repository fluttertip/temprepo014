import 'package:flutter/material.dart';
import 'package:mvproomrentandbook/core/constants/app_constants.dart';
import 'package:mvproomrentandbook/core/constants/app_theme.dart';
import 'package:mvproomrentandbook/features/auth/presentation/auth_provider.dart';
import 'package:mvproomrentandbook/shared/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class LandlordSettingScreen extends StatelessWidget {
  const LandlordSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Custom header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      // Profile Section
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: user.photoUrl != null
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: user.photoUrl == null
                                    ? Text(
                                        user.displayName[0].toUpperCase(),
                                        style: AppTextStyles.heading3,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppSizes.paddingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.displayName,
                                      style: AppTextStyles.heading3,
                                    ),
                                    Text(
                                      user.email,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSizes.paddingXS),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingS,
                                        vertical: AppSizes.paddingXS,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            user.activeRole ==
                                                AppConstants.findRoomRole
                                            ? AppColors.landlordColor
                                                  .withOpacity(0.1)
                                            : AppColors.landlordColor
                                                  .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusS,
                                        ),
                                      ),
                                      child: Text(
                                        user.activeRole,
                                        style: AppTextStyles.caption.copyWith(
                                          color:
                                              user.activeRole ==
                                                  AppConstants.findRoomRole
                                              ? AppColors.landlordColor
                                              : AppColors.landlordColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.paddingM),

                      // Settings Options
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        elevation: 1,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_outlined),
                              title: const Text('Edit Profile'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Navigate to edit profile screen
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.notifications_outlined),
                              title: const Text('Notifications'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Navigate to notifications settings
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.help_outlined),
                              title: const Text('Help & Support'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Navigate to help screen
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.info_outlined),
                              title: const Text('About'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Show about dialog
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.paddingL),

                      // Sign Out Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          text: 'Sign Out',
                          icon: Icons.logout,
                          backgroundColor: AppColors.errorColor,
                          onPressed: () =>
                              _showSignOutDialog(context, authProvider),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
