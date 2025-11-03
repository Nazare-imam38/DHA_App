import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import '../../../services/amenities_service.dart';
import 'media_upload_step.dart';
import '../../../core/theme/app_theme.dart';

class AmenitiesSelectionStep extends StatefulWidget {
  const AmenitiesSelectionStep({Key? key}) : super(key: key);
  
  @override
  _AmenitiesSelectionStepState createState() => _AmenitiesSelectionStepState();
}

class _AmenitiesSelectionStepState extends State<AmenitiesSelectionStep> {
  final AmenitiesService _amenitiesService = AmenitiesService();
  Map<String, List<Map<String, dynamic>>> _amenitiesByCategory = {};
  List<Map<String, dynamic>> _allAmenities = [];
  bool _isLoading = true;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _hasLoaded = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        _loadAmenities();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadAmenities();
    }
  }

  void _loadAmenities() async {
    if (!mounted) {
      print('❌ Widget not mounted, skipping amenities load');
      return;
    }
    
    print('=== AMENITIES STEP INITIALIZED ===');
    print('📱 Widget is mounted: $mounted');
    
    try {
      PropertyFormData? formData;
      try {
        formData = context.read<PropertyFormData>();
        print('✅ FormData accessed successfully');
        print('📋 Current amenities: ${formData.amenities}');
      } catch (e) {
        print('❌ Error accessing FormData: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      print('🔄 Loading amenities from service...');
      final propertyTypeId = formData.propertyTypeId;
      if (propertyTypeId == null) {
        print('❌ No propertyTypeId set in formData. Cannot load amenities.');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      final amenitiesByCategory = await _amenitiesService.getAmenitiesByPropertyType(propertyTypeId);
      print('✅ Loaded amenities categories: ${amenitiesByCategory.keys.length}');
      
      if (!mounted) {
        print('❌ Widget unmounted during load');
        return;
      }

      // Flatten for Select All and counts
      final List<Map<String, dynamic>> allAmenities = amenitiesByCategory.values
          .expand((list) => list)
          .toList();
      print('📊 Total amenities flattened count: ${allAmenities.length}');
      
      setState(() {
        _amenitiesByCategory = amenitiesByCategory;
        _allAmenities = allAmenities;
        _isLoading = false;
      });
      
      print('✅ Amenities loaded successfully');
    } catch (e) {
      print('❌ Error loading amenities: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleAmenity(Map<String, dynamic> amenity) {
    final formData = context.read<PropertyFormData>();
    final amenityId = amenity['id'].toString();
    
    List<String> currentAmenities = List.from(formData.amenities);
    List<Map<String, dynamic>> currentAmenityDetails = List.from(formData.selectedAmenityDetails);
    
    if (currentAmenities.contains(amenityId)) {
      // Remove amenity
      currentAmenities.remove(amenityId);
      currentAmenityDetails.removeWhere((detail) => detail['id'].toString() == amenityId);
    } else {
      // Add amenity
      currentAmenities.add(amenityId);
      currentAmenityDetails.add({
        'id': amenity['id'],
        'amenity_name': amenity['name'],
        'description': amenity['description'],
        'amenity_type': amenity['amenity_type'] ?? _findAmenityCategory(amenity['id']),
        'amenity_order': amenity['amenity_order'],
      });
    }
    
    formData.updateAmenities(currentAmenities, amenityDetails: currentAmenityDetails);
    print('🔄 Updated amenities: $currentAmenities');
    print('🔄 Updated amenity details: ${currentAmenityDetails.length} items');
    print('🔄 FormData amenities after update: ${formData.amenities}');
    print('🔄 FormData selectedAmenityDetails after update: ${formData.selectedAmenityDetails.length} items');
  }

  void _selectAll() {
    final formData = context.read<PropertyFormData>();
    final allAmenityIds = _allAmenities.map((a) => a['id'].toString()).toList();
    final allAmenityDetails = _allAmenities.map((amenity) => {
      'id': amenity['id'],
      'amenity_name': amenity['name'],
      'description': amenity['description'],
      'amenity_type': amenity['amenity_type'] ?? _findAmenityCategory(amenity['id']),
      'amenity_order': amenity['amenity_order'],
    }).toList();
    
    formData.updateAmenities(allAmenityIds, amenityDetails: allAmenityDetails);
    print('✅ Selected all amenities: $allAmenityIds');
  }

  void _clearAll() {
    final formData = context.read<PropertyFormData>();
    formData.updateAmenities([], amenityDetails: []);
    print('🗑️ Cleared all amenities');
  }

  String _findAmenityCategory(dynamic amenityId) {
    for (final entry in _amenitiesByCategory.entries) {
      final categoryName = entry.key;
      final amenities = entry.value;
      
      for (final amenity in amenities) {
        if (amenity['id'] == amenityId) {
          return categoryName;
        }
      }
    }
    return 'Other';
  }

  // Icon mapping for amenities
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyFormData>(
      builder: (context, formData, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF1B5993),
                size: 16,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: const Color(0xFF1B5993),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'SELECT AMENITIES',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5993),
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
                  color: const Color(0xFF1B5993),
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
              // Process Indicator
              Container(
                padding: EdgeInsets.all(16.w),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FD),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF20B2AA).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF20B2AA),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '5',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Amenities Selection',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF20B2AA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Header Section with Status and Actions
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: const Color(0xFF1B5993),
                      size: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Available Amenities',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B5993),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${formData.amenities.length} of ${_allAmenities.length} selected',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B5993),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Select All Button
                    GestureDetector(
                      onTap: _selectAll,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5993),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Clear All Button
                    GestureDetector(
                      onTap: _clearAll,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pro Tip Section
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: const Color(0xFF4CAF50),
                                    size: 24.w,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      'Pro Tip: Select all amenities that are currently available at your property to attract the right buyers',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF6B7280),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 24.h),
                            
                            // Amenities List - Flat List (All Amenities)
                            _allAmenities.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.w),
                                      child: Text(
                                        'No amenities available',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _allAmenities.length,
                                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                                    itemBuilder: (context, index) {
                                      final amenity = _allAmenities[index];
                                      return _buildAmenityItem(amenity, formData);
                                    },
                                  ),
                            ],
                          ),
                        ),
                  ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              boxShadow: AppTheme.lightShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: AppTheme.outlineButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _nextStep(context, formData);
                  },
                  style: AppTheme.primaryButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAmenityItem(Map<String, dynamic> amenity, PropertyFormData formData) {
    final amenityId = amenity['id'].toString();
    final isSelected = formData.amenities.contains(amenityId);
    final amenityName = amenity['name'] ?? 'Unknown';
    final icon = _getAmenityIcon(amenityName);
    
    return GestureDetector(
      onTap: () => _toggleAmenity(amenity),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFE8F4FD) 
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryBlue 
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? AppTheme.primaryBlue 
                    : const Color(0xFF6B7280),
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            // Amenity Name
            Expanded(
              child: Text(
                amenityName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Checkbox
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryBlue 
                    : Colors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryBlue 
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.w,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
  
  void _nextStep(BuildContext context, PropertyFormData formData) {
    print('🚀 Navigating to Media Upload Step');
    print('📋 Selected amenities: ${formData.amenities}');
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider.value(
          value: formData,
          child: MediaUploadStep(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}