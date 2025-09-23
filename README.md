# DHA Marketplace Mobile App

A Flutter mobile application for the DHA (Defence Housing Authority) property marketplace, designed to replicate the functionality of the [DHA Marketplace website](https://dhamarketplace.com/).

## 🎨 Design System

### Color Scheme
- **Primary Green**: `#2ECC71` - Success, Available, CTA highlights
- **Royal Blue**: `#1E3A8A` - Headers, buttons, navigation
- **Gold**: `#FFC107` - CTA highlight buttons (Book Now, Explore)
- **Grey**: `#F4F4F6` - Background
- **Black**: `#222222` - Text/contrast

### Typography
- **Titles**: Poppins Bold
- **Body Text**: Inter Regular
- **Labels**: Inter Medium

## 📱 Features

### 1. Splash & Authentication
- **Splash Screen**: Gradient background with DHA logo and loading animation
- **Login Screen**: Email/password authentication with gradient background
- **Registration**: User registration with form validation

### 2. Home Screen
- **Hero Section**: Carousel showcasing DHA phases
- **Quick Actions**: Grid of 3 action buttons (Explore Plots, Gallery, My Bookings)
- **News Section**: Latest announcements and updates
- **Bottom Navigation**: Easy access to main sections

### 3. Property Listings
- **Advanced Filters**: Phase selection, price range slider, area size filter
- **Property Cards**: Full-width images with property details
- **Status Badges**: Available, Limited, Booked status indicators
- **Search Functionality**: Find properties by various criteria

### 4. Property Details
- **Image Carousel**: Swipeable property images
- **Tabbed Interface**: Overview, Payment Plan, Documentation
- **Sticky Footer**: Contact and Book Now buttons
- **Detailed Information**: Complete property specifications

### 5. Gallery
- **Masonry Grid**: Instagram-style image layout
- **Category Filters**: Filter by Commercial, Residential, Luxury, etc.
- **Full-Screen Viewer**: Tap to view images in full screen
- **Image Navigation**: Swipe between images with indicators

### 6. Profile & Bookings
- **User Profile**: Avatar, contact information, edit profile
- **My Bookings**: List of user's property bookings with status
- **Menu Options**: FAQ, Settings, Notifications, Logout
- **Status Tracking**: Pending, Confirmed, Completed booking states

### 7. FAQ & Contact
- **FAQ Section**: Expandable accordion with common questions
- **Contact Form**: Name, email, message submission
- **Contact Information**: Address, phone, email, working hours
- **Form Validation**: Client-side validation with error messages

## 🛠 Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Google Fonts**: Poppins and Inter font families
- **Carousel Slider**: Image carousels and sliders
- **Flutter Staggered Grid View**: Masonry grid layout
- **Photo View**: Full-screen image viewing

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  carousel_slider: ^4.2.1
  flutter_staggered_grid_view: ^0.7.0
  photo_view: ^0.14.0
  google_fonts: ^6.1.0
```

## 📁 Project Structure

```
lib/
├── main.dart
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── home_screen.dart
    ├── property_listings_screen.dart
    ├── property_detail_screen.dart
    ├── gallery_screen.dart
    ├── profile_screen.dart
    └── faq_contact_screen.dart

assets/
└── images/
    ├── README.md
    ├── property1.jpg
    ├── property2.jpg
    ├── phase1.jpg
    ├── gallery1.jpg
    └── ... (other images)
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dha_marketplace
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add images**
   - Add property images to `assets/images/` directory
   - Update image paths in the code if needed

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS IPA:**
```bash
flutter build ios --release
```

## 🎯 Key Features Implementation

### 1. Responsive Design
- Adaptive layouts for different screen sizes
- Consistent spacing using 8px grid system
- Material Design principles

### 2. Navigation
- Bottom navigation bar for main sections
- Stack-based navigation for detailed screens
- Proper back button handling

### 3. State Management
- StatefulWidget for local state management
- Form validation and error handling
- User input handling

### 4. UI Components
- Custom cards with shadows and rounded corners
- Consistent button styles and colors
- Loading states and animations
- Status indicators and badges

## 📱 Screen Flow

1. **Splash Screen** → **Login Screen** → **Home Screen**
2. **Home Screen** → **Property Listings** → **Property Details**
3. **Home Screen** → **Gallery** → **Full-Screen Image Viewer**
4. **Home Screen** → **Profile** → **FAQ & Contact**

## 🔧 Customization

### Colors
Update colors in `main.dart` and individual screen files:
```dart
const Color(0xFF2ECC71), // Primary Green
const Color(0xFF1E3A8A), // Royal Blue
const Color(0xFFFFC107), // Gold
const Color(0xFFF4F4F6), // Grey
const Color(0xFF222222), // Black
```

### Fonts
Modify font families in `main.dart`:
```dart
textTheme: GoogleFonts.poppinsTextTheme(),
```

### Images
Replace placeholder images in `assets/images/` with actual DHA property images.

## 🚧 Future Enhancements

- [ ] Backend API integration
- [ ] User authentication with JWT
- [ ] Real-time property updates
- [ ] Push notifications
- [ ] Offline data caching
- [ ] Payment gateway integration
- [ ] Social media sharing
- [ ] Advanced search filters
- [ ] Property comparison feature
- [ ] Multi-language support (English/Urdu)

## 📄 License

This project is created for DHA Marketplace mobile app development. All rights reserved.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For support and questions, please contact:
- Email: info@dhamarketplace.com
- Phone: +92-51-1234567

---

**Note**: This is a UI mockup implementation without backend integration. For production use, implement proper API connections, authentication, and data persistence.
