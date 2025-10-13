import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import 'sidebar_drawer.dart';

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

  final List<Map<String, dynamic>> _properties = [
    {
      'title': '10 Marla Plot – Phase 6',
      'price': 'PKR 4,500,000',
      'status': 'Available',
      'image': 'assets/gallery/dha-gate-night.jpg',
      'phase': 'Phase 6',
      'size': '10 Marla',
    },
    {
      'title': '1 Kanal Plot – Phase 3',
      'price': 'PKR 8,200,000',
      'status': 'Limited',
      'image': 'assets/gallery/dha-medical-center.jpg',
      'phase': 'Phase 3',
      'size': '1 Kanal',
    },
    {
      'title': '5 Marla Plot – Phase 5',
      'price': 'PKR 2,800,000',
      'status': 'Available',
      'image': 'assets/gallery/dha-commercial-center.jpg',
      'phase': 'Phase 5',
      'size': '5 Marla',
    },
    {
      'title': '2 Kanal Plot – Phase 2',
      'price': 'PKR 15,000,000',
      'status': 'Booked',
      'image': 'assets/gallery/dha-sports-facility.jpg',
      'phase': 'Phase 2',
      'size': '2 Kanal',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProperties {
    if (_searchQuery.isEmpty || _searchQuery.trim().isEmpty) {
      return _properties;
    }
    
    return _properties.where((property) {
      final title = property['title']?.toString().toLowerCase() ?? '';
      final phase = property['phase']?.toString().toLowerCase() ?? '';
      final size = property['size']?.toString().toLowerCase() ?? '';
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
                              fontSize: 18,
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
                    const SizedBox(height: 12),
                    // Search bar
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
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
              child: _filteredProperties.isEmpty && _searchQuery.isNotEmpty && _searchQuery.trim().isNotEmpty
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected ? const LinearGradient(
          colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ) : null,
        color: isSelected ? null : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
        boxShadow: isSelected ? [
          BoxShadow(
            color: const Color(0xFF20B2AA).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Text(
        label,
        style: TextStyle(
                              fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildZameenPropertyCard(Map<String, dynamic> property, int index) {
    return Container(
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF20B2AA).withOpacity(0.1),
                  const Color(0xFF1B5993).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.home_work,
                    color: Color(0xFF20B2AA),
                    size: 50,
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
                      property['status'],
                      style: TextStyle(
                              fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                      _buildActionButton(Icons.share, () {}),
                      const SizedBox(width: 8),
                      _buildActionButton(Icons.message, () {}),
                      const SizedBox(width: 8),
                      _buildActionButton(Icons.phone, () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Property Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['price'],
                  style: TextStyle(
                              fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF20B2AA),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property['title'],
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
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      property['phase'],
                      style: TextStyle(
                              fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        property['size'],
                        style: TextStyle(
                              fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Flats',
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
                      Icons.home,
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
                      Icons.location_on,
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
}
