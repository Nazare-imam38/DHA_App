import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../ui/screens/home/home_screen.dart';
import 'projects_screen_instant.dart';
import 'property_listings_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'sidebar_drawer.dart';
import '../providers/plots_provider.dart';
import '../ui/widgets/app_icons.dart';
import '../core/navigation/navigation_ad_observer.dart';
import '../ui/widgets/navigation_ad_banner.dart';

class MainWrapper extends StatefulWidget {
  final int initialTabIndex;
  const MainWrapper({super.key, this.initialTabIndex = 0});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Preload all screens to avoid white flash
  late List<Widget> _screens;
  
  // Ad banner state
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    
    // Check if ad should be shown after navigation
    _checkAdStatus();
    
    // Preload all screens
    _screens = [
      HomeScreen(onNavigateToProjects: () => _onTabTapped(1)),
      const ProjectsScreenInstant(),
      const PropertyListingsScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200), // Faster transition
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      // Check if ad should be shown after tab navigation
      _checkAdStatus();
      // No animation needed with IndexedStack - instant switch
    }
  }
  
  void _checkAdStatus() {
    // Use a small delay to ensure navigation observer has updated
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && NavigationAdObserver.shouldShowAd) {
        setState(() {
          _showAd = true;
        });
        NavigationAdObserver.markAdShown();
      }
    });
  }
  
  void _onAdDismiss() {
    if (mounted) {
      setState(() {
        _showAd = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      drawer: const SidebarDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Navigation Ad Banner Overlay - Centered on screen
          if (_showAd)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent backdrop
                child: Center(
                  child: SafeArea(
                    child: NavigationAdBanner(
                      imagePath: 'assets/Ads/375x400.jpg',
                      autoDismissDuration: const Duration(seconds: 3),
                      onDismiss: _onAdDismiss,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(l10n),
      floatingActionButton: _currentIndex == 0 
          ? _buildFloatingActionButton() 
          : null, // Explicitly set to null to remove FAB on all other screens including profile
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A651), Color(0xFF3498DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A651).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          _onTabTapped(1); // Navigate to Projects tab (index 1) which has the map
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(AppIcons.search, color: Colors.white),
      ),
    );
  }

  Widget _buildModernBottomNav(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1B5993), // Navy blue border
            width: 2.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: AppIcons.homeOutlined,
                activeIcon: AppIcons.home,
                label: l10n.home,
                index: 0,
                l10n: l10n,
              ),
              _buildNavItem(
                icon: AppIcons.homeWorkOutlined,
                activeIcon: AppIcons.homeWork,
                label: l10n.projects,
                index: 1,
                l10n: l10n,
              ),
              _buildNavItem(
                icon: AppIcons.searchOutlined,
                activeIcon: AppIcons.search,
                label: l10n.search,
                index: 2,
                l10n: l10n,
              ),
              _buildNavItem(
                icon: AppIcons.favoriteOutline,
                activeIcon: AppIcons.favorite,
                label: l10n.myBookings,
                index: 3,
                l10n: l10n,
              ),
              _buildNavItem(
                icon: AppIcons.personOutline,
                activeIcon: AppIcons.person,
                label: l10n.profile,
                index: 4,
                l10n: l10n,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required AppLocalizations l10n,
  }) {
    bool isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            gradient: isSelected ? const LinearGradient(
              colors: [Color(0xFF1B5993), Color(0xFF1B5993)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isSelected ? [
              BoxShadow(
                color: const Color(0xFF1B5993).withOpacity(0.3),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ] : null,
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: isSelected ? 22.sp : 20.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                              fontFamily: 'Inter',
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
