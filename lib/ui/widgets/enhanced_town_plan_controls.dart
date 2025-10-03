import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/mbtiles_service.dart';
import '../../core/services/enhanced_tile_layer_manager.dart';

/// Enhanced Town Plan Controls Widget
/// Provides comprehensive UI for managing town plan overlays
class EnhancedTownPlanControls extends StatefulWidget {
  final EnhancedTileLayerManager tileManager;
  final Function(String phaseId, bool visible) onLayerToggle;
  final Function(bool showTownPlan) onTownPlanToggle;
  final bool showTownPlan;
  final String? selectedPhase;

  const EnhancedTownPlanControls({
    Key? key,
    required this.tileManager,
    required this.onLayerToggle,
    required this.onTownPlanToggle,
    this.showTownPlan = false,
    this.selectedPhase,
  }) : super(key: key);

  @override
  State<EnhancedTownPlanControls> createState() => _EnhancedTownPlanControlsState();
}

class _EnhancedTownPlanControlsState extends State<EnhancedTownPlanControls>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;
  List<DHAPhase> _availablePhases = [];
  Map<String, bool> _phaseVisibility = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAvailablePhases();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadAvailablePhases() {
    _availablePhases = MBTilesService.getAllPhases();
    for (final phase in _availablePhases) {
      _phaseVisibility[phase.id] = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Main toggle button
          _buildMainToggleButton(),
          
          // Expanded controls
          if (_isExpanded) _buildExpandedControls(),
        ],
      ),
    );
  }

  Widget _buildMainToggleButton() {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.showTownPlan 
                    ? const Color(0xFF4CAF50) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.showTownPlan ? Icons.layers : Icons.layers_outlined,
                color: widget.showTownPlan ? Colors.white : const Color(0xFF4CAF50),
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedControls() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildTownPlanToggle(),
                  _buildPhaseSelector(),
                  _buildCacheInfo(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.map,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Town Plan Layers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleExpansion,
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTownPlanToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.layers,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            'Show Town Plan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch(
            value: widget.showTownPlan,
            onChanged: (value) {
              widget.onTownPlanToggle(value);
            },
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Phases',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: _availablePhases.length,
              itemBuilder: (context, index) {
                final phase = _availablePhases[index];
                final isVisible = _phaseVisibility[phase.id] ?? false;
                
                return _buildPhaseItem(phase, isVisible);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseItem(DHAPhase phase, bool isVisible) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _togglePhaseVisibility(phase.id),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isVisible 
                  ? phase.color.withOpacity(0.1) 
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isVisible 
                    ? phase.color.withOpacity(0.3) 
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: phase.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isVisible ? phase.color : Colors.grey[600],
                        ),
                      ),
                      Text(
                        phase.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: isVisible ? phase.color : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCacheInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.storage,
            color: Color(0xFF4CAF50),
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'Cache: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const Text(
            'Active',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4CAF50),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showCacheDetails,
            child: const Text(
              'Details',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF4CAF50),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _togglePhaseVisibility(String phaseId) {
    setState(() {
      _phaseVisibility[phaseId] = !(_phaseVisibility[phaseId] ?? false);
    });
    
    widget.onLayerToggle(phaseId, _phaseVisibility[phaseId]!);
  }

  void _showCacheDetails() {
    showDialog(
      context: context,
      builder: (context) => _buildCacheDetailsDialog(),
    );
  }

  Widget _buildCacheDetailsDialog() {
    return AlertDialog(
      title: const Text('Cache Information'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tile caching is active and optimized for performance.'),
          const SizedBox(height: 16),
          const Text(
            'Features:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Automatic tile caching'),
          const Text('• Smart cache management'),
          const Text('• Performance optimization'),
          const Text('• Offline tile access'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Town Plan Layer Selector Bottom Sheet
/// Provides a comprehensive layer selection interface
class TownPlanLayerSelector extends StatelessWidget {
  final List<DHAPhase> phases;
  final String? selectedPhase;
  final Function(String phaseId) onPhaseSelected;

  const TownPlanLayerSelector({
    Key? key,
    required this.phases,
    this.selectedPhase,
    required this.onPhaseSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.layers,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Town Plan Layer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Phase list
          Container(
            height: 400,
            child: ListView.builder(
              itemCount: phases.length,
              itemBuilder: (context, index) {
                final phase = phases[index];
                final isSelected = phase.id == selectedPhase;
                
                return _buildPhaseListItem(phase, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseListItem(DHAPhase phase, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPhaseSelected(phase.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? phase.color.withOpacity(0.1) 
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? phase.color 
                    : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: phase.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? phase.color : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phase.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Center: ${phase.center.latitude.toStringAsFixed(4)}, ${phase.center.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: phase.color,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
