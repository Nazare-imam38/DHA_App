# DHA Marketplace - MBTiles Troubleshooting Guide

## 🚨 **Issue: Town Plan Tiles Not Loading**

Based on your screenshot showing the Town Plan panel open with "Phase 2" selected but no overlay visible on the map, here are the fixes I've implemented and troubleshooting steps.

## ✅ **Fixes Applied**

### **1. Fixed URL Format**
- **Before**: `https://tiles.dhamarketplace.com/data/${_selectedTownPlanLayer}/tiles/{z}/{x}/{y}.png`
- **After**: `https://tiles.dhamarketplace.com/data/${_selectedTownPlanLayer}/{z}/{x}/{y}.png`
- **Issue**: Extra `/tiles/` in the path was incorrect

### **2. Added Zoom Level Restrictions**
- **Added**: `minZoom: 14` to town plan tile layer
- **Issue**: Tiles were trying to load at all zoom levels, causing errors

### **3. Added Null Check**
- **Added**: `&& _selectedTownPlanLayer != null` condition
- **Issue**: Tile layer was trying to load even when no layer was selected

### **4. Enhanced Error Handling**
- **Added**: Detailed error logging with tile URLs
- **Added**: Visual tile borders for debugging
- **Added**: Debug overlay showing current state

### **5. Added Default Layer Selection**
- **Added**: Automatic selection of 'phase2' as default
- **Issue**: No default layer was set when town plan was enabled

## 🔧 **Debug Features Added**

### **Debug Overlay**
When town plan is enabled, you'll see a debug overlay showing:
- Selected layer
- Current zoom level
- Map center coordinates
- Zoom level check (✅ if >= 14, ❌ if < 14)
- Tile URL format

### **Enhanced Error Messages**
- Server connectivity tests
- Specific tile availability tests
- User-friendly error messages via SnackBar

## 🧪 **Testing Steps**

### **Step 1: Enable Town Plan**
1. Open the Town Plan panel
2. Select "Phase 2" (should be selected by default now)
3. Check the debug overlay for status

### **Step 2: Check Zoom Level**
1. Zoom in to level 14 or higher
2. The debug overlay should show "Min Zoom: 14 (✅)"
3. If it shows "❌", zoom in more

### **Step 3: Check Network**
1. Look for error messages in the console
2. Check if the debug overlay shows the correct URL
3. Test network connectivity

### **Step 4: Verify Tile Server**
The app will now automatically test:
- Server connectivity
- Specific tile availability
- Show success/error messages

## 🐛 **Common Issues & Solutions**

### **Issue 1: "Min Zoom: 14 (❌)"**
**Solution**: Zoom in to level 14 or higher
```dart
// The tile layer now has minZoom: 14
TileLayer(
  minZoom: 14, // Only show at high zoom levels
  // ...
)
```

### **Issue 2: "Layer: None"**
**Solution**: The app now sets a default layer automatically
```dart
// Default layer is now set automatically
if (_selectedTownPlanLayer == null) {
  _selectedTownPlanLayer = 'phase2';
}
```

### **Issue 3: Network Errors**
**Solution**: Check the debug overlay for specific error messages
- Server not accessible: Check internet connection
- Tile not available: Try different location or zoom level

### **Issue 4: Wrong URL Format**
**Solution**: Fixed the URL format (removed extra `/tiles/`)
```dart
// Correct format
urlTemplate: 'https://tiles.dhamarketplace.com/data/${_selectedTownPlanLayer}/{z}/{x}/{y}.png'
```

## 📱 **How to Test**

### **1. Enable Debug Mode**
The debug overlay will automatically appear when town plan is enabled.

### **2. Check Console Output**
Look for these messages in the console:
```
🗺️ Default town plan layer set to: phase2
🔍 Testing town plan tile URL: https://tiles.dhamarketplace.com/data/phase2/14/12345/67890.png
🌐 Server response: 200
✅ Tile server test passed
```

### **3. Visual Indicators**
- Blue borders around tiles (when loading)
- Debug overlay with status information
- Success/error SnackBar messages

## 🔍 **Advanced Debugging**

### **Manual Tile Testing**
You can manually test tile URLs in your browser:
```
https://tiles.dhamarketplace.com/data/phase2/14/12345/67890.png
```

### **Console Debugging**
Check the console for these messages:
- `🗺️` - Town plan status
- `🔍` - Testing information
- `✅` - Success messages
- `❌` - Error messages
- `🚫` - Tile loading errors

### **Network Tab**
In your browser's developer tools, check the Network tab for:
- Failed tile requests (404, 500, etc.)
- Successful tile requests (200)
- Request URLs and response headers

## 🎯 **Expected Behavior**

### **When Working Correctly**
1. Town Plan panel shows "Phase 2" selected
2. Debug overlay shows "Min Zoom: 14 (✅)"
3. Tiles load with blue borders
4. Console shows success messages
5. Map displays town plan overlay

### **When Not Working**
1. Debug overlay shows error status
2. Console shows error messages
3. SnackBar shows error notification
4. No tiles visible on map

## 🚀 **Quick Fixes**

### **If Still Not Working**
1. **Check zoom level**: Must be 14 or higher
2. **Check network**: Ensure internet connection
3. **Check server**: Verify tiles.dhamarketplace.com is accessible
4. **Check location**: Ensure you're viewing DHA area
5. **Check console**: Look for specific error messages

### **Reset Town Plan**
1. Disable town plan
2. Re-enable town plan
3. Select Phase 2 again
4. Check debug overlay

## 📊 **Performance Monitoring**

The enhanced implementation includes:
- Automatic server connectivity testing
- Tile availability verification
- Performance metrics
- Error rate monitoring
- User-friendly feedback

## 🎉 **Success Indicators**

You'll know it's working when:
- ✅ Debug overlay shows all green checkmarks
- ✅ Console shows success messages
- ✅ Tiles appear on the map with blue borders
- ✅ SnackBar shows "Town plan tiles are loading correctly!"

## 🔄 **Next Steps**

If the basic fixes don't work:
1. Check the tile server status
2. Verify the tile URLs are correct
3. Test with different phases
4. Check network connectivity
5. Review console error messages

The enhanced implementation should resolve the MBTiles loading issues you're experiencing!
