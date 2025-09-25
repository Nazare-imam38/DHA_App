import 'package:flutter/material.dart';
import '../../data/models/plot_details_model.dart';
import '../../core/services/plot_details_service.dart';

class SelectedPlotDetailsWidget extends StatefulWidget {
  final PlotDetailsModel plotDetails;
  final VoidCallback onClearSelection;

  const SelectedPlotDetailsWidget({
    super.key,
    required this.plotDetails,
    required this.onClearSelection,
  });

  @override
  State<SelectedPlotDetailsWidget> createState() => _SelectedPlotDetailsWidgetState();
}

class _SelectedPlotDetailsWidgetState extends State<SelectedPlotDetailsWidget> {
  List<PaymentPlan> _paymentPlans = [];
  String? _selectedPlanId;
  bool _isSecuring = false;

  @override
  void initState() {
    super.initState();
    _paymentPlans = List.from(widget.plotDetails.paymentPlans);
    _selectedPlanId = _paymentPlans.firstWhere((plan) => plan.isSelected).id;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Selected Plot',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onClearSelection,
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Plot Information Card
          _buildPlotInfoCard(),
          
          const SizedBox(height: 24),
          
          // Payment Plans Section
          _buildPaymentPlansSection(),
          
          const SizedBox(height: 24),
          
          // Disclaimer
          _buildDisclaimer(),
          
          const SizedBox(height: 24),
          
          // Secure Plot Section
          _buildSecurePlotSection(),
          
          const SizedBox(height: 24),
          
          // Clear Selection Button
          _buildClearSelectionButton(),
        ],
      ),
    );
  }

  Widget _buildPlotInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plot Number and Status
          Row(
            children: [
              Text(
                'Plot ${widget.plotDetails.plotNo}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusChip('Residential', Colors.green),
              const SizedBox(width: 8),
              _buildStatusChip(widget.plotDetails.status, Colors.orange),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Plot Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Size', widget.plotDetails.size),
              _buildDetailRow('Phase/Sector', '${widget.plotDetails.phase}/${widget.plotDetails.sector}'),
              _buildDetailRow('Dimension', widget.plotDetails.dimension),
              _buildDetailRow('Street', widget.plotDetails.street),
              _buildDetailRow('Lump Sum Price', 'PKR ${_formatPrice(widget.plotDetails.lumpSumPrice)}'),
              _buildDetailRow('Token Amount', 'PKR ${_formatPrice(widget.plotDetails.tokenAmount)}'),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width for labels
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Plans',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._paymentPlans.map((plan) => _buildPaymentPlanCard(plan)),
      ],
    );
  }

  Widget _buildPaymentPlanCard(PaymentPlan plan) {
    final isSelected = _selectedPlanId == plan.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E3C90) : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Radio<String>(
            value: plan.id,
            groupValue: _selectedPlanId,
            onChanged: (value) {
              setState(() {
                _selectedPlanId = value;
              });
            },
            activeColor: const Color(0xFF1E3C90),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'PKR ${_formatPrice(plan.price)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildSecurePlotSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3C90).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3C90).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1E3C90),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Secure Your Plot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3C90),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Pay token amount to secure this plot. This is a non-refundable token payment (Adjustable in Down Payment).',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1E3C90),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSecuring ? null : _securePlot,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3C90),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSecuring
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SECURE YOUR PLOT',
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: widget.onClearSelection,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Clear Selection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _securePlot() async {
    setState(() {
      _isSecuring = true;
    });

    try {
      final selectedPlan = _paymentPlans.firstWhere((plan) => plan.id == _selectedPlanId);
      final success = await PlotDetailsService.securePlot(
        widget.plotDetails.plotNo,
        selectedPlan.id,
        selectedPlan.price,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plot secured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to secure plot. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSecuring = false;
      });
    }
  }
}
