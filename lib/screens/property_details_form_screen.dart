import 'package:flutter/material.dart';
import 'property_review_screen.dart';

class PropertyDetailsFormScreen extends StatefulWidget {
  const PropertyDetailsFormScreen({super.key});

  @override
  State<PropertyDetailsFormScreen> createState() => _PropertyDetailsFormScreenState();
}

class _PropertyDetailsFormScreenState extends State<PropertyDetailsFormScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _expandController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _expandAnimation;

  // Form controllers
  final TextEditingController _propertyTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // Form state
  String _selectedPropertyType = 'House';
  String _selectedPhase = 'Phase 1';
  String _selectedCondition = 'Excellent';
  bool _hasParking = false;
  bool _hasGarden = false;
  bool _hasSecurity = false;
  bool _showQuickActions = false;

  final List<String> _propertyTypes = ['House', 'Flat', 'Plot', 'Commercial'];
  final List<String> _phases = ['Phase 1', 'Phase 2', 'Phase 3', 'Phase 4', 'Phase 5', 'Phase 6', 'Phase 7'];
  final List<String> _conditions = ['Excellent', 'Good', 'Fair', 'Needs Renovation'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _expandController.dispose();
    _propertyTitleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5993),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5993),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PROPERTY DETAILS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5993),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
          
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Process Indicator
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F4FD),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1B5993).withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1B5993),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '3',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Property Details',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1B5993),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Main Title
                        const Text(
                          'Property Information',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B5993),
                            letterSpacing: -0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Subtitle
                        Text(
                          'Provide detailed information about your property',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Compact Form Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B5993).withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Property Title
                              _buildCompactFormField(
                                controller: _propertyTitleController,
                                label: 'Property Title',
                                hint: 'e.g., Beautiful 3 Bedroom House',
                                icon: Icons.title,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Property Type and Phase Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactDropdownField(
                                      label: 'Property Type',
                                      value: _selectedPropertyType,
                                      items: _propertyTypes,
                                      onChanged: (value) => setState(() => _selectedPropertyType = value!),
                                      icon: Icons.home,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildCompactDropdownField(
                                      label: 'DHA Phase',
                                      value: _selectedPhase,
                                      items: _phases,
                                      onChanged: (value) => setState(() => _selectedPhase = value!),
                                      icon: Icons.location_on,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Price and Size Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactFormField(
                                      controller: _priceController,
                                      label: 'Price (PKR)',
                                      hint: '5,000,000',
                                      icon: Icons.attach_money,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildCompactFormField(
                                      controller: _sizeController,
                                      label: 'Size',
                                      hint: '3 Marla',
                                      icon: Icons.straighten,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Address
                              _buildCompactFormField(
                                controller: _addressController,
                                label: 'Address',
                                hint: 'Enter complete address',
                                icon: Icons.location_city,
                                maxLines: 2,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Description
                              _buildCompactFormField(
                                controller: _descriptionController,
                                label: 'Description',
                                hint: 'Describe your property in detail',
                                icon: Icons.description,
                                maxLines: 3,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Condition Dropdown
                              _buildCompactDropdownField(
                                label: 'Property Condition',
                                value: _selectedCondition,
                                items: _conditions,
                                onChanged: (value) => setState(() => _selectedCondition = value!),
                                icon: Icons.build,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Features Section
                              const Text(
                                'Property Features',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B5993),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Feature Checkboxes - Compact Row Layout
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactFeatureCheckbox('Parking', _hasParking, Icons.local_parking),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildCompactFeatureCheckbox('Garden', _hasGarden, Icons.yard),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildCompactFeatureCheckbox('Security', _hasSecurity, Icons.security),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Contact Information
                              _buildCompactFormField(
                                controller: _contactController,
                                label: 'Contact Number',
                                hint: '+92-300-1234567',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  // Back Button
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF1B5993),
                                          width: 2,
                                        ),
                                      ),
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_ios,
                                              color: const Color(0xFF1B5993),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Back',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1B5993),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 12),
                                  
                                  // Continue Button
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B5993),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF1B5993).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: TextButton(
                                        onPressed: _handleContinue,
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Continue',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 16,
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
                        
                        const SizedBox(height: 20),
                        
                        // Collapsible Quick Actions Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header with expand/collapse
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showQuickActions = !_showQuickActions;
                                    if (_showQuickActions) {
                                      _expandController.forward();
                                    } else {
                                      _expandController.reverse();
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1B5993),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.lightbulb_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Quick Actions & Support',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1B5993),
                                          ),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: _showQuickActions ? 0.5 : 0.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF1B5993),
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Expandable content
                              if (_showQuickActions) ...[
                                const Divider(color: Colors.grey),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildCompactQuickActionButton(
                                              icon: Icons.help_outline_rounded,
                                              title: 'Get Help',
                                              onTap: () => _showHelpDialog(),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildCompactQuickActionButton(
                                              icon: Icons.calculate_rounded,
                                              title: 'Price Calculator',
                                              onTap: () => _showPriceCalculator(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildCompactQuickActionButton(
                                              icon: Icons.document_scanner_rounded,
                                              title: 'Required Docs',
                                              onTap: () => _showRequiredDocuments(),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildCompactQuickActionButton(
                                              icon: Icons.schedule_rounded,
                                              title: 'Timeline',
                                              onTap: () => _showTimelineInfo(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B5993),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1B5993),
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1B5993),
                  size: 16,
                ),
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B5993),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFeatureCheckbox(String title, bool value, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (title == 'Parking') {
            _hasParking = !_hasParking;
          } else if (title == 'Garden') {
            _hasGarden = !_hasGarden;
          } else if (title == 'Security') {
            _hasSecurity = !_hasSecurity;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF1B5993).withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? const Color(0xFF1B5993) : Colors.grey[300]!,
            width: value ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF1B5993) : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Icon(
              icon,
              color: const Color(0xFF1B5993),
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: value ? const Color(0xFF1B5993) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactQuickActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1B5993),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5993),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    // Validate form
    if (_propertyTitleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _sizeController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Navigate to review screen
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PropertyReviewScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Property Listing Help',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Tips for listing your property:\n\n• Use clear, descriptive titles\n• Include all relevant features\n• Provide accurate pricing\n• Add high-quality photos\n• Be honest about condition\n• Include contact information',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPriceCalculator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Price Calculator',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Market price estimation:\n\n• Location: Phase 1-7 premium\n• Size: Marla/Kanal rates\n• Condition: Excellent/Good/Fair\n• Features: Parking, Garden, Security\n• Market trends: +8-12% annually\n\nUse DHA official rates as reference.',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showRequiredDocuments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Required Documents',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Documents needed for property listing:\n\n• Property ownership documents\n• DHA membership card\n• CNIC/NICOP\n• Property photos (5-10 images)\n• NOC (if applicable)\n• Utility bills\n• Any other relevant documents',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showTimelineInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Listing Timeline',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        content: const Text(
          'Expected timeline for property listing:\n\n• Form completion: 10-15 minutes\n• Document upload: 5-10 minutes\n• Review & submit: 5-10 minutes\n• Verification: 1-2 hours\n• Live listing: 24-48 hours\n\nTotal: 2-3 days maximum',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}