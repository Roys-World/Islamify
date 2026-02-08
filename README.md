# Islamify 🕌

A comprehensive Flutter application for Islamic prayer times, Quranic guidance, and daily Islamic practices with real-time location-based features and prayer notifications.

## 📱 Features

### Prayer Management
- **Real-time Prayer Times**: Automatic calculation based on GPS location and Islamic prayer methods
- **Prayer Countdown**: Live countdown timer to upcoming prayers
- **Prayer Notifications**: Smart notifications 5 minutes before each prayer time
- **Multiple Prayer Calculation Methods**: Support for Hanafi, Maliki, Shafi'i, and Hanbali madhabs
- **Prayer Time Caching**: Efficient daily caching to reduce API calls

### Quranic Features
- **Complete Quran Access**: Browse all 114 Surahs with full ayah translations
- **Parah Navigation**: Navigate by Islamic Parah divisions (30 sections)
- **Advanced Search**: Search Surahs by name (Arabic/English/Urdu/Spanish)
- **Surah Details**: Complete information with ayah-by-ayah translations
- **Multi-language Support**: Arabic, English, Urdu, and Spanish

### Islamic Practices
- **Supplications (Duas)**: Curated collection of Quranic and Sunnah supplications
- **Daily Azkaar**: Morning, evening, general, istighfar, and family azkaars with counts
- **Tasbeeh Counter**: Digital counter for Subhanallah, Alhamdulillah, Allahu Akbar
- **Expandable Details**: Benefits and recommendations for each practice

### Qibla Direction
- **Real-time Direction**: Live compass-based Qibla direction calculation
- **Distance Display**: Shows distance to Mecca
- **Visual Indicator**: Mosque icon with Kaaba indicator at perimeter

### Settings & Personalization
- **Dark/Light Mode**: Complete dark mode theme support
- **Notification Control**: Toggle notifications and prayer reminders
- **Language Selection**: Choose between multiple languages
- **Islamic Calendar**: Toggle between Gregorian and Hijri calendars
- **Persistent Storage**: All settings saved locally with SharedPreferences

## 🛠️ Tech Stack

### Framework & Language
- **Flutter 3.x**: Cross-platform mobile development
- **Dart**: Modern, type-safe programming language

### State Management
- **Provider 6.1.2**: Simple and scalable state management

### Key Dependencies
- **adhan**: Islamic prayer times calculation (Karachi method)
- **geolocator**: GPS location services with permission handling
- **geocoding**: Reverse geocoding for location names
- **flutter_compass**: Real-time compass for Qibla direction
- **shared_preferences**: Local persistent storage
- **flutter_local_notifications + timezone**: Prayer time alerts with timezone support
- **http**: API requests for Quran data and Islamic dates
- **sqflite**: Local database for Quran caching

### Development Tools
- **Material 3**: Latest Material Design implementation
- **Responsive UI**: Adaptive layouts for all screen sizes
- **Effective Dart**: Code style and best practices

## 📦 Project Structure

```
lib/
├── main.dart                 # App entry point with notification initialization
├── app.dart                  # Material app configuration with dual themes
├── location_service.dart     # Unified location service
├── core/
│   ├── constants/
│   │   └── app_colors.dart   # Comprehensive color palette (light/dark)
│   └── utils/
│       └── responsive.dart   # Responsive design utilities
├── data/
│   └── models/               # Data models and structures
├── models/
│   └── prayer_models.dart    # Prayer-related models
├── providers/
│   ├── prayer_provider.dart       # Prayer times & notifications
│   ├── settings_provider.dart     # App settings with persistence
│   ├── quran_provider.dart        # Quran data management
│   └── daily_tasks_provider.dart  # Daily tasks tracking
├── services/
│   ├── notification_service.dart      # Prayer notifications
│   ├── prayer_times_service.dart      # Prayer calculations
│   ├── islamic_date_service.dart      # Islamic date conversion
│   ├── quran_service.dart             # Quran API integration
│   ├── quran_database_service.dart    # Local Quran database
│   └── quran_api_service.dart         # Quran API client
└── ui/
    └── screens/
        ├── home_screen.dart              # Main dashboard
        ├── prayers_screen.dart           # Prayer times & countdown
        ├── qibla_screen.dart             # Qibla direction calculator
        ├── quran_screen.dart             # Quran browser
        ├── surah_detail_screen.dart      # Surah verses display
        ├── parah_detail_screen.dart      # Parah verses display
        ├── supplication_screen.dart      # Islamic supplications
        ├── azkaar_screen.dart            # Daily azkaars
        ├── tasbeeh_screen.dart           # Tasbeeh counter
        └── settings_screen.dart          # App preferences
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android SDK (for Android builds)
- iOS SDK (for iOS builds, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Roys-World/Islamify.git
   cd Islamify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build release APK**
   ```bash
   flutter build apk --release
   ```

## 📋 Configuration

### Prayer Calculation Methods
The app uses the **Karachi method** by default (Hanafi madhab). Other methods are selectable:
- Hanafi (Karachi) - Default
- Maliki
- Shafi'i
- Hanbali

### Location Services
- **Automatic**: App requests GPS location on first run
- **Manual**: Can update location in prayers screen
- **Caching**: Daily location cache prevents repeated API calls

### Notifications
- **Android 13+**: Automatic permission request
- **iOS**: Alert, Badge, and Sound permissions
- **Timing**: Notifications trigger 5 minutes before prayer time

## 🎨 Design & UI

### Color Scheme
- **Light Mode**: Warm, professional palette with green accent (Primary: #1B6B45)
- **Dark Mode**: Deep blue-grey with golden accents for better night visibility
- **Gradients**: Modern gradient backgrounds for visual appeal
- **Shadows**: Material design elevation and shadows

### Responsive Design
- Fully responsive layouts for mobile devices
- Adaptive padding and font sizing
- Landscape and portrait support
- Multi-screen device compatibility

## 🔐 Permissions Required

### Android
- `ACCESS_FINE_LOCATION`: GPS location access
- `ACCESS_COARSE_LOCATION`: Approximate location
- `ACCESS_BACKGROUND_LOCATION`: Background location for updates
- `INTERNET`: API and data requests
- `POST_NOTIFICATIONS`: Prayer notifications (Android 13+)
- `SCHEDULE_EXACT_ALARM`: Precise notification scheduling

### iOS
- Location (when in use)
- Notifications (alert, badge, sound)

## 📡 API Integration

### Quran API
- Source: Quran.com API
- Features: Arabic text, multiple translations, metadata
- Caching: Local SQLite database for offline access

### Prayer Times
- Method: Adhan library (Karachi calculation)
- Location: GPS-based with fallback to Islamabad
- Updates: Daily automatic recalculation at midnight

### Islamic Dates
- Service: Islamic date conversion API
- Caching: Daily cache with validation
- Fallback: Built-in calculation if API unavailable

## 🧪 Testing

### Device Testing
- Tested on Android devices (API 21+)
- Responsive design tested on various screen sizes
- Location services tested with real GPS data

### Prayer Notifications
To test notifications:
1. Go to Settings → Enable Notifications & Prayer Reminders
2. Wait 5 minutes before a prayer time
3. You'll receive a notification automatically

## 📚 Documentation

- **Responsive Design**: See [RESPONSIVE_DESIGN_SUMMARY.md](RESPONSIVE_DESIGN_SUMMARY.md)
- **Prayer Notifications**: See [PRAYER_NOTIFICATIONS_GUIDE.md](PRAYER_NOTIFICATIONS_GUIDE.md)

## 🤝 Contributing

This is a personal academic project. For contributions, improvements, or bug reports, please create an issue or pull request.

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👨‍💻 Author

**Roy's World**
- GitHub: [@Roys-World](https://github.com/Roys-World)

## 🙏 Acknowledgments

- **Adhan.js**: Islamic prayer times calculation
- **Quran.com**: Quranic text and translations
- **Flutter Team**: Exceptional framework and documentation
- **Islamic Communities**: For guidance on Islamic practices and calculations

## 📞 Support

For support, questions, or feature requests:
1. Check existing issues on GitHub
2. Create a new issue with detailed description
3. Include device info and app version

## 🔄 Version History

### v1.0.0 (Current)
- Initial release with all core features
- Prayer times with notifications
- Complete Quran browser
- Islamic practices (duas, azkaars, tasbeeh)
- Qibla direction calculator
- Dark mode support
- Multi-language support

---

**Made with ❤️ for the Muslim community**

*Alhamdulillah for the completion of this project. May it be beneficial for Muslims seeking to deepen their faith and practice Islam in their daily lives.*
