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
            color: Color(0xFF1B5993), // Navy blue color
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
                color: Color(0xFF1B5993), // Navy blue color
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
                                  color: const Color(0xFF20B2AA).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF20B2AA),
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
                                      color: Color(0xFF20B2AA),
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
                                            color: const Color(0xFF1B5993), // Navy blue border
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
                                                color: const Color(0xFF1B5993), // Navy blue color
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Back',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF1B5993), // Navy blue color
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
                                          color: const Color(0xFF1B5993), // Navy blue background
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF1B5993), // Navy blue border
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
                                                      color: Colors.white, // White color
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      'Verify MS',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white, // White color
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
                                    color: Color(0xFF20B2AA),
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
                                          color: Color(0xFF20B2AA),
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
                          
            // Quick Actions Section - REMOVED COMPLETELY
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
              backgroundColor: const Color(0xFF1B5993), // Navy blue background
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

}