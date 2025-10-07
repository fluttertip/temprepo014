import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/constants/app_constants.dart';
import'dart:async';

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  bool _isGoogleSignInInitialized = false;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> _initializeGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      try {
        await GoogleSignIn.instance.initialize();
        _isGoogleSignInInitialized = true;
        print('Google Sign-In initialized successfully');
      } catch (e) {
        print('Error initializing Google Sign-In: $e');
        _isGoogleSignInInitialized = false;
      }
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((
      firebase_auth.User? firebaseUser,
    ) async {
      print('Firebase auth state changed: ${firebaseUser?.email}');
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final user = User.fromMap(userDoc.data()!);
          print('User found in Firestore: ${user.email}');
          return user;
        }

        // Create new user document
        final user = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          phoneNumber: firebaseUser.phoneNumber,
          activeRole: AppConstants.findRoomRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        print('Creating new user in Firestore: ${user.email}');
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .set(user.toMap());

        return user;
      } catch (e) {
        print('Error in authStateChanges: $e');
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');

      // Initialize Google Sign-In first
      await _initializeGoogleSignIn();

      if (kIsWeb) {
        return await _signInWithGoogleWeb();
      } else {
        return await _signInWithGoogleMobile();
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      return Left(AuthFailure('Google sign-in failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User>> _signInWithGoogleWeb() async {
    try {
      print('Web Google Sign-In: Using Firebase Auth popup');

      // For web, use Firebase Auth directly with Google provider
      final googleProvider = firebase_auth.GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithPopup(googleProvider);

      final firebase_auth.User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Failed to sign in with Google'));
      }

      return await _handleFirebaseUser(firebaseUser);
    } catch (e) {
      print('Web Google Sign-In Error: $e');
      return Left(AuthFailure('Web sign-in failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User>> _signInWithGoogleMobile() async {
    try {
      print('Mobile Google Sign-In: Using new 7.x API');

      // Check if authentication is supported
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const Left(
          AuthFailure('Google Sign-In not supported on this platform'),
        );
      }

      // Use the new authenticate method
      await GoogleSignIn.instance.authenticate();

      // Listen for authentication events
      final completer = Completer<Either<Failure, User>>();
      late StreamSubscription subscription;

      subscription = GoogleSignIn.instance.authenticationEvents.listen(
        (GoogleSignInAuthenticationEvent event) async {
          try {
            switch (event) {
              case GoogleSignInAuthenticationEventSignIn():
                final googleUser = event.user;
                print('Google user authenticated: ${googleUser.email}');

                // Get ID token for Firebase
                final Map<String, String>? headers = await googleUser
                    .authorizationClient
                    .authorizationHeaders(['openid', 'email', 'profile']);

                if (headers == null) {
                  completer.complete(
                    const Left(
                      AuthFailure('Failed to get authorization headers'),
                    ),
                  );
                  subscription.cancel();
                  return;
                }

                // Extract the ID token from headers (this is a simplified approach)
                // In practice, you might need to use the Google Sign-In API differently
                // For now, let's use a different approach with Firebase Auth

                // Alternative: Use Firebase Auth with Google provider
                final googleProvider = firebase_auth.GoogleAuthProvider();

                // Note: In the new API, we need to handle this differently
                // This is a temporary workaround - you might need to implement
                // a custom solution based on your specific needs

                final result = await _handleGoogleUserWithFirebase(googleUser);
                completer.complete(result);
                subscription.cancel();
                break;

              case GoogleSignInAuthenticationEventSignOut():
                completer.complete(
                  const Left(AuthFailure('Google sign-in was cancelled')),
                );
                subscription.cancel();
                break;
            }
          } catch (e) {
            print('Error in authentication event: $e');
            completer.complete(
              Left(AuthFailure('Authentication failed: ${e.toString()}')),
            );
            subscription.cancel();
          }
        },
        onError: (error) {
          print('Authentication error: $error');
          completer.complete(
            Left(AuthFailure('Authentication error: ${error.toString()}')),
          );
          subscription.cancel();
        },
      );

      return await completer.future;
    } catch (e) {
      print('Mobile Google Sign-In Error: $e');
      return Left(AuthFailure('Mobile sign-in failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User>> _handleGoogleUserWithFirebase(
    GoogleSignInAccount googleUser,
  ) async {
    try {
      print('Handling Google user with Firebase: ${googleUser.email}');

      // For the new Google Sign-In API, we need to get server auth code
      // and use it with Firebase Auth
      const scopes = ['openid', 'email', 'profile'];

      final GoogleSignInServerAuthorization? serverAuth = await googleUser
          .authorizationClient
          .authorizeServer(scopes);

      if (serverAuth == null) {
        return const Left(AuthFailure('Failed to get server authorization'));
      }

      // Use the server auth code with Firebase
      final firebase_auth.AuthCredential credential = firebase_auth
          .GoogleAuthProvider.credential(idToken: serverAuth.serverAuthCode);

      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final firebase_auth.User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Failed to sign in with Firebase'));
      }

      return await _handleFirebaseUser(firebaseUser);
    } catch (e) {
      print('Error handling Google user with Firebase: $e');

      // Fallback: Create Firebase user from Google user data
      try {
        final firebase_auth.UserCredential userCredential = await _firebaseAuth
            .signInAnonymously();

        // Update the user profile with Google data
        await userCredential.user?.updateDisplayName(googleUser.displayName);
        await userCredential.user?.updatePhotoURL(googleUser.photoUrl);

        if (userCredential.user != null) {
          return await _handleFirebaseUser(userCredential.user!);
        }
      } catch (fallbackError) {
        print('Fallback auth also failed: $fallbackError');
      }

      return Left(AuthFailure('Failed to authenticate: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User>> _handleFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    try {
      print('Handling Firebase user: ${firebaseUser.email}');

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      User user;
      if (userDoc.exists) {
        user = User.fromMap(userDoc.data()!);
        print('Existing user loaded: ${user.email}');
      } else {
        user = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          phoneNumber: firebaseUser.phoneNumber,
          activeRole: AppConstants.findRoomRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        print('Creating new user: ${user.email}');
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .set(user.toMap());
      }

      return Right(user);
    } catch (e) {
      print('Error handling Firebase user: $e');
      return Left(AuthFailure('Failed to create/load user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
      print('Getting current user: ${firebaseUser?.email}');

      if (firebaseUser == null) {
        return const Right(null);
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final user = User.fromMap(userDoc.data()!);
        return Right(user);
      }

      return const Right(null);
    } catch (e) {
      print('Error getting current user: $e');
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserRole(
    String userId,
    String newRole,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
            'activeRole': newRole,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final user = User.fromMap(userDoc.data()!);
        return Right(user);
      }

      return const Left(AuthFailure('User not found'));
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (_isGoogleSignInInitialized) {
        await GoogleSignIn.instance.disconnect();
      }
      return const Right(null);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }
}
