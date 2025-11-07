import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/property_form_data.dart';
import '../../../ui/widgets/app_icons.dart';
import 'amenities_selection_step.dart';
import '../../../core/services/dha_geojson_boundary_service.dart' as dha;

class PropertyDetailsStep extends StatefulWidget {
  @override
  _PropertyDetailsStepState createState() => _PropertyDetailsStepState();
}

class _PropertyDetailsStepState extends State<PropertyDetailsStep> 
    with SingleTickerProviderStateMixin {
  final _buildingNameController = TextEditingController(); // Also used for plot number
  final _floorNumberController = TextEditingController();
  final _apartmentNumberController = TextEditingController();
  final _areaController = TextEditingController();
  final _sectorController = TextEditingController();
  final _streetNumberController = TextEditingController();
  final _completeAddressController = TextEditingController();
  
  String? _selectedAreaUnit;
  String? _selectedPhase;
  bool _isMapSatellite = false; // Default to street view
  
  // Tab controller
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Map related variables
  MapController _mapController = MapController();
  List<dha.BoundaryPolygon> _boundaryPolygons = [];
  bool _isLoadingBoundaries = false;
  LatLng? _selectedLatLng;
  
  // Phase options
  final List<String> _phases = [
    'Phase 1',
    'Phase 2', 
    'Phase 3',
    'Phase 4',
    'Phase 5',
    'Phase 6',
    'Phase 7',
  ];
  
  // Area unit options
  final List<String> _areaUnits = [
    'Marla',
    'Kanal',
    'Sqft',
    'Sqyd',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadPhaseBoundaries();
    _initializeFormData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buildingNameController.dispose();
    _floorNumberController.dispose();
    _apartmentNumberController.dispose();
    _areaController.dispose();
    _sectorController.dispose();
    _streetNumberController.dispose();
    _completeAddressController.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    final formData = context.read<PropertyFormData>();
    
    // Initialize controllers with existing data
    _buildingNameController.text = formData.buildingName ?? '';
    _floorNumberController.text = formData.floorNumber ?? '';
    _apartmentNumberController.text = formData.apartmentNumber ?? '';
    _areaController.text = formData.area?.toString() ?? '';
    _sectorController.text = formData.sector ?? '';
    _streetNumberController.text = formData.streetNumber ?? '';
    _completeAddressController.text = formData.location ?? '';
    _selectedAreaUnit = formData.areaUnit;
    _selectedPhase = formData.phase;
    if (formData.latitude != null && formData.longitude != null) {
      _selectedLatLng = LatLng(formData.latitude!, formData.longitude!);
    }
  }

  void _loadPhaseBoundaries() async {
    setState(() {
      _isLoadingBoundaries = true;
    });
    
    try {
      print('🔄 Loading DHA phase boundaries...');
      final boundaries = await dha.DhaGeoJSONBoundaryService.loadDhaBoundaries();
      
      setState(() {
        _boundaryPolygons = boundaries;
        _isLoadingBoundaries = false;
      });
      
      print('✅ Loaded ${boundaries.length} phase boundaries');
    } catch (e) {
      print('❌ Error loading phase boundaries: $e');
      setState(() {
        _isLoadingBoundaries = false;
      });
    }
  }

  void _onPhaseSelected(String? phase) {
    if (phase == null) return;
    setState(() {
      _selectedPhase = phase;
    });
    
    // Update form data
    final formData = context.read<PropertyFormData>();
    formData.updateLocationDetails(
      location: formData.location,
      sector: formData.sector,
      phase: phase,
      latitude: formData.latitude,
      longitude: formData.longitude,
      block: formData.block,
      streetNo: formData.streetNo,
      floor: formData.floor,
      building: formData.building,
    );
    formData.updatePropertyDetails(
      buildingName: formData.buildingName,
      floorNumber: formData.floorNumber,
      apartmentNumber: formData.apartmentNumber,
      area: formData.area,
      areaUnit: formData.areaUnit,
      streetNumber: formData.streetNumber,
    );
    
    print('Phase updated: $phase');
    
    // Animate map to selected phase
    _animateToPhase(phase);
  }

  void _animateToPhase(String phase) {
    if (_boundaryPolygons.isEmpty) return;
    
    // Find the boundary for the selected phase
    final boundary = _boundaryPolygons.firstWhere(
      (b) => b.phaseName.toLowerCase().contains(phase.toLowerCase()),
      orElse: () => _boundaryPolygons.first,
    );
    
    if (boundary.polygons.isNotEmpty) {
      // Calculate bounds for the phase
      final bounds = _calculateBounds(boundary.polygons);
      
      // Animate to the phase boundary
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
      
      print('📍 Animated to $phase boundary');
    }
  }

  LatLngBounds _calculateBounds(List<List<LatLng>> polygons) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    for (final polygon in polygons) {
      for (final point in polygon) {
        minLat = minLat < point.latitude ? minLat : point.latitude;
        maxLat = maxLat > point.latitude ? maxLat : point.latitude;
        minLng = minLng < point.longitude ? minLng : point.longitude;
        maxLng = maxLng > point.longitude ? maxLng : point.longitude;
      }
    }
    
    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
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
            AppIcons.arrowBackIosNew,
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
                AppIcons.homeWorkRounded,
                color: const Color(0xFF1B5993),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'PROPERTY DETAILS',
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
                          '4',
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
                      'Property Details',
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
          
          // Main Content - Tab System
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Custom Tab Bar
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCustomTab(
                            'Details',
                            AppIcons.descriptionRounded,
                            0,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildCustomTab(
                            'Map',
                            AppIcons.locationOnRounded,
                            1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDetailsTab(),
                        _buildMapTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            Consumer<PropertyFormData>(
              builder: (context, formData, child) {
                final isValid = formData.isStepValid(5);
                
                // Debug: Print current form data values
                print('Debug - Property Details Form Data:');
                print('  buildingName: ${formData.buildingName}');
                print('  floorNumber: ${formData.floorNumber}');
                print('  apartmentNumber: ${formData.apartmentNumber}');
                print('  area: ${formData.area}');
                print('  areaUnit: ${formData.areaUnit}');
                print('  phase: ${formData.phase}');
                print('  sector: ${formData.sector}');
                print('  streetNumber: ${formData.streetNumber}');
                print('  isValid: $isValid');
                
                return ElevatedButton(
                  onPressed: isValid ? () => _nextStep(context, formData) : null,
              style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? const Color(0xFF1B5993) : Colors.grey,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
                  child: const Text('Continue to Amenities'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Custom Tab Widget
  Widget _buildCustomTab(String title, IconData icon, int index) {
    final isSelected = _currentTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5993) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF1B5993).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.w,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Details Tab Content
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Property Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B5993),
              height: 1.2,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            'Enter your property details and location information.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Form Fields
          _buildFormFields(),
          
          SizedBox(height: 24.h),
          
          // Next Step Instruction - Simplified
          GestureDetector(
            onTap: () {
              _tabController.animateTo(1);
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF1B5993).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: const Color(0xFF1B5993),
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Mark Property Location on Map',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B5993),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    AppIcons.arrowForwardRounded,
                    color: const Color(0xFF1B5993),
                    size: 18.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Map Tab Content
  Widget _buildMapTab() {
    return Column(
      children: [
        // Map Header - Only Toggle Button
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enhanced Map Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildEnhancedMapToggleButton('Street', !_isMapSatellite),
                    _buildEnhancedMapToggleButton('Satellite', _isMapSatellite),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Location Status Bar
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _selectedLatLng != null 
              ? Container(
                  key: const ValueKey('selected'),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.08),
                        const Color(0xFF059669).withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          AppIcons.checkRounded,
                          color: Colors.white,
                          size: 16.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location Selected',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              '${_selectedLatLng!.latitude.toStringAsFixed(6)}, ${_selectedLatLng!.longitude.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLatLng = null;
                          });
                          final formData = context.read<PropertyFormData>();
                          formData.updateLocationDetails(
                            location: formData.location,
                            sector: formData.sector,
                            phase: formData.phase,
                            latitude: null,
                            longitude: null,
                            block: formData.block,
                            streetNo: formData.streetNo,
                            floor: formData.floor,
                            building: formData.building,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            AppIcons.closeRounded,
                            color: const Color(0xFF6B7280),
                            size: 16.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  key: const ValueKey('unselected'),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.08),
                        const Color(0xFF1D4ED8).withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          AppIcons.touchAppRounded,
                          color: const Color(0xFF3B82F6),
                          size: 16.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Tap on map to mark location',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      Icon(
                        AppIcons.arrowDownwardRounded,
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
                        size: 18.w,
                      ),
                    ],
                  ),
                ),
        ),
        
        // Map Container
        Expanded(
          child: _buildEnhancedMap(),
        ),
      ],
    );
  }
  
  Widget _buildFormFields() {
    final formData = context.read<PropertyFormData>();
    // Show plot-style fields for ALL commercial properties OR residential plots
    final isCommercial = formData.category?.toLowerCase() == 'commercial';
    final isResidentialPlot = formData.category?.toLowerCase() == 'residential' && 
                              formData.propertyTypeName?.toLowerCase() == 'plot';
    final showPlotFields = isCommercial || isResidentialPlot;
    
    return Column(
      children: [
        // Conditional fields based on property type
        if (showPlotFields) ...[
          // Plot/Unit Number (for commercial properties and residential plots)
          _buildTextField(
            controller: _buildingNameController, // Reuse controller but change label
            label: isCommercial ? 'Unit/Plot Number *' : 'Plot Number *',
            hint: isCommercial ? 'E.G., Unit 123, Plot A-5' : 'E.G., 123',
            onChanged: (value) {
              formData.updatePropertyDetails(
                buildingName: value, // Store as buildingName in backend
                floorNumber: formData.floorNumber,
                apartmentNumber: formData.apartmentNumber,
                area: formData.area,
                areaUnit: formData.areaUnit,
                streetNumber: formData.streetNumber,
              );
              print('Plot/Unit Number updated: $value');
            },
          ),
        ] else ...[
          // Building Name (for apartments, houses, etc.)
          _buildTextField(
            controller: _buildingNameController,
            label: 'Building Name *',
            hint: 'E.G., Tower A, Building 5',
            onChanged: (value) {
              formData.updatePropertyDetails(
                buildingName: value,
                floorNumber: formData.floorNumber,
                apartmentNumber: formData.apartmentNumber,
                area: formData.area,
                areaUnit: formData.areaUnit,
                streetNumber: formData.streetNumber,
              );
              print('Building Name updated: $value');
            },
          ),
          
          SizedBox(height: 20.h),
          
          // Floor (not for plots)
          _buildTextField(
            controller: _floorNumberController,
            label: 'Floor *',
            hint: 'E.G., 3rd Floor, Ground Floor',
            onChanged: (value) {
              formData.updatePropertyDetails(
                buildingName: formData.buildingName,
                floorNumber: value,
                apartmentNumber: formData.apartmentNumber,
                area: formData.area,
                areaUnit: formData.areaUnit,
                streetNumber: formData.streetNumber,
              );
              print('Floor updated: $value');
            },
          ),
          
          SizedBox(height: 20.h),
          
          // Apartment Number (not for plots)
          _buildTextField(
            controller: _apartmentNumberController,
            label: 'Apartment Number *',
            hint: 'E.G., A-301',
            onChanged: (value) {
              formData.updatePropertyDetails(
                buildingName: formData.buildingName,
                floorNumber: formData.floorNumber,
                apartmentNumber: value,
                area: formData.area,
                areaUnit: formData.areaUnit,
                streetNumber: formData.streetNumber,
              );
              print('Apartment Number updated: $value');
            },
          ),
        ],
        
        SizedBox(height: 20.h),
        
        // Area and Area Unit Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _areaController,
                label: 'Area *',
                hint: 'E.G., 5',
                onChanged: (value) {
                  final formData = context.read<PropertyFormData>();
                  formData.updatePropertyDetails(
                    buildingName: formData.buildingName,
                    floorNumber: formData.floorNumber,
                    apartmentNumber: formData.apartmentNumber,
                    area: double.tryParse(value),
                    areaUnit: formData.areaUnit,
                    streetNumber: formData.streetNumber,
                  );
                  print('Area updated: $value');
                },
              ),
            ),
            
            SizedBox(width: 16.w),
            
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                label: 'Area Unit *',
                value: _selectedAreaUnit,
                items: _areaUnits,
                onChanged: (value) {
                  setState(() {
                    _selectedAreaUnit = value;
                  });
                  final formData = context.read<PropertyFormData>();
                  formData.updatePropertyDetails(
                    buildingName: formData.buildingName,
                    floorNumber: formData.floorNumber,
                    apartmentNumber: formData.apartmentNumber,
                    area: formData.area,
                    areaUnit: value,
                    streetNumber: formData.streetNumber,
                  );
                  print('Area Unit updated: $value');
                },
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20.h),
        
        // Phase Dropdown
        _buildDropdownField(
          label: 'Phase *',
          value: _selectedPhase,
          items: _phases,
          onChanged: _onPhaseSelected,
        ),
        
        SizedBox(height: 8.h),
        
        // Phase hint text
        if (_selectedPhase != null)
          Text(
            'Map will navigate to $_selectedPhase when selected.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              color: const Color(0xFF20B2AA),
              fontStyle: FontStyle.italic,
            ),
          ),
        
        SizedBox(height: 20.h),
        
        // Sector/Block/Zone
        _buildTextField(
          controller: _sectorController,
          label: 'Sector/Block/Zone *',
          hint: 'E.G., Sector A, Block 12',
          onChanged: (value) {
            final formData = context.read<PropertyFormData>();
            // Update both location details and property details
            formData.updateLocationDetails(
              location: formData.location,
              sector: value,
              phase: formData.phase,
              latitude: formData.latitude,
              longitude: formData.longitude,
              block: formData.block,
              streetNo: formData.streetNo,
              floor: formData.floor,
              building: formData.building,
            );
            formData.updatePropertyDetails(
              buildingName: formData.buildingName,
              floorNumber: formData.floorNumber,
              apartmentNumber: formData.apartmentNumber,
              area: formData.area,
              areaUnit: formData.areaUnit,
              streetNumber: formData.streetNumber,
            );
            print('Sector updated: $value');
          },
        ),
        
        SizedBox(height: 20.h),
        
        // Street Number
        _buildTextField(
          controller: _streetNumberController,
          label: 'Street Number *',
          hint: 'E.G., Street 1',
          onChanged: (value) {
            final formData = context.read<PropertyFormData>();
            // Update both location details and property details
            formData.updateLocationDetails(
              location: formData.location,
              sector: formData.sector,
              phase: formData.phase,
              latitude: formData.latitude,
              longitude: formData.longitude,
              block: formData.block,
              streetNo: value,
              floor: formData.floor,
              building: formData.building,
            );
            formData.updatePropertyDetails(
              buildingName: formData.buildingName,
              floorNumber: formData.floorNumber,
              apartmentNumber: formData.apartmentNumber,
              area: formData.area,
              areaUnit: formData.areaUnit,
              streetNumber: value,
            );
            print('Street Number updated: $value');
          },
        ),
        
        SizedBox(height: 20.h),
        
        // Complete Address (especially useful for plots)
        _buildTextField(
          controller: _completeAddressController,
          label: 'Complete Address *',
          hint: 'Enter complete property address',
          maxLines: 3,
          onChanged: (value) {
            final formData = context.read<PropertyFormData>();
            formData.updateLocationDetails(
              location: value,
              sector: formData.sector,
              phase: formData.phase,
              latitude: formData.latitude,
              longitude: formData.longitude,
              block: formData.block,
              streetNo: formData.streetNo,
              floor: formData.floor,
              building: formData.building,
            );
            print('Complete Address updated: $value');
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedMap() {
    return _isLoadingBoundaries
        ? Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: CircularProgressIndicator(
                      color: const Color(0xFF1B5993),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading map boundaries...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(33.6844, 73.0479),
                  initialZoom: 12.0,
                  minZoom: 8.0,
                  maxZoom: 18.0,
                  onTap: (tapPosition, latLng) {
                    setState(() {
                      _selectedLatLng = latLng;
                    });
                    final formData = context.read<PropertyFormData>();
                    formData.updateLocationDetails(
                      location: '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}',
                      sector: formData.sector,
                      phase: formData.phase,
                      latitude: latLng.latitude,
                      longitude: latLng.longitude,
                      block: formData.block,
                      streetNo: formData.streetNo,
                      floor: formData.floor,
                      building: formData.building,
                    );
                    print('📍 Map tapped: ${latLng.latitude}, ${latLng.longitude}');
                  },
                ),
                children: [
                  // Tile Layer
                  TileLayer(
                    urlTemplate: _isMapSatellite
                        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.dhamarketplace.app',
                  ),
                  
                  // Phase Boundaries
                  PolygonLayer(
                    polygons: _buildPhasePolygons(),
                  ),
                  
                  // Selected location marker with enhanced design
                  if (_selectedLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLatLng!,
                          width: 50,
                          height: 50,
                          alignment: Alignment.topCenter,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing circle animation
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B5993).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B5993),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1B5993).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  AppIcons.locationOnRounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              // Map Controls Overlay
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    // Zoom In Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            child: Icon(
                              AppIcons.addRounded,
                              color: const Color(0xFF1B5993),
                              size: 20.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Zoom Out Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            child: Icon(
                              AppIcons.removeRounded,
                              color: const Color(0xFF1B5993),
                              size: 20.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Attribution
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    _isMapSatellite ? '© Esri' : '© OpenStreetMap',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildEnhancedMapToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMapSatellite = label == 'Satellite';
        });
        print('Map type changed to: ${_isMapSatellite ? "Satellite" : "Street"}');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF1B5993)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF1B5993).withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'Satellite' ? AppIcons.satelliteAltRounded : AppIcons.mapRounded,
              size: 14.w,
              color: isSelected 
                  ? Colors.white
                  : const Color(0xFF6B7280),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white
                    : const Color(0xFF6B7280),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Polygon> _buildPhasePolygons() {
    return _boundaryPolygons.map<Polygon>((boundary) {
      return Polygon(
        points: boundary.polygons.isNotEmpty ? boundary.polygons.first : [],
        color: boundary.color.withValues(alpha: 0.3),
        borderColor: boundary.color,
        borderStrokeWidth: 2.0,
      );
    }).toList();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required void Function(String) onChanged,
    int maxLines = 1,
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
            onChanged: onChanged,
            maxLines: maxLines,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
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
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
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
          child: DropdownButtonFormField<String>(
            value: value,
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
            decoration: InputDecoration(
              hintText: label.contains('Phase') ? 'Select phase' : label.contains('Area Unit') ? 'Select unit' : 'Select $label',
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
            ),
            icon: const Icon(
              AppIcons.keyboardArrowDown,
              color: Color(0xFF1B5993),
            ),
          ),
        ),
      ],
    );
  }

  void _nextStep(BuildContext context, PropertyFormData formData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: formData,
          child: AmenitiesSelectionStep(),
        ),
      ),
    );
  }
}