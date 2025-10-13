import 'package:flutter/material.dart';
import 'ms_verification_screen.dart';

class OwnershipSelectionScreen extends StatefulWidget {
  const OwnershipSelectionScreen({super.key});

  @override
  State<OwnershipSelectionScreen> createState() => _OwnershipSelectionScreenState();
}

class _OwnershipSelectionScreenState extends State<OwnershipSelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedOption;
  bool _isLoading = false;
  bool _showQuickActions = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _expandController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _expandAnimation;

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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
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

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
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
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE8F4FD),
              Color(0xFFF0F8FF),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.home_work_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                        'OWNERSHIP SELECTION',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Main Question with Animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Who owns this property?',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B5993),
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Instructions with modern styling
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xCCFFFFFF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0x1A1B5993),
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0D1B5993),
                                    blurRadius: 20,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Please select whether you are listing your own property or listing on behalf of someone else.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF616161),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Selection Options with Modern Cards
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // My Own Property Option
                            _buildModernOptionCard(
                              context: context,
                              title: 'My Own Property',
                              subtitle: 'I am the owner of this property',
                              icon: Icons.home_rounded,
                              isSelected: _selectedOption == 'own',
                              onTap: () => _selectOption('own'),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // On Behalf of Someone Else Option
                            _buildModernOptionCard(
                              context: context,
                              title: 'On Behalf of Someone Else',
                              subtitle: 'I am listing this property for someone else',
                              icon: Icons.people_rounded,
                              isSelected: _selectedOption == 'behalf',
                              onTap: () => _selectOption('behalf'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    
                    const SizedBox(height: 30),
                    
                    // Collapsible Quick Actions Section
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Toggle Button for Quick Actions
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showQuickActions = !_showQuickActions;
                                  if (_showQuickActions) {
                                    _expandController.forward();
                                  } else {
                                    _expandController.reverse();
                                  }
                                });
                              },
                        child: Container(
                          width: double.infinity,
                                padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4D1E3C90),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                      'Quick Actions & Resources',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: _showQuickActions ? 0.5 : 0.0,
                                      duration: const Duration(milliseconds: 300),
                                            child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                              color: Colors.white,
                                        size: 24,
                                            ),
                                          ),
                                        ],
                        ),
                      ),
                    ),
                    
                            // Collapsible Content
                            AnimatedBuilder(
                              animation: _expandAnimation,
                              builder: (context, child) {
                                return SizeTransition(
                                  sizeFactor: _expandAnimation,
                      child: FadeTransition(
                                    opacity: _expandAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                                    // First Row - Main Actions
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionButton(
                                    icon: Icons.info_outline_rounded,
                                    title: 'Property Info',
                                    subtitle: 'Learn about requirements',
                                    onTap: () => _showPropertyInfo(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionButton(
                                    icon: Icons.help_outline_rounded,
                                    title: 'Get Help',
                                    subtitle: 'Contact support',
                                    onTap: () => _showHelpDialog(),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                                    // Second Row - Documentation
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionButton(
                                    icon: Icons.document_scanner_rounded,
                                    title: 'Documents',
                                    subtitle: 'Required documents',
                                    onTap: () => _showDocumentsInfo(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionButton(
                                    icon: Icons.schedule_rounded,
                                    title: 'Timeline',
                                    subtitle: 'Process duration',
                                    onTap: () => _showTimelineInfo(),
                                  ),
                                ),
                              ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Third Row - Additional Features
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildQuickActionButton(
                                            icon: Icons.calculate_rounded,
                                            title: 'Fee Calculator',
                                            subtitle: 'Estimate listing fees',
                                            onTap: () => _showFeeCalculator(),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildQuickActionButton(
                                            icon: Icons.trending_up_rounded,
                                            title: 'Market Trends',
                                            subtitle: 'Property values',
                                            onTap: () => _showMarketTrends(),
                                          ),
                            ),
                          ],
                        ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Fourth Row - Support & Legal
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildQuickActionButton(
                                            icon: Icons.phone_in_talk_rounded,
                                            title: 'Call Support',
                                            subtitle: 'Direct phone line',
                                            onTap: () => _callSupport(),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildQuickActionButton(
                                            icon: Icons.gavel_rounded,
                                            title: 'Legal Info',
                                            subtitle: 'Terms & conditions',
                                            onTap: () => _showLegalInfo(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent
                : const Color(0x1A1B5993),
            width: 2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x4D1B5993),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Color(0x331B5993),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x141B5993),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Modern Icon Container with Glassmorphism
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color(0x4DFFFFFF),
                          Color(0x1AFFFFFF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [
                          Color(0x1A1B5993),
                          Color(0x0D20B2AA),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0x4DFFFFFF)
                      : const Color(0x1A1B5993),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? const Color(0x33FFFFFF)
                        : const Color(0x1A1B5993),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF1B5993),
                size: 32,
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Text Content with Better Typography
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF1B5993),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? const Color(0xE6FFFFFF)
                          : const Color(0xFF757575),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Modern Selection Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x4D4CAF50),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    )
                  : const Icon(
                      Icons.radio_button_unchecked_rounded,
                      color: Color(0xFFBDBDBD),
                      size: 24,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
    
    // Trigger scale animation for selection feedback
    _scaleController.reset();
    _scaleController.forward();
    
    // Automatically navigate after a brief delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _handleContinue();
      }
    });
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0x1A1E3C90),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x141E3C90),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3C90),
                    Color(0xFF2C5AA0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3C90),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPropertyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Property Information',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3C90),
          ),
        ),
        content: const Text(
          'To list a property on DHA Marketplace, you need to:\n\n• Be the legal owner or have written authorization\n• Have valid property documents\n• Complete MS number verification\n• Provide accurate property details',
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Need Help?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3C90),
          ),
        ),
        content: const Text(
          'Contact DHA Support:\n\n📞 Phone: +92-21-111-342-111\n📧 Email: support@dha.gov.pk\n🌐 Website: www.dha.gov.pk\n\nOur support team is available 24/7 to assist you.',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDocumentsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Required Documents',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3C90),
          ),
        ),
        content: const Text(
          'You will need the following documents:\n\n• DHA Membership Card\n• Property Ownership Documents\n• CNIC/NICOP\n• Property Photos\n• NOC (if applicable)\n• Any other relevant documents',
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

  void _showTimelineInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Process Timeline',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3C90),
          ),
        ),
        content: const Text(
          'Expected timeline for property listing:\n\n• Ownership Selection: 1-2 minutes\n• MS Verification: 2-5 minutes\n• Property Details: 10-15 minutes\n• Review & Submit: 5-10 minutes\n\nTotal: 20-30 minutes',
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

  void _showFeeCalculator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Listing Fee Calculator',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3C90),
          ),
        ),
        content: const Text(
          'DHA Marketplace Listing Fees:\n\n• Basic Listing: PKR 2,500\n• Premium Listing: PKR 5,000\n• Featured Listing: PKR 10,000\n• Verification Fee: PKR 1,000\n• Processing Fee: PKR 500\n\nTotal estimated cost: PKR 3,000 - 11,500',
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

  void _showMarketTrends() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Property Market Trends',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3C90),
          ),
        ),
        content: const Text(
          'Current DHA Property Trends:\n\n• Average price increase: 8-12% annually\n• High demand areas: Phase 2, Phase 5\n• Popular property types: 3-4 bedroom houses\n• Average listing time: 2-4 weeks\n• Market activity: Peak season Oct-Mar',
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

  void _callSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Call DHA Support',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3C90),
          ),
        ),
        content: const Text(
          'Contact DHA Support Team:\n\n📞 Main Line: +92-21-111-342-111\n📞 Property Listing: +92-21-111-342-333\n📞 Technical Support: +92-21-111-342-444\n\nAvailable 24/7 for your convenience.',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLegalInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Legal Information',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3C90),
          ),
        ),
        content: const Text(
          'Important Legal Terms:\n\n• You must be the legal owner or have written authorization\n• All property information must be accurate and truthful\n• DHA reserves the right to verify all claims\n• Listing fees are non-refundable\n• Terms and conditions apply to all listings',
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

  Future<void> _handleContinue() async {
    if (_selectedOption == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call with realistic delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _isLoading = false;
    });
    
    // Navigate to next step with modern feedback
    if (mounted) {
      // Show modern success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedOption == 'own' 
                      ? 'Proceeding with your own property'
                      : 'Proceeding on behalf of someone else',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1B5993),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Continue',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to MS Verification screen
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const MSVerificationScreen(),
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
          ),
        ),
      );
    }
  }
}