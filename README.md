# DHA Marketplace Flutter App

A comprehensive Flutter application for the DHA (Defence Housing Authority) Marketplace, featuring interactive maps, plot visualization, and advanced polygon rendering capabilities.

## 🏗️ Features

### 🗺️ Interactive Map System
- **Real-time Plot Visualization**: Interactive polygons showing plot boundaries
- **Multiple Map Views**: Satellite, Street, and Hybrid view modes
- **Zoom-based Loading**: Progressive data loading based on zoom levels
- **Boundary Visualization**: Phase boundaries with color-coded regions

### 📍 Plot Management
- **Advanced Filtering**: Filter by plot type, size, phase, price range, and status
- **Plot Details**: Comprehensive plot information with booking capabilities
- **Search Functionality**: Search plots by ID or location
- **Favorites System**: Save and manage favorite plots

### 🎨 User Interface
- **Modern Design**: Clean, intuitive interface with smooth animations
- **Responsive Layout**: Optimized for various screen sizes
- **Multi-language Support**: English and Urdu localization
- **Dark/Light Theme**: Adaptive theming support

### 🚀 Performance Optimizations
- **Instant Loading**: Zero-wait time map initialization
- **Progressive Rendering**: Smart polygon loading based on viewport
- **Caching System**: Intelligent data caching for improved performance
- **Background Processing**: Non-blocking data operations

## 🛠️ Technical Architecture

### Core Technologies
- **Flutter**: Cross-platform mobile development
- **Flutter Map**: Interactive mapping solution
- **Provider**: State management
- **GeoJSON**: Geographic data processing
- **UTM Coordinate System**: Precise coordinate conversion

### Key Components
- **Polygon Renderer**: Advanced polygon visualization system
- **Coordinate Parser**: Multi-format coordinate conversion
- **Cache Manager**: Intelligent data caching
- **API Manager**: Enterprise-grade API integration
- **Filter System**: Advanced filtering capabilities

## 📱 Screenshots

<div align="center">
  <img src="Screenshot/WhatsApp Image 2025-09-11 at 3.38.27 PM.jpeg" width="200" alt="Map View"/>
  <img src="Screenshot/WhatsApp Image 2025-09-11 at 3.38.28 PM.jpeg" width="200" alt="Plot Details"/>
  <img src="Screenshot/WhatsApp Image 2025-09-11 at 3.38.29 PM.jpeg" width="200" alt="Filters"/>
  <img src="Screenshot/WhatsApp Image 2025-09-11 at 3.38.30 PM.jpeg" width="200" alt="Profile"/>
</div>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dha-marketplace-flutter.git
   cd dha-marketplace-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Quick Start (Windows)
```bash
# Use the provided batch file
run_app.bat
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── services/          # Core business logic services
│   ├── utils/             # Utility functions and helpers
│   └── constants/          # Application constants
├── data/
│   ├── models/            # Data models
│   ├── network/           # API services
│   └── repository/         # Data repositories
├── providers/             # State management
├── screens/               # UI screens
├── ui/
│   ├── screens/           # UI components
│   └── widgets/           # Reusable widgets
└── l10n/                  # Localization files
```

## 🔧 Configuration

### API Configuration
Update the API endpoints in:
- `lib/core/services/enterprise_api_manager.dart`
- `lib/data/network/plots_api_service.dart`

### Map Configuration
Configure map settings in:
- `lib/screens/projects_screen_instant.dart`
- `lib/core/services/enhanced_polygon_service.dart`

## 🎯 Key Features Explained

### Polygon Rendering System
The app features a sophisticated polygon rendering system that:
- Converts UTM coordinates to WGS84 lat/lng
- Handles multiple GeoJSON formats
- Implements progressive loading for performance
- Provides fallback parsing strategies

### Performance Optimizations
- **Instant Loading**: Map loads immediately with cached data
- **Progressive Rendering**: Only renders visible polygons
- **Smart Caching**: Intelligent data caching system
- **Background Processing**: Non-blocking operations

### Filter System
Advanced filtering capabilities:
- Plot type (Residential, Commercial)
- Plot size (3 Marla, 5 Marla, 7 Marla, 10 Marla, 1 Kanal)
- DHA Phase (Phase 1-7, RVS)
- Price range filtering
- Status filtering (Available, Sold, Reserved)

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

Run specific tests:
```bash
flutter test test/filter_test.dart
flutter test test/widget_test.dart
```

## 📊 Performance Metrics

- **Map Load Time**: < 2 seconds
- **Polygon Rendering**: Optimized for 100+ plots
- **Memory Usage**: Efficient memory management
- **Battery Optimization**: Background processing optimization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue in this repository
- Contact the development team
- Check the documentation in the `/Documentation Links/` folder

## 🗺️ Map Data

The application uses:
- **Boundary Data**: DHA Phase boundaries in GeoJSON format
- **Amenities Data**: Location data for parks, schools, mosques, etc.
- **Plot Data**: Real-time plot information from DHA API

## 🔄 Version History

- **v1.0.0**: Initial release with basic map functionality
- **v1.1.0**: Added polygon rendering and filtering
- **v1.2.0**: Performance optimizations and instant loading
- **v1.3.0**: Enhanced UI and multi-language support

## 🎨 Design System

The app follows Material Design principles with:
- **Color Scheme**: DHA brand colors (Blue #1E3C90, Teal #20B2AA)
- **Typography**: Inter and Poppins font families
- **Icons**: Material Design icons with custom DHA branding
- **Animations**: Smooth transitions and micro-interactions

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 11+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows (Windows 10+)
- ✅ macOS (macOS 10.14+)
- ✅ Linux (Ubuntu 18.04+)

---

**Built with ❤️ for DHA Community**