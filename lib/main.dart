import 'dart:async';

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
  late final AppRouter _appRouter = AppRouter(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,

      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      darkTheme: AppTheme.dark,

      themeMode: ThemeMode.light,

      routerConfig: _appRouter.router,

      builder: (context, child) {
        return _DesktopPhonePreview(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _DesktopPhonePreview extends StatelessWidget {
  final Widget child;

  const _DesktopPhonePreview({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return child;
        }

        return Scaffold(
          body: Container(
            width: double.infinity,

            height: double.infinity,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

                colors: [
                  Color(0xffFAFBFF),

                  Color(0xffEEF3FA),

                  Color(0xffF8FAFD),
                ],
              ),
            ),

            child: Stack(
              alignment: Alignment.center,

              children: [
                Positioned(
                  top: -150,

                  left: -120,

                  child: Container(
                    width: 430,

                    height: 430,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: const Color(0xff10B981).withOpacity(.10),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -170,

                  right: -120,

                  child: Container(
                    width: 520,

                    height: 520,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: const Color(0xff3B82F6).withOpacity(.08),
                    ),
                  ),
                ),

                const Positioned(
                  left: 45,

                  bottom: 45,

                  child: Text(
                    "← Zoom out your browser for the best preview",

                    style: TextStyle(
                      color: Colors.black,

                      fontSize: 16,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Positioned(
                  right: 45,

                  bottom: 45,

                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black,

                        fontSize: 16,

                        fontWeight: FontWeight.w600,
                      ),

                      children: [
                        TextSpan(text: "Made by "),

                        TextSpan(
                          text: "Niranjan",

                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: 435,

                  height: 875,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.18),

                        blurRadius: 80,

                        spreadRadius: 10,

                        offset: const Offset(0, 40),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 420,

                  height: 860,

                  padding: const EdgeInsets.all(9),

                  decoration: BoxDecoration(
                    color: const Color(0xff1C1C1E),

                    borderRadius: BorderRadius.circular(46),
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),

                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40),

                          child: child,
                        ),

                        const Positioned(
                          top: 0,

                          left: 0,

                          right: 0,

                          height: 44,

                          child: _PhoneStatusBar(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhoneStatusBar extends StatefulWidget {
  const _PhoneStatusBar();

  @override
  State<_PhoneStatusBar> createState() => _PhoneStatusBarState();
}

class _PhoneStatusBarState extends State<_PhoneStatusBar> {
  String time = "";

  Timer? timer;

  @override
  void initState() {
    super.initState();

    _updateTime();

    timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();

    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;

    final minute = now.minute.toString().padLeft(2, '0');

    setState(() {
      time = "$hour:$minute";
    });
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,

      children: [
        Container(color: Colors.white.withOpacity(.94)),

        Positioned(
          left: 22,

          top: 14,

          child: Text(
            time,

            style: const TextStyle(
              color: Colors.black87,

              fontSize: 15,

              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Container(
          width: 118,

          height: 30,

          decoration: BoxDecoration(
            color: const Color(0xffE5E7EB),

            borderRadius: BorderRadius.circular(18),
          ),
        ),

        Positioned(
          right: 18,

          top: 13,

          child: Row(
            children: [
              const Icon(
                Icons.signal_cellular_alt_rounded,

                size: 16,

                color: Colors.black87,
              ),

              const SizedBox(width: 5),

              const Icon(Icons.wifi_rounded, size: 16, color: Colors.black87),

              const SizedBox(width: 7),

              Container(
                width: 25,

                height: 12,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),

                  border: Border.all(color: Colors.black87, width: 1.2),
                ),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Container(
                    margin: const EdgeInsets.all(2),

                    width: 15,

                    decoration: BoxDecoration(
                      color: Colors.black87,

                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
