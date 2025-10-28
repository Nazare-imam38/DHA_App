import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'property_review_screen.dart';
import 'main_wrapper.dart';
import '../core/theme/app_theme.dart';
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
  late AnimationController _blinkController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _blinkAnimation;

  // Form controllers
  final TextEditingController _plotNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phaseSectorBlockZoneController = TextEditingController();

  // Form state
  String _selectedPhaseSectorBlockZone = 'Phase 1';

  // Map state
  LatLng? _propertyLocation;
  bool _isSatelliteView = false;

  final List<String> _phaseSectorBlockZoneOptions = [
    'Phase 1', 'Phase 2', 'Phase 3', 'Phase 4', 'Phase 5', 'Phase 6', 'Phase 7',
    'Sector A', 'Sector B', 'Sector C', 'Sector D', 'Sector E', 'Sector F',
    'Block A', 'Block B', 'Block C', 'Block D', 'Block E', 'Block F',
    'Zone 1', 'Zone 2', 'Zone 3', 'Zone 4', 'Zone 5'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _blinkAnimation = ColorTween(
      begin: Colors.grey[400],
      end: const Color(0xFF20B2AA),
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    
    // Start blinking animation
    _blinkController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _blinkController.dispose();
    _plotNoController.dispose();
    _addressController.dispose();
    _phaseSectorBlockZoneController.dispose();
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
            color: Color(0xFF1B5993), // Navy blue color
            size: 16, // Smaller size
                ),
                onPressed: () => Navigator.pop(context),
              ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: Color(0xFF1B5993), // Navy blue color
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
              style: AppTheme.titleLarge,
            ),
          ],
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppTheme.radiusXLarge),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            height: 2.0,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5993), // Navy blue border
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusXLarge),
                bottomRight: Radius.circular(AppTheme.radiusXLarge),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          
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
                      color: const Color(0xFFE0F7FA), // Light teal background
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                                color: const Color(0xFF20B2AA), // Teal border
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
                                     color: Color(0xFF20B2AA), // Teal color
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
                            color: Color(0xFF20B2AA), // Teal color
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
                    color: Color(0xFF1B5993), // App theme color
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
                
                        // Form Card
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
                      // Plot No
                      _buildModernFormField(
                        controller: _plotNoController,
                        label: 'Plot No',
                        hint: 'e.g., 123-A, Street 5',
                        icon: Icons.home_work,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Phase/Sector/Block/Zone
                      _buildModernDropdownField(
                        label: 'Phase/Sector/Block/Zone',
                        value: _selectedPhaseSectorBlockZone,
                        items: _phaseSectorBlockZoneOptions,
                        onChanged: (value) => setState(() => _selectedPhaseSectorBlockZone = value!),
                        icon: Icons.location_city,
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
                      Row(
                        children: [
                          Text(
                            'Property Location',
                            style: AppTheme.titleMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          // Map/Satellite Toggle Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMapToggleButton('Map', true),
                                _buildMapToggleButton('Satellite', false),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LocationMapWidget(
                            location: _propertyLocation,
                            address: _addressController.text.trim(),
                            height: 300,
                            showMarker: true,
                            isSatelliteView: _isSatelliteView,
                            onLocationChanged: (location) {
                              setState(() {
                                _propertyLocation = location;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Map Instructions
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF20B2AA).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF20B2AA),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap on the map to place your property marker at the exact location',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: const Color(0xFF20B2AA),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                  width: 1,
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
                                      color: const Color(0xFF1B5993), // App theme color
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Back',
                                      style: TextStyle(
                                                fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1B5993), // App theme color
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
                                color: const Color(0xFF1B5993), // App theme color
                                borderRadius: BorderRadius.circular(12),
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
                
                        // Animated Home Icon
                        Center(
                          child: GestureDetector(
                            onTap: () => _navigateToHome(),
                            onLongPress: () => _navigateToHomeSimple(), // Backup method
                            child: _buildAnimatedHomeIcon(),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5993), // App theme color
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
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF20B2AA), // Teal color for icons
                size: 20,
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5993), // App theme color
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
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF20B2AA), // Teal color for icons
                size: 20,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
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
    if (_plotNoController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
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

  Widget _buildMapToggleButton(String label, bool isMap) {
    bool isSelected = isMap ? !_isSatelliteView : _isSatelliteView;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSatelliteView = !isMap;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF20B2AA) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHomeIcon() {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) {
            // Add a subtle scale effect on tap
            _scaleController.reverse();
          },
          onTapUp: (_) {
            _scaleController.forward();
          },
          onTapCancel: () {
            _scaleController.forward();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _blinkAnimation.value!.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.home_rounded,
                  color: _blinkAnimation.value,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToHome() {
    try {
      // Stop all animations before navigation
      _fadeController.stop();
      _slideController.stop();
      _scaleController.stop();
      _blinkController.stop();
      
      // Add a small delay to ensure animations are stopped
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainWrapper(initialTabIndex: 0),
            ),
          );
        }
      });
    } catch (e) {
      print('Navigation error: $e');
      // Fallback navigation - just pop to root
      if (mounted && context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  void _navigateToHomeSimple() {
    // Simple navigation without animations
    try {
      if (mounted && context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Simple navigation error: $e');
    }
  }
}