import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'models/property_form_data.dart';
import 'property_posting_flow.dart';
import '../ownership_selection_screen.dart';
import '../property_listing_status_screen.dart';
import '../../services/auth_service.dart';

class TestPropertyPostingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Property Posting Test',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1B5993),
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FD),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: const Color(0xFF20B2AA).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      size: 60,
                      color: Color(0xFF1B5993),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Property Posting Test Suite',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5993),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Test all components of the property posting flow',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF616161),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Test Options
            const Text(
              'Available Tests',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5993),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Complete Flow Test
            _buildTestCard(
              context: context,
              icon: Icons.play_circle_filled_rounded,
              title: 'Complete Property Posting Flow',
              description: 'Test the entire 7-step property posting process from ownership selection to submission',
              buttonText: 'Start Complete Flow',
              onPressed: () => _startCompleteFlow(context),
            ),
            
            const SizedBox(height: 16),
            
            // Ownership Selection Test
            _buildTestCard(
              context: context,
              icon: Icons.person_rounded,
              title: 'Ownership Selection Only',
              description: 'Test just the ownership selection step (own property vs on behalf)',
              buttonText: 'Test Ownership',
              onPressed: () => _testOwnershipSelection(context),
            ),
            
            const SizedBox(height: 16),
            
            // Direct Flow Test
            _buildTestCard(
              context: context,
              icon: Icons.fast_forward_rounded,
              title: 'Direct Property Flow',
              description: 'Skip ownership selection and go directly to the property posting steps',
              buttonText: 'Start Direct Flow',
              onPressed: () => _startDirectFlow(context),
            ),
            
            const SizedBox(height: 16),
            
            // Status Check Test
            _buildTestCard(
              context: context,
              icon: Icons.check_circle_rounded,
              title: 'Property Status Check',
              description: 'Test the property listing status checker with a sample property ID',
              buttonText: 'Test Status Check',
              onPressed: () => _testStatusCheck(context),
            ),
            
            const SizedBox(height: 40),
            
            // Flow Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF20B2AA).withValues(alpha: 0.3),
                ),
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
                      const Icon(
                        Icons.info_rounded,
                        color: Color(0xFF20B2AA),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Flow Information',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5993),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Property Posting Steps:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5993),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildStepList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1B5993),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B5993),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF616161),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5993),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildStepList() {
    final steps = [
      'Purpose & Ownership Selection',
      'Type & Pricing (with API)',
      'Property Details',
      'Location Details',
      'Amenities Selection (with API)',
      'Media Upload (optional)',
      'Owner Details (conditional)',
      'Review & Submit (with API)',
    ];
    
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF20B2AA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF616161),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
  
  void _startCompleteFlow(BuildContext context) async {
    // Set test token for API testing
    final authService = AuthService();
    await authService.setTestToken('eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMmExZC0xMjEyLTczZGYtODE5OS1iMmM5MGM1NmE4NDIiLCJqdGkiOiI4YTA5Y2U4ODQxNWM4NGI3YjEyOTUwMTY2Y2UzOTU2NzFhMzc0ZWY3NTQ5ZmUzYWFmNjZkZTA2MzIzYWI4YzNiM2VlMmU5ZGE4NTBhYTdmOSIsImlhdCI6MTc2MTc2MzgxMi45ODY3NzgsIm5iZiI6MTc2MTc2MzgxMi45ODY3ODIsImV4cCI6MTc5MzI5OTgxMi45NzY2NjEsInN1YiI6IjE5Iiwic2NvcGVzIjpbXX0.D6quu21hk5sEe17frN6um0a30i7VLZMQmE6BERb_dxkRw5aCNSx33ek5uY7pF0eMnUE2owk__-LwCR7O1A1ezVIq68LF81t_04iKj5ZES4LPT1t8SRqhk1bqfZYpT1_WqpPcavoALGOw1UZyxLn3U8iRgcI7cNZgJmtH0vOjX8k4airq__BcI9UvLjVXW4p44LzYuBjNL0GfLpR0s81TkncYltpDK7TWYCqM7q5bb9fxDjk1zu9UHPBXoYYN74k0WeqCHUKCr9fQhABIcvZzmOW7R8BQvBf-XDVm_tYu8YOxUz_HaFSN6f_JuhduqpRUaIRXZAS1G37ZOa5g-Uwz41azYkjgMw3vdEfiu5JwrSpfAiVBXo7DDyzfTflfltF77y6-JOT2vfb44bKY7UF655NTx7-YltrIgZVkKU9LIg3dtCi1TCT8s3e0N6AmRs444DS6z_lPEl4OJw7lVDFMTQy5IGEAuVF44A5Ce87Pr68UIJNvwqkWL2yGMVLyoocC7XGYBEBfH9QIPu2gprlRJ8Yb4A4qXpcW2oRApCRQzM71DvEx4uF-IFCZZCSVAu7p3v3c8hehq8hG__Mc1vPAuGghAVsIeqoViOogB1BmkplYLsWQB6rb73ECpHADf8ti5ThV3n1KPgkvCNjGJVbYjPaHwtC2XMnXoSuPUysFlno');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OwnershipSelectionScreen(),
      ),
    );
  }
  
  void _testOwnershipSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OwnershipSelectionScreen(),
      ),
    );
  }
  
  void _startDirectFlow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => PropertyFormData(),
          child: PropertyPostingFlow(),
        ),
      ),
    );
  }
  
  void _testStatusCheck(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PropertyListingStatusScreen(propertyId: '123'),
      ),
    );
  }
}
