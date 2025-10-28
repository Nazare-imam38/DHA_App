import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5993), // Navy blue color
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.work_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
                        'OWNERSHIP SELECTION',
                        style: TextStyle(
                fontFamily: 'Inter',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5993), // Navy blue color
                letterSpacing: 0.5,
                              ),
            ),
          ],
        ),
        centerTitle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0.h),
          child: Container(
            height: 2.0.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5993), // Navy blue border
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
                padding: EdgeInsets.all(24.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    
            // Process Indicator
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ownership Selection',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF20B2AA),
                        ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main Question
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
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                                color: Color(0xFF1B5993), // Navy blue color
                        height: 1.2,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                    // Instructions Card
                            Container(
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
                    
            // Selection Options
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // My Own Property Option
                    _buildOptionCard(
                              title: 'My Own Property',
                              subtitle: 'I am the owner of this property',
                              icon: Icons.home_rounded,
                              isSelected: _selectedOption == 'own',
                              onTap: () => _selectOption('own'),
                            ),
                            
                    const SizedBox(height: 16),
                            
                            // On Behalf of Someone Else Option
                    _buildOptionCard(
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
                    
            const SizedBox(height: 40),
            
            // Continue Button
            if (_selectedOption != null)
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF20B2AA),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: const Color(0xFF20B2AA),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B5993)),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 20,
                                  color: Color(0xFF20B2AA),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedOption == 'own' 
                                      ? 'PROCEED with your own property'
                                      : 'PROCEED on behalf of someone else',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
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
            
            const SizedBox(height: 20),
            
            // Quick Actions Section - REMOVED COMPLETELY
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, // Always white background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF20B2AA) : const Color(0xFFE0E0E0), // Teal border when selected
            width: 2,
          ),
          boxShadow: [
                  BoxShadow(
              color: isSelected 
                  ? const Color(0xFF20B2AA).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF20B2AA).withValues(alpha: 0.1) : const Color(0xFF1B5993).withValues(alpha: 0.1), // Teal background when selected, navy blue when not
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF20B2AA) : const Color(0xFF1B5993), // Teal when selected, navy blue when not
                size: 28,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF20B2AA) : const Color(0xFF1B5993), // Teal when selected, navy blue when not
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF616161), // Gray for both selected and unselected
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : const Color(0xFFBDBDBD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF20B2AA),
                      size: 16,
                    )
                  : null,
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
  }


  Future<void> _handleContinue() async {
    if (_selectedOption == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _isLoading = false;
    });
    
    // Navigate to next step
    if (mounted) {
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
    }
  }
}