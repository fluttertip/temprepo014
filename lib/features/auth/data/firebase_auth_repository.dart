import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/errors/failures.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  bool _googleInitialized = false;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(AppConstants.usersCollection).doc(uid);

  Future<void> _ensureGoogleInit() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb
          ? (AppConfig.googleWebClientId.isEmpty
              ? null
              : AppConfig.googleWebClientId)
          : null,
    );
    _googleInitialized = true;
  }

  @override
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((fbUser) async {
        if (fbUser == null) return null;
        try {
          return await _loadOrCreate(fbUser);
        } catch (e) {
          debugPrint('authStateChanges error: $e');
          return null;
        }
      });

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      await _ensureGoogleInit();
      final fbUser = kIsWeb ? await _googleWeb() : await _googleMobile();
      if (fbUser == null) {
        return const Left(AuthFailure('Google sign-in was cancelled.'));
      }
      return Right(await _loadOrCreate(fbUser));
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  Future<fb.User?> _googleWeb() async {
    final provider = fb.GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');
    final cred = await _auth.signInWithPopup(provider);
    return cred.user;
  }

  Future<fb.User?> _googleMobile() async {
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const AuthFailure('Google Sign-In not supported on this platform.');
    }
    final googleUser = await GoogleSignIn.instance.authenticate();
    final auth = googleUser.authentication;
    // BUG FIX (v1): v1 passed `accessToken: auth.idToken`, mixing token types.
    // google_sign_in 7.x exposes only the idToken here, which is sufficient for
    // Firebase's GoogleAuthProvider credential.
    final credential = fb.GoogleAuthProvider.credential(idToken: auth.idToken);
    final cred = await _auth.signInWithCredential(credential);
    return cred.user;
  }

  /// Loads the Firestore user profile, creating it on first sign-in.
  Future<User> _loadOrCreate(fb.User fbUser) async {
    final doc = await _userDoc(fbUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return User.fromMap(doc.data()!);
    }
    final now = DateTime.now();
    final user = User(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName ?? 'Guest',
      photoUrl: fbUser.photoURL,
      phoneNumber: fbUser.phoneNumber,
      activeRole: AppConstants.findRoomRole,
      createdAt: now,
      updatedAt: now,
    );
    await _userDoc(fbUser.uid).set(user.toMap());
    return user;
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final fbUser = _auth.currentUser;
      if (fbUser == null) return const Right(null);
      final doc = await _userDoc(fbUser.uid).get();
      return Right(doc.exists ? User.fromMap(doc.data()!) : null);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserRole(String userId, String role) async {
    try {
      await _userDoc(userId).update({
        'activeRole': role,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      final doc = await _userDoc(userId).get();
      if (!doc.exists) return const Left(AuthFailure('User not found'));
      return Right(User.fromMap(doc.data()!));
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      if (_googleInitialized) {
        try {
          await GoogleSignIn.instance.disconnect();
        } catch (_) {}
      }
      return const Right(null);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }
}

// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import '../domain/auth_repository.dart';
// import '../domain/user.dart';
// import '../../../core/errors/failures.dart';
// import '../../../core/errors/error_handler.dart';
// import '../../../core/constants/app_constants.dart';

// class FirebaseAuthRepository implements AuthRepository {
//   final firebase_auth.FirebaseAuth _firebaseAuth;
//   final FirebaseFirestore _firestore;
//   bool _isGoogleSignInInitialized = false;

//   FirebaseAuthRepository({
//     firebase_auth.FirebaseAuth? firebaseAuth,
//     FirebaseFirestore? firestore,
//   })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
//         _firestore = firestore ?? FirebaseFirestore.instance;

//   // ---------------- Google Sign-In Initialization ----------------
//   Future<void> _initializeGoogleSignIn() async {
//     if (_isGoogleSignInInitialized) return;

//     try {
//       print('Initializing Google Sign-In...');
//       await GoogleSignIn.instance.initialize(
//         clientId: kIsWeb
//             ? '776388841511-ekuomv5at7g7edmb9fsd017jau3s9epb.apps.googleusercontent.com'
//             : null,
//         serverClientId: null, // Optional on Android/iOS
//       );

//       GoogleSignIn.instance.authenticationEvents.listen(
//         (event) => print('Authentication event: $event'),
//         onError: (error) => print('Authentication event error: $error'),
//       );

//       _isGoogleSignInInitialized = true;
//     } catch (e) {
//       print('Google Sign-In initialization failed: $e');
//       rethrow;
//     }
//   }

//   // ---------------- Auth State Changes ----------------
//   @override
//   Stream<User?> get authStateChanges {
//     return _firebaseAuth.authStateChanges().asyncMap((firebase_auth.User? firebaseUser) async {
//       print('Firebase auth state changed: ${firebaseUser?.email}');
//       if (firebaseUser == null) return null;

//       try {
//         final userDoc = await _firestore
//             .collection(AppConstants.usersCollection)
//             .doc(firebaseUser.uid)
//             .get();

//         if (userDoc.exists) {
//           return User.fromMap(userDoc.data()!);
//         }

//         // Create new user if not exists
//         final user = User(
//           id: firebaseUser.uid,
//           email: firebaseUser.email ?? '',
//           displayName: firebaseUser.displayName ?? 'User',
//           photoUrl: firebaseUser.photoURL,
//           phoneNumber: firebaseUser.phoneNumber,
//           activeRole: AppConstants.findRoomRole,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );

//         await _firestore.collection(AppConstants.usersCollection).doc(firebaseUser.uid).set(user.toMap());
//         return user;
//       } catch (e) {
//         print('Error in authStateChanges: $e');
//         return null;
//       }
//     });
//   }

//   // ---------------- Sign-In ----------------
//   @override
//   Future<Either<Failure, User>> signInWithGoogle() async {
//     try {
//       await _initializeGoogleSignIn();

//       if (kIsWeb) {
//         return await _signInWithGoogleWeb();
//       } else {
//         return await _signInWithGoogleMobile();
//       }
//     } catch (e) {
//       print('Google Sign-In Error: $e');
//       return Left(AuthFailure('Google sign-in failed: ${e.toString()}'));
//     }
//   }

//   Future<Either<Failure, User>> _signInWithGoogleWeb() async {
//     try {
//       print('Web Google Sign-In using signInWithPopup...');
//       final googleProvider = firebase_auth.GoogleAuthProvider();
//       googleProvider.addScope('email');
//       googleProvider.addScope('profile');

//       final firebase_auth.UserCredential userCredential =
//           await _firebaseAuth.signInWithPopup(googleProvider);

//       final firebase_auth.User? firebaseUser = userCredential.user;
//       if (firebaseUser == null) return const Left(AuthFailure('Failed to sign in with Google'));

//       return await _handleFirebaseUser(firebaseUser);
//     } catch (e) {
//       print('Web Google Sign-In Error: $e');
//       return Left(AuthFailure('Web sign-in failed: ${e.toString()}'));
//     }
//   }

//   Future<Either<Failure, User>> _signInWithGoogleMobile() async {
//     try {
//       print('Mobile Google Sign-In using authenticate()...');
//       if (!GoogleSignIn.instance.supportsAuthenticate()) {
//         return const Left(AuthFailure('Google Sign-In not supported on this platform'));
//       }

//       final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
//       final auth = await googleUser.authentication;

//       final credential = firebase_auth.GoogleAuthProvider.credential(
//         idToken: auth.idToken,
//         accessToken: auth.idToken,
//       );

//       final firebase_auth.UserCredential userCredential =
//           await _firebaseAuth.signInWithCredential(credential);

//       final firebase_auth.User? firebaseUser = userCredential.user;
//       if (firebaseUser == null) return const Left(AuthFailure('Firebase authentication failed'));

//       return await _handleFirebaseUser(firebaseUser);
//     } catch (e) {
//       print('Mobile Google Sign-In Error: $e');
//       try {
//         await GoogleSignIn.instance.disconnect();
//       } catch (_) {}

//       return Left(AuthFailure('Sign-in failed: ${e.toString()}'));
//     }
//   }

//   // ---------------- Handle Firebase User ----------------
//   Future<Either<Failure, User>> _handleFirebaseUser(firebase_auth.User firebaseUser) async {
//     try {
//       final userDoc = await _firestore.collection(AppConstants.usersCollection).doc(firebaseUser.uid).get();

//       User user;
//       if (userDoc.exists) {
//         user = User.fromMap(userDoc.data()!);
//       } else {
//         user = User(
//           id: firebaseUser.uid,
//           email: firebaseUser.email ?? '',
//           displayName: firebaseUser.displayName ?? 'User',
//           photoUrl: firebaseUser.photoURL,
//           phoneNumber: firebaseUser.phoneNumber,
//           activeRole: AppConstants.findRoomRole,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );
//         await _firestore.collection(AppConstants.usersCollection).doc(firebaseUser.uid).set(user.toMap());
//       }

//       return Right(user);
//     } catch (e) {
//       print('Error handling Firebase user: $e');
//       return Left(AuthFailure('Failed to create/load user: ${e.toString()}'));
//     }
//   }

//   // ---------------- Other Auth Methods ----------------
//   @override
//   Future<Either<Failure, User?>> getCurrentUser() async {
//     try {
//       final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
//       if (firebaseUser == null) return const Right(null);

//       final userDoc = await _firestore.collection(AppConstants.usersCollection).doc(firebaseUser.uid).get();
//       if (userDoc.exists) return Right(User.fromMap(userDoc.data()!));

//       return const Right(null);
//     } catch (e) {
//       return Left(FirebaseErrorHandler.handleGenericError(e));
//     }
//   }

//   @override
//   Future<Either<Failure, User>> updateUserRole(String userId, String newRole) async {
//     try {
//       await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
//         'activeRole': newRole,
//         'updatedAt': DateTime.now(),
//       });

//       final userDoc = await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
//       if (userDoc.exists) return Right(User.fromMap(userDoc.data()!));

//       return const Left(AuthFailure('User not found'));
//     } catch (e) {
//       return Left(FirebaseErrorHandler.handleGenericError(e));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> signOut() async {
//     try {
//       await _firebaseAuth.signOut();
//       if (_isGoogleSignInInitialized) await GoogleSignIn.instance.disconnect();
//       return const Right(null);
//     } catch (e) {
//       return Left(FirebaseErrorHandler.handleGenericError(e));
//     }
//   }
// }