# Property Posting Integration Guide

This guide explains how to integrate the complete property posting flow into your existing DHA Marketplace app.

## Overview

The property posting implementation includes a 10-step flow with the updated order where owner details are moved to step 2. The implementation follows the existing app's design patterns and integrates seamlessly with the current codebase.

## Key Changes Made

### 1. Updated Step Order
- **Owner Details moved to Step 2** - Immediately after ownership selection
- **Conditional rendering** - If user selects "My Own Property", Step 2 shows confirmation message
- **Form validation** - Owner details form only appears if "On Behalf" is selected

### 2. New Files Created

```
lib/screens/property_posting/
├── models/property_form_data.dart
├── property_posting_flow.dart
├── steps/ (10 step files)
└── test_property_posting.dart

lib/services/property_service.dart
lib/widgets/step_progress_indicator.dart
```

### 3. Updated Files

- `lib/screens/ownership_selection_screen.dart` - Updated to navigate to new flow

## Integration Steps

### Step 1: Add Dependencies

Ensure these dependencies are in your `pubspec.yaml`:

```yaml
dependencies:
  provider: ^6.0.0
  http: ^1.1.0
  # ... other existing dependencies
```

### Step 2: Update Main App

Add the PropertyFormData provider to your main app:

```dart
// main.dart
import 'package:provider/provider.dart';
import 'screens/property_posting/models/property_form_data.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PropertyFormData()),
        // ... other providers
      ],
      child: MyApp(),
    ),
  );
}
```

### Step 3: Update Navigation

The ownership selection screen now navigates to the new property posting flow. No additional changes needed for basic integration.

### Step 4: Configure API

Update the API base URL in `lib/services/property_service.dart`:

```dart
class PropertyService {
  static const String baseUrl = 'YOUR_ACTUAL_API_BASE_URL';
  // ... rest of the implementation
}
```

### Step 5: Test Integration

Use the test screen to verify everything works:

```dart
// Add to your navigation or create a test button
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TestPropertyPostingScreen(),
  ),
);
```

## API Requirements

### Required Endpoints

1. **POST /create/property** - Create new property listing
2. **GET /property-types** - Get available property types
3. **GET /amenities** - Get available amenities
4. **GET /user/properties** - Get user's properties

### Authentication

The service expects a Bearer token. Update the `_getAuthToken()` method in `PropertyService` to use your actual authentication system.

## Customization Options

### 1. Styling
All components use the existing app's color scheme and design patterns. To customize:

- Update colors in individual step files
- Modify the `StepProgressIndicator` widget
- Adjust spacing and typography as needed

### 2. Form Fields
To add/remove form fields:

1. Update `PropertyFormData` model
2. Modify the corresponding step widget
3. Update validation logic
4. Update API integration

### 3. Step Order
To change step order:

1. Reorder the `steps` list in `property_posting_flow.dart`
2. Update the `stepNames` list
3. Update step numbers in individual step files
4. Update validation logic in `PropertyFormData`

## Testing

### Manual Testing
1. Navigate to the ownership selection screen
2. Select "My Own Property" and proceed
3. Verify Step 2 shows confirmation message
4. Go back and select "On Behalf of Someone Else"
5. Verify Step 2 shows owner details form
6. Complete the entire flow

### Automated Testing
The implementation includes proper state management that can be easily tested:

```dart
// Example test
testWidgets('Property posting flow test', (WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => PropertyFormData(),
      child: MaterialApp(home: PropertyPostingFlow()),
    ),
  );
  
  // Test step navigation
  expect(find.text('Ownership'), findsOneWidget);
  
  // Test form validation
  // ... add more tests
});
```

## Troubleshooting

### Common Issues

1. **Import errors**: Ensure all file paths are correct
2. **Provider errors**: Make sure PropertyFormData is provided at the app level
3. **API errors**: Check the base URL and authentication token
4. **Validation errors**: Verify all required fields are properly validated

### Debug Mode

Enable debug mode in `PropertyService` to see API requests:

```dart
// Add debug prints in PropertyService methods
print('Sending request to: ${request.url}');
print('Request fields: ${request.fields}');
```

## Performance Considerations

1. **Image uploads**: Implement proper image compression
2. **Form state**: The form data is kept in memory throughout the flow
3. **API calls**: Only one API call is made at the end of the flow
4. **Navigation**: Uses PageView for smooth step transitions

## Security Considerations

1. **File uploads**: Validate file types and sizes
2. **API tokens**: Store securely and refresh as needed
3. **Form data**: Validate all inputs on both client and server
4. **User data**: Ensure owner details are properly protected

## Future Enhancements

1. **Draft saving**: Save form progress locally
2. **Offline support**: Cache form data for offline completion
3. **Image editing**: Add basic image editing capabilities
4. **Location services**: Integrate with GPS for automatic location detection
5. **Price suggestions**: Add market price suggestions based on location

## Support

For issues or questions about the implementation:

1. Check the README in the property_posting directory
2. Review the test implementation
3. Check the API integration examples
4. Verify all dependencies are properly installed
