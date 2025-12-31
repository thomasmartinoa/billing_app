import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _hasShopKey = 'has_shop';
  static const String _shopIdKey = 'shop_id';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Token Management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // User Data Management
  Future<void> saveUserData({
    required int userId,
    required String email,
    required bool hasShop,
    int? shopId,
  }) async {
    final prefs = await _prefs;
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setBool(_hasShopKey, hasShop);
    if (shopId != null) {
      await prefs.setInt(_shopIdKey, shopId);
    }
  }

  Future<int?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getInt(_userIdKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_userEmailKey);
  }

  Future<bool> hasShop() async {
    final prefs = await _prefs;
    return prefs.getBool(_hasShopKey) ?? false;
  }

  Future<int?> getShopId() async {
    final prefs = await _prefs;
    return prefs.getInt(_shopIdKey);
  }

  Future<void> setHasShop(bool value, {int? shopId}) async {
    final prefs = await _prefs;
    await prefs.setBool(_hasShopKey, value);
    if (shopId != null) {
      await prefs.setInt(_shopIdKey, shopId);
    }
  }

  // Clear All Data
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
