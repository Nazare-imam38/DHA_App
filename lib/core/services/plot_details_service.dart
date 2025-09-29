import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/plot_details_model.dart';
import '../../data/models/plot_model.dart';

class PlotDetailsService {
  static const String _baseUrl = 'https://backend-apis.dhamarketplace.com/api';
  
  /// Fetch detailed information for a specific plot using real API
  static Future<PlotDetailsModel?> fetchPlotDetails(String plotNo) async {
    try {
      print('🔍 Fetching details for plot: $plotNo from API');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/plot-details?plot_no=$plotNo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API Response for plot $plotNo: $data');
        
        // Parse the API response into PlotDetailsModel
        return PlotDetailsModel.fromJson(data);
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
      
    } catch (e) {
      print('❌ Error fetching plot details from API: $e');
      return null;
    }
  }
  
  /// Create PlotDetailsModel from existing PlotModel (fallback method)
  static PlotDetailsModel? createFromPlotModel(PlotModel plot) {
    try {
      print('🔍 Creating plot details from existing plot model: ${plot.plotNo}');
      
      // Convert PlotModel to PlotDetailsModel format
      final plotData = {
        'plotNo': plot.plotNo,
        'phase': plot.phase,
        'sector': plot.sector,
        'street': plot.streetNo,
        'size': plot.size,
        'dimension': plot.dimension,
        'status': plot.status,
        'category': plot.category,
        'lumpSumPrice': double.tryParse(plot.basePrice) ?? 0.0,
        'tokenAmount': double.tryParse(plot.tokenAmount) ?? 0.0,
        'latitude': plot.latitude,
        'longitude': plot.longitude,
        'remarks': plot.remarks,
        'paymentPlans': [
          {
            'id': 'lump_sum',
            'name': 'Lump Sum',
            'description': 'One-time payment',
            'price': double.tryParse(plot.basePrice) ?? 0.0,
            'durationMonths': 0,
            'isSelected': true,
          },
          {
            'id': '1_year',
            'name': '1 Year Plan',
            'description': 'Installments',
            'price': double.tryParse(plot.oneYrPlan) ?? 0.0,
            'durationMonths': 12,
            'isSelected': false,
          },
          {
            'id': '2_year',
            'name': '2 Years Plan',
            'description': 'Installments',
            'price': double.tryParse(plot.twoYrsPlan) ?? 0.0,
            'durationMonths': 24,
            'isSelected': false,
          },
          {
            'id': '3_year',
            'name': '3 Years Plan',
            'description': 'Installments',
            'price': double.tryParse(plot.threeYrsPlan) ?? 0.0,
            'durationMonths': 36,
            'isSelected': false,
          },
        ],
      };
      
      print('✅ Created plot details from existing data for plot: ${plot.plotNo}');
      return PlotDetailsModel.fromJson(plotData);
      
    } catch (e) {
      print('❌ Error creating plot details from plot model: $e');
      return null;
    }
  }
  
  /// Secure a plot with token payment
  static Future<bool> securePlot(String plotNo, String paymentPlanId, double amount) async {
    try {
      print('🔒 Securing plot: $plotNo with plan: $paymentPlanId, amount: $amount');
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Mock success response
      print('✅ Plot secured successfully');
      return true;
      
    } catch (e) {
      print('❌ Error securing plot: $e');
      return false;
    }
  }
  
  /// Clear plot selection
  static Future<bool> clearSelection(String plotNo) async {
    try {
      print('🗑️ Clearing selection for plot: $plotNo');
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('✅ Selection cleared successfully');
      return true;
      
    } catch (e) {
      print('❌ Error clearing selection: $e');
      return false;
    }
  }
}
