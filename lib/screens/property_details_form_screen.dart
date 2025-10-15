import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'property_review_screen.dart';
import '../core/theme/app_theme.dart';
import '../core/services/geocoding_service.dart';
import '../ui/widgets/location_map_widget.dart';

class PropertyDetailsFormScreen extends StatefulWidget {
  const PropertyDetailsFormScreen({super.key});

  @override
  State<PropertyDetailsFormScreen> createState() => _PropertyDetailsFormScreenState();
}

class _PropertyDetailsFormScreenState extends State<PropertyDetailsFormScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Form controllers
  final TextEditingController _propertyTitleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // Form state
  String _selectedPropertyType = 'House';
  String _selectedPhase = 'Phase 1';

  // Map and geocoding state
  LatLng? _propertyLocation;
  bool _isGeocoding = false;
  final GeocodingService _geocodingService = GeocodingService();

  final List<String> _propertyTypes = ['House', 'Flat', 'Plot', 'Commercial'];
  final List<String> _phases = ['Phase 1', 'Phase 2', 'Phase 3', 'Phase 4', 'Phase 5', 'Phase 6', 'Phase 7'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupAddressListener();
  }

  void _setupAddressListener() {
    _addressController.addListener(() {
      _debounceGeocoding();
    });
  }

  void _debounceGeocoding() {
    // Debounce geocoding to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_addressController.text.trim().isNotEmpty) {
        _geocodeAddress();
      }
    });
  }

  Future<void> _geocodeAddress() async {
    if (_isGeocoding) return;
    
    setState(() {
      _isGeocoding = true;
    });

    try {
      final address = _addressController.text.trim();
      if (address.isNotEmpty) {
        final location = await _geocodingService.geocodeAddress(address);
        if (location != null) {
          setState(() {
            _propertyLocation = location;
          });
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    } finally {
      setState(() {
        _isGeocoding = false;
      });
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));


    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _propertyTitleController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
                color: AppTheme.navyBlue, // Navy blue color
                size: 16, // Smaller size
          ),
          onPressed: () => Navigator.pop(context),
        ),
            flexibleSpace: FlexibleSpaceBar(
        title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                      color: AppTheme.navyBlue,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.home_work_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Text(
              'PROPERTY DETAILS',
                    style: AppTheme.titleLarge.copyWith(fontSize: 16),
            ),
          ],
        ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
          
          // Main Content
          SliverToBoxAdapter(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                color: AppTheme.tealAccent.withValues(alpha: 0.3),
                                width: 1,
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
                            color: AppTheme.tealAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                        const SizedBox(height: 20),
                
                // Main Title
                const Text(
                  'Property Information',
                  style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                    color: AppTheme.navyBlue,
                            letterSpacing: -0.5,
                  ),
                ),
                
                        const SizedBox(height: 6),
                
                // Subtitle
                Text(
                  'Provide detailed information about your property',
                  style: TextStyle(
                    fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                
                        const SizedBox(height: 20),
                
                        // Compact Form Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                                color: const Color(0xFF1B5993).withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Title
                              _buildModernFormField(
                        controller: _propertyTitleController,
                        label: 'Property Title',
                        hint: 'e.g., Beautiful 3 Bedroom House',
                        icon: Icons.title,
                      ),
                      
                              const SizedBox(height: 16),
                              
                              // Property Type and Phase Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernDropdownField(
                        label: 'Property Type',
                        value: _selectedPropertyType,
                        items: _propertyTypes,
                        onChanged: (value) => setState(() => _selectedPropertyType = value!),
                        icon: Icons.home,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildModernDropdownField(
                                      label: 'DHA Phase',
                                      value: _selectedPhase,
                                      items: _phases,
                                      onChanged: (value) => setState(() => _selectedPhase = value!),
                                      icon: Icons.location_on,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                      
                      // Price and Size Row
                      Row(
                        children: [
                          Expanded(
                                    child: _buildModernFormField(
                              controller: _priceController,
                              label: 'Price (PKR)',
                                      hint: 'e.g., 5,000,000',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                                  const SizedBox(width: 12),
                          Expanded(
                                    child: _buildModernFormField(
                              controller: _sizeController,
                              label: 'Size',
                              hint: 'e.g., 3 Marla',
                              icon: Icons.straighten,
                            ),
                          ),
                        ],
                      ),
                      
                              const SizedBox(height: 16),
                      
                      // Address
                              _buildModernFormField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'Enter complete address',
                        icon: Icons.location_city,
                        maxLines: 2,
                      ),
                      
                              const SizedBox(height: 16),
                      
                      // Location Map
                      if (_addressController.text.trim().isNotEmpty) ...[
                        Text(
                          'Property Location',
                          style: AppTheme.titleMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        LocationMapWidget(
                          location: _propertyLocation,
                          address: _addressController.text.trim(),
                          height: 200,
                          showMarker: true,
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Contact Information
                              _buildModernFormField(
                        controller: _contactController,
                        label: 'Contact Number',
                        hint: 'e.g., +92-300-1234567',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      
                              const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          // Back Button
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                          color: AppTheme.navyBlue,
                                          width: 2,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios,
                                              color: AppTheme.navyBlue,
                                      size: 16,
                                    ),
                                            const SizedBox(width: 6),
                                    Text(
                                      'Back',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                                fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                                color: AppTheme.navyBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Continue Button
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.navyBlue,
                                        borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                            color: const Color(0xFF1B5993).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: _handleContinue,
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                                fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                        const SizedBox(height: 20),
                
                        // Navigate to Home Button
                Container(
                  width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _navigateToHome(),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF20B2AA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                                      child: const Icon(
                                        Icons.home_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                          Text(
                                            'Navigate to Home',
                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF20B2AA),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Return to the main dashboard',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF20B2AA),
                                      size: 16,
                                  ),
                                ],
                              ),
                              ),
                            ),
                          ),
                        ),
                
              ],
            ),
                          ),
                        ),
                      ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildModernFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.titleMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.borderGrey.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontFamily: AppTheme.primaryFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: AppTheme.primaryFont,
                fontSize: 16,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 8, right: 12),
                child: Icon(
                  icon,
                  color: AppTheme.tealAccent,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.titleMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.borderGrey.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 8, right: 12),
                child: Icon(
                  icon,
                  color: AppTheme.tealAccent,
                  size: 22,
                ),
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: AppTheme.primaryFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _handleContinue() {
    // Validate form
    if (_propertyTitleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _sizeController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Navigate to review screen
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PropertyReviewScreen(),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Property Listing Help',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Tips for listing your property:\n\n• Use clear, descriptive titles\n• Include all relevant features\n• Provide accurate pricing\n• Add high-quality photos\n• Be honest about condition\n• Include contact information',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPriceCalculator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Price Calculator',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Market price estimation:\n\n• Location: Phase 1-7 premium\n• Size: Marla/Kanal rates\n• Condition: Excellent/Good/Fair\n• Features: Parking, Garden, Security\n• Market trends: +8-12% annually\n\nUse DHA official rates as reference.',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showRequiredDocuments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Required Documents',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Documents needed for property listing:\n\n• Property ownership documents\n• DHA membership card\n• CNIC/NICOP\n• Property photos (5-10 images)\n• NOC (if applicable)\n• Utility bills\n• Any other relevant documents',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showTimelineInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Listing Timeline',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Expected timeline for property listing:\n\n• Form completion: 10-15 minutes\n• Document upload: 5-10 minutes\n• Review & submit: 5-10 minutes\n• Verification: 1-2 hours\n• Live listing: 24-48 hours\n\nTotal: 2-3 days maximum',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    // Navigate to home screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home', // Assuming you have a home route defined
      (route) => false, // Remove all previous routes
    );
  }
}