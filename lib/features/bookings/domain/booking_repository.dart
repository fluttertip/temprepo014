import 'package:dartz/dartz.dart';
import '../domain/booking.dart';
import '../../../core/errors/failures.dart';

abstract class BookingRepository {
  Future<Either<Failure, Booking>> createBooking(Booking booking);
  Future<Either<Failure, List<Booking>>> getBookingsByTenant(String tenantId);
  Future<Either<Failure, List<Booking>>> getBookingsByLandlord(
    String landlordId,
  );
  Future<Either<Failure, Booking>> updateBookingStatus(
    String bookingId,
    String status,
  );
  Future<Either<Failure, void>> deleteBooking(String bookingId);
  Future<Either<Failure, Booking>> getBookingById(String bookingId);
}
