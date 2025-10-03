import 'package:flutter/material.dart';
import '../../data/models/plot_model.dart';

/// Plot details modal that matches the design from the images
class PlotDetailsModal extends StatefulWidget {
  final PlotModel plot;
  final VoidCallback? onClose;
  final VoidCallback? onBookNow;
  final VoidCallback? onViewDetails;

  const PlotDetailsModal({
    super.key,
    required this.plot,
    this.onClose,
    this.onBookNow,
    this.onViewDetails,
  });

  @override
  State<PlotDetailsModal> createState() => _PlotDetailsModalState();
}

class _PlotDetailsModalState extends State<PlotDetailsModal> {
  String _selectedPaymentPlan = 'Lump Sum';
  
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
  }

  void _calculatePaymentPlans() {
    final basePrice = double.tryParse(widget.plot.basePrice) ?? 0;
    final tokenAmount = basePrice * 0.05; // 5% token amount
    
    setState(() {
      _paymentPlans['Lump Sum']!['price'] = basePrice;
      _paymentPlans['1 Year Plan']!['price'] = basePrice * 1.1;
      _paymentPlans['2 Years Plan']!['price'] = basePrice * 1.2;
      _paymentPlans['3 Years Plan']!['price'] = basePrice * 1.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),
          
          // Plot information
          _buildPlotInfo(),
          
          // Price section
          _buildPriceSection(),
          
          // Payment plans
          _buildPaymentPlans(),
          
          // Disclaimer
          _buildDisclaimer(),
          
          // Login section
          _buildLoginSection(),
          
          // Clear selection button
          _buildClearSelectionButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3C90),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Selected Plot',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlotInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plot number and status
          Row(
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
              _buildStatusChip('Residential', Colors.green),
              const SizedBox(width: 8),
              _buildStatusChip('Unsold', Colors.green),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Plot details in two columns
          Row(
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
          ),
        ],
      ),
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
    final tokenAmount = basePrice * 0.05; // 5% token amount
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
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
                          setState(() {
                            _selectedPaymentPlan = value!;
                          });
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
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
    return Container(
      margin: const EdgeInsets.all(20),
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

  Widget _buildClearSelectionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextButton(
        onPressed: widget.onClose,
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[600],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    } else {
      return price.toStringAsFixed(0);
    }
  }
}
