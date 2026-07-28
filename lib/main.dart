import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/bookings/data/firebase_booking_repository.dart';
import 'features/bookings/domain/booking_repository.dart';
import 'features/bookings/presentation/provider/booking_provider.dart';
import 'features/rooms/data/firebase_room_repository.dart';
import 'features/rooms/domain/room_repository.dart';
import 'features/rooms/presentation/provider/room_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.assertValid();

  // v1 locked to portrait; v2 is responsive so we allow all orientations and
  // let layout adapt. (Remove this line entirely for default behavior.)

  final prefs = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(KothaKhojApp(prefs: prefs));
}

class KothaKhojApp extends StatelessWidget {
  const KothaKhojApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories exposed via their domain interfaces (DIP) so providers
        // depend on abstractions, not Firebase concretions — easy to test/mock.
        Provider<AuthRepository>(create: (_) => FirebaseAuthRepository()),
        Provider<RoomRepository>(create: (_) => FirebaseRoomRepository()),
        Provider<BookingRepository>(create: (_) => FirebaseBookingRepository()),
        ChangeNotifierProvider(create: (_) => ThemeController(prefs)),
        ChangeNotifierProvider(
          create: (c) => AuthProvider(c.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (c) => RoomProvider(c.read<RoomRepository>()),
        ),
        ChangeNotifierProvider(
          create: (c) => BookingProvider(c.read<BookingRepository>()),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final AppRouter _appRouter = AppRouter(
    context.read<AuthProvider>(),
  );

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.mode,
      routerConfig: _appRouter.router,

      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;

            if (isMobile) {
              return child!;
            }

            final scheme = Theme.of(context).colorScheme;

            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary,
                      scheme.primary.withOpacity(.85),
                      scheme.surface,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      children: [
                          /// LEFT
  Expanded(
    child: Center(
      child: Text(
        "Zoom out browser to 67% for better view",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),

  /// PHONE
  SizedBox(
    width: 460,
    child: Center(
      child: _PhoneMockup(
        child: child!,
      ),
    ),
  ),

  /// RIGHT
  Expanded(
    child: Center(
      child: Text(
        "Made by Niranjan Dahal",
        textAlign: TextAlign.center,
        style: TextStyle(
          color:Colors.black,
          fontSize: 16,
        ),
      ),
    ),
  ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withOpacity(.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: scheme.onPrimary, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: scheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 430,
      height: 900,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(.30),
              blurRadius: 45,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48),
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withOpacity(.30),
                    Colors.black87,
                    Colors.black,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(.12),
                  width: 10,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
