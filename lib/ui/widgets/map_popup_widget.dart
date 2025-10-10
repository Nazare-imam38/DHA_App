import 'package:flutter/material.dart';
import '../../data/models/plot_model.dart';

/// Map popup widget that appears anchored to plot boundary with pointer
class MapPopupWidget extends StatelessWidget {
  final PlotModel plot;
  final VoidCallback? onClose;
  final VoidCallback? onViewDetails;

  const MapPopupWidget({
    super.key,
    required this.plot,
    this.onClose,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Content
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status tags
          Row(
            children: [
              _buildStatusChip(plot.category, _getCategoryColor(plot.category)),
              const SizedBox(width: 4),
              _buildStatusChip('Selected', Colors.blue.shade600),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Plot details - essential info only
          _buildInfoRow('Sector', plot.sector),
          _buildInfoRow('Street', plot.streetNo),
          _buildInfoRow('Size', plot.catArea),
          
          const SizedBox(height: 6),
          
          // Price
          _buildPrice(),
          
          const SizedBox(height: 6),
          
          // Action button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Row(
      children: [
        const Text(
          'Price:',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            'PKR ${_formatPrice(plot.basePrice)}',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3C90),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onViewDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3C90),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: const Text(
          'View Details',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
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
}


