import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/customer_property.dart';
import '../core/theme/app_theme.dart';
import '../core/services/geocoding_service.dart';

class ListingDetailScreen extends StatefulWidget {
  final CustomerProperty property;
  const ListingDetailScreen({super.key, required this.property});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final GeocodingService _geocodingService = GeocodingService();
  String? _geocodedAddress;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _geocodeLocation();
    // Amenities should already be parsed from the customer-properties API response
    // with categories grouped by amenity_type field
  }

  Future<void> _geocodeLocation() async {
    final property = widget.property;
    if (property.latitude == null || property.longitude == null) return;
    
    setState(() {
      _isGeocoding = true;
    });
    
    try {
      final address = await _geocodingService.reverseGeocode(
        LatLng(property.latitude!, property.longitude!),
      );
      if (mounted) {
        setState(() {
          _geocodedAddress = address;
          _isGeocoding = false;
        });
      }
    } catch (e) {
      print('Geocoding error: $e');
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryBlue, size: 16),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Property Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.star_border), text: 'Features'),
              Tab(icon: Icon(Icons.place_outlined), text: 'Location'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Payment'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header image with overlay price/title
            _buildHeader(p),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFeatures(p),
                  _buildLocation(p),
                  _buildPayment(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CustomerProperty p) {
    return Stack(
      children: [
        Container(
          height: 180.h,
          width: double.infinity,
          color: AppTheme.lightBlue,
          child: p.images.isNotEmpty
              ? Image.network(
                  p.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: AppTheme.lightBlue),
                )
              : Container(color: AppTheme.lightBlue),
        ),
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: _buildStatusPill(p),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PKR ${p.displayPrice}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                p.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.fullLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white70,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatusPill(CustomerProperty p) {
    final bg = p.statusColor.withOpacity(0.12);
    final fg = p.statusColor;
    final text = p.isApproved ? 'Available' : p.statusText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            p.isApproved
                ? Icons.check_circle
                : p.isRejected
                    ? Icons.cancel
                    : Icons.hourglass_top,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(CustomerProperty p) {
    final amenitiesByCategory = p.amenitiesByCategory;
    final flatAmenities = p.amenities;
    
    // Debug logging
    print('🔍 Features tab - Property ${p.id}');
    print('   Flat amenities: ${flatAmenities.length}');
    print('   Categories: ${amenitiesByCategory?.keys.length ?? 0}');
    if (amenitiesByCategory != null) {
      amenitiesByCategory.forEach((cat, items) {
        print('   📁 "$cat": ${items.length} items');
      });
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Details Section
          Text(
            'Property Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Property Type
          if (p.propertyType != null && p.propertyType!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.home, color: AppTheme.primaryBlue, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Type',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          p.propertyType!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Purpose
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.sell, color: AppTheme.primaryBlue, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purpose',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        p.purpose,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Location
          if (p.fullLocation.isNotEmpty || (p.latitude != null && p.longitude != null))
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          p.fullLocation.isNotEmpty 
                              ? p.fullLocation 
                              : (p.latitude != null && p.longitude != null 
                                  ? '${p.latitude}, ${p.longitude}' 
                                  : 'Location not specified'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Description
          if (p.description.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.description, color: AppTheme.primaryBlue, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          p.description,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: 24.h),
          
          // Amenities/Features Section
          Text(
            'Amenities & Features',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          
          if (amenitiesByCategory != null && amenitiesByCategory.isNotEmpty) ...[
            // Display amenities grouped by category
            ...amenitiesByCategory.entries.map((entry) {
              final categoryName = entry.key;
              final amenities = entry.value;
              
              if (amenities == null) return const SizedBox.shrink();
              
              List<dynamic> amenityList = [];
              if (amenities is List) {
                amenityList = amenities;
              } else if (amenities is String) {
                amenityList = [amenities];
              }
              
              if (amenityList.isEmpty) return const SizedBox.shrink();
              
              return Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...amenityList.map((amenity) {
                      String name;
                      if (amenity is Map) {
                        name = amenity['name']?.toString() ?? 
                               amenity['amenity_name']?.toString() ?? 
                               amenity.toString();
                      } else {
                        name = amenity.toString();
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: const Color(0xFF4CAF50), size: 18.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
          ] else if (flatAmenities.isNotEmpty) ...[
            // Fallback: display flat list if no category info
            Text(
              'Plot Features',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 12.h),
            ...flatAmenities.map((name) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: const Color(0xFF4CAF50), size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ] else ...[
            Text(
              'Plot Features',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'No features provided',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocation(CustomerProperty p) {
    final lat = p.latitude;
    final lng = p.longitude;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          // Show geocoded address if available
          if (lat != null && lng != null) ...[
            if (_isGeocoding)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Getting address...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else if (_geocodedAddress != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 18.sp, color: AppTheme.primaryBlue),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _geocodedAddress!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (p.fullLocation.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 18.sp, color: AppTheme.primaryBlue),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${p.fullLocation} (${lat}, ${lng})',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 12.h),
          ],
          Container(
            height: 220.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: (lat != null && lng != null)
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.dhamarketplace.app',
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 36,
                          height: 36,
                          alignment: Alignment.topCenter,
                          child: const Icon(Icons.location_on, color: Color(0xFFE53935), size: 32),
                        )
                      ])
                    ],
                  )
                : const Center(child: Text('No location available')),
          ),
        ],
      ),
    );
  }

  Widget _buildPayment(CustomerProperty p) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          _buildPaymentRow('Price', 'PKR ${p.displayPrice}'),
          if (p.paymentMethod != null && p.paymentMethod!.isNotEmpty)
            _buildPaymentRow('Payment Method', p.paymentMethod!),
          if (p.category.isNotEmpty)
            _buildPaymentRow('Category', p.category),
          if (p.purpose.isNotEmpty)
            _buildPaymentRow('Purpose', p.purpose),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
