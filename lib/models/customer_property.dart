import 'dart:convert';
import 'package:flutter/material.dart';

class CustomerProperty {
  final String id;
  final String title;
  final String description;
  final String purpose; // Sell or Rent
  final String category; // Residential or Commercial
  final String? propertyType;
  final int? propertyTypeId; // Property type ID from API
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
  final double? latitude;
  final double? longitude;
  final String? paymentMethod;
  final int? durationDays; // Duration in days from API
  final List<String> images;
  final List<String> videos;
  List<String> amenities;
  Map<String, dynamic>? amenitiesByCategory; // Store amenities grouped by category
  final String? createdAt;
  final String? updatedAt;
  
  // Approval status
  String? approvalStatus;
  String? approvalNotes;
  bool? isApprovalLoading;
  
  // Property approvals and rejection logs
  List<Map<String, dynamic>>? propertyApprovals;
  List<Map<String, dynamic>>? propertyRejectionLogs;
  
  // User/Owner contact information
  String? userName;
  String? userPhone;

  CustomerProperty({
    required this.id,
    required this.title,
    required this.description,
    required this.purpose,
    required this.category,
    this.propertyType,
    this.propertyTypeId,
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
    this.latitude,
    this.longitude,
    this.paymentMethod,
    this.durationDays,
    List<String>? images,
    List<String>? videos,
    List<String>? amenities,
    this.amenitiesByCategory,
    this.createdAt,
    this.updatedAt,
    this.approvalStatus,
    this.approvalNotes,
    this.isApprovalLoading = false,
    this.propertyApprovals,
    this.propertyRejectionLogs,
    this.userName,
    this.userPhone,
  }) : images = images ?? [],
       videos = videos ?? [],
       amenities = amenities ?? [];

  factory CustomerProperty.fromJson(Map<String, dynamic> json) {
    final propertyId = json['id']?.toString() ?? '';
    final amenitiesData = json['amenities'];
    final parsedAmenities = _parseAmenitiesList(amenitiesData);
    final parsedAmenitiesByCategory = _parseAmenitiesByCategory(amenitiesData, json['amenities_by_category']);
    final mediaData = json['images'] ?? json['media'];
    final parsedImages = _parseMediaList(mediaData);
    
    // Parse user/owner contact information
    String? userName;
    String? userPhone;
    
    // Check for user object in the response
    if (json['user'] is Map) {
      final userData = json['user'] as Map;
      userName = userData['name']?.toString();
      userPhone = userData['phone']?.toString() ?? 
                  userData['phone_number']?.toString() ?? 
                  userData['mobile']?.toString() ??
                  userData['contact']?.toString();
    }
    
    // If no user object, check owner array (first owner if available)
    if ((userName == null || userPhone == null) && json['owner'] is List) {
      final ownerList = json['owner'] as List;
      if (ownerList.isNotEmpty && ownerList.first is Map) {
        final ownerData = ownerList.first as Map;
        userName = userName ?? ownerData['name']?.toString();
        userPhone = userPhone ?? 
                    ownerData['phone']?.toString() ?? 
                    ownerData['phone_number']?.toString() ?? 
                    ownerData['mobile']?.toString() ??
                    ownerData['contact']?.toString();
      }
    }
    
    // Check for phone number at top level (as fallback)
    if (userPhone == null) {
      userPhone = json['phone']?.toString() ?? 
                  json['phone_number']?.toString() ?? 
                  json['owner_phone']?.toString() ??
                  json['contact_number']?.toString();
    }
    
    // Check for owner object (not array)
    if ((userName == null || userPhone == null) && json['owner'] is Map) {
      final ownerData = json['owner'] as Map;
      userName = userName ?? ownerData['name']?.toString();
      userPhone = userPhone ?? 
                  ownerData['phone']?.toString() ?? 
                  ownerData['phone_number']?.toString() ?? 
                  ownerData['mobile']?.toString() ??
                  ownerData['contact']?.toString();
    }
    
    print('🏠 Parsing property $propertyId');
    print('   📸 Media/Images: ${parsedImages.length} items');
    print('   🎯 Amenities: ${parsedAmenities.length} items, Categories: ${parsedAmenitiesByCategory?.keys.length ?? 0}');
    print('   👤 User: $userName, Phone: $userPhone');
    if (parsedAmenitiesByCategory != null) {
      parsedAmenitiesByCategory.forEach((cat, items) {
        print('   📁 Category "$cat": ${items.length} amenities');
      });
    }
    
    return CustomerProperty(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      category: _stringOrName(json['category']) ?? '',
      propertyType: _stringOrName(json['property_type']),
      propertyTypeId: json['property_type_id'] is int 
          ? json['property_type_id'] as int
          : (json['property_type_id'] != null ? int.tryParse(json['property_type_id'].toString()) : null) ??
            (json['property_type'] is Map ? (json['property_type'] as Map)['id'] as int? : null),
      price: json['price']?.toString(),
      rentPrice: json['rent_price']?.toString(),
      location: _stringOrName(json['location']),
      phase: _stringOrName(json['phase']),
      sector: _stringOrName(json['sector']),
      area: json['area']?.toString() ?? json['size']?.toString(), // API uses 'size' field
      areaUnit: json['area_unit']?.toString(),
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      apartmentNumber: json['apartment_number']?.toString() ?? json['unit_no']?.toString(), // API uses 'unit_no'
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      paymentMethod: json['payment_method']?.toString(),
      durationDays: json['duration_days'] is int ? json['duration_days'] as int : (json['duration_days'] != null ? int.tryParse(json['duration_days'].toString()) : null),
      images: parsedImages,
      videos: _parseStringList(json['videos']),
      amenities: parsedAmenities,
      amenitiesByCategory: parsedAmenitiesByCategory,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      userName: userName,
      userPhone: userPhone,
      // Parse property approvals and rejection logs
      propertyApprovals: json['property_approvals'] is List 
          ? List<Map<String, dynamic>>.from(
              (json['property_approvals'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : {})
            )
          : null,
      propertyRejectionLogs: json['property_rejection_logs'] is List
          ? List<Map<String, dynamic>>.from(
              (json['property_rejection_logs'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : {})
            )
          : null,
      // Parse approval status from API response - determine from property_approvals and rejection_logs
      approvalStatus: _determineApprovalStatus(
        json['property_approvals'],
        json['property_rejection_logs'],
        json['approval_status'],
        json['status'],
        json['is_approved'],
      ),
    );
  }

  /// Determine approval status based on property_approvals and property_rejection_logs
  static String? _determineApprovalStatus(
    dynamic propertyApprovals,
    dynamic propertyRejectionLogs,
    dynamic approvalStatus,
    dynamic status,
    dynamic isApproved,
  ) {
    // First check if there are rejection logs - if so, property is rejected
    if (propertyRejectionLogs is List && propertyRejectionLogs.isNotEmpty) {
      return 'rejected';
    }
    
    // Check property_approvals array
    if (propertyApprovals is List && propertyApprovals.isNotEmpty) {
      // Check if all approvals have status "Approved"
      bool allApproved = true;
      bool hasRejected = false;
      
      for (var approval in propertyApprovals) {
        if (approval is Map) {
          final approvalStatus = approval['status']?.toString().toLowerCase();
          if (approvalStatus == 'rejected') {
            hasRejected = true;
            allApproved = false;
            break; // If any is rejected, property is rejected
          } else if (approvalStatus != 'approved') {
            allApproved = false;
          }
        }
      }
      
      if (hasRejected) {
        return 'rejected';
      } else if (allApproved) {
        return 'approved';
      } else {
        return 'pending';
      }
    }
    
    // Fallback to other status fields if property_approvals is not available
    if (approvalStatus != null) {
      return approvalStatus.toString().toLowerCase();
    }
    if (status != null) {
      return status.toString().toLowerCase();
    }
    if (isApproved == true) {
      return 'approved';
    }
    if (isApproved == false) {
      return 'pending';
    }
    
    // Default to pending if no status information is available
    return 'pending';
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      return double.tryParse(v);
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      // Support list of strings or list of maps with url-like fields
      return value.map((e) {
        if (e is Map) {
          final v = e['url'] ?? e['image_url'] ?? e['full_url'] ?? e['src'] ?? e['path'] ?? e['file'] ?? e['image'];
          return v?.toString() ?? e.toString();
        }
        return e.toString();
      }).toList();
    }
    if (value is String) {
      try {
        // Try to parse as JSON array
        final List<dynamic> parsed = json.decode(value);
        return parsed.map((e) {
          if (e is Map) {
            final v = e['url'] ?? e['image_url'] ?? e['full_url'] ?? e['src'] ?? e['path'] ?? e['file'] ?? e['image'];
            return v?.toString() ?? e.toString();
          }
          return e.toString();
        }).toList();
      } catch (e) {
        // If not JSON, split by comma
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return [];
  }

  static List<String> _parseMediaList(dynamic value) {
    if (value == null) {
      print('📸 Media data is null');
      return [];
    }
    if (value is List) {
      print('📸 Parsing media list with ${value.length} items');
      final images = value.where((e) {
        // Only include images (not videos)
        if (e is Map) {
          final mediaType = e['media_type']?.toString() ?? e['type']?.toString() ?? '';
          final typeLower = mediaType.toLowerCase();
          print('   📷 Media item type: "$mediaType" (lowercase: "$typeLower")');
          // Check for video types - skip them
          if (typeLower == 'video' || typeLower == 'videos') {
            print('   ⏭️ Skipping video');
            return false;
          }
          // Include if it's "Image" (case-insensitive) or if no type specified (assume image)
          if (typeLower == 'image' || mediaType.isEmpty) {
            print('   ✅ Including image');
            return true;
          }
          // If type is something else, skip it
          print('   ❓ Unknown type, skipping');
          return false;
        }
        // Non-map items are included (strings, etc.)
        print('   ✅ Including non-map item (string)');
        return true;
      }).map((e) {
        if (e is Map) {
          // API uses 'media_link' field - prioritize this
          final mediaLink = e['media_link'];
          if (mediaLink != null) {
            final url = mediaLink.toString().trim();
            if (url.isNotEmpty) {
              print('   ✅ Extracted image URL from media_link: ${url.substring(0, url.length > 60 ? 60 : url.length)}...');
              return url;
            }
          }
          
          // Fallback to other possible field names
          final v = e['url'] ?? 
                   e['image_url'] ?? 
                   e['full_url'] ?? 
                   e['src'] ?? 
                   e['path'] ?? 
                   e['file'] ?? 
                   e['image'] ?? 
                   e['media_url'];
          final url = v?.toString()?.trim();
          if (url != null && url.isNotEmpty) {
            print('   ✅ Extracted image URL from fallback: ${url.substring(0, url.length > 60 ? 60 : url.length)}...');
            return url;
          } else {
            print('   ❌ No URL found in media item. Available keys: ${e.keys.toList()}');
          }
          return null;
        }
        // Handle string values directly
        final strValue = e?.toString()?.trim();
        if (strValue != null && strValue.isNotEmpty) {
          print('   ✅ Using string value directly: ${strValue.substring(0, strValue.length > 60 ? 60 : strValue.length)}...');
          return strValue;
        }
        return null;
      }).whereType<String>().where((url) => url.isNotEmpty).toList();
      print('📸 Final parsed images: ${images.length}');
      if (images.isNotEmpty) {
        print('   📷 First image URL: ${images.first.substring(0, images.first.length > 80 ? 80 : images.first.length)}...');
      }
      return images;
    }
    print('📸 Media is not a list, using fallback parser. Type: ${value.runtimeType}');
    return _parseStringList(value);
  }

  static String? _stringOrName(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) {
      final candidate = v['name'] ?? v['title'] ?? v['label'];
      return candidate?.toString();
    }
    return v.toString();
  }

  static List<String> _parseAmenitiesList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) {
        if (e is Map) {
          // Extract amenity name from the object
          return e['amenity_name']?.toString() ?? e['name']?.toString() ?? e.toString();
        }
        // If it's a number (ID), store it as string to be resolved later
        if (e is num) {
          return e.toString(); // Store ID as string for later resolution
        }
        return e.toString();
      }).where((name) => name.isNotEmpty).toList();
    }
    return _parseStringList(value);
  }

  static Map<String, dynamic>? _parseAmenitiesByCategory(dynamic amenities, dynamic amenitiesByCategory) {
    // If API provides amenities_by_category, use it
    if (amenitiesByCategory is Map) {
      return Map<String, dynamic>.from(amenitiesByCategory);
    }
    // Parse from amenities array - group by amenity_type (category)
    if (amenities is List && amenities.isNotEmpty) {
      Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var item in amenities) {
        if (item is Map) {
          // Use amenity_type as the category (e.g., "Basic Utilities", "Security & Safety")
          final category = item['amenity_type']?.toString() ?? 
                          item['category']?.toString() ?? 
                          item['category_name']?.toString() ?? 
                          'Other';
          
          if (!grouped.containsKey(category)) {
            grouped[category] = [];
          }
          
          // Store the full amenity object or at least the name
          grouped[category]!.add({
            'id': item['id'],
            'name': item['amenity_name'] ?? item['name'],
            'description': item['description'],
            'amenity_type': category,
          });
        } else if (item is num) {
          // Handle case where amenities come back as just IDs (numbers)
          // Store with ID only, name will be resolved later
          // We'll group them under 'Unresolved' temporarily, they'll be properly categorized when resolved
          if (!grouped.containsKey('Unresolved')) {
            grouped['Unresolved'] = [];
          }
          grouped['Unresolved']!.add({
            'id': item.toInt(),
            'name': item.toString(), // Store ID as name temporarily
            'description': null,
            'amenity_type': 'Unresolved',
          });
        }
      }
      return grouped.isNotEmpty ? grouped : null;
    }
    return null;
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
      'latitude': latitude,
      'longitude': longitude,
      'payment_method': paymentMethod,
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
  
  // Status helpers - recalculate based on property_approvals and rejection_logs
  bool get isPending {
    // Recalculate status if we have property_approvals data
    if (propertyApprovals != null || propertyRejectionLogs != null) {
      final calculatedStatus = _calculateStatusFromApprovals();
      return calculatedStatus == null || calculatedStatus == 'pending';
    }
    return approvalStatus == null || approvalStatus == 'pending';
  }
  
  bool get isApproved {
    // Recalculate status if we have property_approvals data
    if (propertyApprovals != null || propertyRejectionLogs != null) {
      final calculatedStatus = _calculateStatusFromApprovals();
      return calculatedStatus == 'approved';
    }
    return approvalStatus == 'approved';
  }
  
  bool get isRejected {
    // Recalculate status if we have property_approvals data
    if (propertyApprovals != null || propertyRejectionLogs != null) {
      final calculatedStatus = _calculateStatusFromApprovals();
      return calculatedStatus == 'rejected';
    }
    return approvalStatus == 'rejected';
  }
  
  /// Calculate status from property_approvals and property_rejection_logs
  String? _calculateStatusFromApprovals() {
    // First check rejection logs
    if (propertyRejectionLogs != null && propertyRejectionLogs!.isNotEmpty) {
      return 'rejected';
    }
    
    // Check property_approvals
    if (propertyApprovals != null && propertyApprovals!.isNotEmpty) {
      bool allApproved = true;
      bool hasRejected = false;
      
      for (var approval in propertyApprovals!) {
        final status = approval['status']?.toString().toLowerCase();
        if (status == 'rejected') {
          hasRejected = true;
          allApproved = false;
          break;
        } else if (status != 'approved') {
          allApproved = false;
        }
      }
      
      if (hasRejected) {
        return 'rejected';
      } else if (allApproved) {
        return 'approved';
      } else {
        return 'pending';
      }
    }
    
    // Fallback to stored approvalStatus
    return approvalStatus;
  }
  
  Color get statusColor {
    // Use calculated status from approvals
    final status = _calculateStatusFromApprovals() ?? approvalStatus;
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
  
  String get statusText {
    // Use calculated status from approvals
    final status = _calculateStatusFromApprovals() ?? approvalStatus;
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }
}