// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:mvproomrentandbook/features/bookings/presentation/provider/booking_provider.dart';
// import 'package:mvproomrentandbook/features/rooms/presentation/provider/room_provider.dart';
// import 'package:provider/provider.dart';
// import 'features/auth/data/firebase_auth_repository.dart';
// import 'features/auth/presentation/auth_provider.dart';
// import 'features/auth/presentation/auth_screen.dart';
// import 'shared/screens/home_screen_unified.dart';
// import 'features/rooms/data/firebase_room_repository.dart';
// import 'features/bookings/data/firebase_booking_repository.dart';
// import 'core/constants/app_theme.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
// );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Repositories
//         Provider<FirebaseAuthRepository>(
//           create: (_) => FirebaseAuthRepository(),
//         ),
//         Provider<FirebaseRoomRepository>(
//           create: (_) => FirebaseRoomRepository(),
//         ),
//         Provider<FirebaseBookingRepository>(
//           create: (_) => FirebaseBookingRepository(),
//         ),

//         // Providers
//         ChangeNotifierProvider<AuthProvider>(
//           create: (context) =>
//               AuthProvider(context.read<FirebaseAuthRepository>()),
//         ),
//         ChangeNotifierProvider<RoomProvider>(
//           create: (context) =>
//               RoomProvider(context.read<FirebaseRoomRepository>()),
//         ),
//         ChangeNotifierProvider<BookingProvider>(
//           create: (context) =>
//               BookingProvider(context.read<FirebaseBookingRepository>()),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'Room Rental Kathmandu',
//         theme: AppTheme.lightTheme,
//         home: const AuthWrapper(),
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         // Check authentication status on startup
//         if (authProvider.state == AuthState.initial) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             authProvider.checkAuthStatus();
//           });
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // Show loading screen
//         if (authProvider.state == AuthState.loading) {
//           return const Scaffold(

//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // Show home screen if authenticated
//         if (authProvider.isAuthenticated) {
//           return const HomeScreenUnified();
//         }

//         // Show auth screen if not authenticated
//         return const AuthScreen();
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mvproomrentandbook/features/bookings/presentation/provider/booking_provider.dart';
import 'package:mvproomrentandbook/features/rooms/presentation/provider/room_provider.dart';
import 'package:provider/provider.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'shared/screens/home_screen_unified.dart';
import 'features/rooms/data/firebase_room_repository.dart';
import 'features/bookings/data/firebase_booking_repository.dart';
import 'core/constants/app_theme.dart';
import 'firebase_options.dart';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return MaterialApp(
            title: 'Room Rental Kathmandu',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              if (isMobile) {
                return child!;
              }

              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "This app is best viewed in mobile size. Please zoom out or resize your browser.\n Some features might not work properly on web.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 400,
                        height: 800,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: child!,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            home: const AuthWrapper(),
          );
        },
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
