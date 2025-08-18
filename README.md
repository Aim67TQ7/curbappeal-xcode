# CurbAppeal iOS App

A comprehensive real estate application built for iOS with Swift, featuring location services, push notifications, and property browsing capabilities designed for App Store deployment.

## Features

### Core Functionality
- **Property Browsing**: Interactive map view with property markers and detailed list view
- **Advanced Search**: Location-based search with filtering by property type, price, and other criteria
- **Property Details**: Comprehensive property information with image galleries, virtual tours, and agent contact
- **Favorites Management**: Save and manage favorite properties
- **Location Services**: GPS-based property discovery and distance calculations

### iOS-Specific Features
- **Push Notifications**: Property alerts, price changes, and viewing reminders
- **Background Location**: Geofenced notifications when near properties of interest
- **Native UI**: Fully native iOS interface following Human Interface Guidelines
- **Universal Support**: Optimized for iPhone and iPad
- **iOS Integration**: Share properties, contact agents via phone/email, calendar integration

### App Store Ready
- **Privacy Compliance**: Proper usage descriptions for all sensitive permissions
- **Background Modes**: Configured for location and remote notifications
- **App Icons**: Complete icon set for all device sizes
- **Launch Screen**: Professional branded launch experience
- **Deployment Target**: iOS 15.0+ for broad compatibility

## Technical Architecture

### Frameworks Used
- **UIKit**: Native iOS user interface
- **MapKit**: Interactive property maps and location display
- **CoreLocation**: GPS services and geofencing
- **UserNotifications**: Local and remote push notifications
- **MessageUI**: Native email composition
- **Foundation**: Core data structures and utilities

### Project Structure
```
CurbAppeal/
├── Models/
│   └── Property.swift              # Property data model
├── Views/
│   ├── Main.storyboard            # Interface layouts
│   └── LaunchScreen.storyboard    # App launch screen
├── Controllers/
│   ├── HomeViewController.swift    # Map-based property browsing
│   ├── PropertyListViewController.swift    # List view with sorting
│   └── PropertyDetailViewController.swift  # Detailed property information
├── Services/
│   ├── LocationManager.swift      # GPS and geofencing services
│   └── NotificationManager.swift  # Push notification handling
├── Resources/
│   └── Assets.xcassets           # App icons and images
├── AppDelegate.swift             # App lifecycle and setup
├── SceneDelegate.swift           # Scene management for iOS 13+
└── Info.plist                   # App configuration and permissions
```

## Setup Instructions

### Prerequisites
- Xcode 14.0+
- iOS 15.0+ deployment target
- Apple Developer Account (for App Store deployment)
- CocoaPods installed

### Installation
1. Clone or download the project
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   pod install
   ```
4. Open `CurbAppeal.xcworkspace` in Xcode
5. Configure your development team in project settings
6. Update bundle identifier to your unique ID
7. Build and run on device or simulator

### Configuration
1. **Location Services**: The app will request location permission on first launch
2. **Notifications**: Push notification permission requested during app setup
3. **Developer Team**: Set your Apple Developer Team in project settings
4. **Bundle ID**: Update to your unique bundle identifier for App Store submission

## App Store Deployment

### Required Setup
1. **Apple Developer Account**: Paid developer account required
2. **App Store Connect**: Create app listing in App Store Connect
3. **Bundle Identifier**: Must match your App Store Connect app
4. **Code Signing**: Configure automatic or manual signing
5. **App Icons**: All icon sizes included in Assets.xcassets
6. **Privacy Policy**: Required for location and notification features

### Permissions Explained
The app requests the following permissions with clear justifications:

- **Location (Always)**: For geofenced notifications when near saved properties
- **Location (When In Use)**: For showing nearby properties and calculating distances
- **Camera**: For taking property photos (if feature is implemented)
- **Photo Library**: For saving and selecting property images
- **Push Notifications**: For property alerts and viewing reminders

### App Store Review Guidelines Compliance
- All location usage clearly explained to users
- Background location only used for relevant property notifications
- Notifications provide clear value to users
- No unnecessary data collection
- Follows iOS Human Interface Guidelines

## Key Features for Real Estate Use

### Property Discovery
- Interactive map showing property locations
- List view with sorting by price, distance, or date
- Search by address, city, or ZIP code
- Filter by property type (house, condo, etc.)

### Property Information
- High-resolution photo galleries
- Detailed specifications (beds, baths, square footage)
- Property description and features
- Agent contact information
- Virtual tour integration (when available)

### User Engagement
- Save favorite properties
- Share properties with others
- Schedule viewing reminders
- Get notified of price changes
- Location-based property alerts

### Professional Features
- Agent contact via phone and email
- Property sharing via native share sheet
- Calendar integration for appointments
- Professional UI/UX design
- Fast, responsive performance

## Dependencies (via CocoaPods)

- **Firebase**: Analytics, crash reporting, and remote notifications
- **Alamofire**: Network requests for property data
- **Kingfisher**: Efficient image loading and caching
- **Lottie**: Smooth animations and loading indicators
- **SnapKit**: Auto Layout assistance
- **SwiftyJSON**: JSON parsing utilities

## License

This project is created for educational and development purposes. Ensure you have proper licensing for any real estate data and comply with MLS requirements if using live property data.

## Support

For technical support or questions about the implementation:
- Review the code comments for detailed implementation notes
- Check Info.plist for all configured permissions and capabilities
- Refer to Apple's documentation for App Store submission guidelines