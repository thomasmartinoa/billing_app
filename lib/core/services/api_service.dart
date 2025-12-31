import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:billing_app/core/config/api_config.dart';
import 'package:billing_app/core/services/storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    
    if (requiresAuth) {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .delete(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null && body['data'] != null) {
        return ApiResponse.success(
          fromJson(body['data']),
          message: body['message'],
        );
      }
      return ApiResponse.success(body['data'], message: body['message']);
    } else if (response.statusCode == 401) {
      return ApiResponse.error(body['message'] ?? 'Unauthorized');
    } else {
      return ApiResponse.error(body['message'] ?? 'An error occurred');
    }
  }
}

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final String? error;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.success(T? data, {String? message}) {
    return ApiResponse._(isSuccess: true, data: data, message: message);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse._(isSuccess: false, error: error);
  }
}
