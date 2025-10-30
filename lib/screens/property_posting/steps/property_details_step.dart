import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/property_form_data.dart';
import 'amenities_selection_step.dart';
import '../../../core/services/dha_geojson_boundary_service.dart' as dha;
import '../../../core/theme/app_theme.dart';

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
  final _addressController = TextEditingController();
  
  String? _selectedAreaUnit;
  String? _selectedPhase;
  bool _isMapSatellite = true;
  
  // Map related variables
  MapController _mapController = MapController();
  List<dha.BoundaryPolygon> _boundaryPolygons = [];
  bool _isLoadingBoundaries = false;
  LatLng? _selectedLocation;
  bool _isGeocoding = false;
  
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
    _addressController.text = formData.location ?? '';
    _selectedAreaUnit = formData.areaUnit;
    _selectedPhase = formData.phase;
    
    // Initialize selected location if available
    if (formData.latitude != null && formData.longitude != null) {
      _selectedLocation = LatLng(formData.latitude!, formData.longitude!);
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
  
  // Geocoding functionality
  Future<void> _geocodeAddress(String address) async {
    if (address.trim().isEmpty) return;
    
    setState(() {
      _isGeocoding = true;
    });
    
    try {
      print('🔍 Geocoding address: $address');
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);
        
        setState(() {
          _selectedLocation = latLng;
        });
        
        // Update form data
        final formData = context.read<PropertyFormData>();
        formData.updateLocationDetails(
          location: address,
          sector: formData.sector,
          phase: formData.phase,
          latitude: location.latitude,
          longitude: location.longitude,
          block: formData.block,
          streetNo: formData.streetNo,
          floor: formData.floor,
          building: formData.building,
        );
        
        // Animate map to location
        _mapController.move(latLng, 16.0);
        
        print('✅ Geocoded to: ${location.latitude}, ${location.longitude}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location found and marked on map'),
            backgroundColor: AppTheme.tealAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print('❌ Geocoding error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not find location. Please check the address.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isGeocoding = false;
      });
    }
  }
  
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    
    // Update form data with selected coordinates
    final formData = context.read<PropertyFormData>();
    formData.updateLocationDetails(
      location: formData.location,
      sector: formData.sector,
      phase: formData.phase,
      latitude: point.latitude,
      longitude: point.longitude,
      block: formData.block,
      streetNo: formData.streetNo,
      floor: formData.floor,
      building: formData.building,
    );
    
    print('📍 Location selected: ${point.latitude}, ${point.longitude}');
    
    // Show enhanced feedback with coordinates and reverse geocoding option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.cardWhite, size: 16),
                SizedBox(width: 8),
                Text(
                  'Property location marked!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cardWhite,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Lat: ${point.latitude.toStringAsFixed(6)}, Lng: ${point.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppTheme.cardWhite.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.tealAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Get Address',
          textColor: AppTheme.cardWhite,
          onPressed: () => _reverseGeocode(point),
        ),
      ),
    );
  }
  
  // Add reverse geocoding to get address from coordinates
  Future<void> _reverseGeocode(LatLng point) async {
    try {
      print('🔄 Reverse geocoding coordinates: ${point.latitude}, ${point.longitude}');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude, 
        point.longitude
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String address = '';
        
        // Build address from placemark components
        if (placemark.name != null && placemark.name!.isNotEmpty) {
          address += placemark.name! + ', ';
        }
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          address += placemark.street! + ', ';
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          address += placemark.subLocality! + ', ';
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          address += placemark.locality! + ', ';
        }
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          address += placemark.administrativeArea! + ', ';
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          address += placemark.country!;
        }
        
        // Clean up address
        address = address.replaceAll(RegExp(r',\s*$'), ''); // Remove trailing comma
        
        if (address.isNotEmpty) {
          setState(() {
            _addressController.text = address;
          });
          
          // Update form data
          final formData = context.read<PropertyFormData>();
          formData.updateLocationDetails(
            location: address,
            sector: formData.sector,
            phase: formData.phase,
            latitude: point.latitude,
            longitude: point.longitude,
            block: formData.block,
            streetNo: formData.streetNo,
            floor: formData.floor,
            building: formData.building,
          );
          
          print('✅ Reverse geocoded address: $address');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Address updated: $address'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Reverse geocoding error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not get address for this location'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
  
  // Get current location functionality
  Future<void> _getCurrentLocation() async {
    try {
      print('🔍 Getting current location...');
      
      // Check permissions first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location services are disabled. Please enable them.'),
            backgroundColor: AppTheme.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are permanently denied'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final currentLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = currentLocation;
      });
      
      // Update form data
      final formData = context.read<PropertyFormData>();
      formData.updateLocationDetails(
        location: formData.location,
        sector: formData.sector,
        phase: formData.phase,
        latitude: position.latitude,
        longitude: position.longitude,
        block: formData.block,
        streetNo: formData.streetNo,
        floor: formData.floor,
        building: formData.building,
      );
      
      // Move map to current location
      _mapController.move(currentLocation, 16.0);
      
      print('✅ Current location: ${position.latitude}, ${position.longitude}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.my_location, color: AppTheme.cardWhite, size: 16),
              SizedBox(width: 8),
              Text('Current location marked on map'),
            ],
          ),
          backgroundColor: AppTheme.tealAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Get Address',
            textColor: AppTheme.cardWhite,
            onPressed: () => _reverseGeocode(currentLocation),
          ),
        ),
      );
      
    } catch (e) {
      print('❌ Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not get current location: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
  
  // Clear marker functionality
  void _clearMarker() {
    setState(() {
      _selectedLocation = null;
    });
    
    // Clear coordinates from form data
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
    
    print('🗑️ Location marker cleared');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.clear, color: AppTheme.cardWhite, size: 16),
            SizedBox(width: 8),
            Text('Property location marker cleared'),
          ],
        ),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
    _addressController.dispose();
    super.dispose();
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
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: AppTheme.lightShadow,
              ),
              child: Icon(
                Icons.home,
                color: AppTheme.primaryBlue,
                size: 20.w,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Property Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: _buildFormFields(),
      ),
    );
  }
  
  Widget _buildFormFields() {
    return Column(
      children: [
        // Simple test container
        Container(
          height: 200,
          color: Colors.grey[200],
          child: Center(
            child: Text('Form content will go here'),
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
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppTheme.cardWhite : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
  
  List<Polygon> _buildPhasePolygons() {
    return _boundaryPolygons.map<Polygon>((boundary) {
      return Polygon(
        points: boundary.polygons.isNotEmpty ? boundary.polygons.first : [],
        color: boundary.color.withOpacity(0.3),
        borderColor: boundary.color,
        borderStrokeWidth: 2.0,
      );
    }).toList();
  }

  Widget _buildTextField({
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
              color: AppTheme.tealAccent,
              fontStyle: FontStyle.italic,
            ),
          ),
        
        const SizedBox(height: 16),
        
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
        
        const SizedBox(height: 24),
        
        // Address Section Header
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppTheme.tealAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Complete Address & Location',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Complete Address Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Address *',
              style: TextStyle(
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
                  color: AppTheme.textLight.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: _addressController,
                maxLines: 2,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter complete address (e.g., House 123, Street 5, Sector A, Phase 2, DHA Karachi)',
                  hintStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.location_city,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  suffixIcon: _isGeocoding
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.tealAccent,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.search,
                            color: AppTheme.tealAccent,
                          ),
                          onPressed: () => _geocodeAddress(_addressController.text),
                          tooltip: 'Find location on map',
                        ),
                ),
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
                  print('Address updated: $value');
                },
                onFieldSubmitted: (value) => _geocodeAddress(value),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.tealAccent.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.tealAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '📍 Enter address & tap search OR tap directly on map to mark your property location. Use satellite view for better accuracy.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppTheme.tealAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Map integrated in form
        Row(
          children: [
            Icon(
              Icons.map,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Property Location',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            const Spacer(),
            // Map Type Toggle
            Container(
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
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
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.textLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isLoadingBoundaries
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                  )
                : Stack(
                    children: [
                      // Main Map
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedLocation ?? const LatLng(33.6844, 73.0479),
                          initialZoom: _selectedLocation != null ? 16.0 : 12.0,
                          minZoom: 8.0,
                          maxZoom: 18.0,
                          onTap: _onMapTap,
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
                          
                          // Selected Location Marker
                          if (_selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.tealAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.cardWhite,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppTheme.cardWhite,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      
                      // Map Controls Overlay
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Column(
                          children: [
                            // Current Location Button
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cardWhite,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: AppTheme.lightShadow,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  // Handle current location
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
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
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppTheme.cardWhite : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
  
  List<Polygon> _buildPhasePolygons() {
    return _boundaryPolygons.map<Polygon>((boundary) {
      return Polygon(
        points: boundary.polygons.isNotEmpty ? boundary.polygons.first : [],
        color: boundary.color.withOpacity(0.3),
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
              color: AppTheme.textLight.withOpacity(0.3),
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
                color: AppTheme.textLight,
                fontWeight: FontWeight.w400,
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
              color: AppTheme.textLight.withOpacity(0.3),
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
                color: AppTheme.textLight,
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
              color: AppTheme.primaryBlue,
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