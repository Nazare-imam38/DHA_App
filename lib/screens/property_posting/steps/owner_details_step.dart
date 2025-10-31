import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import '../../../services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    final formData = context.read<PropertyFormData>();
    _cnicController.text = formData.cnic ?? '';
    _nameController.text = formData.name ?? '';
    _phoneController.text = formData.phone ?? '';
    _addressController.text = formData.address ?? '';
    _emailController.text = formData.email ?? '';
    if (formData.isOwnProperty) {
      _prefillFromUser();
    }
  }

  Future<void> _prefillFromUser() async {
    setState(() => _loadingUser = true);
    try {
      final auth = AuthService();
      final userInfo = await auth.getUserInfo();
      final user = userInfo.data.user;
      if (!mounted) return;
      setState(() {
        _nameController.text = user.name ?? '';
        _cnicController.text = user.cnic ?? '';
        _addressController.text = user.address ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
      });
      final form = context.read<PropertyFormData>();
      form.updateOwnerDetails(
        cnic: _cnicController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
      );
    } catch (_) {
      // ignore errors, allow manual fill
    } finally {
      if (mounted) setState(() => _loadingUser = false);
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
    final title = isOwn ? 'Owner Details (Your Info)' : 'Owner Details (On Behalf)';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5993), size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5993),
          ),
        ),
        centerTitle: false,
      ),
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      label: 'CNIC',
                      controller: _cnicController,
                      readOnly: isOwn,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().length != 13 ? 'Enter 13-digit CNIC' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Name',
                      controller: _nameController,
                      readOnly: isOwn,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Phone',
                      controller: _phoneController,
                      readOnly: isOwn,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Address',
                      controller: _addressController,
                      readOnly: isOwn,
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Email (optional)',
                      controller: _emailController,
                      readOnly: isOwn,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
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
                if (isOwn || _formKey.currentState?.validate() == true) {
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5993),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }
}