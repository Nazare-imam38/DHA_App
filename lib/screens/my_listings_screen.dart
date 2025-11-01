import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/customer_properties_service.dart';
import '../models/customer_property.dart';
import '../core/theme/app_theme.dart';
import 'listing_detail_screen.dart';
import '../core/services/geocoding_service.dart';
import 'package:latlong2/latlong.dart';
import 'update_property_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final CustomerPropertiesService _service = CustomerPropertiesService();
  final GeocodingService _geocodingService = GeocodingService();
  List<CustomerProperty> _properties = [];
  List<CustomerProperty> _filteredProperties = [];
  bool _isLoading = true;
  String? _error;
  final Map<String, String?> _geocodedAddresses = {}; // Cache geocoded addresses
  
  // Filter options
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _geocodeProperty(CustomerProperty property) async {
    if (property.latitude == null || property.longitude == null) return;
    
    final cacheKey = '${property.latitude},${property.longitude}';
    if (_geocodedAddresses.containsKey(cacheKey)) return;
    
    try {
      final address = await _geocodingService.reverseGeocode(
        LatLng(property.latitude!, property.longitude!),
      );
      if (mounted) {
        setState(() {
          _geocodedAddresses[cacheKey] = address;
        });
      }
    } catch (e) {
      print('Geocoding error for property ${property.id}: $e');
    }
  }

  void _navigateToUpdateProperty(CustomerProperty property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePropertyScreen(property: property),
      ),
    ).then((_) {
      // Refresh properties after update
      _loadProperties();
    });
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // If you want to test with a provided token, you can temporarily pass it here.
      // final result = await _service.getCustomerProperties(overrideToken: 'YOUR_TEST_TOKEN');
      final result = await _service.getCustomerProperties();
      
      if (result['success'] == true) {
        final data = result['data'];
        List<CustomerProperty> properties = [];
        
        // Parse properties from API response
        if (data is Map && data['properties'] is List) {
          final propertiesList = data['properties'] as List;
          properties = propertiesList.map((json) => CustomerProperty.fromJson(json)).toList();
        } else if (data is List) {
          properties = data.map((json) => CustomerProperty.fromJson(json)).toList();
        } else if (data is Map && data['data'] is List) {
          final propertiesList = data['data'] as List;
          properties = propertiesList.map((json) => CustomerProperty.fromJson(json)).toList();
        }
        
        // Load approval status for each property and geocode addresses
        for (var property in properties) {
          _loadApprovalStatus(property);
          _geocodeProperty(property);
        }
        
        // Amenities are now included in the API response - no need for separate resolution
        print('✅ Properties loaded with amenities from API');
        
        setState(() {
          _properties = properties;
          _isLoading = false;
        });
        // Apply current filter (defaults to Pending)
        _applyFilter(_selectedFilter);
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load properties';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading properties: $e';
        _isLoading = false;
      });
    }
  }




  


  Future<void> _loadApprovalStatus(CustomerProperty property) async {
    property.isApprovalLoading = true;
    
    try {
      final result = await _service.getPropertyApprovalStatus(property.id);
      
      if (result['success']) {
        final data = result['data'];
        property.approvalStatus = data['status']?.toString() ?? 'pending';
        property.approvalNotes = data['notes']?.toString();
      } else {
        property.approvalStatus = 'unknown';
        property.approvalNotes = 'Could not fetch status';
      }
    } catch (e) {
      property.approvalStatus = 'error';
      property.approvalNotes = 'Error fetching status';
    } finally {
      property.isApprovalLoading = false;
      if (mounted) setState(() {});
    }
  }



  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      if (filter == 'All') {
        _filteredProperties = _properties;
      } else {
        _filteredProperties = _properties.where((property) {
          switch (filter) {
            case 'Pending':
              return property.isPending;
            case 'Approved':
              return property.isApproved;
            case 'Rejected':
              return property.isRejected;
            default:
              return true;
          }
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primaryBlue,
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.home_work_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'MY LISTINGS',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0.h),
          child: Container(
            height: 2.0.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: 12.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) => _applyFilter(filter),
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.tealAccent.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppTheme.tealAccent : AppTheme.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.tealAccent : AppTheme.borderGrey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/ownership-selection'),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Property',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryBlue,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadProperties,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 64.sp,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              _selectedFilter == 'All' ? 'No Properties Found' : 'No $_selectedFilter Properties',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _selectedFilter == 'All' 
                  ? 'You haven\'t posted any properties yet.'
                  : 'No properties match the selected filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            if (_selectedFilter == 'All') ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/ownership-selection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Post Your First Property',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProperties,
      color: AppTheme.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _filteredProperties.length,
        itemBuilder: (context, index) {
          return _buildPropertyCard(_filteredProperties[index]);
        },
      ),
    );
  }

  Widget _buildPropertyCard(CustomerProperty property) {
    // Debug: Check property images
    print('🎴 Building card for property ${property.id} - Images: ${property.images.length}');
    if (property.images.isNotEmpty) {
      print('   📷 First image URL: ${property.images.first.substring(0, property.images.first.length > 80 ? 80 : property.images.first.length)}...');
    }
    
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListingDetailScreen(property: property),
        ),
      ),
      child: Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
            // Property Image with Status Overlay
            Stack(
              children: [
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              color: AppTheme.lightBlue,
            ),
            child: (property.images.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: Stack(
                      children: [
                        PageView.builder(
                          itemCount: property.images.length,
                          itemBuilder: (context, idx) {
                            final raw = property.images[idx];
                            print('🖼️ Loading image ${idx + 1}/${property.images.length}: ${raw.substring(0, raw.length > 60 ? 60 : raw.length)}...');
                            final url = raw.startsWith('http')
                                ? raw
                                : 'https://testingbackend.dhamarketplace.com${raw.startsWith('/') ? '' : '/'}$raw';
                            return Image.network(
                              url,
                              width: double.infinity,
                              height: 200.h,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200.h,
                                  color: AppTheme.lightBlue,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Image load error: $error');
                                return _buildPlaceholderImage();
                              },
                            );
                          },
                        ),
                        // Simple dots indicator
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                property.images.length,
                                (index) => Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildPlaceholderImage(),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildStatusPill(property),
                ),
              ],
          ),
          
          // Property Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status with Edit Button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildStatusChip(property),
                    SizedBox(width: 8.w),
                    // Edit Button
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryBlue,
                        size: 20.sp,
                      ),
                      onPressed: () => _navigateToUpdateProperty(property),
                      tooltip: 'Edit Property',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                // Property Size
                if (property.area != null && property.area!.isNotEmpty)
                  Text(
                    '${property.area} ${property.areaUnit ?? ''}'.trim(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                
                SizedBox(height: 8.h),
                
                // Price
                Text(
                  '${property.priceLabel}: PKR ${property.displayPrice}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.tealAccent,
                  ),
                ),
                
                // Amenities
                if (property.amenitiesByCategory != null && property.amenitiesByCategory!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildAmenitiesSection(property),
                ] else if (property.amenities.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildAmenitiesSection(property),
                ],
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection(CustomerProperty property) {
    print('🎯 Building amenities section for property ${property.id}');
    print('   📋 amenitiesByCategory: ${property.amenitiesByCategory}');
    print('   📋 flat amenities: ${property.amenities}');
    
    // Get all amenity names to display
    final List<String> amenityNames = [];
    
    if (property.amenitiesByCategory != null && property.amenitiesByCategory!.isNotEmpty) {
      // Extract names from amenitiesByCategory
      for (final category in property.amenitiesByCategory!.values) {
        if (category is List) {
          for (var amenity in category) {
            if (amenity is Map) {
              final name = amenity['name']?.toString();
              if (name != null && name.isNotEmpty) {
                // Skip if it's still just an ID (numeric string)
                if (!RegExp(r'^\d+$').hasMatch(name)) {
                  amenityNames.add(name);
                }
              }
            }
          }
        }
      }
    } else if (property.amenities.isNotEmpty) {
      // Use flat amenities list, but skip numeric IDs
      for (final amenity in property.amenities) {
        if (amenity.isNotEmpty && !RegExp(r'^\d+$').hasMatch(amenity)) {
          amenityNames.add(amenity);
        }
      }
    }
    
    // If no resolved names but we have amenities, show count
    if (amenityNames.isEmpty && 
        ((property.amenitiesByCategory != null && property.amenitiesByCategory!.isNotEmpty) || 
         property.amenities.isNotEmpty)) {
      final totalCount = property.amenitiesByCategory?.values
          .expand((list) => list is List ? list : [])
          .length ?? property.amenities.length;
      
      if (totalCount > 0) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '$totalCount amenities',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlue,
            ),
          ),
        );
      }
    }
    
    if (amenityNames.isEmpty) return const SizedBox.shrink();
    
    // Show up to 3 amenities, with "and X more" if there are more
    final displayAmenities = amenityNames.take(3).toList();
    final remainingCount = amenityNames.length - displayAmenities.length;
    
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: [
        ...displayAmenities.map((name) => Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlue,
            ),
          ),
        )),
        if (remainingCount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '+$remainingCount more',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 48.sp,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 8.h),
          Text(
            'No Image',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CustomerProperty property) {
    if (property.isApprovalLoading == true) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12.sp,
              height: 12.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textSecondary),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'Loading...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: property.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: property.statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        property.statusText,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: property.statusColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: AppTheme.primaryBlue,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // Top-right status pill overlay (e.g., Available/Pending/Rejected)
  Widget _buildStatusPill(CustomerProperty property) {
    final bg = property.statusColor.withValues(alpha: 0.12);
    final fg = property.statusColor;
    final text = property.isApproved ? 'Available' : property.statusText;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            property.isApproved
                ? Icons.check_circle
                : property.isRejected
                    ? Icons.cancel
                    : Icons.hourglass_top,
            size: 14.sp,
            color: fg,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}