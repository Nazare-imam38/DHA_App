import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import 'sidebar_drawer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedFilter = 'All';
  
  final List<String> _filters = ['All', 'Pending', 'Paid', 'Cancelled', 'Completed'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    
    String _getTranslatedFilter(String filter) {
      switch (filter) {
        case 'All':
          return l10n.all;
        case 'Pending':
          return l10n.pending;
        case 'Paid':
          return l10n.paid;
        case 'Cancelled':
          return l10n.cancelled;
        case 'Completed':
          return l10n.completed;
        default:
          return filter;
      }
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const SidebarDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header with DHA Marketplace gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            l10n.myBookings,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showFilterBottomSheet();
                          },
                          icon: const Icon(Icons.filter_list, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.searchBookings,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Filter chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    bool isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? const LinearGradient(
                              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ) : null,
                            color: isSelected ? null : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: const Color(0xFF1E3C90).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                        child: Text(
                          _getTranslatedFilter(filter),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Bookings list
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBookingsList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    final bookings = [
      {
        'id': 'BK001',
        'type': 'Plot',
        'title': '10 Marla Plot in DHA Phase 5',
        'location': 'DHA Phase 5, Lahore',
        'price': 'PKR 85,00,000',
        'bookingDate': '2024-01-15',
        'paymentStatus': 'Paid',
        'bookingStatus': 'Confirmed',
        'plotNumber': 'A-123',
        'phase': 'Phase 5',
        'size': '10 Marla',
        'downPayment': 'PKR 8,50,000',
        'remainingAmount': 'PKR 76,50,000',
        'nextDueDate': '2024-02-15',
        'paymentMethod': 'Bank Transfer',
        'transactionId': 'TXN123456789',
      },
      {
        'id': 'BK002',
        'type': 'Home',
        'title': '5 Marla House in DHA Phase 2',
        'location': 'DHA Phase 2, Lahore',
        'price': 'PKR 1,20,00,000',
        'bookingDate': '2024-01-10',
        'paymentStatus': 'Pending',
        'bookingStatus': 'Under Review',
        'plotNumber': 'B-456',
        'phase': 'Phase 2',
        'size': '5 Marla',
        'downPayment': 'PKR 12,00,000',
        'remainingAmount': 'PKR 1,08,00,000',
        'nextDueDate': '2024-01-25',
        'paymentMethod': 'Credit Card',
        'transactionId': 'TXN987654321',
      },
      {
        'id': 'BK003',
        'type': 'Commercial',
        'title': 'Office Space in DHA Commercial',
        'location': 'DHA Commercial, Lahore',
        'price': 'PKR 2,50,00,000',
        'bookingDate': '2024-01-05',
        'paymentStatus': 'Paid',
        'bookingStatus': 'Completed',
        'plotNumber': 'C-789',
        'phase': 'Commercial',
        'size': '2000 sq ft',
        'downPayment': 'PKR 25,00,000',
        'remainingAmount': 'PKR 0',
        'nextDueDate': 'N/A',
        'paymentMethod': 'Bank Transfer',
        'transactionId': 'TXN456789123',
      },
      {
        'id': 'BK004',
        'type': 'Plot',
        'title': '8 Marla Plot in DHA Phase 8',
        'location': 'DHA Phase 8, Lahore',
        'price': 'PKR 68,00,000',
        'bookingDate': '2024-01-20',
        'paymentStatus': 'Cancelled',
        'bookingStatus': 'Cancelled',
        'plotNumber': 'D-321',
        'phase': 'Phase 8',
        'size': '8 Marla',
        'downPayment': 'PKR 0',
        'remainingAmount': 'PKR 68,00,000',
        'nextDueDate': 'N/A',
        'paymentMethod': 'N/A',
        'transactionId': 'N/A',
      },
    ];

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_online,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookings Yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start booking properties to see them here',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3C90),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Browse Properties',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, index);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    Color statusColor = _getStatusColor(booking['paymentStatus']);
    Color bookingStatusColor = _getBookingStatusColor(booking['bookingStatus']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header with booking ID and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                      'Booking #${booking['id']}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                          fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                      Text(
                      booking['bookingDate'],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                Text(
                  booking['price'],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3C90),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
          
          // Property details
            Row(
              children: [
                Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                    color: _getTypeColor(booking['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPropertyIcon(booking['type']),
                    color: _getTypeColor(booking['type']),
                        size: 20,
                      ),
                    ),
                const SizedBox(width: 12),
                Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                        booking['title'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                      const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                            size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                              booking['location'],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                          color: Colors.grey[600],
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
            
            const SizedBox(height: 16),
            
            // Status badges and action buttons - responsive layout
            Column(
              children: [
                // Status badges row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        booking['paymentStatus'],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: bookingStatusColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: bookingStatusColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        booking['bookingStatus'],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Action buttons row
                Row(
                  children: [
                    if (booking['paymentStatus'] == 'Paid')
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3C90).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _printReceipt(booking),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                                  const Icon(Icons.print, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Print',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (booking['paymentStatus'] == 'Paid') const SizedBox(width: 8),
                    if (booking['paymentStatus'] == 'Pending')
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3498DB), Color(0xFF1E3C90)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3498DB).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _makePayment(booking),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.payment, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pay',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (booking['paymentStatus'] == 'Pending') const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF1E3C90), width: 1.5),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3C90).withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _viewDetails(booking),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.visibility, size: 14, color: Color(0xFF1E3C90)),
                                const SizedBox(width: 4),
                                Text(
                                  'Details',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E3C90),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        ],
                ),
              ],
            ),
          ],
          ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPropertyIcon(String type) {
    switch (type) {
      case 'Home':
        return Icons.home;
      case 'Plot':
        return Icons.landscape;
      case 'Commercial':
        return Icons.business;
      case 'Project':
        return Icons.home_work;
      default:
        return Icons.home;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Home':
        return Color(0xFF1E3C90);
      case 'Plot':
        return Colors.green;
      case 'Commercial':
        return Colors.orange;
      case 'Project':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      case 'Completed':
        return Color(0xFF1E3C90);
      default:
        return Colors.grey;
    }
  }

  Color _getBookingStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Under Review':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      case 'Completed':
        return Color(0xFF1E3C90);
      default:
        return Colors.grey;
    }
  }

  void _printReceipt(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Print Receipt',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking #${booking['id']}',
              style: TextStyle(
                fontFamily: 'Inter',
            fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Property: ${booking['title']}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
            color: Colors.grey[600],
          ),
            ),
            Text(
              'Amount: ${booking['price']}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Payment Method: ${booking['paymentMethod']}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Transaction ID: ${booking['transactionId']}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
            color: Colors.grey[600],
          ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate printing
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Receipt sent to printer'),
                  backgroundColor: const Color(0xFF1E3C90),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3C90),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Print',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _makePayment(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Make Payment',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking #${booking['id']}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ${booking['downPayment']}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3C90),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Payment Method:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildPaymentOption('Credit Card', Icons.credit_card),
            _buildPaymentOption('Bank Transfer', Icons.account_balance),
            _buildPaymentOption('JazzCash', Icons.phone_android),
            _buildPaymentOption('EasyPaisa', Icons.mobile_friendly),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate payment
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Payment initiated successfully'),
                  backgroundColor: const Color(0xFF1E3C90),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3C90),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Pay Now',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            method,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _viewDetails(Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(booking: booking),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter Bookings',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('All Bookings', Icons.list),
              _buildFilterOption('Pending Payment', Icons.pending),
              _buildFilterOption('Paid Bookings', Icons.check_circle),
              _buildFilterOption('Cancelled Bookings', Icons.cancel),
              _buildFilterOption('Completed Bookings', Icons.done_all),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3C90),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Receipt Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Company Logo/Title
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.home_work,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DHA MARKETPLACE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Property Booking Receipt',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Booking #${booking['id']}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Receipt Content
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Information Section
                    _buildReceiptSection(
                      'Property Information',
                      Icons.home,
                      [
                        _buildReceiptRow('Property Type', booking['type'], true),
                        _buildReceiptRow('Property Title', booking['title'], false),
                        _buildReceiptRow('Location', booking['location'], false),
                        _buildReceiptRow('Plot Number', booking['plotNumber'], true),
                        _buildReceiptRow('Phase', booking['phase'], true),
                        _buildReceiptRow('Size', booking['size'], true),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Financial Information Section
                    _buildReceiptSection(
                      'Financial Details',
                      Icons.account_balance_wallet,
                      [
                        _buildReceiptRow('Total Price', booking['price'], true, isPrice: true),
                        _buildReceiptRow('Down Payment', booking['downPayment'], true, isPrice: true),
                        _buildReceiptRow('Remaining Amount', booking['remainingAmount'], true, isPrice: true),
                        if (booking['nextDueDate'] != 'N/A')
                          _buildReceiptRow('Next Due Date', booking['nextDueDate'], true),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Payment Information Section
                    _buildReceiptSection(
                      'Payment Information',
                      Icons.payment,
                      [
                        _buildReceiptRow('Payment Status', booking['paymentStatus'], true, isStatus: true),
                        _buildReceiptRow('Booking Status', booking['bookingStatus'], true, isStatus: true),
                        _buildReceiptRow('Payment Method', booking['paymentMethod'], true),
                        if (booking['transactionId'] != 'N/A')
                          _buildReceiptRow('Transaction ID', booking['transactionId'], true),
                        _buildReceiptRow('Booking Date', booking['bookingDate'], true),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Receipt Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Receipt Generated:',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                DateTime.now().toString().split(' ')[0],
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thank you for choosing DHA Marketplace',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E3C90),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _printReceipt(context),
                            icon: const Icon(Icons.print, size: 20),
                            label: Text(
                              'Print Receipt',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3C90),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareReceipt(context),
                            icon: const Icon(Icons.share, size: 20),
                            label: Text(
                              'Share',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E3C90),
                              side: const BorderSide(color: Color(0xFF1E3C90), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildReceiptSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3C90).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1E3C90),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isImportant, {bool isPrice = false, bool isStatus = false}) {
    Color valueColor = Colors.black;
    FontWeight valueWeight = FontWeight.w500;
    
    if (isPrice) {
      valueColor = const Color(0xFF1E3C90);
      valueWeight = FontWeight.w700;
    } else if (isStatus) {
      if (value == 'Paid' || value == 'Confirmed' || value == 'Completed') {
        valueColor = Colors.green;
      } else if (value == 'Pending' || value == 'Under Review') {
        valueColor = Colors.orange;
      } else if (value == 'Cancelled') {
        valueColor = Colors.red;
      }
      valueWeight = FontWeight.w600;
    } else if (isImportant) {
      valueWeight = FontWeight.w600;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: valueColor,
                fontWeight: valueWeight,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _printReceipt(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt sent to printer'),
        backgroundColor: const Color(0xFF1E3C90),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _shareReceipt(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt shared successfully'),
        backgroundColor: const Color(0xFF1E3C90),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}