import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/property_approval_service.dart';

class PropertyListingStatusScreen extends StatefulWidget {
  final String? propertyId;
  
  const PropertyListingStatusScreen({super.key, this.propertyId});

  @override
  State<PropertyListingStatusScreen> createState() => _PropertyListingStatusScreenState();
}

class _PropertyListingStatusScreenState extends State<PropertyListingStatusScreen> {
  final _controller = TextEditingController();
  final _service = PropertyApprovalService();
  bool _loading = false;
  String? _status;
  String? _notes;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-populate and check status if property ID is provided
    if (widget.propertyId != null) {
      _controller.text = widget.propertyId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkStatus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Property Listing Status'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5993),
        elevation: 0.5,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Property ID', style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp, color: const Color(0xFF616161))),
            SizedBox(height: 8.h),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 123',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _checkStatus,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5993), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : const Text('Check Status'),
              ),
            ),
            SizedBox(height: 24.h),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12.r)),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_status != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user, color: Color(0xFF1B5993)),
                        SizedBox(width: 8.w),
                        const Text('Current Status', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Color(0xFF1B5993))),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(_status!, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700)),
                    if (_notes != null && _notes!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      const Text('Notes', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Color(0xFF1B5993))),
                      SizedBox(height: 6.h),
                      Text(_notes!, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF616161))),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkStatus() async {
    final id = _controller.text.trim();
    if (id.isEmpty) {
      setState(() { _error = 'Please enter a property ID.'; _status = null; _notes = null; });
      return;
    }
    setState(() { _loading = true; _error = null; _status = null; _notes = null; });
    final res = await _service.checkApprovalStatus(propertyId: id);
    setState(() { _loading = false; });
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      // Try common shapes
      final status = data['status']?.toString() ?? data['data']?['status']?.toString();
      final notes = data['notes']?.toString() ?? data['data']?['notes']?.toString();
      setState(() { _status = status ?? 'Pending'; _notes = notes; });
    } else {
      setState(() { _error = res['message']?.toString() ?? 'Failed to fetch status'; });
    }
  }
}


