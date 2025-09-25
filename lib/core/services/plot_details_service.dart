import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/plot_details_model.dart';

class PlotDetailsService {
  static const String _baseUrl = 'https://your-api-endpoint.com/api'; // Replace with actual API endpoint
  
  /// Fetch detailed information for a specific plot
  static Future<PlotDetailsModel?> fetchPlotDetails(String plotNo) async {
    try {
      print('🔍 Fetching details for plot: $plotNo');
      
      // Simulate API call with mock data for now
      // Replace this with actual API call
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Mock data - replace with actual API response
      final mockData = {
        'plotNo': plotNo,
        'phase': 'RVS',
        'sector': 'RVS',
        'street': 'St. 09',
        'size': '7 Marla',
        'dimension': '30×52.5',
        'status': 'Unsold',
        'category': 'Residential',
        'lumpSumPrice': 7660000.0,
        'tokenAmount': 450000.0,
        'latitude': 33.6844,
        'longitude': 73.0479,
        'remarks': 'Premium location with easy access',
        'paymentPlans': [
          {
            'id': 'lump_sum',
            'name': 'Lump Sum',
            'description': 'One-time payment',
            'price': 7660000.0,
            'durationMonths': 0,
            'isSelected': true,
          },
          {
            'id': '1_year',
            'name': '1 Year Plan',
            'description': 'Installments',
            'price': 8415000.0,
            'durationMonths': 12,
            'isSelected': false,
          },
          {
            'id': '2_year',
            'name': '2 Years Plan',
            'description': 'Installments',
            'price': 9170000.0,
            'durationMonths': 24,
            'isSelected': false,
          },
          {
            'id': '3_year',
            'name': '3 Years Plan',
            'description': 'Installments',
            'price': 9925000.0,
            'durationMonths': 36,
            'isSelected': false,
          },
        ],
      };
      
      print('✅ Plot details fetched successfully for plot: $plotNo');
      return PlotDetailsModel.fromJson(mockData);
      
    } catch (e) {
      print('❌ Error fetching plot details: $e');
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
