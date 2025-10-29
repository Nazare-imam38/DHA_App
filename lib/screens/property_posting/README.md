# Property Posting Implementation

This directory contains the complete property posting flow implementation with the updated step order where owner details are moved to step 2.

## File Structure

```
lib/screens/property_posting/
├── models/
│   └── property_form_data.dart          # Data model for form state management
├── steps/
│   ├── ownership_selection_step.dart    # Step 1: Ownership selection
│   ├── owner_details_step.dart          # Step 2: Owner details (MOVED HERE)
│   ├── purpose_selection_step.dart      # Step 3: Purpose selection
│   ├── type_pricing_step.dart           # Step 4: Type & pricing
│   ├── property_details_step.dart       # Step 5: Property details
│   ├── location_details_step.dart       # Step 6: Location details
│   ├── unit_details_step.dart           # Step 7: Unit details
│   ├── payment_method_step.dart         # Step 8: Payment method
│   ├── media_upload_step.dart           # Step 9: Media upload
│   └── amenities_selection_step.dart    # Step 10: Amenities selection
├── property_posting_flow.dart           # Main flow controller
└── test_property_posting.dart           # Test screen
```

## Key Features

### 1. Updated Step Order
- **Step 1**: Ownership Selection (Own property vs On behalf)
- **Step 2**: Owner Details (Only if "On behalf" selected)
- **Step 3**: Purpose Selection (Sell vs Rent)
- **Step 4**: Type & Pricing
- **Step 5**: Property Details
- **Step 6**: Location Details
- **Step 7**: Unit Details
- **Step 8**: Payment Method
- **Step 9**: Media Upload
- **Step 10**: Amenities Selection

### 2. Smart Step Navigation
- Owner details step shows confirmation message if user owns the property
- Form validation ensures all required fields are completed before proceeding
- Progress indicator shows current step and completion status

### 3. Data Management
- `PropertyFormData` class manages all form state using ChangeNotifier
- Validation methods for each step
- Update methods for each form section
- Helper methods for conditional logic

### 4. API Integration
- `PropertyService` handles API communication
- Supports multipart form data for file uploads
- Includes owner details in API payload when applicable
- Error handling and success responses

## Usage

### Basic Implementation

```dart
import 'package:provider/provider.dart';
import 'screens/property_posting/property_posting_flow.dart';
import 'screens/property_posting/models/property_form_data.dart';

// In your main app or navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChangeNotifierProvider(
      create: (_) => PropertyFormData(),
      child: PropertyPostingFlow(),
    ),
  ),
);
```

### Testing

Use the test screen to verify the complete flow:

```dart
import 'screens/property_posting/test_property_posting.dart';

// Navigate to test screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => TestPropertyPostingScreen()),
);
```

## API Integration

### Required API Endpoints

1. **Create Property**: `POST /create/property`
2. **Property Types**: `GET /property-types`
3. **Amenities**: `GET /amenities`
4. **User Properties**: `GET /user/properties`

### API Payload Structure

```json
{
  "purpose": "Sell",
  "property_type_id": 1,
  "title": "Beautiful 3 Bedroom House",
  "description": "A beautiful house with modern amenities",
  "area": 3.5,
  "area_unit": "Marla",
  "category": "Residential",
  "unit_no": "Ground Floor",
  "price": 5000000,
  "latitude": 24.8607,
  "longitude": 67.0011,
  "location": "DHA Phase 2",
  "sector": "A",
  "phase": "Phase 2",
  "payment_method": "KuickPay",
  "property_duration": "30",
  "on_behalf": 0,
  "cnic": "3840392735407",
  "name": "John Doe",
  "phone": "+923035523964",
  "address": "123 Main Street, Karachi",
  "email": "john@example.com",
  "images[]": ["file1.jpg", "file2.jpg"],
  "videos[]": ["video1.mp4"],
  "amenities[1][1]": "1",
  "amenities[1][2]": "2"
}
```

## Customization

### Adding New Steps

1. Create a new step widget in the `steps/` directory
2. Add the step to the `steps` list in `property_posting_flow.dart`
3. Add the step name to the `stepNames` list
4. Update the `PropertyFormData` model if needed
5. Add validation logic in `isStepValid()` method

### Modifying Form Fields

1. Update the `PropertyFormData` model
2. Add validation logic
3. Update the corresponding step widget
4. Update API integration in `PropertyService`

### Styling

All steps use consistent styling with:
- Blue color scheme (`Colors.blue[600]`, `Colors.blue[800]`)
- White cards with subtle shadows
- Rounded corners and proper spacing
- Responsive design

## Dependencies

- `provider`: State management
- `http`: API communication
- `flutter/material.dart`: UI components

## Notes

- The implementation follows the existing app's design patterns
- All form validation is client-side
- File upload simulation is included (replace with actual image picker)
- Error handling is implemented for API calls
- The flow is fully responsive and follows Material Design guidelines
