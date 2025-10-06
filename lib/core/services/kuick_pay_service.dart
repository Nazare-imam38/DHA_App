import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

/// Service for handling KuickPay fee calculations and payments
class KuickPayService {
  static const String baseUrl = 'https://backend-apis.dhamarketplace.com/api';
  final AuthService _authService = AuthService();

  /// Calculate KuickPay fee for a given token amount
  Future<KuickPayFeeResponse> calculateFee(double tokenAmount) async {
    try {
      print('KuickPayService: Calculating fee for token amount: $tokenAmount');
      
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      final uri = Uri.parse('$baseUrl/kuick-pay-fee?token_amount=${tokenAmount.toInt()}');
      
      print('KuickPayService: Request URL: $uri');
      print('KuickPayService: Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('KuickPayService: Response status: ${response.statusCode}');
      print('KuickPayService: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return KuickPayFeeResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to calculate KuickPay fee');
      }
    } catch (e) {
      print('KuickPayService: Error calculating fee: $e');
      throw Exception('Failed to calculate KuickPay fee: $e');
    }
  }

  /// Get payment summary with token amount and fees
  Future<PaymentSummary> getPaymentSummary(double plotPrice, String selectedPlan) async {
    try {
      print('KuickPayService: Getting payment summary for plot price: $plotPrice, plan: $selectedPlan');
      
      // Fixed token amount as per requirement: 250,000 PKR
      const double tokenAmount = 250000.0;
      print('KuickPayService: Using fixed token amount: $tokenAmount');

      // Get KuickPay fee for the fixed token amount
      final feeResponse = await calculateFee(tokenAmount);
      
      return PaymentSummary(
        tokenAmount: tokenAmount,
        kuickPayFee: feeResponse.fee,
        totalAmount: tokenAmount + feeResponse.fee,
        selectedPlan: selectedPlan,
      );
    } catch (e) {
      print('KuickPayService: Error getting payment summary: $e');
      throw Exception('Failed to get payment summary: $e');
    }
  }

  /// Reserve a plot with payment details
  Future<ReservePlotResponse> reservePlot(String plotId, double tokenAmount, String paymentMethod, String planType) async {
    try {
      print('KuickPayService: Reserving plot: $plotId with token amount: $tokenAmount');
      print('KuickPayService: Payment method: $paymentMethod, Plan type: $planType');
      
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      final uri = Uri.parse('$baseUrl/reserve-plot');
      
      print('KuickPayService: Request URL: $uri');
      print('KuickPayService: Using token: ${token.substring(0, 20)}...');

      final requestBody = {
        'plot_id': plotId,
        'token_amount': tokenAmount.toString(),
        'payment_method': paymentMethod,
        'plan_type': planType,
      };
      
      print('KuickPayService: Request body: $requestBody');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      print('KuickPayService: Response status: ${response.statusCode}');
      print('KuickPayService: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ReservePlotResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        print('KuickPayService: API Error - Status: ${response.statusCode}');
        print('KuickPayService: API Error - Message: ${errorData['message']}');
        print('KuickPayService: API Error - Errors: ${errorData['errors']}');
        throw Exception(errorData['message'] ?? 'Failed to reserve plot');
      }
    } catch (e) {
      print('KuickPayService: Error reserving plot: $e');
      throw Exception('Failed to reserve plot: $e');
    }
  }
}

/// Response model for KuickPay fee calculation
class KuickPayFeeResponse {
  final double fee;

  KuickPayFeeResponse({required this.fee});

  factory KuickPayFeeResponse.fromJson(Map<String, dynamic> json) {
    return KuickPayFeeResponse(
      fee: (json['fee'] ?? 0).toDouble(),
    );
  }
}

/// Payment summary model
class PaymentSummary {
  final double tokenAmount;
  final double kuickPayFee;
  final double totalAmount;
  final String selectedPlan;

  PaymentSummary({
    required this.tokenAmount,
    required this.kuickPayFee,
    required this.totalAmount,
    required this.selectedPlan,
  });

  String get formattedTokenAmount {
    // Format with commas for thousands
    return 'PKR ${_formatNumberWithCommas(tokenAmount)}';
  }

  String get formattedKuickPayFee {
    // Format with commas for thousands
    return 'PKR ${_formatNumberWithCommas(kuickPayFee)}';
  }

  String get formattedTotalAmount {
    // Format with commas for thousands
    return 'PKR ${_formatNumberWithCommas(totalAmount)}';
  }

  String _formatNumberWithCommas(double number) {
    // Convert to int to remove decimal places
    int intNumber = number.round();
    
    // Add commas for thousands
    String numberStr = intNumber.toString();
    String result = '';
    
    for (int i = 0; i < numberStr.length; i++) {
      if (i > 0 && (numberStr.length - i) % 3 == 0) {
        result += ',';
      }
      result += numberStr[i];
    }
    
    return result;
  }
}

/// Response model for plot reservation
class ReservePlotResponse {
  final String message;
  final ReservePlotData data;

  ReservePlotResponse({required this.message, required this.data});

  factory ReservePlotResponse.fromJson(Map<String, dynamic> json) {
    return ReservePlotResponse(
      message: json['message'] ?? '',
      data: ReservePlotData.fromJson(json['data'] ?? {}),
    );
  }
}

/// Data model for plot reservation response
class ReservePlotData {
  final String psid;
  final String kuickpayFee;
  final String challanExpiryTime;
  final String tokenAmount;

  ReservePlotData({
    required this.psid,
    required this.kuickpayFee,
    required this.challanExpiryTime,
    required this.tokenAmount,
  });

  factory ReservePlotData.fromJson(Map<String, dynamic> json) {
    return ReservePlotData(
      psid: json['psid'] ?? '',
      kuickpayFee: json['kuickpay_fee'] ?? '0.00',
      challanExpiryTime: json['challan_expiry_time'] ?? '',
      tokenAmount: json['token_amount'] ?? '0.00',
    );
  }

  /// Get formatted total amount (token amount + kuickpay fee)
  String get formattedTotalAmount {
    final token = double.tryParse(tokenAmount) ?? 0;
    final fee = double.tryParse(kuickpayFee) ?? 0;
    final total = token + fee;
    return 'PKR ${_formatNumberWithCommas(total)}';
  }

  /// Get formatted token amount
  String get formattedTokenAmount {
    final amount = double.tryParse(tokenAmount) ?? 0;
    return 'PKR ${_formatNumberWithCommas(amount)}';
  }

  /// Get formatted KuickPay fee
  String get formattedKuickPayFee {
    final fee = double.tryParse(kuickpayFee) ?? 0;
    return 'PKR ${_formatNumberWithCommas(fee)}';
  }

  String _formatNumberWithCommas(double number) {
    int intNumber = number.round();
    String numberStr = intNumber.toString();
    String result = '';
    
    for (int i = 0; i < numberStr.length; i++) {
      if (i > 0 && (numberStr.length - i) % 3 == 0) {
        result += ',';
      }
      result += numberStr[i];
    }
    
    return result;
  }
}
