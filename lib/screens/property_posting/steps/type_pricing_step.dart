import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import 'property_details_step.dart';
import '../../../services/property_type_service.dart';
import '../../../core/theme/app_theme.dart';

class TypePricingStep extends StatefulWidget {
  @override
  _TypePricingStepState createState() => _TypePricingStepState();
}

class _TypePricingStepState extends State<TypePricingStep> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // API service
  final PropertyTypeService _propertyTypeService = PropertyTypeService();
  
  // Property type data
  List<String> _categories = [];
  List<Map<String, dynamic>> _propertyTypes = [];
  List<Map<String, dynamic>> _propertySubtypes = [];
  bool _isLoadingCategories = false;
  bool _isLoadingTypes = false;
  bool _isLoadingSubtypes = false;
  
  // Dropdown values
  String? _selectedCategory;
  int? _selectedPropertyTypeId;
  String? _selectedPropertyTypeName;
  int? _selectedPropertySubtypeId;
  String? _selectedPropertySubtypeName;
  String? _selectedListingDuration;
  
  // Listing duration options
  final List<String> _listingDurations = ['15 Days', '30 Days', '60 Days'];
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formData = context.read<PropertyFormData>();
      
      // Set default purpose if not set
      if (formData.purpose == null) {
        formData.updatePurpose('Sell'); // Default to Sell
      }
      
      // Initialize text controllers with existing values
      if (formData.title != null) {
        _titleController.text = formData.title!;
      }
      if (formData.description != null) {
        _descriptionController.text = formData.description!;
      }
      
      // Initialize dropdown values
      _selectedCategory = formData.category;
      _selectedPropertyTypeId = formData.propertyTypeId;
      _selectedPropertyTypeName = formData.propertyTypeName;
      _selectedPropertySubtypeId = formData.propertySubtypeId;
      _selectedPropertySubtypeName = formData.propertySubtypeName;
      _selectedListingDuration = formData.listingDuration;
      
      // Load categories and property types
      _loadCategories();
      if (_selectedCategory != null) {
        _loadPropertyTypes(_selectedCategory!);
      }
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    
    try {
      final categories = await _propertyTypeService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categories = ['Residential', 'Commercial'];
        _isLoadingCategories = false;
      });
    }
  }

  void _loadPropertyTypes(String category) async {
    setState(() {
      _isLoadingTypes = true;
      _propertyTypes = [];
      _propertySubtypes = []; // Reset subtypes
      _selectedPropertyTypeId = null;
      _selectedPropertyTypeName = null;
      _selectedPropertySubtypeId = null;
      _selectedPropertySubtypeName = null;
    });
    
    try {
      final formData = context.read<PropertyFormData>();
      print('Loading property types for category: $category, purpose: ${formData.purpose}');
      
      final propertyTypes = await _propertyTypeService.getPropertyTypes(
        category: category,
        purpose: formData.purpose,
      );
      
      print('Received property types: $propertyTypes');
      
      setState(() {
        _propertyTypes = propertyTypes;
        _isLoadingTypes = false;
      });
    } catch (e) {
      print('Error in _loadPropertyTypes: $e');
      setState(() {
        _propertyTypes = [];
        _isLoadingTypes = false;
      });
    }
  }
  
  void _loadPropertySubtypes(int parentId) async {
    setState(() {
      _isLoadingSubtypes = true;
      _propertySubtypes = [];
      _selectedPropertySubtypeId = null;
      _selectedPropertySubtypeName = null;
    });
    
    try {
      print('Loading property subtypes for parentId: $parentId');
      
      final subtypes = await _propertyTypeService.getPropertySubtypes(
        parentId: parentId,
      );
      
      print('Received property subtypes: $subtypes');
      
      setState(() {
        _propertySubtypes = subtypes;
        _isLoadingSubtypes = false;
      });
    } catch (e) {
      print('Error in _loadPropertySubtypes: $e');
      setState(() {
        _propertySubtypes = [];
        _isLoadingSubtypes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: AppTheme.lightShadow,
              ),
              child: Icon(
                Icons.home_work_rounded,
                color: AppTheme.primaryBlue,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'PROPERTY TYPE & LISTING',
              style: AppTheme.titleLarge.copyWith(
                fontSize: 18.sp,
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
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.tealAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppTheme.tealAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: AppTheme.cardWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Property Type & Listing',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.tealAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Main Question
                Text(
                  'Select Property Type & Add Details',
                  style: AppTheme.headingMedium,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Choose your property type and provide basic listing information.',
                  style: AppTheme.bodyLarge,
                ),
                
                const SizedBox(height: 40),
                
                // Vertical Layout - One beneath another
                Column(
                    children: [
                    // Property Type Selection Section
                    _buildPropertyTypeSection(formData),
                
                const SizedBox(height: 24),
                
                    // Basic Listing Information Section
                    _buildBasicListingSection(formData),
                  ],
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
          color: AppTheme.cardWhite,
          boxShadow: AppTheme.lightShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: AppTheme.outlineButtonStyle.copyWith(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              child: const Text('Back'),
            ),
            Consumer<PropertyFormData>(
              builder: (context, formData, child) {
                final isValid = formData.isStepValid(4);
                
                // Debug: Print current form data values
                print('Debug - Property Type & Listing Form Data:');
                print('  category: ${formData.category}');
                print('  propertyTypeId: ${formData.propertyTypeId}');
                print('  propertyTypeName: ${formData.propertyTypeName}');
                print('  title: ${formData.title}');
                print('  description: ${formData.description}');
                print('  listingDuration: ${formData.listingDuration}');
                print('  purpose: ${formData.purpose}');
                print('  isRent: ${formData.isRent}');
                if (formData.isRent) {
                  print('  rentPrice: ${formData.rentPrice}');
                } else {
                  print('  price: ${formData.price}');
                }
                print('  isValid: $isValid');
                
                return ElevatedButton(
                  onPressed: isValid ? () => _nextStep(context, formData) : null,
              style: AppTheme.primaryButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(
                  isValid ? AppTheme.primaryBlue : AppTheme.textLight,
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              child: const Text('Continue'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPropertyTypeSection(PropertyFormData formData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Property Type Selection',
                style: AppTheme.titleLarge,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Category Dropdown
          _buildDropdownField(
            label: 'Category *',
            value: _selectedCategory,
            items: _categories,
            isLoading: _isLoadingCategories,
            placeholder: 'Select category',
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
              _loadPropertyTypes(value!);
              formData.updatePropertyTypeAndListing(
                category: value,
                propertyTypeId: null,
                propertyTypeName: null,
                propertySubtypeId: null,
                propertySubtypeName: null,
                title: formData.title,
                description: formData.description,
                listingDuration: formData.listingDuration,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Property Type Dropdown
          _buildDropdownField(
            label: 'Property Type *',
            value: _selectedPropertyTypeName,
            items: _propertyTypes.map((type) => type['name'] as String).toList(),
            isLoading: _isLoadingTypes,
            placeholder: _selectedCategory == null ? 'Select category first' : 'Select type',
            onChanged: (value) {
              final selectedType = _propertyTypes.firstWhere((type) => type['name'] == value);
              setState(() {
                _selectedPropertyTypeId = selectedType['id'] as int;
                _selectedPropertyTypeName = selectedType['name'] as String;
              });
              
              // Load subtypes for this property type
              _loadPropertySubtypes(_selectedPropertyTypeId!);
              
              formData.updatePropertyTypeAndListing(
                category: formData.category,
                propertyTypeId: _selectedPropertyTypeId,
                propertyTypeName: _selectedPropertyTypeName,
                propertySubtypeId: null,
                propertySubtypeName: null,
                title: formData.title,
                description: formData.description,
                listingDuration: formData.listingDuration,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Property Subtype Dropdown (Optional)
          _buildDropdownField(
            label: 'Property Subtype',
            value: _selectedPropertySubtypeName,
            items: _propertySubtypes.map((subtype) => subtype['name'] as String).toList(),
            isLoading: _isLoadingSubtypes,
            placeholder: _selectedPropertyTypeId == null ? 'Select property type first' : 'No subtypes available',
            onChanged: (value) {
              final selectedSubtype = _propertySubtypes.firstWhere((subtype) => subtype['name'] == value);
              setState(() {
                _selectedPropertySubtypeId = selectedSubtype['id'] as int;
                _selectedPropertySubtypeName = selectedSubtype['name'] as String;
              });
              
              formData.updatePropertyTypeAndListing(
                category: formData.category,
                propertyTypeId: formData.propertyTypeId,
                propertyTypeName: formData.propertyTypeName,
                propertySubtypeId: _selectedPropertySubtypeId,
                propertySubtypeName: _selectedPropertySubtypeName,
                title: formData.title,
                description: formData.description,
                listingDuration: formData.listingDuration,
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildBasicListingSection(PropertyFormData formData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Basic Listing Information',
                style: AppTheme.titleLarge,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Property Title Field
          _buildTextField(
            controller: _titleController,
            label: 'Property Title *',
            hint: 'E.G., Beautiful 5 Marla House In Phase 2',
            icon: Icons.title,
            onChanged: (value) {
              formData.updatePropertyTypeAndListing(
                category: formData.category,
                propertyTypeId: formData.propertyTypeId,
                propertyTypeName: formData.propertyTypeName,
                propertySubtypeId: formData.propertySubtypeId,
                propertySubtypeName: formData.propertySubtypeName,
                title: value,
                description: formData.description,
                listingDuration: formData.listingDuration,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Listing Duration Dropdown
          _buildDropdownField(
            label: 'Listing Duration *',
            value: _selectedListingDuration,
            items: _listingDurations,
            onChanged: (value) {
              setState(() {
                _selectedListingDuration = value;
              });
              formData.updatePropertyTypeAndListing(
                category: formData.category,
                propertyTypeId: formData.propertyTypeId,
                propertyTypeName: formData.propertyTypeName,
                propertySubtypeId: formData.propertySubtypeId,
                propertySubtypeName: formData.propertySubtypeName,
                title: formData.title,
                description: formData.description,
                listingDuration: value,
              );
              // Also update propertyDuration for API compatibility
              formData.updateTypePricing(
                propertyDuration: value,
                propertyTypeId: formData.propertyTypeId,
                category: formData.category,
                price: formData.price,
                rentPrice: formData.rentPrice,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Listing Duration Dropdown
          _buildDropdownField(
            label: 'Listing Duration *',
            value: _selectedListingDuration,
            items: _listingDurations,
            onChanged: (value) {
              setState(() {
                _selectedListingDuration = value;
              });
              formData.updatePropertyTypeAndListing(
                category: formData.category,
                propertyTypeId: formData.propertyTypeId,
                propertyTypeName: formData.propertyTypeName,
                propertySubtypeId: formData.propertySubtypeId,
                propertySubtypeName: formData.propertySubtypeName,
                title: formData.title,
                description: formData.description,
                listingDuration: value,
              );
              // Also update propertyDuration for API compatibility
              formData.updateTypePricing(
                propertyDuration: value,
                propertyTypeId: formData.propertyTypeId,
                category: formData.category,
                price: formData.price,
                rentPrice: formData.rentPrice,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Dynamic Pricing based on Purpose Selection (Step 2)
          _buildTextField(
            controller: TextEditingController(
              text: formData.isRent 
                ? (formData.rentPrice?.toString() ?? '')
                : (formData.price?.toString() ?? '')
            ),
            label: formData.isRent ? 'Rent Price (PKR) *' : 'Selling Price (PKR) *',
            hint: formData.isRent ? 'Enter monthly rent amount' : 'Enter property selling price',
            icon: Icons.attach_money,
            onChanged: (value) {
              if (formData.isRent) {
                // For rent: update rentPrice field
                formData.updateTypePricing(
                  propertyTypeId: formData.propertyTypeId,
                  category: formData.category,
                  rentPrice: double.tryParse(value),
                  propertyDuration: formData.propertyDuration,
                );
              } else {
                // For sell: update price field
                formData.updateTypePricing(
                  propertyTypeId: formData.propertyTypeId,
                  category: formData.category,
                  price: double.tryParse(value),
                  propertyDuration: formData.propertyDuration,
                );
              }
            },
          ),

          // Description Field
          _buildTextField(
            controller: _descriptionController,
            label: 'Description *',
            hint: 'Describe your property in detail...',
            icon: Icons.description,
            maxLines: 4,
            onChanged: (value) {
              formData.updatePropertyTypeAndListing(
                category: formData.category,
                propertyTypeId: formData.propertyTypeId,
                propertyTypeName: formData.propertyTypeName,
                propertySubtypeId: formData.propertySubtypeId,
                propertySubtypeName: formData.propertySubtypeName,
                title: formData.title,
                description: value,
                listingDuration: formData.listingDuration,
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? placeholder,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(12),
                border: Border.all(
              color: AppTheme.textLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: placeholder ?? 'Select option',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required void Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.titleMedium.copyWith(
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.borderGrey,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textLight,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void _nextStep(BuildContext context, PropertyFormData formData) {
    // Navigate to the next step (Property Details)
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider.value(
          value: formData,
          child: PropertyDetailsStep(),
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
}