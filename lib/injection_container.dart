import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:muezzin_flutter/src/api/muezzin_remote_data_source.dart';
import 'package:muezzin_flutter/src/repositories/muezzin_repository_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as dev;

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Connectivity for network status
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Dio HTTP client for Aladhan API
  sl.registerLazySingleton<Dio>(
    () {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.aladhan.com/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (log) {
            if (kDebugMode) {
              dev.log(log.toString(), name: 'Dio');
            }
          },
        ),
      );
      return dio;
    }
  );

  // Data sources
  sl.registerLazySingleton<MuezzinRemoteDataSource>(
    () => MuezzinRemoteDataSourceImpl(sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<MuezzinRepository>(
    () => MuezzinRepositoryImpl(remoteDataSource: sl(), connectivity: sl()),
  );
}
