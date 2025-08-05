import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserStorageService {
  // Keys for storing data
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _loginTimeKey = 'login_time';
  static const String _isLoggedInKey = 'is_logged_in';

  // Store access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Store refresh token
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Store user data as JSON
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = json.encode(userData);
    await prefs.setString(_userDataKey, userDataJson);
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    if (userDataJson != null) {
      return json.decode(userDataJson) as Map<String, dynamic>;
    }
    return null;
  }

  // Store login status
  static Future<void> setLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);

    // Store login time if logging in
    if (isLoggedIn) {
      await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get login time
  static Future<DateTime?> getLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_loginTimeKey);
    if (loginTime != null) {
      return DateTime.fromMillisecondsSinceEpoch(loginTime);
    }
    return null;
  }

  // Store complete authentication data
  static Future<void> saveAuthenticationData({
    required String accessToken,
    String? refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    await saveAccessToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
    await saveUserData(userData);
    await setLoginStatus(true);

    print('Authentication data saved successfully');
    print('Access token: ${accessToken.substring(0, 20)}...');
    print('User data: ${userData.toString()}');
  }

  // Clear all stored data (logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_loginTimeKey);
    await prefs.setBool(_isLoggedInKey, false);

    print('All authentication data cleared');
  }

  // Check if token is expired (optional - for future use)
  static Future<bool> isTokenExpired() async {
    final loginTime = await getLoginTime();
    if (loginTime == null) return true;

    // Assume token expires after 1 hour (adjust as needed)
    final expirationTime = loginTime.add(Duration(hours: 1));
    return DateTime.now().isAfter(expirationTime);
  }

  // Get all stored data for debugging
  static Future<Map<String, dynamic>> getAllStoredData() async {
    return {
      'access_token': await getAccessToken(),
      'refresh_token': await getRefreshToken(),
      'user_data': await getUserData(),
      'is_logged_in': await isLoggedIn(),
      'login_time': await getLoginTime(),
    };
  }
}
