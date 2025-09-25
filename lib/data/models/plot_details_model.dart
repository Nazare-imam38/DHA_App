class PlotDetailsModel {
  final String plotNo;
  final String phase;
  final String sector;
  final String street;
  final String size;
  final String dimension;
  final String status;
  final String category;
  final double lumpSumPrice;
  final double tokenAmount;
  final List<PaymentPlan> paymentPlans;
  final String? remarks;
  final double? latitude;
  final double? longitude;

  PlotDetailsModel({
    required this.plotNo,
    required this.phase,
    required this.sector,
    required this.street,
    required this.size,
    required this.dimension,
    required this.status,
    required this.category,
    required this.lumpSumPrice,
    required this.tokenAmount,
    required this.paymentPlans,
    this.remarks,
    this.latitude,
    this.longitude,
  });

  factory PlotDetailsModel.fromJson(Map<String, dynamic> json) {
    return PlotDetailsModel(
      plotNo: json['plotNo'] ?? '',
      phase: json['phase'] ?? '',
      sector: json['sector'] ?? '',
      street: json['street'] ?? '',
      size: json['size'] ?? '',
      dimension: json['dimension'] ?? '',
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      lumpSumPrice: (json['lumpSumPrice'] ?? 0).toDouble(),
      tokenAmount: (json['tokenAmount'] ?? 0).toDouble(),
      paymentPlans: (json['paymentPlans'] as List<dynamic>?)
          ?.map((plan) => PaymentPlan.fromJson(plan))
          .toList() ?? [],
      remarks: json['remarks'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class PaymentPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMonths;
  final bool isSelected;

  PaymentPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMonths,
    this.isSelected = false,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) {
    return PaymentPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationMonths: json['durationMonths'] ?? 0,
      isSelected: json['isSelected'] ?? false,
    );
  }

  PaymentPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? durationMonths,
    bool? isSelected,
  }) {
    return PaymentPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMonths: durationMonths ?? this.durationMonths,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
