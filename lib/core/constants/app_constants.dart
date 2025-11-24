class AppConstants {
  // App Info
  static const String appName = 'Room Rental Kathmandu';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String findRoomRole = 'Find Room';
  static const String rentRoomRole = 'Rent Room';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String roomsCollection = 'rooms';
  static const String bookingsCollection = 'bookings';
  static const String favoritesCollection = 'favorites';

  // Room Types
  static const List<String> roomTypes = [
    'Single Room',
    'Double Room',
    'Apartment',
    'Studio',
    'Shared Room',
  ];

  // Locations in Kathmandu
  static const List<String> kathmanduLocations = [
    'Thamel',
    'New Road',
    'Durbar Marg',
    'Baneshwor',
    'Koteshwor',
    'Balaju',
    'Maharajgunj',
    'Dillibazar',
    'Putalisadak',
    'Lazimpat',
    'Naxal',
    'Boudha',
    'Chabahil',
    'Kapan',
    'Budhanilkantha',
    'Samakhusi',
    'Gongabu',
    'Kalimati',
    'Kuleshwor',
    'Swayambhu',
  ];

  // Room Features
  static const List<String> roomFeatures = [
    'WiFi',
    'Air Conditioning',
    'Heater',
    'Parking',
    'Laundry',
    'Kitchen Access',
    'Private Bathroom',
    'Furnished',
    'Security',
    'Water 24/7',
    'Electricity Backup',
  ];

  // Booking Status
  static const String pendingStatus = 'pending';
  static const String confirmedStatus = 'confirmed';
  static const String cancelledStatus = 'cancelled';
  static const String completedStatus = 'completed';

  // Error Messages
  static const String networkError = 'Network error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String authError = 'Authentication error';
  static const String permissionDenied = 'Permission denied';
}
