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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Plot Reserved'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Success message
            Container(
              padding: const EdgeInsets.all(20),
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
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Plot reserved successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Payment information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // PSID/Challan
                  _buildInfoRow(
                    'PSID/Challan:',
                    widget.reservationData.psid,
                    showCopyButton: true,
                    onCopy: () => _copyToClipboard(context, widget.reservationData.psid),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '(Go to your banking app/kuick pay and enter PSID)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Amount
                  _buildInfoRow(
                    'Amount:',
                    widget.reservationData.formattedTotalAmount,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Method
                  _buildInfoRow(
                    'Method:',
                    'KuickPay',
                  ),
                  
                  const SizedBox(height: 20),
                  
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
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Once paid, go to my bookings',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Go to My Bookings button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onGoToBookings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Go to My Bookings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
