# TrynaGo 🌟

**Discover activities near you with a swipe!**

TrynaGo is a location-based activity discovery app that brings the familiar swipe mechanics of dating apps to finding events and activities. Whether you're looking for a hiking group, pickup basketball game, coffee meetup, or art gallery opening - just swipe right to show interest!

## ✨ Features

### 🎯 Core Functionality
- **Tinder-style swiping** - Swipe right to like, left to pass
- **Location-based discovery** - Find activities happening near you
- **Smart matching** - Keep track of events you're interested in
- **User profiles** - Showcase your interests and activity history

### 📱 Current Screens
- **Authentication** - Login/Register with demo mode
- **Discover** - Swipe through events with smooth animations
- **Matches** - View and manage your liked events
- **Profile** - Personal stats, interests, and settings

### 🎨 User Experience
- **Beautiful UI** - Modern, clean design with custom animations
- **Smooth interactions** - Buttery 60fps swiping with visual feedback
- **Responsive design** - Works perfectly on all screen sizes
- **Intuitive navigation** - Easy-to-use bottom tab navigation

## 🛠 Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **flutter_riverpod** - State management
- **go_router** - Navigation and routing
- **flutter_card_swiper** - Tinder-style card swiping

### Key Dependencies
```yaml
flutter_riverpod: ^2.4.9      # State management
go_router: ^12.1.3            # Navigation
flutter_card_swiper: ^7.0.1   # Card swiping
geolocator: ^10.1.0          # Location services
dio: ^5.4.0                  # HTTP client
cached_network_image: ^3.3.0  # Image caching
flutter_animate: ^4.3.0      # Animations
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android device/emulator or iOS simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/trynago.git
   cd trynago
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```
   
   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>TrynaGo needs location access to show nearby activities.</string>
   ```

4. **Run the app**
   ```bash
   # For web (development)
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS (Mac only)
   flutter run -d ios
   ```

## 📁 Project Structure

```
trynago/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # App configuration & routing
│   ├── models/                   # Data models
│   │   ├── event.dart           # Event model
│   │   └── user.dart            # User model
│   ├── screens/                  # UI screens
│   │   ├── auth/                # Authentication screens
│   │   ├── discover/            # Event discovery
│   │   ├── matches/             # Liked events
│   │   └── profile/             # User profile
│   ├── widgets/                  # Reusable components
│   │   └── event_card.dart      # Event card widget
│   ├── providers/               # State management
│   │   └── app_state.dart       # Global app state
│   └── services/                # API & external services
├── assets/                      # Images and static files
├── android/                     # Android configuration
├── ios/                         # iOS configuration
└── web/                         # Web configuration
```

## 🎮 How to Use

### Demo Mode
1. Launch the app
2. Tap **"Try Demo Mode"** on the login screen
3. Start swiping through sample events!

### Full Experience
1. **Register** for an account or **login**
2. **Allow location access** when prompted
3. **Discover** events by swiping:
   - ➡️ **Swipe right** if you're interested
   - ⬅️ **Swipe left** to pass
   - 🔄 **Tap undo** to reverse your last swipe
4. **Check "Matches"** to see events you liked
5. **View your profile** to see stats and manage settings

## 🔮 Upcoming Features

### 🏗 In Development
- **Photo carousels** for events (multiple images)
- **Enhanced swipe gestures** (up/down for more actions)
- **User-created events** (post your own activities)
- **Real-time event data** (Meetup API integration)

### 🎯 Roadmap
- **Chat system** for event attendees
- **Push notifications** for matches and reminders
- **Advanced filters** (category, distance, price, time)
- **Map view** of nearby events
- **Social features** (follow friends, see their activities)
- **Event reviews** and ratings

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines
- Follow Flutter/Dart conventions
- Write descriptive commit messages
- Add comments for complex logic
- Test on multiple screen sizes
- Ensure smooth 60fps animations

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **Web** (Chrome, Safari, Firefox)
- 🔄 **Desktop** (Coming soon)

## 🐛 Known Issues

- Location services may require app restart on first permission grant
- Web version has limited location accuracy
- Some animations may be slower on older devices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter team** for the amazing framework
- **flutter_card_swiper** for smooth swipe mechanics
- **Riverpod** for clean state management
- **All contributors** who help make TrynaGo better

## 📞 Contact

- **Email**: hello@trynago.com
- **Website**: [trynago.com](https://trynago.com)
- **Issues**: [GitHub Issues](https://github.com/yourusername/trynago/issues)

---

**Ready to discover your next adventure? Download TrynaGo and start swiping! 🚀**