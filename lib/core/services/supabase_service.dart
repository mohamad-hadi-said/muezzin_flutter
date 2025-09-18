import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class SupabaseService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // number of method calls to be displayed
      errorMethodCount: 5, // number of method calls if stacktrace is provided
      lineLength: 50, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Should each log print contain a timestamp
    ),
  );

  static void _log(Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.log(level, message, error: error, stackTrace: stackTrace);
  }
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() {
    _init();
  }

  Future<void> _init() async {
    try {
      _log(Level.info, 'Initializing Supabase...');
      await Supabase.initialize(
        url: 'https://vfdqrhrxflquvbehzdmq.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmZHFyaHJ4ZmxxdXZiZWh6ZG1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxNDQxNjgsImV4cCI6MjA2OTcyMDE2OH0.3pBvO8MX-fkzng2L3BHpQqmgIxasRZq6NjFI2LhSMI8',
      );
      client = Supabase.instance.client;
      _log(Level.info, 'Supabase initialized successfully');
    } catch (e, stackTrace) {
      _log(Level.error, 'Failed to initialize Supabase', e, stackTrace);
      rethrow;
    }
  }

  // Example method to fetch data
  Future<List<Map<String, dynamic>>> fetchData(String tableName) async {
    try {
      _log(Level.debug, 'Fetching data from table: $tableName');
      final response = await client
          .from(tableName)
          .select()
          .order('created_at', ascending: false);
      _log(Level.debug, 'Successfully fetched ${response.length} records from $tableName');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _log(Level.error, 'Error fetching data from $tableName', e, stackTrace);
      rethrow;
    }
  }

  // Example method to insert data
  Future<Map<String, dynamic>> insertData(
      String tableName, Map<String, dynamic> data) async {
    try {
      _log(Level.debug, 'Inserting data into $tableName: $data');
      final response = await client
          .from(tableName)
          .insert(data)
          .select()
          .single();
      _log(Level.debug, 'Successfully inserted data into $tableName');
      return response;
    } catch (e, stackTrace) {
      _log(Level.error, 'Error inserting data into $tableName', e, stackTrace);
      rethrow;
    }
  }

  // Example method to update data
  Future<Map<String, dynamic>> updateData(
      String tableName, String id, Map<String, dynamic> data) async {
    try {
      _log(Level.debug, 'Updating record $id in $tableName with data: $data');
      final response = await client
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      _log(Level.debug, 'Successfully updated record $id in $tableName');
      return response;
    } catch (e, stackTrace) {
      _log(Level.error, 'Error updating record $id in $tableName', e, stackTrace);
      rethrow;
    }
  }

  // Example method to delete data
  Future<void> deleteData(String tableName, String id) async {
    try {
      _log(Level.debug, 'Deleting record $id from $tableName');
      await client
          .from(tableName)
        .delete()
        .eq('id', id);
      _log(Level.debug, 'Successfully deleted record $id from $tableName');
    } catch (e, stackTrace) {
      _log(Level.error, 'Error deleting record $id from $tableName', e, stackTrace);
      rethrow;
    } 
  }
}
