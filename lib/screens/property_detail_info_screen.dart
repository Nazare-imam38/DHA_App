import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/app_localizations.dart';
import '../services/whatsapp_service.dart';
import 'main_wrapper.dart';
import 'projects_screen_instant.dart';
import 'property_listings_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class PropertyDetailInfoScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailInfoScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailInfoScreen> createState() => _PropertyDetailInfoScreenState();
}

class _PropertyDetailInfoScreenState extends State<PropertyDetailInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: const Color(0xFF1B5993),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Property Image
                  Image.asset(
                    widget.property['image'] ?? 'assets/images/property_placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Property Info Overlay
                  Positioned(
                    bottom: 20.h,
                    left: 20.w,
                    right: 20.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Text(
                          widget.property['price'] ?? 'PKR 25,000,000',
                          style: GoogleFonts.inter(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Property Title
                        Text(
                          widget.property['title'] ?? 'Luxury Villa - Phase 1',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              widget.property['location'] ?? '${AppLocalizations.of(context)!.dhaPhase1}',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action Icons
                  Positioned(
                    top: 50.h,
                    right: 20.w,
                    child: Row(
                      children: [
                        _buildActionIcon(Icons.share, () {}),
                        SizedBox(width: 12.w),
                        _buildActionIcon(Icons.chat_bubble_outline, () {
                          _launchWhatsAppForProperty();
                        }),
                        SizedBox(width: 12.w),
                        _buildActionIcon(Icons.phone, () {}),
                      ],
                    ),
                  ),
                  // Available Tag
                  Positioned(
                    top: 50.h,
                    left: 20.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20B2AA),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.available,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Property Details Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFF1B5993),
                      labelColor: const Color(0xFF1B5993),
                      unselectedLabelColor: Colors.grey[600],
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(AppLocalizations.of(context)!.features, style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(AppLocalizations.of(context)!.location, style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(AppLocalizations.of(context)!.payment, style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab Content
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4, // Use percentage of screen height
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFeaturesTab(),
                        _buildLocationTab(),
                        _buildPaymentTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Features
          _buildFeatureSection(
            AppLocalizations.of(context)!.plotFeatures,
            Icons.square_foot,
            [
              AppLocalizations.of(context)!.electricity,
              AppLocalizations.of(context)!.sewerage,
              AppLocalizations.of(context)!.waterSupply,
              AppLocalizations.of(context)!.accessibleByRoad,
            ],
          ),
          SizedBox(height: 24.h),
          
          _buildFeatureSection(
            AppLocalizations.of(context)!.businessAndCommunication,
            Icons.business,
            [
              AppLocalizations.of(context)!.broadbandInternetAccess,
              AppLocalizations.of(context)!.satelliteOrCableTvReady,
            ],
          ),
          SizedBox(height: 24.h),
          
          _buildFeatureSection(
            AppLocalizations.of(context)!.nearbyFacilities,
            Icons.location_on,
            [
              AppLocalizations.of(context)!.nearbyHospitals,
              AppLocalizations.of(context)!.nearbyPublicTransportService,
              AppLocalizations.of(context)!.nearbyRestaurants,
              AppLocalizations.of(context)!.nearbySchools,
              AppLocalizations.of(context)!.nearbyShoppingMalls,
            ],
          ),
          SizedBox(height: 24.h),
          
          _buildFeatureSection(
            AppLocalizations.of(context)!.otherFacilities,
            Icons.more_horiz,
            [
              AppLocalizations.of(context)!.cctvSecurity,
              AppLocalizations.of(context)!.maintenanceStaff,
              AppLocalizations.of(context)!.securityStaff,
              AppLocalizations.of(context)!.petPolicyAllowed,
            ],
          ),
          SizedBox(height: 20.h), // Add bottom padding to prevent overflow
        ],
      ),
    );
  }

  Widget _buildFeatureSection(String title, IconData icon, List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF1B5993), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5993),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...features.map((feature) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: const Color(0xFF20B2AA),
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  feature,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildLocationTab() {
    // Default coordinates for DHA Phase 1, Islamabad (better for DHA properties)
    final defaultLocation = LatLng(33.5348, 73.0951);
    final propertyLocation = widget.property['coordinates'] != null 
        ? LatLng(
            widget.property['coordinates']['lat'] ?? defaultLocation.latitude,
            widget.property['coordinates']['lng'] ?? defaultLocation.longitude,
          )
        : defaultLocation;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.location,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B5993),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Interactive Map
          Container(
            height: 400.h, // Increased height for better map visibility
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                children: [
                  FlutterMap(
                options: MapOptions(
                  initialCenter: propertyLocation,
                  initialZoom: 12.0, // Reduced zoom to show more area
                  minZoom: 8.0, // Allow zooming out more
                  maxZoom: 18.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      LatLng(33.0, 72.5), // Southwest corner
                      LatLng(34.0, 73.5), // Northeast corner
                    ),
                  ),
                ),
                children: [
                  // OpenStreetMap tiles with better configuration
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.dha.marketplace',
                    maxZoom: 18,
                    minZoom: 8,
                    tileProvider: NetworkTileProvider(),
                    errorTileCallback: (tile, error, stackTrace) {
                      print('Tile error: $error');
                    },
                  ),
                  
                  // Property marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: propertyLocation,
                        width: 50.w,
                        height: 50.h,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5993),
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(color: Colors.white, width: 4.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Map attribution
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      margin: EdgeInsets.all(8.w),
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Location Details
          Text(
            AppLocalizations.of(context)!.propertyLocationDetails,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.property['location'] ?? 'Located in the heart of ${AppLocalizations.of(context)!.dhaPhase1}, this property offers excellent connectivity to major areas of the city.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Nearby Amenities
          Text(
            AppLocalizations.of(context)!.nearbyAmenities,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Amenities Grid
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildAmenityChip(AppLocalizations.of(context)!.hospitals, Icons.local_hospital),
              _buildAmenityChip(AppLocalizations.of(context)!.schools, Icons.school),
              _buildAmenityChip(AppLocalizations.of(context)!.shopping, Icons.shopping_cart),
              _buildAmenityChip(AppLocalizations.of(context)!.restaurants, Icons.restaurant),
              _buildAmenityChip(AppLocalizations.of(context)!.transport, Icons.directions_bus),
              _buildAmenityChip(AppLocalizations.of(context)!.parks, Icons.park),
            ],
          ),
          SizedBox(height: 20.h), // Add bottom padding to prevent overflow
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5993).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF1B5993).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: const Color(0xFF1B5993),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1B5993),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Plan Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5993),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.monthlyInstallments,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'PKR 47,500',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.monthly,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'PKR 95,000',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.monthly,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          
          // Payment Details
          _buildPaymentDetail(AppLocalizations.of(context)!.downPayment, 'PKR 520,000'),
          _buildPaymentDetail(AppLocalizations.of(context)!.totalCost, 'PKR 1,200,000'),
          _buildPaymentDetail(AppLocalizations.of(context)!.finalPayment, 'PKR 3,999,999'),
          SizedBox(height: 16.h),
          
          // Additional Charges
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.additionalCharges,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Addition Rs. 100,000/- For West Open & Road Facing',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.orange[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Addition Rs. 200,000/- For Corner & Park Facing',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          
          // Contact Information
          _buildContactSection(),
          SizedBox(height: 20.h), // Add bottom padding to prevent overflow
        ],
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B5993),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.contactInformation,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B5993),
            ),
          ),
          SizedBox(height: 12.h),
          _buildContactItem(AppLocalizations.of(context)!.bookingOffice, '+92 21 1234567'),
          _buildContactItem(AppLocalizations.of(context)!.siteOffice, '+92 21 7654321'),
          _buildContactItem(AppLocalizations.of(context)!.salesCentre, '+92 21 9876543'),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String number) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B5993),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1B5993),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Action Buttons
            Container(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF20B2AA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFF20B2AA)),
                      ),
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.info_outline, color: const Color(0xFF20B2AA), size: 14.sp),
                        label: Text(
                          AppLocalizations.of(context)!.getMoreInfo,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF20B2AA),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5993),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.phone, color: Colors.white, size: 14.sp),
                        label: Text(
                          AppLocalizations.of(context)!.call,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _launchWhatsAppForProperty();
                      },
                      icon: Icon(Icons.chat, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
            // Navigation Bar
            Container(
              height: 60.h,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: l10n.home,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.home_work_outlined,
                activeIcon: Icons.home_work,
                label: l10n.projects,
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: l10n.search,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite,
                label: l10n.myBookings,
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: l10n.profile,
                index: 4,
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    // Only highlight the Search tab (index 2) as it's the active one
    bool isSelected = index == 2;
    
    return GestureDetector(
      onTap: () => _navigateToTab(index),
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
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: isSelected ? 22.sp : 20.sp,
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

  void _navigateToTab(int index) {
    // Navigate back to main wrapper with the selected tab
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainWrapper(initialTabIndex: index),
      ),
      (route) => false,
    );
  }

  void _launchWhatsAppForProperty() {
    WhatsAppService.launchWhatsAppForProperty(
      phoneNumber: WhatsAppService.defaultContactNumber,
      propertyTitle: widget.property['title'] ?? 'Property',
      propertyPrice: widget.property['price'] ?? 'Price not available',
      propertyLocation: widget.property['location'] ?? 'Location not available',
      context: context,
    );
  }
}

