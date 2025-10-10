import 'package:flutter/material.dart';
import '../../data/models/plot_model.dart';

/// Map popup widget that appears anchored to plot boundary with pointer
class MapPopupWidget extends StatelessWidget {
  final PlotModel plot;
  final VoidCallback? onClose;

  const MapPopupWidget({
    super.key,
    required this.plot,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
              boxShadow: [
                BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            'Plot ${plot.plotNo}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status tags - smaller
          Row(
            children: [
              _buildStatusChip(plot.category, _getCategoryColor(plot.category)),
              const SizedBox(width: 3),
              _buildStatusChip('Selected', Colors.blue.shade600),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Plot details - essential info only
          _buildInfoRow('Sector', plot.sector),
          _buildInfoRow('Street', plot.streetNo),
          _buildInfoRow('Size', plot.catArea),
          
          const SizedBox(height: 4),
          
          // Price
          _buildPrice(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w600,
          color: color,
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
            width: 35,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 7,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.green[200]!,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Price:',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              'PKR ${_formatPrice(plot.basePrice)}',
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
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


