import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  // Default WhatsApp contact number for DHA Marketplace
  static const String defaultContactNumber = '+923001234567';
  
  /// Launches WhatsApp with a specific phone number and message
  static Future<void> launchWhatsApp({
    required String phoneNumber,
    String? message,
    BuildContext? context,
  }) async {
    try {
      // Clean the phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Ensure the number starts with country code if not already present
      String formattedNumber = cleanNumber;
      if (!cleanNumber.startsWith('+')) {
        if (cleanNumber.startsWith('92')) {
          formattedNumber = '+$cleanNumber';
        } else if (cleanNumber.startsWith('0')) {
          formattedNumber = '+92${cleanNumber.substring(1)}';
        } else {
          formattedNumber = '+92$cleanNumber';
        }
      }
      
      // Remove the + for WhatsApp URL scheme
      final whatsappNumber = formattedNumber.replaceFirst('+', '');
      
      // Create the WhatsApp URL
      String whatsappUrl = 'https://wa.me/$whatsappNumber';
      
      // Add message if provided
      if (message != null && message.isNotEmpty) {
        final encodedMessage = Uri.encodeComponent(message);
        whatsappUrl += '?text=$encodedMessage';
      }
      
      final Uri uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context != null) {
          _showErrorSnackBar(context, 'WhatsApp is not installed on this device');
        }
      }
    } catch (e) {
      if (context != null) {
        _showErrorSnackBar(context, 'Failed to open WhatsApp: $e');
      }
    }
  }
  
  /// Launches WhatsApp with property information
  static Future<void> launchWhatsAppForProperty({
    required String phoneNumber,
    required String propertyTitle,
    required String propertyPrice,
    required String propertyLocation,
    BuildContext? context,
  }) async {
    final message = '''
🏠 *Property Inquiry*

*Property:* $propertyTitle
*Price:* $propertyPrice
*Location:* $propertyLocation

Hi! I'm interested in this property. Could you please provide more details?

Thank you!
''';
    
    await launchWhatsApp(
      phoneNumber: phoneNumber,
      message: message,
      context: context,
    );
  }
  
  /// Launches WhatsApp with general inquiry
  static Future<void> launchWhatsAppGeneral({
    required String phoneNumber,
    String? customMessage,
    BuildContext? context,
  }) async {
    final message = customMessage ?? '''
🏠 *DHA Marketplace Inquiry*

Hi! I'm interested in properties in DHA. Could you please provide more information about available properties?

Thank you!
''';
    
    await launchWhatsApp(
      phoneNumber: phoneNumber,
      message: message,
      context: context,
    );
  }
  
  /// Shows error message
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Shows success message
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
