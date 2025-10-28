import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'property_details_form_screen.dart';
import '../core/theme/app_theme.dart';

class PropertyTypePricingScreen extends StatefulWidget {
  final String selectedPurpose; // 'sell' or 'rent'
  
  const PropertyTypePricingScreen({
    super.key,
    required this.selectedPurpose,
  });

  @override
  State<PropertyTypePricingScreen> createState() => _PropertyTypePricingScreenState();
}

class _PropertyTypePricingScreenState extends State<PropertyTypePricingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedPropertyType; // 'residential' or 'commercial'
  String? _selectedListingDuration; // '15', '30', or '60'
  
  // Pricing controllers
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  
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
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _rentAmountController.dispose();
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
                Icons.category,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Text(
              'PROPERTY TYPE & PRICING',
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
                              '3',
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
                          'Type & Pricing',
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
                      'Property Type & Pricing Details',
                      style: AppTheme.headingMedium,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Select your property type and set pricing information',
                      style: AppTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Property Type Selection Card
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
                      // Property Type Label
                      Text(
                        'Select Property Type',
                        style: AppTheme.titleMedium,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Residential Option
                      GestureDetector(
                        onTap: () => setState(() => _selectedPropertyType = 'residential'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _selectedPropertyType == 'residential' 
                                ? const Color(0xFF1B5993).withValues(alpha: 0.1)
                                : AppTheme.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPropertyType == 'residential' 
                                  ? const Color(0xFF1B5993)
                                  : AppTheme.borderGrey,
                              width: _selectedPropertyType == 'residential' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _selectedPropertyType == 'residential' 
                                      ? const Color(0xFF1B5993)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Icon(
                                  Icons.apartment,
                                  color: _selectedPropertyType == 'residential' 
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
                                      'Residential',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedPropertyType == 'residential' 
                                            ? const Color(0xFF1B5993)
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Houses, apartments, and residential plots',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedPropertyType == 'residential')
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
                      
                      // Commercial Option
                      GestureDetector(
                        onTap: () => setState(() => _selectedPropertyType = 'commercial'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _selectedPropertyType == 'commercial' 
                                ? const Color(0xFF1B5993).withValues(alpha: 0.1)
                                : AppTheme.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPropertyType == 'commercial' 
                                  ? const Color(0xFF1B5993)
                                  : AppTheme.borderGrey,
                              width: _selectedPropertyType == 'commercial' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _selectedPropertyType == 'commercial' 
                                      ? const Color(0xFF1B5993)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: _selectedPropertyType == 'commercial' 
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
                                      'Commercial',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedPropertyType == 'commercial' 
                                            ? const Color(0xFF1B5993)
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Offices, shops, and commercial plots',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedPropertyType == 'commercial')
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1B5993),
                                  size: 24,
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
            
            const SizedBox(height: 24),
            
            // Pricing Section
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
                      Text(
                        widget.selectedPurpose == 'sell' ? 'Selling Price Range' : 'Rental Amount',
                        style: AppTheme.titleMedium,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      if (widget.selectedPurpose == 'sell') ...[
                        // Min Price Field
                        _buildPriceField(
                          controller: _minPriceController,
                          label: 'Minimum Price (PKR)',
                          hint: 'Enter minimum selling price',
                          icon: Icons.attach_money,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Max Price Field
                        _buildPriceField(
                          controller: _maxPriceController,
                          label: 'Maximum Price (PKR)',
                          hint: 'Enter maximum selling price',
                          icon: Icons.attach_money,
                        ),
                      ] else ...[
                        // Rent Amount Field
                        _buildPriceField(
                          controller: _rentAmountController,
                          label: 'Monthly Rent Amount (PKR)',
                          hint: 'Enter monthly rental amount',
                          icon: Icons.attach_money,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Listing Duration Section
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
                      Text(
                        'Listing Duration',
                        style: AppTheme.titleMedium,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'How long do you want to list your property?',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Duration Options
                      Row(
                        children: [
                          Expanded(
                            child: _buildDurationOption('15', '15 Days'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDurationOption('30', '30 Days'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDurationOption('60', '60 Days'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
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
                          color: _canContinue() 
                              ? const Color(0xFF1B5993) // Navy blue background
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _canContinue() 
                                ? const Color(0xFF1B5993) // Navy blue border
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: TextButton(
                          onPressed: _canContinue() && !_isProcessing ? _continueToNextStep : null,
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
                              widget.selectedPurpose == 'sell' 
                                  ? 'Set competitive price ranges to attract buyers. You can adjust these later based on market response.'
                                  : 'Set a fair rental amount based on market rates. Consider location, size, and amenities when pricing.',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderGrey,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[500],
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF1B5993),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationOption(String value, String label) {
    bool isSelected = _selectedListingDuration == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedListingDuration = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF1B5993).withValues(alpha: 0.1)
              : AppTheme.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF1B5993)
                : AppTheme.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? const Color(0xFF1B5993)
                    : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value == '15' ? 'Quick listing' : value == '30' ? 'Standard' : 'Extended',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canContinue() {
    if (_selectedPropertyType == null || _selectedListingDuration == null) {
      return false;
    }
    
    if (widget.selectedPurpose == 'sell') {
      return _minPriceController.text.isNotEmpty && _maxPriceController.text.isNotEmpty;
    } else {
      return _rentAmountController.text.isNotEmpty;
    }
  }

  void _continueToNextStep() async {
    if (!_canContinue()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
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
                  'Details saved! Proceeding to property information...',
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

      // Navigate to Property Details Form after brief delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
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
