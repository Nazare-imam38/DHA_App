import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CallService {
  // Country code mapping
  static const Map<String, String> countryCodes = {
    '+1': 'United States',
    '+1-242': 'Bahamas',
    '+1-246': 'Barbados',
    '+1-264': 'Anguilla',
    '+1-268': 'Antigua and Barbuda',
    '+1-284': 'British Virgin Islands',
    '+1-340': 'US Virgin Islands',
    '+1-345': 'Cayman Islands',
    '+1-441': 'Bermuda',
    '+1-473': 'Grenada',
    '+1-649': 'Turks and Caicos Islands',
    '+1-664': 'Montserrat',
    '+1-670': 'Northern Mariana Islands',
    '+1-671': 'Guam',
    '+1-684': 'American Samoa',
    '+1-721': 'Sint Maarten',
    '+1-758': 'Saint Lucia',
    '+1-767': 'Dominica',
    '+1-784': 'Saint Vincent and the Grenadines',
    '+1-787': 'Puerto Rico',
    '+1-809': 'Dominican Republic',
    '+1-829': 'Dominican Republic',
    '+1-849': 'Dominican Republic',
    '+1-868': 'Trinidad and Tobago',
    '+1-869': 'Saint Kitts and Nevis',
    '+1-876': 'Jamaica',
    '+7': 'Russia',
    '+7-6': 'Kazakhstan',
    '+7-7': 'Kazakhstan',
    '+20': 'Egypt',
    '+27': 'South Africa',
    '+30': 'Greece',
    '+31': 'Netherlands',
    '+32': 'Belgium',
    '+33': 'France',
    '+34': 'Spain',
    '+36': 'Hungary',
    '+39': 'Italy',
    '+40': 'Romania',
    '+41': 'Switzerland',
    '+43': 'Austria',
    '+44': 'United Kingdom',
    '+45': 'Denmark',
    '+46': 'Sweden',
    '+47': 'Norway',
    '+48': 'Poland',
    '+49': 'Germany',
    '+51': 'Peru',
    '+52': 'Mexico',
    '+53': 'Cuba',
    '+54': 'Argentina',
    '+55': 'Brazil',
    '+56': 'Chile',
    '+57': 'Colombia',
    '+58': 'Venezuela',
    '+60': 'Malaysia',
    '+61': 'Australia',
    '+62': 'Indonesia',
    '+63': 'Philippines',
    '+64': 'New Zealand',
    '+65': 'Singapore',
    '+66': 'Thailand',
    '+81': 'Japan',
    '+82': 'South Korea',
    '+84': 'Vietnam',
    '+86': 'China',
    '+90': 'Turkey',
    '+91': 'India',
    '+92': 'Pakistan',
    '+93': 'Afghanistan',
    '+94': 'Sri Lanka',
    '+95': 'Myanmar',
    '+98': 'Iran',
    '+212': 'Morocco',
    '+213': 'Algeria',
    '+216': 'Tunisia',
    '+218': 'Libya',
    '+220': 'Gambia',
    '+221': 'Senegal',
    '+222': 'Mauritania',
    '+223': 'Mali',
    '+224': 'Guinea',
    '+225': 'Ivory Coast',
    '+226': 'Burkina Faso',
    '+227': 'Niger',
    '+228': 'Togo',
    '+229': 'Benin',
    '+230': 'Mauritius',
    '+231': 'Liberia',
    '+232': 'Sierra Leone',
    '+233': 'Ghana',
    '+234': 'Nigeria',
    '+235': 'Chad',
    '+236': 'Central African Republic',
    '+237': 'Cameroon',
    '+238': 'Cape Verde',
    '+239': 'São Tomé and Príncipe',
    '+240': 'Equatorial Guinea',
    '+241': 'Gabon',
    '+242': 'Republic of the Congo',
    '+243': 'Democratic Republic of the Congo',
    '+244': 'Angola',
    '+245': 'Guinea-Bissau',
    '+246': 'British Indian Ocean Territory',
    '+248': 'Seychelles',
    '+249': 'Sudan',
    '+250': 'Rwanda',
    '+251': 'Ethiopia',
    '+252': 'Somalia',
    '+253': 'Djibouti',
    '+254': 'Kenya',
    '+255': 'Tanzania',
    '+256': 'Uganda',
    '+257': 'Burundi',
    '+258': 'Mozambique',
    '+260': 'Zambia',
    '+261': 'Madagascar',
    '+262': 'Réunion',
    '+263': 'Zimbabwe',
    '+264': 'Namibia',
    '+265': 'Malawi',
    '+266': 'Lesotho',
    '+267': 'Botswana',
    '+268': 'Swaziland',
    '+269': 'Comoros',
    '+290': 'Saint Helena',
    '+291': 'Eritrea',
    '+297': 'Aruba',
    '+298': 'Faroe Islands',
    '+299': 'Greenland',
    '+350': 'Gibraltar',
    '+351': 'Portugal',
    '+352': 'Luxembourg',
    '+353': 'Ireland',
    '+354': 'Iceland',
    '+355': 'Albania',
    '+356': 'Malta',
    '+357': 'Cyprus',
    '+358': 'Finland',
    '+359': 'Bulgaria',
    '+370': 'Lithuania',
    '+371': 'Latvia',
    '+372': 'Estonia',
    '+373': 'Moldova',
    '+374': 'Armenia',
    '+375': 'Belarus',
    '+376': 'Andorra',
    '+377': 'Monaco',
    '+378': 'San Marino',
    '+380': 'Ukraine',
    '+381': 'Serbia',
    '+382': 'Montenegro',
    '+383': 'Kosovo',
    '+385': 'Croatia',
    '+386': 'Slovenia',
    '+387': 'Bosnia and Herzegovina',
    '+389': 'North Macedonia',
    '+420': 'Czech Republic',
    '+421': 'Slovakia',
    '+423': 'Liechtenstein',
    '+500': 'Falkland Islands',
    '+501': 'Belize',
    '+502': 'Guatemala',
    '+503': 'El Salvador',
    '+504': 'Honduras',
    '+505': 'Nicaragua',
    '+506': 'Costa Rica',
    '+507': 'Panama',
    '+508': 'Saint Pierre and Miquelon',
    '+509': 'Haiti',
    '+590': 'Guadeloupe',
    '+591': 'Bolivia',
    '+592': 'Guyana',
    '+593': 'Ecuador',
    '+594': 'French Guiana',
    '+595': 'Paraguay',
    '+596': 'Martinique',
    '+597': 'Suriname',
    '+598': 'Uruguay',
    '+599': 'Netherlands Antilles',
    '+670': 'East Timor',
    '+672': 'Australian External Territories',
    '+673': 'Brunei',
    '+674': 'Nauru',
    '+675': 'Papua New Guinea',
    '+676': 'Tonga',
    '+677': 'Solomon Islands',
    '+678': 'Vanuatu',
    '+679': 'Fiji',
    '+680': 'Palau',
    '+681': 'Wallis and Futuna',
    '+682': 'Cook Islands',
    '+683': 'Niue',
    '+684': 'American Samoa',
    '+685': 'Samoa',
    '+686': 'Kiribati',
    '+687': 'New Caledonia',
    '+688': 'Tuvalu',
    '+689': 'French Polynesia',
    '+690': 'Tokelau',
    '+691': 'Micronesia',
    '+692': 'Marshall Islands',
    '+850': 'North Korea',
    '+852': 'Hong Kong',
    '+853': 'Macau',
    '+855': 'Cambodia',
    '+856': 'Laos',
    '+880': 'Bangladesh',
    '+886': 'Taiwan',
    '+960': 'Maldives',
    '+961': 'Lebanon',
    '+962': 'Jordan',
    '+963': 'Syria',
    '+964': 'Iraq',
    '+965': 'Kuwait',
    '+966': 'Saudi Arabia',
    '+967': 'Yemen',
    '+968': 'Oman',
    '+970': 'Palestine',
    '+971': 'United Arab Emirates',
    '+972': 'Israel',
    '+973': 'Bahrain',
    '+974': 'Qatar',
    '+975': 'Bhutan',
    '+976': 'Mongolia',
    '+977': 'Nepal',
    '+992': 'Tajikistan',
    '+993': 'Turkmenistan',
    '+994': 'Azerbaijan',
    '+995': 'Georgia',
    '+996': 'Kyrgyzstan',
    '+998': 'Uzbekistan',
  };

  /// Extract country code from phone number
  static String? extractCountryCode(String phoneNumber) {
    // Remove spaces, dashes, and parentheses
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check for exact matches first (longer codes first)
    List<String> sortedCodes = countryCodes.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    
    for (String code in sortedCodes) {
      if (cleanNumber.startsWith(code)) {
        return code;
      }
    }
    
    return null;
  }

  /// Get country name from phone number
  static String getCountryName(String phoneNumber) {
    String? countryCode = extractCountryCode(phoneNumber);
    if (countryCode != null) {
      return countryCodes[countryCode] ?? 'Unknown Country';
    }
    return 'Unknown Country';
  }

  /// Launch phone call
  static Future<void> launchCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch phone call');
    }
  }

  /// Show call bottom sheet with country information
  static void showCallBottomSheet(BuildContext context, String phoneNumber) {
    String countryName = getCountryName(phoneNumber);
    String? countryCode = extractCountryCode(phoneNumber);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CallBottomSheet(
        phoneNumber: phoneNumber,
        countryName: countryName,
        countryCode: countryCode,
      ),
    );
  }
}

class CallBottomSheet extends StatelessWidget {
  final String phoneNumber;
  final String countryName;
  final String? countryCode;

  const CallBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.countryName,
    this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    // App theme blue color
    const appBlue = Color(0xFF1B5993);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.45, // Reduced from 0.75 to 0.45
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12, // Reduced from 24
          bottom: MediaQuery.of(context).padding.bottom + 16, // Reduced from 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Changed from max to min
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12), // Reduced from 20
            
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contact Details',
                  style: TextStyle(
                    fontSize: 18, // Reduced from 20
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Reduced from 30
            
            // Phone icon - smaller
            Container(
              width: 70, // Reduced from 100
              height: 70, // Reduced from 100
              decoration: BoxDecoration(
                color: appBlue.withOpacity(0.1), // Changed to blue
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone,
                size: 35, // Reduced from 50
                color: appBlue, // Changed to blue
              ),
            ),
            const SizedBox(height: 16), // Reduced from 30
            
            // Numbers section header
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 16, // Reduced from 18
                  color: appBlue, // Changed to blue
                ),
                const SizedBox(width: 6), // Reduced from 8
                const Text(
                  'Numbers',
                  style: TextStyle(
                    fontSize: 14, // Reduced from 16
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Reduced from 20
            
            // Country name
            Text(
              countryName,
              style: const TextStyle(
                fontSize: 12, // Reduced from 14
                color: Colors.grey,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            
            // Phone number with country flag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: appBlue.withOpacity(0.1), // Changed to blue
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: appBlue.withOpacity(0.3), // Changed to blue
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Country flag placeholder
                  Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      color: appBlue, // Changed to blue
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Center(
                      child: Text(
                        'PK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appBlue, // Changed to blue
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Reduced from 20, removed Spacer()
            
            // Action buttons
            Row(
              children: [
                // Call button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await CallService.launchCall(phoneNumber);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not make call: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.phone, color: Colors.white, size: 18), // Reduced from 20
                    label: const Text(
                      'Call Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        fontSize: 15, // Reduced from 16
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBlue, // Changed to blue
                      padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 18
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Reduced from 15
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Reduced from 16
                
                // Copy button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: phoneNumber));
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Phone number copied to clipboard'),
                            backgroundColor: appBlue, // Changed to blue
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, color: appBlue, size: 18), // Changed to blue, reduced size
                    label: const Text(
                      'Copy',
                      style: TextStyle(
                        color: appBlue, // Changed to blue
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        fontSize: 15, // Reduced from 16
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 18
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Reduced from 15
                      ),
                      side: const BorderSide(color: appBlue, width: 2), // Changed to blue
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced from 20
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  fontSize: 14, // Reduced from 16
                ),
              ),
            ),
            const SizedBox(height: 8), // Reduced from 20
          ],
        ),
      ),
    );
  }
}
