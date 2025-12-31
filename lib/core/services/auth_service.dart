import 'package:billing_app/core/services/api_service.dart';
import 'package:billing_app/core/services/storage_service.dart';
import 'package:billing_app/models/auth_models.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<ApiResponse<AuthResponse>> signup({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final response = await _api.post<AuthResponse>(
      '/v1/auth/signup',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
      requiresAuth: false,
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.isSuccess && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post<AuthResponse>(
      '/v1/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.isSuccess && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse.error('No refresh token available');
    }

    final response = await _api.post<AuthResponse>(
      '/v1/auth/refresh',
      body: {'refreshToken': refreshToken},
      requiresAuth: false,
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.isSuccess && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  Future<void> logout() async {
    try {
      await _api.post('/v1/auth/logout');
    } finally {
      await _storage.clearAll();
    }
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _storage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    if (authResponse.user != null) {
      await _storage.saveUserData(
        userId: authResponse.user!.id,
        email: authResponse.user!.email,
        hasShop: authResponse.user!.hasShop,
        shopId: authResponse.user!.shopId,
      );
    }
  }

  Future<bool> isLoggedIn() => _storage.isLoggedIn();
  
  Future<bool> hasShop() => _storage.hasShop();
}
