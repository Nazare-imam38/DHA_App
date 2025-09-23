import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Language storage
  Future<String?> getLanguage() async {
    return _prefs?.getString('selected_language');
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs?.setString('selected_language', languageCode);
  }

  // Generic storage methods
  Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs?.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs?.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _prefs?.getDouble(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _prefs?.getStringList(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }

  Future<bool> containsKey(String key) async {
    return _prefs?.containsKey(key) ?? false;
  }

  Set<String> getKeys() {
    return _prefs?.getKeys() ?? <String>{};
  }
}
