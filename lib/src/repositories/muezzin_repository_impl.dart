import 'package:dartz/dartz.dart';
import 'package:muezzin_flutter/core/errors/exceptions.dart';
import 'package:muezzin_flutter/core/errors/failures.dart';
import 'package:muezzin_flutter/src/api/muezzin_remote_data_source.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';


abstract class MuezzinRepository {
 
  
  /// Fetch prayer times for a specific date and location using Aladhan API
  Future<Either<Failure, PrayerTimesData>> getPrayerTimesByDate({
    required String date,
    required double latitude,
    required double longitude,
    int method = 3,
    String? timezone,
    bool iso8601 = false,
  });
  
  
}


class MuezzinRepositoryImpl implements MuezzinRepository {
  final MuezzinRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  MuezzinRepositoryImpl({required this.remoteDataSource, required this.connectivity});


  @override
  Future<Either<Failure, PrayerTimesData>> getPrayerTimesByDate({
    required String date,
    required double latitude,
    required double longitude,
    int method = 3,
    String? timezone,
    bool iso8601 = false,
  }) async {
    try {
      final connectivityResults = await connectivity.checkConnectivity();
      if (connectivityResults.isEmpty || connectivityResults.first == ConnectivityResult.none) {
        return Left(ServerFailure('لا يوجد اتصال بالانترنت'));
      }
      final data = await remoteDataSource.getPrayerTimesByDate(
        date: date,
        latitude: latitude,
        longitude: longitude,
        method: method,
        timezone: timezone,
        iso8601: iso8601,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
