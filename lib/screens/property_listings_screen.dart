import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../services/whatsapp_service.dart';
import '../services/call_service.dart';
import '../services/customer_properties_service.dart';
import '../models/customer_property.dart';
import '../ui/widgets/cached_asset_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'sidebar_drawer.dart';
import 'property_detail_info_screen.dart';

class PropertyListingsScreen extends StatefulWidget {
  const PropertyListingsScreen({super.key});

  @override
  State<PropertyListingsScreen> createState() => _PropertyListingsScreenState();
}

class _PropertyListingsScreenState extends State<PropertyListingsScreen> {
  String _selectedPropertyType = 'All';
  String _selectedPriceRange = 'Any';
  String _selectedLocation = 'Any';
  String _searchQuery = '';
  late final TextEditingController _searchController;
  
  final CustomerPropertiesService _propertiesService = CustomerPropertiesService();
  List<CustomerProperty> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadProperties();
  }

  Future<void> _loadProperties({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _properties.clear();
      });
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _propertiesService.getApprovedProperties(
        purpose: 'Rent', // Default to Rent, can be made dynamic
        perPage: 9,
        page: _currentPage,
      );

      if (result['success'] == true) {
        // Handle different response structures
        dynamic propertiesData = result['data'];
        
        // If data is a map, try to get properties from it
        if (propertiesData is Map<String, dynamic>) {
          propertiesData = propertiesData['properties'] ?? propertiesData['data'] ?? [];
        }
        
        // Ensure it's a list
        if (propertiesData is! List) {
          print('⚠️ Properties data is not a list: ${propertiesData.runtimeType}');
          propertiesData = [];
        }
        
        final List<CustomerProperty> newProperties = [];
        
        // Convert each map to CustomerProperty
        for (var propData in propertiesData) {
          try {
            // Ensure propData is a Map
            if (propData is! Map<String, dynamic>) {
              print('⚠️ Property data is not a Map: ${propData.runtimeType}');
              continue;
            }
            
            final property = CustomerProperty.fromJson(propData);
            newProperties.add(property);
          } catch (e, stackTrace) {
            print('❌ Error parsing property: $e');
            print('   Stack trace: $stackTrace');
            print('   Property data type: ${propData.runtimeType}');
            print('   Property data: $propData');
          }
        }

        print('✅ Successfully parsed ${newProperties.length} properties from ${propertiesData.length} items');

        setState(() {
          if (refresh) {
            _properties = List<CustomerProperty>.from(newProperties);
          } else {
            _properties.addAll(newProperties);
          }
          _hasMore = newProperties.length >= 9; // If we got less than requested, no more pages
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load properties';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading properties: $e';
        _isLoading = false;
      });
    }
  }

  // Convert CustomerProperty to the format expected by PropertyDetailInfoScreen
  Map<String, dynamic> _propertyToMap(CustomerProperty property) {
    // Get first image URL or use placeholder
    String imageUrl = property.images.isNotEmpty 
        ? property.images.first 
        : 'https://via.placeholder.com/400x300';
    
    // Format price
    String priceDisplay = property.isRent 
        ? 'PKR ${property.rentPrice ?? 'N/A'}'
        : 'PKR ${property.price ?? 'N/A'}';
    
    return {
      'id': property.id,
      'title': property.title,
      'price': priceDisplay,
      'status': property.isApproved ? 'Available' : 'Pending',
      'image': imageUrl,
      'images': property.images,
      'phase': property.phase ?? property.location ?? 'N/A',
      'size': property.propertyDetails.isNotEmpty ? property.propertyDetails : 'N/A',
      'type': property.propertyType ?? property.category,
      'bedrooms': property.building ?? 'N/A',
      'bathrooms': property.floor ?? 'N/A',
      'description': property.description,
      'coordinates': {
        'lat': property.latitude ?? 31.5204,
        'lng': property.longitude ?? 74.3587,
      },
      'latitude': property.latitude,
      'longitude': property.longitude,
      'amenities': property.amenities,
      'amenitiesByCategory': property.amenitiesByCategory,
      'paymentMethod': property.paymentMethod,
      'durationDays': property.durationDays,
      'userName': property.userName,
      'userPhone': property.userPhone,
      'purpose': property.purpose,
      'category': property.category,
      'propertyType': property.propertyType,
      'area': property.area,
      'areaUnit': property.areaUnit,
      'fullLocation': property.fullLocation,
      'rentPrice': property.rentPrice,
      'priceValue': property.price,
    };
  }

  final List<Map<String, dynamic>> _hardcodedProperties = [
    {
      'title': 'Luxury Villa – Phase 1',
      'price': 'PKR 25,000,000',
      'status': 'Available',
      'image': 'assets/gallery/dha-gate-night.jpg',
      'phase': 'Phase 1',
      'size': '1 Kanal',
      'type': 'House',
      'bedrooms': '4',
      'bathrooms': '3',
      'description': 'Beautiful luxury villa with modern amenities',
      'coordinates': {'lat': 31.5204, 'lng': 74.3587}, // DHA Phase 1 - Main DHA area
    },
    {
      'title': 'Modern Apartment – Phase 3',
      'price': 'PKR 8,500,000',
      'status': 'Available',
      'image': 'assets/gallery/dha-medical-center.jpg',
      'phase': 'Phase 3',
      'size': '2 Marla',
      'type': 'Apartment',
      'bedrooms': '3',
      'bathrooms': '2',
      'description': 'Spacious apartment with city views',
      'coordinates': {'lat': 31.4800, 'lng': 74.3200}, // DHA Phase 3 - Gulberg area
    },
    {
      'title': 'Commercial Plot – Phase 5',
      'price': 'PKR 12,000,000',
      'status': 'Limited',
      'image': 'assets/gallery/dha-commercial-center.jpg',
      'phase': 'Phase 5',
      'size': '5 Marla',
      'type': 'Commercial',
      'bedrooms': 'N/A',
      'bathrooms': 'N/A',
      'description': 'Prime commercial location for business',
      'coordinates': {'lat': 31.4500, 'lng': 74.2800}, // DHA Phase 5 - Johar Town area
    },
    {
      'title': 'Residential Plot – Phase 2',
      'price': 'PKR 6,500,000',
      'status': 'Available',
      'image': 'assets/gallery/dha-sports-facility.jpg',
      'phase': 'Phase 2',
      'size': '10 Marla',
      'type': 'Plot',
      'bedrooms': 'N/A',
      'bathrooms': 'N/A',
      'description': 'Well-located residential plot',
      'coordinates': {'lat': 31.5100, 'lng': 74.3500}, // DHA Phase 2 - Residential area
    },
    {
      'title': 'Penthouse – Phase 4',
      'price': 'PKR 35,000,000',
      'status': 'Booked',
      'image': 'assets/gallery/dha-mosque-night.jpg',
      'phase': 'Phase 4',
      'size': '3 Marla',
      'type': 'Penthouse',
      'bedrooms': '5',
      'bathrooms': '4',
      'description': 'Exclusive penthouse with panoramic views',
      'coordinates': {'lat': 31.5600, 'lng': 74.4000}, // DHA Phase 4 - Model Town area
    },
    {
      'title': 'Townhouse – Phase 6',
      'price': 'PKR 15,000,000',
      'status': 'Available',
      'image': 'assets/gallery/dha-park-night.jpg',
      'phase': 'Phase 6',
      'size': '8 Marla',
      'type': 'Townhouse',
      'bedrooms': '3',
      'bathrooms': '3',
      'description': 'Modern townhouse near park area',
      'coordinates': {'lat': 31.4200, 'lng': 74.2500}, // DHA Phase 6 - Bahria Town area
    },
    {
      'title': 'Office Space – Phase 7',
      'price': 'PKR 18,000,000',
      'status': 'Available',
      'image': 'assets/gallery/imperial-hall.jpg',
      'phase': 'Phase 7',
      'size': '4 Marla',
      'type': 'Commercial',
      'bedrooms': 'N/A',
      'bathrooms': 'N/A',
      'description': 'Premium office space in business district',
      'coordinates': {'lat': 31.3900, 'lng': 74.2200}, // DHA Phase 7 - Defence area
    },
    {
      'title': 'Duplex House – Phase 1',
      'price': 'PKR 22,000,000',
      'status': 'Limited',
      'image': 'assets/gallery/dha-gate-night.jpg',
      'phase': 'Phase 1',
      'size': '1.5 Kanal',
      'type': 'House',
      'bedrooms': '4',
      'bathrooms': '3',
      'description': 'Spacious duplex with garden',
      'coordinates': {'lat': 31.5220, 'lng': 74.3600}, // DHA Phase 1 - Duplex area
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerProperty> get _filteredProperties {
    if (_searchQuery.isEmpty || _searchQuery.trim().isEmpty) {
      return _properties;
    }
    
    return _properties.where((property) {
      final title = property.title.toLowerCase();
      final phase = (property.phase ?? property.location ?? '').toLowerCase();
      final size = (property.propertyDetails).toLowerCase();
      final query = _searchQuery.toLowerCase().trim();
      
      return title.contains(query) || 
             phase.contains(query) || 
             size.contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const SidebarDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header with white background
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF1B5993), // Navy blue border
                    width: 2.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,
                            color: Color(0xFF1B5993),
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            l10n.properties,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B5993),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showFilterBottomSheet();
                          },
                          icon: const Icon(Icons.tune, color: Color(0xFF1B5993)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Search bar
                    Container(
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.w,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: l10n.searchProperties,
                          hintStyle: TextStyle(
                              fontFamily: 'Inter',
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          suffixIcon: (_searchQuery.isNotEmpty && _searchQuery.trim().isNotEmpty)
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Filter pills
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(l10n.all, true),
                    const SizedBox(width: 8),
                    _buildFilterChip(l10n.houses, false),
                    const SizedBox(width: 8),
                    _buildFilterChip(l10n.flats, false),
                    const SizedBox(width: 8),
                    _buildFilterChip(l10n.plots, false),
                    const SizedBox(width: 8),
                    _buildFilterChip(l10n.commercial, false),
                  ],
                ),
              ),
            ),
            
            // Properties List
            Expanded(
              child: _isLoading && _properties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF20B2AA)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading properties...',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null && _properties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadProperties(refresh: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF20B2AA),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredProperties.isEmpty && _searchQuery.isNotEmpty && _searchQuery.trim().isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No properties found',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try searching with different keywords',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _filteredProperties.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.home_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No properties available',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredProperties.length,
                                  itemBuilder: (context, index) {
                                    final property = _filteredProperties[index];
                                    return _buildZameenPropertyCard(property, index);
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPropertyType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5993) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B5993) : const Color(0xFF1B5993).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF1B5993).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1B5993),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZameenPropertyCard(CustomerProperty property, int index) {
    final propertyMap = _propertyToMap(property);
    final imageUrl = property.images.isNotEmpty ? property.images.first : null;
    final priceDisplay = property.isRent 
        ? 'PKR ${property.rentPrice ?? 'N/A'}'
        : 'PKR ${property.price ?? 'N/A'}';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailInfoScreen(property: property, propertyMap: propertyMap),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  // Property Image - Use network image if available, otherwise placeholder
                  imageUrl != null && imageUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF20B2AA).withOpacity(0.1),
                                  const Color(0xFF1B5993).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF20B2AA)),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF20B2AA).withOpacity(0.1),
                                  const Color(0xFF1B5993).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF20B2AA),
                                size: 50,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF20B2AA).withOpacity(0.1),
                                const Color(0xFF1B5993).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.home,
                              color: Color(0xFF20B2AA),
                              size: 50,
                            ),
                          ),
                        ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20B2AA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      property.isApproved ? 'Available' : 'Pending',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Tilted DHA Managed tag - very gentle angle for complete text visibility
                Positioned(
                  top: 0,
                  left: -30,
                  child: Transform.rotate(
                    angle: -0.3, // Very gentle angle (about 17 degrees) for maximum text visibility
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20B2AA), // Teal color
                        // No borderRadius for rectangle shape
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Managed by DHA',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Action buttons
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _buildActionButton(Icons.message, () {
                        _launchWhatsAppForProperty(property);
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(Icons.phone, () {
                        CallService.showCallBottomSheet(
                          context, 
                          property.userPhone ?? '+92-51-111-555-400'
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
          
          // Property Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  priceDisplay,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF20B2AA),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.fullLocation.isNotEmpty ? property.fullLocation : (property.phase ?? property.location ?? 'N/A'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (property.propertyDetails.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          property.propertyDetails,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    if (property.propertyDetails.isNotEmpty) const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        property.propertyType ?? property.category ?? 'N/A',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  property.description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF20B2AA),
          size: 16,
        ),
      ),
    );
  }


  Widget _buildFilterSection(String title, IconData icon, List<String> options, String selectedValue, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getFilterIconColor(title).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: _getFilterIconColor(title),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: options.map((option) {
                bool isSelected = selectedValue == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onChanged(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _getFilterIconColor(title) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFilterIconColor(String title) {
    switch (title) {
      case 'Property Type':
        return const Color(0xFF1B5993);
      case 'Price Range':
        return Colors.green;
      case 'Location':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Properties',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            
            // Filter Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Property Type Filter
                    _buildFilterSection(
                      'Property Type',
                      Icons.apartment,
                      [
                        'All', 'Houses', 'Flats', 'Plots', 'Commercial'
                      ],
                      _selectedPropertyType,
                      (value) => setState(() => _selectedPropertyType = value),
                    ),
                    
                    // Price Range Filter
                    _buildFilterSection(
                      'Price Range',
                      Icons.attach_money,
                      [
                        'Any', 'Under 5M', '5M - 10M', '10M - 20M', 'Above 20M'
                      ],
                      _selectedPriceRange,
                      (value) => setState(() => _selectedPriceRange = value),
                    ),
                    
                    // Location Filter
                    _buildFilterSection(
                      'Location',
                      Icons.place,
                      [
                        'Any', 'Phase 1', 'Phase 2', 'Phase 3', 'Phase 4', 'Phase 5', 'Phase 6', 'Phase 7'
                      ],
                      _selectedLocation,
                      (value) => setState(() => _selectedLocation = value),
                    ),
                  ],
                ),
              ),
            ),
            
            // Filter Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedPropertyType = 'All';
                          _selectedPriceRange = 'Any';
                          _selectedLocation = 'Any';
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear All'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Apply filters logic can be added here
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Apply Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5993),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _launchWhatsAppForProperty(CustomerProperty property) {
    final priceDisplay = property.isRent 
        ? 'PKR ${property.rentPrice ?? 'N/A'}'
        : 'PKR ${property.price ?? 'N/A'}';
    
    WhatsAppService.launchWhatsAppForProperty(
      phoneNumber: property.userPhone ?? WhatsAppService.defaultContactNumber,
      propertyTitle: property.title,
      propertyPrice: priceDisplay,
      propertyLocation: property.fullLocation.isNotEmpty ? property.fullLocation : (property.phase ?? property.location ?? 'Location not available'),
      context: context,
    );
  }
}
