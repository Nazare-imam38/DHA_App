# Plot Info Card Zoom-Based Visibility Implementation

## Overview
Implemented zoom-based visibility control for plot info cards to prevent UI clutter when zooming out beyond a certain level. This ensures that plot information cards automatically disappear when the zoom level is too low, maintaining a clean map interface.

## Implementation Details

### 1. Zoom Threshold
- **Minimum Zoom Level**: 14.0
- **Behavior**: Plot info cards are only visible when zoom level is 14.0 or higher
- **Rationale**: At zoom levels below 14.0, plot boundaries become too small to be meaningful, and info cards would clutter the map interface

### 2. Code Changes

#### File: `lib/screens/projects_screen_instant.dart`

**Method: `_getPlotPopupMarker()`**
- Added zoom level check: `if (_zoom < 14.0) return [];`
- Added debug logging to track visibility state
- Plot info cards are now conditionally rendered based on zoom level

**Method: `_handleZoomChange(int newZoomLevel)`**
- Added plot card visibility feedback in zoom change handler
- Provides console logging when plot cards are shown/hidden based on zoom level
- Maintains existing functionality for amenities and other map features

### 3. User Experience

#### Before Implementation:
- Plot info cards remained visible at all zoom levels
- Cards became disproportionately large when zoomed out
- Map UI was cluttered with oversized plot information

#### After Implementation:
- Plot info cards automatically disappear when zoom level drops below 14.0
- Cards reappear when zooming back in to 14.0 or higher
- Clean map interface at lower zoom levels
- Optimal viewing experience for plot details at appropriate zoom levels

### 4. Technical Benefits

1. **Performance**: Reduces rendering overhead at low zoom levels
2. **UX**: Prevents UI clutter and maintains map readability
3. **Responsive**: Automatically adapts to user zoom behavior
4. **Consistent**: Follows standard map application patterns

### 5. Debug Information

The implementation includes comprehensive logging:
- `🔍 Plot info card hidden - zoom level X is too low (minimum: 14.0)`
- `🔍 Plot info card visible - zoom level X is sufficient (minimum: 14.0)`
- `🔍 Plot info card will be hidden/visible - zoom level X is below/above minimum (14.0)`

### 6. Testing

To test the implementation:
1. Select a plot to show the info card
2. Zoom out gradually - card should disappear at zoom level 13.9 and below
3. Zoom back in - card should reappear at zoom level 14.0 and above
4. Verify console logs show appropriate visibility messages

## Files Modified
- `lib/screens/projects_screen_instant.dart` - Added zoom-based visibility control

## Future Enhancements
- Could add smooth fade-out animation when hiding cards
- Could make zoom threshold configurable
- Could add different thresholds for different types of plot information
