import 'dart:developer' as dev;

import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/errors/exceptions.dart';
import 'package:muezzin_flutter/src/model/azkar_model.dart';
import 'package:muezzin_flutter/core/services/supabase_service.dart';

abstract class MuezzinRemoteDataSource {
  Future<List<MuezzinModel>> getAllMuezzin();
  Future<int> getUserScore(String userId);
}

class MuezzinRemoteDataSourceImpl implements MuezzinRemoteDataSource {
  final SupabaseService _supabaseService;

  MuezzinRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<List<MuezzinModel>> getAllMuezzin() async {
    try {
      dev.log('Fetching azkar from Supabase...');
      final response = await _supabaseService.fetchData('azkar');
      dev.log('Supabase response: ${response.toString()}');
      dev.log('Response type: ${response.runtimeType}');
      dev.log('Response length: ${(response as List).length}');

      if (response.isEmpty) {
        dev.log('Warning: No azkar found in database');
        return [];
      }
      final azkar =
          (response as List)
              .map(
                (q) =>
                    MuezzinModel.fromJson(Map<String, dynamic>.from(q as Map)),
              )
              .toList();
      dev.log('Successfully parsed ${azkar.length} azkar');
      await AppCache.instance.saveMuezzin(azkar);
      return azkar;
    } catch (e) {
      dev.log('Error fetching azkar: ${e.toString()}');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<int> getUserScore(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('user_profiles')
          .select('score')
          .eq('id', userId)
          .single()
          .catchError((_) => <String, dynamic>{});

      if (response.isNotEmpty) {
        return response['score'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      // If there's an error (e.g., user doesn't exist), return 0
      return 0;
    }
  }
}
