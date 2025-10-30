import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import 'review_confirmation_step.dart';
import '../../../core/theme/app_theme.dart';

class OwnerDetailsStep extends StatefulWidget {
  @override
  _OwnerDetailsStepState createState() => _OwnerDetailsStepState();
}

class _OwnerDetailsStepState extends State<OwnerDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _cnicController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    final formData = context.read<PropertyFormData>();
    _cnicController.text = formData.cnic ?? '';
    _nameController.text = formData.name ?? '';
    _phoneController.text = formData.phone ?? '';
    _addressController.text = formData.address ?? '';
    _emailController.text = formData.email ?? '';
  }

  @override
  void dispose() {
    _cnicController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundGrey,
          appBar: AppBar(
        backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryBlue),
              onPressed: () => Navigator.pop(context),
            ),
        title: const Text(
          'Owner Details',
                  style: TextStyle(
                    fontFamily: 'Inter',
            fontSize: 20,
                    fontWeight: FontWeight.w700,
            color: AppTheme.primaryBlue,
          ),
        ),
        centerTitle: true,
          ),
          body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Header
                  Container(
                padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4)) {
                              return 'CNIC is required';
                            }
                  if (value.length < 13) {
                    return 'Please enter a valid CNIC';
                            }
                            return null;
                          },
                keyboardType: TextInputType.number,
                        ),
                        
              SizedBox(height: 16.h),
                        
                        // Name Field
              _buildTextField(
                          controller: _nameController,
                label: 'Full Name',
                          hint: 'Enter owner\'s full name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        
              SizedBox(height: 16.h),
                        
                        // Phone Field
              _buildTextField(
                          controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number (e.g., +92 300 1234567)',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                keyboardType: TextInputType.phone,
                        ),
                        
              SizedBox(height: 16.h),
                        
                        // Address Field
              _buildTextField(
                          controller: _addressController,
                label: 'Address',
                hint: 'Enter complete address',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Address is required';
                            }
                            return null;
                          },
                maxLines: 3,
                        ),
                        
              SizedBox(height: 16.h),
                        
              // Email Field
              _buildTextField(
                          controller: _emailController,
                label: 'Email Address',
                hint: 'Enter email address (optional)',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                            }
                            return null;
                          },
              ),

              SizedBox(height: 32.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: AppTheme.primaryBlue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text(
                        'Back',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                          fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                          style: TextStyle(
                            fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cardWhite,
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
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4));
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      final formData = context.read<PropertyFormData>();
      
      // Update form data with owner details
      formData.updateOwnerDetails(
        cnic: _cnicController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      );

      // Navigate to review confirmation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: formData,
            child: ReviewConfirmationStep(),
          ),
        ),
      );
    }
  }
}