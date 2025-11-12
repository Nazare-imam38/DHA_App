import 'package:shared_preferences/shared_preferences.dart';

// Test script to check auth token accessibility
void main() async {
  await testAuthTokenAccess();
}

Future<void> testAuthTokenAccess() async {
  print('🧪 Testing Auth Token Access');
  print('=' * 40);
  
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Check different possible token keys
    final keys = ['access_token', 'auth_token', 'token', 'bearer_token'];
    
    print('🔍 Checking SharedPreferences for tokens:');
    for (final key in keys) {
      final value = prefs.getString(key);
      print('   $key: ${value != null ? "EXISTS (${value.length} chars)" : "NOT FOUND"}');
      if (value != null && value.length > 20) {
        print('      Preview: ${value.substring(0, 20)}...');
      }
    }
    
    print('');
    print('🔍 All SharedPreferences keys:');
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      final value = prefs.get(key);
      print('   $key: ${value.runtimeType} = ${value.toString().length > 50 ? value.toString().substring(0, 50) + "..." : value}');
    }
    
  } catch (e) {
    print('❌ Error accessing SharedPreferences: $e');
  }
}