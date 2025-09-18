import 'package:get_it/get_it.dart';
import 'package:muezzin_flutter/core/services/supabase_service.dart';
import 'package:muezzin_flutter/src/api/azkar_remote_data_source.dart';
import 'package:muezzin_flutter/src/repositories/quiz_repository_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {

  sl.registerLazySingleton(() => SupabaseService());
  // Connectivity for network status
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Data sources
  sl.registerLazySingleton<MuezzinRemoteDataSource>(
    () => MuezzinRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<MuezzinRepository>(
    () => MuezzinRepositoryImpl(
      remoteDataSource: sl(),
      connectivity: sl(),
    ),
  );
}
