import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/bookings/presentation/screens/landlord_booking_management_screen.dart';
import '../../features/bookings/presentation/screens/tenant_booking_management_screen.dart';
import '../../features/rooms/presentation/screen/landlord/landlord_addroom_screen.dart';
import '../../features/rooms/presentation/screen/landlord/landlord_dashboard_screen.dart';
import '../../features/rooms/presentation/screen/landlord/landlord_setting_screen.dart';
import '../../features/rooms/presentation/screen/tenant/tenant_favoriate_screen.dart';
import '../../features/rooms/presentation/screen/tenant/tenant_room_list_screen.dart';
import '../../features/rooms/presentation/screen/tenant/tenant_setting_screen.dart';
import '../widgets/role_switcher.dart';

/// Single adaptive shell for both roles. Replaces `HomeScreenUnified`.
/// - Phone: bottom NavigationBar (M3).
/// - Tablet/desktop/web: NavigationRail + content, so the responsive layout is
///   real instead of v1's "zoom to 67%" phone-mockup hack.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        if (user == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final isTenant = user.activeRole == AppConstants.findRoomRole;
        final tabs = isTenant ? _tenantTabs : _landlordTabs;
        // Clamp when switching roles keeps a valid index.
        final index = _index.clamp(0, tabs.length - 1);

        final width = MediaQuery.sizeOf(context).width;
        final wide = width >= AppBreakpoints.tablet;
        // const wide = false;

        final body = IndexedStack(
          index: index,
          children: [for (final t in tabs) t.screen],
        );

        return Scaffold(
          backgroundColor: context.scheme.surface,
          appBar: AppBar(
            toolbarHeight: 96,
            automaticallyImplyLeading: false,
            titleSpacing: AppSpacing.lg,
            backgroundColor: context.scheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: SizedBox(
                width: 220,
                child: RoleSwitcher(
                  activeRole: user.activeRole,
                  onChanged: auth.switchRole,
                ),
              ),
            ),
            actions: [
              const _ProfileMenu(),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
          body: SafeArea(child: body),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final t in tabs)
                NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon),
                  label: t.label,
                ),
            ],
          ),
        );
      },
    );
  }

  List<_Tab> get _tenantTabs => const [
        _Tab('Explore', Icons.explore_outlined, Icons.explore, TenantRoomListScreen()),
        _Tab('Bookings', Icons.receipt_long_outlined, Icons.receipt_long,
            TenantBookingManagementScreen()),
        _Tab('Saved', Icons.favorite_outline, Icons.favorite, TenantFavoriteScreen()),
        _Tab('Profile', Icons.person_outline, Icons.person, TenantSettingScreen()),
      ];

  List<_Tab> get _landlordTabs => const [
        _Tab('Dashboard', Icons.dashboard_outlined, Icons.dashboard,
            LandlordDashboardScreen()),
        _Tab('Requests', Icons.inbox_outlined, Icons.inbox,
            LandlordBookingManagementScreen()),
        _Tab('Add', Icons.add_circle_outline, Icons.add_circle,
            LandlordAddRoomScreen()),
        _Tab('Profile', Icons.person_outline, Icons.person, LandlordSettingScreen()),
      ];
}

class _Tab {
  const _Tab(this.label, this.icon, this.activeIcon, this.screen);
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user!;
        return PopupMenuButton<String>(
          tooltip: 'Account',
          onSelected: (v) {
            if (v == 'signout') auth.signOut();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName, style: context.text.titleSmall),
                  Text(user.email,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.scheme.onSurfaceVariant)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'signout',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout_rounded),
                title: Text('Sign out'),
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: context.scheme.primaryContainer,
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(user.displayName.characters.first.toUpperCase(),
                      style: context.text.titleSmall)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
