import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../domain/room_repository.dart';
import '../domain/room.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/constants/app_constants.dart';

class FirebaseRoomRepository implements RoomRepository {
  final FirebaseFirestore _firestore;

  FirebaseRoomRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, List<Room>>> getAllRooms() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.roomsCollection)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final rooms = querySnapshot.docs
          .map((doc) => Room.fromMap(doc.data()))
          .toList();

      return Right(rooms);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, List<Room>>> getRoomsByOwner(String ownerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.roomsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      final rooms = querySnapshot.docs
          .map((doc) => Room.fromMap(doc.data()))
          .toList();

      return Right(rooms);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, Room>> createRoom(Room room) async {
    try {
      final docRef = _firestore.collection(AppConstants.roomsCollection).doc();

      final roomWithId = room.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(roomWithId.toMap());

      return Right(roomWithId);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, Room>> updateRoom(Room room) async {
    try {
      final updatedRoom = room.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(AppConstants.roomsCollection)
          .doc(room.id)
          .update(updatedRoom.toMap());

      return Right(updatedRoom);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoom(String roomId) async {
    try {
      await _firestore
          .collection(AppConstants.roomsCollection)
          .doc(roomId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, Room>> getRoomById(String roomId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.roomsCollection)
          .doc(roomId)
          .get();

      if (!docSnapshot.exists) {
        return const Left(ServerFailure('Room not found'));
      }

      final room = Room.fromMap(docSnapshot.data()!);
      return Right(room);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }

  @override
  Future<Either<Failure, List<Room>>> searchRooms({
    String? location,
    String? type,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.roomsCollection)
          .where('isAvailable', isEqualTo: true);

      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }

      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      final rooms = querySnapshot.docs
          .map((doc) => Room.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return Right(rooms);
    } catch (e) {
      return Left(FirebaseErrorHandler.handleGenericError(e));
    }
  }
}
