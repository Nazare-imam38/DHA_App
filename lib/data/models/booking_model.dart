import 'package:flutter/material.dart';
import '../../core/services/kuick_pay_service.dart';

/// Model for plot bookings/reservations
class BookingModel {
  final String id;
  final String plotNo;
  final String psid;
  final String tokenAmount;
  final String kuickpayFee;
  final String totalAmount;
  final String challanExpiryTime;
  final String paymentMethod;
  final String planType;
  final String status; // 'reserved', 'paid', 'expired'
  final DateTime createdAt;
  final DateTime? paidAt;

  BookingModel({
    required this.id,
    required this.plotNo,
    required this.psid,
    required this.tokenAmount,
    required this.kuickpayFee,
    required this.totalAmount,
    required this.challanExpiryTime,
    required this.paymentMethod,
    required this.planType,
    required this.status,
    required this.createdAt,
    this.paidAt,
  });

  factory BookingModel.fromReservePlotData(ReservePlotData data, String plotNo) {
    final token = double.tryParse(data.tokenAmount) ?? 0;
    final fee = double.tryParse(data.kuickpayFee) ?? 0;
    final total = token + fee;
    
    return BookingModel(
      id: data.psid, // Use PSID as unique ID
      plotNo: plotNo,
      psid: data.psid,
      tokenAmount: data.tokenAmount,
      kuickpayFee: data.kuickpayFee,
      totalAmount: total.toString(),
      challanExpiryTime: data.challanExpiryTime,
      paymentMethod: 'KuickPay',
      planType: '0',
      status: 'reserved',
      createdAt: DateTime.now(),
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      plotNo: json['plotNo'] ?? '',
      psid: json['psid'] ?? '',
      tokenAmount: json['tokenAmount'] ?? '0',
      kuickpayFee: json['kuickpayFee'] ?? '0',
      totalAmount: json['totalAmount'] ?? '0',
      challanExpiryTime: json['challanExpiryTime'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      planType: json['planType'] ?? '',
      status: json['status'] ?? 'reserved',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plotNo': plotNo,
      'psid': psid,
      'tokenAmount': tokenAmount,
      'kuickpayFee': kuickpayFee,
      'totalAmount': totalAmount,
      'challanExpiryTime': challanExpiryTime,
      'paymentMethod': paymentMethod,
      'planType': planType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  /// Get formatted total amount
  String get formattedTotalAmount {
    final amount = double.tryParse(totalAmount) ?? 0;
    return 'PKR ${_formatNumberWithCommas(amount)}';
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

  /// Check if reservation is expired
  bool get isExpired {
    try {
      final expiryTime = DateTime.parse(challanExpiryTime);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return false;
    }
  }

  /// Get remaining time until expiry
  Duration? get remainingTime {
    try {
      final expiryTime = DateTime.parse(challanExpiryTime);
      final now = DateTime.now();
      if (now.isAfter(expiryTime)) {
        return null; // Expired
      }
      return expiryTime.difference(now);
    } catch (e) {
      return null;
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'reserved':
        return isExpired ? Colors.red : Colors.orange;
      case 'paid':
        return Colors.green;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get status text
  String get statusText {
    if (isExpired) {
      return 'Expired';
    }
    switch (status.toLowerCase()) {
      case 'reserved':
        return 'Reserved';
      case 'paid':
        return 'Paid';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
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
