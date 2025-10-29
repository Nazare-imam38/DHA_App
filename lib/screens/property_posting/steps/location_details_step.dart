import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import 'unit_details_step.dart';

class LocationDetailsStep extends StatefulWidget {
  @override
  _LocationDetailsStepState createState() => _LocationDetailsStepState();
}

class _LocationDetailsStepState extends State<LocationDetailsStep> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _sectorController = TextEditingController();
  final _phaseController = TextEditingController();
  final _blockController = TextEditingController();
  final _streetController = TextEditingController();
  final _floorController = TextEditingController();
  final _buildingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _sectorController.dispose();
    _phaseController.dispose();
    _blockController.dispose();
    _streetController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    super.dispose();
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
                Icons.location_on_rounded,
                color: const Color(0xFF1B5993),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'LOCATION DETAILS',
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
            return Form(
              key: _formKey,
              child: Column(
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
                            'Location Details',
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
                    'Property Location',
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
                      'Provide accurate location details for your property.',
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
                  
                  // Coordinates Section
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
                        const Text(
                          'Coordinates *',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B5993),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernFormField(
                                controller: _latitudeController,
                                label: 'Latitude',
                                hint: 'e.g., 33.6844',
                                icon: Icons.my_location,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Latitude is required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid latitude';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  formData.updateLocationDetails(latitude: double.tryParse(value));
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernFormField(
                                controller: _longitudeController,
                                label: 'Longitude',
                                hint: 'e.g., 73.0479',
                                icon: Icons.my_location,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Longitude is required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid longitude';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  formData.updateLocationDetails(longitude: double.tryParse(value));
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Address Details Section
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
                        const Text(
                          'Address Details *',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B5993),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernFormField(
                                controller: _sectorController,
                                label: 'Sector',
                                hint: 'e.g., Sector A',
                                icon: Icons.location_city,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Sector is required';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  formData.updateLocationDetails(sector: value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernFormField(
                                controller: _phaseController,
                                label: 'Phase',
                                hint: 'e.g., Phase 1',
                                icon: Icons.location_city,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Phase is required';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  formData.updateLocationDetails(phase: value);
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernFormField(
                                controller: _blockController,
                                label: 'Block',
                                hint: 'e.g., Block 5',
                                icon: Icons.home,
                                onChanged: (value) {
                                  formData.updateLocationDetails(block: value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernFormField(
                                controller: _streetController,
                                label: 'Street Number',
                                hint: 'e.g., Street 12',
                                icon: Icons.route,
                                onChanged: (value) {
                                  formData.updateLocationDetails(streetNo: value);
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernFormField(
                                controller: _floorController,
                                label: 'Floor',
                                hint: 'e.g., Ground Floor',
                                icon: Icons.layers,
                                onChanged: (value) {
                                  formData.updateLocationDetails(floor: value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernFormField(
                                controller: _buildingController,
                                label: 'Building',
                                hint: 'e.g., Building A',
                                icon: Icons.business,
                                onChanged: (value) {
                                  formData.updateLocationDetails(building: value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Help Section
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
                          'Location Tips',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B5993),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Use GPS or Google Maps to get accurate coordinates\n'
                          '• Provide complete address for better visibility\n'
                          '• Include nearby landmarks for reference\n'
                          '• Verify all location details before submitting',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF1B5993),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                if (formData.location != null && formData.streetNo != null) {
                  _nextStep(context, formData);
                }
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
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _nextStep(BuildContext context, PropertyFormData formData) {
    // Navigate to the next step (Unit Details)
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider.value(
          value: formData,
          child: UnitDetailsStep(),
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
  
  Widget _buildModernFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
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
            color: Color(0xFF1B5993),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF1B5993),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}