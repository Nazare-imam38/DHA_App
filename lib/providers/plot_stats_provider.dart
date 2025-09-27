import 'package:flutter/foundation.dart';
import '../data/models/plot_stats_model.dart';
import '../services/plot_stats_service.dart';

class PlotStatsProvider with ChangeNotifier {
  PlotStatsModel? _plotStats;
  bool _isLoading = false;
  String? _error;

  // Getters
  PlotStatsModel? get plotStats => _plotStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get residential count
  int get residentialCount => _plotStats?.data.plotCategories.residential ?? 0;
  
  // Get commercial count
  int get commercialCount => _plotStats?.data.plotCategories.commercial ?? 0;
  
  // Get total plots count
  int get totalPlotsCount => _plotStats?.data.totalPlots ?? 0;

  /// Fetch plot statistics from the API
  Future<void> fetchPlotStats({int eventId = 3}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('PlotStatsProvider: Fetching plot statistics...');
      _plotStats = await PlotStatsService.fetchPlotStats(eventId: eventId);
      print('PlotStatsProvider: Successfully fetched plot statistics');
      print('PlotStatsProvider: Residential: $residentialCount, Commercial: $commercialCount');
      _error = null;
    } catch (e) {
      print('PlotStatsProvider: Error fetching plot statistics: $e');
      _error = e.toString();
      _plotStats = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh plot statistics
  Future<void> refreshPlotStats({int eventId = 3}) async {
    await fetchPlotStats(eventId: eventId);
  }

  /// Clear plot statistics
  void clearPlotStats() {
    _plotStats = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Check if plot statistics are available
  bool get hasPlotStats => _plotStats != null && _error == null;

  /// Get plot statistics with fallback values
  Map<String, int> getPlotStatsWithFallback() {
    if (hasPlotStats) {
      return {
        'residential': residentialCount,
        'commercial': commercialCount,
        'total': totalPlotsCount,
      };
    } else {
      // Return fallback values if API data is not available
      return {
        'residential': 75,
        'commercial': 15,
        'total': 90,
      };
    }
  }
}
