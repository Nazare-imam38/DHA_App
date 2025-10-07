import 'package:flutter/material.dart';
import '../../data/models/plot_model.dart';

/// Small plot information card that appears on the map at plot location
class SmallPlotInfoCard extends StatelessWidget {
  final PlotModel plot;
  final VoidCallback? onClose;
  final VoidCallback? onViewDetails;

  const SmallPlotInfoCard({
    super.key,
    required this.plot,
    this.onClose,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 320,
        minWidth: 280,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          _buildHeader(),
          
          // Plot details
          _buildPlotDetails(),
          
          // Action button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3C90),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Plot ${plot.plotNo}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status tags - matching web app design
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildStatusChip(plot.category, _getCategoryColor(plot.category)),
              _buildStatusChip('Selected', Colors.blue.shade600),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Plot information - matching web app layout
          _buildInfoRow('Phase', plot.phase),
          _buildInfoRow('Sector', plot.sector),
          _buildInfoRow('Street', plot.streetNo),
          _buildInfoRow('Size', plot.catArea),
          if (plot.dimension != null && plot.dimension!.isNotEmpty)
            _buildInfoRow('Dimension', plot.dimension!),
          
          const SizedBox(height: 12),
          
          // Price information with better formatting
          _buildPriceRow(),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'residential':
        return Colors.red.shade600;
      case 'commercial':
        return Colors.orange.shade600;
      case 'agricultural':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Text(
            'Price:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'PKR ${_formatPrice(plot.basePrice)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3C90),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String? price) {
    if (price == null || price.isEmpty) return 'N/A';
    try {
      final priceValue = double.parse(price);
      if (priceValue >= 1000000) {
        return '${(priceValue / 1000000).toStringAsFixed(0)}M';
      } else if (priceValue >= 1000) {
        return '${(priceValue / 1000).toStringAsFixed(0)}K';
      } else {
        return priceValue.toStringAsFixed(0);
      }
    } catch (e) {
      return price;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 11,
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
                fontSize: 11,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onViewDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3C90),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'View Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
