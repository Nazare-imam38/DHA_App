import 'dart:async';
import 'package:flutter/material.dart';

class PerformanceService {
  static final Map<String, Timer> _debounceTimers = {};
  static final Map<String, DateTime> _lastUpdateTimes = {};
  
  /// Debounce function calls to prevent excessive updates
  static void debounce(
    String key,
    Duration duration,
    VoidCallback callback,
  ) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(duration, callback);
  }
  
  /// Throttle function calls to limit frequency
  static bool throttle(String key, Duration duration) {
    final now = DateTime.now();
    final lastUpdate = _lastUpdateTimes[key];
    
    if (lastUpdate == null || now.difference(lastUpdate) >= duration) {
      _lastUpdateTimes[key] = now;
      return true;
    }
    
    return false;
  }
  
  /// Cancel all debounce timers
  static void cancelAllDebounce() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }
  
  /// Cancel specific debounce timer
  static void cancelDebounce(String key) {
    _debounceTimers[key]?.cancel();
    _debounceTimers.remove(key);
  }
  
  /// Check if enough time has passed since last update
  static bool canUpdate(String key, Duration minInterval) {
    final lastUpdate = _lastUpdateTimes[key];
    if (lastUpdate == null) return true;
    
    return DateTime.now().difference(lastUpdate) >= minInterval;
  }
  
  /// Update last update time
  static void markUpdate(String key) {
    _lastUpdateTimes[key] = DateTime.now();
  }
}
