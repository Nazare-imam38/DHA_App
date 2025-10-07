import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/kuick_pay_service.dart';
import '../../core/services/booking_service.dart';
import '../../data/models/booking_model.dart';

/// Success screen shown after plot reservation
class PlotReservationSuccessScreen extends StatefulWidget {
  final ReservePlotData reservationData;
  final String plotNumber;
  final VoidCallback? onGoToBookings;

  const PlotReservationSuccessScreen({
    super.key,
    required this.reservationData,
    required this.plotNumber,
    this.onGoToBookings,
  });

  @override
  State<PlotReservationSuccessScreen> createState() => _PlotReservationSuccessScreenState();
}

class _PlotReservationSuccessScreenState extends State<PlotReservationSuccessScreen> {
  String _selectedPaymentMethod = 'KuickPay';

  @override
  void initState() {
    super.initState();
    _saveBooking();
  }

  Future<void> _saveBooking() async {
    try {
      // Create booking from reservation data
      final booking = BookingModel.fromReservePlotData(
        widget.reservationData,
        widget.plotNumber, // Use actual plot number for display
      );
      
      // Save to local storage
      await BookingService.addBooking(booking);
      print('Booking saved successfully for plot ${widget.plotNumber}');
    } catch (e) {
      print('Error saving booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: Stack(
        children: [
          // Background with map blur effect
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E3C90),
                  Color(0xFF20B2AA),
                ],
              ),
            ),
          ),
          
          // Main content overlay
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
                    // Header with app branding
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu,
                            color: const Color(0xFF1E3C90),
                            size: 24,
                          ),
                          Expanded(
                            child: Text(
                              'DHA PROJECTS MAP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E3C90),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: const Color(0xFF1E3C90),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Main payment overlay
            Container(
                      padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
              ),
              child: Column(
                children: [
                          // Success message with green banner
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                                  color: const Color(0xFF00A651),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Plot reserved successfully!',
                        style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF00A651),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Payment method selection
                          _buildPaymentMethodSelection(),
                          
                          const SizedBox(height: 20),
                          
                          // Amount summary
                          _buildAmountSummary(),
                          
                          const SizedBox(height: 16),
                          
                          // Terms and conditions
                          _buildTermsAndConditions(),
                          
                          const SizedBox(height: 20),
                          
                          // Payment information section
                          _buildPaymentInformationSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Action buttons
                          _buildActionButtons(),
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
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodButton(
                'KuickPay',
                _selectedPaymentMethod == 'KuickPay',
                () => setState(() => _selectedPaymentMethod = 'KuickPay'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentMethodButton(
                'Credit-Debit',
                _selectedPaymentMethod == 'Credit-Debit',
                () => setState(() => _selectedPaymentMethod = 'Credit-Debit'),
                        ),
                      ),
                    ],
                  ),
                ],
    );
  }

  Widget _buildPaymentMethodButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3C90) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3C90) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildAmountRow('Token Amount:', 'PKR 250,000', false),
          const SizedBox(height: 8),
          _buildAmountRow('KuickPay Fee:', 'PKR 135', false),
          const Divider(height: 20),
          _buildAmountRow('Total Amount:', 'PKR 250,135', true),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFF00A651) : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return GestureDetector(
      onTap: () {
        // Handle terms and conditions
      },
      child: Text(
        'Terms and Conditions',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E3C90),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildPaymentInformationSection() {
    return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A651).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Information',
                    style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00A651),
            ),
          ),
          const SizedBox(height: 16),
          
          // PSID/Challan with copy button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PSID/Challan: ${widget.reservationData.psid}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                    const SizedBox(height: 4),
                  Text(
                    '(Go to your banking app/kuick pay and enter PSID)',
                    style: TextStyle(
                        fontFamily: 'Inter',
                      fontSize: 12,
                        color: const Color(0xFF00A651),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _copyToClipboard(context, widget.reservationData.psid),
                child: Icon(
                  Icons.copy,
                  size: 18,
                  color: const Color(0xFF1E3C90),
                ),
              ),
            ],
                  ),
                  
                  const SizedBox(height: 12),
                  
          _buildInfoRow('Amount:', widget.reservationData.formattedTotalAmount),
          const SizedBox(height: 8),
          _buildInfoRow('Method:', _selectedPaymentMethod),
          
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
                      fontFamily: 'Inter',
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
              fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onGoToBookings,
                      style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3C90),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                        ),
              elevation: 0,
                      ),
            child: Text(
                        'Go to My Bookings',
                        style: TextStyle(
                fontFamily: 'Poppins',
                          fontSize: 16,
                fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopyButton = false, VoidCallback? onCopy}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (showCopyButton) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(
                    Icons.copy,
                    size: 18,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PSID copied to clipboard: $text'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
