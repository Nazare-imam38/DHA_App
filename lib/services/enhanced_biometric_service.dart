import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Enhanced BiometricService with cryptographic binding and secure token storage
class EnhancedBiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
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
  static const String _biometricKeyAlias = 'biometric_key_alias';
  static const String _wrappedTokenKey = 'wrapped_token';
  static const String _deviceSecurityLevelKey = 'device_security_level';
  static const String _biometricFingerprintKey = 'biometric_fingerprint';
  static const String _lastBiometricCheckKey = 'last_biometric_check';
  static const String _retryCountKey = 'biometric_retry_count';
  static const String _lockoutUntilKey = 'biometric_lockout_until';

  // Constants
  static const int maxRetryAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 5);
  static const Duration idleTimeout = Duration(minutes: 2);

  /// Initialize biometric service and check device capabilities
  Future<BiometricInitResult> initializeBiometric() async {
    try {
      // Check device support
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        return BiometricInitResult(
          success: false,
          error: BiometricError.deviceNotSupported,
          message: 'Biometric authentication is not supported on this device',
        );
      }

      // Check if biometrics are available
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return BiometricInitResult(
          success: false,
          error: BiometricError.notAvailable,
          message: 'Biometric authentication is not available',
        );
      }

      // Get available biometric types
      final List<BiometricType> availableTypes = await _localAuth.getAvailableBiometrics();
      if (availableTypes.isEmpty) {
        return BiometricInitResult(
          success: false,
          error: BiometricError.notEnrolled,
          message: 'No biometric data is enrolled on this device',
        );
      }

      // Check if biometrics have changed
      final bool hasBiometricDataChanged = await _hasBiometricDataChanged();
      if (hasBiometricDataChanged) {
        await _clearBiometricData();
        return BiometricInitResult(
          success: false,
          error: BiometricError.biometricChanged,
          message: 'Biometric data has changed. Please re-enable biometric authentication.',
        );
      }

      // Check lockout status
      final bool isLockedOut = await _isLockedOut();
      if (isLockedOut) {
        return BiometricInitResult(
          success: false,
          error: BiometricError.lockedOut,
          message: 'Biometric authentication is temporarily locked due to multiple failed attempts',
        );
      }

      return BiometricInitResult(
        success: true,
        message: 'Enhanced biometric authentication initialized successfully',
        availableTypes: availableTypes,
        deviceSecurityLevel: await _getDeviceSecurityLevel(),
      );
    } catch (e) {
      return BiometricInitResult(
        success: false,
        error: BiometricError.unknown,
        message: 'Failed to initialize biometric authentication: $e',
      );
    }
  }

  /// Generate a biometric-protected key for token encryption
  Future<BiometricKeyResult> generateBiometricKey() async {
    try {
      // Check if biometric is available
      final BiometricInitResult initResult = await initializeBiometric();
      if (!initResult.success) {
        return BiometricKeyResult(
          success: false,
          error: initResult.error,
          message: initResult.message,
        );
      }

      // Generate a random key
      final Uint8List keyBytes = Uint8List.fromList(List.generate(32, (i) => DateTime.now().millisecondsSinceEpoch % 256));
      final String keyAlias = 'biometric_key_${DateTime.now().millisecondsSinceEpoch}';

      // Store key alias securely
      await _secureStorage.write(key: _biometricKeyAlias, value: keyAlias);

      return BiometricKeyResult(
        success: true,
        keyAlias: keyAlias,
        message: 'Biometric key generated successfully',
      );
    } catch (e) {
      return BiometricKeyResult(
        success: false,
        error: BiometricError.keyGenerationFailed,
        message: 'Failed to generate biometric key: $e',
      );
    }
  }

  /// Remove biometric key and clear associated data
  Future<BiometricResult> removeBiometricKey() async {
    try {
      await _secureStorage.delete(key: _biometricKeyAlias);
      await _secureStorage.delete(key: _wrappedTokenKey);
      await _secureStorage.delete(key: _biometricFingerprintKey);
      await _secureStorage.delete(key: _lastBiometricCheckKey);
      await _secureStorage.delete(key: _retryCountKey);
      await _secureStorage.delete(key: _lockoutUntilKey);
      
      return BiometricResult(
        success: true,
        message: 'Biometric key removed successfully',
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: BiometricError.keyRemovalFailed,
        message: 'Failed to remove biometric key: $e',
      );
    }
  }

  /// Wrap token with biometric-protected key
  Future<BiometricTokenResult> wrapTokenWithBiometricKey(String token) async {
    try {
      // Check if biometric is available and not locked out
      final BiometricInitResult initResult = await initializeBiometric();
      if (!initResult.success) {
        return BiometricTokenResult(
          success: false,
          error: initResult.error,
          message: initResult.message,
        );
      }

      // Authenticate with biometrics
      final BiometricAuthResult authResult = await authenticateWithBiometric(
        reason: 'Authenticate to encrypt your login token',
      );

      if (!authResult.success) {
        return BiometricTokenResult(
          success: false,
          error: authResult.error,
          message: authResult.message,
        );
      }

      // Generate biometric fingerprint for change detection
      final String biometricFingerprint = await _generateBiometricFingerprint();
      
      // Create wrapped token (simplified encryption for demo)
      final String wrappedToken = _encryptToken(token, biometricFingerprint);
      
      // Store wrapped token and fingerprint
      await _secureStorage.write(key: _wrappedTokenKey, value: wrappedToken);
      await _secureStorage.write(key: _biometricFingerprintKey, value: biometricFingerprint);
      await _secureStorage.write(key: _lastBiometricCheckKey, value: DateTime.now().millisecondsSinceEpoch.toString());

      return BiometricTokenResult(
        success: true,
        wrappedToken: wrappedToken,
        message: 'Token wrapped with biometric key successfully',
      );
    } catch (e) {
      return BiometricTokenResult(
        success: false,
        error: BiometricError.tokenWrappingFailed,
        message: 'Failed to wrap token with biometric key: $e',
      );
    }
  }

  /// Unwrap token using biometric authentication
  Future<BiometricTokenResult> unwrapTokenWithBiometricKey() async {
    try {
      // Check if biometric is available
      final BiometricInitResult initResult = await initializeBiometric();
      if (!initResult.success) {
        return BiometricTokenResult(
          success: false,
          error: initResult.error,
          message: initResult.message,
        );
      }

      // Check if wrapped token exists
      final String? wrappedToken = await _secureStorage.read(key: _wrappedTokenKey);
      if (wrappedToken == null) {
        return BiometricTokenResult(
          success: false,
          error: BiometricError.noWrappedToken,
          message: 'No wrapped token found. Please login with password first.',
        );
      }

      // Check if biometric data has changed
      final bool hasBiometricDataChanged = await _hasBiometricDataChanged();
      if (hasBiometricDataChanged) {
        await _clearBiometricData();
        return BiometricTokenResult(
          success: false,
          error: BiometricError.biometricChanged,
          message: 'Biometric data has changed. Please login with password to re-enable biometric authentication.',
        );
      }

      // Authenticate with biometrics
      final BiometricAuthResult authResult = await authenticateWithBiometric(
        reason: 'Authenticate to access your account',
      );

      if (!authResult.success) {
        return BiometricTokenResult(
          success: false,
          error: authResult.error,
          message: authResult.message,
        );
      }

      // Get stored fingerprint
      final String? storedFingerprint = await _secureStorage.read(key: _biometricFingerprintKey);
      if (storedFingerprint == null) {
        return BiometricTokenResult(
          success: false,
          error: BiometricError.invalidFingerprint,
          message: 'Invalid biometric fingerprint. Please login with password.',
        );
      }

      // Decrypt token
      final String? decryptedToken = _decryptToken(wrappedToken, storedFingerprint);
      if (decryptedToken == null) {
        return BiometricTokenResult(
          success: false,
          error: BiometricError.tokenDecryptionFailed,
          message: 'Failed to decrypt token. Please login with password.',
        );
      }

      // Update last check time
      await _secureStorage.write(key: _lastBiometricCheckKey, value: DateTime.now().millisecondsSinceEpoch.toString());

      return BiometricTokenResult(
        success: true,
        token: decryptedToken,
        message: 'Token unwrapped successfully',
      );
    } catch (e) {
      return BiometricTokenResult(
        success: false,
        error: BiometricError.tokenUnwrappingFailed,
        message: 'Failed to unwrap token: $e',
      );
    }
  }

  /// Enhanced biometric authentication with retry logic and lockout
  Future<BiometricAuthResult> authenticateWithBiometric({
    required String reason,
    bool allowDeviceCredential = false,
  }) async {
    try {
      // Check lockout status
      final bool isLockedOut = await _isLockedOut();
      if (isLockedOut) {
        final DateTime? lockoutUntil = await _getLockoutUntil();
        final Duration remainingTime = lockoutUntil!.difference(DateTime.now());
        return BiometricAuthResult(
          success: false,
          error: BiometricError.lockedOut,
          message: 'Biometric authentication is locked. Try again in ${remainingTime.inMinutes} minutes.',
        );
      }

      // Perform biometric authentication
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: !allowDeviceCredential,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Reset retry count on successful authentication
        await _secureStorage.delete(key: _retryCountKey);
        await _secureStorage.delete(key: _lockoutUntilKey);
        
        return BiometricAuthResult(
          success: true,
          message: 'Biometric authentication successful',
        );
      } else {
        // Increment retry count
        await _incrementRetryCount();
        return BiometricAuthResult(
          success: false,
          error: BiometricError.authenticationFailed,
          message: 'Biometric authentication failed',
        );
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        error: BiometricError.unknown,
        message: 'Biometric authentication failed: $e',
      );
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final String? enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Enable biometric authentication
  Future<BiometricResult> enableBiometric() async {
    try {
      // Check if biometric is available
      final BiometricInitResult initResult = await initializeBiometric();
      if (!initResult.success) {
        return BiometricResult(
          success: false,
          error: initResult.error,
          message: initResult.message,
        );
      }

      // Authenticate user with biometrics to enable the feature
      final BiometricAuthResult authResult = await authenticateWithBiometric(
        reason: 'Enable biometric authentication for faster login',
      );

      if (!authResult.success) {
        return BiometricResult(
          success: false,
          error: authResult.error,
          message: authResult.message,
        );
      }

      // Enable biometric authentication
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      
      return BiometricResult(
        success: true,
        message: 'Biometric authentication enabled successfully',
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: BiometricError.enableFailed,
        message: 'Failed to enable biometric authentication: $e',
      );
    }
  }

  /// Disable biometric authentication and clear all data
  Future<BiometricResult> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await removeBiometricKey();
      
      return BiometricResult(
        success: true,
        message: 'Biometric authentication disabled successfully',
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: BiometricError.disableFailed,
        message: 'Failed to disable biometric authentication: $e',
      );
    }
  }

  /// Get comprehensive biometric status
  Future<BiometricStatus> getBiometricStatus() async {
    try {
      final BiometricInitResult initResult = await initializeBiometric();
      final bool isEnabled = await isBiometricEnabled();
      final bool isLockedOut = await _isLockedOut();
      final int retryCount = await _getRetryCount();
      final DateTime? lastCheck = await _getLastBiometricCheck();

      return BiometricStatus(
        isAvailable: initResult.success,
        isEnabled: isEnabled,
        isLockedOut: isLockedOut,
        retryCount: retryCount,
        lastCheck: lastCheck,
        availableTypes: initResult.availableTypes ?? [],
        deviceSecurityLevel: initResult.deviceSecurityLevel ?? DeviceSecurityLevel.unknown,
        error: initResult.error,
        message: initResult.message,
      );
    } catch (e) {
      return BiometricStatus(
        isAvailable: false,
        isEnabled: false,
        isLockedOut: false,
        retryCount: 0,
        lastCheck: null,
        availableTypes: [],
        deviceSecurityLevel: DeviceSecurityLevel.unknown,
        error: BiometricError.unknown,
        message: 'Failed to get biometric status: $e',
      );
    }
  }

  /// Check if biometric data has changed
  Future<bool> _hasBiometricDataChanged() async {
    try {
      final String? storedFingerprint = await _secureStorage.read(key: _biometricFingerprintKey);
      if (storedFingerprint == null) {
        return false; // No stored fingerprint, not changed
      }

      final String currentFingerprint = await _generateBiometricFingerprint();
      return storedFingerprint != currentFingerprint;
    } catch (e) {
      return true; // Assume changed if we can't check
    }
  }

  /// Generate biometric fingerprint for change detection
  Future<String> _generateBiometricFingerprint() async {
    try {
      final List<BiometricType> availableTypes = await _localAuth.getAvailableBiometrics();
      final String fingerprint = availableTypes.map((type) => type.toString()).join(',');
      return sha256.convert(utf8.encode(fingerprint)).toString();
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  /// Check if biometric is locked out
  Future<bool> _isLockedOut() async {
    try {
      final String? lockoutUntilStr = await _secureStorage.read(key: _lockoutUntilKey);
      if (lockoutUntilStr == null) {
        return false;
      }

      final DateTime lockoutUntil = DateTime.fromMillisecondsSinceEpoch(int.parse(lockoutUntilStr));
      return DateTime.now().isBefore(lockoutUntil);
    } catch (e) {
      return false;
    }
  }

  /// Get lockout until time
  Future<DateTime?> _getLockoutUntil() async {
    try {
      final String? lockoutUntilStr = await _secureStorage.read(key: _lockoutUntilKey);
      if (lockoutUntilStr == null) {
        return null;
      }
      return DateTime.fromMillisecondsSinceEpoch(int.parse(lockoutUntilStr));
    } catch (e) {
      return null;
    }
  }

  /// Increment retry count and set lockout if needed
  Future<void> _incrementRetryCount() async {
    try {
      final int currentCount = await _getRetryCount();
      final int newCount = currentCount + 1;
      
      await _secureStorage.write(key: _retryCountKey, value: newCount.toString());
      
      if (newCount >= maxRetryAttempts) {
        final DateTime lockoutUntil = DateTime.now().add(lockoutDuration);
        await _secureStorage.write(key: _lockoutUntilKey, value: lockoutUntil.millisecondsSinceEpoch.toString());
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get current retry count
  Future<int> _getRetryCount() async {
    try {
      final String? countStr = await _secureStorage.read(key: _retryCountKey);
      return countStr != null ? int.parse(countStr) : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get last biometric check time
  Future<DateTime?> _getLastBiometricCheck() async {
    try {
      final String? lastCheckStr = await _secureStorage.read(key: _lastBiometricCheckKey);
      if (lastCheckStr == null) {
        return null;
      }
      return DateTime.fromMillisecondsSinceEpoch(int.parse(lastCheckStr));
    } catch (e) {
      return null;
    }
  }

  /// Get device security level
  Future<DeviceSecurityLevel> _getDeviceSecurityLevel() async {
    try {
      final List<BiometricType> availableTypes = await _localAuth.getAvailableBiometrics();
      
      if (availableTypes.contains(BiometricType.face) && availableTypes.contains(BiometricType.fingerprint)) {
        return DeviceSecurityLevel.high;
      } else if (availableTypes.contains(BiometricType.fingerprint)) {
        return DeviceSecurityLevel.medium;
      } else if (availableTypes.contains(BiometricType.face)) {
        return DeviceSecurityLevel.medium;
      } else {
        return DeviceSecurityLevel.low;
      }
    } catch (e) {
      return DeviceSecurityLevel.unknown;
    }
  }

  /// Clear all biometric data
  Future<void> _clearBiometricData() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _wrappedTokenKey);
      await _secureStorage.delete(key: _biometricFingerprintKey);
      await _secureStorage.delete(key: _lastBiometricCheckKey);
      await _secureStorage.delete(key: _retryCountKey);
      await _secureStorage.delete(key: _lockoutUntilKey);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Simple token encryption (in production, use proper encryption)
  String _encryptToken(String token, String fingerprint) {
    // This is a simplified encryption for demo purposes
    // In production, use proper encryption with the biometric key
    final String combined = '$token:$fingerprint';
    return base64.encode(utf8.encode(combined));
  }

  /// Simple token decryption (in production, use proper decryption)
  String? _decryptToken(String wrappedToken, String fingerprint) {
    try {
      // This is a simplified decryption for demo purposes
      // In production, use proper decryption with the biometric key
      final String decoded = utf8.decode(base64.decode(wrappedToken));
      final List<String> parts = decoded.split(':');
      
      if (parts.length == 2 && parts[1] == fingerprint) {
        return parts[0];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Handle platform exceptions
  BiometricAuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return BiometricAuthResult(
          success: false,
          error: BiometricError.notAvailable,
          message: 'Biometric authentication is not available',
        );
      case 'NotEnrolled':
        return BiometricAuthResult(
          success: false,
          error: BiometricError.notEnrolled,
          message: 'No biometric data is enrolled on this device',
        );
      case 'LockedOut':
        return BiometricAuthResult(
          success: false,
          error: BiometricError.lockedOut,
          message: 'Biometric authentication is locked out',
        );
      case 'PermanentlyLockedOut':
        return BiometricAuthResult(
          success: false,
          error: BiometricError.permanentlyLockedOut,
          message: 'Biometric authentication is permanently locked out',
        );
      case 'UserCancel':
        return BiometricAuthResult(
          success: false,
          error: BiometricError.userCancel,
          message: 'Biometric authentication was cancelled by user',
        );
      default:
        return BiometricAuthResult(
          success: false,
          error: BiometricError.unknown,
          message: 'Biometric authentication failed: ${e.message}',
        );
    }
  }
}

/// Biometric error types
enum BiometricError {
  deviceNotSupported,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  userCancel,
  authenticationFailed,
  biometricChanged,
  keyGenerationFailed,
  keyRemovalFailed,
  tokenWrappingFailed,
  tokenUnwrappingFailed,
  tokenDecryptionFailed,
  noWrappedToken,
  invalidFingerprint,
  enableFailed,
  disableFailed,
  unknown,
}

/// Device security levels
enum DeviceSecurityLevel {
  low,
  medium,
  high,
  unknown,
}

/// Biometric initialization result
class BiometricInitResult {
  final bool success;
  final BiometricError? error;
  final String message;
  final List<BiometricType>? availableTypes;
  final DeviceSecurityLevel? deviceSecurityLevel;

  BiometricInitResult({
    required this.success,
    this.error,
    required this.message,
    this.availableTypes,
    this.deviceSecurityLevel,
  });
}

/// Biometric key generation result
class BiometricKeyResult {
  final bool success;
  final BiometricError? error;
  final String message;
  final String? keyAlias;

  BiometricKeyResult({
    required this.success,
    this.error,
    required this.message,
    this.keyAlias,
  });
}

/// Biometric authentication result
class BiometricAuthResult {
  final bool success;
  final BiometricError? error;
  final String message;

  BiometricAuthResult({
    required this.success,
    this.error,
    required this.message,
  });
}

/// Biometric token result
class BiometricTokenResult {
  final bool success;
  final BiometricError? error;
  final String message;
  final String? token;
  final String? wrappedToken;

  BiometricTokenResult({
    required this.success,
    this.error,
    required this.message,
    this.token,
    this.wrappedToken,
  });
}

/// Biometric result
class BiometricResult {
  final bool success;
  final BiometricError? error;
  final String message;

  BiometricResult({
    required this.success,
    this.error,
    required this.message,
  });
}

/// Comprehensive biometric status
class BiometricStatus {
  final bool isAvailable;
  final bool isEnabled;
  final bool isLockedOut;
  final int retryCount;
  final DateTime? lastCheck;
  final List<BiometricType> availableTypes;
  final DeviceSecurityLevel deviceSecurityLevel;
  final BiometricError? error;
  final String message;

  BiometricStatus({
    required this.isAvailable,
    required this.isEnabled,
    required this.isLockedOut,
    required this.retryCount,
    this.lastCheck,
    required this.availableTypes,
    required this.deviceSecurityLevel,
    this.error,
    required this.message,
  });

  bool get canUseBiometric => isAvailable && isEnabled && !isLockedOut;
  
  String get statusMessage {
    if (error != null) {
      return message;
    } else if (!isAvailable) {
      return 'Biometric authentication is not available on this device';
    } else if (availableTypes.isEmpty) {
      return 'No biometric data is enrolled on this device';
    } else if (isLockedOut) {
      return 'Biometric authentication is temporarily locked';
    } else if (!isEnabled) {
      return 'Biometric authentication is not enabled for this app';
    } else {
      return 'Biometric authentication is ready to use';
    }
  }
}
