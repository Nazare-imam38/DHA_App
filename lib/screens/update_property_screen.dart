import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  
  // Media selection state
  List<File> _selectedImages = [];
  List<File> _selectedVideos = [];
  final int _maxImageSize = 3 * 1024 * 1024; // 3MB
  final int _maxVideoSize = 50 * 1024 * 1024; // 50MB
  
  // Expandable card state
  bool _isContactInfoExpanded = false;

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
    
    // Owner details - initialize with existing contact information if available
    _formData!.updateOwnership(0);
    _formData!.updateOwnerDetails(
      name: property.userName,
      phone: property.userPhone,
      // CNIC and address may not be available in property object, will be empty
      cnic: null,
      address: null,
    );
    
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
                flex: 2,
                child: _buildDropdown(
                  label: 'Unit *',
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
            value: _formData?.location ?? '',
            maxLines: 2,
            onChanged: (value) {
              _formData?.updateLocationDetails(location: value);
              setState(() {});
            },
          ),
          SizedBox(height: 32.h),
          
          // Contact Information Section (Expandable Card)
          _buildExpandableCard(
            title: 'Contact Information',
            icon: Icons.contact_phone,
            description: 'Update owner/contact details for this property',
            isExpanded: _isContactInfoExpanded,
            onToggle: () => setState(() => _isContactInfoExpanded = !_isContactInfoExpanded),
            child: Column(
              children: [
                // CNIC Field
                _buildTextField(
                  label: 'CNIC',
                  value: _formData?.cnic ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _formData?.updateOwnerDetails(cnic: value);
                    setState(() {});
                  },
                ),
                SizedBox(height: 16.h),
                
                // Name Field
                _buildTextField(
                  label: 'Full Name',
                  value: _formData?.name ?? widget.property.userName ?? '',
                  onChanged: (value) {
                    _formData?.updateOwnerDetails(name: value);
                    setState(() {});
                  },
                ),
                SizedBox(height: 16.h),
                
                // Phone Field
                _buildTextField(
                  label: 'Phone Number',
                  value: _formData?.phone ?? widget.property.userPhone ?? '',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    _formData?.updateOwnerDetails(phone: value);
                    setState(() {});
                  },
                ),
                SizedBox(height: 16.h),
                
                // Address Field
                _buildTextField(
                  label: 'Address',
                  value: _formData?.address ?? '',
                  maxLines: 3,
                  onChanged: (value) {
                    _formData?.updateOwnerDetails(address: value);
                    setState(() {});
                  },
                ),
              ],
            ),
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
                SizedBox(height: 16.h),
                // Media selection buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: Icon(Icons.image, size: 18.sp),
                        label: Text('Add Images'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickVideos,
                        icon: Icon(Icons.video_library, size: 18.sp),
                        label: Text('Add Videos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tealAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          
          // Existing Media Display
          if (widget.property.images.isNotEmpty) ...[
            Text(
              'Existing Images',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.property.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: widget.property.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.lightBlue,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.lightBlue,
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
          ],
          
          // Selected New Images
          if (_selectedImages.isNotEmpty) ...[
            Text(
              'Selected Images (${_selectedImages.length})',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 1,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 16.sp),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 24.h),
          ],
          
          // Selected New Videos
          if (_selectedVideos.isNotEmpty) ...[
            Text(
              'Selected Videos (${_selectedVideos.length})',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 12.h),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _selectedVideos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppTheme.borderGrey),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.video_library, color: AppTheme.primaryBlue, size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _selectedVideos[index].path.split('/').last,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVideos.removeAt(index);
                          });
                        },
                        child: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
          ],
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
      child: AspectRatio(
        aspectRatio: 1.0, // Maintain square shape
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                textAlign: TextAlign.center,
              ),
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Icon(Icons.check_circle, color: AppTheme.tealAccent, size: 20.sp),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build expandable card
  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    String? description,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.borderGrey,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: AppTheme.primaryBlue, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        if (description != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            description,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: AppTheme.borderGrey),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
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
          if (_formData?.cnic != null && _formData!.cnic!.isNotEmpty)
            _buildSummaryRow('CNIC', _formData!.cnic!),
          if (_formData?.name != null && _formData!.name!.isNotEmpty)
            _buildSummaryRow('Name', _formData!.name!),
          if (_formData?.phone != null && _formData!.phone!.isNotEmpty)
            _buildSummaryRow('Phone', _formData!.phone!),
          if (_formData?.address != null && _formData!.address!.isNotEmpty)
            _buildSummaryRow('Address', _formData!.address!),
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

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null) {
        List<File> newImages = [];
        
        for (var file in result.files) {
          if (file.size <= _maxImageSize) {
            try {
              File tempFile;
              
              if (file.bytes != null) {
                final tempDir = await getTemporaryDirectory();
                tempFile = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.${file.extension}');
                await tempFile.writeAsBytes(file.bytes!);
              } else if (file.path != null) {
                tempFile = File(file.path!);
              } else {
                continue;
              }
              
              newImages.add(tempFile);
            } catch (e) {
              print('Error processing image ${file.name}: $e');
              continue;
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image ${file.name} is too large (max 3MB). Skipping...'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        if (_selectedImages.length + newImages.length > 20) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 20 photos allowed. Please remove some existing photos first.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null) {
        List<File> newVideos = [];
        
        for (var file in result.files) {
          if (file.size <= _maxVideoSize) {
            try {
              File tempFile;
              
              if (file.bytes != null) {
                final tempDir = await getTemporaryDirectory();
                tempFile = File('${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.${file.extension}');
                await tempFile.writeAsBytes(file.bytes!);
              } else if (file.path != null) {
                tempFile = File(file.path!);
              } else {
                continue;
              }
              
              newVideos.add(tempFile);
            } catch (e) {
              print('Error processing video ${file.name}: $e');
              continue;
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Video ${file.name} is too large (max 50MB). Skipping...'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        if (_selectedVideos.length + newVideos.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 5 videos allowed. Please remove some existing videos first.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _selectedVideos.addAll(newVideos);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting videos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

      // Handle ownership and contact information
      if (_formData!.onBehalf == 1) {
        propertyData['on_behalf'] = '1';
      } else {
        propertyData['on_behalf'] = '0';
      }
      
      // Always include contact information if provided (regardless of on_behalf)
      if (_formData!.cnic != null && _formData!.cnic!.isNotEmpty) {
        propertyData['cnic'] = _formData!.cnic;
      }
      if (_formData!.name != null && _formData!.name!.isNotEmpty) {
        propertyData['name'] = _formData!.name;
      }
      if (_formData!.phone != null && _formData!.phone!.isNotEmpty) {
        propertyData['phone'] = _formData!.phone;
      }
      if (_formData!.address != null && _formData!.address!.isNotEmpty) {
        propertyData['address'] = _formData!.address;
      }

      final result = await _updateService.updateProperty(
        propertyId: widget.property.id,
        propertyData: propertyData,
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
        videos: _selectedVideos.isNotEmpty ? _selectedVideos : null,
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
