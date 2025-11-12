import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

/// Exception thrown when attempting to book a plot that is already booked
class DuplicateBookingException implements Exception {
  final String message;
  DuplicateBookingException(this.message);
  
  @override
  String toString() => message;
}

/// Response model for fee calculation
class FeeResponse {
  final double fee;
  
  FeeResponse({required this.fee});
  
  factory FeeResponse.fromJson(Map<String, dynamic> json) {
    return FeeResponse(
      fee: (json['fee'] ?? 0).toDouble(),
    );
  }
}

/// Payment summary model
class PaymentSummary {
  final double tokenAmount;
  final double kuickpayFee;
  final double totalAmount;
  
  PaymentSummary({
    required this.tokenAmount,
    required this.kuickpayFee,
    required this.totalAmount,
  });
  
  String get formattedTokenAmount {
    return 'PKR ${_formatNumberWithCommas(tokenAmount)}';
  }
  
  String get formattedKuickPayFee {
    return 'PKR ${_formatNumberWithCommas(kuickpayFee)}';
  }
  
  String get formattedTotalAmount {
    return 'PKR ${_formatNumberWithCommas(totalAmount)}';
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
  
  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      tokenAmount: (json['tokenAmount'] ?? 0).toDouble(),
      kuickpayFee: (json['kuickpayFee'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

/// Reserve plot data model
class ReservePlotData {
  final String psid;
  final String tokenAmount;
  final String kuickpayFee;
  final String challanExpiryTime;
  
  ReservePlotData({
    required this.psid,
    required this.tokenAmount,
    required this.kuickpayFee,
    required this.challanExpiryTime,
  });
  
  String get formattedTotalAmount {
    final token = double.tryParse(tokenAmount) ?? 0;
    final fee = double.tryParse(kuickpayFee) ?? 0;
    final total = token + fee;
    return 'PKR ${_formatNumberWithCommas(total)}';
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
  
  factory ReservePlotData.fromJson(Map<String, dynamic> json) {
    return ReservePlotData(
      psid: json['psid'] ?? '',
      tokenAmount: json['tokenAmount']?.toString() ?? '0',
      kuickpayFee: json['kuickpayFee']?.toString() ?? '0',
      challanExpiryTime: json['challanExpiryTime'] ?? '',
    );
  }
}

/// Reserve plot response wrapper
class ReservePlotResponse {
  final ReservePlotData data;
  
  ReservePlotResponse({required this.data});
  
  factory ReservePlotResponse.fromJson(Map<String, dynamic> json) {
    return ReservePlotResponse(
      data: ReservePlotData.fromJson(json['data'] ?? json),
    );
  }
}

/// Service for handling KuickPay payment operations
class KuickPayService {
  static const String _baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  final AuthService _authService = AuthService();
  
  /// Calculate KuickPay fee for a given amount
  Future<FeeResponse> calculateFee(double amount) async {
    try {
      // TODO: Implement actual API call if available
      // For now, returning a mock calculation (typically 2-3% fee)
      final fee = amount * 0.025; // 2.5% fee
      
      return FeeResponse(fee: fee);
    } catch (e) {
      throw Exception('Failed to calculate fee: $e');
    }
  }
  
  /// Get payment summary for a plot
  Future<PaymentSummary> getPaymentSummary(
    double basePrice,
    String paymentPlan,
    double tokenAmount,
  ) async {
    try {
      // Calculate KuickPay fee
      final feeResponse = await calculateFee(tokenAmount);
      final totalAmount = tokenAmount + feeResponse.fee;
      
      return PaymentSummary(
        tokenAmount: tokenAmount,
        kuickpayFee: feeResponse.fee,
        totalAmount: totalAmount,
      );
    } catch (e) {
      throw Exception('Failed to get payment summary: $e');
    }
  }
  
  /// Reserve a plot
  Future<ReservePlotResponse> reservePlot(
    String plotId,
    double tokenAmount,
    String paymentMethod,
    String planType,
  ) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Unauthenticated. Please login to continue.');
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/reserve-plot'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'plot_id': plotId,
          'token_amount': tokenAmount,
          'payment_method': paymentMethod,
          'plan_type': planType,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ReservePlotResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 409) {
        // Conflict - duplicate booking
        throw DuplicateBookingException('This plot has already been booked');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthenticated. Please login to continue.');
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Failed to reserve plot';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is DuplicateBookingException) {
        rethrow;
      }
      if (e.toString().contains('Unauthenticated') || 
          e.toString().contains('not authenticated')) {
        throw Exception('Unauthenticated. Please login to continue.');
      }
      throw Exception('Failed to reserve plot: $e');
    }
  }
}

