import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/customer_property.dart';
import '../services/property_update_service.dart';
import '../screens/property_posting/models/property_form_data.dart';
import '../core/theme/app_theme.dart';
import 'my_listings_screen.dart';
import '../services/amenities_service.dart';

class UpdatePropertyScreen extends StatefulWidget {
  final CustomerProperty property;

  const UpdatePropertyScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<UpdatePropertyScreen> createState() => _UpdatePropertyScreenState();
}

class _UpdatePropertyScreenState extends State<UpdatePropertyScreen> {
  final PropertyUpdateService _updateService = PropertyUpdateService();
  final AmenitiesService _amenitiesService = AmenitiesService();
  int _currentStep = 1;
  final PageController _pageController = PageController();
  bool _isUpdating = false;
  PropertyFormData? _formData;
  Map<String, List<Map<String, dynamic>>> _amenitiesByCategory = {};
  List<Map<String, dynamic>> _allAmenities = [];
  bool _amenitiesLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    final property = widget.property;
    
    // Initialize form data with existing property values
    _formData = PropertyFormData();
    
    // Step 1: Basic Information
    _formData!.updatePurpose(property.purpose);
    _formData!.updatePropertyTypeAndListing(
      category: property.category,
      propertyTypeId: property.propertyTypeId,
      title: property.title,
      description: property.description,
      listingDuration: '30 Days',
    );
    _formData!.updateTypePricing(
      propertyTypeId: property.propertyTypeId,
      category: property.category,
      price: property.price != null ? double.tryParse(property.price!) : null,
      rentPrice: property.rentPrice != null ? double.tryParse(property.rentPrice!) : null,
    );
    _formData!.updatePropertyDetails(
      buildingName: property.building,
      floorNumber: property.floor,
      apartmentNumber: property.apartmentNumber,
      area: property.area != null ? double.tryParse(property.area!) : null,
      areaUnit: property.areaUnit,
    );
    
    // Step 2: Location
    _formData!.updateLocationDetails(
      location: property.location,
      sector: property.sector,
      phase: property.phase,
      latitude: property.latitude,
      longitude: property.longitude,
    );
    
    // Step 3: Amenities
    _formData!.updateAmenities(property.amenities);
    
    // Owner details
    _formData!.updateOwnership(0);
    
    // Load amenities for selection
    if (property.propertyTypeId != null) {
      _loadAmenities(property.propertyTypeId!);
    }
  }

  Future<void> _loadAmenities(int propertyTypeId) async {
    setState(() {
      _amenitiesLoading = true;
    });
    
    try {
      final amenitiesByCategory = await _amenitiesService.getAmenitiesByPropertyType(propertyTypeId);
      final allAmenities = amenitiesByCategory.values.expand((list) => list).toList();
      
      setState(() {
        _amenitiesByCategory = amenitiesByCategory;
        _allAmenities = allAmenities;
        _amenitiesLoading = false;
      });
    } catch (e) {
      setState(() {
        _amenitiesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.info_outline,
            title: 'Basic Information',
            description: 'Update your property\'s basic details',
          ),
          SizedBox(height: 32.h),
          
          // Purpose Selection
          Text(
            'Property Purpose',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildPurposeCard('Sell', Icons.sell, _formData?.purpose == 'Sell', () {
                  _formData?.updatePurpose('Sell');
                  setState(() {});
                }),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildPurposeCard('Rent', Icons.home, _formData?.purpose == 'Rent', () {
                  _formData?.updatePurpose('Rent');
                  setState(() {});
                }),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Title
          _buildTextField(
            label: 'Property Title *',
            icon: Icons.title,
            value: _formData?.title ?? '',
            onChanged: (value) {
              _formData?.updatePropertyTypeAndListing(title: value);
              setState(() {});
            },
          ),
          SizedBox(height: 16.h),
          
          // Description
          _buildTextField(
            label: 'Description *',
            icon: Icons.description,
            value: _formData?.description ?? '',
            maxLines: 4,
            onChanged: (value) {
              _formData?.updatePropertyTypeAndListing(description: value);
              setState(() {});
            },
          ),
          SizedBox(height: 16.h),
          
          // Price
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: _formData?.isRent == true ? 'Rent Price *' : 'Sale Price *',
                  icon: Icons.attach_money,
                  value: _formData?.isRent == true 
                      ? (_formData?.rentPrice?.toString() ?? '')
                      : (_formData?.price?.toString() ?? ''),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final price = double.tryParse(value);
                    if (_formData?.isRent == true) {
                      _formData?.updateTypePricing(rentPrice: price);
                    } else {
                      _formData?.updateTypePricing(price: price);
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Area
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: 'Area *',
                  icon: Icons.straighten,
                  value: _formData?.area?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _formData?.updatePropertyDetails(area: double.tryParse(value));
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDropdown(
                  label: 'Unit *',
                  icon: Icons.grid_view,
                  value: _formData?.areaUnit,
                  items: ['Marla', 'Kanal', 'Sqft', 'Sqyd'],
                  onChanged: (value) {
                    _formData?.updatePropertyDetails(areaUnit: value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.location_on,
            title: 'Location & Features',
            description: 'Update location and select amenities',
          ),
          SizedBox(height: 32.h),
          
          // Building Details
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Building Name',
                  icon: Icons.business,
                  value: _formData?.buildingName ?? '',
                  onChanged: (value) {
                    _formData?.updatePropertyDetails(buildingName: value);
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  label: 'Floor',
                  icon: Icons.layers,
                  value: _formData?.floorNumber ?? '',
                  onChanged: (value) {
                    _formData?.updatePropertyDetails(floorNumber: value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          _buildTextField(
            label: 'Apartment Number',
            icon: Icons.home,
            value: _formData?.apartmentNumber ?? '',
            onChanged: (value) {
              _formData?.updatePropertyDetails(apartmentNumber: value);
              setState(() {});
            },
          ),
          SizedBox(height: 16.h),
          
          // Location
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: 'Phase *',
                  icon: Icons.map,
                  value: _formData?.phase ?? '',
                  onChanged: (value) {
                    _formData?.updateLocationDetails(phase: value);
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  label: 'Sector *',
                  icon: Icons.map,
                  value: _formData?.sector ?? '',
                  onChanged: (value) {
                    _formData?.updateLocationDetails(sector: value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          _buildTextField(
            label: 'Complete Address *',
            icon: Icons.location_on,
            value: _formData?.location ?? '',
            maxLines: 2,
            onChanged: (value) {
              _formData?.updateLocationDetails(location: value);
              setState(() {});
            },
          ),
          SizedBox(height: 24.h),
          
          // Amenities Section
          Text(
            'Amenities',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          if (_amenitiesLoading)
            Center(child: CircularProgressIndicator())
          else if (_amenitiesByCategory.isEmpty)
            Text(
              'No amenities available',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            )
          else
            ..._amenitiesByCategory.entries.map((entry) {
              return _buildAmenityCategory(entry.key, entry.value);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.photo_library,
            title: 'Media & Review',
            description: 'Update images and review your changes',
          ),
          SizedBox(height: 32.h),
          
          // Media Upload Section
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_library, color: AppTheme.primaryBlue, size: 24.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Property Media',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'You can add new images or videos. Existing media will be preserved.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          
          // Summary
          Text(
            'Update Summary',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildStepHeader({required IconData icon, required String title, required String description}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.tealAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.tealAccent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeCard(String purpose, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.tealAccent.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.tealAccent : AppTheme.borderGrey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.tealAccent : AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppTheme.primaryBlue, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              purpose == 'Sell' ? 'Sell Property' : 'Rent Property',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Icon(Icons.check_circle, color: AppTheme.tealAccent, size: 20.sp),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.tealAccent),
            filled: true,
            fillColor: AppTheme.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.tealAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppTheme.inputBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.tealAccent),
              border: InputBorder.none,
            ),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityCategory(String category, List<Map<String, dynamic>> amenities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: amenities.map((amenity) {
            final amenityId = amenity['id'].toString();
            final isSelected = _formData?.amenities.contains(amenityId) ?? false;
            return InkWell(
              onTap: () {
                final formData = _formData;
                if (formData == null) return;
                List<String> current = List.from(formData.amenities);
                if (isSelected) {
                  current.remove(amenityId);
                } else {
                  current.add(amenityId);
                }
                formData.updateAmenities(current);
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.tealAccent : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppTheme.tealAccent : AppTheme.borderGrey,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      amenity['name']?.toString() ?? amenity['amenity_name']?.toString() ?? '',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.tealAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Purpose', _formData?.purpose ?? ''),
          _buildSummaryRow('Title', _formData?.title ?? ''),
          _buildSummaryRow('Category', _formData?.category ?? ''),
          _buildSummaryRow('Price', _formData?.isRent == true 
              ? 'PKR ${_formData?.rentPrice ?? 0}' 
              : 'PKR ${_formData?.price ?? 0}'),
          _buildSummaryRow('Area', '${_formData?.area ?? ''} ${_formData?.areaUnit ?? ''}'),
          _buildSummaryRow('Phase', _formData?.phase ?? ''),
          _buildSummaryRow('Sector', _formData?.sector ?? ''),
          _buildSummaryRow('Amenities', '${_formData?.amenities.length ?? 0} selected'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProperty() async {
    if (_formData == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final propertyData = <String, dynamic>{
        'purpose': _formData!.purpose ?? '',
        'property_type_id': _formData!.propertyTypeId?.toString() ?? '',
        'title': _formData!.title ?? '',
        'description': _formData!.description ?? '',
        'area': _formData!.area?.toString() ?? '',
        'area_unit': _formData!.areaUnit ?? '',
        'category': _formData!.category ?? '',
        'unit_no': _formData!.apartmentNumber ?? '',
        'price': _formData!.isRent ? '0' : (_formData!.price?.toString() ?? '0'),
        'rent_price': _formData!.isRent ? (_formData!.rentPrice?.toString() ?? '0') : '0',
        'latitude': _formData!.latitude?.toString() ?? '',
        'longitude': _formData!.longitude?.toString() ?? '',
        'location': _formData!.location ?? '',
        'sector': _formData!.sector ?? '',
        'phase': _formData!.phase ?? '',
        'street': _formData!.streetNumber ?? '',
        'payment_method': 'KuickPay',
        'property_duration': _mapDurationToApiFormat(_formData!.listingDuration ?? '30 Days'),
      };

      if (_formData!.buildingName != null && _formData!.buildingName!.isNotEmpty) {
        propertyData['building'] = _formData!.buildingName;
      }
      if (_formData!.floorNumber != null && _formData!.floorNumber!.isNotEmpty) {
        propertyData['floor'] = _formData!.floorNumber;
      }

      if (_formData!.onBehalf == 1) {
        propertyData['on_behalf'] = '1';
        if (_formData!.cnic != null) propertyData['cnic'] = _formData!.cnic;
        if (_formData!.name != null) propertyData['name'] = _formData!.name;
        if (_formData!.phone != null) propertyData['phone'] = _formData!.phone;
        if (_formData!.address != null) propertyData['address'] = _formData!.address;
      } else {
        propertyData['on_behalf'] = '0';
      }

      final result = await _updateService.updateProperty(
        propertyId: widget.property.id,
        propertyData: propertyData,
        images: _formData!.images,
        videos: _formData!.videos,
        propertyTypeId: _formData!.propertyTypeId,
        amenities: _formData!.amenities,
      );

      if (mounted) {
        if (result['success'] == true) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update property'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success, size: 28.sp),
            SizedBox(width: 12.w),
            Text(
              'Property Updated',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        content: Text(
          'Your property detail is updated.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Back',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.success,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyListingsScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text(
              'Go to My Listings',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _mapDurationToApiFormat(String duration) {
    switch (duration) {
      case '15 Days':
        return '15 days';
      case '30 Days':
        return '30 days';
      case '60 Days':
        return '60 days';
      default:
        return '30 days';
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _updateProperty();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _formData,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Update Property',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _formData == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Step Indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue.withValues(alpha: 0.1), AppTheme.tealAccent.withValues(alpha: 0.1)],
                      ),
                    ),
                    child: Row(
                      children: [
                        ...List.generate(3, (index) {
                          final stepNum = index + 1;
                          final isActive = _currentStep == stepNum;
                          final isCompleted = _currentStep > stepNum;
                          
                          return Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      color: isCompleted || isActive
                                          ? AppTheme.tealAccent
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                ),
                                if (stepNum < 3)
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted || isActive
                                          ? AppTheme.tealAccent
                                          : Colors.grey[300],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Step $_currentStep of 3',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Steps Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(),
                        _buildStep2(),
                        _buildStep3(),
                      ],
                    ),
                  ),
                  
                  // Navigation Buttons
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_currentStep > 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                side: BorderSide(color: AppTheme.primaryBlue, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        if (_currentStep > 1) SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentStep == 3 ? AppTheme.tealAccent : AppTheme.primaryBlue,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: _isUpdating
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _currentStep == 3 ? 'Update Property' : 'Continue',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
