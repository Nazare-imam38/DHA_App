import 'package:flutter/material.dart';

class ModernFiltersPanel extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> initialFilters;
  final List<String>? enabledPhases;
  final List<String>? enabledSizes;

  const ModernFiltersPanel({
    Key? key,
    required this.isVisible,
    required this.onClose,
    required this.onFiltersChanged,
    this.initialFilters = const {},
    this.enabledPhases,
    this.enabledSizes,
  }) : super(key: key);


  @override
  State<ModernFiltersPanel> createState() => _ModernFiltersPanelState();
}

class _ModernFiltersPanelState extends State<ModernFiltersPanel>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Price range bounds
  static const double _minPrice = 5475000; // 5.475M
  static const double _maxPrice = 565000000; // 565M
  
  // Primary filter states (only 4)
  RangeValues _priceRange = const RangeValues(_minPrice, _maxPrice);
  String? _selectedPlotType; // Commercial / Residential
  String? _selectedDhaPhase; // Phase names and RVS
  String? _selectedPlotSize; // Dynamic from data

  // Expanded states
  bool _isPriceRangeExpanded = true;
  bool _isPlotTypeExpanded = false;
  bool _isDhaPhaseExpanded = false;
  bool _isPlotSizeExpanded = false;

  // Dynamic options (will be updated based on API responses)
  List<String> _plotTypes = ['Commercial', 'Residential'];
  List<String> _dhaPhasesStatic = ['Phase 1','Phase 2','Phase 3','Phase 4','Phase 5','Phase 6','Phase 7','RVS'];
  List<String> _availablePlotSizes = [];
  
  // Dynamic filter states
  bool _categoriesEnabled = true;
  bool _phasesEnabled = true;
  bool _sizesEnabled = true;

  // Active filters
  List<String> _activeFilters = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFilters();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  void _initializeFilters() {
    _selectedPlotType = widget.initialFilters['plotType'];
    _selectedDhaPhase = widget.initialFilters['dhaPhase'];
    _selectedPlotSize = widget.initialFilters['plotSize'];
    
    // Safely initialize price range with validation
    final initialPriceRange = widget.initialFilters['priceRange'];
    if (initialPriceRange is RangeValues) {
      _priceRange = RangeValues(
        initialPriceRange.start.clamp(_minPrice, _maxPrice),
        initialPriceRange.end.clamp(_minPrice, _maxPrice),
      );
    } else {
      _priceRange = const RangeValues(_minPrice, _maxPrice);
    }
    
    _updateActiveFilters();
  }

  @override
  void didUpdateWidget(ModernFiltersPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _slideController.forward();
      _fadeController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _slideController.reverse();
      _fadeController.reverse();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Update available categories dynamically
  void updateAvailableCategories(List<String> categories) {
    setState(() {
      _plotTypes = categories;
      _categoriesEnabled = categories.isNotEmpty;
    });
  }

  /// Update available phases dynamically
  void updateAvailablePhases(List<String> phases) {
    setState(() {
      _dhaPhasesStatic = phases;
      _phasesEnabled = phases.isNotEmpty;
    });
  }

  /// Update available sizes dynamically
  void updateAvailableSizes(List<String> sizes) {
    setState(() {
      _availablePlotSizes = sizes;
      _sizesEnabled = sizes.isNotEmpty;
    });
  }

  void _updateActiveFilters() {
    _activeFilters.clear();
    
    if (_selectedDhaPhase != null) {
      _activeFilters.add(_selectedDhaPhase!);
    }
    if (_selectedPlotType != null) {
      _activeFilters.add(_selectedPlotType!);
    }
    if (_selectedPlotSize != null) {
      _activeFilters.add(_selectedPlotSize!);
    }
    if (_priceRange.start > 5475000 || _priceRange.end < 565000000) {
      _activeFilters.add('Price Range');
    }
    
    if (_activeFilters.isEmpty) {
      _activeFilters.add('All Plots');
    }
  }

  void _removeFilter(String filter) {
    setState(() {
      _activeFilters.remove(filter);
      
      if (filter == _selectedDhaPhase) {
        _selectedDhaPhase = null;
      } else if (filter == _selectedPlotType) {
        _selectedPlotType = null;
      } else if (filter == _selectedPlotSize) {
        _selectedPlotSize = null;
      } else if (filter == 'Price Range') {
        _priceRange = const RangeValues(_minPrice, _maxPrice);
      }
      
      if (_activeFilters.isEmpty) {
        _activeFilters.add('All Plots');
      }
      
      _notifyFiltersChanged();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDhaPhase = null;
      _selectedPlotType = null;
      _selectedPlotSize = null;
      _priceRange = const RangeValues(_minPrice, _maxPrice);
      _activeFilters.clear();
      _activeFilters.add('All Plots');
      _notifyFiltersChanged();
    });
  }

  void _notifyFiltersChanged() {
    widget.onFiltersChanged({
      'plotType': _selectedPlotType,
      'dhaPhase': _selectedDhaPhase,
      'plotSize': _selectedPlotSize,
      'priceRange': _priceRange,
      'activeFilters': _activeFilters,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                minHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(-2, 0),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildFilterCard(
                              icon: Icons.currency_rupee,
                              iconColor: const Color(0xFF20B2AA),
                              title: 'Price Range',
                              isExpanded: _isPriceRangeExpanded,
                              hasSelection: _priceRange.start > 5475000 || _priceRange.end < 565000000,
                              selectionTag: '${(_priceRange.start / 1000000).toStringAsFixed(2)}M - ${(_priceRange.end / 1000000).toStringAsFixed(0)}M',
                              onTap: () {
                                setState(() {
                                  _isPriceRangeExpanded = !_isPriceRangeExpanded;
                                });
                              },
                              children: [
                                _buildPriceRangeSlider(),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                              
                            _buildFilterCard(
                              icon: Icons.home,
                              iconColor: _categoriesEnabled ? const Color(0xFF20B2AA) : Colors.grey,
                              title: 'Plot Type',
                              isExpanded: _isPlotTypeExpanded,
                              hasSelection: _selectedPlotType != null,
                              selectionCount: _selectedPlotType != null ? 1 : 0,
                              onTap: _categoriesEnabled ? () {
                                setState(() {
                                  _isPlotTypeExpanded = !_isPlotTypeExpanded;
                                });
                              } : () {},
                              children: _plotTypes.map((type) => _buildFilterOption(
                                type,
                                _selectedPlotType == type,
                                () {
                                  setState(() {
                                    _selectedPlotType = type;
                                    _updateActiveFilters();
                                    _isPlotTypeExpanded = false;
                                    _notifyFiltersChanged();
                                  });
                                },
                              )).toList(),
                            ),
                            
                            const SizedBox(height: 8),
                              
                            _buildFilterCard(
                              icon: Icons.location_city,
                              iconColor: _phasesEnabled ? const Color(0xFFE57373) : Colors.grey,
                              title: 'DHA Phase',
                              isExpanded: _isDhaPhaseExpanded,
                              hasSelection: _selectedDhaPhase != null,
                              selectionTag: _selectedDhaPhase ?? 'Select Phase',
                              onTap: _phasesEnabled ? () {
                                setState(() {
                                  _isDhaPhaseExpanded = !_isDhaPhaseExpanded;
                                });
                              } : () {},
                              children: (_getEnabledPhases()).map((phase) => _buildFilterOptionDisabled(
                                phase,
                                _selectedDhaPhase == phase,
                                _isPhaseEnabled(phase),
                                () {
                                  if (!_isPhaseEnabled(phase)) return;
                                  setState(() {
                                    _selectedDhaPhase = phase;
                                    _updateActiveFilters();
                                    _isDhaPhaseExpanded = false;
                                    _notifyFiltersChanged();
                                  });
                                },
                              )).toList(),
                            ),
                            
                            const SizedBox(height: 8),
                              
                            _buildFilterCard(
                              icon: Icons.straighten,
                              iconColor: _sizesEnabled ? const Color(0xFFFFB74D) : Colors.grey,
                              title: 'Plot Size',
                              isExpanded: _isPlotSizeExpanded,
                              hasSelection: _selectedPlotSize != null,
                              selectionTag: _selectedPlotSize ?? 'Select Size',
                              onTap: _sizesEnabled ? () {
                                setState(() {
                                  _isPlotSizeExpanded = !_isPlotSizeExpanded;
                                });
                              } : () {},
                              children: (_getEnabledSizes()).map((size) => _buildFilterOptionDisabled(
                                size,
                                _selectedPlotSize == size,
                                _isSizeEnabled(size),
                                () {
                                  if (!_isSizeEnabled(size)) return;
                                  setState(() {
                                    _selectedPlotSize = size;
                                    _updateActiveFilters();
                                    _isPlotSizeExpanded = false;
                                    _notifyFiltersChanged();
                                  });
                                },
                              )).toList(),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Removed all non-required sections to keep UI focused
                            
                            const SizedBox(height: 6),
                              
                            _buildActiveFiltersSection(),
                            
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF20B2AA),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF20B2AA).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Refine your search',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Filter count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF20B2AA),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF20B2AA).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_activeFilters.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
    bool hasSelection = false,
    String? selectionTag,
    int? selectionCount,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? iconColor.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded 
                ? iconColor.withOpacity(0.1) 
                : Colors.black.withOpacity(0.03),
            blurRadius: isExpanded ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        if (selectionTag != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            selectionTag,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasSelection) ...[
                    if (selectionCount != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: iconColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$selectionCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else if (selectionTag != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: iconColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          selectionTag,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isSelected, VoidCallback onTap, {String? count}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF20B2AA).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF20B2AA) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF20B2AA) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF20B2AA) : const Color(0xFFE0E0E0),
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF20B2AA).withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ] : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptionDisabled(String title, bool isSelected, bool isEnabled, VoidCallback onTap, {String? count}) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF20B2AA).withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF20B2AA) : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF20B2AA) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF20B2AA) : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    count,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getEnabledPhases() {
    return widget.enabledPhases != null && widget.enabledPhases!.isNotEmpty
        ? widget.enabledPhases!
        : _dhaPhasesStatic;
  }

  bool _isPhaseEnabled(String phase) {
    return _getEnabledPhases().contains(phase);
  }

  List<String> _getEnabledSizes() {
    return _availablePlotSizes.isNotEmpty ? _availablePlotSizes : (widget.enabledSizes ?? []);
  }

  bool _isSizeEnabled(String size) {
    return _getEnabledSizes().contains(size);
  }

  Widget _buildPriceRangeSlider() {
    // Ensure price range is valid before building slider
    final safePriceRange = RangeValues(
      _priceRange.start.clamp(_minPrice, _maxPrice),
      _priceRange.end.clamp(_minPrice, _maxPrice),
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: PKR ${(safePriceRange.start / 1000000).toStringAsFixed(2)}M',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                'Max: PKR ${(safePriceRange.end / 1000000).toStringAsFixed(0)}M',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: safePriceRange,
            min: _minPrice,
            max: _maxPrice,
            divisions: 50,
            activeColor: const Color(0xFF20B2AA),
            inactiveColor: Colors.grey[300],
            onChanged: (RangeValues values) {
              // Validate the new values
              final newStart = values.start.clamp(_minPrice, _maxPrice);
              final newEnd = values.end.clamp(_minPrice, _maxPrice);
              final newRange = RangeValues(newStart, newEnd);
              
              setState(() {
                _priceRange = newRange;
                _updateActiveFilters();
                _notifyFiltersChanged();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersSection() {
    if (_activeFilters.isEmpty || (_activeFilters.length == 1 && _activeFilters.first == 'All Plots')) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt,
                color: Color(0xFF2196F3),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Filters',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _activeFilters
                .where((filter) => filter != 'All Plots')
                .map((filter) => _buildFilterChip(filter))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    // Use teal color for all filter chips
    Color chipColor = const Color(0xFF20B2AA); // Teal color for all filters
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filter,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeFilter(filter),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getPlotTypeCount(String type) {
    switch (type) {
      case 'Residential':
        return '79';
      case 'Commercial':
        return '15';
      case 'Agricultural':
        return '8';
      default:
        return '0';
    }
  }

  String _getPlotSizeCount(String size) {
    switch (size) {
      case '3 Marla':
        return '25';
      case '5 Marla':
        return '35';
      case '7 Marla':
        return '20';
      case '10 Marla':
        return '15';
      case '1 Kanal':
        return '10';
      default:
        return '0';
    }
  }

  String _getSectorCount(String sector) {
    // Mock data - in real app, this would come from the provider
    switch (sector) {
      case 'A':
        return '12';
      case 'B':
        return '18';
      case 'C':
        return '15';
      case 'D':
        return '22';
      case 'E':
        return '8';
      case 'F':
        return '14';
      case 'G':
        return '16';
      case 'H':
        return '20';
      case 'I':
        return '10';
      case 'J':
        return '6';
      default:
        return '0';
    }
  }

  String _getStatusCount(String status) {
    // Mock data - in real app, this would come from the provider
    switch (status) {
      case 'Available':
        return '45';
      case 'Sold':
        return '32';
      case 'Reserved':
        return '18';
      case 'Unsold':
        return '25';
      default:
        return '0';
    }
  }

  Widget _buildCheckboxOption(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: value ? const Color(0xFF1E3C90).withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value ? const Color(0xFF1E3C90) : Colors.grey[300]!,
              width: value ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? const Color(0xFF1E3C90) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: value ? const Color(0xFF1E3C90) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: value
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: value ? const Color(0xFF1E3C90) : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}
