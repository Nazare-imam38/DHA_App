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
        maxWidth: 240, // Much smaller width
        minWidth: 200,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact header
          _buildCompactHeader(),
          
          // Compact plot details
          _buildCompactDetails(),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3C90),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Plot ${plot.plotNo}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetails() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact status tags
          Row(
            children: [
              _buildCompactStatusChip(plot.category, _getCategoryColor(plot.category)),
              const SizedBox(width: 6),
              _buildCompactStatusChip('Selected', Colors.blue.shade600),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Essential plot information only
          _buildCompactInfoRow('Phase', plot.phase),
          _buildCompactInfoRow('Sector', plot.sector),
          _buildCompactInfoRow('Size', plot.catArea),
          
          const SizedBox(height: 8),
          
          // Compact price
          _buildCompactPrice(),
          
          const SizedBox(height: 8),
          
          // Compact action button
          _buildCompactActionButton(),
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

  Widget _buildCompactStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCompactPrice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Text(
            'Price:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'PKR ${_formatPrice(plot.basePrice)}',
              style: const TextStyle(
                fontSize: 10,
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

  Widget _buildCompactInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onViewDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3C90),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          'View Details',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
