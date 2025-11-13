import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../services/call_service.dart';
import 'sidebar_drawer.dart';
import '../ui/widgets/app_icons.dart';
import '../core/theme/app_theme.dart';
import '../ui/widgets/cached_asset_image.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Expandable section states
  bool _isVisitOfficeExpanded = true;
  bool _isCallUsExpanded = true;
  bool _isEmailUsExpanded = true;
  bool _isWhyChooseExpanded = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMap() async {
    const String address = "Defence Ave, Sector A DHA Phase 1, Islamabad";
    final Uri uri = Uri.parse('https://maps.google.com/?q=$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      drawer: const SidebarDrawer(),
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Parallax Effect
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  AppIcons.arrowBackIos,
                  color: Colors.black87,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                  child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                            // DHA Logo
                            SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primaryBlue.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: CachedAssetImage(
                                  assetPath: 'assets/images/dhalogo.png',
                                  width: 60.w,
                                  height: 60.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                      Text(
                        l10n.contactUs,
                        style: TextStyle(
                          fontFamily: AppTheme.headingFont,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.getInTouchWithUs,
                        style: TextStyle(
                          fontFamily: AppTheme.primaryFont,
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                          ],
                        ),
                      ),
                    ),
                ),
              ),
            ),
            
            // Contact Cards Section
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Visit Our Office Card with Map
                  SlideTransition(
                    position: _slideAnimation,
                  child: _buildEnhancedContactCard(
                      icon: AppIcons.place,
                      title: l10n.visitOurOffice,
                      iconColor: AppTheme.primaryBlue,
                      isExpanded: _isVisitOfficeExpanded,
                      onToggle: () => setState(() => _isVisitOfficeExpanded = !_isVisitOfficeExpanded),
                      content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Office Info Header
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                child: Icon(
                                  AppIcons.business,
                                  color: AppTheme.primaryBlue,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DHA Islamabad Head Office',
                                      style: TextStyle(
                                        fontFamily: AppTheme.primaryFont,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Defence Ave, Sector A DHA Phase 1, Islamabad',
                                      style: TextStyle(
                                        fontFamily: AppTheme.primaryFont,
                                        fontSize: 14.sp,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Embedded Map
                        Container(
                          height: 200.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                            ),
                            boxShadow: AppTheme.lightShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: const LatLng(33.6844, 73.0479), // DHA Phase 1, Islamabad coordinates
                                initialZoom: 15.0,
                                minZoom: 10.0,
                                maxZoom: 18.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.dhamarketplace.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: const LatLng(33.6844, 73.0479),
                                      width: 60,
                                      height: 60,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryBlue.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          AppIcons.place,
                                          color: Colors.white,
                                          size: 30.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Action Button
                          GestureDetector(
                            onTap: _launchMap,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: AppTheme.tealAccent,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.tealAccent.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    AppIcons.directions,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Get Directions',
                                    style: TextStyle(
                                      fontFamily: AppTheme.primaryFont,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                SizedBox(height: 16.h),
                  
                  // Call Us Card
                  SlideTransition(
                    position: _slideAnimation,
                  child: _buildEnhancedContactCard(
                      icon: AppIcons.phone,
                      title: l10n.callUs,
                      iconColor: AppTheme.tealAccent,
                      isExpanded: _isCallUsExpanded,
                      onToggle: () => setState(() => _isCallUsExpanded = !_isCallUsExpanded),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Office
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppTheme.tealAccent.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(
                                color: AppTheme.tealAccent.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: AppTheme.lightShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.tealAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                    ),
                                    child: Icon(
                                      AppIcons.businessCenter,
                                      color: AppTheme.tealAccent,
                                      size: 22.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      l10n.mainOffice,
                                      style: TextStyle(
                                        fontFamily: AppTheme.primaryFont,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              GestureDetector(
                                onTap: () => CallService.showCallBottomSheet(context, '+92-51-111-555-400'),
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    border: Border.all(
                                      color: AppTheme.tealAccent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        AppIcons.phone,
                                        color: AppTheme.tealAccent,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        '+92-51-111-555-400',
                                        style: TextStyle(
                                          fontFamily: AppTheme.primaryFont,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.tealAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Extensions: 1223, 1381, 1244, 1606',
                                style: TextStyle(
                                  fontFamily: AppTheme.primaryFont,
                                  fontSize: 14.sp,
                                  color: AppTheme.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              ],
                            ),
                          ),
                        SizedBox(height: 16.h),
                          // Direct Lines
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: AppTheme.lightShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                      ),
                                      child: Icon(
                                        AppIcons.supportAgent,
                                        color: AppTheme.primaryBlue,
                                        size: 22.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        l10n.directLines,
                                        style: TextStyle(
                                          fontFamily: AppTheme.primaryFont,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                _buildEnhancedPhoneRow('Sales Executive', '0321-5081777', AppTheme.primaryBlue),
                                SizedBox(height: 12.h),
                                _buildEnhancedPhoneRow('Sales Executive', '0332-4305958', AppTheme.primaryBlue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                SizedBox(height: 16.h),
                  
                  // Email Us Card
                  SlideTransition(
                    position: _slideAnimation,
                  child: _buildEnhancedContactCard(
                      icon: AppIcons.email,
                      title: l10n.emailUs,
                      iconColor: AppTheme.primaryBlue,
                      isExpanded: _isEmailUsExpanded,
                      onToggle: () => setState(() => _isEmailUsExpanded = !_isEmailUsExpanded),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email Marketplace
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightBlue,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: AppTheme.lightShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                      ),
                                      child: Icon(
                                        AppIcons.store,
                                        color: AppTheme.primaryBlue,
                                        size: 22.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        l10n.emailMarketplace,
                                        style: TextStyle(
                                          fontFamily: AppTheme.primaryFont,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                GestureDetector(
                                  onTap: () => _launchEmail('info@dhamarketplace.com'),
                                  child: Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                      border: Border.all(
                                        color: AppTheme.primaryBlue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          AppIcons.email,
                                          color: AppTheme.primaryBlue,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            'info@dhamarketplace.com',
                                            style: TextStyle(
                                              fontFamily: AppTheme.primaryFont,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primaryBlue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                          // Business Hours
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightBlue,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: AppTheme.lightShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                      ),
                                      child: Icon(
                                        AppIcons.accessTime,
                                        color: AppTheme.primaryBlue,
                                        size: 22.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        l10n.businessHours,
                                        style: TextStyle(
                                          fontFamily: AppTheme.primaryFont,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                _buildBusinessHoursRow('Mon - Fri', '9:00 AM - 6:00 PM'),
                                SizedBox(height: 8.h),
                                _buildBusinessHoursRow('Saturday', '9:00 AM - 2:00 PM'),
                                SizedBox(height: 8.h),
                                _buildBusinessHoursRow('Sunday', 'Closed', isClosed: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                SizedBox(height: 32.h),
                  
                  // Why Choose DHA Marketplace Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with expand/collapse button
                          InkWell(
                            onTap: () => setState(() => _isWhyChooseExpanded = !_isWhyChooseExpanded),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
                            child: Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.whyChooseDhaMarketplace,
                                          style: TextStyle(
                                            fontFamily: AppTheme.headingFont,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          l10n.trustedPartnerForProperty,
                                          style: TextStyle(
                                            fontFamily: AppTheme.primaryFont,
                                            fontSize: 14.sp,
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  AnimatedRotation(
                                    turns: _isWhyChooseExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      AppIcons.keyboardArrowDown,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Expandable content
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: ClipRect(
                              child: _isWhyChooseExpanded
                                  ? Padding(
                                      padding: EdgeInsets.all(24.w),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: _buildEnhancedFeatureItem(AppIcons.security, l10n.secureTransactions, l10n.secureTransactionsDesc, AppTheme.primaryBlue)),
                                              SizedBox(width: 16.w),
                                              Expanded(child: _buildEnhancedFeatureItem(AppIcons.supportAgent, l10n.expertSupport, l10n.expertSupportDesc, AppTheme.tealAccent)),
                                            ],
                                          ),
                                          SizedBox(height: 16.h),
                                          Row(
                                            children: [
                                              Expanded(child: _buildEnhancedFeatureItem(AppIcons.locationCity, l10n.premiumLocations, l10n.premiumLocationsDesc, AppTheme.primaryBlue)),
                                              SizedBox(width: 16.w),
                                              Expanded(child: _buildEnhancedFeatureItem(AppIcons.speed, l10n.quickProcessing, l10n.quickProcessingDesc, AppTheme.tealAccent)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                SizedBox(height: 32.h),
                  
                // Call to Action Section - Simplified
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.readyToInvestInFuture,
                            style: TextStyle(
                              fontFamily: AppTheme.headingFont,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            l10n.joinThousandsOfInvestors,
                            style: TextStyle(
                              fontFamily: AppTheme.primaryFont,
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.h),
                          // Single action button to avoid overflow
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/properties');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryBlue,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(AppIcons.explore, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    l10n.exploreProperties,
                                    style: TextStyle(
                                      fontFamily: AppTheme.primaryFont,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                SizedBox(height: 16.h),
              ]),
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildEnhancedContactCard({
    required IconData icon,
    required String title,
    required Widget content,
    required Color iconColor,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse button
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
            child: Container(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTheme.headingFont,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      AppIcons.keyboardArrowDown,
                      color: iconColor,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ClipRect(
              child: isExpanded
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        bottom: 20.h,
                      ),
                      child: content,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPhoneRow(String label, String phoneNumber, Color color) {
    return GestureDetector(
      onTap: () => CallService.showCallBottomSheet(context, phoneNumber),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.phone,
              color: color,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.primaryFont,
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                phoneNumber,
                style: TextStyle(
                  fontFamily: AppTheme.primaryFont,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.6),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHoursRow(String day, String hours, {bool isClosed = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isClosed ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: isClosed ? Colors.grey[200]! : AppTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            day,
            style: TextStyle(
              fontFamily: AppTheme.primaryFont,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isClosed ? Colors.grey[600] : AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            hours,
            style: TextStyle(
              fontFamily: AppTheme.primaryFont,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isClosed ? Colors.grey[500] : AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFeatureItem(IconData icon, String title, String description, Color color) {
    return Container(
      height: 160.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTheme.primaryFont,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontFamily: AppTheme.primaryFont,
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
                height: 1.3,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}
