import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import 'sidebar_drawer.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const SidebarDrawer(),
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Parallax Effect
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
        backgroundColor: const Color(0xFF1E3C90),
        elevation: 0,
        leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative background elements
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Main content
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                  child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                            // Animated icon
                            SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.contact_phone,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                      Text(
                        l10n.contactUs,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                          color: Colors.white,
                                letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.getInTouchWithUs,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.white70,
                                fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                          ],
                        ),
                      ),
                    ),
                    ],
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
                      icon: Icons.location_on,
                      title: l10n.visitOurOffice,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                      content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Office Info Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1E3C90).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3C90).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.business,
                                  color: Color(0xFF1E3C90),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DHA Islamabad Head Office',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                                    const SizedBox(height: 4),
                          Text(
                                      'Defence Ave, Sector A DHA Phase 1, Islamabad',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Embedded Map
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1E3C90).withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
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
                                          color: const Color(0xFF1E3C90),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF1E3C90).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 30,
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF20B2AA), Color(0xFF17a2b8)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF20B2AA).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              ),
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                  Icons.directions,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                  Text(
                                  'Get Directions',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                    fontSize: 15,
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
                  
                const SizedBox(height: 16),
                  
                  // Call Us Card
                  SlideTransition(
                    position: _slideAnimation,
                  child: _buildEnhancedContactCard(
                      icon: Icons.phone,
                      title: l10n.callUs,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Office
                          Container(
                          padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.business_center,
                                      color: Color(0xFF10B981),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                  l10n.mainOffice,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => _launchPhone('+92-51-111-555-400'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF10B981).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Color(0xFF10B981),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                    '+92-51-111-555-400',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                                Text(
                                'Extensions: 1223, 1381, 1244, 1606',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                  fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                          // Direct Lines
                          Container(
                          padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF3E8FF), Color(0xFFFAF5FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.support_agent,
                                      color: Color(0xFF8B5CF6),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                  l10n.directLines,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildEnhancedPhoneRow('Sales Executive', '0321-5081777', const Color(0xFF8B5CF6)),
                              const SizedBox(height: 12),
                              _buildEnhancedPhoneRow('Sales Executive', '0332-4305958', const Color(0xFF8B5CF6)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 16),
                  
                  // Email Us Card
                  SlideTransition(
                    position: _slideAnimation,
                  child: _buildEnhancedContactCard(
                      icon: Icons.email,
                      title: l10n.emailUs,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email Marketplace
                          Container(
                          padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEFF6FF), Color(0xFFF0F9FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF1E3C90).withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3C90).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3C90).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.store,
                                      color: Color(0xFF1E3C90),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                  l10n.emailMarketplace,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => _launchEmail('info@dhamarketplace.com'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF1E3C90).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.email,
                                        color: Color(0xFF1E3C90),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                  child: Text(
                                    'info@dhamarketplace.com',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E3C90),
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
                        const SizedBox(height: 16),
                          // Business Hours
                          Container(
                          padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF0EA5E9).withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.access_time,
                                      color: Color(0xFF0EA5E9),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                  l10n.businessHours,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildBusinessHoursRow('Mon - Fri', '9:00 AM - 6:00 PM'),
                              const SizedBox(height: 8),
                              _buildBusinessHoursRow('Saturday', '9:00 AM - 2:00 PM'),
                              const SizedBox(height: 8),
                              _buildBusinessHoursRow('Sunday', 'Closed', isClosed: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 32),
                  
                  // Why Choose DHA Marketplace Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                    padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFFAFAFA)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.whyChooseDhaMarketplace,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.trustedPartnerForProperty,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                          Row(
                            children: [
                            Expanded(child: _buildEnhancedFeatureItem(Icons.security, l10n.secureTransactions, l10n.secureTransactionsDesc, const Color(0xFF1E3C90))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildEnhancedFeatureItem(Icons.support_agent, l10n.expertSupport, l10n.expertSupportDesc, const Color(0xFF10B981))),
                          ],
                        ),
                        const SizedBox(height: 20),
                          Row(
                            children: [
                            Expanded(child: _buildEnhancedFeatureItem(Icons.location_city, l10n.premiumLocations, l10n.premiumLocationsDesc, const Color(0xFF8B5CF6))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildEnhancedFeatureItem(Icons.speed, l10n.quickProcessing, l10n.quickProcessingDesc, const Color(0xFFF59E0B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 32),
                  
                // Call to Action Section - Simplified
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                    padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3C90).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.readyToInvestInFuture,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.joinThousandsOfInvestors,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        // Single action button to avoid overflow
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/properties');
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3C90),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.explore, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                    l10n.exploreProperties,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                    fontSize: 16,
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
                  
                const SizedBox(height: 16),
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
    required Gradient gradient,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildEnhancedPhoneRow(String label, String phoneNumber, Color color) {
    return GestureDetector(
      onTap: () => _launchPhone(phoneNumber),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
      children: [
            Icon(
              Icons.phone,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
                fontSize: 13,
            color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
            Expanded(
          child: Text(
            phoneNumber,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.6),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHoursRow(String day, String hours, {bool isClosed = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isClosed ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isClosed ? Colors.grey[200]! : const Color(0xFF0EA5E9).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            day,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isClosed ? Colors.grey[600] : const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          Text(
            hours,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isClosed ? Colors.grey[500] : const Color(0xFF0EA5E9),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildEnhancedFeatureItem(IconData icon, String title, String description, Color color) {
    return Container(
      height: 160, // Fixed height for all cards
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 56,
            height: 56,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
              color: color,
              size: 28,
          ),
        ),
          const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
        ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
          description,
          style: const TextStyle(
            fontFamily: 'Inter',
                fontSize: 12,
            color: Color(0xFF6B7280),
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

  Color _getFeatureColor(IconData icon) {
    switch (icon) {
      case Icons.security:
        return const Color(0xFF2563EB);
      case Icons.support_agent:
        return const Color(0xFF20B2AA);
      case Icons.location_city:
        return const Color(0xFF7C3AED);
      case Icons.speed:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
