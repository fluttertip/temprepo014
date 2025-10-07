import 'package:dartz/dartz.dart';
import '../domain/room.dart';
import '../../../core/errors/failures.dart';

abstract class RoomRepository {
  Future<Either<Failure, List<Room>>> getAllRooms();
  Future<Either<Failure, List<Room>>> getRoomsByOwner(String ownerId);
  Future<Either<Failure, Room>> createRoom(Room room);
  Future<Either<Failure, Room>> updateRoom(Room room);
  Future<Either<Failure, void>> deleteRoom(String roomId);
  Future<Either<Failure, Room>> getRoomById(String roomId);
  Future<Either<Failure, List<Room>>> searchRooms({
    String? location,
    String? type,
    double? minPrice,
    double? maxPrice,
  });
}
