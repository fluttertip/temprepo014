import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

class FirebaseErrorHandler {
  static Failure handleFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return const AuthFailure('No user found with this email.');
      case 'wrong-password':
        return const AuthFailure('Wrong password provided.');
      case 'email-already-in-use':
        return const AuthFailure('An account already exists with this email.');
      case 'weak-password':
        return const AuthFailure('The password provided is too weak.');
      case 'invalid-email':
        return const AuthFailure('The email address is not valid.');
      case 'user-disabled':
        return const AuthFailure('This user account has been disabled.');
      case 'too-many-requests':
        return const AuthFailure('Too many requests. Please try again later.');
      case 'operation-not-allowed':
        return const AuthFailure('This operation is not allowed.');
      case 'network-request-failed':
        return const NetworkFailure(
          'Network error. Please check your connection.',
        );
      default:
        return AuthFailure(error.message ?? AppConstants.authError);
    }
  }

  static Failure handleFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return const PermissionFailure(
          'You do not have permission to perform this action.',
        );
      case 'unavailable':
        return const NetworkFailure(
          'Service is currently unavailable. Please try again.',
        );
      case 'deadline-exceeded':
        return const NetworkFailure('Request timeout. Please try again.');
      case 'not-found':
        return const ServerFailure('The requested document was not found.');
      case 'already-exists':
        return const ServerFailure('The document already exists.');
      case 'invalid-argument':
        return const ValidationFailure('Invalid data provided.');
      case 'failed-precondition':
        return const ServerFailure(
          'Operation failed due to precondition failure.',
        );
      case 'aborted':
        return const ServerFailure('Operation was aborted.');
      case 'out-of-range':
        return const ValidationFailure('Value is out of range.');
      case 'unimplemented':
        return const ServerFailure('This operation is not implemented.');
      case 'internal':
        return const ServerFailure('Internal server error occurred.');
      case 'data-loss':
        return const ServerFailure('Data loss occurred.');
      case 'unauthenticated':
        return const AuthFailure('You are not authenticated. Please sign in.');
      default:
        return ServerFailure(error.message ?? AppConstants.unknownError);
    }
  }

  static Failure handleGenericError(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleFirebaseAuthError(error);
    } else if (error is FirebaseException) {
      return handleFirestoreError(error);
    } else if (error is SocketException) {
      return const NetworkFailure(
        'No internet connection. Please check your network.',
      );
    } else {
      return UnknownFailure(error.toString());
    }
  }
}
