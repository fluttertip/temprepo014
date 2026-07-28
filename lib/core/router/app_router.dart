import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/rooms/domain/room.dart';
import '../../features/rooms/presentation/screen/tenant/tenant_room_detail_screen.dart';
import '../../shared/screens/home_shell.dart';

/// Central route table. Replaces v1's imperative `Navigator.push` +
/// `AuthWrapper` Consumer with a declarative, auth-aware GoRouter.
///
/// Benefits: deep-linkable room URLs (/room/:id), a single source of truth for
/// redirects, and web URL support for the newly responsive layout.
class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const home = '/home';
  static const roomDetail = '/room';
}

class AppRouter {
  AppRouter(this._auth);
  final AuthProvider _auth;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    // Rebuild redirects whenever auth state changes.
    refreshListenable: _auth,
    redirect: (context, state) {
      final s = _auth.state;
      final loc = state.matchedLocation;

      if (s == AuthState.initial || s == AuthState.loading) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }
      final loggedIn = _auth.isAuthenticated;
      final onAuth = loc == AppRoutes.auth;
      final onSplash = loc == AppRoutes.splash;

      if (!loggedIn) return onAuth ? null : AppRoutes.auth;
      if (onAuth || onSplash) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeShell(),
      ),
      GoRoute(
        path: '${AppRoutes.roomDetail}/:id',
        builder: (context, state) {
          // Prefer the Room passed via extra (instant, has full data); fall
          // back to id-only for deep links (detail screen fetches by id).
          final extra = state.extra;
          if (extra is Room) {
            return TenantRoomDetailScreen(room: extra);
          }
          return TenantRoomDetailScreen(roomId: state.pathParameters['id']);
        },
      ),
    ],
  );
}

/// Minimal splash shown while auth resolves on cold start.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    // Kick off the auth check once.
    final auth = context.read<AuthProvider>();
    if (auth.state == AuthState.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => auth.checkAuthStatus());
    }
    return  ColoredBox(
      color: Color(0xFF0E7C66),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(color: Color(0xFFFFFFFF), strokeWidth: 3),
        ),
      ),
    );
  }
}