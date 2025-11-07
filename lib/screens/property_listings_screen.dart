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
import '../ui/widgets/app_icons.dart';
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

  // Filter state variables
  String? _selectedCategory; // Commercial or Residential
  String? _selectedPurpose; // Rent or Sell
  double _priceMin = 1000;
  double _priceMax = 5000000;
  bool _priceRangeModified = false; // Track if user has modified price range
  String? _selectedSortBy; // price_high_low or price_low_high
  
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
        perPage: 9,
        page: _currentPage,
        category: _selectedCategory,
        purpose: _selectedPurpose,
        priceMin: _priceRangeModified ? _priceMin.toInt() : null,
        priceMax: _priceRangeModified ? _priceMax.toInt() : null,
        sortBy: _selectedSortBy,
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

  bool _matchesPropertyType(CustomerProperty property, String filterLabel) {
    final propertyType = (property.propertyType ?? property.category ?? '').toLowerCase();
    final filterLower = filterLabel.toLowerCase();
    
    // Check if filter matches "All" (handle both localized and English)
    if (filterLower == 'all' || filterLower.isEmpty) {
      return true;
    }
    
    // Map filter labels to property type keywords
    // This handles both localized strings and English keywords
    List<String> typeKeywords = [];
    
    // Check for Houses filter (matches: house, houses, villa, townhouse, etc.)
    if (filterLower.contains('house') || filterLower.contains('villa') || filterLower.contains('townhouse')) {
      typeKeywords = ['house', 'villa', 'townhouse', 'duplex', 'bungalow', 'residential house', 'home'];
    } 
    // Check for Flats filter (matches: flat, flats, apartment, etc.)
    else if (filterLower.contains('flat') || filterLower.contains('apartment') || filterLower.contains('penthouse')) {
      typeKeywords = ['flat', 'apartment', 'penthouse', 'studio', 'condo', 'unit', 'apartments'];
    } 
    // Check for Plots filter (matches: plot, plots, land, etc.)
    else if (filterLower.contains('plot') || filterLower.contains('land')) {
      typeKeywords = ['plot', 'land', 'plot of land', 'residential plot', 'commercial plot', 'plots'];
    } 
    // Check for Commercial filter
    else if (filterLower.contains('commercial') || filterLower.contains('office') || filterLower.contains('shop')) {
      typeKeywords = ['commercial', 'office', 'shop', 'store', 'warehouse', 'retail', 'showroom', 'offices'];
    }
    
    // If no keywords found, return false (shouldn't happen with valid filters)
    if (typeKeywords.isEmpty) {
      return false;
    }
    
    // Check if property type matches any of the keywords
    return typeKeywords.any((keyword) => propertyType.contains(keyword));
  }

  List<CustomerProperty> get _filteredProperties {
    List<CustomerProperty> filtered = _properties;
    
    // Filter by property type (skip if "All" is selected)
    final filterLower = _selectedPropertyType.toLowerCase();
    if (filterLower != 'all' && _selectedPropertyType.isNotEmpty) {
      filtered = filtered.where((property) {
        return _matchesPropertyType(property, _selectedPropertyType);
      }).toList();
    }
    
    // Filter by search query if provided
    if (_searchQuery.isNotEmpty && _searchQuery.trim().isNotEmpty) {
      filtered = filtered.where((property) {
        final title = property.title.toLowerCase();
        final phase = (property.phase ?? property.location ?? '').toLowerCase();
        final size = (property.propertyDetails).toLowerCase();
      final query = _searchQuery.toLowerCase().trim();
      
      return title.contains(query) || 
             phase.contains(query) || 
             size.contains(query);
    }).toList();
    }
    
    return filtered;
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
                          icon: Icon(
                            AppIcons.menu,
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
                          icon: Icon(AppIcons.tune, color: Color(0xFF1B5993)),
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
                          prefixIcon: Icon(
                            AppIcons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          suffixIcon: (_searchQuery.isNotEmpty && _searchQuery.trim().isNotEmpty)
                              ? IconButton(
                                  icon: Icon(
                                    AppIcons.clear,
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
                    _buildFilterPill(l10n.all, _selectedPropertyType == l10n.all),
                    const SizedBox(width: 8),
                    _buildFilterPill(l10n.houses, _selectedPropertyType == l10n.houses),
                    const SizedBox(width: 8),
                    _buildFilterPill(l10n.flats, _selectedPropertyType == l10n.flats),
                    const SizedBox(width: 8),
                    _buildFilterPill(l10n.plots, _selectedPropertyType == l10n.plots),
                    const SizedBox(width: 8),
                    _buildFilterPill(l10n.commercial, _selectedPropertyType == l10n.commercial),
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
                                AppIcons.errorOutline,
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
                            AppIcons.searchOff,
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
                                        AppIcons.homeOutlined,
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

  Widget _buildFilterPill(String label, bool isSelected) {
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
              Icon(
                AppIcons.check,
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
                        child: Center(
                          child: Icon(
                            AppIcons.imageNotSupported,
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
                      'Approved',
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
                      _buildActionButton(AppIcons.favoriteBorder, () {
                        _addToFavorites(property);
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(AppIcons.message, () {
                        _launchWhatsAppForProperty(property);
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(AppIcons.phone, () {
                        if (property.userPhone != null && property.userPhone!.isNotEmpty) {
                          CallService.showCallBottomSheet(
                            context, 
                            property.userPhone!
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Phone number not available for this property'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
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
                      AppIcons.place,
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                  color: Color(0xFF1B5993),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.tune, color: Colors.white, size: 24),
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
                    child: Icon(AppIcons.close, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            
            // Filter Content
            Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // Category Filter
                      _buildFilterSectionHeader(Icons.category, 'Category'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterChip(
                              'Commercial',
                              _selectedCategory == 'Commercial',
                              () {
                                setModalState(() {
                                  _selectedCategory = _selectedCategory == 'Commercial' ? null : 'Commercial';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterChip(
                              'Residential',
                              _selectedCategory == 'Residential',
                              () {
                                setModalState(() {
                                  _selectedCategory = _selectedCategory == 'Residential' ? null : 'Residential';
                                });
                              },
                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    
                      // Purpose Filter
                      _buildFilterSectionHeader(AppIcons.sell, 'Purpose'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterChip(
                              'Rent',
                              _selectedPurpose == 'Rent',
                              () {
                                setModalState(() {
                                  _selectedPurpose = _selectedPurpose == 'Rent' ? null : 'Rent';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterChip(
                              'Sell',
                              _selectedPurpose == 'Sell',
                              () {
                                setModalState(() {
                                  _selectedPurpose = _selectedPurpose == 'Sell' ? null : 'Sell';
                                });
                              },
                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Property Type Filter (based on category)
                      _buildFilterSectionHeader(Icons.apartment, 'Property Type'),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'All',
                              _selectedPropertyType == 'All',
                              () {
                                setModalState(() {
                                  _selectedPropertyType = 'All';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Houses',
                              _selectedPropertyType == 'Houses',
                              () {
                                setModalState(() {
                                  _selectedPropertyType = 'Houses';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Flats',
                              _selectedPropertyType == 'Flats',
                              () {
                                setModalState(() {
                                  _selectedPropertyType = 'Flats';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Plots',
                              _selectedPropertyType == 'Plots',
                              () {
                                setModalState(() {
                                  _selectedPropertyType = 'Plots';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Commercial',
                              _selectedPropertyType == 'Commercial',
                              () {
                                setModalState(() {
                                  _selectedPropertyType = 'Commercial';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Price Range Slider
                      _buildFilterSectionHeader(Icons.attach_money, 'Price Range'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PKR ${_priceMin.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B5993),
                            ),
                          ),
                          Text(
                            'PKR ${_priceMax.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B5993),
                            ),
                    ),
                  ],
                ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: RangeValues(_priceMin, _priceMax),
                        min: 1000,
                        max: 5000000,
                        divisions: 499,
                        activeColor: const Color(0xFF1B5993),
                        inactiveColor: Colors.grey[300],
                        labels: RangeLabels(
                          'PKR ${_priceMin.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          'PKR ${_priceMax.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        ),
                        onChanged: (RangeValues values) {
                          setModalState(() {
                            _priceMin = values.start;
                            _priceMax = values.end;
                            _priceRangeModified = true;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Sort Filter
                      _buildFilterSectionHeader(Icons.sort, 'Sort By'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterChip(
                              'Price: Low to High',
                              _selectedSortBy == 'price_low_high',
                              () {
                                setModalState(() {
                                  _selectedSortBy = _selectedSortBy == 'price_low_high' ? null : 'price_low_high';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterChip(
                              'Price: High to Low',
                              _selectedSortBy == 'price_high_low',
                              () {
                                setModalState(() {
                                  _selectedSortBy = _selectedSortBy == 'price_high_low' ? null : 'price_high_low';
                                });
                              },
                            ),
                          ),
                        ],
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
                          // Clear all filters and reload properties
                          setModalState(() {
                            _selectedCategory = null;
                            _selectedPurpose = null;
                            _selectedPropertyType = 'All';
                            _priceMin = 1000;
                            _priceMax = 5000000;
                            _priceRangeModified = false;
                            _selectedSortBy = null;
                          });
                          // Update main state and close bottom sheet
                          Navigator.pop(context);
                        setState(() {
                            _selectedCategory = null;
                            _selectedPurpose = null;
                          _selectedPropertyType = 'All';
                            _priceMin = 1000;
                            _priceMax = 5000000;
                            _priceRangeModified = false;
                            _selectedSortBy = null;
                        });
                          // Reload all properties without any filters
                          _loadProperties(refresh: true);
                      },
                      icon: Icon(AppIcons.clear, size: 16),
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
                            // Sync state and apply filters
                        Navigator.pop(context);
                            setState(() {
                              // Ensure price range modification flag is set if values differ from defaults
                              if (!_priceRangeModified && (_priceMin != 1000 || _priceMax != 5000000)) {
                                _priceRangeModified = true;
                              }
                            });
                            _loadProperties(refresh: true);
                      },
                      icon: Icon(AppIcons.check, size: 16),
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
      ),
    );
  }

  Widget _buildFilterSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5993).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1B5993),
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
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5993) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
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

  Future<void> _addToFavorites(CustomerProperty property) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Adding to favorites...'),
            ],
          ),
          backgroundColor: const Color(0xFF20B2AA),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      final result = await _propertiesService.addFavoriteProperty(property.id);

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(AppIcons.checkCircle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(result['message'] ?? 'Property added to favorites successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(AppIcons.errorOutline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(result['message'] ?? 'Failed to add property to favorites'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
