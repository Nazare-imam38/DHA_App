class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String cnic;
  final int role;
  final String? address;
  final String? fatherName;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.role,
    this.address,
    this.fatherName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      cnic: json['cnic'] ?? '',
      role: json['role'] ?? 0,
      address: json['address'],
      fatherName: json['father_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'cnic': cnic,
      'role': role,
      'address': address,
      'father_name': fatherName,
    };
  }
}

class ReserveBooking {
  final int id;
  final String date;
  final String tokenAmount;
  final String bidAmount;
  final String status;
  final int rankNo;
  final String challanNo;
  final String challanType;
  final String challanDate;
  final String challanExpiryTime;
  final String kuickpayFee;
  final String? redirectUrl;
  final String? paymentDate;
  final String? receivedDate;
  final String receivedAmount;
  final String? bankType;
  final String? bankName;
  final String? chequeNo;
  final String? chequeDate;
  final String? paymentMode;
  final String trendTime;
  final int planType;
  final int interestedOneYear;
  final bool isBidding;
  final Plot plot;

  ReserveBooking({
    required this.id,
    required this.date,
    required this.tokenAmount,
    required this.bidAmount,
    required this.status,
    required this.rankNo,
    required this.challanNo,
    required this.challanType,
    required this.challanDate,
    required this.challanExpiryTime,
    required this.kuickpayFee,
    this.redirectUrl,
    this.paymentDate,
    this.receivedDate,
    required this.receivedAmount,
    this.bankType,
    this.bankName,
    this.chequeNo,
    this.chequeDate,
    this.paymentMode,
    required this.trendTime,
    required this.planType,
    required this.interestedOneYear,
    required this.isBidding,
    required this.plot,
  });

  factory ReserveBooking.fromJson(Map<String, dynamic> json) {
    return ReserveBooking(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      tokenAmount: json['token_amount']?.toString() ?? '0',
      bidAmount: json['bid_amount']?.toString() ?? '0',
      status: json['status'] ?? '',
      rankNo: json['rank_no'] ?? 0,
      challanNo: json['challan_no'] ?? '',
      challanType: json['challan_type'] ?? '',
      challanDate: json['challan_date'] ?? '',
      challanExpiryTime: json['challan_expiry_time'] ?? '',
      kuickpayFee: json['kuickpay_fee']?.toString() ?? '0',
      redirectUrl: json['redirect_url'],
      paymentDate: json['payment_date'],
      receivedDate: json['received_date'],
      receivedAmount: json['received_amount']?.toString() ?? '0',
      bankType: json['bank_type'],
      bankName: json['bank_name'],
      chequeNo: json['cheque_no'],
      chequeDate: json['cheque_date'],
      paymentMode: json['payment_mode'],
      trendTime: json['trend_time'] ?? '',
      planType: json['plan_type'] ?? 0,
      interestedOneYear: json['interested_one_year'] ?? 0,
      isBidding: json['is_bidding'] ?? false,
      plot: Plot.fromJson(json['plot'] ?? {}),
    );
  }
}

class Plot {
  final int id;
  final String plotNo;
  final String category;
  final String phase;
  final String sector;
  final String streetNo;
  final String block;
  final String status;
  final String basePrice;
  final String tokenAmount;
  final String size;
  final String dimension;

  Plot({
    required this.id,
    required this.plotNo,
    required this.category,
    required this.phase,
    required this.sector,
    required this.streetNo,
    required this.block,
    required this.status,
    required this.basePrice,
    required this.tokenAmount,
    required this.size,
    required this.dimension,
  });

  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'] ?? 0,
      plotNo: json['plot_no'] ?? '',
      category: json['category'] ?? '',
      phase: json['phase'] ?? '',
      sector: json['sector'] ?? '',
      streetNo: json['street_no'] ?? '',
      block: json['block'] ?? '',
      status: json['status'] ?? '',
      basePrice: json['base_price']?.toString() ?? '0',
      tokenAmount: json['token_amount']?.toString() ?? '0',
      size: json['size'] ?? '',
      dimension: json['dimension'] ?? '',
    );
  }
}

class UserInfo {
  final User user;
  final List<ReserveBooking> reserveBookings;

  UserInfo({
    required this.user,
    required this.reserveBookings,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      user: User.fromJson(json['user'] ?? {}),
      reserveBookings: (json['reserve_bookings'] as List<dynamic>?)
          ?.map((booking) => ReserveBooking.fromJson(booking))
          .toList() ?? [],
    );
  }
}

// API Request Models
class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String cnic;
  final String password;
  final String passwordConfirmation;
  final String? isOverseas; // Optional: "0" or "1"
  final String? isSeller; // Optional: "0" or "1"

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.password,
    required this.passwordConfirmation,
    this.isOverseas,
    this.isSeller,
  });

  Map<String, String> toFormData() {
    final data = {
      'name': name,
      'email': email,
      'phone': phone,
      'cnic': cnic,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    
    // Add optional fields if provided
    if (isOverseas != null && isOverseas!.isNotEmpty) {
      data['is_overseas'] = isOverseas!;
    }
    if (isSeller != null && isSeller!.isNotEmpty) {
      data['is_seller'] = isSeller!;
    }
    
    return data;
  }
}

class VerifyOtpRequest {
  final int userId;
  final String otpCode;

  VerifyOtpRequest({
    required this.userId,
    required this.otpCode,
  });

  Map<String, String> toFormData() {
    return {
      'user_id': userId.toString(),
      'otp_code': otpCode,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, String> toFormData() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class ResendOtpRequest {
  final int userId;

  ResendOtpRequest({
    required this.userId,
  });

  Map<String, String> toFormData() {
    return {
      'user_id': userId.toString(),
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, String> toFormData() {
    return {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}

class ForgotPasswordRequest {
  final String email;
  final String cnic;
  final String phone;

  ForgotPasswordRequest({
    required this.email,
    required this.cnic,
    required this.phone,
  });

  Map<String, String> toFormData() {
    return {
      'email': email,
      'cnic': cnic,
      'phone': phone,
    };
  }
}

class ChangeAddressRequest {
  final String address;

  ChangeAddressRequest({
    required this.address,
  });

  Map<String, String> toJson() {
    return {
      'address': address,
    };
  }
}

class UpdateProfileRequest {
  final String name;
  final String cnic;
  final String address;

  UpdateProfileRequest({
    required this.name,
    required this.cnic,
    required this.address,
  });

  Map<String, String> toFormData() {
    return {
      'name': name,
      'cnic': cnic,
      'address': address,
    };
  }
}

// API Response Models
class RegisterResponse {
  final String message;
  final int userId;
  final String otpCode;

  RegisterResponse({
    required this.message,
    required this.userId,
    required this.otpCode,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      userId: json['user_id'] ?? 0,
      otpCode: json['otp_code'] ?? '',
    );
  }
}

class VerifyOtpResponse {
  final String message;
  final User user;
  final String accessToken;

  VerifyOtpResponse({
    required this.message,
    required this.user,
    required this.accessToken,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      accessToken: json['access_token'] ?? '',
    );
  }
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class ResendOtpResponse {
  final String message;
  final String otpCode;

  ResendOtpResponse({
    required this.message,
    required this.otpCode,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      message: json['message'] ?? '',
      otpCode: json['otp_code'] ?? '',
    );
  }
}

class UserInfoResponse {
  final String message;
  final UserInfo data;

  UserInfoResponse({
    required this.message,
    required this.data,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      message: json['message'] ?? '',
      data: UserInfo.fromJson(json['data'] ?? {}),
    );
  }
}

class UserByCnicResponse {
  final String status;
  final User user;

  UserByCnicResponse({
    required this.status,
    required this.user,
  });

  factory UserByCnicResponse.fromJson(Map<String, dynamic> json) {
    return UserByCnicResponse(
      status: json['status'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class ApiResponse {
  final String message;

  ApiResponse({
    required this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      message: json['message'] ?? '',
    );
  }
}
