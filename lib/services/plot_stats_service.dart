import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/plot_stats_model.dart';

class PlotStatsService {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  /// Fetch plot statistics from the API
  static Future<PlotStatsModel> fetchPlotStats({int eventId = 3}) async {
    print('PlotStatsService: Fetching plot stats for event_id: $eventId');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('PlotStatsService: Attempt $attempt/$_maxRetries');
        
        final response = await http.get(
          Uri.parse('$baseUrl/dashboard-plot-stats?event_id=$eventId'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(_timeout);
        
        print('PlotStatsService: Response status: ${response.statusCode}');
        print('PlotStatsService: Response body: ${response.body}');
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          final plotStats = PlotStatsModel.fromJson(jsonData);
          
          print('PlotStatsService: Successfully fetched plot stats');
          print('PlotStatsService: Total plots: ${plotStats.data.totalPlots}');
          print('PlotStatsService: Residential: ${plotStats.data.plotCategories.residential}');
          print('PlotStatsService: Commercial: ${plotStats.data.plotCategories.commercial}');
          
          return plotStats;
        } else {
          throw Exception('Failed to fetch plot stats: ${response.statusCode}');
        }
      } catch (e) {
        print('PlotStatsService: Attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          print('PlotStatsService: All attempts failed, throwing exception');
          throw Exception('Failed to fetch plot stats after $_maxRetries attempts: $e');
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw Exception('Failed to fetch plot stats after $_maxRetries attempts');
  }

  /// Get cached plot statistics (if available)
  static Future<PlotStatsModel?> getCachedPlotStats() async {
    // This could be implemented with local storage if needed
    // For now, we'll always fetch fresh data
    return null;
  }

  /// Cache plot statistics locally
  static Future<void> cachePlotStats(PlotStatsModel plotStats) async {
    // This could be implemented with local storage if needed
    // For now, we'll skip caching
  }
}
