import 'package:flutter/material.dart';
import 'property_details_form_screen.dart';
import 'ms_otp_verification_screen.dart';
import '../services/ms_verification_service.dart';
import '../core/theme/app_theme.dart';

class MSVerificationScreen extends StatefulWidget {
  const MSVerificationScreen({super.key});

  @override
  State<MSVerificationScreen> createState() => _MSVerificationScreenState();
}

class _MSVerificationScreenState extends State<MSVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _msNumberController = TextEditingController();
  bool _isVerifying = false;
  bool _isQuickActionsExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _msNumberController.dispose();
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
            color: Color(0xFF1B5993), // Blue color
            size: 16, // Smaller size
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Text(
              'MS VERIFICATION',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
            const SizedBox(height: 20),
            
            // Step Indicator
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                            child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F4FD),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF1B5993).withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1B5993),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MS Number Verification',
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ],
                    ),
                  ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Main Title
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                          Text(
                            'Verify Your MS Number',
                            style: AppTheme.headingMedium,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Enter your DHA membership number to verify property ownership',
                            style: AppTheme.bodyLarge,
                    ),
                  ],
                ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Main Form Card
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppTheme.paddingLarge),
                            decoration: BoxDecoration(
                              color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.borderGrey,
                      width: 1,
                    ),
                              boxShadow: AppTheme.lightShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Input Label
                                Text(
                                  'DHA Membership Number (MS)',
                                  style: AppTheme.titleMedium,
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Input Field
                                Container(
                                  decoration: BoxDecoration(
                          color: AppTheme.inputBackground,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    border: Border.all(
                            color: AppTheme.borderGrey,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _msNumberController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontFamily: AppTheme.primaryFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter Your MS Number',
                                      hintStyle: const TextStyle(
                                        fontFamily: AppTheme.primaryFont,
                                        fontSize: 16,
                                        color: AppTheme.textLight,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.paddingMedium,
                                        vertical: AppTheme.paddingMedium,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Purpose explanation
                                Text(
                                  'This number is used to verify your property ownership',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    height: 1.3,
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
                                            color: const Color(0xFF1B5993),
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
                                                color: const Color(0xFF1B5993),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Back',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF1B5993),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // Verify Button
                                    Expanded(
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF1B5993),
                                            width: 2,
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed: _isVerifying ? null : _verifyMSNumber,
                                          style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _isVerifying
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B5993)),
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.verified_user,
                                                      color: Color(0xFF1B5993),
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      'Verify MS',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF1B5993),
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
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Help Section
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                      color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                          color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.help_outline,
                                    color: Color(0xFF1B5993),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Need Help?',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1B5993),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Your MS number can be found on your DHA membership card or property documents. If you\'re having trouble finding it, please contact DHA support.',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                  ),
                ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
            // Quick Actions Section
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with expand/collapse
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isQuickActionsExpanded = !_isQuickActionsExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B5993),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Quick Actions & Support',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B5993),
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _isQuickActionsExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF1B5993),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expandable content
                      if (_isQuickActionsExpanded) ...[
                        const Divider(color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      icon: Icons.phone_in_talk_rounded,
                                      title: 'Call Support',
                                      onTap: () => _callSupport(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      icon: Icons.email_rounded,
                                      title: 'Email Support',
                                      onTap: () => _emailSupport(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      icon: Icons.help_outline_rounded,
                                      title: 'FAQ',
                                      onTap: () => _showFAQ(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      icon: Icons.credit_card_rounded,
                                      title: 'Find MS Number',
                                      onTap: () => _showMSNumberHelp(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGrey,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderGrey,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              title,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _verifyMSNumber() async {
    if (_msNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your MS number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Verify MS number with backend
      final msService = MSVerificationService();
      final response = await msService.verifyMSNumber(_msNumberController.text.trim());
      
      if (!response.isValid) {
        setState(() {
          _isVerifying = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid MS number. Please check and try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      setState(() {
        _isVerifying = false;
      });

      // Show success message briefly then navigate automatically
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
              const Expanded(
                child: Text(
                  'MS Number verified successfully! Proceeding to OTP verification...',
          style: TextStyle(
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
          duration: const Duration(seconds: 1),
        ),
      );

      // Navigate to MS OTP Verification Screen after brief delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MSOtpVerificationScreen(
              msNumber: _msNumberController.text.trim(),
              email: response.email ?? 'member@dha.gov.pk',
              phoneNumber: response.phoneNumber ?? '+92 300 1234567',
            ),
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
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _callSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Call DHA Support',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Contact DHA Support Team:\n\n📞 Main Line: +92-21-111-342-111\n📞 MS Verification: +92-21-111-342-222\n📞 Property Listing: +92-21-111-342-333\n\nAvailable 24/7 for your convenience.',
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

  void _emailSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Email Support',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Send your query to DHA Support:\n\n📧 General: support@dha.gov.pk\n📧 MS Issues: ms-verification@dha.gov.pk\n📧 Property Listing: property@dha.gov.pk\n\nWe respond within 2-4 hours during business hours.',
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

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: SingleChildScrollView(
          child: const Text(
            'Common MS Verification Questions:\n\nQ: Where can I find my MS number?\nA: Check your DHA membership card or property documents.\n\nQ: What if I don\'t have an MS number?\nA: Contact DHA support to verify your membership status.\n\nQ: How long does verification take?\nA: Usually 2-5 minutes for valid MS numbers.\n\nQ: What if verification fails?\nA: Double-check your MS number or contact support.\n\nQ: Can I use someone else\'s MS number?\nA: No, you must use your own valid MS number.',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
            ),
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

  void _showMSNumberHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Finding Your MS Number',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Where to find your MS number:\n\n• DHA Membership Card (front side)\n• Property Ownership Documents\n• DHA Portal Account\n• Previous DHA correspondence\n• Contact DHA office if lost\n\nMS number format: Usually 6-8 digits',
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
}