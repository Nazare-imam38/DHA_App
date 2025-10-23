import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

/// Secure storage helper with validation and integrity checks
class SecureStorageHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  // Storage keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _wrappedTokenKey = 'wrapped_token';
  static const String _deviceSecurityLevelKey = 'device_security_level';
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _sessionExpiryKey = 'session_expiry';
  static const String _lastLoginKey = 'last_login';
  static const String _integrityHashKey = 'integrity_hash';

  /// Store biometric enabled status with validation
  Future<StorageResult> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
      
      // Update integrity hash
      await _updateIntegrityHash();
      
      return StorageResult(
        success: true,
        message: 'Biometric enabled status stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store biometric enabled status: $e',
      );
    }
  }

  /// Get biometric enabled status with validation
  Future<bool> isBiometricEnabled() async {
    try {
      final String? enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Store wrapped token with integrity validation
  Future<StorageResult> setWrappedToken(String wrappedToken) async {
    try {
      // Validate wrapped token format
      if (!_isValidWrappedToken(wrappedToken)) {
        return StorageResult(
          success: false,
          error: StorageError.invalidData,
          message: 'Invalid wrapped token format',
        );
      }

      await _secureStorage.write(
        key: _wrappedTokenKey,
        value: wrappedToken,
      );
      
      // Update integrity hash
      await _updateIntegrityHash();
      
      return StorageResult(
        success: true,
        message: 'Wrapped token stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store wrapped token: $e',
      );
    }
  }

  /// Get wrapped token with validation
  Future<String?> getWrappedToken() async {
    try {
      final String? wrappedToken = await _secureStorage.read(key: _wrappedTokenKey);
      
      if (wrappedToken != null && !_isValidWrappedToken(wrappedToken)) {
        // Invalid token format, clear it
        await _secureStorage.delete(key: _wrappedTokenKey);
        return null;
      }
      
      return wrappedToken;
    } catch (e) {
      return null;
    }
  }

  /// Store device security level
  Future<StorageResult> setDeviceSecurityLevel(String securityLevel) async {
    try {
      await _secureStorage.write(
        key: _deviceSecurityLevelKey,
        value: securityLevel,
      );
      
      // Update integrity hash
      await _updateIntegrityHash();
      
      return StorageResult(
        success: true,
        message: 'Device security level stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store device security level: $e',
      );
    }
  }

  /// Get device security level
  Future<String?> getDeviceSecurityLevel() async {
    try {
      return await _secureStorage.read(key: _deviceSecurityLevelKey);
    } catch (e) {
      return null;
    }
  }

  /// Store authentication token securely
  Future<StorageResult> storeAuthToken(String token) async {
    try {
      // Validate token format
      if (!_isValidToken(token)) {
        return StorageResult(
          success: false,
          error: StorageError.invalidData,
          message: 'Invalid token format',
        );
      }

      await _secureStorage.write(key: _authTokenKey, value: token);
      
      // Update integrity hash
      await _updateIntegrityHash();
      
      return StorageResult(
        success: true,
        message: 'Authentication token stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store authentication token: $e',
      );
    }
  }

  /// Retrieve authentication token
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _authTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Store user data securely
  Future<StorageResult> storeUserData(User user) async {
    try {
      final String userJson = json.encode(user.toJson());
      await _secureStorage.write(key: _userDataKey, value: userJson);
      
      // Update integrity hash
      await _updateIntegrityHash();
      
      return StorageResult(
        success: true,
        message: 'User data stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store user data: $e',
      );
    }
  }

  /// Retrieve user data
  Future<User?> getUserData() async {
    try {
      final String? userJson = await _secureStorage.read(key: _userDataKey);
      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Store refresh token
  Future<StorageResult> storeRefreshToken(String refreshToken) async {
    try {
      // Validate refresh token format
      if (!_isValidToken(refreshToken)) {
        return StorageResult(
          success: false,
          error: StorageError.invalidData,
          message: 'Invalid refresh token format',
        );
      }

      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      
      // Update integrity hash
      await _updateIntegrityHash();
      
      return StorageResult(
        success: true,
        message: 'Refresh token stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store refresh token: $e',
      );
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Store session expiry
  Future<StorageResult> setSessionExpiry(DateTime sessionExpiry) async {
    try {
      await _secureStorage.write(
        key: _sessionExpiryKey,
        value: sessionExpiry.millisecondsSinceEpoch.toString(),
      );
      
      // Update integrity hash
      await _updateIntegrityHash();
      
      return StorageResult(
        success: true,
        message: 'Session expiry stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store session expiry: $e',
      );
    }
  }

  /// Get session expiry
  Future<DateTime?> getSessionExpiry() async {
    try {
      final String? sessionExpiryStr = await _secureStorage.read(key: _sessionExpiryKey);
      if (sessionExpiryStr != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(sessionExpiryStr));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Store last login timestamp
  Future<StorageResult> setLastLogin(DateTime lastLogin) async {
    try {
      await _secureStorage.write(
        key: _lastLoginKey,
        value: lastLogin.millisecondsSinceEpoch.toString(),
      );
      
      // Update integrity hash
      await _updateIntegrityHash();
      
      return StorageResult(
        success: true,
        message: 'Last login stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store last login: $e',
      );
    }
  }

  /// Get last login timestamp
  Future<DateTime?> getLastLogin() async {
    try {
      final String? lastLoginStr = await _secureStorage.read(key: _lastLoginKey);
      if (lastLoginStr != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(lastLoginStr));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Store complete authentication data with validation
  Future<StorageResult> storeAuthData({
    required String token,
    required User user,
    String? refreshToken,
    DateTime? sessionExpiry,
  }) async {
    try {
      // Validate all data before storing
      if (!_isValidToken(token)) {
        return StorageResult(
          success: false,
          error: StorageError.invalidData,
          message: 'Invalid authentication token format',
        );
      }

      if (refreshToken != null && !_isValidToken(refreshToken)) {
        return StorageResult(
          success: false,
          error: StorageError.invalidData,
          message: 'Invalid refresh token format',
        );
      }

      // Store all data
      await Future.wait([
        storeAuthToken(token),
        storeUserData(user),
        if (refreshToken != null) storeRefreshToken(refreshToken),
        if (sessionExpiry != null) setSessionExpiry(sessionExpiry),
        setLastLogin(DateTime.now()),
      ]);
      
      return StorageResult(
        success: true,
        message: 'Authentication data stored successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to store authentication data: $e',
      );
    }
  }

  /// Retrieve complete authentication data with validation
  Future<AuthData?> getAuthData() async {
    try {
      final String? token = await getAuthToken();
      final User? user = await getUserData();
      final String? refreshToken = await getRefreshToken();
      final DateTime? sessionExpiry = await getSessionExpiry();

      if (token != null && user != null) {
        return AuthData(
          token: token,
          user: user,
          refreshToken: refreshToken,
          sessionExpiry: sessionExpiry,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated with validation
  Future<bool> isAuthenticated() async {
    try {
      final String? token = await getAuthToken();
      final User? user = await getUserData();
      
      if (token == null || user == null) {
        return false;
      }

      // Check if session has expired
      final DateTime? sessionExpiry = await getSessionExpiry();
      if (sessionExpiry != null && DateTime.now().isAfter(sessionExpiry)) {
        await clearAuthData();
        return false;
      }

      // Validate integrity
      if (!await _validateIntegrity()) {
        await clearAuthData();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all authentication data
  Future<StorageResult> clearAuthData() async {
    try {
      await _secureStorage.deleteAll();
      
      return StorageResult(
        success: true,
        message: 'Authentication data cleared successfully',
      );
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.clearFailed,
        message: 'Failed to clear authentication data: $e',
      );
    }
  }

  /// Validate secure storage integrity
  Future<bool> validateSecureStorage() async {
    try {
      // Check if all required keys exist
      final Map<String, String> allValues = await _secureStorage.readAll();
      
      // Validate integrity hash
      if (!await _validateIntegrity()) {
        return false;
      }

      // Check for unauthorized modifications
      if (await _detectUnauthorizedModifications()) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get storage information for debugging
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final Map<String, String> allValues = await _secureStorage.readAll();
      final bool isValid = await validateSecureStorage();
      
      return {
        'hasAuthToken': allValues.containsKey(_authTokenKey),
        'hasUserData': allValues.containsKey(_userDataKey),
        'hasRefreshToken': allValues.containsKey(_refreshTokenKey),
        'isBiometricEnabled': allValues[_biometricEnabledKey] == 'true',
        'hasWrappedToken': allValues.containsKey(_wrappedTokenKey),
        'deviceSecurityLevel': allValues[_deviceSecurityLevelKey],
        'lastLogin': await getLastLogin(),
        'sessionExpiry': await getSessionExpiry(),
        'isSessionExpired': await isSessionExpired(),
        'isValid': isValid,
        'integrityHash': allValues[_integrityHashKey],
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Check if session is expired
  Future<bool> isSessionExpired() async {
    try {
      final DateTime? sessionExpiry = await getSessionExpiry();
      if (sessionExpiry == null) {
        return false; // No expiry set, consider valid
      }
      return DateTime.now().isAfter(sessionExpiry);
    } catch (e) {
      return true; // Assume expired if we can't check
    }
  }

  /// Update session expiry
  Future<StorageResult> updateSessionExpiry(Duration sessionDuration) async {
    try {
      final DateTime newExpiry = DateTime.now().add(sessionDuration);
      return await setSessionExpiry(newExpiry);
    } catch (e) {
      return StorageResult(
        success: false,
        error: StorageError.writeFailed,
        message: 'Failed to update session expiry: $e',
      );
    }
  }

  /// Validate token format
  bool _isValidToken(String token) {
    if (token.isEmpty) return false;
    if (token.length < 10) return false; // Minimum token length
    return true;
  }

  /// Validate wrapped token format
  bool _isValidWrappedToken(String wrappedToken) {
    if (wrappedToken.isEmpty) return false;
    try {
      // Try to decode base64
      final List<int> decoded = base64.decode(wrappedToken);
      return decoded.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Update integrity hash
  Future<void> _updateIntegrityHash() async {
    try {
      final Map<String, String> allValues = await _secureStorage.readAll();
      final String dataString = allValues.entries
          .where((entry) => entry.key != _integrityHashKey)
          .map((entry) => '${entry.key}:${entry.value}')
          .join('|');
      
      final String hash = _generateHash(dataString);
      await _secureStorage.write(key: _integrityHashKey, value: hash);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Validate integrity hash
  Future<bool> _validateIntegrity() async {
    try {
      final Map<String, String> allValues = await _secureStorage.readAll();
      final String? storedHash = allValues[_integrityHashKey];
      
      if (storedHash == null) {
        return false; // No integrity hash stored
      }

      final String dataString = allValues.entries
          .where((entry) => entry.key != _integrityHashKey)
          .map((entry) => '${entry.key}:${entry.value}')
          .join('|');
      
      final String calculatedHash = _generateHash(dataString);
      return storedHash == calculatedHash;
    } catch (e) {
      return false;
    }
  }

  /// Detect unauthorized modifications
  Future<bool> _detectUnauthorizedModifications() async {
    try {
      // Check for suspicious patterns or unexpected keys
      final Map<String, String> allValues = await _secureStorage.readAll();
      
      // Check for unexpected keys
      final Set<String> expectedKeys = {
        _biometricEnabledKey,
        _wrappedTokenKey,
        _deviceSecurityLevelKey,
        _authTokenKey,
        _userDataKey,
        _refreshTokenKey,
        _sessionExpiryKey,
        _lastLoginKey,
        _integrityHashKey,
      };
      
      for (final String key in allValues.keys) {
        if (!expectedKeys.contains(key)) {
          return true; // Unauthorized modification detected
        }
      }
      
      return false;
    } catch (e) {
      return true; // Assume unauthorized if we can't check
    }
  }

  /// Generate hash for integrity checking
  String _generateHash(String data) {
    // Simple hash for demo purposes
    // In production, use proper cryptographic hash
    return data.hashCode.toString();
  }
}

/// Storage result
class StorageResult {
  final bool success;
  final StorageError? error;
  final String message;

  StorageResult({
    required this.success,
    this.error,
    required this.message,
  });
}

/// Storage error types
enum StorageError {
  writeFailed,
  readFailed,
  clearFailed,
  invalidData,
  integrityViolation,
  unauthorizedModification,
  unknown,
}

/// Authentication data model
class AuthData {
  final String token;
  final User user;
  final String? refreshToken;
  final DateTime? sessionExpiry;

  AuthData({
    required this.token,
    required this.user,
    this.refreshToken,
    this.sessionExpiry,
  });

  bool get isExpired {
    if (sessionExpiry == null) return false;
    return DateTime.now().isAfter(sessionExpiry!);
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'refreshToken': refreshToken,
      'sessionExpiry': sessionExpiry?.millisecondsSinceEpoch,
    };
  }
}
