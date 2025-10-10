import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> with TickerProviderStateMixin {
  // Filter states
  String? _selectedEvent = 'DHA Phase Launch';
  String? _selectedPlotType = 'Residential';
  String? _selectedDhaPhase = 'RVS';
  RangeValues _priceRange = const RangeValues(1000000, 5000000);
  String? _selectedPlotSize = '5 Marla';
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      shape: const CircleBorder(),
                    ),
                  ),
                          Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                          color: const Color(0xFF1E3C90).withOpacity(0.3),
                          blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                        const Icon(Icons.tune, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                                          Text(
                          '3',
                                            style: GoogleFonts.inter(
                            fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            
            // Main Filters Card - Web app style compact design
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Filters Header - Web app premium styling
                    Container(
                      padding: const EdgeInsets.all(16),
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: Color(0xFF1E3C90),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                  'Filters',
                                    style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E3C90),
                                    ),
                                  ),
                                  Text(
                                  'Refine your search',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                    color: const Color(0xFF1E3C90).withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3C90).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Filter Options - Web app compact spacing
                  Expanded(
                    child: ClipRect(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                        children: [
                          _buildFilterRow(
                            icon: Icons.event,
                            title: 'Select Event',
                            badge: _selectedEvent != null ? 'Selected' : null,
                            gradientColors: [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
                            onTap: () => _showEventDialog(),
                          ),
                          const SizedBox(height: 6),
                          _buildFilterRow(
                            icon: Icons.attach_money,
                            title: 'Price Range',
                            gradientColors: [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
                            onTap: () => _showPriceDialog(),
                          ),
                          const SizedBox(height: 6),
                          _buildFilterRow(
                            icon: Icons.home,
                            title: 'Plot Type',
                            badge: _selectedPlotType != null ? '1' : null,
                            gradientColors: [const Color(0xFF1E3C90), const Color(0xFF20B2AA)],
                            onTap: () => _showPlotTypeDialog(),
                          ),
                          const SizedBox(height: 6),
                          _buildFilterRow(
                            icon: Icons.location_on,
                            title: 'DHA Phase',
                            badge: _selectedDhaPhase != null ? 'RVS' : null,
                            gradientColors: [const Color(0xFFF44336), const Color(0xFFEF5350)],
                            onTap: () => _showDhaPhaseDialog(),
                          ),
                          const SizedBox(height: 6),
                          _buildFilterRow(
                            icon: Icons.straighten,
                            title: 'Plot Size',
                            gradientColors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
                            onTap: () => _showPlotSizeDialog(),
                          ),
                          
                          // Active Filters Section - Web app compact style
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                Text(
                                      'Active Filters',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_up,
                                      color: Color(0xFF9CA3AF),
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Active Filter Tags - Web app style
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _buildActiveFilterTag('All Plots'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildFilterRow({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
    List<Color>? gradientColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Icon with premium gradient background - Web app style
          Container(
              width: 36,
              height: 36,
            decoration: BoxDecoration(
                gradient: gradientColors != null 
                    ? LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [const Color(0xFF1E3C90), const Color(0xFF20B2AA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: (gradientColors?.first ?? const Color(0xFF1E3C90)).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                ),
              ],
            ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            
            // Title
            Expanded(
                      child: Text(
                title,
                        style: GoogleFonts.inter(
                  fontSize: 14,
                          fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
            
            // Badge or Chevron with premium styling
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                      ),
                      child: Text(
                  badge,
                        style: GoogleFonts.inter(
                    fontSize: 10,
                          fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF9CA3AF),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterTag(String text, {bool isRemovable = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E3C90), const Color(0xFF20B2AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3C90).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (isRemovable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                // Remove filter logic here
              },
              child: Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Event',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('DHA Phase Launch', _selectedEvent),
            _buildDialogOption('New Project Launch', _selectedEvent),
            _buildDialogOption('Plot Auction', _selectedEvent),
            _buildDialogOption('None', _selectedEvent),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Price Range',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 10000000,
              divisions: 100,
              activeColor: const Color(0xFF2E7D32),
              onChanged: (values) {
        setState(() {
                  _priceRange = values;
        });
      },
            ),
            Text(
              'PKR ${_priceRange.start.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} - PKR ${_priceRange.end.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showPlotTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Plot Type',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Residential', _selectedPlotType),
            _buildDialogOption('Commercial', _selectedPlotType),
            _buildDialogOption('Farm House', _selectedPlotType),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDhaPhaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'DHA Phase',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('RVS', _selectedDhaPhase),
            _buildDialogOption('Phase 1', _selectedDhaPhase),
            _buildDialogOption('Phase 2', _selectedDhaPhase),
            _buildDialogOption('Phase 3', _selectedDhaPhase),
            _buildDialogOption('Phase 4', _selectedDhaPhase),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPlotSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Plot Size',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('3 Marla', _selectedPlotSize),
            _buildDialogOption('5 Marla', _selectedPlotSize),
            _buildDialogOption('7 Marla', _selectedPlotSize),
            _buildDialogOption('10 Marla', _selectedPlotSize),
            _buildDialogOption('1 Kanal', _selectedPlotSize),
            _buildDialogOption('2 Kanal', _selectedPlotSize),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption(String option, String? selectedValue) {
    final isSelected = option == selectedValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedValue == _selectedEvent) _selectedEvent = option;
          if (selectedValue == _selectedPlotType) _selectedPlotType = option;
          if (selectedValue == _selectedDhaPhase) _selectedDhaPhase = option;
          if (selectedValue == _selectedPlotSize) _selectedPlotSize = option;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          ),
        ),
          child: Text(
          option,
            style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}
