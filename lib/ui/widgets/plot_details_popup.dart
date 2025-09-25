import 'package:flutter/material.dart';
import '../../data/models/plot_details_model.dart';

class PlotDetailsPopup extends StatelessWidget {
  final PlotDetailsModel plotDetails;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  const PlotDetailsPopup({
    super.key,
    required this.plotDetails,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Plot ${plotDetails.plotNo}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Plot Type Selection
          Row(
            children: [
              _buildTypeButton('Residential', true),
              const SizedBox(width: 8),
              _buildTypeButton('Selected', false),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Plot Details
          _buildDetailRow('Phase', plotDetails.phase),
          _buildDetailRow('Sector', plotDetails.sector),
          _buildDetailRow('Street', plotDetails.street),
          _buildDetailRow('Size', plotDetails.size),
          _buildDetailRow('Dimension', plotDetails.dimension),
          _buildDetailRow('Price', 'PKR ${_formatPrice(plotDetails.lumpSumPrice)}'),
          
          const SizedBox(height: 16),
          
          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3C90),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.red[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.red[300]! : Colors.blue[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.red[700] : Colors.blue[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
