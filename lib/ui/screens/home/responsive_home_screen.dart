import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/language_service.dart';
import '../../../screens/property_listings_screen.dart';
import '../../../screens/projects_screen_instant.dart';
import '../../../screens/ownership_selection_screen.dart';
import '../../../ui/screens/auth/login_screen.dart';
import '../../../ui/widgets/cached_asset_image.dart';
import '../../../providers/plot_stats_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/responsive/responsive_breakpoints.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../ui/widgets/responsive/responsive_container.dart';
import '../../../ui/widgets/responsive/responsive_text.dart';
import '../../../ui/widgets/responsive/responsive_grid.dart';

/// Responsive HomeScreen that adapts to all device sizes
class ResponsiveHomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProjects;
  
  const ResponsiveHomeScreen({super.key, this.onNavigateToProjects});

  @override
  State<ResponsiveHomeScreen> createState() => _ResponsiveHomeScreenState();
}

class _ResponsiveHomeScreenState extends State<ResponsiveHomeScreen>
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
      'gradient': [Color(0xFF20B2AA), Color(0xFF1B5993)],
    },
    {
      'title': 'DHA Phase 2',
      'subtitle': 'Modern Residential Plots',
      'gradient': [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
    },
    {
      'title': 'DHA Phase 3',
      'subtitle': 'Luxury Living Standards',
      'gradient': [Color(0xFF1B5993), Color(0xFF1B5993)],
    },
    {
      'title': 'DHA Phase 4',
      'subtitle': 'Well-Planned Community',
      'gradient': [Color(0xFF27AE60), Color(0xFF2ECC71)],
    },
  ];

  final List<String> _dhaPhases = [
    'Phase 1', 'Phase 2', 'Phase 3', 'Phase 4',
    'Phase 5', 'Phase 6', 'Phase 7', 'Phase 8',
  ];

  final List<String> _filterOptions = [
    'Popular', 'Type', 'Location', 'Area Size',
    'Price Range', 'New Listings',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchPlotStatsAndStartAnimations();
  }

  void _initializeAnimations() {
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
    
    // Initialize animations
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
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut),
    );
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOutCubic));
    
    _parallaxAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _parallaxController, curve: Curves.easeInOut),
    );
    
    _initializeCounterAnimations();
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

  void _initializeCounterAnimations() {
    _residentialCounterAnimation = Tween<double>(begin: 0.0, end: 75.0).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
    
    _commercialCounterAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
  }

  void _updateCounterAnimations(int residentialCount, int commercialCount) {
    _residentialCounterAnimation = Tween<double>(begin: 0.0, end: residentialCount.toDouble()).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
    
    _commercialCounterAnimation = Tween<double>(begin: 0.0, end: commercialCount.toDouble()).animate(
      CurvedAnimation(parent: _counterAnimationController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _fetchPlotStatsAndStartAnimations() async {
    _heroAnimationController.forward();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _textAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 900), () {
      _parallaxController.forward();
    });
    
    try {
      final plotStatsProvider = Provider.of<PlotStatsProvider>(context, listen: false);
      await plotStatsProvider.fetchPlotStats();
      
      if (plotStatsProvider.hasPlotStats) {
        _updateCounterAnimations(
          plotStatsProvider.residentialCount,
          plotStatsProvider.commercialCount,
        );
        _counterAnimationController.reset();
        _counterAnimationController.forward();
      } else {
        _counterAnimationController.forward();
      }
    } catch (e) {
      print('Error fetching plot statistics: $e');
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
  }

  void _clearAllFilters() {
    setState(() {
      _selectedPropertyType = 'Buy';
      _selectedPropertyCategory = '';
      _selectedFilter = '';
      _selectedLocation = '';
      _showLocationDropdown = false;
    });
    
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OwnershipSelectionScreen(),
        ),
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ResponsiveContainer(
            mobileWidth: 0.95,
            tabletWidth: 0.8,
            desktopWidth: 0.6,
            backgroundColor: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5993).withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLoginDialogHeader(),
                _buildLoginDialogContent(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginDialogHeader() {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(context),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 48, mobile: 56, tablet: 64, desktop: 72),
            height: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 48, mobile: 56, tablet: 64, desktop: 72),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 24, mobile: 28, tablet: 32, desktop: 36),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
          ResponsiveHeading(
            'Login Required',
            level: 2,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginDialogContent() {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        children: [
          ResponsiveBodyText(
            'You need to be logged in to post a property. Please login to continue.',
            textAlign: TextAlign.center,
            color: const Color(0xFF616161),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 2),
          
          Row(
            children: [
              Expanded(
                child: _buildCancelButton(),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
              Expanded(
                child: _buildLoginButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      height: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 40, mobile: 44, tablet: 48, desktop: 52),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
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
        child: ResponsiveText(
          'Cancel',
          mobileFontSize: 14,
          tabletFontSize: 16,
          desktopFontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF757575),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 40, mobile: 44, tablet: 48, desktop: 52),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
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
            ResponsiveText(
              'Login',
              mobileFontSize: 14,
              tabletFontSize: 16,
              desktopFontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context) * 0.5),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 12, mobile: 14, tablet: 16, desktop: 18),
              ),
            ),
          ],
        ),
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
              _buildResponsiveHeader(l10n),
              Expanded(
                child: _buildResponsiveContent(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1B5993),
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
      child: SafeArea(
        child: Container(
          height: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 48, mobile: 52, tablet: 56, desktop: 60),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ResponsiveHeading(
                    l10n.home,
                    level: 2,
                    color: const Color(0xFF1B5993),
                  ),
                ),
              ),
              Positioned(
                left: ResponsiveHelper.getResponsiveSpacing(context),
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: Icon(
                      Icons.menu,
                      color: const Color(0xFF1B5993),
                      size: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 20, mobile: 22, tablet: 24, desktop: 26),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResponsiveHeroSection(l10n),
          _buildResponsiveStatsSection(l10n),
          _buildResponsiveFeatureCards(l10n),
          _buildResponsiveProjectsSection(l10n),
        ],
      ),
    );
  }

  Widget _buildResponsiveHeroSection(AppLocalizations l10n) {
    final heroHeight = ResponsiveHelper.getResponsiveHeight(
      context,
      mobileSmall: 0.15,
      mobile: 0.18,
      mobileLarge: 0.2,
      tablet: 0.22,
      desktop: 0.25,
    );

    return Container(
      height: heroHeight,
      child: Stack(
        children: [
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
                          ResponsiveHeading(
                            l10n.appTitle.split(' ')[0],
                            level: 1,
                            color: const Color(0xFF1B5993),
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 0.5),
                          ResponsiveHeading(
                            l10n.appTitle.split(' ')[1],
                            level: 3,
                            color: const Color(0xFF20B2AA),
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
    );
  }

  Widget _buildResponsiveStatsSection(AppLocalizations l10n) {
    return ResponsiveContainer(
      mobileWidth: 0.95,
      tabletWidth: 0.9,
      desktopWidth: 0.8,
      mobilePadding: const EdgeInsets.all(12),
      tabletPadding: const EdgeInsets.all(16),
      desktopPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
      child: Consumer<PlotStatsProvider>(
        builder: (context, plotStatsProvider, child) {
          final stats = plotStatsProvider.getPlotStatsWithFallback();
          
          return Row(
            children: [
              Expanded(
                child: _buildResponsivePropertyTypeCard(
                  l10n.residentialProperties,
                  stats['residential'].toString(),
                  l10n.propertiesCount,
                  Icons.home,
                  const Color(0xFF20B2AA),
                  animation: _residentialCounterAnimation,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
              Expanded(
                child: _buildResponsivePropertyTypeCard(
                  l10n.commercialProperties,
                  stats['commercial'].toString(),
                  l10n.propertiesCount,
                  Icons.business,
                  const Color(0xFF1B5993),
                  animation: _commercialCounterAnimation,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResponsivePropertyTypeCard(
    String title,
    String count,
    String subtitle,
    IconData icon,
    Color color, {
    Animation<double>? animation,
  }) {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context) * 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 32, mobile: 36, tablet: 40, desktop: 44),
            height: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 32, mobile: 36, tablet: 40, desktop: 44),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 16, mobile: 18, tablet: 20, desktop: 22),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 0.5),
          AnimatedBuilder(
            animation: animation ?? const AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              return ResponsiveHeading(
                animation != null ? animation!.value.round().toString() : count,
                level: 3,
                color: color,
              );
            },
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 0.25),
          ResponsiveText(
            title,
            mobileFontSize: 10,
            tabletFontSize: 12,
            desktopFontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 0.25),
          ResponsiveCaption(
            subtitle,
            color: Colors.grey[600],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveFeatureCards(AppLocalizations l10n) {
    return ResponsivePadding(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _cardAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _cardFadeAnimation,
                child: SlideTransition(
                  position: _cardSlideAnimation,
                  child: ScaleTransition(
                    scale: _cardScaleAnimation,
                    child: _buildResponsiveFeatureCard(
                      title: l10n.plotFinder,
                      subtitle: l10n.interactiveSocietyMaps,
                      description: l10n.plotsCount,
                      buttonText: l10n.tryItNow,
                      icon: Icons.map_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        if (widget.onNavigateToProjects != null) {
                          widget.onNavigateToProjects!();
                        } else {
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
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 0.5),
          
          AnimatedBuilder(
            animation: _cardAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _cardFadeAnimation,
                child: SlideTransition(
                  position: _cardSlideAnimation,
                  child: ScaleTransition(
                    scale: _cardScaleAnimation,
                    child: _buildResponsiveFeatureCard(
                      title: l10n.postYourProperty,
                      subtitle: l10n.sellOrRentOut,
                      description: l10n.reachBuyers,
                      buttonText: l10n.postAnAd,
                      icon: Icons.add_home_work_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF20B2AA), Color(0xFF1B5993)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: _handlePostPropertyTap,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveFeatureCard({
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
        padding: ResponsiveHelper.getResponsivePadding(context),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                  ResponsiveHeading(
                    title,
                    level: 3,
                    color: Colors.white,
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 0.5),
                  ResponsiveBodyText(
                    subtitle,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 0.25),
                  ResponsiveCaption(
                    description,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsiveSpacing(context),
                      vertical: ResponsiveHelper.getResponsiveSpacing(context) * 0.5,
                    ),
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
                        ResponsiveText(
                          buttonText,
                          mobileFontSize: 10,
                          tabletFontSize: 12,
                          desktopFontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context) * 0.5),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 12, mobile: 14, tablet: 16, desktop: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
            Container(
              width: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 60, mobile: 70, tablet: 80, desktop: 90),
              height: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 60, mobile: 70, tablet: 80, desktop: 90),
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
                size: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 28, mobile: 32, tablet: 36, desktop: 40),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveProjectsSection(AppLocalizations l10n) {
    return ResponsivePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveHeading(
                l10n.newProjects,
                level: 3,
                color: Colors.black,
              ),
              ResponsiveText(
                l10n.viewAll,
                mobileFontSize: 12,
                tabletFontSize: 14,
                desktopFontSize: 16,
                color: const Color(0xFF1B5993),
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
          ResponsiveHorizontalList(
            children: List.generate(7, (index) => _buildResponsiveProjectCard(index)),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveProjectCard(int index) {
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProjectsScreenInstant()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context) * 0.8),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
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
            Container(
              height: ResponsiveHelper.getResponsiveHeight(context, mobileSmall: 0.12, mobile: 0.14, tablet: 0.16, desktop: 0.18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ResponsiveHelper.getResponsiveBorderRadius(context) * 0.8),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(ResponsiveHelper.getResponsiveBorderRadius(context) * 0.8),
                    ),
                    child: CachedAssetImage(
                      assetPath: project['image'] as String,
                      width: double.infinity,
                      height: double.infinity,
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
                              Icons.home_work,
                              color: const Color(0xFF1B5993),
                              size: ResponsiveHelper.getResponsiveIconSize(context, mobileSmall: 32, mobile: 36, tablet: 40, desktop: 44),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (project['badge'] != null)
                    Positioned(
                      top: ResponsiveHelper.getResponsiveSpacing(context) * 0.5,
                      left: ResponsiveHelper.getResponsiveSpacing(context) * 0.5,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveSpacing(context) * 0.5,
                          vertical: ResponsiveHelper.getResponsiveSpacing(context) * 0.25,
                        ),
                        decoration: BoxDecoration(
                          color: project['badgeColor'] as Color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ResponsiveCaption(
                          project['badge'] as String,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText(
                    project['title'] as String,
                    mobileFontSize: 10,
                    tabletFontSize: 12,
                    desktopFontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 0.25),
                  ResponsiveCaption(
                    project['description'] as String,
                    color: Colors.grey[600],
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
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF20B2AA).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    
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
