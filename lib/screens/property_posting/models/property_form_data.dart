import 'package:flutter/material.dart';
import 'dart:io';

class PropertyFormData extends ChangeNotifier {
  // Step 1: Ownership
  int? onBehalf; // 0 = own property, 1 = on behalf of someone
  
  // Step 2: Owner Details (ONLY if on_behalf = 1)
  String? cnic;
  String? name;
  String? phone;
  String? address;
  String? email;
  
  // Step 3: Purpose
  String? purpose; // "Sell" or "Rent"
  
  // Step 3: Property Type & Basic Listing Info (Combined)
  String? category; // "Residential" or "Commercial"
  int? propertyTypeId; // ID from API
  String? propertyTypeName; // Name from API (e.g., "Apartment", "Plot", "Office", "Shop")
  int? propertySubtypeId; // ID for subtype
  String? propertySubtypeName; // Name for subtype
  String? title;
  String? description;
  String? listingDuration; // "15 Days", "30 Days", "60 Days"
  
  // Step 4: Pricing (Separated)
  double? price;
  double? rentPrice;
  String? propertyDuration; // "15 days", "30 days", "60 days"
  
  // Step 5: Property Details
  String? buildingName;
  String? floorNumber;
  String? apartmentNumber;
  double? area;
  String? areaUnit; // "Marla", "Kanal", "Sqft", "Sqyd"
  String? streetNumber;
  
  // Step 6: Location Details
  String? location; // Complete address for geocoding
  String? sector;
  String? phase;
  double? latitude;
  double? longitude;
  String? block;
  String? streetNo;
  String? floor;
  String? building;
  
  // Step 7: Unit Details
  String? unitNo;
  
  // Step 8: Payment Method
  String? paymentMethod; // "KuickPay", "Credit-Debit", "Other"
  
  // Step 9: Media
  List<File> images = [];
  List<File> videos = [];
  
  // Step 5: Amenities
  List<String> amenities = []; // List of selected amenity IDs
  
  // Submission tracking
  String? submittedPropertyId; // Store property ID after successful submission
  
  // Helper methods
  bool get isOwnProperty => onBehalf == 0;
  bool get isRent => purpose == "Rent";
  bool get hasOwnerDetails => onBehalf == 1;
  
  // Updated validation for simplified flow (removed unit details and payment method)
  bool isStepValid(int stepNumber) {
    switch (stepNumber) {
      case 1: return onBehalf != null;
      case 2: return !hasOwnerDetails || 
               (cnic != null && name != null && phone != null && address != null);
      case 3: return purpose != null;
      case 4: return category != null && propertyTypeId != null && 
               title != null && description != null && 
               (listingDuration != null || propertyDuration != null) &&
               (isRent ? (rentPrice != null) : (price != null));
      case 5: return buildingName != null && floorNumber != null && apartmentNumber != null &&
               area != null && areaUnit != null && phase != null && 
               sector != null && streetNumber != null &&
               location != null && latitude != null && longitude != null;
      case 6: return true; // Amenities optional
      case 7: return true; // Media upload optional
      case 8: return !hasOwnerDetails || 
               (cnic != null && name != null && phone != null && address != null); // Owner details if needed
      default: return false;
    }
  }
  
  // Update methods
  void updateOwnership(int? onBehalf) {
    this.onBehalf = onBehalf;
    notifyListeners();
  }
  
  void updateOwnerDetails({
    String? cnic,
    String? name,
    String? phone,
    String? address,
    String? email,
  }) {
    this.cnic = cnic;
    this.name = name;
    this.phone = phone;
    this.address = address;
    this.email = email;
    notifyListeners();
  }
  
  void updatePurpose(String? purpose) {
    this.purpose = purpose;
    notifyListeners();
  }
  
  void updatePropertyTypeAndListing({
    String? category,
    int? propertyTypeId,
    String? propertyTypeName,
    int? propertySubtypeId,
    String? propertySubtypeName,
    String? title,
    String? description,
    String? listingDuration,
  }) {
    if (category != null) this.category = category;
    if (propertyTypeId != null) this.propertyTypeId = propertyTypeId;
    if (propertyTypeName != null) this.propertyTypeName = propertyTypeName;
    if (propertySubtypeId != null) this.propertySubtypeId = propertySubtypeId;
    if (propertySubtypeName != null) this.propertySubtypeName = propertySubtypeName;
    if (title != null) this.title = title;
    if (description != null) this.description = description;
    if (listingDuration != null) this.listingDuration = listingDuration;
    notifyListeners();
  }
  
  void updateTypePricing({
    int? propertyTypeId,
    String? category,
    double? price,
    double? rentPrice,
    String? propertyDuration,
  }) {
    if (propertyTypeId != null) this.propertyTypeId = propertyTypeId;
    if (category != null) this.category = category;
    if (price != null) this.price = price;
    if (rentPrice != null) this.rentPrice = rentPrice;
    if (propertyDuration != null) this.propertyDuration = propertyDuration;
    notifyListeners();
  }
  
  void updatePropertyDetails({
    String? buildingName,
    String? floorNumber,
    String? apartmentNumber,
    double? area,
    String? areaUnit,
    String? streetNumber,
  }) {
    if (buildingName != null) this.buildingName = buildingName;
    if (floorNumber != null) this.floorNumber = floorNumber;
    if (apartmentNumber != null) this.apartmentNumber = apartmentNumber;
    if (area != null) this.area = area;
    if (areaUnit != null) this.areaUnit = areaUnit;
    if (streetNumber != null) this.streetNumber = streetNumber;
    notifyListeners();
  }
  
  void updateLocationDetails({
    String? location,
    String? sector,
    String? phase,
    double? latitude,
    double? longitude,
    String? block,
    String? streetNo,
    String? floor,
    String? building,
  }) {
    this.location = location;
    this.sector = sector;
    this.phase = phase;
    this.latitude = latitude;
    this.longitude = longitude;
    this.block = block;
    this.streetNo = streetNo;
    this.floor = floor;
    this.building = building;
    notifyListeners();
  }
  
  void updateUnitDetails(String? unitNo) {
    this.unitNo = unitNo;
    notifyListeners();
  }
  
  void updatePaymentMethod(String? paymentMethod) {
    this.paymentMethod = paymentMethod;
    notifyListeners();
  }
  
  void updateMedia({
    List<File>? images,
    List<File>? videos,
  }) {
    if (images != null) this.images = images;
    if (videos != null) this.videos = videos;
    notifyListeners();
  }
  
  void updateAmenities(List<String> amenities) {
    this.amenities = amenities;
    notifyListeners();
  }
  
  void toggleAmenity(String amenityId) {
    if (amenities.contains(amenityId)) {
      amenities.remove(amenityId);
    } else {
      amenities.add(amenityId);
    }
    notifyListeners();
  }
  
  void updateSubmittedPropertyId(String? propertyId) {
    submittedPropertyId = propertyId;
    notifyListeners();
  }
}
