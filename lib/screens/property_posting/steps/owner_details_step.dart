import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import '../../../services/user_service.dart';
import 'review_confirmation_step.dart';

class OwnerDetailsStep extends StatefulWidget {
  const OwnerDetailsStep({super.key});

  @override
  State<OwnerDetailsStep> createState() => _OwnerDetailsStepState();
}

class _OwnerDetailsStepState extends State<OwnerDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _cnicController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loadingUser = false;
  bool _wasAutoFilled = false;

  @override
  void initState() {
    super.initState();
    final formData = context.read<PropertyFormData>();
    
    print('🔍 OwnerDetailsStep initState:');
    print('   isOwnProperty: ${formData.isOwnProperty}');
    print('   onBehalf: ${formData.onBehalf}');
    print('   Existing CNIC: ${formData.cnic}');
    print('   Existing Name: ${formData.name}');
    
    _cnicController.text = formData.cnic ?? '';
    _nameController.text = formData.name ?? '';
    _phoneController.text = formData.phone ?? '';
    _addressController.text = formData.address ?? '';
    _emailController.text = formData.email ?? '';
    
    if (formData.isOwnProperty) {
      print('🔄 User owns property - calling _prefillFromUser()');
      _prefillFromUser();
    } else {
      print('ℹ️ Property on behalf - no auto-fill needed');
    }
  }

  Future<void> _prefillFromUser() async {
    print('🚀 _prefillFromUser() started');
    setState(() => _loadingUser = true);
    
    try {
      print('🔄 Creating UserService instance...');
      final userService = UserService();
      
      print('🔄 Calling getOwnerDetailsForProperty()...');
      final ownerDetails = await userService.getOwnerDetailsForProperty();
      
      print('📥 Received owner details: $ownerDetails');
      
      if (!mounted) {
        print('⚠️ Widget not mounted, returning');
        return;
      }
      
      if (ownerDetails != null && ownerDetails.isNotEmpty) {
        print('✅ Owner details found, updating form fields...');
        
        final name = ownerDetails['name']?.toString() ?? '';
        final cnic = ownerDetails['cnic']?.toString() ?? '';
        final address = ownerDetails['address']?.toString() ?? '';
        final email = ownerDetails['email']?.toString() ?? '';
        final phone = ownerDetails['phone']?.toString() ?? '';
        
        print('   Name: "$name"');
        print('   CNIC: "$cnic"');
        print('   Phone: "$phone"');
        print('   Address: "$address"');
        print('   Email: "$email"');
        
        setState(() {
          _nameController.text = name;
          _cnicController.text = cnic;
          _addressController.text = address;
          _emailController.text = email;
          _phoneController.text = phone;
        });
        
        final form = context.read<PropertyFormData>();
        form.updateOwnerDetails(
          cnic: cnic.isEmpty ? null : cnic,
          name: name.isEmpty ? null : name,
          phone: phone.isEmpty ? null : phone,
          address: address.isEmpty ? null : address,
          email: email.isEmpty ? null : email,
        );
        
        // Set auto-fill flag to true only if we got some data
        _wasAutoFilled = name.isNotEmpty || cnic.isNotEmpty || phone.isNotEmpty;
        
        print('✅ Owner details prefilled and form data updated');
        print('   Auto-fill successful: $_wasAutoFilled');
      } else {
        print('⚠️ No user details found or empty response');
        print('   ownerDetails is null: ${ownerDetails == null}');
        print('   ownerDetails is empty: ${ownerDetails?.isEmpty ?? true}');
      }
    } catch (e, stackTrace) {
      print('❌ Error prefilling user details: $e');
      print('❌ Stack trace: $stackTrace');
    } finally {
      if (mounted) {
        print('🏁 Setting loading to false');
        setState(() => _loadingUser = false);
      }
    }
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
    final formData = context.watch<PropertyFormData>();
    final isOwn = formData.isOwnProperty;
    final title = isOwn ? 'OWNER DETAILS' : 'OWNER DETAILS';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5993), size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_rounded,
                color: const Color(0xFF1B5993),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5993),
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
              color: const Color(0xFF1B5993),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
          ),
        ),
      ),
      body: _loadingUser
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF1B5993)),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your details...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      color: const Color(0xFF1B5993),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
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
                                '7',
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
                            'Owner Details',
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
                  Text(
                    isOwn ? 'Your Information' : 'Property Owner Information',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5993),
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    isOwn 
                      ? 'Your details have been automatically filled from your profile. You can edit them if needed.'
                      : 'Please enter the property owner\'s details.',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF616161),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Owner Details Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF1B5993),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isOwn 
                                  ? (_wasAutoFilled ? 'Your Details (Auto-filled)' : 'Your Details') 
                                  : 'Owner Details',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B5993),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          _buildField(
                            label: 'CNIC *',
                            controller: _cnicController,
                            readOnly: false, // Always editable
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().length != 13 ? 'Enter 13-digit CNIC' : null,
                            isAutoFilled: isOwn && _wasAutoFilled,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Full Name *',
                            controller: _nameController,
                            readOnly: false, // Always editable
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            isAutoFilled: isOwn && _wasAutoFilled,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Phone Number *',
                            controller: _phoneController,
                            readOnly: false, // Always editable
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            isAutoFilled: isOwn && _wasAutoFilled,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Address *',
                            controller: _addressController,
                            readOnly: false, // Always editable
                            maxLines: 3,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            isAutoFilled: isOwn && _wasAutoFilled,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Email (Optional)',
                            controller: _emailController,
                            readOnly: false, // Always editable
                            keyboardType: TextInputType.emailAddress,
                            isAutoFilled: isOwn && _wasAutoFilled,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.w),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                // Always validate the form since fields are now editable in both cases
                if (_formKey.currentState?.validate() == true) {
                  final form = context.read<PropertyFormData>();
                  form.updateOwnerDetails(
                    cnic: _cnicController.text.trim(),
                    name: _nameController.text.trim(),
                    phone: _phoneController.text.trim(),
                    address: _addressController.text.trim(),
                    email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewConfirmationStep(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5993),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Continue to Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isAutoFilled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5993),
                letterSpacing: 0.2,
              ),
            ),
            if (isAutoFilled) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF20B2AA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Auto-filled',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF20B2AA),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAutoFilled 
                ? const Color(0xFF20B2AA).withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: isAutoFilled 
                ? const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF20B2AA),
                    size: 16,
                  )
                : null,
            ),
          ),
        ),
      ],
    );
  }
}