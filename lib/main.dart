import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/enhanced_splash_screen.dart';
import 'screens/main_wrapper.dart';
import 'services/language_service.dart';
import 'providers/auth_provider.dart';
import 'providers/plots_provider.dart';
import 'providers/plot_stats_provider.dart';
import 'core/services/location_service.dart';
import 'core/services/instant_boundary_service.dart';
import 'core/services/optimized_boundary_service.dart';
import 'core/services/optimized_plots_cache.dart';
import 'core/services/optimized_tile_cache.dart';
import 'core/services/unified_memory_cache.dart';
import 'core/services/enhanced_startup_preloader.dart';
import 'core/services/unified_cache_manager.dart';
import 'core/services/enterprise_api_manager.dart';
import 'core/services/smart_filter_manager.dart';
import 'core/services/progressive_map_renderer.dart';

// Custom gradient theme extension
@immutable
class GradientTheme extends ThemeExtension<GradientTheme> {
  const GradientTheme({
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.accentGradient,
    required this.successGradient,
  });

  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final LinearGradient accentGradient;
  final LinearGradient successGradient;

  @override
  GradientTheme copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    LinearGradient? accentGradient,
    LinearGradient? successGradient,
  }) {
    return GradientTheme(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      accentGradient: accentGradient ?? this.accentGradient,
      successGradient: successGradient ?? this.successGradient,
    );
  }

  @override
  GradientTheme lerp(ThemeExtension<GradientTheme>? other, double t) {
    if (other is! GradientTheme) {
      return this;
    }
    return GradientTheme(
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t) ?? primaryGradient,
      secondaryGradient: LinearGradient.lerp(secondaryGradient, other.secondaryGradient, t) ?? secondaryGradient,
      accentGradient: LinearGradient.lerp(accentGradient, other.accentGradient, t) ?? accentGradient,
      successGradient: LinearGradient.lerp(successGradient, other.successGradient, t) ?? successGradient,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const DHAMarketplaceApp());
}

class DHAMarketplaceApp extends StatefulWidget {
  const DHAMarketplaceApp({super.key});

  @override
  State<DHAMarketplaceApp> createState() => _DHAMarketplaceAppState();
}

class _DHAMarketplaceAppState extends State<DHAMarketplaceApp> {
  final LanguageService _languageService = LanguageService();
  Locale _currentLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _preloadData();
  }

  Future<void> _loadLanguage() async {
    await _languageService.loadLanguage();
    setState(() {
      _currentLocale = _languageService.currentLocale;
    });
  }

  /// Preload essential data in background for instant access
  Future<void> _preloadData() async {
    // Enhanced startup preloading with progress tracking
    print('Main: Starting enhanced startup preloading...');
    
    // Initialize unified cache manager
    Future.microtask(() async {
      try {
        await UnifiedCacheManager.instance.initialize();
        print('Main: Unified cache manager initialized');
      } catch (e) {
        print('Main: Error initializing unified cache manager: $e');
      }
    });
    
    // Preload boundaries at startup
    Future.microtask(() async {
      try {
        await InstantBoundaryService.preloadBoundaries();
        print('Main: Boundaries preloaded at startup');
      } catch (e) {
        print('Main: Error preloading boundaries: $e');
      }
    });
    
    // Initialize performance monitoring
    Future.microtask(() async {
      try {
        _initializePerformanceMonitoring();
        print('Main: Performance monitoring initialized');
      } catch (e) {
        print('Main: Error initializing performance monitoring: $e');
      }
    });
  }
  
  /// Initialize performance monitoring for production app
  void _initializePerformanceMonitoring() {
    // Monitor performance metrics
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _logPerformanceMetrics();
    });
  }
  
  /// Log performance metrics for monitoring
  void _logPerformanceMetrics() {
    try {
      final apiStats = EnterpriseAPIManager.getPerformanceStats();
      final filterStats = SmartFilterManager.getPerformanceStats();
      final renderStats = ProgressiveMapRenderer.getPerformanceStats();
      final memoryCacheStats = UnifiedMemoryCache.instance.getStatistics();
      final plotsStats = OptimizedPlotsCache.getCacheStatistics();
      final tileStats = OptimizedTileCache.instance.getCacheStatistics();
      final preloadStatus = EnhancedStartupPreloader.getPreloadStatus();
      final cacheStats = UnifiedCacheManager.instance.getStatistics();
      
      print('=== PERFORMANCE METRICS ===');
      print('API Stats: $apiStats');
      print('Filter Stats: $filterStats');
      print('Render Stats: $renderStats');
      print('Memory Cache: $memoryCacheStats');
      print('Plots Cache: $plotsStats');
      print('Tile Cache: $tileStats');
      print('Preload Status: $preloadStatus');
      print('Unified Cache: $cacheStats');
      print('===========================');
    } catch (e) {
      print('Error logging performance metrics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageService>(
          create: (context) => _languageService,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<PlotsProvider>(
          create: (context) => PlotsProvider(),
        ),
        ChangeNotifierProvider<PlotStatsProvider>(
          create: (context) => PlotStatsProvider(),
        ),
        ChangeNotifierProvider<LocationService>(
          create: (context) {
            final locationService = LocationService();
            // Initialize location service
            locationService.initializeLocation();
            return locationService;
          },
        ),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'DHA Marketplace',
            locale: languageService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ur'), // Urdu
            ],
            theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A651),
          primary: const Color(0xFF00A651),
          secondary: const Color(0xFF2ECC71),
          tertiary: const Color(0xFF3498DB),
          surface: const Color(0xFFF8F9FA),
        ),
        // Custom gradient theme
        extensions: <ThemeExtension<dynamic>>[
          GradientTheme(
            primaryGradient: const LinearGradient(
              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            secondaryGradient: const LinearGradient(
              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            accentGradient: const LinearGradient(
              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            successGradient: const LinearGradient(
              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ],
      ),
      home: const EnhancedSplashScreen(),
      debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
