class AuthResponse {
  final bool status;
  final String? message;
  final String? token;
  final AuthUserModel? user;

  AuthResponse({required this.status, this.message, this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Explicit failure if status is false or message says unauthenticated
    final rawStatus = json['status'];
    final rawMessage = json['message']?.toString() ?? '';
    final lowerMessage = rawMessage.toLowerCase();

    bool isSuccess = false;

    if (rawStatus == false ||
        lowerMessage.contains('unauthenticated') ||
        lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('غير مصرح') ||
        lowerMessage.contains('غير سجل') ||
        json.containsKey('errors')) {
      isSuccess = false;
      print(
        'AuthResponse.fromJson: Explicit failure detected in message/status or presence of errors.',
      );
    } else {
      isSuccess =
          (rawStatus == true ||
          rawStatus == 'success' ||
          rawStatus == 'successful');

      // If no explicit status, look for success indicators
      if (!isSuccess) {
        isSuccess =
            json.containsKey('token') ||
            json.containsKey('access_token') ||
            json.containsKey('user') ||
            (json['data'] != null && json['data'] is Map);
      }

      // Check message if still not sure
      if (!isSuccess && rawMessage.isNotEmpty) {
        // Prevent matching "غير صحيحة" or similar negations
        if (!lowerMessage.contains('غير') &&
            !lowerMessage.contains('not') &&
            !lowerMessage.contains('fail') &&
            !lowerMessage.contains('incorrect')) {
          if (lowerMessage.contains('success') ||
              lowerMessage.contains('sent') ||
              lowerMessage.contains('created') ||
              lowerMessage.contains('login') ||
              lowerMessage.contains('تم') ||
              lowerMessage.contains('ارسال') ||
              lowerMessage.contains('صالح') ||
              lowerMessage.contains('صحيح')) {
            isSuccess = true;
          }
        }
      }
    }
    print('AuthResponse.fromJson: Final isSuccess: $isSuccess');

    // Helper to find token in a map
    String? findToken(Map<String, dynamic>? m) {
      if (m == null) return null;
      print('AuthResponse: Checking map keys for token: ${m.keys.toList()}');
      return m['token']?.toString() ??
          m['accessToken']?.toString() ??
          m['access_token']?.toString() ??
          m['authorisation']?['token']?.toString() ??
          m['authorization']?['token']?.toString() ??
          m['data']?['token']?.toString() ??
          m['data']?['access_token']?.toString();
    }

    String? token = findToken(json);
    if (token == null && json['data'] is Map<String, dynamic>) {
      print('AuthResponse: Token not found at root, checking data object...');
      token = findToken(json['data'] as Map<String, dynamic>);
    }

    if (isSuccess && token == null) {
      print(
        'WARNING: AuthResponse.fromJson: API returned success but NO TOKEN WAS FOUND.',
      );
      print('JSON structure: $json');
    } else if (token != null) {
      print(
        'AuthResponse: Token FOUND: ${token.substring(0, token.length > 10 ? 10 : token.length)}...',
      );
    }

    // Helper to find user in a map
    AuthUserModel? findUser(Map<String, dynamic>? m) {
      if (m == null) return null;
      if (m['user'] != null) return AuthUserModel.fromJson(m['user']);
      if (m['id'] != null && m['name'] != null)
        return AuthUserModel.fromJson(m);
      return null;
    }

    AuthUserModel? user = findUser(json);
    if (user == null && json['data'] is Map<String, dynamic>) {
      user = findUser(json['data']);
    }

    return AuthResponse(
      status: isSuccess,
      message: json['message']?.toString() ?? json['msg']?.toString(),
      token: token,
      user: user,
    );
  }
}

class AuthUserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? image;
  final String? role;
  final AuthCustomerData? customer;

  AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.image,
    this.role,
    this.customer,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      image: json['image']?.toString() ?? json['image_url']?.toString(),
      role: json['role']?.toString(),
      customer: json['customer'] != null
          ? AuthCustomerData.fromJson(json['customer'])
          : null,
    );
  }
}

class AuthCustomerData {
  final int? zoneId;
  final double? latitude;
  final double? longitude;
  final dynamic zone;

  AuthCustomerData({this.zoneId, this.latitude, this.longitude, this.zone});

  factory AuthCustomerData.fromJson(Map<String, dynamic> json) {
    return AuthCustomerData(
      zoneId: json['zone_id'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      zone: json['zone'],
    );
  }
}
