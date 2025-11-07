import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import '../../../ui/widgets/app_icons.dart';
import 'type_pricing_step.dart';
import '../../../core/theme/app_theme.dart';

class PurposeSelectionStep extends StatelessWidget {
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
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: AppTheme.lightShadow,
              ),
              child: Icon(
                AppIcons.sellRounded,
                color: AppTheme.primaryBlue,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'PURPOSE SELECTION',
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
        child: Consumer<PropertyFormData>(
          builder: (context, formData, child) {
            return Column(
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
                              '2',
                              style: TextStyle(
                                color: AppTheme.cardWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Purpose Selection',
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
                Text(
                  'Property Purpose',
                  style: AppTheme.headingMedium,
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
                    'Select whether you want to sell or rent your property.',
                    style: AppTheme.bodyLarge,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Purpose Options
                _buildPurposeOption(
                  context: context,
                  formData: formData,
                  icon: Icons.sell_rounded,
                  title: 'Sell Property',
                  description: 'I want to sell this property',
                  value: 'Sell',
                ),
                
                const SizedBox(height: 16),
                
                _buildPurposeOption(
                  context: context,
                  formData: formData,
                  icon: AppIcons.homeRounded,
                  title: 'Rent Property',
                  description: 'I want to rent this property',
                  value: 'Rent',
                ),
              ],
            );
          },
        ),
      ),
      
      // Navigation Buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.0.w),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          boxShadow: AppTheme.lightShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: AppTheme.outlineButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              child: const Text('Back'),
            ),
            Consumer<PropertyFormData>(
              builder: (context, formData, child) {
                return ElevatedButton(
                  onPressed: formData.purpose != null ? () => _nextStep(context, formData) : null,
                  style: AppTheme.primaryButtonStyle.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      formData.purpose != null ? AppTheme.primaryBlue : AppTheme.textLight,
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  child: const Text('Continue'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPurposeOption({
    required BuildContext context,
    required PropertyFormData formData,
    required IconData icon,
    required String title,
    required String description,
    required String value,
  }) {
    final isSelected = formData.purpose == value;
    
    return GestureDetector(
      onTap: () {
        formData.updatePurpose(value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? const Color(0xFF20B2AA) : AppTheme.borderGrey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppTheme.primaryBlue.withValues(alpha: 0.1)
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
                color: isSelected ? const Color(0xFF20B2AA).withValues(alpha: 0.1) : AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF20B2AA) : AppTheme.textSecondary,
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
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF20B2AA) : AppTheme.borderGrey,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF20B2AA) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      AppIcons.checkRounded,
                      color: AppTheme.cardWhite,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
  
  void _nextStep(BuildContext context, PropertyFormData formData) {
    // Navigate to the next step (Type & Pricing)
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChangeNotifierProvider.value(
          value: formData,
          child: TypePricingStep(),
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