import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'ms_verification_screen.dart';
import 'property_posting/property_posting_flow.dart';
import 'property_posting/models/property_form_data.dart';
import 'property_posting/steps/purpose_selection_step.dart';
import '../ui/widgets/app_icons.dart';
import '../core/theme/app_theme.dart';

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
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.cardWhite,
              elevation: 0,
              leading: IconButton(
                  icon: const Icon(
                    AppIcons.arrowBackIosNew,
            color: AppTheme.primaryBlue,
            size: 16,
                  ),
                  onPressed: () => Navigator.pop(context),
              ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                AppIcons.workRounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
                        'OWNERSHIP SELECTION',
                        style: AppTheme.titleLarge.copyWith(
                          fontSize: 18.sp,
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
              color: AppTheme.primaryBlue,
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
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.tealAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppTheme.tealAccent,
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
                    Text(
                      'Ownership Selection',
                        style: AppTheme.titleMedium.copyWith(
                          fontSize: 14,
                          color: AppTheme.tealAccent,
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
                                color: AppTheme.primaryBlue,
                        height: 1.2,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                    // Instructions Card
                            Container(
                      width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                border: Border.all(
                          color: AppTheme.borderGrey,
                                  width: 1,
                                ),
                        boxShadow: AppTheme.lightShadow,
                              ),
                              child: Text(
                                'Please select whether you are listing your own property or listing on behalf of someone else.',
                                style: AppTheme.bodyLarge,
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
                              icon: AppIcons.homeRounded,
                              isSelected: _selectedOption == 'own',
                              onTap: () => _selectOption('own'),
                            ),
                            
                    const SizedBox(height: 16),
                            
                            // On Behalf of Someone Else Option
                    _buildOptionCard(
                              title: 'On Behalf of Someone Else',
                              subtitle: 'I am listing this property for someone else',
                              icon: AppIcons.peopleRounded,
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
                        backgroundColor: AppTheme.cardWhite,
                        foregroundColor: AppTheme.tealAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          side: BorderSide(
                            color: AppTheme.tealAccent,
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
                                  AppIcons.checkCircleRounded,
                                  size: 20,
                                  color: AppTheme.tealAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedOption == 'own' 
                                      ? 'PROCEED with your own property'
                                      : 'PROCEED on behalf of someone else',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: AppTheme.tealAccent,
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
            color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.tealAccent : AppTheme.borderGrey,
            width: 2,
          ),
          boxShadow: [
                  BoxShadow(
              color: isSelected 
                  ? AppTheme.tealAccent.withValues(alpha: 0.3)
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
                  color: isSelected ? AppTheme.tealAccent.withValues(alpha: 0.1) : AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.tealAccent : AppTheme.primaryBlue,
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
                    style: AppTheme.titleLarge.copyWith(
                      color: isSelected ? AppTheme.tealAccent : AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.bodyMedium.copyWith(
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
                color: isSelected ? AppTheme.cardWhite : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.cardWhite : AppTheme.textLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      AppIcons.checkRounded,
                      color: AppTheme.tealAccent,
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
    
    // Create form data with ownership selection
    final formData = PropertyFormData();
    formData.updateOwnership(_selectedOption == 'own' ? 0 : 1);
    
    // Navigate directly to purpose selection step
    // User details will be fetched later in Step 7 (Owner Details Step)
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider.value(
            value: formData,
            child: PurposeSelectionStep(),
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
  }
}