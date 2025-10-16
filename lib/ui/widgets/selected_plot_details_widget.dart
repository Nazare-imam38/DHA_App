import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/plot_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/kuick_pay_service.dart';
import '../../core/services/booking_service.dart';
import '../../data/models/booking_model.dart';

/// Detailed plot information widget for the Selected tab in bottom sheet
class SelectedPlotDetailsWidget extends StatefulWidget {
  final PlotModel plot;
  final VoidCallback? onBookNow;
  final VoidCallback? onClearSelection;

  const SelectedPlotDetailsWidget({
    super.key,
    required this.plot,
    this.onBookNow,
    this.onClearSelection,
  });

  @override
  State<SelectedPlotDetailsWidget> createState() => _SelectedPlotDetailsWidgetState();
}

class _SelectedPlotDetailsWidgetState extends State<SelectedPlotDetailsWidget> {
  String _selectedPaymentPlan = 'Lump Sum';
  PaymentSummary? _paymentSummary;
  bool _isLoadingPaymentSummary = false;
  final KuickPayService _kuickPayService = KuickPayService();
  
  final Map<String, Map<String, dynamic>> _paymentPlans = {
    'Lump Sum': {
      'description': 'One-time payment',
      'price': 0, // Will be calculated from plot price
      'discount': 0,
    },
    '1 Year Plan': {
      'description': 'Installments',
      'price': 0, // Will be calculated
      'discount': 0.1, // 10% more
    },
    '2 Years Plan': {
      'description': 'Installments',
      'price': 0, // Will be calculated
      'discount': 0.2, // 20% more
    },
    '3 Years Plan': {
      'description': 'Installments',
      'price': 0, // Will be calculated
      'discount': 0.3, // 30% more
    },
  };

  @override
  void initState() {
    super.initState();
    _calculatePaymentPlans();
    _loadPaymentSummary();
  }

  void _calculatePaymentPlans() {
    final basePrice = double.tryParse(widget.plot.basePrice) ?? 0;
    
    setState(() {
      _paymentPlans['Lump Sum']!['price'] = basePrice;
      _paymentPlans['1 Year Plan']!['price'] = basePrice * 1.1;
      _paymentPlans['2 Years Plan']!['price'] = basePrice * 1.2;
      _paymentPlans['3 Years Plan']!['price'] = basePrice * 1.3;
    });
  }

  Future<void> _loadPaymentSummary() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn) {
      setState(() {
        _isLoadingPaymentSummary = true;
      });

      try {
        final basePrice = double.tryParse(widget.plot.basePrice) ?? 0;
        final summary = await _kuickPayService.getPaymentSummary(basePrice, _selectedPaymentPlan);
        
        setState(() {
          _paymentSummary = summary;
          _isLoadingPaymentSummary = false;
        });
      } catch (e) {
        print('Error loading payment summary: $e');
        setState(() {
          _isLoadingPaymentSummary = false;
        });
      }
    }
  }

  void _onPaymentPlanChanged(String plan) {
    setState(() {
      _selectedPaymentPlan = plan;
    });
    _loadPaymentSummary();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plot header
          _buildPlotHeader(),
          
          const SizedBox(height: 20),
          
          // Plot information
          _buildPlotInfo(),
          
          const SizedBox(height: 20),
          
          // Price section
          _buildPriceSection(),
          
          const SizedBox(height: 20),
          
          // Payment plans
          _buildPaymentPlans(),
          
          const SizedBox(height: 20),
          
          // Disclaimer
          _buildDisclaimer(),
          
          const SizedBox(height: 20),
          
          // Login section
          _buildLoginSection(),
          
          const SizedBox(height: 20),
          
          // Clear selection button
          _buildClearSelectionButton(),
        ],
      ),
    );
  }

  Widget _buildPlotHeader() {
    return Row(
      children: [
        Text(
          'Plot ${widget.plot.plotNo}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        _buildStatusChip(widget.plot.category, _getCategoryColor(widget.plot.category)),
        const SizedBox(width: 8),
        _buildStatusChip('Unsold', Colors.green),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPlotInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Size', widget.plot.catArea),
              _buildInfoRow('Phase/Sector', '${widget.plot.phase}/${widget.plot.sector}'),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Dimension', widget.plot.dimension ?? 'N/A'),
              _buildInfoRow('Street', widget.plot.streetNo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final basePrice = double.tryParse(widget.plot.basePrice) ?? 0;
    const tokenAmount = 250000.0; // Fixed token amount as per requirement
    
    return Container(
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
              const Text(
                'Lump Sum Price',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'PKR ${_formatPrice(basePrice)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Token Amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                'PKR ${_formatPrice(tokenAmount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Plans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        // Payment plan options
        ..._paymentPlans.entries.map((entry) {
          final isSelected = _selectedPaymentPlan == entry.key;
          final planData = entry.value;
          final price = planData['price'] as double;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentPlan = entry.key;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: entry.key,
                      groupValue: _selectedPaymentPlan,
                      onChanged: (value) {
                        _onPaymentPlanChanged(value!);
                      },
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue : Colors.black87,
                            ),
                          ),
                          Text(
                            planData['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.blue[700] : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'PKR ${_formatPrice(price)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        'Dimensions and area (oversize / undersize) may be changed until physical possession is handed over to the owner, charges related to oversize will be paid by the member as per prevailing rates / policies of DHAI-R. Prices will be inclusive of Govt Taxes and exclusive of DHA charges',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red[700],
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoggedIn) {
          return _buildSecurePlotSection();
        } else {
          return _buildLoginPromptSection();
        }
      },
    );
  }

  Widget _buildLoginPromptSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Login to Secure Plot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You must log in to secure this plot and pay the token amount.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Login to Secure Plot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurePlotSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Secure Your Plot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pay token amount to secure this plot. This is a non-refundable token payment (Adjustable in Down Payment).',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Payment method selection
          _buildPaymentMethodSection(),
          
          const SizedBox(height: 16),
          
          // Amount details
          if (_paymentSummary != null) _buildAmountDetails(),
          
          const SizedBox(height: 16),
          
          // Terms and conditions
          _buildTermsAndConditions(),
          
          const SizedBox(height: 16),
          
          // Pay button
          _buildPayButton(),
          
          const SizedBox(height: 8),
          
          // Post-payment info
          _buildPostPaymentInfo(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'KuickPay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'Credit-Debit',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Token Amount:'),
              Text(
                _paymentSummary!.formattedTokenAmount,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('KuickPay Fee:'),
              Text(
                _paymentSummary!.formattedKuickPayFee,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _paymentSummary!.formattedTotalAmount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return GestureDetector(
      onTap: () {
        // Handle terms and conditions
        print('Terms and Conditions tapped');
      },
      child: const Text(
        'Terms and Conditions',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoadingPaymentSummary ? null : _handlePayTokenAmount,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoadingPaymentSummary
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Pay Token Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildPostPaymentInfo() {
    return Text(
      'After payment, you can manage your plot and view details in your profile.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  void _handlePayTokenAmount() async {
    // Check authentication first
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      print('Reserving plot ${widget.plot.plotNo}');
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call reserve plot API
      final response = await _kuickPayService.reservePlot(
        widget.plot.id.toString(), // Using database ID, not plot number
        250135.0, // Total amount (250,000 + 135)
        'KuickPay',
        '0', // plan_type
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show booking success modal on the same page
      if (mounted) {
        _showBookingSuccessModal(context, response.data, widget.plot.plotNo);
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Check if it's an authentication error
      if (e.toString().contains('Unauthenticated') || e.toString().contains('not authenticated')) {
        _showLoginRequiredDialog();
      } else if (e.toString().contains('maximum limit of bookings') || e.toString().contains('complete your existing bookings')) {
        // Show booking limit alert
        _showBookingLimitDialog();
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reserve plot: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showBookingLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Booking Limit Reached',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have reached the maximum limit of bookings.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please complete your existing bookings before creating a new one.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can view and manage your existing bookings in the "My Bookings" section.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Login required header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2161B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2161B0).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: const Color(0xFF2161B0),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please Login to Reserve Plot',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2161B0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Login message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2161B0).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2161B0).withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF2161B0),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You need to be logged in to secure this plot.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2161B0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please login to continue with the reservation process.',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF2161B0).withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2161B0),
                        side: BorderSide(color: const Color(0xFF2161B0), width: 2),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate to login
                        widget.onBookNow?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2161B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Go to Login'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingSuccessModal(BuildContext context, ReservePlotData reservationData, String plotNumber) async {
    // Save booking first
    try {
      final booking = BookingModel.fromReservePlotData(reservationData, plotNumber);
      await BookingService.addBooking(booking);
      print('Booking saved successfully for plot $plotNumber');
    } catch (e) {
      print('Error saving booking: $e');
    }

    // Refresh user info to get updated reservations from server
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.getUserInfo();
      print('User info refreshed after plot reservation');
    } catch (e) {
      print('Error refreshing user info: $e');
    }

    // Show success modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Plot reserved successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Payment method tabs
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'KuickPay',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Credit-Debit',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Amount details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Token Amount:'),
                        Text(
                          'PKR 250,000',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('KuickPay Fee:'),
                        Text(
                          'PKR 135',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'PKR 250,135',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Terms and conditions
              const Text(
                'Terms and Conditions',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Payment information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2161B0).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2161B0).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2161B0),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // PSID/Challan
                    Row(
                      children: [
                        const Text('PSID/Challan:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2161B0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF2161B0).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    reservationData.psid,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2161B0),
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: reservationData.psid));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('PSID copied: ${reservationData.psid}'),
                                        backgroundColor: const Color(0xFF2161B0),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: const Color(0xFF2161B0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    Text(
                      '(Go to your banking app/kuick pay and enter PSID)',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2161B0).withOpacity(0.8),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          reservationData.formattedTotalAmount,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Method:'),
                        const Text('KuickPay'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Expiry warning
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.red[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your reservation will expire in 15 min if payment is not received.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    Text(
                      'Once paid, go to my bookings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO: Navigate to My Bookings page
                        print('Navigate to My Bookings');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Go to My Bookings'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearSelectionButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: widget.onClearSelection,
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[600],
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'Clear Selection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    // Format with commas for thousands
    return _formatNumberWithCommas(price);
  }

  String _formatNumberWithCommas(double number) {
    // Convert to int to remove decimal places
    int intNumber = number.round();
    
    // Add commas for thousands
    String numberStr = intNumber.toString();
    String result = '';
    
    for (int i = 0; i < numberStr.length; i++) {
      if (i > 0 && (numberStr.length - i) % 3 == 0) {
        result += ',';
      }
      result += numberStr[i];
    }
    
    return result;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'residential':
        return Colors.green;
      case 'commercial':
        return Colors.orange;
      case 'agricultural':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
