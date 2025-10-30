import 'dart:convert';
import 'package:flutter/material.dart';

class CustomerProperty {
  final String id;
  final String title;
  final String description;
  final String purpose; // Sell or Rent
  final String category; // Residential or Commercial
  final String? propertyType;
  final String? price;
  final String? rentPrice;
  final String? location;
  final String? phase;
  final String? sector;
  final String? area;
  final String? areaUnit;
  final String? building;
  final String? floor;
  final String? apartmentNumber;
  final List<String> images;
  final List<String> videos;
  final List<String> amenities;
  final String? createdAt;
  final String? updatedAt;
  
  // Approval status
  String? approvalStatus;
  String? approvalNotes;
  bool? isApprovalLoading;

  CustomerProperty({
    required this.id,
    required this.title,
    required this.description,
    required this.purpose,
    required this.category,
    this.propertyType,
    this.price,
    this.rentPrice,
    this.location,
    this.phase,
    this.sector,
    this.area,
    this.areaUnit,
    this.building,
    this.floor,
    this.apartmentNumber,
    this.images = const [],
    this.videos = const [],
    this.amenities = const [],
    this.createdAt,
    this.updatedAt,
    this.approvalStatus,
    this.approvalNotes,
    this.isApprovalLoading = false,
  });

  factory CustomerProperty.fromJson(Map<String, dynamic> json) {
    return CustomerProperty(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      propertyType: json['property_type']?.toString(),
      price: json['price']?.toString(),
      rentPrice: json['rent_price']?.toString(),
      location: json['location']?.toString(),
      phase: json['phase']?.toString(),
      sector: json['sector']?.toString(),
      area: json['area']?.toString(),
      areaUnit: json['area_unit']?.toString(),
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      apartmentNumber: json['apartment_number']?.toString(),
      images: _parseStringList(json['images']),
      videos: _parseStringList(json['videos']),
      amenities: _parseStringList(json['amenities']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      try {
        // Try to parse as JSON array
        final List<dynamic> parsed = json.decode(value);
        return parsed.map((e) => e.toString()).toList();
      } catch (e) {
        // If not JSON, split by comma
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'purpose': purpose,
      'category': category,
      'property_type': propertyType,
      'price': price,
      'rent_price': rentPrice,
      'location': location,
      'phase': phase,
      'sector': sector,
      'area': area,
      'area_unit': areaUnit,
      'building': building,
      'floor': floor,
      'apartment_number': apartmentNumber,
      'images': images,
      'videos': videos,
      'amenities': amenities,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper getters
  bool get isRent => purpose.toLowerCase() == 'rent';
  String get displayPrice => isRent ? (rentPrice ?? 'N/A') : (price ?? 'N/A');
  String get priceLabel => isRent ? 'Rent' : 'Sale Price';
  String get fullLocation => [location, phase, sector].where((e) => e != null && e.isNotEmpty).join(', ');
  String get propertyDetails => [area, areaUnit].where((e) => e != null && e.isNotEmpty).join(' ');
  
  // Status helpers
  bool get isPending => approvalStatus == null || approvalStatus == 'pending';
  bool get isApproved => approvalStatus == 'approved';
  bool get isRejected => approvalStatus == 'rejected';
  
  Color get statusColor {
    switch (approvalStatus?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
  
  String get statusText {
    switch (approvalStatus?.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }
}