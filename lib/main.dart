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
      themeMode: ThemeMode.light,
      routerConfig: _appRouter.router,

      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        final screenSize = MediaQuery.of(context).size;
        final phoneHeight = screenSize.height - 40;

        return Container(
          color: scheme.surface,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black12, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: SizedBox(
                      height: phoneHeight.clamp(600.0, 920.0),
                      child: Column(
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(40),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 110,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Material(
                              color: scheme.surface,
                              child: child ?? const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
