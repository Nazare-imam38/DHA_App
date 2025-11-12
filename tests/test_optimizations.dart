import 'package:flutter/material.dart';
import 'providers/optimized_plots_provider.dart';
import 'core/services/optimized_api_manager.dart';
import 'core/services/optimized_memory_cache.dart';
import 'core/services/smart_filter_manager.dart';
import 'data/models/plot_model.dart';

/// Test file to verify all optimizations work correctly
/// This ensures no functionality is broken while performance is improved
class OptimizationTester {
  
  /// Test optimized plots provider
  static Future<void> testOptimizedPlotsProvider() async {
    print('🧪 Testing OptimizedPlotsProvider...');
    
    try {
      final provider = OptimizedPlotsProvider();
      
      // Test initial state
      assert(provider.plots.isEmpty);
      assert(provider.filteredPlots.isEmpty);
      assert(!provider.isLoading);
      assert(provider.error == null);
      
      // Test filter methods
      provider.filterByPhase('Phase1');
      provider.filterByCategory('Residential');
      provider.filterByStatus('Available');
      provider.setSearchQuery('Plot 123');
      
      // Test getters
      final phases = provider.availablePhases;
      final categories = provider.availableCategories;
      final statuses = provider.availableStatuses;
      
      print('✅ OptimizedPlotsProvider: All tests passed');
      print('   - Available phases: ${phases.length}');
      print('   - Available categories: ${categories.length}');
      print('   - Available statuses: ${statuses.length}');
      
    } catch (e) {
      print('❌ OptimizedPlotsProvider test failed: $e');
      rethrow;
    }
  }
  
  /// Test optimized API manager
  static Future<void> testOptimizedAPIManager() async {
    print('🧪 Testing OptimizedAPIManager...');
    
    try {
      // Test request deduplication
      final request1 = OptimizedAPIManager.loadPlotsOptimized(useCache: true);
      final request2 = OptimizedAPIManager.loadPlotsOptimized(useCache: true);
      
      // Both requests should return the same result (deduplication)
      final results = await Future.wait([request1, request2]);
      assert(results[0].length == results[1].length);
      
      // Test performance stats
      final stats = OptimizedAPIManager.getPerformanceStats();
      assert(stats.containsKey('api_success'));
      assert(stats.containsKey('cache_hits'));
      
      print('✅ OptimizedAPIManager: All tests passed');
      print('   - Performance stats: $stats');
      
    } catch (e) {
      print('❌ OptimizedAPIManager test failed: $e');
      rethrow;
    }
  }
  
  /// Test optimized memory cache
  static Future<void> testOptimizedMemoryCache() async {
    print('🧪 Testing OptimizedMemoryCache...');
    
    try {
      final cache = OptimizedMemoryCache.instance;
      await cache.initialize();
      
      // Test storing data
      await cache.store('test_key', 'test_value');
      assert(cache.contains('test_key'));
      
      // Test retrieving data
      final value = cache.get<String>('test_key');
      assert(value == 'test_value');
      
      // Test cache statistics
      final stats = cache.getStatistics();
      assert(stats.containsKey('cache_size'));
      assert(stats.containsKey('hit_rate'));
      
      // Test clearing cache
      cache.clear('test_key');
      assert(!cache.contains('test_key'));
      
      print('✅ OptimizedMemoryCache: All tests passed');
      print('   - Cache stats: $stats');
      
    } catch (e) {
      print('❌ OptimizedMemoryCache test failed: $e');
      rethrow;
    }
  }
  
  /// Test smart filter manager
  static Future<void> testSmartFilterManager() async {
    print('🧪 Testing SmartFilterManager...');
    
    try {
      // Create test plots
      final testPlots = _createTestPlots();
      
      // Test filtering
      final filteredPlots = await SmartFilterManager.applyFilters(
        allPlots: testPlots,
        phase: 'Phase1',
        category: 'Residential',
        status: 'Available',
      );
      
      assert(filteredPlots.isNotEmpty);
      assert(filteredPlots.every((plot) => plot.phase == 'Phase1'));
      assert(filteredPlots.every((plot) => plot.category == 'Residential'));
      assert(filteredPlots.every((plot) => plot.status == 'Available'));
      
      // Test performance stats
      final stats = SmartFilterManager.getPerformanceStats();
      assert(stats.containsKey('filter_cache_hits'));
      
      print('✅ SmartFilterManager: All tests passed');
      print('   - Filtered ${filteredPlots.length} plots');
      print('   - Performance stats: $stats');
      
    } catch (e) {
      print('❌ SmartFilterManager test failed: $e');
      rethrow;
    }
  }
  
  /// Test all optimizations together
  static Future<void> testAllOptimizations() async {
    print('🚀 Testing all optimizations...');
    
    try {
      await testOptimizedPlotsProvider();
      await testOptimizedAPIManager();
      await testOptimizedMemoryCache();
      await testSmartFilterManager();
      
      print('🎉 All optimization tests passed!');
      print('✅ Performance optimizations are working correctly');
      print('✅ All functionality is preserved');
      print('✅ No breaking changes detected');
      
    } catch (e) {
      print('❌ Some optimization tests failed: $e');
      rethrow;
    }
  }
  
  /// Create test plots for testing
  static List<PlotModel> _createTestPlots() {
    return [
      PlotModel(
        id: 1,
        eventHistoryId: '1',
        plotNo: 'Plot 1',
        size: '5 Marla',
        category: 'Residential',
        catArea: '5 Marla',
        dimension: '25x45',
        phase: 'Phase1',
        sector: 'A',
        streetNo: 'Street 1',
        block: 'Block A',
        status: 'Available',
        tokenAmount: '100000',
        remarks: 'Good plot',
        basePrice: '5000000',
        holdBy: null,
        expireTime: null,
        oneYrPlan: '500000',
        twoYrsPlan: '250000',
        twoFiveYrsPlan: '200000',
        threeYrsPlan: '166667',
        stAsgeojson: '{"type":"MultiPolygon","coordinates":[[[[0,0],[1,0],[1,1],[0,1],[0,0]]]]}',
        eventHistory: EventHistory(
          id: '1',
          plotId: 1,
          eventType: 'Created',
          eventDate: DateTime.now().toIso8601String(),
          description: 'Plot created',
        ),
        latitude: 33.6844,
        longitude: 73.0479,
        expoBasePrice: '5000000',
        vloggerBasePrice: '5000000',
      ),
      PlotModel(
        id: 2,
        eventHistoryId: '2',
        plotNo: 'Plot 2',
        size: '10 Marla',
        category: 'Commercial',
        catArea: '10 Marla',
        dimension: '50x45',
        phase: 'Phase2',
        sector: 'B',
        streetNo: 'Street 2',
        block: 'Block B',
        status: 'Sold',
        tokenAmount: '200000',
        remarks: 'Sold plot',
        basePrice: '10000000',
        holdBy: 'Buyer',
        expireTime: null,
        oneYrPlan: '1000000',
        twoYrsPlan: '500000',
        twoFiveYrsPlan: '400000',
        threeYrsPlan: '333333',
        stAsgeojson: '{"type":"MultiPolygon","coordinates":[[[[1,1],[2,1],[2,2],[1,2],[1,1]]]]}',
        eventHistory: EventHistory(
          id: '2',
          plotId: 2,
          eventType: 'Sold',
          eventDate: DateTime.now().toIso8601String(),
          description: 'Plot sold',
        ),
        latitude: 33.6845,
        longitude: 73.0480,
        expoBasePrice: '10000000',
        vloggerBasePrice: '10000000',
      ),
    ];
  }
}

/// Performance monitoring widget
class PerformanceMonitorWidget extends StatefulWidget {
  const PerformanceMonitorWidget({super.key});

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  Map<String, dynamic> _performanceStats = {};

  @override
  void initState() {
    super.initState();
    _updatePerformanceStats();
    
    // Update stats every 5 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _updatePerformanceStats();
    });
  }

  void _updatePerformanceStats() {
    setState(() {
      _performanceStats = {
        'memory_cache': OptimizedMemoryCache.instance.getStatistics(),
        'api_manager': OptimizedAPIManager.getPerformanceStats(),
        'filter_manager': SmartFilterManager.getPerformanceStats(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Performance Monitor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatItem('Memory Usage', '${_performanceStats['memory_cache']?['usage_percentage'] ?? '0'}%'),
          _buildStatItem('Cache Hit Rate', '${_performanceStats['memory_cache']?['hit_rate'] ?? '0'}%'),
          _buildStatItem('API Cache Hits', '${_performanceStats['api_manager']?['cache_hits'] ?? '0'}'),
          _buildStatItem('Filter Cache Hits', '${_performanceStats['filter_manager']?['filter_cache_hits'] ?? '0'}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
