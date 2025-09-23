import '../models/plot_model.dart';
import '../network/plots_api_service.dart';

class PlotsRepository {
  final PlotsApiService _apiService;
  
  PlotsRepository(this._apiService);
  
  // Get all plots
  Future<List<PlotModel>> getAllPlots({bool forceRefresh = false, int? zoomLevel}) async {
    return await PlotsApiService.fetchPlots();
  }
  
  // Get plots by phase
  Future<List<PlotModel>> getPlotsByPhase(String phase, {int? zoomLevel}) async {
    return await PlotsApiService.fetchPlotsByPhase(phase);
  }
  
  // Get plots by category
  Future<List<PlotModel>> getPlotsByCategory(String category, {int? zoomLevel}) async {
    return await PlotsApiService.fetchPlotsByCategory(category);
  }
  
  // Get plots by price range
  Future<List<PlotModel>> getPlotsByPriceRange(double minPrice, double maxPrice, {int? zoomLevel}) async {
    return await PlotsApiService.fetchPlotsByPriceRange(minPrice, maxPrice);
  }
  
  // Get plots by status
  Future<List<PlotModel>> getPlotsByStatus(String status, {int? zoomLevel}) async {
    return await PlotsApiService.fetchPlotsByStatus(status);
  }
  
  // Get plot by ID
  Future<PlotModel> getPlotById(int id) async {
    return await PlotsApiService.fetchPlotById(id);
  }
  
  // Search plots with multiple criteria
  Future<List<PlotModel>> searchPlots({
    String? phase,
    String? sector,
    String? status,
    String? category,
    String? size,
    double? minPrice,
    double? maxPrice,
    double? minTokenAmount,
    double? maxTokenAmount,
    bool? hasInstallmentPlan,
    bool? isAvailable,
    bool? hasRemarks,
    int? zoomLevel,
  }) async {
    return await PlotsApiService.searchPlots(
      phase: phase,
      sector: sector,
      status: status,
      category: category,
      size: size,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minTokenAmount: minTokenAmount,
      maxTokenAmount: maxTokenAmount,
      hasInstallmentPlan: hasInstallmentPlan,
      isAvailable: isAvailable,
      hasRemarks: hasRemarks,
    );
  }
}