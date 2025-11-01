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

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyFormData>(
      builder: (context, formData, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundGrey,
          appBar: AppBar(
            backgroundColor: AppTheme.cardWhite,
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
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: AppTheme.lightShadow,
                  ),
                  child: Icon(
                    Icons.home_work,
                    color: AppTheme.primaryBlue,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Amenities',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${formData.amenities.length} amenities selected',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selection Status and Controls
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: AppTheme.lightShadow,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${formData.amenities.length} of ${_allAmenities.length} selected',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: _selectAll,
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Select All'),
                              style: AppTheme.outlineButtonStyle.copyWith(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            ElevatedButton.icon(
                              onPressed: _clearAll,
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Clear All'),
                              style: AppTheme.outlineButtonStyle.copyWith(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Amenities by Category
                      _amenitiesByCategory.isEmpty
                          ? const Center(
                              child: Text(
                                'No amenities available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            )
                          : Column(
                              children: _amenitiesByCategory.entries.map((entry) {
                                return _buildCategorySection(entry.key, entry.value, formData);
                              }).toList(),
                            ),
                    ],
                  ),
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
  
Widget _buildCategorySection(String category, List<Map<String, dynamic>> amenities, PropertyFormData formData) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: amenities.map((amenity) {
              return _buildAmenityChip(amenity, formData);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(Map<String, dynamic> amenity, PropertyFormData formData) {
    final amenityId = amenity['id'].toString();
    final isSelected = formData.amenities.contains(amenityId);
    
    return GestureDetector(
      onTap: () => _toggleAmenity(amenity),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGrey,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check,
                size: 16.w,
                color: AppTheme.cardWhite,
              ),
            if (isSelected) SizedBox(width: 8.w),
            Text(
              amenity['name'] ?? 'Unknown',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.cardWhite : AppTheme.textPrimary,
              ),
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