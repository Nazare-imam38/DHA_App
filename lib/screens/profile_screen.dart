import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../providers/auth_provider.dart';
import '../core/services/location_service.dart';
import '../services/customer_properties_service.dart';
import '../models/auth_models.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/widgets/cached_asset_image.dart';
import '../ui/widgets/app_icons.dart';
import 'property_listing_status_screen.dart';
import 'my_listings_screen.dart';
import 'contact_us_screen.dart';
import 'sidebar_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserInfo? _userInfo;
  bool _isLoadingUserInfo = false;
  int _verifiedPropertiesCount = 0;
  bool _isLoadingPropertyCounts = false;
  final CustomerPropertiesService _propertiesService = CustomerPropertiesService();
  
  // Feedback emojis
  final List<Map<String, dynamic>> _feedbackEmojis = [
    {'emoji': '😍', 'text': 'Love it!', 'value': 5},
    {'emoji': '😊', 'text': 'Like it', 'value': 4},
    {'emoji': '😐', 'text': 'Okay', 'value': 3},
    {'emoji': '😕', 'text': 'Not good', 'value': 2},
    {'emoji': '😞', 'text': 'Hate it', 'value': 1},
  ];
  
  int? _selectedFeedback;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadPropertyCounts();
  }

  Future<void> _loadPropertyCounts() async {
    setState(() {
      _isLoadingPropertyCounts = true;
    });

    try {
      final result = await _propertiesService.getPropertyCounts();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _verifiedPropertiesCount = data['verified_properties'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading property counts: $e');
    } finally {
      setState(() {
        _isLoadingPropertyCounts = false;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoadingUserInfo = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // First try to get user from stored data
      if (authProvider.userInfo != null) {
        setState(() {
          _userInfo = authProvider.userInfo;
        });
        _isLoadingUserInfo = false;
      } else if (authProvider.user != null) {
        // Create UserInfo from stored user data
        setState(() {
          _userInfo = UserInfo(
            user: authProvider.user!,
            reserveBookings: [], // Will be loaded separately if needed
          );
        });
        _isLoadingUserInfo = false;
        
        // Then try to refresh with latest data from server
        try {
          final response = await authProvider.getUserInfo();
          setState(() {
            _userInfo = response.data;
          });
        } catch (e) {
          // If server call fails, keep using stored data
          print('Failed to refresh user info from server: $e');
        }
      } else {
        // If no stored user, try to get from server
        final response = await authProvider.getUserInfo();
        setState(() {
          _userInfo = response.data;
        });
      }
    } catch (e) {
      // Handle error silently or show a message
      print('Failed to load user info: $e');
    } finally {
      setState(() {
        _isLoadingUserInfo = false;
      });
    }
  }


  void _showLanguageSelector() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    l10n.selectLanguage,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Radio<String>(
                      value: 'en',
                      groupValue: languageService.currentLanguageCode,
                      onChanged: (value) {
                        languageService.setEnglish();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Language changed to English'),
                            backgroundColor: const Color(0xFF20B2AA),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      activeColor: const Color(0xFF20B2AA),
                    ),
                    title: Text(
                      l10n.english,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Radio<String>(
                      value: 'ur',
                      groupValue: languageService.currentLanguageCode,
                      onChanged: (value) {
                        languageService.setUrdu();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Language changed to Urdu'),
                            backgroundColor: const Color(0xFF20B2AA),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      activeColor: const Color(0xFF20B2AA),
                    ),
                    title: Text(
                      l10n.urdu,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageChangeDialog() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.languageChanged,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.languageChangedMessage(languageService.currentLanguageName),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.ok,
              style: TextStyle(
                color: const Color(0xFF20B2AA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactUsScreen(),
      ),
    );
  }


  void _showFeedbackDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Rate Your Experience',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'How would you rate our app?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Use SingleChildScrollView to handle overflow
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _feedbackEmojis.map((emoji) {
                          bool isSelected = _selectedFeedback == emoji['value'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFeedback = emoji['value'];
                              });
                            },
                            child: Container(
                              width: 70, // Fixed width to prevent overflow
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF20B2AA).withOpacity(0.1) : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF20B2AA) : Colors.grey[200]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    emoji['emoji'],
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    emoji['text'],
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? const Color(0xFF20B2AA) : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedFeedback != null ? () {
                              Navigator.pop(context);
                              _showAppStoreRating();
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF20B2AA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
            
          ],
        ),
      ),
    );
  }

  void _showAppStoreRating() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rate on App Store',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Would you like to rate our app on the App Store?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Not Now',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchAppStore();
            },
            child: Text(
              'Rate Now',
              style: TextStyle(
                color: const Color(0xFF20B2AA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _launchAppStore() async {
    // This would launch the app store rating page
    // For now, we'll show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirecting to App Store...'),
        backgroundColor: const Color(0xFF20B2AA),
      ),
    );
  }

  void _showUpdateProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user ?? _userInfo?.user;
    final nameController = TextEditingController(text: currentUser?.name ?? '');
    final cnicController = TextEditingController(text: currentUser?.cnic ?? '');
    final addressController = TextEditingController(text: currentUser?.address ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Profile',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF20B2AA), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cnicController,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'CNIC',
                      labelStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF20B2AA), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 13,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF20B2AA), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: TextButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF20B2AA),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                if (nameController.text.isEmpty || 
                    cnicController.text.isEmpty || 
                    addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  isLoading = true;
                });

                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.updateProfile(UpdateProfileRequest(
                    name: nameController.text.trim(),
                    cnic: cnicController.text.trim(),
                    address: addressController.text.trim(),
                  ));

                  if (mounted) {
                    Navigator.pop(context);
                    await _loadUserInfo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: const Color(0xFF20B2AA),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF20B2AA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Update',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: currentPasswordController,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF20B2AA), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF20B2AA), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF20B2AA), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: TextButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF20B2AA),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                if (currentPasswordController.text.isEmpty || 
                    newPasswordController.text.isEmpty || 
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  isLoading = true;
                });

                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.changePassword(ChangePasswordRequest(
                    currentPassword: currentPasswordController.text,
                    password: newPasswordController.text,
                    passwordConfirmation: confirmPasswordController.text,
                  ));

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password changed successfully'),
                        backgroundColor: const Color(0xFF20B2AA),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF20B2AA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Change Password',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B5993).withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B5993), // Blue color matching other dialogs
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo container
                      Container(
                        width: 64.w,
                        height: 64.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.w,
                          ),
                        ),
                        padding: EdgeInsets.all(8.w),
                        child: CachedAssetImage(
                          assetPath: 'assets/images/dhalogo.png',
                          width: 48.w,
                          height: 48.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
          'Logout',
          style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
          ),
        ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontFamily: 'Inter',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF616161),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
          ),
                      
                      SizedBox(height: 32.h),
                      
                      // Action buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1.w,
                                ),
                              ),
                              child: TextButton(
            onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
            child: Text(
              'Cancel',
              style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF757575),
              ),
            ),
          ),
                            ),
                          ),
                          
                          SizedBox(width: 12.w),
                          
                          // Logout button (red)
                          Expanded(
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: Colors.red, // Red color for logout button
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
              Navigator.pushReplacement(
                context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
              );
              }
            },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
              'Logout',
              style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      AppIcons.logout,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
              ),
            ),
          ),
        ],
      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final locationService = Provider.of<LocationService>(context);
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        drawer: const SidebarDrawer(),
        floatingActionButton: null, // Explicitly remove any floating action button
        floatingActionButtonLocation: null, // Also remove the location to ensure no FAB appears
        body: SafeArea(
        child: Column(
          children: [
            // Header with white background
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF1B5993), // Navy blue border
                    width: 2.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Icon(
                        AppIcons.menu,
                        color: Color(0xFF1B5993),
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.profile,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B5993),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Settings functionality
                      },
                      icon: Icon(AppIcons.settings, color: Color(0xFF1B5993)),
                    ),
                  ],
                ),
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // User Profile Section
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              AppIcons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.welcomeBack,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Text(
                                _isLoadingUserInfo 
                                    ? 'Loading...'
                                    : authProvider.user?.name ?? _userInfo?.user.name ?? 'User',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              locationService.requestLocationPermission();
                            },
                            child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF20B2AA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF20B2AA).withOpacity(0.3),
                                  width: 1,
                                ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  if (locationService.isLoadingLocation)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF20B2AA)),
                                      ),
                                    )
                                  else
                                const Icon(
                                  AppIcons.place,
                                  color: Color(0xFF20B2AA),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    locationService.currentLocation,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: const Color(0xFF20B2AA),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    AppIcons.refresh,
                                    color: Color(0xFF20B2AA),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            
                    const SizedBox(height: 12),
            
                    // Menu Options Grid - Directly beneath profile image section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _buildGridButton(
                            icon: AppIcons.search,
                            title: 'Verified\nProperties',
                            count: _verifiedPropertiesCount,
                            onTap: () {
                              // TODO: Navigate to verified properties
                            },
                          ),
                          _buildGridButton(
                            icon: AppIcons.favoriteBorder,
                            title: 'My\nFavourites',
                            onTap: () {
                              // TODO: Navigate to favourites
                            },
                          ),
                          _buildGridButton(
                            icon: AppIcons.homeWork,
                            title: 'My\nProperties',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyListingsScreen()),
                            ),
                          ),
                          _buildGridButton(
                            icon: AppIcons.domainVerification,
                            title: 'Property Listing\nStatus',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PropertyListingStatusScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
            
                    // User Information Card
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final userData = authProvider.user ?? _userInfo?.user;
                        if (userData == null) return const SizedBox.shrink();
                        
                        return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildUserInfoOption(
                              'Email',
                              userData.email,
                              AppIcons.email,
                            ),
                            _buildModernMenuDivider(),
                            _buildUserInfoOption(
                              'Phone',
                              userData.phone,
                              AppIcons.phone,
                            ),
                            _buildModernMenuDivider(),
                            _buildUserInfoOption(
                              'CNIC',
                              userData.cnic,
                              AppIcons.creditCard,
                            ),
                            if (userData.address != null) ...[
                              _buildModernMenuDivider(),
                              _buildUserInfoOption(
                                'Address',
                                userData.address!,
                                AppIcons.place,
                              ),
                            ],
                            _buildModernMenuDivider(),
                            _buildModernMenuOption(
                              'Update Profile',
                              AppIcons.edit,
                              null,
                              _showUpdateProfileDialog,
                            ),
                            _buildModernMenuDivider(),
                            _buildModernMenuOption(
                              'Change Password',
                              AppIcons.lock,
                              null,
                              _showChangePasswordDialog,
                            ),
                          ],
                        ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Additional Options
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildModernMenuOption(
                            l10n.language,
                            AppIcons.language,
                            languageService.currentLanguageName,
                            _showLanguageSelector,
                          ),
                          _buildModernMenuDivider(),
                          _buildModernMenuOption(
                            l10n.contactUs,
                            AppIcons.phone,
                            null,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                            ),
                          ),
                          _buildModernMenuDivider(),
                          _buildModernMenuOption(
                            l10n.feedback,
                            AppIcons.thumbUp,
                            null,
                            _showFeedbackDialog,
                          ),
                        ],
                      ),
                    ),
            
                    const SizedBox(height: 20),
                    
                    // Logout Button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.logout,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.logout,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildUserInfoOption(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF20B2AA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF20B2AA),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildModernMenuOption(
    String title,
    IconData icon,
    String? subtitle,
    VoidCallback? onTap, {
    bool isClickable = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isClickable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF20B2AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF20B2AA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: const Color(0xFF20B2AA),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isClickable)
                Icon(
                  AppIcons.arrowForwardIos,
                  color: Colors.grey[400],
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernMenuDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildGridButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    int? count,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                count != null
                    ? Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF20B2AA),
                        ),
                      )
                    : Icon(
                        icon,
                        color: const Color(0xFF20B2AA),
                        size: 36,
                      ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZameenMenuOption(
    String title,
    IconData icon,
    String? subtitle,
    VoidCallback? onTap, {
    bool isClickable = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF00A651),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFF00A651),
              ),
            )
          : null,
      trailing: isClickable
          ? const Icon(
              AppIcons.arrowForwardIos,
              size: 16,
              color: Colors.grey,
            )
          : null,
      onTap: isClickable ? onTap : null,
    );
  }

  Widget _buildZameenMenuDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 56,
    );
  }
}

