import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'logger_service.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en');
  StorageService? _storageService;
  
  Locale get currentLocale => _currentLocale;
  
  String get currentLanguageCode => _currentLocale.languageCode;
  
  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'ur':
        return 'Urdu';
      default:
        return 'English';
    }
  }
  
  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
    await loadLanguage();
  }
  
  Future<void> loadLanguage() async {
    try {
      _storageService ??= await StorageService.getInstance();
      final String? languageCode = await _storageService!.getLanguage();
      _currentLocale = Locale(languageCode ?? 'en');
      LoggerService.instance.info('Language loaded: ${_currentLocale.languageCode}');
      notifyListeners();
    } catch (e) {
      LoggerService.instance.error('Failed to load language', error: e);
      _currentLocale = const Locale('en');
      notifyListeners();
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    try {
      _currentLocale = Locale(languageCode);
      _storageService ??= await StorageService.getInstance();
      await _storageService!.setLanguage(languageCode);
      LoggerService.instance.info('Language changed to: $languageCode');
      notifyListeners();
    } catch (e) {
      LoggerService.instance.error('Failed to set language: $languageCode', error: e);
    }
  }
  
  Future<void> setEnglish() async {
    await setLanguage('en');
  }
  
  Future<void> setUrdu() async {
    await setLanguage('ur');
  }
  
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isUrdu => _currentLocale.languageCode == 'ur';
  
  // Get supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ur'),
  ];
  
  // Get locale display name
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ur':
        return 'اردو';
      default:
        return 'English';
    }
  }
  
  // Check if locale is supported
  bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode);
  }
}
