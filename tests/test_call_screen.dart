import 'package:flutter/material.dart';
import '../services/call_service.dart';

class TestCallScreen extends StatelessWidget {
  const TestCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Call Functionality'),
        backgroundColor: const Color(0xFF20B2AA),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Different Country Codes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            
            // Pakistan
            _buildTestCallButton(
              context,
              '+92-51-111-555-400',
              'Pakistan',
              'DHA Islamabad Office',
            ),
            
            // United States
            _buildTestCallButton(
              context,
              '+1-555-123-4567',
              'United States',
              'US Office',
            ),
            
            // United Kingdom
            _buildTestCallButton(
              context,
              '+44-20-7946-0958',
              'United Kingdom',
              'UK Office',
            ),
            
            // India
            _buildTestCallButton(
              context,
              '+91-11-2345-6789',
              'India',
              'India Office',
            ),
            
            // China
            _buildTestCallButton(
              context,
              '+86-10-1234-5678',
              'China',
              'China Office',
            ),
            
            // Germany
            _buildTestCallButton(
              context,
              '+49-30-12345678',
              'Germany',
              'Germany Office',
            ),
            
            // Australia
            _buildTestCallButton(
              context,
              '+61-2-1234-5678',
              'Australia',
              'Australia Office',
            ),
            
            // Unknown country
            _buildTestCallButton(
              context,
              '+999-123-456-789',
              'Unknown Country',
              'Test Unknown',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCallButton(
    BuildContext context,
    String phoneNumber,
    String country,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF20B2AA).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.phone,
            color: Color(0xFF20B2AA),
          ),
        ),
        title: Text(
          phoneNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        subtitle: Text(
          '$description • $country',
          style: const TextStyle(
            color: Colors.grey,
            fontFamily: 'Inter',
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF20B2AA),
        ),
        onTap: () {
          CallService.showCallBottomSheet(context, phoneNumber);
        },
      ),
    );
  }
}
