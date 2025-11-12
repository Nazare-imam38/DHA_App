# MapTiler API Integration Guide

## Overview

This guide explains how the DHA Marketplace app now uses MapTiler API endpoints instead of local GeoJSON files for boundary data. This integration provides better performance, reduced app bundle size, and dynamic updates.

## MapTiler API Endpoints

The app now fetches boundary data from the following MapTiler API endpoints:

### Phase Boundaries
- **Phase 1**: `https://api.maptiler.com/data/0199c78c-7608-7c9c-9f37-829f6e855976/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 2**: `https://api.maptiler.com/data/0199c78d-17c1-72cc-938e-91055a6ac1c9/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 3**: `https://api.maptiler.com/data/0199c790-7caa-797d-843c-38cfe260604b/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 4**: `https://api.maptiler.com/data/0199c794-25e7-7ca4-8e88-1f5852f96b51/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 4 GV**: `https://api.maptiler.com/data/0199c794-9c99-7831-8b0e-4927de2c9b8a/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 4 RVN**: `https://api.maptiler.com/data/0199c794-ff1e-7c52-bd07-45305f747039/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 4 RVS**: `https://api.maptiler.com/data/0199c796-b04a-7204-9990-54d9bb65c30e/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 5**: `https://api.maptiler.com/data/0199c797-495f-7d85-9965-79977c5334c4/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 6**: `https://api.maptiler.com/data/0199c797-eafc-7dfc-b64e-cdfd0104b6cf/features.json?key=sLbV8i7mevpHxpBO0R4c`
- **Phase 7**: `https://api.maptiler.com/data/0199c799-7326-79bf-aea5-4365b5559c18/features.json?key=sLbV8i7mevpHxpBO0R4c`

## Implementation Details

### 1. MapTiler Boundary Service (`lib/core/services/maptiler_boundary_service.dart`)

Basic service for fetching boundary data from MapTiler API:

```dart
// Load all boundaries from MapTiler API
final boundaries = await MapTilerBoundaryService.loadAllBoundaries();

// Load specific phase
final phase1Boundary = await MapTilerBoundaryService._loadBoundaryFromApi('Phase1', '0199c78c-7608-7c9c-9f37-829f6e855976');
```

### 2. Enhanced MapTiler Boundary Service (`lib/core/services/enhanced_maptiler_boundary_service.dart`)

Advanced service with memory caching and performance optimizations:

```dart
// Initialize the service
await EnhancedMapTilerBoundaryService.initialize();

// Get boundaries instantly from cache
final boundaries = EnhancedMapTilerBoundaryService.getBoundariesInstantly();

// Load all boundaries with caching
final boundaries = await EnhancedMapTilerBoundaryService.loadAllBoundaries();
```

### 3. Phase Label Widget (`lib/ui/widgets/phase_label_widget.dart`)

Widget for displaying phase names on boundaries:

```dart
// Enhanced phase label with styling
EnhancedPhaseLabel(
  phaseName: 'Phase 1',
  color: Colors.green,
  icon: Icons.home_work,
  position: LatLng(33.6844, 73.0479),
  zoom: 12.0,
)
```

## Key Features

### 1. **Performance Improvements**
- **Reduced App Bundle Size**: No more local GeoJSON files in assets
- **Dynamic Updates**: Boundary data can be updated without app updates
- **Memory Caching**: Boundaries are cached for instant access
- **Parallel Loading**: All boundaries load simultaneously for faster startup

### 2. **Phase Labels**
- **Automatic Labeling**: Each phase boundary displays its name
- **Zoom-Based Display**: Labels only show at zoom level 10+
- **Styled Labels**: Beautiful labels with phase colors and icons
- **Center Positioning**: Labels are positioned at the center of each boundary

### 3. **Caching System**
- **24-Hour Cache**: API responses are cached for 24 hours
- **Memory Cache**: Boundaries are stored in memory for instant access
- **Background Preloading**: Boundaries load in the background for instant display

## Usage in Screens

### Projects Screen (Instant)
```dart
// Load boundaries from MapTiler API
final boundaries = await maptiler.EnhancedMapTilerBoundaryService.loadAllBoundaries();

// Display phase labels
MarkerLayer(
  markers: _getPhaseLabelMarkers(),
)
```

### Projects Screen (Optimized)
```dart
// Same implementation with additional optimizations
final boundaries = await maptiler.EnhancedMapTilerBoundaryService.loadAllBoundaries();
```

## API Response Format

The MapTiler API returns GeoJSON data in the following format:

```json
{
  "type": "FeatureCollection",
  "name": "Phase1",
  "crs": {
    "type": "name",
    "properties": {
      "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
    }
  },
  "features": [
    {
      "type": "Feature",
      "properties": {
        "Phase": "Phase 1"
      },
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [...]
      }
    }
  ]
}
```

## Benefits

### 1. **Performance**
- ✅ Faster app startup (no local file loading)
- ✅ Reduced memory usage
- ✅ Better caching system
- ✅ Parallel data loading

### 2. **Maintenance**
- ✅ No need to update app for boundary changes
- ✅ Centralized data management
- ✅ Easy to add new phases
- ✅ Automatic updates from MapTiler

### 3. **User Experience**
- ✅ Phase labels on boundaries
- ✅ Consistent styling
- ✅ Better visual identification
- ✅ Zoom-based label display

## Configuration

### API Key
The MapTiler API key is configured in the service:
```dart
static const String _apiKey = 'sLbV8i7mevpHxpBO0R4c';
```

### Cache Settings
```dart
static const Duration _cacheExpiry = Duration(hours: 24); // 24-hour cache
```

### Phase Colors
```dart
static final Map<String, Color> _phaseColors = {
  'Phase1': const Color(0xFF4CAF50), // Green
  'Phase2': const Color(0xFF2196F3), // Blue
  'Phase3': const Color(0xFFFF9800), // Orange
  // ... more phases
};
```

## Error Handling

The service includes comprehensive error handling:

```dart
try {
  final boundaries = await EnhancedMapTilerBoundaryService.loadAllBoundaries();
} catch (e) {
  print('❌ Error loading boundaries: $e');
  // Fallback to cached data or empty list
}
```

## Monitoring

### Cache Statistics
```dart
final stats = EnhancedMapTilerBoundaryService.getCacheStatistics();
print('Cached boundaries: ${stats['cached_count']}');
```

### Loading Status
```dart
final status = EnhancedMapTilerBoundaryService.getLoadingStatus();
print('Is preloaded: ${status['is_preloaded']}');
print('Data source: ${status['data_source']}');
```

## Migration from Local GeoJSON

The app has been successfully migrated from local GeoJSON files to MapTiler API:

### Before (Local Files)
- ❌ Large app bundle size
- ❌ Static boundary data
- ❌ Manual updates required
- ❌ No phase labels

### After (MapTiler API)
- ✅ Smaller app bundle
- ✅ Dynamic boundary data
- ✅ Automatic updates
- ✅ Phase labels with styling

## Conclusion

The MapTiler API integration provides a modern, scalable solution for boundary data management. The implementation maintains backward compatibility while adding significant performance improvements and new features like phase labels.

The system is designed to be:
- **Fast**: Instant access through caching
- **Reliable**: Comprehensive error handling
- **Maintainable**: Centralized configuration
- **User-Friendly**: Clear phase identification with labels
