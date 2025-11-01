import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/property_form_data.dart';
import 'amenities_selection_step.dart';
import '../../../core/services/dha_geojson_boundary_service.dart' as dha;

class PropertyDetailsStep extends StatefulWidget {
  @override
  _PropertyDetailsStepState createState() => _PropertyDetailsStepState();
}

class _PropertyDetailsStepState extends State<PropertyDetailsStep> {
  final _buildingNameController = TextEditingController();
  final _floorNumberController = TextEditingController();
  final _apartmentNumberController = TextEditingController();
  final _areaController = TextEditingController();
  final _sectorController = TextEditingController();
  final _streetNumberController = TextEditingController();
  
  String? _selectedAreaUnit;
  String? _selectedPhase;
  bool _isMapSatellite = true;
  
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
    _loadPhaseBoundaries();
    _initializeFormData();
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
  void dispose() {
    _buildingNameController.dispose();
    _floorNumberController.dispose();
    _apartmentNumberController.dispose();
    _areaController.dispose();
    _sectorController.dispose();
    _streetNumberController.dispose();
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
                Icons.home_work_rounded,
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
                  
          // Main Content - Vertical Layout
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Form Section
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
                        // Header
                        const Text(
                          'Property Details',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B5993),
                            height: 1.2,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        const Text(
                          'Enter your property details and location information.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF616161),
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Form Fields
                        _buildFormFields(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Map Section
                  Container(
                    width: double.infinity,
                    height: 400.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: _buildMapSection(),
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
  
  Widget _buildFormFields() {
    return Column(
      children: [
        // Building Name
        _buildTextField(
          controller: _buildingNameController,
          label: 'Building Name *',
          hint: 'E.G., Tower A, Building 5',
          icon: Icons.business,
          onChanged: (value) {
            final formData = context.read<PropertyFormData>();
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
        
        const SizedBox(height: 16),
        
        // Floor
        _buildTextField(
          controller: _floorNumberController,
          label: 'Floor *',
          hint: 'E.G., 3rd Floor, Ground Floor',
          icon: Icons.layers,
          onChanged: (value) {
            final formData = context.read<PropertyFormData>();
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
        
        const SizedBox(height: 16),
        
        // Apartment Number
        _buildTextField(
          controller: _apartmentNumberController,
          label: 'Apartment Number *',
          hint: 'E.G., A-301',
          icon: Icons.home,
          onChanged: (value) {
            final formData = context.read<PropertyFormData>();
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
        
        const SizedBox(height: 16),
        
        // Area and Area Unit Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _areaController,
                label: 'Area *',
                hint: 'E.G., 5',
                icon: Icons.straighten,
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
            
            const SizedBox(width: 16),
            
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
        
        const SizedBox(height: 16),
        
        // Phase Dropdown
        _buildDropdownField(
          label: 'Phase *',
          value: _selectedPhase,
          items: _phases,
          onChanged: _onPhaseSelected,
        ),
        
        const SizedBox(height: 8),
        
        // Phase hint text
        if (_selectedPhase != null)
          Text(
            'Map will navigate to $_selectedPhase when selected.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: const Color(0xFF20B2AA),
              fontStyle: FontStyle.italic,
            ),
          ),
        
        const SizedBox(height: 16),

        // Location helper + coordinates preview (set by tapping the map)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.touch_app, color: Color(0xFF4CAF50), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedLatLng == null
                      ? 'Tip: Tap on the map below to mark your exact property location.'
                      : 'Selected location: ${_selectedLatLng!.latitude.toStringAsFixed(6)}, ${_selectedLatLng!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Sector/Block/Zone
        _buildTextField(
          controller: _sectorController,
          label: 'Sector/Block/Zone *',
          hint: 'E.G., Sector A, Block 12',
          icon: Icons.location_city,
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
        
        const SizedBox(height: 16),
        
        // Street Number
        _buildTextField(
          controller: _streetNumberController,
          label: 'Street Number *',
          hint: 'E.G., Street 1',
          icon: Icons.streetview,
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
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      children: [
        // Map Header with Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.map,
                color: const Color(0xFF1B5993),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Property Location',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5993),
                ),
              ),
              const Spacer(),
              // Map Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMapToggleButton('OpenStreetMap', !_isMapSatellite),
                    _buildMapToggleButton('Satellite', _isMapSatellite),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Map
        Expanded(
          child: _isLoadingBoundaries
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1B5993),
                  ),
                )
              : FlutterMap(
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
                    // Selected location marker
                    if (_selectedLatLng != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLatLng!,
                            width: 36,
                            height: 36,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFFE53935),
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMapToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMapSatellite = label == 'Satellite';
        });
        print('Map type changed to: ${_isMapSatellite ? "Satellite" : "OpenStreetMap"}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5993) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
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
    required IconData icon,
    required void Function(String) onChanged,
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
              Icons.keyboard_arrow_down,
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