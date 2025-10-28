import 'package:flutter/material.dart';
import '../../data/models/plot_model.dart';

/// Optimized plot information card with reduced rebuilds
/// Preserves all existing functionality and design while improving performance
class OptimizedPlotInfoCard extends StatefulWidget {
  final PlotModel plot;
  final VoidCallback? onClose;
  final VoidCallback? onBookNow;
  final VoidCallback? onViewDetails;
  final String? townPlanValidationStatus;
  final Color? townPlanValidationColor;

  const OptimizedPlotInfoCard({
    super.key,
    required this.plot,
    this.onClose,
    this.onBookNow,
    this.onViewDetails,
    this.townPlanValidationStatus,
    this.townPlanValidationColor,
  });

  @override
  State<OptimizedPlotInfoCard> createState() => _OptimizedPlotInfoCardState();
}

class _OptimizedPlotInfoCardState extends State<OptimizedPlotInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Performance optimization: Cache expensive computations
  String? _cachedFormattedPrice;
  String? _cachedFormattedTokenAmount;
  Color? _cachedStatusColor;
  IconData? _cachedStatusIcon;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _precomputeExpensiveValues();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  void _precomputeExpensiveValues() {
    // Cache expensive computations to avoid recalculating on every build
    _cachedFormattedPrice = _formatPrice(widget.plot.basePrice);
    _cachedFormattedTokenAmount = _formatTokenAmount(widget.plot.tokenAmount);
    _cachedStatusColor = _getStatusColor(widget.plot.status);
    _cachedStatusIcon = _getStatusIcon(widget.plot.status);
  }

  @override
  void didUpdateWidget(OptimizedPlotInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only recompute if plot data actually changed
    if (oldWidget.plot.id != widget.plot.id ||
        oldWidget.plot.basePrice != widget.plot.basePrice ||
        oldWidget.plot.tokenAmount != widget.plot.tokenAmount ||
        oldWidget.plot.status != widget.plot.status) {
      _precomputeExpensiveValues();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 280,
        minWidth: 240,
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
          
          // Plot details section
          _buildPlotDetails(),
          
          // Price section
          _buildPriceSection(),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
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
            'Plot ${widget.plot.plotNo}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
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
          // Phase and Sector
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Phase',
                  widget.plot.phase,
                  Icons.work,
                  const Color(0xFF1E3C90),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailItem(
                  'Sector',
                  widget.plot.sector,
                  Icons.location_city,
                  const Color(0xFF20B2AA),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Category and Size
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Category',
                  widget.plot.category,
                  Icons.category,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailItem(
                  'Size',
                  widget.plot.catArea,
                  Icons.straighten,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Status with cached color and icon
          _buildStatusItem(),
          
          // Town Plan Validation (if available)
          if (widget.townPlanValidationStatus != null) ...[
            const SizedBox(height: 12),
            _buildTownPlanValidation(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _cachedStatusColor!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cachedStatusColor!.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_cachedStatusIcon!, size: 16, color: _cachedStatusColor),
          const SizedBox(width: 8),
          Text(
            'Status: ${widget.plot.status}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _cachedStatusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTownPlanValidation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.townPlanValidationColor!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.townPlanValidationColor!.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified,
            size: 16,
            color: widget.townPlanValidationColor,
          ),
          const SizedBox(width: 8),
          Text(
            widget.townPlanValidationStatus!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.townPlanValidationColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          // Base Price
          _buildPriceItem(
            'Base Price',
            _cachedFormattedPrice!,
            Icons.attach_money,
            const Color(0xFF1E3C90),
          ),
          
          const SizedBox(height: 8),
          
          // Token Amount
          _buildPriceItem(
            'Token Amount',
            _cachedFormattedTokenAmount!,
            Icons.payment,
            const Color(0xFF20B2AA),
          ),
          
          // Installment Plans (if available)
          if (widget.plot.hasInstallmentPlans) ...[
            const SizedBox(height: 8),
            _buildInstallmentPlans(),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentPlans() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 14, color: Color(0xFF4CAF50)),
          const SizedBox(width: 6),
          const Text(
            'Installment Plans Available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3C90),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
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
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Book Now',
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

  // Helper methods for expensive computations (cached)
  String _formatPrice(String price) {
    try {
      final priceValue = double.tryParse(price) ?? 0;
      if (priceValue >= 1000000) {
        return 'PKR ${(priceValue / 1000000).toStringAsFixed(1)}M';
      } else if (priceValue >= 1000) {
        return 'PKR ${(priceValue / 1000).toStringAsFixed(1)}K';
      } else {
        return 'PKR ${priceValue.toStringAsFixed(0)}';
      }
    } catch (e) {
      return 'PKR $price';
    }
  }

  String _formatTokenAmount(String tokenAmount) {
    try {
      final amount = double.tryParse(tokenAmount) ?? 0;
      if (amount >= 1000000) {
        return 'PKR ${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return 'PKR ${(amount / 1000).toStringAsFixed(1)}K';
      } else {
        return 'PKR ${amount.toStringAsFixed(0)}';
      }
    } catch (e) {
      return 'PKR $tokenAmount';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'unsold':
        return const Color(0xFF4CAF50); // Green
      case 'sold':
        return const Color(0xFFF44336); // Red
      case 'reserved':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'unsold':
        return Icons.check_circle;
      case 'sold':
        return Icons.sell;
      case 'reserved':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }
}
