import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import '../../../services/media_upload_service.dart';
import '../../../services/local_amenities_cache.dart';
import '../../property_listing_status_screen.dart';
import '../../main_wrapper.dart';
import '../../../ui/widgets/app_icons.dart';
import '../../../core/theme/app_theme.dart';

class ReviewConfirmationStep extends StatefulWidget {
  @override
  _ReviewConfirmationStepState createState() => _ReviewConfirmationStepState();
}

class _ReviewConfirmationStepState extends State<ReviewConfirmationStep> {
  final MediaUploadService _mediaUploadService = MediaUploadService();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final formData = context.watch<PropertyFormData>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowBackIos, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Review Details',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              title: 'Listing',
              rows: [
                _row('Purpose', formData.purpose),
                _row('Category', formData.category),
                _row('Type', formData.propertyTypeName),
                _row('Subtype', formData.propertySubtypeName),
                _row('Title', formData.title),
                _row('Description', formData.description),
                _row('Duration', formData.listingDuration),
                _row(formData.isRent ? 'Rent Price' : 'Sale Price', 
                     formData.isRent ? formData.rentPrice?.toString() : formData.price?.toString()),
              ],
            ),
            SizedBox(height: 16.h),
            _section(
              title: 'Property Details',
              rows: [
                _row('Building', formData.buildingName),
                _row('Floor', formData.floorNumber),
                _row('Apartment', formData.apartmentNumber),
                _row('Area', formData.area?.toString()),
                _row('Area Unit', formData.areaUnit),
                _row('Street Number', formData.streetNumber),
              ],
            ),
            SizedBox(height: 16.h),
            _section(
              title: 'Location Details',
              rows: [
                _row('Complete Address', formData.location ?? 'Not provided'),
                _row('Phase', formData.phase),
                _row('Sector', formData.sector),
                _row('Street Number', formData.streetNumber),
                _row('Coordinates', formData.latitude != null && formData.longitude != null 
                    ? '${formData.latitude!.toStringAsFixed(6)}, ${formData.longitude!.toStringAsFixed(6)}'
                    : 'Not set'),
              ],
            ),
            SizedBox(height: 16.h),
            _section(
              title: 'Media',
              rows: [
                _row('Photos', '${formData.images.length} uploaded'),
                _row('Videos', '${formData.videos.length} uploaded'),
              ],
            ),
            SizedBox(height: 16.h),
            _section(
              title: 'Amenities',
              rows: [
                _row('Selected', formData.amenities.isEmpty ? 'None' : '${formData.amenities.length} amenities selected'),
              ],
            ),

            if (formData.onBehalf == 1) ...[
              SizedBox(height: 16.h),
              _section(
                title: 'Owner Details',
                rows: [
                  _row('CNIC', formData.cnic),
                  _row('Name', formData.name),
                  _row('Phone', formData.phone),
                  _row('Address', formData.address),
                  _row('Email', formData.email ?? 'Not provided'),
                ],
              ),
            ],
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitProperty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cardWhite),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Submitting...',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.cardWhite,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Confirm & Submit',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cardWhite,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> rows}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value == null || value.toString().isEmpty ? '-' : value.toString(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProperty() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final formData = context.read<PropertyFormData>();
      final propertyData = _preparePropertyData(formData);

      print('🚀 SUBMITTING PROPERTY: Starting API call');
      print('📍 Property Data: $propertyData');

      final result = await _mediaUploadService.uploadPropertyMedia(
        images: formData.images,
        videos: formData.videos,
        propertyData: propertyData,
      );

      if (result['success'] == true) {
        // Store the property ID for status tracking
        final propertyId = result['data']?['id']?.toString();
        if (propertyId != null) {
          formData.updateSubmittedPropertyId(propertyId);
          
          // Store the exact amenities selected by the user for this specific property
          if (formData.amenities.isNotEmpty) {
            await LocalAmenitiesCache.storePropertyAmenities(propertyId, formData.amenities);
            print('💾 Stored ${formData.amenities.length} selected amenity IDs for property $propertyId: ${formData.amenities}');
          }
          
          // Store the complete amenity details (names, descriptions) for display
          if (formData.selectedAmenityDetails.isNotEmpty) {
            final propertyAmenityDetails = <String, Map<String, dynamic>>{};
            for (final amenity in formData.selectedAmenityDetails) {
              final id = amenity['id'].toString();
              propertyAmenityDetails[id] = {
                'name': amenity['amenity_name']?.toString() ?? 'Unknown',
                'description': amenity['description']?.toString() ?? '',
                'amenity_type': amenity['amenity_type']?.toString() ?? 'Other',
              };
            }
            
            // Store property-specific amenity details
            await LocalAmenitiesCache.storePropertyAmenityDetails(propertyId, propertyAmenityDetails);
            print('💾 Stored complete amenity details for property $propertyId: ${propertyAmenityDetails.keys.toList()}');
          }
        }
        _showSuccessDialog(result['data']);
      } else {
        _showErrorDialog('Submission failed: ${result['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Error submitting property: $e');
      _showErrorDialog('Submission failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Map<String, dynamic> _preparePropertyData(PropertyFormData formData) {
    print('🔍 DEBUG: Preparing property data...');
    print('🔍 FormData amenities: ${formData.amenities}');
    print('🔍 FormData selectedAmenityDetails: ${formData.selectedAmenityDetails.length} items');
    
    // Prepare amenities with complete details
    List<Map<String, dynamic>> amenitiesArray = [];
    
    if (formData.selectedAmenityDetails.isNotEmpty) {
      // Use complete amenity details if available
      amenitiesArray = formData.selectedAmenityDetails;
      print('🏠 Using complete amenity details: ${amenitiesArray.length} items');
      
      for (int i = 0; i < amenitiesArray.length; i++) {
        final amenity = amenitiesArray[i];
        print('   Amenity $i: ID=${amenity['id']}, Name=${amenity['amenity_name']}, Type=${amenity['amenity_type']}');
      }
    } else if (formData.amenities.isNotEmpty) {
      // Fallback to IDs only (for backward compatibility)
      final amenityIds = formData.amenities.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      amenitiesArray = amenityIds.map((id) => {'id': int.tryParse(id) ?? 0}).toList();
      print('🏠 Using amenity IDs only: ${amenityIds}');
    } else {
      print('⚠️ WARNING: No amenities found in formData!');
    }
    
    print('🏠 Final amenities being sent: ${amenitiesArray.length} items');
    print('🏠 Purpose: ${formData.purpose}, isRent: ${formData.isRent}');
    print('🏠 Price: ${formData.price}, RentPrice: ${formData.rentPrice}');
    
    Map<String, dynamic> propertyData = {
      // Basic property info
      'title': formData.title,
      'description': formData.description,
      'purpose': formData.purpose,
      'category': formData.category,
      'property_type_id': formData.propertyTypeId?.toString(),
      'property_subtype_id': formData.propertySubtypeId?.toString(),
      // Map listing duration to API format
      'property_duration': _mapDurationToApiFormat(formData.listingDuration ?? formData.propertyDuration),
      'is_rent': formData.isRent ? '1' : '0',
      
      // Required location fields
      'location': formData.location, // Complete address
      'latitude': formData.latitude?.toString(),
      'longitude': formData.longitude?.toString(),
      
      // Property details
      'building': formData.buildingName, // API expects 'building' not 'building_name'
      'floor': formData.floorNumber, // API expects 'floor' not 'floor_number'
      'apartment_number': formData.apartmentNumber,
      'area': formData.area?.toString(),
      'area_unit': formData.areaUnit,
      'phase': formData.phase,
      'sector': formData.sector,
      'street_number': formData.streetNumber,
      
      // Unit details (use apartment number as unit number)
      'unit_no': formData.apartmentNumber ?? formData.buildingName ?? 'N/A',
      
      // Default payment method (use KuickPay as requested)
      'payment_method': 'KuickPay', // Set KuickPay by default
      
      // Amenities as array
      'amenities': amenitiesArray,
      
      // Owner details (if posting on behalf)
      'on_behalf': formData.onBehalf?.toString() ?? '0',
      'cnic': formData.cnic,
      'name': formData.name,
      'phone': formData.phone,
      'address': formData.address,
      'email': formData.email,
    };
    
    // Add correct price field based on purpose
    if (formData.isRent) {
      propertyData['rent_price'] = formData.rentPrice?.toString();
    } else {
      propertyData['price'] = formData.price?.toString();
    }
    
    return propertyData;
  }
  
  // Map duration from UI format to API format
  String _mapDurationToApiFormat(String? duration) {
    if (duration == null) return '30 days'; // Default
    
    switch (duration) {
      case '15 Days':
        return '15 days';
      case '30 Days':
        return '30 days';
      case '60 Days':
        return '60 days';
      default:
        return '30 days'; // Default fallback
    }
  }

  void _showSuccessDialog(Map<String, dynamic>? responseData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(AppIcons.checkCircle, color: AppTheme.success, size: 28.sp),
            SizedBox(width: 12.w),
            const Text(
              'Application Submitted',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your property listing application is under process.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            if (responseData != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.tealAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (responseData['id'] != null)
                      Text(
                        'Property ID: ${responseData['id']}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    if (responseData['psid'] != null)
                      Text(
                        'PSID: ${responseData['psid']}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    if (responseData['property_fee'] != null)
                      Text(
                        'Property Fee: ${responseData['property_fee']}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    if (responseData['challan_due_date'] != null)
                      Text(
                        'Challan Due: ${responseData['challan_due_date']}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Go back to main app (home tab)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainWrapper(initialTabIndex: 0), // Home tab
                ),
                (route) => false, // Clear entire stack
              );
            },
            child: const Text('Back'),
          ),
          if (responseData?['id'] != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Back to previous
                _navigateToPropertyStatus(responseData!['id'].toString());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tealAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: const Text(
                'Check Status',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cardWhite,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Clear property posting stack and go to main app with profile tab
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainWrapper(initialTabIndex: 4), // Profile tab
                ),
                (route) => false, // Clear entire stack
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text(
              'Go to Profile',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.cardWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPropertyStatus(String propertyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyListingStatusScreen(propertyId: propertyId),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(AppIcons.error, color: AppTheme.error, size: 28.sp),
            SizedBox(width: 12.w),
            const Text(
              'Error',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.cardWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


