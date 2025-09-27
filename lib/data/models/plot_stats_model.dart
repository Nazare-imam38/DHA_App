class PlotStatsModel {
  final bool success;
  final PlotStatsData data;

  PlotStatsModel({
    required this.success,
    required this.data,
  });

  factory PlotStatsModel.fromJson(Map<String, dynamic> json) {
    return PlotStatsModel(
      success: json['success'] ?? false,
      data: PlotStatsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class PlotStatsData {
  final int totalPlots;
  final PlotCategories plotCategories;

  PlotStatsData({
    required this.totalPlots,
    required this.plotCategories,
  });

  factory PlotStatsData.fromJson(Map<String, dynamic> json) {
    return PlotStatsData(
      totalPlots: json['total_plots'] ?? 0,
      plotCategories: PlotCategories.fromJson(json['plot_categories'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_plots': totalPlots,
      'plot_categories': plotCategories.toJson(),
    };
  }
}

class PlotCategories {
  final int residential;
  final int commercial;

  PlotCategories({
    required this.residential,
    required this.commercial,
  });

  factory PlotCategories.fromJson(Map<String, dynamic> json) {
    return PlotCategories(
      residential: json['residential'] ?? 0,
      commercial: json['commercial'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'residential': residential,
      'commercial': commercial,
    };
  }
}
