import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/customer_property.dart';
import '../core/theme/app_theme.dart';
import '../services/whatsapp_service.dart';
import '../services/call_service.dart';
import '../core/services/geocoding_service.dart';
import '../services/amenities_service.dart';

class ListingDetailScreen extends StatefulWidget {
  final CustomerProperty property;
  const ListingDetailScreen({super.key, required this.property});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final GeocodingService _geocodingService = GeocodingService();
  final AmenitiesService _amenitiesService = AmenitiesService();
  String? _geocodedAddress;
  bool _isGeocoding = false;
  Map<String, List<Map<String, dynamic>>>? _resolvedAmenitiesByCategory;
  bool _isLoadingAmenities = false;

  @override
  void initState() {
    super.initState();
    _geocodeLocation();
    _loadAmenitiesByIds();
  }

  /// Load amenities by their IDs - fetch all amenities for property type and resolve IDs
  Future<void> _loadAmenitiesByIds() async {
    final property = widget.property;
    
    // Check if we have a property type ID
    if (property.propertyTypeId == null) {
      print('⚠️ No property type ID, cannot fetch amenities');
      return;
    }

    // Extract amenity IDs from the property
    final amenityIds = _extractAmenityIds(property);
    if (amenityIds.isEmpty) {
      print('ℹ️ No amenity IDs found in property');
      return;
    }

    print('🔍 Found ${amenityIds.length} amenity IDs: $amenityIds');
    
    setState(() {
      _isLoadingAmenities = true;
    });

    try {
      // Fetch all amenities for this property type
      final amenitiesByCategory = await _amenitiesService.fetchAmenitiesByPropertyType(
        propertyTypeId: property.propertyTypeId!,
      );

      // Create mappings: ID -> name, ID -> category
      final Map<int, String> idToName = {};
      final Map<int, String> idToCategory = {};
      
      for (final entry in amenitiesByCategory.entries) {
        final categoryName = entry.key;
        for (final amenity in entry.value) {
          final id = amenity['id'] as int?;
          final name = amenity['name'] as String?;
          if (id != null && name != null) {
            idToName[id] = name;
            idToCategory[id] = categoryName;
          }
        }
      }

      // Resolve amenity IDs and group by category
      final Map<String, List<Map<String, dynamic>>> resolvedAmenities = {};
      
      for (final amenityId in amenityIds) {
        final id = amenityId is int ? amenityId : int.tryParse(amenityId.toString());
        if (id == null) continue;
        
        if (idToName.containsKey(id) && idToCategory.containsKey(id)) {
          final category = idToCategory[id]!;
          final name = idToName[id]!;
          
          if (!resolvedAmenities.containsKey(category)) {
            resolvedAmenities[category] = [];
          }
          
          resolvedAmenities[category]!.add({
            'id': id,
            'name': name,
          });
        } else {
          // If ID not found, skip it - don't show "Amenity ID: X"
          // Only show amenities that have actual names
          print('⚠️ Amenity ID $id not found in fetched amenities, skipping');
        }
      }

      if (mounted) {
        setState(() {
          _resolvedAmenitiesByCategory = resolvedAmenities.isNotEmpty ? resolvedAmenities : null;
          _isLoadingAmenities = false;
        });
        
        print('✅ Resolved ${amenityIds.length} amenities into ${resolvedAmenities.length} categories');
      }
    } catch (e) {
      print('❌ Error loading amenities: $e');
      if (mounted) {
        setState(() {
          _isLoadingAmenities = false;
        });
      }
    }
  }

  /// Extract amenity IDs from property (from amenities list or amenitiesByCategory)
  List<dynamic> _extractAmenityIds(CustomerProperty property) {
    final List<dynamic> ids = [];
    
    // First try to get IDs from amenitiesByCategory
    if (property.amenitiesByCategory != null) {
      property.amenitiesByCategory!.forEach((category, amenities) {
        if (amenities is List) {
          for (var amenity in amenities) {
            if (amenity is Map) {
              final id = amenity['id'];
              if (id != null) {
                ids.add(id);
              }
            } else if (amenity is num) {
              ids.add(amenity);
            }
          }
        }
      });
    }
    
    // If no IDs found in categories, check if amenities list contains IDs
    // The amenities list might contain IDs as numbers or strings
    if (ids.isEmpty && property.amenities.isNotEmpty) {
      // Try to parse the amenities list - it might be IDs or names
      // If they're all numbers or numeric strings, treat as IDs
      for (var item in property.amenities) {
        if (item is num) {
          ids.add(item);
        } else if (item is String) {
          final id = int.tryParse(item);
          if (id != null) {
            ids.add(id);
          }
        }
      }
    }
    
    return ids;
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
                      _cleanLocationString(p.fullLocation),
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
    // Use resolved amenities if available, otherwise fallback to property data
    final amenitiesByCategory = _resolvedAmenitiesByCategory ?? p.amenitiesByCategory;
    final flatAmenities = p.amenities;
    
    // Property Details Grid (Side by Side)
    // Collect all available details
    List<Map<String, dynamic>> details = [];
    
    if (p.propertyType != null && p.propertyType!.isNotEmpty)
      details.add({'label': 'Property Type', 'value': p.propertyType!});
    
    details.add({'label': 'Purpose', 'value': p.purpose});
    
    if (p.area != null && p.area!.isNotEmpty)
      details.add({'label': 'Size', 'value': p.area!});
    
    if (p.phase != null && p.phase!.isNotEmpty)
      details.add({'label': 'Phase', 'value': p.phase!});
    
    if (p.sector != null && p.sector!.isNotEmpty)
      details.add({'label': 'Sector', 'value': p.sector!});
    
    if (p.building != null && p.building!.isNotEmpty)
      details.add({'label': 'Building', 'value': p.building!});
    
    if (p.floor != null && p.floor!.isNotEmpty)
      details.add({'label': 'Floor', 'value': p.floor!});
    
    if (p.apartmentNumber != null && p.apartmentNumber!.isNotEmpty)
      details.add({'label': 'Unit No', 'value': p.apartmentNumber!});
    
    if (p.durationDays != null)
      details.add({'label': 'Duration', 'value': '${p.durationDays} Days'});
    
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
          
          // Display in 2-column grid
          ...List.generate(
            (details.length / 2).ceil(),
            (index) {
              final firstIndex = index * 2;
              final secondIndex = firstIndex + 1;
              
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildGridDetailItem(
                        details[firstIndex]['label'],
                        details[firstIndex]['value'],
                      ),
                    ),
                    if (secondIndex < details.length) ...[
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildGridDetailItem(
                          details[secondIndex]['label'],
                          details[secondIndex]['value'],
                        ),
                      ),
                    ] else
                      Expanded(child: SizedBox()),
                  ],
                ),
              );
            },
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
          
          // Show flat list of amenities selected by user in step 5
          // Filter out any IDs or "Amenity ID:" entries - only show actual amenity names
          if (flatAmenities.isNotEmpty) ...[
            ...flatAmenities.where((name) {
              final nameStr = name.toString().trim();
              // Filter out entries that are just numbers (IDs) or contain "Amenity ID:"
              if (nameStr.isEmpty) return false;
              if (nameStr.contains('Amenity ID:') || nameStr.startsWith('Amenity ID:')) return false;
              // Check if it's just a number (ID)
              if (RegExp(r'^\d+$').hasMatch(nameStr)) return false;
              return true;
            }).map((name) {
              final nameStr = name.toString().trim();
              final icon = _getAmenityIcon(nameStr);
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(icon, color: AppTheme.primaryBlue, size: 18.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        nameStr,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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

  // Helper function to remove coordinate patterns from location string
  String _cleanLocationString(String location) {
    // Remove patterns like "33.533725, 73.150831" or "(33.53, 73.15)"
    // Pattern matches: optional opening paren, digits and decimals, comma, space, digits and decimals, optional closing paren
    String cleaned = location.replaceAll(RegExp(r'\(?\d+\.?\d*\s*,\s*\d+\.?\d*\)?'), '');
    // Clean up any double commas or extra spaces
    cleaned = cleaned.replaceAll(RegExp(r',\s*,+'), ',');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Remove leading/trailing commas
    cleaned = cleaned.replaceAll(RegExp(r'^,+\s*|\s*,+$'), '').trim();
    return cleaned;
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
                        _cleanLocationString(p.fullLocation),
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
          
          // Contact Owner Section
          if (p.userPhone != null && p.userPhone!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.borderGrey,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Owner',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (p.userName != null && p.userName!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18.sp,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          p.userName!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 18.sp,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          p.userPhone!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      // Call Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makeCall(p.userPhone!),
                          icon: Icon(
                            Icons.phone,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Call',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF20B2AA),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // WhatsApp Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _sendWhatsApp(p.userPhone!, p),
                          icon: Icon(
                            Icons.message,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Message',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF20B2AA),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Icon mapping for amenities (same as in amenities_selection_step.dart)
  IconData _getAmenityIcon(String amenityName) {
    final name = amenityName.toLowerCase();
    if (name.contains('water')) return Icons.water_drop;
    if (name.contains('sewerage') || name.contains('drainage')) return Icons.water;
    if (name.contains('gas')) return Icons.local_gas_station;
    if (name.contains('electricity') || name.contains('power')) {
      if (name.contains('backup')) return Icons.battery_charging_full;
      return Icons.bolt;
    }
    if (name.contains('broadband') || name.contains('cable') || name.contains('wifi') || name.contains('wi-fi')) return Icons.wifi;
    if (name.contains('elevator')) return Icons.elevator;
    if (name.contains('fire') || name.contains('safety')) return Icons.shield;
    if (name.contains('waste') || name.contains('disposal') || name.contains('trash')) return Icons.delete_outline;
    if (name.contains('parking')) return Icons.local_parking;
    if (name.contains('security')) return Icons.security;
    if (name.contains('servant') || name.contains('quarter')) return Icons.home;
    if (name.contains('storage') || name.contains('utility')) return Icons.inventory_2;
    if (name.contains('reception')) return Icons.desk;
    return Icons.star_outline;
  }
  
  // Build detail row with icon and label
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
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
            child: Icon(icon, color: AppTheme.primaryBlue, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
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
    );
  }

  Widget _buildGridDetailItem(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppTheme.borderGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
  
  // Make phone call
  Future<void> _makeCall(String phoneNumber) async {
    try {
      await CallService.launchCall(phoneNumber);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Send WhatsApp message
  Future<void> _sendWhatsApp(String phoneNumber, CustomerProperty property) async {
    try {
      final message = 'Hi, I am interested in your property "${property.title}"';
      await WhatsAppService.launchWhatsApp(
        phoneNumber: phoneNumber,
        message: message,
        context: context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
