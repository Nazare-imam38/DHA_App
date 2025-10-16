import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'property_details_form_screen.dart';
import '../services/ms_verification_service.dart';
import '../core/theme/app_theme.dart';

class MSOtpVerificationScreen extends StatefulWidget {
  final String msNumber;
  final String email;
  final String phoneNumber;

  const MSOtpVerificationScreen({
    super.key,
    required this.msNumber,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<MSOtpVerificationScreen> createState() => _MSOtpVerificationScreenState();
}

class _MSOtpVerificationScreenState extends State<MSOtpVerificationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 0;
  bool _isQuickActionsExpanded = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startResendTimer();
    _sendInitialOtp();
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
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
    });
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendTimer--;
        });
        return _resendTimer > 0;
      }
      return false;
    });
  }

  Future<void> _sendInitialOtp() async {
    try {
      final msService = MSVerificationService();
      await msService.sendMSOtp(widget.msNumber);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP sent successfully to your registered email and phone'),
            backgroundColor: const Color(0xFF1B5993),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: ${e.toString()}'),
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

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      final otpCode = _getOtpCode();
      if (otpCode.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter complete OTP code'),
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
        _isLoading = true;
      });

      try {
        // Verify OTP with backend
        final msService = MSVerificationService();
        await msService.verifyMSOtp(widget.msNumber, otpCode);

        if (mounted) {
          // Show success message
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
                      'MS Number verified successfully!',
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
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to Property Details Form
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const PropertyDetailsFormScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
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
  }

  Future<void> _resendOtp() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Resend OTP via backend
      final msService = MSVerificationService();
      await msService.resendMSOtp(widget.msNumber);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP sent successfully to your registered email and phone'),
            backgroundColor: const Color(0xFF1B5993),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
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
              'OTP VERIFICATION',
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
              child: Form(
                key: _formKey,
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              const SizedBox(height: 20),
              
              // Main Title
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text(
                            'Verify MS Number',
                        style: TextStyle(
                          fontFamily: 'Inter',
                              fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5993),
                          height: 1.2,
                            ),
                          ),
                      
                          const SizedBox(height: 8),
                      
                          Text(
                            'Enter the OTP sent to your registered email and phone',
                        style: TextStyle(
                          fontFamily: 'Inter',
                              fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                  ),
                      ),
                    ),
                    
              const SizedBox(height: 32),
                    
              // MS Number Information Card
                    SlideTransition(
                      position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                      child: Container(
                    width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_card_rounded,
                              color: const Color(0xFF1B5993),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                            const Text(
                                  'MS Number:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                color: Color(0xFF1B5993),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.msNumber,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5993),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.email_rounded,
                              color: const Color(0xFF20B2AA),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.email,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                              color: const Color(0xFF20B2AA),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.phoneNumber,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: Colors.grey[600],
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
                    
                    const SizedBox(height: 32),
                    
                    // OTP Input Section
                    SlideTransition(
                      position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                        child: Container(
                    width: double.infinity,
                          padding: const EdgeInsets.all(24),
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
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        const Text(
                                'Enter OTP Code',
                          style: TextStyle(
                            fontFamily: 'Inter',
                                  fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B5993),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'We sent a 6-digit code to your registered email and phone number',
                          style: TextStyle(
                            fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Colors.grey[600],
                            height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // OTP Input Fields
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 45,
                                    height: 55,
                                    decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _focusNodes[index].hasFocus
                                      ? const Color(0xFF1B5993)
                                      : const Color(0xFFE0E0E0),
                                        width: 2,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _otpControllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5993),
                                      ),
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          if (index < 5) {
                                            _focusNodes[index + 1].requestFocus();
                                          } else {
                                            _focusNodes[index].unfocus();
                                          }
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    ),
                                  );
                                }),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Verify Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1B5993),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: const Color(0xFF1B5993),
                                        width: 2,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF1B5993),
                                            strokeWidth: 2,
                                          ),
                                        )
                                : const Text(
                                          'Verify OTP',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                            fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B5993),
                                          ),
                                        ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Resend OTP
                              Center(
                                child: TextButton(
                                  onPressed: _resendTimer > 0 || _isResending ? null : _resendOtp,
                                  child: _isResending
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                      color: Color(0xFF1B5993),
                                          ),
                                        )
                                      : Text(
                                          _resendTimer > 0
                                              ? 'Resend OTP in ${_resendTimer}s'
                                              : 'Resend OTP',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _resendTimer > 0
                                                ? Colors.grey[400]
                                          : const Color(0xFF1B5993),
                                          ),
                                        ),
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
                                              icon: Icons.arrow_back_rounded,
                                              title: 'Back to MS Entry',
                                              onTap: () => Navigator.pop(context),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF1B5993),
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5993),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
          'Contact DHA Support Team:\n\n📞 Main Line: +92-21-111-342-111\n📞 OTP Issues: +92-21-111-342-222\n📞 Property Listing: +92-21-111-342-333\n\nAvailable 24/7 for your convenience.',
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
          'Send your query to DHA Support:\n\n📧 General: support@dha.gov.pk\n📧 OTP Issues: otp-support@dha.gov.pk\n📧 Property Listing: property@dha.gov.pk\n\nWe respond within 2-4 hours during business hours.',
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
            'Common OTP Verification Questions:\n\nQ: How long is the OTP valid?\nA: OTP is valid for 10 minutes.\n\nQ: What if I don\'t receive the OTP?\nA: Check your email spam folder or try resending.\n\nQ: Can I use the same OTP multiple times?\nA: No, each OTP can only be used once.\n\nQ: What if OTP verification fails?\nA: Double-check the code or request a new one.\n\nQ: How many times can I resend OTP?\nA: You can resend up to 3 times per hour.',
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
}
