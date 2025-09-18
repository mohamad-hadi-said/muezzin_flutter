import 'package:dartz/dartz.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/errors/exceptions.dart';
import 'package:muezzin_flutter/core/errors/failures.dart';
import 'package:muezzin_flutter/src/api/azkar_remote_data_source.dart';
import 'package:muezzin_flutter/src/model/azkar_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


abstract class MuezzinRepository {
 
  /// Fetches all azkar (for admin purposes or initial load)
  Future<Either<Failure, List<MuezzinModel>>> getAllMuezzin();
  
  /// Gets the user's current score
  Future<Either<Failure, int>> getUserScore(String userId);
  
}


class MuezzinRepositoryImpl implements MuezzinRepository {
  final MuezzinRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  MuezzinRepositoryImpl({required this.remoteDataSource, required this.connectivity});


  @override
  Future<Either<Failure, List<MuezzinModel>>> getAllMuezzin() async {
    try {
      final connectivityResults = await connectivity.checkConnectivity();
      if (connectivityResults.isEmpty || connectivityResults.first == ConnectivityResult.none) {
        List<MuezzinModel> azkar = AppCache.instance.getMuezzin();
        if(azkar.isEmpty){
          return Left(ServerFailure('لا يوجد اتصال بالانترنت \n قم بالتصال بالانترنت لتحميل الأذكار'));
        }
        return Right(azkar);
      }
      final azkar = await remoteDataSource.getAllMuezzin();
      return Right(azkar);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUserScore(String userId) async {
    try {
      final score = await remoteDataSource.getUserScore(userId);
      return Right(score);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
