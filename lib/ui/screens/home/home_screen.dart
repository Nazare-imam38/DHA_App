import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/language_service.dart';
import '../../../screens/property_listings_screen.dart';
import '../../../screens/projects_screen_instant.dart';

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
  
  
  final List<Map<String, dynamic>> _carouselData = [
    {
      'title': 'DHA Phase 1',
      'subtitle': 'Premium Commercial Area',
      'gradient': [Color(0xFF20B2AA), Color(0xFF1E3C90)],
    },
    {
      'title': 'DHA Phase 2',
      'subtitle': 'Modern Residential Plots',
      'gradient': [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
    },
    {
      'title': 'DHA Phase 3',
      'subtitle': 'Luxury Living Standards',
      'gradient': [Color(0xFF1E3C90), Color(0xFF1E3C90)],
    },
    {
      'title': 'DHA Phase 4',
      'subtitle': 'Well-Planned Community',
      'gradient': [Color(0xFF27AE60), Color(0xFF2ECC71)],
    },
  ];

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
    
    // Counter Animations
    _residentialCounterAnimation = Tween<double>(begin: 0.0, end: 75.0).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
    
    _commercialCounterAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
    
    // Start animations with staggered timing
    _startAnimations();
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

  void _startAnimations() {
    // Start hero animation first
    _heroAnimationController.forward();
    
    // Start card animation after a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
    
    // Start text animation after cards
    Future.delayed(const Duration(milliseconds: 600), () {
      _textAnimationController.forward();
    });
    
    // Start counter animation with a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _counterAnimationController.forward();
    });
    
    // Start parallax animation
    _parallaxController.forward();
    
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
        backgroundColor: const Color(0xFF1E3C90),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    
    return GestureDetector(
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
        body: SafeArea(
        child: Column(
          children: [
            // Simplified Header with Menu Only
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                  child: Row(
                  children: [
                      // Menu button
                      GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: Container(
                          padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.menu,
                              color: Colors.white,
                            size: 24,
                          ),
                                  ),
                                ),
                                const Spacer(),
                      // App title
                                        Text(
                        l10n.home,
                                          style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                                      const Spacer(),
                                  ],
                                ),
                              ),
              ),
            ),
            
            // Main content area
                        Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Hero Section with Parallax
                    Container(
                      height: MediaQuery.of(context).size.height * 0.12,
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
                                        const Color(0xFF1E3C90).withOpacity(0.1),
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
                                                            colors: [Color(0xFF1E3C90), Color(0xFF1E3C90)],
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                          ).createShader(bounds),
                                                          child: Text(
                                                            l10n.appTitle.split(' ')[0],
                                                            style: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 32,
                                                              fontWeight: FontWeight.w900,
                                                              color: Colors.white,
                                                              letterSpacing: 2,
                                                              shadows: [
                                                                Shadow(
                                                                  color: const Color(0xFF1E3C90).withOpacity(0.5),
                                                                  offset: const Offset(0, 2),
                                                                  blurRadius: 4,
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
                                                            colors: [Color(0xFF20B2AA), Color(0xFF1E3C90)],
                                                            begin: Alignment.centerLeft,
                                                            end: Alignment.centerRight,
                                                          ).createShader(bounds),
                                                          child: Text(
                                                            l10n.appTitle.split(' ')[1],
                                                            style: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.white,
                                                              letterSpacing: 1.5,
                                                              shadows: [
                                                                Shadow(
                                                                  color: const Color(0xFF20B2AA).withOpacity(0.5),
                                                                  offset: const Offset(0, 1),
                                                                  blurRadius: 2,
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildPropertyTypeCard(
                                  l10n.residentialProperties,
                                  '75',
                                  l10n.propertiesCount,
                                  Icons.home,
                                  const Color(0xFF20B2AA),
                                  animation: _residentialCounterAnimation,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPropertyTypeCard(
                                  l10n.commercialProperties,
                                  '15',
                                  l10n.propertiesCount,
                                  Icons.business,
                                  const Color(0xFF1E3C90),
                                  animation: _commercialCounterAnimation,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Premium Feature Cards Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                      icon: Icons.map_outlined,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
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
                          
                          const SizedBox(height: 6),
                          
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
                                      icon: Icons.add_home_work_outlined,
                                gradient: const LinearGradient(
                                        colors: [Color(0xFF20B2AA), Color(0xFF1E3C90)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                      onTap: () {
                                        // Navigate to post property screen
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
                    
                    const SizedBox(height: 16),
                    
                    // New Projects section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.newProjects,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            l10n.viewAll,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: const Color(0xFF1E3C90),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Project cards
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return _buildProjectCard(index);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPropertyTypeTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => _filterByCategory(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
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
            colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
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
                        const Icon(
                          Icons.arrow_forward_rounded,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: animation ?? const AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              return Text(
                animation != null ? animation!.value.round().toString() : count,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
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
        'title': 'DHA Phase 8',
        'location': 'Lahore',
        'price': 'PKR 2.8-6.1 Cr',
        'badge': 'HOT',
        'badgeColor': Colors.red,
      },
      {
        'title': 'DHA NEO',
        'location': 'Lahore',
        'price': 'PKR 3.2-7.9 Cr',
        'badge': 'New',
        'badgeColor': Color(0xFF1E3C90),
      },
      {
        'title': 'DHA Commercial',
        'location': 'Karachi',
        'price': 'PKR 32.3L-2.24Cr',
        'badge': 'Verified',
        'badgeColor': Colors.green,
      },
    ];
    
    final project = projects[index];
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProjectsScreenInstant()),
        );
      },
      child: Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 80,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF20B2AA).withOpacity(0.15),
                    const Color(0xFF1E3C90).withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.home_work,
                    color: Color(0xFF1E3C90),
                    size: 40,
                  ),
                ),
                if (project['badge'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: project['badgeColor'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                          project['badge'] as String,
                        style: TextStyle(
                              fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        // Add to favorites
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${project['title']} added to favorites'),
                            backgroundColor: const Color(0xFF20B2AA),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Color(0xFF1E3C90),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    project['price'] as String,
                  style: TextStyle(
                              fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3C90),
                  ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                    project['title'] as String,
                  style: TextStyle(
                              fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project['location'] as String,
                      style: TextStyle(
                              fontFamily: 'Inter',
                        fontSize: 10,
                        color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
      ..color = const Color(0xFF1E3C90).withOpacity(0.03)
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
