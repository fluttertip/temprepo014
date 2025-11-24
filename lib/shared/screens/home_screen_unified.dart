import 'package:flutter/material.dart';
import 'package:kothakhoj/features/bookings/presentation/screens/landlord_booking_management_screen.dart';
import 'package:kothakhoj/features/rooms/presentation/screen/landlord/landlord_addroom_screen.dart';
import 'package:kothakhoj/features/rooms/presentation/screen/landlord/landlord_dashboard_screen.dart';
import 'package:kothakhoj/features/rooms/presentation/screen/landlord/landlord_setting_screen.dart';
import 'package:kothakhoj/features/bookings/presentation/screens/tenant_booking_management_screen.dart';
import 'package:kothakhoj/features/rooms/presentation/screen/tenant/tenant_favoriate_screen.dart';
import 'package:kothakhoj/features/rooms/presentation/screen/tenant/tenant_room_list_screen.dart';
import 'package:kothakhoj/features/rooms/presentation/screen/tenant/tenant_setting_screen.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/auth_provider.dart';
import 'dart:ui';
import '../../core/constants/app_constants.dart';

class HomeScreenUnified extends StatefulWidget {
  const HomeScreenUnified({super.key});

  @override
  State<HomeScreenUnified> createState() => _HomeScreenUnifiedState();
}

class _HomeScreenUnifiedState extends State<HomeScreenUnified> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authProvider.user!;
        final isTenant = user.activeRole == AppConstants.findRoomRole;

        // Get screens based on user role
        final screens = isTenant ? _getTenantScreens() : _getLandlordScreens();
        final bottomNavItems = isTenant
            ? _getTenantNavItems()
            : _getLandlordNavItems();

        final shouldShowAppBar = _shouldShowAppBar(isTenant);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: shouldShowAppBar
              ? AppBar(
                  toolbarHeight: 90,

                  backgroundColor: Colors.white.withOpacity(
                    0.95,
                  ), // Slightly transparent
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.98),
                          Colors.white.withOpacity(0.92),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // Compact role switcher
                    _RoleSwitcher(
                      activeRole: user.activeRole,
                      onRoleChanged: (newRole) {
                        authProvider.switchRole(newRole);
                      },
                    ),
                    const SizedBox(width: 12),

                    // User menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          authProvider.signOut();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 18),
                              const SizedBox(width: 8),
                              Text(user.displayName),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 18),
                              SizedBox(width: 8),
                              Text('Sign Out'),
                            ],
                          ),
                        ),
                      ],
                      child: CircleAvatar(
                        radius: 18, // Smaller avatar
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.displayName[0].toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 16),
                  ],
                )
              : null,

          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: bottomNavItems,
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }

  bool _shouldShowAppBar(bool isTenant) {
    if (isTenant) {
      return _currentIndex == 0; // Only show AppBar on Rooms tab
    } else {
      return _currentIndex == 0; // Only show AppBar on Dashboard tab
    }
  }

  List<Widget> _getTenantScreens() {
    return [
      const TenantRoomListScreen(),
      TenantBookingManagementScreen(),
      const TenantFavoriteScreen(),
      const TenantSettingScreen(),
    ];
  }

  List<Widget> _getLandlordScreens() {
    return [
      const LandlordDashboardScreen(),
      // const LandlordMyRoomScreen(),
      LandlordBookingManagementScreen(),
      const LandlordAddRoomScreen(),
      const LandlordSettingScreen(),
    ];
  }

  List<BottomNavigationBarItem> _getTenantNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Rooms',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.book_outlined),
        activeIcon: Icon(Icons.book),
        label: 'Bookings',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite_outline),
        activeIcon: Icon(Icons.favorite),
        label: 'Favorites',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
  }

  List<BottomNavigationBarItem> _getLandlordNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home_work_outlined),
        activeIcon: Icon(Icons.home_work),
        label: 'My Rooms',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_home_outlined),
        activeIcon: Icon(Icons.add_home),
        label: 'Add Room',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
  }
}

class _RoleSwitcher extends StatelessWidget {
  final String activeRole;
  final ValueChanged<String> onRoleChanged;

  const _RoleSwitcher({required this.activeRole, required this.onRoleChanged});

  @override
  Widget build(BuildContext context) {
    // Get the actual screen width, not the constrained width
    final screenWidth =
        View.of(context).physicalSize.width / View.of(context).devicePixelRatio;
    final containerWidth = screenWidth > 600 ? 280.0 : screenWidth * 0.75;
    return Container(
      width: containerWidth,
      height: 52,
      decoration: BoxDecoration(
        // Enhanced glassmorphic effect
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2), // More visible border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Stack(
                children: [
                  // Enhanced sliding indicator
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    alignment: activeRole == "Find Room"
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      // width: MediaQuery.sizeOf(context).width * 0.75 / 2 - 6,
                      width:
                          (containerWidth - 12) /
                          2, // Calculate based on container width

                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(23),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Button options
                  Row(
                    children: [
                      Expanded(
                        child: _SwitcherOption(
                          label: "Find Room",
                          isActive: activeRole == "Find Room",
                          onTap: () => onRoleChanged("Find Room"),
                          icon: Icons.search_rounded,
                        ),
                      ),
                      Expanded(
                        child: _SwitcherOption(
                          label: "Rent Room",
                          isActive: activeRole == "Rent Room",
                          onTap: () => onRoleChanged("Rent Room"),
                          icon: Icons.add_home_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitcherOption extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData icon;

  const _SwitcherOption({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        width: 50,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(23)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(23),
            splashColor: isActive
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isActive ? Colors.white : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[700],
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
