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
import 'dart:async';

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
        print('Initializing Google Sign-In...');

        // For google_sign_in 7.x, initialize with proper configuration
        await GoogleSignIn.instance.initialize(
          // Use your actual web client ID from the index.html
          clientId: kIsWeb
              ? '185746498577-sodrd9biacf0pjjljedm9r72l95mr0al.apps.googleusercontent.com'
              : null,
          // For Android, this is optional and read from google-services.json
          serverClientId: null,
        );

        _isGoogleSignInInitialized = true;
        print('Google Sign-In initialized successfully');

        // Set up authentication event listener
        GoogleSignIn.instance.authenticationEvents.listen(
          (GoogleSignInAuthenticationEvent event) {
            print('Authentication event: $event');
          },
          onError: (error) {
            print('Authentication event error: $error');
          },
        );
      } catch (e) {
        print('Error initializing Google Sign-In: $e');
        _isGoogleSignInInitialized = false;
        rethrow;
      }
    }
  }

  // Future<void> _initializeGoogleSignIn() async {
  //   if (!_isGoogleSignInInitialized) {
  //     try {
  //       await GoogleSignIn.instance.initialize();
  //       _isGoogleSignInInitialized = true;
  //       print('Google Sign-In initialized successfully');
  //     } catch (e) {
  //       print('Error initializing Google Sign-In: $e');
  //       _isGoogleSignInInitialized = false;
  //     }
  //   }
  // }

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
      print('Mobile Google Sign-In: Using correct 7.x approach');

      // Step 1: Check if authenticate is supported
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const Left(
          AuthFailure('Google Sign-In not supported on this platform'),
        );
      }

      // Step 2: Authenticate with Google
      print('Step 1: Authenticating with Google...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        return const Left(AuthFailure('Google authentication was cancelled'));
      }

      print('Google user authenticated: ${googleUser.email}');

      // Step 3: Get client authorization for basic scopes
      print('Step 2: Getting client authorization...');
      final GoogleSignInClientAuthorization? clientAuth = await googleUser
          .authorizationClient
          .authorizationForScopes(['openid', 'email', 'profile']);

      if (clientAuth == null) {
        // If no existing authorization, request it
        print('No existing authorization, requesting scopes...');
        final GoogleSignInClientAuthorization newClientAuth = await googleUser
            .authorizationClient
            .authorizeScopes(['openid', 'email', 'profile']);

        if (newClientAuth.accessToken.isEmpty) {
          return const Left(AuthFailure('Failed to get access token'));
        }
      }

      // Step 4: For Firebase, we need to create our own ID token
      // Since google_sign_in 7.x doesn't provide direct ID token access,
      // we'll use Firebase Auth's signInWithPopup equivalent for mobile
      print('Step 3: Using Firebase Auth directly...');

      // Create a Google provider
      final googleProvider = firebase_auth.GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Use signInWithProvider for mobile (equivalent to signInWithPopup for web)
      final firebase_auth.UserCredential userCredential;

      try {
        userCredential = await _firebaseAuth.signInWithProvider(googleProvider);
      } catch (e) {
        print('signInWithProvider failed, trying alternative approach: $e');

        // Alternative: Try to get ID token through server authorization
        final GoogleSignInServerAuthorization? serverAuth = await googleUser
            .authorizationClient
            .authorizeServer(['openid', 'email', 'profile']);

        if (serverAuth == null || serverAuth.serverAuthCode.isEmpty) {
          return const Left(AuthFailure('Failed to get server authorization'));
        }

        // The serverAuthCode can be exchanged for tokens on your backend
        // For now, let's try a different approach - manual credential creation
        throw Exception('Need backend integration for server auth code');
      }

      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return const Left(AuthFailure('Firebase authentication failed'));
      }

      print('Firebase sign-in successful: ${firebaseUser.email}');
      return await _handleFirebaseUser(firebaseUser);
    } catch (e) {
      print('Mobile Google Sign-In Error: $e');

      // Clean up on error
      try {
        await GoogleSignIn.instance.disconnect();
      } catch (cleanupError) {
        print('Cleanup error: $cleanupError');
      }

      // Handle specific error types
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        return const Left(AuthFailure('Sign-in was cancelled'));
      } else if (e.toString().contains('network')) {
        return const Left(
          AuthFailure('Network error. Please check your connection.'),
        );
      }

      return Left(AuthFailure('Sign-in failed: ${e.toString()}'));
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
