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
import 'package:kothakhoj/shared/widgets/role_switcher.dart';

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
                  centerTitle: true,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: RoleSwitcher(
                      activeRole: user.activeRole,
                      onChanged: (newRole) => authProvider.switchRole(newRole),
                    ),
                  ),
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
                        radius: 18,
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

