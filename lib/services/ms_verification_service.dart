// Frontend-only implementation - no HTTP calls needed

class MSVerificationService {
  
  // Verify MS number and get associated email/phone
  Future<MSVerificationResponse> verifyMSNumber(String msNumber) async {
    // For frontend-only implementation, simulate successful verification
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    
    // Return mock data for demo purposes
    return MSVerificationResponse(
      isValid: true,
      email: 'member@dha.gov.pk',
      phoneNumber: '+92 300 1234567',
      memberName: 'DHA Member',
      membershipStatus: 'Active',
    );
  }

  // Send OTP for MS number verification
  Future<void> sendMSOtp(String msNumber) async {
    // For frontend-only implementation, simulate successful OTP sending
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    print('OTP sent to registered email and phone for MS: $msNumber');
  }

  // Verify OTP for MS number
  Future<void> verifyMSOtp(String msNumber, String otpCode) async {
    // For frontend-only implementation, simulate OTP verification
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network delay
    
    // For demo purposes, accept any 6-digit OTP
    if (otpCode.length == 6 && RegExp(r'^\d{6}$').hasMatch(otpCode)) {
      print('OTP verified successfully for MS: $msNumber');
      return;
    } else {
      throw Exception('Invalid OTP code. Please enter a valid 6-digit code.');
    }
  }

  // Resend OTP for MS number
  Future<void> resendMSOtp(String msNumber) async {
    // For frontend-only implementation, simulate successful OTP resending
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    print('OTP resent to registered email and phone for MS: $msNumber');
  }
}

class MSVerificationResponse {
  final bool isValid;
  final String? email;
  final String? phoneNumber;
  final String? memberName;
  final String? membershipStatus;

  MSVerificationResponse({
    required this.isValid,
    this.email,
    this.phoneNumber,
    this.memberName,
    this.membershipStatus,
  });

  factory MSVerificationResponse.fromJson(Map<String, dynamic> json) {
    return MSVerificationResponse(
      isValid: json['is_valid'] ?? false,
      email: json['email'],
      phoneNumber: json['phone_number'],
      memberName: json['member_name'],
      membershipStatus: json['membership_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'email': email,
      'phone_number': phoneNumber,
      'member_name': memberName,
      'membership_status': membershipStatus,
    };
  }
}
