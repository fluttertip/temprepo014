
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../domain/booking_repository.dart';
import '../domain/booking.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/constants/app_constants.dart';

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore;

  FirebaseBookingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, Booking>> createBooking(Booking booking) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.bookingsCollection)
          .doc();

      final bookingWithId = booking.copyWith(
        id: docRef.id,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(bookingWithId.toMap());

      return Right(bookingWithId);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getBookingsByTenant(
    String tenantId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('tenantId', isEqualTo: tenantId)
          .orderBy('createdAt', descending: true)
          .get();

      final bookings = querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.data()))
          .toList();

      return Right(bookings);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getBookingsByLandlord(
    String landlordId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('landlordId', isEqualTo: landlordId)
          .orderBy('createdAt', descending: true)
          .get();

      final bookings = querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.data()))
          .toList();

      return Right(bookings);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, Booking>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      final now = DateTime.now();
      final updateData = {
        'status': status,
        'updatedAt': now.millisecondsSinceEpoch,
      };

      // Add responseDate if status is not pending
      if (status != 'pending') {
        updateData['responseDate'] = now.millisecondsSinceEpoch;
      }

      await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .update(updateData);

      final docSnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .get();

      final booking = Booking.fromMap(docSnapshot.data()!);
      return Right(booking);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBooking(String bookingId) async {
    try {
      await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String bookingId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .get();

      if (!docSnapshot.exists) {
        return const Left(ServerFailure('Booking not found'));
      }

      final booking = Booking.fromMap(docSnapshot.data()!);
      return Right(booking);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }
}
