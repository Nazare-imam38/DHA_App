import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      
      // Try multiple WhatsApp URL schemes for better compatibility
      List<String> whatsappUrls = [
        'https://wa.me/$whatsappNumber',
        'whatsapp://send?phone=$whatsappNumber',
        'https://api.whatsapp.com/send?phone=$whatsappNumber',
        'whatsapp://send?phone=$whatsappNumber&text=${Uri.encodeComponent(message ?? '')}',
      ];
      
      // Add message if provided
      if (message != null && message.isNotEmpty) {
        final encodedMessage = Uri.encodeComponent(message);
        whatsappUrls = [
          'https://wa.me/$whatsappNumber?text=$encodedMessage',
          'whatsapp://send?phone=$whatsappNumber&text=$encodedMessage',
          'https://api.whatsapp.com/send?phone=$whatsappNumber&text=$encodedMessage',
        ];
      }
      
      bool launched = false;
      
      // Try each URL scheme until one works
      for (String url in whatsappUrls) {
        try {
          final Uri uri = Uri.parse(url);
          
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri, 
              mode: LaunchMode.externalApplication,
            );
            launched = true;
            break;
          }
        } catch (e) {
          // Continue to next URL scheme
          continue;
        }
      }
      
      if (!launched) {
        // Try fallback to SMS if WhatsApp fails
        if (context != null) {
          _showWhatsAppErrorDialog(context, phoneNumber, message);
        }
      }
    } catch (e) {
      if (context != null) {
        _showErrorSnackBar(context, 'Failed to open WhatsApp. Please try again.');
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
  
  /// Fallback method to open phone's default messaging app
  static Future<void> _launchFallbackMessaging({
    required String phoneNumber,
    String? message,
    BuildContext? context,
  }) async {
    try {
      final Uri uri = Uri.parse('sms:$phoneNumber${message != null ? '?body=${Uri.encodeComponent(message)}' : ''}');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context != null) {
          _showErrorSnackBar(context, 'No messaging app available on this device');
        }
      }
    } catch (e) {
      if (context != null) {
        _showErrorSnackBar(context, 'Failed to open messaging app');
      }
    }
  }

  /// Shows WhatsApp error dialog with fallback options
  static void _showWhatsAppErrorDialog(BuildContext context, String phoneNumber, String? message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.chat, color: Color(0xFF25D366), size: 24),
              SizedBox(width: 8),
              Text('WhatsApp Not Available'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('WhatsApp is not installed or not working on your device.'),
              SizedBox(height: 16),
              Text('You can:'),
              SizedBox(height: 8),
              Text('• Install WhatsApp from Play Store/App Store'),
              Text('• Use SMS to contact the agent'),
              Text('• Copy the phone number to call directly'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchFallbackMessaging(
                  phoneNumber: phoneNumber,
                  message: message,
                  context: context,
                );
              },
              child: Text('Send SMS'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _copyPhoneNumber(context, phoneNumber);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
              child: Text('Copy Number'),
            ),
          ],
        );
      },
    );
  }

  /// Copy phone number to clipboard
  static void _copyPhoneNumber(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone number copied: $phoneNumber'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Shows error message with fallback option
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Try SMS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // You can add fallback SMS functionality here if needed
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
