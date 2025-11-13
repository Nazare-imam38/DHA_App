import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/language_service.dart';
import '../../../screens/property_listings_screen.dart';
import '../../../screens/projects_screen_instant.dart';
import '../../../screens/ownership_selection_screen.dart';
import '../../../screens/sidebar_drawer.dart';
import '../../../ui/screens/auth/login_screen.dart';
import '../../../ui/widgets/cached_asset_image.dart';
import '../../../ui/widgets/app_icons.dart';
import '../../../ui/widgets/ad_banner_widget.dart';
import '../../../providers/plot_stats_provider.dart';
import '../../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProjects;
  
  const HomeScreen({super.key, this.onNavigateToProjects});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  String _selectedPropertyType = 'Buy';
  String _selectedPropertyCategory = '';
  String _selectedFilter = '';
  String _selectedLocation = '';
  bool _showLocationDropdown = false;
  bool _showImageModal = false;
  String _selectedImagePath = '';
  String _selectedImageTitle = '';
  
  // Animation Controllers
  late AnimationController _heroAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _parallaxController;
  late AnimationController _counterAnimationController;
  
  // Hero Section Animations
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _heroScaleAnimation;
  
  // Card Animations
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  
  // Counter Animations
  Animation<double>? _residentialCounterAnimation;
  Animation<double>? _commercialCounterAnimation;
  late Animation<double> _cardScaleAnimation;
  
  // Text Animations
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  
  // Parallax Animation
  late Animation<double> _parallaxAnimation;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  
  List<Map<String, dynamic>> _getCarouselData(BuildContext context) {
    return [
      {
        'title': AppLocalizations.of(context)!.dhaPhase1,
        'subtitle': 'Premium Commercial Area',
        'gradient': [Color(0xFF20B2AA), Color(0xFF1B5993)],
      },
      {
        'title': AppLocalizations.of(context)!.dhaPhase2,
        'subtitle': 'Modern Residential Plots',
        'gradient': [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
      },
      {
        'title': AppLocalizations.of(context)!.dhaPhase3,
        'subtitle': 'Luxury Living Standards',
        'gradient': [Color(0xFF1B5993), Color(0xFF1B5993)],
      },
      {
        'title': AppLocalizations.of(context)!.dhaPhase4,
        'subtitle': 'Well-Planned Community',
        'gradient': [Color(0xFF27AE60), Color(0xFF2ECC71)],
      },
    ];
  }

  final List<String> _dhaPhases = [
    'Phase 1',
    'Phase 2', 
    'Phase 3',
    'Phase 4',
    'Phase 5',
    'Phase 6',
    'Phase 7',
    'Phase 8',
  ];

  final List<String> _filterOptions = [
    'Popular',
    'Type',
    'Location', 
    'Area Size',
    'Price Range',
    'New Listings',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize Animation Controllers
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _counterAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Hero Section Animations
    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    
    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroAnimationController, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)));
    
    _heroScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimationController, curve: const Interval(0.2, 1.0, curve: Curves.elasticOut)),
    );
    
    // Card Animations
    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
    );
    
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));
    
    _cardScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );
    
    // Text Animations
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut),
    );
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOutCubic));
    
    // Parallax Animation
    _parallaxAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _parallaxController, curve: Curves.easeInOut),
    );
    
    // Initialize counter animations with default values
    _initializeCounterAnimations();
    
    // Fetch plot statistics and start animations
    _fetchPlotStatsAndStartAnimations();
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _cardAnimationController.dispose();
    _textAnimationController.dispose();
    _parallaxController.dispose();
    _counterAnimationController.dispose();
    super.dispose();
  }

  /// Initialize counter animations with default values
  void _initializeCounterAnimations() {
    _residentialCounterAnimation = Tween<double>(begin: 0.0, end: 75.0).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
    
    _commercialCounterAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
  }

  /// Update counter animations with new values
  void _updateCounterAnimations(int residentialCount, int commercialCount) {
    _residentialCounterAnimation = Tween<double>(begin: 0.0, end: residentialCount.toDouble()).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
    
    _commercialCounterAnimation = Tween<double>(begin: 0.0, end: commercialCount.toDouble()).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
  }

  /// Fetch plot statistics and start animations
  Future<void> _fetchPlotStatsAndStartAnimations() async {
    // Start hero animation first
    _heroAnimationController.forward();
    
    // Start other animations with delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _textAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 900), () {
      _parallaxController.forward();
    });
    
    // Fetch plot statistics in the background
    try {
      final plotStatsProvider = Provider.of<PlotStatsProvider>(context, listen: false);
      await plotStatsProvider.fetchPlotStats();
      
      // Update counter animations with fetched data
      if (plotStatsProvider.hasPlotStats) {
        _updateCounterAnimations(
          plotStatsProvider.residentialCount,
          plotStatsProvider.commercialCount,
        );
        
        // Restart counter animation with new values
        _counterAnimationController.reset();
        _counterAnimationController.forward();
      } else {
        // Use fallback values and start counter animation
        _counterAnimationController.forward();
      }
    } catch (e) {
      print('Error fetching plot statistics: $e');
      // Use fallback values and start counter animation
      _counterAnimationController.forward();
    }
  }


  void _filterPropertiesByType(String type) {
    setState(() {
      _selectedPropertyType = type;
    });
    
    _applyFilters();
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedPropertyCategory = category;
    });
    
    _applyFilters();
  }

  void _filterByFilterType(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    
    // Navigate to search screen with the selected filter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyListingsScreen(),
        settings: RouteSettings(
          arguments: {
            'filter': filter,
            'propertyType': _selectedPropertyType,
            'location': _selectedLocation,
          },
        ),
      ),
    );
  }

  void _filterByLocation(String location) {
    setState(() {
      _selectedLocation = location;
      _showLocationDropdown = false;
    });
    
    _applyFilters();
  }

  void _applyFilters() {
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtering: $_selectedPropertyType $_selectedPropertyCategory in $_selectedLocation (${_selectedFilter})'),
        backgroundColor: const Color(0xFF1B5993),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Here you would typically:
    // 1. Call your backend API with all filter parameters
    // 2. Update the property list based on the response
    // 3. Refresh the UI with the filtered data
    // 4. Navigate to property listings screen with filters applied
  }

  void _clearAllFilters() {
    setState(() {
      _selectedPropertyType = 'Buy';
      _selectedPropertyCategory = '';
      _selectedFilter = '';
      _selectedLocation = '';
      _showLocationDropdown = false;
    });
    
    // Show clear confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All filters cleared successfully'),
        backgroundColor: const Color(0xFF20B2AA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePostPropertyTap() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn) {
      // User is logged in, navigate to ownership selection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OwnershipSelectionScreen(),
        ),
      );
    } else {
      // User is not logged in, navigate to login screen
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    // Show modern dialog to ask user to login
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B5993).withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF20B2AA).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B5993), // App theme color from second image
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Icon container
                      Container(
                        width: 64.w,
                        height: 64.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.w,
                          ),
                        ),
                        child: Icon(
                          AppIcons.lockOutlineRounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Login Required',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'You need to be logged in to post a property. Please login to continue.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF616161),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 32.h),
                      
                      // Action buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1.w,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(width: 12.w),
                          
                          // Login button
                          Expanded(
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5993), // App theme color from second image
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1B5993).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Navigate to login screen with animation
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
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
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        AppIcons.arrowForwardIos,
                                        color: Colors.white,
                                        size: 14,
                                      ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // Close location dropdown when tapping outside
            if (_showLocationDropdown) {
              setState(() {
                _showLocationDropdown = false;
              });
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: const SidebarDrawer(),
            body: SafeArea(
              child: Column(
                children: [
            // Simplified Header with Menu Only
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF1B5993), // Medium to dark blue border
                    width: 2.0.w,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Container(
                height: 56.h, // Fixed height for consistent centering
                child: Stack(
                  children: [
                    // Perfectly centered title using absolute positioning
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          l10n.home,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B5993),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    // Menu button positioned on the left
                    Positioned(
                      left: 16.w,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          child: Icon(
                            AppIcons.menu,
                            color: const Color(0xFF1B5993),
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Ad Banner
            AdBannerWidget(
              imagePath: 'assets/Ads/300x80.jpg',
              autoDismissDuration: const Duration(seconds: 2),
            ),
            
            // Main content area
                        Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Hero Section with Parallax
                    Container(
                      height: 0.12.sh,
                            child: Stack(
                              children: [
                          // Animated Background with Parallax
                          AnimatedBuilder(
                            animation: _parallaxAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _parallaxAnimation.value * 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF1B5993).withOpacity(0.1),
                                        const Color(0xFF20B2AA).withOpacity(0.05),
                                        Colors.white,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: _BackgroundPatternPainter(),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Hero Content
                          Center(
                            child: AnimatedBuilder(
                              animation: _heroAnimationController,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _heroFadeAnimation,
                                  child: SlideTransition(
                                    position: _heroSlideAnimation,
                                    child: ScaleTransition(
                                      scale: _heroScaleAnimation,
                child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                                          // DHA MARKETPLACE Text without Circle Background
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                                              // DHA Text with Premium Styling and Animation
                                              AnimatedBuilder(
                                                animation: _heroAnimationController,
                                                builder: (context, child) {
                                                  return Transform.scale(
                                                    scale: _heroScaleAnimation.value,
                                                    child: FadeTransition(
                                                      opacity: _heroFadeAnimation,
                                                      child: SlideTransition(
                                                        position: _heroSlideAnimation,
                                                        child: ShaderMask(
                                                          shaderCallback: (bounds) => const LinearGradient(
                                                            colors: [Color(0xFF1B5993), Color(0xFF1B5993)],
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                          ).createShader(bounds),
                                                          child: Text(
                                                            l10n.appTitle.split(' ')[0],
                                                            style: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 32.sp,
                                                              fontWeight: FontWeight.w900,
                                                              color: Colors.white,
                                                              letterSpacing: 2,
                                                              shadows: [
                                                                Shadow(
                                                                  color: const Color(0xFF1B5993).withOpacity(0.5),
                                                                  offset: Offset(0, 2.h),
                                                                  blurRadius: 4.r,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                               const SizedBox(height: 4),
                                               // MARKETPLACE Text with Gradient and Animation
                                              AnimatedBuilder(
                                                animation: _heroAnimationController,
                                                builder: (context, child) {
                                                  return Transform.scale(
                                                    scale: _heroScaleAnimation.value,
                                                    child: FadeTransition(
                                                      opacity: _heroFadeAnimation,
                                                      child: SlideTransition(
                                                        position: _heroSlideAnimation,
                                                        child: ShaderMask(
                                                          shaderCallback: (bounds) => const LinearGradient(
                                                            colors: [Color(0xFF20B2AA), Color(0xFF1B5993)],
                                                            begin: Alignment.centerLeft,
                                                            end: Alignment.centerRight,
                                                          ).createShader(bounds),
                                                          child: Text(
                                                            l10n.appTitle.split(' ')[1],
                                                            style: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 18.sp,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.white,
                                                              letterSpacing: 1.5,
                                                              shadows: [
                                                                Shadow(
                                                                  color: const Color(0xFF20B2AA).withOpacity(0.5),
                                                                  offset: Offset(0, 1.h),
                                                                  blurRadius: 2.r,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                            ],
                          ),
                                          
                        ],
                      ),
                            ),
                          ),
                        );
                      },
                            ),
                          ),
                        ],
                      ),
                                ),
                    
                    // Residential and Commercial Details Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Consumer<PlotStatsProvider>(
                            builder: (context, plotStatsProvider, child) {
                              // Get plot statistics with fallback values
                              final stats = plotStatsProvider.getPlotStatsWithFallback();
                              
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildPropertyTypeCard(
                                      l10n.residentialProperties,
                                      stats['residential'].toString(),
                                      l10n.propertiesCount,
                                      AppIcons.apartment,
                                      const Color(0xFF20B2AA),
                                      animation: _residentialCounterAnimation,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildPropertyTypeCard(
                                      l10n.commercialProperties,
                                      stats['commercial'].toString(),
                                      l10n.propertiesCount,
                                      AppIcons.business,
                                      const Color(0xFF1B5993),
                                      animation: _commercialCounterAnimation,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Premium Feature Cards Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            child: Column(
                              children: [
                          // Plot Finder Card
                          AnimatedBuilder(
                            animation: _cardAnimationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _cardFadeAnimation,
                                child: SlideTransition(
                                  position: _cardSlideAnimation,
                                  child: ScaleTransition(
                                    scale: _cardScaleAnimation,
                                    child: _buildPremiumFeatureCard(
                                      title: l10n.plotFinder,
                                      subtitle: l10n.interactiveSocietyMaps,
                                      description: l10n.plotsCount,
                                      buttonText: l10n.tryItNow,
                                      icon: AppIcons.mapOutlined,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      onTap: () {
                                        if (widget.onNavigateToProjects != null) {
                                          widget.onNavigateToProjects!();
                                        } else {
                                          // Fallback to default navigation if callback is not provided
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ProjectsScreenInstant()),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          SizedBox(height: 6.h),
                          
                          // Post Property Card
                          AnimatedBuilder(
                            animation: _cardAnimationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _cardFadeAnimation,
                                child: SlideTransition(
                                  position: _cardSlideAnimation,
                                  child: ScaleTransition(
                                    scale: _cardScaleAnimation,
                                    child: _buildPremiumFeatureCard(
                                      title: l10n.postYourProperty,
                                      subtitle: l10n.sellOrRentOut,
                                      description: l10n.reachBuyers,
                                      buttonText: l10n.postAnAd,
                                      icon: AppIcons.addHomeWorkOutlined,
                                gradient: const LinearGradient(
                                        colors: [Color(0xFF20B2AA), Color(0xFF1B5993)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                      onTap: () {
                                        _handlePostPropertyTap();
                                      },
                            ),
                            ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // New Projects section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                              Text(
                            'GALLERY',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Project cards
                    SizedBox(
                      height: 150.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          return _buildProjectCard(index);
                        },
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
                ],
              ),
            ),
          ),
        ),
        
        // Image Modal
        if (_showImageModal)
          _buildImageModal(),
      ],
    );
  }

  Widget _buildPropertyTypeTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => _filterByCategory(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF20B2AA).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
                              fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => _filterByFilterType(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF20B2AA).withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          title,
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



  Widget _buildPremiumFeatureCard({
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                  Text(
                          buttonText,
                          style: const TextStyle(
                      fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          AppIcons.arrowForwardRounded,
                          color: Colors.white,
                          size: 16,
                  ),
                ],
              ),
            ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 36,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeCard(String title, String count, String subtitle, IconData icon, Color color, {Animation<double>? animation}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          AnimatedBuilder(
            animation: animation ?? const AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              return Text(
                animation != null ? animation!.value.round().toString() : count,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(int index) {
    final projects = [
      {
        'title': 'DHA Phase 4 Entrance',
        'description': 'Iconic entrance gate with modern architecture',
        'badge': 'Featured',
        'badgeColor': Colors.orange,
        'category': 'Infrastructure',
        'categoryColor': Color(0xFF1B5993),
        'image': 'assets/gallery/dha-gate-night.jpg',
      },
      {
        'title': 'DHA Medical Center',
        'description': 'State-of-the-art healthcare facility',
        'badge': 'Healthcare',
        'badgeColor': Colors.green,
        'category': '',
        'categoryColor': Colors.transparent,
        'image': 'assets/gallery/dha-medical-center.jpg',
      },
      {
        'title': 'Commercial Hub',
        'description': 'Aerial view of the circular commercial center',
        'badge': 'Featured',
        'badgeColor': Colors.orange,
        'category': 'Commercial',
        'categoryColor': Colors.purple,
        'image': 'assets/gallery/dha-commercial-center.jpg',
      },
      {
        'title': 'Sports Complex',
        'description': 'Modern football grounds with night lighting',
        'badge': 'Recreation',
        'badgeColor': Colors.orange,
        'category': '',
        'categoryColor': Colors.transparent,
        'image': 'assets/gallery/dha-sports-facility.jpg',
      },
      {
        'title': 'Grand Mosque',
        'description': 'Beautifully illuminated mosque with golden dome',
        'badge': 'Featured',
        'badgeColor': Colors.orange,
        'category': 'Religious',
        'categoryColor': Color(0xFF20B2AA),
        'image': 'assets/gallery/dha-mosque-night.jpg',
      },
      {
        'title': 'Imperial Hall',
        'description': 'Modern community center and event venue',
        'badge': 'Community',
        'badgeColor': Colors.pink,
        'category': '',
        'categoryColor': Colors.transparent,
        'image': 'assets/gallery/imperial-hall.jpg',
      },
      {
        'title': 'Community Park',
        'description': 'Illuminated recreational area with walking paths',
        'badge': 'Recreation',
        'badgeColor': Colors.orange,
        'category': '',
        'categoryColor': Colors.transparent,
        'image': 'assets/gallery/dha-park-night.jpg',
      },
    ];
    
    final project = projects[index];
    
    return GestureDetector(
      onTap: () {
        // Show image modal instead of navigating to marketplace
        setState(() {
          _selectedImagePath = project['image'] as String;
          _selectedImageTitle = project['title'] as String;
          _showImageModal = true;
        });
      },
      child: Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Image
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: CachedAssetImage(
                    assetPath: project['image'] as String,
                    width: double.infinity,
                    height: 80.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF20B2AA).withOpacity(0.15),
                              const Color(0xFF1B5993).withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            AppIcons.work,
                            color: const Color(0xFF1B5993),
                            size: 40.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Eye icon for image modal (now redundant but kept for visual consistency)
                Positioned(
                  bottom: 8.h,
                  right: 8.w,
                  child: Icon(
                    AppIcons.visibility,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
                if (project['badge'] != null)
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                          color: project['badgeColor'] as Color,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                          project['badge'] as String,
                        style: TextStyle(
                              fontFamily: 'Inter',
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                if (project['category'] != null && project['category'].toString().isNotEmpty)
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                          color: project['categoryColor'] as Color,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                          project['category'] as String,
                        style: TextStyle(
                              fontFamily: 'Inter',
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (project['category'] == null || project['category'].toString().isEmpty)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImagePath = project['image'] as String;
                            _selectedImageTitle = project['title'] as String;
                            _showImageModal = true;
                          });
                        },
                        child: Icon(
                          AppIcons.visibility,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    project['title'] as String,
                  style: TextStyle(
                              fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                    project['description'] as String,
                  style: TextStyle(
                              fontFamily: 'Inter',
                    fontSize: 9.sp,
                    color: Colors.grey[600],
                    height: 1.2,
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

  // Image Modal with zoom functionality and blurry background
  Widget _buildImageModal() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.4),
        child: Stack(
          children: [
            // Blurry background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CachedAssetImage(
                          assetPath: _selectedImagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 300.w,
                              height: 200.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    AppIcons.brokenImage,
                                    color: Colors.grey[400],
                                    size: 48.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Image not found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 50.h,
              right: 20.w,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showImageModal = false;
                    _selectedImagePath = '';
                    _selectedImageTitle = '';
                  });
                },
                child: Icon(
                  AppIcons.close,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
            
            // Image title
            Positioned(
              bottom: 50.h,
              left: 20.w,
              right: 20.w,
              child: Text(
                _selectedImageTitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Zoom instructions
            Positioned(
              bottom: 100.h,
              left: 20.w,
              right: 20.w,
              child: Text(
                'Pinch to zoom • Double tap to reset',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF20B2AA).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw subtle geometric patterns
    final path = Path();
    
    // Create flowing curves
    for (int i = 0; i < 5; i++) {
      final y = (size.height / 5) * i;
      path.moveTo(0, y);
      path.quadraticBezierTo(
        size.width * 0.3,
        y + 20,
        size.width * 0.6,
        y,
      );
      path.quadraticBezierTo(
        size.width * 0.8,
        y - 10,
        size.width,
        y + 10,
      );
    }
    
    canvas.drawPath(path, paint);
    
    // Add some dots
    final dotPaint = Paint()
      ..color = const Color(0xFF1B5993).withOpacity(0.03)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i;
      final y = (size.height / 10) * (i % 10);
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
