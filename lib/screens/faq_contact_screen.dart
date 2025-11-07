import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/widgets/app_icons.dart';

class FAQContactScreen extends StatefulWidget {
  const FAQContactScreen({super.key});

  @override
  State<FAQContactScreen> createState() => _FAQContactScreenState();
}

class _FAQContactScreenState extends State<FAQContactScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I book a plot in DHA?',
      'answer': 'To book a plot in DHA, you can browse available properties through our app, select your preferred plot, and follow the booking process. You\'ll need to provide your personal information and make the required down payment.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'We accept various payment methods including bank transfers, credit/debit cards, and mobile payment services like JazzCash and EasyPaisa. All transactions are secure and encrypted.',
    },
    {
      'question': 'Can I visit the plot before booking?',
      'answer': 'Yes, you can schedule a site visit through our app. Simply select the plot you\'re interested in and request a site visit. Our team will arrange a convenient time for you.',
    },
    {
      'question': 'What documents are required for booking?',
      'answer': 'You\'ll need a valid CNIC, proof of income, and bank statements. Additional documents may be required depending on the payment plan you choose.',
    },
    {
      'question': 'Are there any hidden charges?',
      'answer': 'No, all charges are clearly displayed during the booking process. The final price includes the plot cost, registration fees, and applicable taxes. No hidden charges are added.',
    },
    {
      'question': 'How long does the booking process take?',
      'answer': 'The booking process typically takes 1-2 business days after all required documents are submitted and payment is confirmed. You\'ll receive updates via SMS and email.',
    },
    {
      'question': 'Can I cancel my booking?',
      'answer': 'Yes, you can cancel your booking within 7 days of confirmation. However, cancellation fees may apply depending on the stage of the booking process.',
    },
    {
      'question': 'What amenities are available in DHA?',
      'answer': 'DHA offers world-class amenities including schools, hospitals, shopping centers, parks, sports facilities, and excellent road connectivity. Each phase has its own unique features.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        title: Text(
          'FAQ & Contact',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3C90),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFF2ECC71),
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions about DHA properties and booking process.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // FAQ Items
          ..._faqs.asMap().entries.map((entry) {
            return _buildFAQItem(entry.value, entry.key);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Have questions? Send us a message and we\'ll get back to you soon.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Contact Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.inter(color: const Color(0xFF222222)),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      prefixIcon: Icon(AppIcons.person, color: Color(0xFF1E3C90)),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(color: const Color(0xFF222222)),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      prefixIcon: Icon(AppIcons.email, color: Color(0xFF1E3C90)),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Message Field
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    style: GoogleFonts.inter(color: const Color(0xFF222222)),
                    decoration: InputDecoration(
                      labelText: 'Message',
                      labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 120),
                        child: Icon(AppIcons.message, color: Color(0xFF1E3C90)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message sent successfully! We\'ll get back to you soon.'),
                              backgroundColor: Color(0xFF2ECC71),
                            ),
                          );
                          _nameController.clear();
                          _emailController.clear();
                          _messageController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Send Message',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildContactInfo(
                    AppIcons.place,
                    'Address',
                    'DHA Islamabad-Rawalpindi\nPhase 1, Commercial Area\nIslamabad, Pakistan',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildContactInfo(
                    AppIcons.phone,
                    'Phone',
                    '+92-51-1234567',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildContactInfo(
                    AppIcons.email,
                    'Email',
                    'info@dhamarketplace.com',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildContactInfo(
                    AppIcons.accessTime,
                    'Working Hours',
                    'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 9:00 AM - 2:00 PM',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF222222),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
        iconColor: const Color(0xFF2ECC71),
        collapsedIconColor: const Color(0xFF1E3C90),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String title, String info) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF2ECC71),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
