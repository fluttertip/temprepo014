import 'package:flutter/foundation.dart';
import 'package:mvproomrentandbook/features/bookings/domain/booking.dart';
import 'package:mvproomrentandbook/features/bookings/domain/booking_repository.dart';

enum BookingState { initial, loading, loaded, error }

class BookingProvider extends ChangeNotifier {
  final BookingRepository _bookingRepository;

  BookingProvider(this._bookingRepository);

  BookingState _state = BookingState.initial;
  List<Booking> _tenantBookings = [];
  List<Booking> _landlordBookings = [];
  String? _errorMessage;

  BookingState get state => _state;
  List<Booking> get tenantBookings => _tenantBookings;
  List<Booking> get landlordBookings => _landlordBookings;
  String? get errorMessage => _errorMessage;

  // Add method to check if user already booked a room
  bool hasUserBookedRoom(String tenantId, String roomId) {
    return _tenantBookings.any(
      (booking) =>
          booking.tenantId == tenantId &&
          booking.roomId == roomId &&
          booking.status != BookingStatus.cancelled &&
          booking.status != BookingStatus.rejected,
    );
  }

  // Add method to get user's booking for a specific room
  Booking? getUserBookingForRoom(String tenantId, String roomId) {
    try {
      return _tenantBookings.firstWhere(
        (booking) =>
            booking.tenantId == tenantId &&
            booking.roomId == roomId &&
            booking.status != BookingStatus.cancelled &&
            booking.status != BookingStatus.rejected,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> createBooking(Booking booking) async {
    // Check for duplicate booking before creating

    if (hasUserBookedRoom(booking.tenantId, booking.roomId)) {
      _errorMessage = 'You have already booked this room';
      notifyListeners();
      return false;
    }
    _setState(BookingState.loading, null);

    final result = await _bookingRepository.createBooking(booking);
    return result.fold(
      (failure) {
        _setState(BookingState.error, failure.message);
        return false;
      },
      (createdBooking) {
        _tenantBookings.insert(0, createdBooking);
        _setState(BookingState.loaded, null);
        return true;
      },
    );
  }

  Future<void> loadTenantBookings(String tenantId) async {
    _setState(BookingState.loading, null);

    final result = await _bookingRepository.getBookingsByTenant(tenantId);
    result.fold((failure) => _setState(BookingState.error, failure.message), (
      bookings,
    ) {
      _tenantBookings = bookings;
      _setState(BookingState.loaded, null);
    });
  }

  Future<void> loadLandlordBookings(String landlordId) async {
    _setState(BookingState.loading, null);

    final result = await _bookingRepository.getBookingsByLandlord(landlordId);
    result.fold((failure) => _setState(BookingState.error, failure.message), (
      bookings,
    ) {
      _landlordBookings = bookings;
      _setState(BookingState.loaded, null);
    });
  }

  // Fixed: Now accepts BookingStatus enum and converts to string
  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    _setState(BookingState.loading, null);

    final result = await _bookingRepository.updateBookingStatus(
      bookingId,
      status.name, // Convert enum to string
    );
    return result.fold(
      (failure) {
        _setState(BookingState.error, failure.message);
        return false;
      },
      (updatedBooking) {
        // Update responseDate when status changes from pending
        final bookingWithResponse = updatedBooking.copyWith(
          responseDate: status != BookingStatus.pending ? DateTime.now() : null,
        );

        // Update in tenant bookings list
        final tenantIndex = _tenantBookings.indexWhere(
          (b) => b.id == bookingWithResponse.id,
        );
        if (tenantIndex != -1) {
          _tenantBookings[tenantIndex] = bookingWithResponse;
        }

        // Update in landlord bookings list
        final landlordIndex = _landlordBookings.indexWhere(
          (b) => b.id == bookingWithResponse.id,
        );
        if (landlordIndex != -1) {
          _landlordBookings[landlordIndex] = bookingWithResponse;
        }

        _setState(BookingState.loaded, null);
        return true;
      },
    );
  }

  Future<bool> deleteBooking(String bookingId) async {
    _setState(BookingState.loading, null);

    final result = await _bookingRepository.deleteBooking(bookingId);
    return result.fold(
      (failure) {
        _setState(BookingState.error, failure.message);
        return false;
      },
      (_) {
        _tenantBookings.removeWhere((booking) => booking.id == bookingId);
        _landlordBookings.removeWhere((booking) => booking.id == bookingId);
        _setState(BookingState.loaded, null);
        return true;
      },
    );
  }

  Future<Booking?> getBookingById(String bookingId) async {
    final result = await _bookingRepository.getBookingById(bookingId);
    return result.fold((failure) {
      _errorMessage = failure.message;
      return null;
    }, (booking) => booking);
  }

  List<Booking> getBookingsByStatus(BookingStatus status, bool isLandlord) {
    final bookings = isLandlord ? _landlordBookings : _tenantBookings;
    return bookings.where((booking) => booking.status == status).toList();
  }

  void _setState(BookingState newState, String? errorMessage) {
    _state = newState;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == BookingState.error) {
      _state = BookingState.initial;
    }
    notifyListeners();
  }
}
