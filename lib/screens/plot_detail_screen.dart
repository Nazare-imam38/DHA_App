import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/plot_model.dart';

class PlotDetailScreen extends StatefulWidget {
  final PlotModel plot;

  const PlotDetailScreen({super.key, required this.plot});

  @override
  State<PlotDetailScreen> createState() => _PlotDetailScreenState();
}

class _PlotDetailScreenState extends State<PlotDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E3C90)),
                  ),
                  Expanded(
                      child: Text(
                        'Plot Details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E3C90),
                        ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Add favorite functionality
                    },
                    icon: const Icon(Icons.favorite_border, color: Color(0xFF1E3C90)),
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plot image/visual representation
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2ECC71).withOpacity(0.8),
                            const Color(0xFF1E3C90).withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.home_work,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Plot basic info card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Plot number and price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Plot ${widget.plot.plotNo}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E3C90),
                                  ),
                                ),
                              ),
                              Text(
                                widget.plot.formattedPrice,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2ECC71),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Plot specifications
                          _buildSpecRow('Size', widget.plot.catArea, Icons.straighten),
                          _buildSpecRow('Category', widget.plot.category, Icons.category),
                          _buildSpecRow('Area', widget.plot.catArea, Icons.area_chart),
                          _buildSpecRow('Phase', widget.plot.phase, Icons.location_city),
                          _buildSpecRow('Sector', 'Sector ${widget.plot.sector}', Icons.map),
                          _buildSpecRow('Street', 'St. ${widget.plot.streetNo}', Icons.streetview),
                          if (widget.plot.block != null)
                            _buildSpecRow('Block', widget.plot.block!, Icons.grid_view),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Status and token amount card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plot Status',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E3C90),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatusCard(
                                  'Status',
                                  widget.plot.status,
                                  _getStatusColor(widget.plot.status),
                                  Icons.info_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatusCard(
                                  'Token Amount',
                                  widget.plot.formattedTokenAmount,
                                  const Color(0xFFFF9800),
                                  Icons.account_balance_wallet,
                                ),
                              ),
                            ],
                          ),
                          
                          if (widget.plot.dimension != null) ...[
                            const SizedBox(height: 16),
                            _buildStatusCard(
                              'Dimension',
                              widget.plot.dimension!,
                              const Color(0xFF2196F3),
                              Icons.straighten,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tabs
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFF1E3C90),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: const Color(0xFF2ECC71),
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(text: 'Overview'),
                              Tab(text: 'Payment Plans'),
                              Tab(text: 'Location'),
                            ],
                          ),
                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildOverviewTab(),
                                _buildPaymentPlansTab(),
                                _buildLocationTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom action buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact functionality coming soon')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3C90),
                  side: const BorderSide(color: Color(0xFF1E3C90), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showBookingDialog();
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
                  'Book Now',
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
    );
  }

  Widget _buildSpecRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2ECC71), size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3C90),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plot Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3C90),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Plot Number', widget.plot.plotNo),
          _buildInfoRow('Size', widget.plot.catArea),
          _buildInfoRow('Category', widget.plot.category),
          _buildInfoRow('Phase', widget.plot.phase),
          _buildInfoRow('Sector', 'Sector ${widget.plot.sector}'),
          _buildInfoRow('Street', 'St. ${widget.plot.streetNo}'),
          if (widget.plot.block != null)
            _buildInfoRow('Block', widget.plot.block!),
          _buildInfoRow('Status', widget.plot.status),
          _buildInfoRow('Base Price', widget.plot.formattedPrice),
          _buildInfoRow('Token Amount', widget.plot.formattedTokenAmount),
          
          if (widget.plot.remarks != null && widget.plot.remarks!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Remarks',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3C90),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.plot.remarks!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentPlansTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Installment Plans',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3C90),
            ),
          ),
          const SizedBox(height: 16),
          
          if (widget.plot.availablePaymentPlans.isNotEmpty)
            ...widget.plot.availablePaymentPlans.map((plan) => 
              _buildPaymentPlanCard(plan['period']!, plan['formatted']!)
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No installment plans available',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3C90),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildLocationCard(
            'Address',
            'St. ${widget.plot.streetNo}, Sector ${widget.plot.sector}',
            Icons.location_on,
            const Color(0xFF2ECC71),
          ),
          
          _buildLocationCard(
            'Phase',
            widget.plot.phase,
            Icons.location_city,
            const Color(0xFF1E3C90),
          ),
          
          if (widget.plot.latitude != null && widget.plot.longitude != null)
            _buildLocationCard(
              'Coordinates',
              '${widget.plot.latitude!.toStringAsFixed(6)}, ${widget.plot.longitude!.toStringAsFixed(6)}',
              Icons.my_location,
              const Color(0xFF2196F3),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3C90),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPlanCard(String period, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E3C90),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2ECC71),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF2ECC71);
      case 'sold':
        return const Color(0xFFE74C3C);
      case 'reserved':
        return const Color(0xFFFF9800);
      case 'unsold':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _showBookingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Booking Plot ${widget.plot.plotNo}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3C90),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Booking functionality coming soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
