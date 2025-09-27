import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String baseUrl = 'https://backend-apis.dhamarketplace.com/api';
  
  // SharedPreferences keys
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user data
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Store authentication data
  Future<void> _storeAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Clear authentication data
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Helper method to get headers
  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Helper method to handle API responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'An error occurred');
    }
  }

  // 1. User Registration
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: await _getHeaders(),
        body: request.toFormData(),
      );

      final data = _handleResponse(response);
      return RegisterResponse.fromJson(data);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // 2. Verify OTP
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: await _getHeaders(),
        body: request.toFormData(),
      );

      final data = _handleResponse(response);
      final verifyResponse = VerifyOtpResponse.fromJson(data);
      
      // Store authentication data after successful verification
      await _storeAuthData(verifyResponse.accessToken, verifyResponse.user);
      
      return verifyResponse;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // 3. Login
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(),
        body: request.toFormData(),
      );

      final data = _handleResponse(response);
      final loginResponse = LoginResponse.fromJson(data);
      
      // Store authentication data after successful login
      await _storeAuthData(loginResponse.token, loginResponse.user);
      
      return loginResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // 4. Resend OTP
  Future<ResendOtpResponse> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: await _getHeaders(),
        body: request.toFormData(),
      );

      final data = _handleResponse(response);
      return ResendOtpResponse.fromJson(data);
    } catch (e) {
      throw Exception('Resend OTP failed: $e');
    }
  }

  // 5. Get User Info
  Future<UserInfoResponse> getUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: await _getHeaders(includeAuth: true),
      );

      final data = _handleResponse(response);
      return UserInfoResponse.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  // 6. Get User by CNIC
  Future<UserByCnicResponse> getUserByCnic(String cnic) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-by-cnic?cnic=$cnic'),
        headers: await _getHeaders(includeAuth: true),
      );

      final data = _handleResponse(response);
      return UserByCnicResponse.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user by CNIC: $e');
    }
  }

  // 7. Change Password
  Future<ApiResponse> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: await _getHeaders(includeAuth: true),
        body: request.toFormData(),
      );

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data);
    } catch (e) {
      throw Exception('Change password failed: $e');
    }
  }

  // 8. Forgot Password
  Future<ApiResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: await _getHeaders(includeAuth: true),
        body: request.toFormData(),
      );

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data);
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  // 9. Change Address
  Future<ApiResponse> changeAddress(ChangeAddressRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-address'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data);
    } catch (e) {
      throw Exception('Change address failed: $e');
    }
  }

  // 10. Update Profile
  Future<ApiResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-profile'),
        headers: await _getHeaders(includeAuth: true),
        body: request.toFormData(),
      );

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data);
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await clearAuthData();
  }

  // Refresh user data
  Future<User?> refreshUserData() async {
    try {
      final userInfoResponse = await getUserInfo();
      final user = userInfoResponse.data.user;
      
      // Update stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
      
      return user;
    } catch (e) {
      // If refresh fails, return stored user data
      return await getStoredUser();
    }
  }
}
