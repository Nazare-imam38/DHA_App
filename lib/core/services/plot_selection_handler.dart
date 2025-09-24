import 'package:flutter/material.dart';
import '../../data/models/plot_model.dart';

/// Plot selection handler for managing plot selection state
class PlotSelectionHandler {
  static PlotModel? _selectedPlot;
  static BuildContext? _context;
  static Function(PlotModel)? _onPlotSelected;
  static VoidCallback? _onPlotDeselected;

  /// Initialize the plot selection handler
  static void initialize(BuildContext context) {
    _context = context;
  }

  /// Select a plot
  static void selectPlot(PlotModel plot) {
    _selectedPlot = plot;
    _onPlotSelected?.call(plot);
    print('PlotSelectionHandler: Selected plot ${plot.plotNo}');
  }

  /// Deselect current plot
  static void deselectPlot() {
    _selectedPlot = null;
    _onPlotDeselected?.call();
    print('PlotSelectionHandler: Deselected plot');
  }

  /// Handle map tap (deselect if no plot found)
  static void handleMapTap() {
    if (_selectedPlot != null) {
      deselectPlot();
    }
  }

  /// Get currently selected plot
  static PlotModel? get selectedPlot => _selectedPlot;

  /// Check if a plot is selected
  static bool get hasSelectedPlot => _selectedPlot != null;

  /// Set plot selection callbacks
  static void setCallbacks({
    Function(PlotModel)? onPlotSelected,
    VoidCallback? onPlotDeselected,
  }) {
    _onPlotSelected = onPlotSelected;
    _onPlotDeselected = onPlotDeselected;
  }

  /// Clear all state
  static void clear() {
    _selectedPlot = null;
    _context = null;
    _onPlotSelected = null;
    _onPlotDeselected = null;
  }
}
