import 'package:flutter/material.dart';
import '../../data/models/plot_model.dart';

/// Beautiful plot information card widget
class PlotInfoCard extends StatelessWidget {
  final PlotModel plot;
  final VoidCallback? onClose;
  final VoidCallback? onBookNow;
  final VoidCallback? onViewDetails;

  const PlotInfoCard({
    super.key,
    required this.plot,
    this.onClose,
    this.onBookNow,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
            offset: const Offset(0, 10),
                  ),
                ],
              ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
          // Header with close button
          _buildHeader(context),
          
          // Plot image placeholder
          _buildImageSection(),
          
          // Plot details
          _buildPlotDetails(),
          
          // Price section
          _buildPriceSection(),
          
          // Installment plans
          _buildInstallmentPlans(),
          
          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor().withOpacity(0.1),
            _getStatusColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          
          // Plot number and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plot ${plot.plotNo}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  plot.status,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.grey),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.1),
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor().withOpacity(0.3),
            _getCategoryColor().withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Plot visualization placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(),
                  size: 48,
                  color: _getCategoryColor(),
                ),
                const SizedBox(height: 8),
                Text(
                  '${plot.catArea} ${plot.category}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(),
                  ),
                ),
                if (plot.dimension != null)
                Text(
                    plot.dimension!,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // Phase badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white,
              borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
            ),
            child: Text(
                plot.phase,
                style: const TextStyle(
                  fontSize: 12,
                fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlotDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
      children: [
          // Location details
          _buildDetailRow(
            icon: Icons.place,
            label: 'Location',
            value: '${plot.sector}, ${plot.streetNo}',
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(
            icon: Icons.category,
            label: 'Category',
            value: plot.category,
        ),
        const SizedBox(height: 12),
          
          _buildDetailRow(
            icon: Icons.straighten,
            label: 'Size',
            value: plot.catArea,
          ),
          const SizedBox(height: 12),
          
          if (plot.block != null)
            _buildDetailRow(
              icon: Icons.grid_view,
              label: 'Block',
              value: plot.block!,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Base price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
                'Base Price',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                plot.formattedPrice,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
        const SizedBox(height: 12),
          
          // Token amount
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              const Text(
                'Token Amount',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
                  Text(
                plot.formattedTokenAmount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                  color: Colors.black87,
                    ),
                  ),
                ],
          ),
          
          // Hold status
          if (plot.isOnHold) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'On Hold by ${plot.holdBy}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstallmentPlans() {
    if (!plot.hasInstallmentPlans) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Installment Plans',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
              color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
          
          ...plot.availablePaymentPlans.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                Text(
                  plan['period']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  plan['formatted']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
              ),
            ),
          ],
        ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
            child: Row(
              children: [
          // View Details button
                Expanded(
            child: OutlinedButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
          ),
          
          const SizedBox(width: 12),
          
          // Book Now button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: plot.isAvailable ? onBookNow : null,
              icon: const Icon(Icons.book_online, size: 18),
              label: Text(plot.isAvailable ? 'Book Now' : 'Not Available'),
              style: ElevatedButton.styleFrom(
                backgroundColor: plot.isAvailable ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (plot.status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'unsold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor() {
    return plot.category.toLowerCase() == 'commercial' 
        ? const Color(0xFF1E3C90) 
        : const Color(0xFF20B2AA);
  }

  IconData _getCategoryIcon() {
    return plot.category.toLowerCase() == 'commercial' 
        ? Icons.business 
        : Icons.apartment;
  }
}