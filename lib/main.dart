import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:kothakhoj/features/bookings/presentation/provider/booking_provider.dart';
import 'package:kothakhoj/features/rooms/presentation/provider/room_provider.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'shared/screens/home_screen_unified.dart';
import 'features/rooms/data/firebase_room_repository.dart';
import 'features/bookings/data/firebase_booking_repository.dart';
import 'core/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock app to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ignore: avoid_print
    print('Firebase initialized successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<FirebaseAuthRepository>(
          create: (_) => FirebaseAuthRepository(),
        ),
        Provider<FirebaseRoomRepository>(
          create: (_) => FirebaseRoomRepository(),
        ),
        Provider<FirebaseBookingRepository>(
          create: (_) => FirebaseBookingRepository(),
        ),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(context.read<FirebaseAuthRepository>()),
        ),
        ChangeNotifierProvider<RoomProvider>(
          create: (context) =>
              RoomProvider(context.read<FirebaseRoomRepository>()),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (context) =>
              BookingProvider(context.read<FirebaseBookingRepository>()),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              if (isMobile) {
                // Mobile/tablet view - show full app
                return child!;
              } else {
                // Desktop/web view - show phone mockup with clean layout
                return Scaffold(
                  body: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0F0F1E),
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                          Color(0xFF0F0F1E),
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: Row(
                      children: [
                        // LEFT: zoom out message
                        Expanded(
                          child: Center(
                            child: Text(
                              "zoom out browser to 67% for better view",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // CENTER: phone mockup
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: _PhoneMockup(child: child!),
                          ),
                        ),

                        // RIGHT: Made by text
                        Expanded(
                          child: Center(
                            child: Text(
                              "Made by Niranjan Dahal",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check authentication status on startup
        if (authProvider.state == AuthState.initial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.checkAuthStatus();
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show loading screen
        if (authProvider.state == AuthState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show home screen if authenticated
        if (authProvider.isAuthenticated) {
          return const HomeScreenUnified();
        }

        // Show auth screen if not authenticated
        return const AuthScreen();
      },
    );
  }
}

// Phone mockup widget
class _PhoneMockup extends StatelessWidget {
  final Widget child;
  const _PhoneMockup({required this.child});

  @override
  Widget build(BuildContext context) {
    const frameWidth = 440.0;
    const frameHeight = 920.0;

    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.25),
              blurRadius: 40.0,
              offset: const Offset(-10, 10),
            ),
            BoxShadow(
              color: const Color(0xFF764BA2).withOpacity(0.25),
              blurRadius: 40.0,
              offset: const Offset(10, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2C2C3E),
                    Color(0xFF1C1C2E),
                    Color(0xFF0F0F1E),
                  ],
                ),
                border: Border.all(width: 12.0, color: const Color(0xFF1A1A2E)),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38.0),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Animated background orbs (kept lightweight)
class _AnimatedBackgroundOrbs extends StatefulWidget {
  const _AnimatedBackgroundOrbs();

  @override
  State<_AnimatedBackgroundOrbs> createState() =>
      _AnimatedBackgroundOrbsState();
}

class _AnimatedBackgroundOrbsState extends State<_AnimatedBackgroundOrbs>
    with TickerProviderStateMixin {
  late final AnimationController _c1;
  late final AnimationController _c2;
  late final AnimationController _c3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _c2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _c3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _c1,
          builder: (context, _) {
            return Positioned(
              left: 50 + (200 * _c1.value),
              top: 60 + (120 * (1 - _c1.value)),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _c2,
          builder: (context, _) {
            return Positioned(
              right: 40 + (150 * _c2.value),
              top: 180 + (120 * _c2.value),
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF764BA2).withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _c3,
          builder: (context, _) {
            return Positioned(
              left: 260 + (100 * (1 - _c3.value)),
              bottom: 40 + (180 * _c3.value),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
