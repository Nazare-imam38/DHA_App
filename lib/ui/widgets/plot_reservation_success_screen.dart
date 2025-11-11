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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Modern header with app theme
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF1B5993), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5993).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5993),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DHA MARKETPLACE',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1B5993),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Plot Reservation',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF20B2AA),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF20B2AA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Main payment card with white background and app theme
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFF1B5993).withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Enhanced success message with animation
                      _buildEnhancedSuccessMessage(),
                      
                      const SizedBox(height: 32),
                      
                      // Payment method selection with modern design
                      _buildEnhancedPaymentMethodSelection(),
                      
                      const SizedBox(height: 28),
                      
                      // Amount summary with better styling
                      _buildEnhancedAmountSummary(),
                      
                      const SizedBox(height: 20),
                      
                      // Terms and conditions with better styling
                      _buildEnhancedTermsAndConditions(),
                      
                      const SizedBox(height: 28),
                      
                      // Payment information section with modern design
                      _buildEnhancedPaymentInformationSection(),
                      
                      const SizedBox(height: 32),
                      
                      // Action buttons with enhanced design
                      _buildEnhancedActionButtons(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // Enhanced success message with animation
  Widget _buildEnhancedSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B5993),
            Color(0xFF20B2AA),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5993).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plot Reserved Successfully!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your plot is now reserved. Complete payment to confirm.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced payment method selection
  Widget _buildEnhancedPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5993),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildEnhancedPaymentMethodButton(
                'KuickPay',
                Icons.account_balance_wallet,
                _selectedPaymentMethod == 'KuickPay',
                () => setState(() => _selectedPaymentMethod = 'KuickPay'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedPaymentMethodButton(
                'Credit-Debit',
                Icons.credit_card,
                _selectedPaymentMethod == 'Credit-Debit',
                () => setState(() => _selectedPaymentMethod = 'Credit-Debit'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedPaymentMethodButton(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            colors: [Color(0xFF1B5993), Color(0xFF20B2AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isSelected ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B5993) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF1B5993).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
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

  // Enhanced amount summary
  Widget _buildEnhancedAmountSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF1B5993).withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildEnhancedAmountRow(
            'Token Amount:', 
            widget.reservationData.formattedTokenAmount, 
            false, 
            Icons.apartment
          ),
          const SizedBox(height: 16),
          _buildEnhancedAmountRow(
            'KuickPay Fee:', 
            widget.reservationData.formattedKuickPayFee, 
            false, 
            Icons.payment
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, const Color(0xFF1B5993).withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildEnhancedAmountRow(
            'Total Amount:', 
            widget.reservationData.formattedTotalAmount, 
            true, 
            Icons.account_balance_wallet
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAmountRow(String label, String amount, bool isTotal, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTotal ? const Color(0xFF20B2AA).withOpacity(0.1) : const Color(0xFF1B5993).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isTotal ? const Color(0xFF20B2AA) : const Color(0xFF1B5993),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? const Color(0xFF1B5993) : Colors.grey[700],
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? const Color(0xFF20B2AA) : const Color(0xFF1B5993),
            ),
          ),
        ],
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
          _buildAmountRow('Token Amount:', widget.reservationData.formattedTokenAmount, false),
          const SizedBox(height: 8),
          _buildAmountRow('KuickPay Fee:', widget.reservationData.formattedKuickPayFee, false),
          const Divider(height: 20),
          _buildAmountRow('Total Amount:', widget.reservationData.formattedTotalAmount, true),
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

  // Enhanced terms and conditions
  Widget _buildEnhancedTermsAndConditions() {
    return GestureDetector(
      onTap: () {
        // Handle terms and conditions
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF20B2AA).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF20B2AA).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              color: const Color(0xFF20B2AA),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF20B2AA),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
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

  // Enhanced payment information section
  Widget _buildEnhancedPaymentInformationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF1B5993).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5993),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Information',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B5993),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // PSID/Challan with enhanced copy button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5993).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1B5993).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PSID/Challan:',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B5993),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.reservationData.psid,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B5993),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, widget.reservationData.psid),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF20B2AA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.copy,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '(Go to your banking app/kuick pay and enter PSID)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: const Color(0xFF20B2AA),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildEnhancedInfoRow('Amount:', widget.reservationData.formattedTotalAmount, Icons.account_balance_wallet),
          const SizedBox(height: 12),
          _buildEnhancedInfoRow('Method:', _selectedPaymentMethod, Icons.payment),
          
          const SizedBox(height: 20),
          
          // Enhanced expiry warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your reservation will expire in 15 min if payment is not received.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF20B2AA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF20B2AA),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Once paid, go to my bookings',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: const Color(0xFF1B5993),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5993).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1B5993),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1B5993),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF20B2AA),
            ),
          ),
        ],
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

  // Enhanced action buttons
  Widget _buildEnhancedActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1B5993), width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close,
                        color: const Color(0xFF1B5993),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B5993),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5993),
                  Color(0xFF20B2AA),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B5993).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onGoToBookings,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.book_online,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Go to My Bookings',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
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
