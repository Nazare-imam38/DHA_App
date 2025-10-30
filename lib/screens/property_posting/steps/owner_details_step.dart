import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import 'review_confirmation_step.dart';

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
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
        backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5993)),
              onPressed: () => Navigator.pop(context),
            ),
        title: const Text(
          'Owner Details',
                  style: TextStyle(
                    fontFamily: 'Inter',
            fontSize: 20,
                    fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
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
                      color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                      offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: const Color(0xFF1B5993),
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Step 7. Owner Information',
                      style: TextStyle(
                        fontFamily: 'Inter',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B5993),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Please provide the property owner\'s details.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF616161),
                      ),
                        ),
                      ],
                    ),
              ),

              SizedBox(height: 24.h),

                        // CNIC Field
              _buildTextField(
                          controller: _cnicController,
                label: 'CNIC Number',
                hint: 'Enter CNIC (e.g., 12345-1234567-1)',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
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
                        side: const BorderSide(color: Color(0xFF1B5993), width: 2),
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
                            color: Color(0xFF1B5993),
                          ),
                        ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5993),
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
                          color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
            style: TextStyle(
            fontFamily: 'Inter',
              fontSize: 16.sp,
            fontWeight: FontWeight.w600,
              color: const Color(0xFF1B5993),
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: const Color(0xFF9E9E9E),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFF1B5993), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
            ),
          ),
        ),
      ],
      ),
    );
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