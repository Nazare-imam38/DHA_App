import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import '../../../services/media_upload_service.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5993)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
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
                _row('Price', formData.isRent ? formData.rentPrice?.toString() : formData.price?.toString()),
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
              title: 'Location',
              rows: [
                _row('Phase', formData.phase),
                _row('Sector', formData.sector),
                _row('Latitude', formData.latitude?.toString()),
                _row('Longitude', formData.longitude?.toString()),
              ],
            ),
            SizedBox(height: 16.h),
            _section(
              title: 'Amenities',
              rows: [
                _row('Selected', formData.amenities.isEmpty ? 'None' : formData.amenities.join(', ')),
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
                      side: const BorderSide(color: Color(0xFF1B5993), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5993),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitProperty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5993),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Submitting...',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
                              color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5993),
            ),
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
                color: Color(0xFF616161),
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
                color: Color(0xFF1B5993),
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
        _showSuccessDialog();
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
    return {
      // Basic property info
      'title': formData.title,
      'description': formData.description,
      'purpose': formData.purpose,
      'category': formData.category,
      'property_type_id': formData.propertyTypeId?.toString(),
      'property_subtype_id': formData.propertySubtypeId?.toString(),
      'listing_duration': formData.listingDuration,
      'price': formData.isRent ? formData.rentPrice?.toString() : formData.price?.toString(),
      'is_rent': formData.isRent ? '1' : '0',
      
      // Property details
      'building_name': formData.buildingName,
      'floor_number': formData.floorNumber,
      'apartment_number': formData.apartmentNumber,
      'area': formData.area?.toString(),
      'area_unit': formData.areaUnit,
      'phase': formData.phase,
      'sector': formData.sector,
      'street_number': formData.streetNumber,
      'latitude': formData.latitude?.toString(),
      'longitude': formData.longitude?.toString(),
      
      // Amenities
      'amenities': formData.amenities.join(','),
      
      // Owner details (if posting on behalf)
      'on_behalf': formData.onBehalf?.toString(),
      'cnic': formData.cnic,
      'name': formData.name,
      'phone': formData.phone,
      'address': formData.address,
      'email': formData.email,
    };
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28.sp),
            SizedBox(width: 12.w),
            const Text(
              'Application Submitted',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5993),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your property listing application is under process. You can check its status from your Profile page.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF616161),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Back to previous
            },
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5993),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text(
              'Go to Profile',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
            Icon(Icons.error, color: Colors.red, size: 28.sp),
            SizedBox(width: 12.w),
            const Text(
              'Error',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.red,
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
            color: Color(0xFF616161),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5993),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


