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
      constraints: const BoxConstraints(
        maxWidth: 280,
        minWidth: 240,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main popup content
          Container(
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
                // Header
                _buildHeader(),
                
                // Content
                _buildContent(),
              ],
            ),
          ),
          
          // Pointer/Arrow pointing to plot
          _buildPointer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status tags
          Row(
            children: [
              _buildStatusChip(plot.category, _getCategoryColor(plot.category)),
              const SizedBox(width: 6),
              _buildStatusChip('Selected', Colors.blue.shade600),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Plot details
          _buildInfoRow('Phase', plot.phase),
          _buildInfoRow('Sector', plot.sector),
          _buildInfoRow('Street', plot.streetNo),
          _buildInfoRow('Size', plot.catArea),
          if (plot.dimension != null && plot.dimension!.isNotEmpty)
            _buildInfoRow('Dimension', plot.dimension!),
          
          const SizedBox(height: 8),
          
          // Price
          _buildPrice(),
          
          const SizedBox(height: 8),
          
          // Action button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 50,
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

  Widget _buildPrice() {
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

  Widget _buildActionButton() {
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

  Widget _buildPointer() {
    return Container(
      width: 20,
      height: 15,
      child: CustomPaint(
        size: const Size(20, 15),
        painter: PointerPainter(),
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

/// Custom painter for the pointer/arrow
class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw shadow first
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final shadowPath = Path();
    shadowPath.moveTo(size.width / 2, size.height);
    shadowPath.lineTo(0, 0);
    shadowPath.lineTo(size.width, 0);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main pointer
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Draw border for better visibility
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
