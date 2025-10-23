import 'package:local_auth/local_auth.dart';

/// Biometric authentication state model
enum BiometricAuthState {
  idle,
  available,
  locked,
  disabled,
  error,
}

/// Biometric authentication state with detailed information
class BiometricAuthStateModel {
  final BiometricAuthState state;
  final bool isAvailable;
  final bool isEnabled;
  final bool isLockedOut;
  final int retryCount;
  final DateTime? lastCheck;
  final List<BiometricType> availableTypes;
  final String? errorMessage;
  final String? statusMessage;
  final DateTime? lockoutUntil;
  final int maxRetryAttempts;
  final Duration lockoutDuration;

  BiometricAuthStateModel({
    required this.state,
    required this.isAvailable,
    required this.isEnabled,
    required this.isLockedOut,
    required this.retryCount,
    this.lastCheck,
    required this.availableTypes,
    this.errorMessage,
    this.statusMessage,
    this.lockoutUntil,
    this.maxRetryAttempts = 3,
    this.lockoutDuration = const Duration(minutes: 5),
  });

  /// Create idle state
  factory BiometricAuthStateModel.idle() {
    return BiometricAuthStateModel(
      state: BiometricAuthState.idle,
      isAvailable: false,
      isEnabled: false,
      isLockedOut: false,
      retryCount: 0,
      availableTypes: [],
      statusMessage: 'Biometric authentication is idle',
    );
  }

  /// Create available state
  factory BiometricAuthStateModel.available({
    required List<BiometricType> availableTypes,
    required bool isEnabled,
    DateTime? lastCheck,
  }) {
    return BiometricAuthStateModel(
      state: BiometricAuthState.available,
      isAvailable: true,
      isEnabled: isEnabled,
      isLockedOut: false,
      retryCount: 0,
      lastCheck: lastCheck,
      availableTypes: availableTypes,
      statusMessage: isEnabled 
          ? 'Biometric authentication is ready to use'
          : 'Biometric authentication is available but not enabled',
    );
  }

  /// Create locked state
  factory BiometricAuthStateModel.locked({
    required int retryCount,
    required DateTime lockoutUntil,
    int maxRetryAttempts = 3,
    Duration lockoutDuration = const Duration(minutes: 5),
  }) {
    final Duration remainingTime = lockoutUntil.difference(DateTime.now());
    return BiometricAuthStateModel(
      state: BiometricAuthState.locked,
      isAvailable: true,
      isEnabled: true,
      isLockedOut: true,
      retryCount: retryCount,
      lockoutUntil: lockoutUntil,
      availableTypes: [],
      maxRetryAttempts: maxRetryAttempts,
      lockoutDuration: lockoutDuration,
      statusMessage: 'Biometric authentication is locked. Try again in ${remainingTime.inMinutes} minutes.',
    );
  }

  /// Create disabled state
  factory BiometricAuthStateModel.disabled({
    required List<BiometricType> availableTypes,
    DateTime? lastCheck,
  }) {
    return BiometricAuthStateModel(
      state: BiometricAuthState.disabled,
      isAvailable: true,
      isEnabled: false,
      isLockedOut: false,
      retryCount: 0,
      lastCheck: lastCheck,
      availableTypes: availableTypes,
      statusMessage: 'Biometric authentication is disabled',
    );
  }

  /// Create error state
  factory BiometricAuthStateModel.error({
    required String errorMessage,
    List<BiometricType> availableTypes = const [],
  }) {
    return BiometricAuthStateModel(
      state: BiometricAuthState.error,
      isAvailable: false,
      isEnabled: false,
      isLockedOut: false,
      retryCount: 0,
      availableTypes: availableTypes,
      errorMessage: errorMessage,
      statusMessage: 'Biometric authentication error: $errorMessage',
    );
  }

  /// Check if biometric can be used
  bool get canUseBiometric => 
      state == BiometricAuthState.available && 
      isAvailable && 
      isEnabled && 
      !isLockedOut;

  /// Check if biometric setup is available
  bool get canSetupBiometric => 
      state == BiometricAuthState.available && 
      isAvailable && 
      !isEnabled && 
      !isLockedOut;

  /// Check if biometric is locked out
  bool get isCurrentlyLockedOut => 
      state == BiometricAuthState.locked || 
      (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil!));

  /// Get remaining lockout time
  Duration? get remainingLockoutTime {
    if (lockoutUntil == null) return null;
    final Duration remaining = lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Get biometric type display name
  String get biometricTypeDisplayName {
    if (availableTypes.isEmpty) return 'None';
    
    final List<String> typeNames = availableTypes.map((type) {
      switch (type) {
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.face:
          return 'Face';
        case BiometricType.iris:
          return 'Iris';
        case BiometricType.strong:
          return 'Strong Biometric';
        case BiometricType.weak:
          return 'Weak Biometric';
      }
    }).toList();
    
    return typeNames.join(', ');
  }

  /// Get state description
  String get stateDescription {
    switch (state) {
      case BiometricAuthState.idle:
        return 'Idle';
      case BiometricAuthState.available:
        return 'Available';
      case BiometricAuthState.locked:
        return 'Locked';
      case BiometricAuthState.disabled:
        return 'Disabled';
      case BiometricAuthState.error:
        return 'Error';
    }
  }

  /// Get detailed status message
  String get detailedStatusMessage {
    if (errorMessage != null) {
      return errorMessage!;
    }
    
    if (statusMessage != null) {
      return statusMessage!;
    }
    
    switch (state) {
      case BiometricAuthState.idle:
        return 'Biometric authentication is not initialized';
      case BiometricAuthState.available:
        if (isEnabled) {
          return 'Biometric authentication is ready to use';
        } else {
          return 'Biometric authentication is available but not enabled';
        }
      case BiometricAuthState.locked:
        if (remainingLockoutTime != null) {
          return 'Biometric authentication is locked. Try again in ${remainingLockoutTime!.inMinutes} minutes.';
        } else {
          return 'Biometric authentication is locked due to multiple failed attempts';
        }
      case BiometricAuthState.disabled:
        return 'Biometric authentication is disabled';
      case BiometricAuthState.error:
        return 'Biometric authentication encountered an error';
    }
  }

  /// Copy with new values
  BiometricAuthStateModel copyWith({
    BiometricAuthState? state,
    bool? isAvailable,
    bool? isEnabled,
    bool? isLockedOut,
    int? retryCount,
    DateTime? lastCheck,
    List<BiometricType>? availableTypes,
    String? errorMessage,
    String? statusMessage,
    DateTime? lockoutUntil,
    int? maxRetryAttempts,
    Duration? lockoutDuration,
  }) {
    return BiometricAuthStateModel(
      state: state ?? this.state,
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      isLockedOut: isLockedOut ?? this.isLockedOut,
      retryCount: retryCount ?? this.retryCount,
      lastCheck: lastCheck ?? this.lastCheck,
      availableTypes: availableTypes ?? this.availableTypes,
      errorMessage: errorMessage ?? this.errorMessage,
      statusMessage: statusMessage ?? this.statusMessage,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      lockoutDuration: lockoutDuration ?? this.lockoutDuration,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'state': state.toString(),
      'isAvailable': isAvailable,
      'isEnabled': isEnabled,
      'isLockedOut': isLockedOut,
      'retryCount': retryCount,
      'lastCheck': lastCheck?.millisecondsSinceEpoch,
      'availableTypes': availableTypes.map((type) => type.toString()).toList(),
      'errorMessage': errorMessage,
      'statusMessage': statusMessage,
      'lockoutUntil': lockoutUntil?.millisecondsSinceEpoch,
      'maxRetryAttempts': maxRetryAttempts,
      'lockoutDuration': lockoutDuration.inMilliseconds,
    };
  }

  /// Create from JSON
  factory BiometricAuthStateModel.fromJson(Map<String, dynamic> json) {
    return BiometricAuthStateModel(
      state: BiometricAuthState.values.firstWhere(
        (state) => state.toString() == json['state'],
        orElse: () => BiometricAuthState.idle,
      ),
      isAvailable: json['isAvailable'] ?? false,
      isEnabled: json['isEnabled'] ?? false,
      isLockedOut: json['isLockedOut'] ?? false,
      retryCount: json['retryCount'] ?? 0,
      lastCheck: json['lastCheck'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastCheck'])
          : null,
      availableTypes: (json['availableTypes'] as List<dynamic>?)
          ?.map((type) => BiometricType.values.firstWhere(
                (bt) => bt.toString() == type,
                orElse: () => BiometricType.weak,
              ))
          .toList() ?? [],
      errorMessage: json['errorMessage'],
      statusMessage: json['statusMessage'],
      lockoutUntil: json['lockoutUntil'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lockoutUntil'])
          : null,
      maxRetryAttempts: json['maxRetryAttempts'] ?? 3,
      lockoutDuration: Duration(milliseconds: json['lockoutDuration'] ?? 300000),
    );
  }

  @override
  String toString() {
    return 'BiometricAuthStateModel('
        'state: $state, '
        'isAvailable: $isAvailable, '
        'isEnabled: $isEnabled, '
        'isLockedOut: $isLockedOut, '
        'retryCount: $retryCount, '
        'availableTypes: $availableTypes, '
        'errorMessage: $errorMessage'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BiometricAuthStateModel &&
        other.state == state &&
        other.isAvailable == isAvailable &&
        other.isEnabled == isEnabled &&
        other.isLockedOut == isLockedOut &&
        other.retryCount == retryCount &&
        other.lastCheck == lastCheck &&
        other.availableTypes == availableTypes &&
        other.errorMessage == errorMessage &&
        other.statusMessage == statusMessage &&
        other.lockoutUntil == lockoutUntil &&
        other.maxRetryAttempts == maxRetryAttempts &&
        other.lockoutDuration == lockoutDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      state,
      isAvailable,
      isEnabled,
      isLockedOut,
      retryCount,
      lastCheck,
      availableTypes,
      errorMessage,
      statusMessage,
      lockoutUntil,
      maxRetryAttempts,
      lockoutDuration,
    );
  }
}
