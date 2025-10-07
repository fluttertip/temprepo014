import 'package:flutter/foundation.dart';
import 'package:mvproomrentandbook/features/rooms/domain/room.dart';
import 'package:mvproomrentandbook/features/rooms/domain/room_repository.dart';


enum RoomState { initial, loading, loaded, error }

class RoomProvider extends ChangeNotifier {
  final RoomRepository _roomRepository;

  RoomProvider(this._roomRepository);

  RoomState _state = RoomState.initial;
  List<Room> _rooms = [];
  List<Room> _myRooms = [];
  List<Room> _favoriteRooms = [];
  String? _errorMessage;

  RoomState get state => _state;
  List<Room> get rooms => _rooms;
  List<Room> get myRooms => _myRooms;
  List<Room> get favoriteRooms => _favoriteRooms;
  String? get errorMessage => _errorMessage;

  Future<void> loadRooms() async {
    _setState(RoomState.loading, null);

    final result = await _roomRepository.getAllRooms();
    result.fold((failure) => _setState(RoomState.error, failure.message), (
      rooms,
    ) {
      _rooms = rooms;
      _setState(RoomState.loaded, null);
    });
  }

  Future<void> loadMyRooms(String ownerId) async {
    _setState(RoomState.loading, null);

    final result = await _roomRepository.getRoomsByOwner(ownerId);
    result.fold((failure) => _setState(RoomState.error, failure.message), (
      rooms,
    ) {
      _myRooms = rooms;
      _setState(RoomState.loaded, null);
    });
  }

  Future<bool> createRoom(Room room) async {
    _setState(RoomState.loading, null);

    final result = await _roomRepository.createRoom(room);
    return result.fold(
      (failure) {
        _setState(RoomState.error, failure.message);
        return false;
      },
      (createdRoom) {
        _myRooms.insert(0, createdRoom);
        _setState(RoomState.loaded, null);
        return true;
      },
    );
  }

  Future<bool> updateRoom(Room room) async {
    _setState(RoomState.loading, null);

    final result = await _roomRepository.updateRoom(room);
    return result.fold(
      (failure) {
        _setState(RoomState.error, failure.message);
        return false;
      },
      (updatedRoom) {
        // Update in my rooms list
        final index = _myRooms.indexWhere((r) => r.id == updatedRoom.id);
        if (index != -1) {
          _myRooms[index] = updatedRoom;
        }

        // Update in all rooms list
        final allIndex = _rooms.indexWhere((r) => r.id == updatedRoom.id);
        if (allIndex != -1) {
          _rooms[allIndex] = updatedRoom;
        }

        _setState(RoomState.loaded, null);
        return true;
      },
    );
  }

  Future<bool> deleteRoom(String roomId) async {
    _setState(RoomState.loading, null);

    final result = await _roomRepository.deleteRoom(roomId);
    return result.fold(
      (failure) {
        _setState(RoomState.error, failure.message);
        return false;
      },
      (_) {
        _myRooms.removeWhere((room) => room.id == roomId);
        _rooms.removeWhere((room) => room.id == roomId);
        _setState(RoomState.loaded, null);
        return true;
      },
    );
  }

  Future<Room?> getRoomById(String roomId) async {
    final result = await _roomRepository.getRoomById(roomId);
    return result.fold((failure) {
      _errorMessage = failure.message;
      return null;
    }, (room) => room);
  }

  Future<void> searchRooms({
    String? location,
    String? type,
    double? minPrice,
    double? maxPrice,
  }) async {
    _setState(RoomState.loading, null);

    final result = await _roomRepository.searchRooms(
      location: location,
      type: type,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    result.fold((failure) => _setState(RoomState.error, failure.message), (
      rooms,
    ) {
      _rooms = rooms;
      _setState(RoomState.loaded, null);
    });
  }

  void toggleFavorite(Room room) {
    if (_favoriteRooms.any((r) => r.id == room.id)) {
      _favoriteRooms.removeWhere((r) => r.id == room.id);
    } else {
      _favoriteRooms.add(room);
    }
    notifyListeners();
  }

  bool isFavorite(String roomId) {
    return _favoriteRooms.any((room) => room.id == roomId);
  }

  void _setState(RoomState newState, String? errorMessage) {
    _state = newState;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == RoomState.error) {
      _state = RoomState.initial;
    }
    notifyListeners();
  }
}
