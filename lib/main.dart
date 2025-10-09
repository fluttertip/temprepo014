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
              final isWebDesktop = constraints.maxWidth > 800;
              final isMobile = constraints.maxWidth < 600;

              if (isWebDesktop && !isMobile) {
                // Desktop/web view - show phone mockup + animated background
                return Scaffold(
                  backgroundColor: const Color(0xFF0F0F1E),
                  body: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: const [
                          Color(0xFF0F0F1E),
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                          Color(0xFF0F0F1E),
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        const _AnimatedBackgroundOrbs(),
                        Row(
                          children: [
                            // Center - Phone mockup
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: _PhoneMockup(
                                  child: child ?? const SizedBox.shrink(),
                                ),
                              ),
                            ),

                            // Info message on right
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.08),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: Color(0xFF667EEA),
                                        size: 48,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Zoom out your browser - 67%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'All features may not work properly on the web version.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Mobile/tablet view or narrow web view - show full app
                return child!;
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

// Phone mockup widget (adapted from example)
class _PhoneMockup extends StatelessWidget {
  final Widget child;
  const _PhoneMockup({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const frameWidth = 440.0;
    const frameHeight = 920.0;

    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 30,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Bezel/frame
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.black,
                border: Border.all(width: 8.0, color: const Color(0xFF1A1A1A)),
              ),
            ),

            // Screen content
            Center(
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: SizedBox(
                    width: frameWidth - 40,
                    height: frameHeight - 40,
                    child: child,
                  ),
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
  const _AnimatedBackgroundOrbs({Key? key}) : super(key: key);

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
