import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../models/biometric_auth_state.dart';
import '../services/enhanced_biometric_service.dart';
import '../services/secure_storage_helper.dart';
import '../services/enhanced_auth_service.dart';

/// Enhanced authentication provider with comprehensive biometric support
class EnhancedBiometricAuthProvider with ChangeNotifier {
  final EnhancedBiometricService _biometricService = EnhancedBiometricService();
  final SecureStorageHelper _secureStorage = SecureStorageHelper();
  final EnhancedAuthService _authService = EnhancedAuthService();
  
  // Authentication state
  User? _user;
  UserInfo? _userInfo;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  
  // Biometric state
  BiometricAuthStateModel _biometricState = BiometricAuthStateModel.idle();
  bool _canUseBiometric = false;
  bool _biometricSetupRequired = false;
  DateTime? _lastBiometricCheck;
  
  // Session state
  DateTime? _sessionStartTime;
  Duration _idleTimeout = const Duration(minutes: 2);
  bool _isIdle = false;

  // Getters
  User? get user => _user;
  UserInfo? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  BiometricAuthStateModel get biometricState => _biometricState;
  bool get canUseBiometric => _canUseBiometric;
  bool get biometricSetupRequired => _biometricSetupRequired;
  DateTime? get lastBiometricCheck => _lastBiometricCheck;
  bool get isIdle => _isIdle;

  /// Initialize authentication and biometric state
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      // Check authentication status
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await _authService.getStoredUser();
        _sessionStartTime = DateTime.now();
      }

      // Initialize biometric state
      await _initializeBiometricState();
      
      // Check if biometric setup is required after successful login
      if (_isLoggedIn && !_canUseBiometric) {
        _biometricSetupRequired = await _shouldOfferBiometricSetup();
      }
      
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize biometric state
  Future<void> _initializeBiometricState() async {
    try {
      final BiometricStatus biometricStatus = await _biometricService.getBiometricStatus();
      
      if (!biometricStatus.isAvailable) {
        _biometricState = BiometricAuthStateModel.error(
          errorMessage: biometricStatus.message,
          availableTypes: biometricStatus.availableTypes,
        );
        _canUseBiometric = false;
        return;
      }

      if (biometricStatus.isLockedOut) {
        _biometricState = BiometricAuthStateModel.locked(
          retryCount: biometricStatus.retryCount,
          lockoutUntil: DateTime.now().add(const Duration(minutes: 5)), // Simplified
        );
        _canUseBiometric = false;
        return;
      }

      if (biometricStatus.isEnabled) {
        _biometricState = BiometricAuthStateModel.available(
          availableTypes: biometricStatus.availableTypes,
          isEnabled: true,
          lastCheck: _lastBiometricCheck,
        );
        _canUseBiometric = true;
      } else {
        _biometricState = BiometricAuthStateModel.disabled(
          availableTypes: biometricStatus.availableTypes,
          lastCheck: _lastBiometricCheck,
        );
        _canUseBiometric = false;
      }
      
    } catch (e) {
      _biometricState = BiometricAuthStateModel.error(
        errorMessage: 'Failed to initialize biometric state: $e',
      );
      _canUseBiometric = false;
    }
  }

  /// Check if biometric setup should be offered
  Future<bool> _shouldOfferBiometricSetup() async {
    try {
      // Only offer if user is logged in and biometric is available but not enabled
      if (!_isLoggedIn) return false;
      
      final BiometricStatus biometricStatus = await _biometricService.getBiometricStatus();
      return biometricStatus.isAvailable && !biometricStatus.isEnabled;
    } catch (e) {
      return false;
    }
  }

  /// Enhanced login with biometric support
  Future<LoginResponse> login(LoginRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.login(request);
      _user = response.user;
      _isLoggedIn = true;
      _sessionStartTime = DateTime.now();
      
      // Check if biometric setup should be offered
      _biometricSetupRequired = await _shouldOfferBiometricSetup();
      
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Login failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Enhanced OTP verification with biometric support
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.verifyOtp(request);
      _user = response.user;
      _isLoggedIn = true;
      _sessionStartTime = DateTime.now();
      
      // Check if biometric setup should be offered
      _biometricSetupRequired = await _shouldOfferBiometricSetup();
      
      notifyListeners();
      return response;
    } catch (e) {
      _setError('OTP verification failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Biometric login with enhanced security
  Future<BiometricLoginResult> loginWithBiometric() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check if biometric can be used
      if (!_canUseBiometric) {
        return BiometricLoginResult(
          success: false,
          error: 'Biometric authentication is not available or enabled',
          requiresPassword: true,
        );
      }

      // Check if user is idle and needs re-authentication
      if (_isIdle) {
        final BiometricAuthResult authResult = await _biometricService.authenticateWithBiometric(
          reason: 'Re-authenticate to continue using the app',
        );
        
        if (!authResult.success) {
          return BiometricLoginResult(
            success: false,
            error: authResult.message,
            requiresPassword: false,
          );
        }
        
        _isIdle = false;
        _lastBiometricCheck = DateTime.now();
        notifyListeners();
        return BiometricLoginResult(
          success: true,
          message: 'Re-authentication successful',
        );
      }

      // Perform biometric authentication
      final BiometricTokenResult tokenResult = await _biometricService.unwrapTokenWithBiometricKey();
      
      if (!tokenResult.success) {
        return BiometricLoginResult(
          success: false,
          error: tokenResult.message,
          requiresPassword: true,
        );
      }

      // Set user as logged in
      _isLoggedIn = true;
      _sessionStartTime = DateTime.now();
      _lastBiometricCheck = DateTime.now();
      
      // Get user data from secure storage
      final AuthData? authData = await _secureStorage.getAuthData();
      if (authData != null) {
        _user = authData.user;
      }
      
      notifyListeners();
      return BiometricLoginResult(
        success: true,
        message: 'Biometric login successful',
      );
    } catch (e) {
      _setError('Biometric login failed: $e');
      return BiometricLoginResult(
        success: false,
        error: 'Biometric login failed: $e',
        requiresPassword: true,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Enable biometric authentication
  Future<BiometricResult> enableBiometric() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check if user is logged in
      if (!_isLoggedIn) {
        return BiometricResult(
          success: false,
          error: BiometricError.enableFailed,
          message: 'User must be logged in to enable biometric authentication',
        );
      }

      // Enable biometric authentication
      final BiometricResult enableResult = await _biometricService.enableBiometric();
      
      if (enableResult.success) {
        // Wrap current authentication token
        final String? token = await _authService.getToken();
        if (token != null) {
          final BiometricTokenResult wrapResult = await _biometricService.wrapTokenWithBiometricKey(token);
          
          if (wrapResult.success) {
            // Update biometric state
            await _initializeBiometricState();
            _biometricSetupRequired = false;
            notifyListeners();
          }
        }
      }
      
      return enableResult;
    } catch (e) {
      _setError('Failed to enable biometric authentication: $e');
      return BiometricResult(
        success: false,
        error: BiometricError.enableFailed,
        message: 'Failed to enable biometric authentication: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Disable biometric authentication
  Future<BiometricResult> disableBiometric() async {
    _setLoading(true);
    _clearError();
    
    try {
      final BiometricResult disableResult = await _biometricService.disableBiometric();
      
      if (disableResult.success) {
        // Update biometric state
        await _initializeBiometricState();
        notifyListeners();
      }
      
      return disableResult;
    } catch (e) {
      _setError('Failed to disable biometric authentication: $e');
      return BiometricResult(
        success: false,
        error: BiometricError.disableFailed,
        message: 'Failed to disable biometric authentication: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Skip biometric setup
  void skipBiometricSetup() {
    _biometricSetupRequired = false;
    notifyListeners();
  }

  /// Handle app resume - check if re-authentication is needed
  Future<void> handleAppResume() async {
    if (!_isLoggedIn) return;
    
    try {
      // Check if user has been idle for too long
      if (_sessionStartTime != null) {
        final Duration idleTime = DateTime.now().difference(_sessionStartTime!);
        if (idleTime > _idleTimeout) {
          _isIdle = true;
          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Refresh biometric status
  Future<void> refreshBiometricStatus() async {
    try {
      await _initializeBiometricState();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh biometric status: $e');
    }
  }

  /// Enhanced logout with biometric cleanup
  Future<void> logout() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Clear biometric data
      await _biometricService.disableBiometric();
      
      // Clear authentication data
      await _authService.logout();
      
      // Reset state
      _user = null;
      _userInfo = null;
      _isLoggedIn = false;
      _canUseBiometric = false;
      _biometricSetupRequired = false;
      _biometricState = BiometricAuthStateModel.idle();
      _sessionStartTime = null;
      _isIdle = false;
      _lastBiometricCheck = null;
      
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get comprehensive authentication status
  Future<Map<String, dynamic>> getAuthStatus() async {
    try {
      final Map<String, dynamic> authStatus = await _authService.getAuthStatus();
      final Map<String, dynamic> storageInfo = await _secureStorage.getStorageInfo();
      
      return {
        ...authStatus,
        'biometricState': _biometricState.toJson(),
        'canUseBiometric': _canUseBiometric,
        'biometricSetupRequired': _biometricSetupRequired,
        'isIdle': _isIdle,
        'sessionStartTime': _sessionStartTime?.millisecondsSinceEpoch,
        'storageInfo': storageInfo,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'isLoggedIn': _isLoggedIn,
        'canUseBiometric': _canUseBiometric,
        'biometricState': _biometricState.toJson(),
      };
    }
  }

  /// Update idle timeout
  void updateIdleTimeout(Duration timeout) {
    _idleTimeout = timeout;
  }

  /// Reset idle state
  void resetIdleState() {
    _isIdle = false;
    _sessionStartTime = DateTime.now();
    notifyListeners();
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
}

/// Biometric login result
class BiometricLoginResult {
  final bool success;
  final String? error;
  final String? message;
  final bool requiresPassword;

  BiometricLoginResult({
    required this.success,
    this.error,
    this.message,
    this.requiresPassword = false,
  });
}
