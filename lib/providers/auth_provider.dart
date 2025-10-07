import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserInfo? _userInfo;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  // Getters
  User? get user => _user;
  UserInfo? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize authentication state
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await _authService.getStoredUser();
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Register user
  Future<RegisterResponse> register(RegisterRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.register(request);
      return response;
    } catch (e) {
      _setError('Registration failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.verifyOtp(request);
      _user = response.user;
      _isLoggedIn = true;
      notifyListeners();
      return response;
    } catch (e) {
      _setError('OTP verification failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<LoginResponse> login(LoginRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.login(request);
      _user = response.user;
      _isLoggedIn = true;
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Login failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<ResendOtpResponse> resendOtp(ResendOtpRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.resendOtp(request);
      return response;
    } catch (e) {
      _setError('Resend OTP failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get user info
  Future<UserInfoResponse> getUserInfo() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.getUserInfo();
      _user = response.data.user;
      _userInfo = response.data;
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to get user info: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get user by CNIC
  Future<UserByCnicResponse> getUserByCnic(String cnic) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.getUserByCnic(cnic);
      return response;
    } catch (e) {
      _setError('Failed to get user by CNIC: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<ApiResponse> changePassword(ChangePasswordRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.changePassword(request);
      return response;
    } catch (e) {
      _setError('Change password failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<ApiResponse> forgotPassword(ForgotPasswordRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.forgotPassword(request);
      return response;
    } catch (e) {
      _setError('Forgot password failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Change address
  Future<ApiResponse> changeAddress(ChangeAddressRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.changeAddress(request);
      // Refresh user data after successful address change
      await refreshUserData();
      return response;
    } catch (e) {
      _setError('Change address failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<ApiResponse> updateProfile(UpdateProfileRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.updateProfile(request);
      // Refresh user data after successful profile update
      await refreshUserData();
      return response;
    } catch (e) {
      _setError('Update profile failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      final refreshedUser = await _authService.refreshUserData();
      if (refreshedUser != null) {
        _user = refreshedUser;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to refresh user data: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
