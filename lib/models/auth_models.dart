class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserInfo? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 0,
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }
}

class UserInfo {
  final int id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool hasShop;
  final int? shopId;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.hasShop,
    this.shopId,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      hasShop: json['hasShop'] ?? false,
      shopId: json['shopId'],
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class SignupRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;

  SignupRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
  };
}
