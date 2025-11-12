import 'package:flutter/material.dart';
import 'lib/services/whatsapp_service.dart';

void main() {
  runApp(WhatsAppTestApp());
}

class WhatsAppTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Test',
      home: WhatsAppTestScreen(),
    );
  }
}

class WhatsAppTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Integration Test'),
        backgroundColor: Color(0xFF25D366),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'WhatsApp Integration Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Test 1: Basic WhatsApp launch
            ElevatedButton(
              onPressed: () {
                WhatsAppService.launchWhatsApp(
                  phoneNumber: '+923001234567',
                  message: 'Hello! This is a test message from DHA Marketplace app.',
                  context: context,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Test Basic WhatsApp Launch'),
            ),
            
            SizedBox(height: 16),
            
            // Test 2: Property-specific WhatsApp
            ElevatedButton(
              onPressed: () {
                WhatsAppService.launchWhatsAppForProperty(
                  phoneNumber: '+923001234567',
                  propertyTitle: 'Modern Apartment - Phase 3',
                  propertyPrice: 'PKR 8,500,000',
                  propertyLocation: 'DHA Phase 1',
                  context: context,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1B5993),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Test Property WhatsApp'),
            ),
            
            SizedBox(height: 16),
            
            // Test 3: General inquiry
            ElevatedButton(
              onPressed: () {
                WhatsAppService.launchWhatsAppGeneral(
                  phoneNumber: '+923001234567',
                  customMessage: 'Hi! I am interested in DHA properties. Please provide more information.',
                  context: context,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF20B2AA),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Test General Inquiry'),
            ),
            
            SizedBox(height: 20),
            
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. Make sure WhatsApp is installed on your device\n'
              '2. Click any button above to test WhatsApp integration\n'
              '3. WhatsApp should open with the pre-filled message\n'
              '4. If WhatsApp is not installed, you should see an error message',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
