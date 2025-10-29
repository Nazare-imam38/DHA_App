import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import '../../../services/amenities_service.dart';
import 'media_upload_step.dart';

class AmenitiesSelectionStep extends StatefulWidget {
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
    // Load amenities immediately when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        print('🚀 Calling _loadAmenities() from initState postFrameCallback');
        _loadAmenities();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔄 didChangeDependencies called - _hasLoaded: $_hasLoaded');
    // Load amenities once when dependencies are ready
    if (!_hasLoaded) {
      _hasLoaded = true;
      print('🚀 Calling _loadAmenities() from didChangeDependencies');
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
        print('✅ Successfully read PropertyFormData from context');
      } catch (e) {
        print('❌ ERROR: Failed to read PropertyFormData from context: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      
      final propertyTypeId = formData?.propertyTypeId;
      
      print('=== AMENITIES LOADING DEBUG ===');
      print('Property Type ID: $propertyTypeId');
      print('Property Type Name: ${formData?.propertyTypeName}');
      print('Category: ${formData?.category}');
      print('Purpose: ${formData?.purpose}');
      
      if (propertyTypeId == null) {
        print('ERROR: Property type ID is null - cannot load amenities');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      
      print('🚀 Starting amenities API call...');
      print('🔗 API URL: https://testingbackend.dhamarketplace.com/api/amenities/by-property-type?property_type_id=$propertyTypeId');
      
      print('📞 Calling _amenitiesService.getAmenitiesByPropertyType($propertyTypeId)');
      final amenitiesData = await _amenitiesService.getAmenitiesByPropertyType(propertyTypeId);
      
      print('API Response received: ${amenitiesData.length} categories');
      
      if (!mounted) return;
      
      setState(() {
        _amenitiesByCategory = amenitiesData;
        _allAmenities = [];
        
        // Flatten all amenities into a single list, maintaining order
        amenitiesData.forEach((category, amenities) {
          print('Category: $category - ${amenities.length} amenities');
          for (var amenity in amenities) {
            _allAmenities.add({
              'id': amenity['id'].toString(),
              'name': amenity['amenity_name'],
              'description': amenity['description'],
              'category': category,
              'icon': _getIconForAmenity(amenity['amenity_name']),
              'selected': formData?.amenities.contains(amenity['id'].toString()) ?? false,
            });
          }
        });
        
        _isLoading = false;
      });
      
      print('SUCCESS: Loaded ${_allAmenities.length} amenities from ${amenitiesData.length} categories');
      print('Categories: ${amenitiesData.keys.toList()}');
      print('=== AMENITIES LOADING COMPLETE ===');
    } catch (e) {
      print('ERROR loading amenities: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getIconForAmenity(String amenityName) {
    switch (amenityName.toLowerCase()) {
      case 'electricity':
      case 'electricity (with backup)':
        return Icons.flash_on;
      case 'water supply':
        return Icons.water_drop;
      case 'sewerage/drainage':
        return Icons.water_drop_outlined;
      case 'gas':
        return Icons.local_fire_department;
      case 'broadband ready':
      case 'broadband/cable ready':
        return Icons.wifi;
      case 'elevator access':
      case 'elevator':
        return Icons.elevator;
      case 'fire safety':
      case 'fire safety system':
        return Icons.local_fire_department;
      case 'facility management':
        return Icons.settings;
      case 'waste disposal':
        return Icons.delete_outline;
      case 'parking':
      case 'parking (allocated)':
      case 'car parking':
        return Icons.local_parking;
      case 'security staff':
      case 'security & reception':
      case 'security features':
        return Icons.security;
      case 'fire extinguisher':
        return Icons.fire_extinguisher;
      case 'storage/utility areas':
        return Icons.storage;
      case 'power backup provision':
        return Icons.battery_charging_full;
      case 'servant quarter':
        return Icons.home_work;
      case 'outdoor spaces':
        return Icons.yard;
      default:
        return Icons.star;
    }
  }

  void _toggleAmenity(int index) {
    setState(() {
      _allAmenities[index]['selected'] = !_allAmenities[index]['selected'];
    });
    
    // Update form data
    final formData = context.read<PropertyFormData>();
    final selectedAmenities = _allAmenities
        .where((amenity) => amenity['selected'] == true)
        .map((amenity) => amenity['id'] as String)
        .toList();
    
    formData?.updateAmenities(selectedAmenities);
  }

  void _selectAll() {
    setState(() {
      for (var amenity in _allAmenities) {
        amenity['selected'] = true;
      }
    });
    
    final formData = context.read<PropertyFormData>();
    final allAmenityIds = _allAmenities.map((amenity) => amenity['id'] as String).toList();
    formData?.updateAmenities(allAmenityIds);
  }

  void _clearAll() {
    setState(() {
      for (var amenity in _allAmenities) {
        amenity['selected'] = false;
      }
    });
    
    final formData = context.read<PropertyFormData>();
    formData?.updateAmenities([]);
  }

  @override
  Widget build(BuildContext context) {
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
              'AMENITIES SELECTION',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.w),
        child: Consumer<PropertyFormData>(
          builder: (context, formData, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                
                // Process Indicator
                Center(
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
                
                const SizedBox(height: 32),
                
                // Main Question
                const Text(
                  'Property Amenities',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5993),
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Instructions Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Select all amenities available in your property. This helps attract more potential buyers or tenants.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF616161),
                      height: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Selected Amenities Count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1B5993).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFF1B5993),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${formData.amenities.length} amenities selected',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B5993),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Amenities Grid
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Color(0xFF1B5993),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                      const Text(
                        'Available Amenities',
                        style: TextStyle(
                          fontFamily: 'Inter',
                              fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5993),
                        ),
                      ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Select all amenities available at your property',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF616161),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Pro Tip
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF4CAF50),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Pro Tip: Select all amenities that are currently available at your property to attract the right buyers',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Selection Status and Controls
                      Row(
                        children: [
                       Text(
                         '${formData?.amenities.length ?? 0} of ${_allAmenities.length} selected',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5993),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _selectAll,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Select All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5993),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _clearAll,
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear All'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B5993),
                              side: const BorderSide(color: Color(0xFF1B5993)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Amenities Grid
                      _isLoading 
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1B5993),
                            ),
                          )
                        : _allAmenities.isEmpty
                            ? Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 40),
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[400],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No amenities available for this property type',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                                  childAspectRatio: 3.2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _allAmenities.length,
                        itemBuilder: (context, index) {
                                  final amenity = _allAmenities[index];
                                  final isSelected = amenity['selected'] as bool;
                          
                          return GestureDetector(
                                    onTap: () => _toggleAmenity(index),
                            child: Container(
                              decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF1B5993) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                          color: isSelected 
                                              ? const Color(0xFF1B5993) 
                                              : Colors.grey.withValues(alpha: 0.2),
                                          width: 1.5,
                                        ),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: const Color(0xFF1B5993).withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ] : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                              amenity['icon'] as IconData,
                                              color: isSelected ? Colors.white : const Color(0xFF1B5993),
                                              size: 22,
                                            ),
                                            const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                                amenity['name'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                                  color: isSelected ? Colors.white : const Color(0xFF1B5993),
                                      ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                    ),
                                  ),
                                            const SizedBox(width: 8),
                                    Icon(
                                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                              color: isSelected ? Colors.white : Colors.grey[400],
                                              size: 20,
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Tips Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amenities Tips',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5993),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildTipItem('Select amenities that are actually available'),
                      _buildTipItem('More amenities can increase property value'),
                      _buildTipItem('Be honest about what\'s included'),
                      _buildTipItem('You can add or remove amenities later'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Popular Amenities Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Most Popular Amenities',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5993),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildPopularAmenity('Parking', 'Essential for most properties'),
                      _buildPopularAmenity('Security', 'Highly valued by tenants'),
                      _buildPopularAmenity('Air Conditioning', 'Important for comfort'),
                      _buildPopularAmenity('WiFi', 'Modern necessity'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      
      // Navigation Buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.0.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B5993),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: const Color(0xFF1B5993),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                final formData = context.read<PropertyFormData>();
                _nextStep(context, formData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5993),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _nextStep(BuildContext context, PropertyFormData formData) {
    // Navigate to the media upload step
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider.value(
          value: formData,
          child: MediaUploadStep(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
  
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5993),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF1B5993),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPopularAmenity(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: const Color(0xFF1B5993),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF616161),
                ),
                children: [
                  TextSpan(
                    text: '$name - ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5993),
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}