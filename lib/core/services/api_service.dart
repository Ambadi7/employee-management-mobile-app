import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get dio => _dio;

  static Future<Response?> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Response?> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
