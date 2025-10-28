import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'property_type_pricing_screen.dart';
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

  String? _selectedPurpose; // 'sell' or 'rent'
  bool _isProcessing = false;

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
          mainAxisSize: MainAxisSize.min,
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
              'PROPERTY PURPOSE',
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
                                    'Purpose',
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
                            'Choose Your Property Purpose',
                            style: AppTheme.headingMedium,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Select whether you want to sell or rent your property',
                            style: AppTheme.bodyLarge,
                          ),
                  ],
                ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Purpose Selection Card
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
                                // Purpose Label
                                Text(
                                  'Select Property Purpose',
                                  style: AppTheme.titleMedium,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Sell Option
                                GestureDetector(
                                  onTap: () => setState(() => _selectedPurpose = 'sell'),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: _selectedPurpose == 'sell' 
                                          ? const Color(0xFF1B5993).withValues(alpha: 0.1)
                                          : AppTheme.inputBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedPurpose == 'sell' 
                                            ? const Color(0xFF1B5993)
                                            : AppTheme.borderGrey,
                                        width: _selectedPurpose == 'sell' ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: _selectedPurpose == 'sell' 
                                                ? const Color(0xFF1B5993)
                                                : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Icon(
                                            Icons.sell,
                                            color: _selectedPurpose == 'sell' 
                                                ? Colors.white
                                                : Colors.grey[600],
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Sell Property',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: _selectedPurpose == 'sell' 
                                                      ? const Color(0xFF1B5993)
                                                      : AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'List your property for sale',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_selectedPurpose == 'sell')
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF1B5993),
                                            size: 24,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Rent Option
                                GestureDetector(
                                  onTap: () => setState(() => _selectedPurpose = 'rent'),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: _selectedPurpose == 'rent' 
                                          ? const Color(0xFF1B5993).withValues(alpha: 0.1)
                                          : AppTheme.inputBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedPurpose == 'rent' 
                                            ? const Color(0xFF1B5993)
                                            : AppTheme.borderGrey,
                                        width: _selectedPurpose == 'rent' ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: _selectedPurpose == 'rent' 
                                                ? const Color(0xFF1B5993)
                                                : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Icon(
                                            Icons.home_work,
                                            color: _selectedPurpose == 'rent' 
                                                ? Colors.white
                                                : Colors.grey[600],
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Rent Property',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: _selectedPurpose == 'rent' 
                                                      ? const Color(0xFF1B5993)
                                                      : AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'List your property for rent',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_selectedPurpose == 'rent')
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF1B5993),
                                            size: 24,
                                          ),
                                      ],
                                    ),
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
                                    
                                    // Continue Button
                                    Expanded(
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _selectedPurpose != null 
                                              ? const Color(0xFF1B5993) // Navy blue background
                                              : Colors.grey[400],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _selectedPurpose != null 
                                                ? const Color(0xFF1B5993) // Navy blue border
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed: _selectedPurpose != null && !_isProcessing ? _continueToNextStep : null,
                                          style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _isProcessing
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white, // White color
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      'Continue',
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
                                        'Choose "Sell" if you want to sell your property permanently, or "Rent" if you want to rent it out. You can change this later in your property settings.',
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


  void _continueToNextStep() async {
    if (_selectedPurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a property purpose'),
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
      _isProcessing = true;
    });

    try {
      // Show success message briefly then navigate
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
                  'Purpose selected! Proceeding to property details...',
                  style: const TextStyle(
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

      // Navigate to Property Type & Pricing Screen after brief delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PropertyTypePricingScreen(
              selectedPurpose: _selectedPurpose!,
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
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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