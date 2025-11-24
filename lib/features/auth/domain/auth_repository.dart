import 'package:dartz/dartz.dart';
import '../domain/user.dart';
import '../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, User>> updateUserRole(String userId, String role);
  Stream<User?> get authStateChanges;
}
