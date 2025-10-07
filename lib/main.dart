import 'package:flutter/material.dart';
import 'package:kothakhoj/features/bookings/presentation/provider/booking_provider.dart';
import 'package:kothakhoj/features/rooms/presentation/provider/room_provider.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'shared/screens/home_screen_unified.dart';
import 'features/rooms/data/firebase_room_repository.dart';
import 'features/bookings/data/firebase_booking_repository.dart';
import 'core/constants/app_theme.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
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
        title: 'Room Find + Rent in Kathmandu',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWeb = constraints.maxWidth > 800;
              final isMobile = constraints.maxWidth < 600;

              if (isWeb && !isMobile) {
                // Web desktop view - show mobile simulator
                return Scaffold(
                  backgroundColor: const Color(0xFF1a1a1a),
                  body: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Text(
                              "Kothakhoj - Room Rental App",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Text(
                              "This app is optimized for mobile devices. Web version shows mobile simulation and all features might not works here.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Mobile simulator container
                          Container(
                            width: 380, // Fixed width for mobile simulation
                            height: 720, // Fixed height for mobile simulation
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.grey[800]!,
                                width: 8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              child: child!,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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
