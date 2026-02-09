# Prayer Notification System - Implementation Guide

## Overview

The Islamic app now has a fully functional prayer notification system that alerts users 5 minutes before each prayer time. The system integrates seamlessly with the existing settings and respects user preferences.

## Features Implemented

### 1. **NotificationService** (`lib/services/notification_service.dart`)

- Singleton pattern for global access
- Initializes notification channels for Android and iOS
- Requests necessary permissions (Android 13+)
- Schedules notifications using timezone-aware scheduling
- Checks user settings before sending notifications
- Methods:
  - `initialize()` - Sets up notification system on app start
  - `schedulePrayerNotification()` - Schedules a notification for a specific prayer
  - `showPrayerNotification()` - Shows immediate notification (for testing)
  - `cancelPrayerNotifications()` - Cancels all scheduled prayers
  - `cancelNotification()` - Cancels a specific prayer notification

### 2. **PrayerProvider Updates** (`lib/providers/prayer_provider.dart`)

- Automatically schedules notifications for all daily prayers
- Re-schedules notifications at midnight
- Re-schedules when user location changes
- Integrates with NotificationService
- Skips past prayers (doesn't schedule if time has already passed)
- Method: `rescheduleNotifications()` - Can be called manually to refresh notifications

### 3. **Settings Integration** (`lib/ui/screens/settings_screen.dart`)

- **Notifications Toggle**:
  - When disabled: Cancels all scheduled notifications
  - When enabled: Reschedules all prayer notifications
- **Prayer Reminders Toggle**:
  - Same behavior as Notifications toggle
  - Works in conjunction with Notifications setting
- Both settings must be enabled for notifications to work

### 4. **Main App Initialization** (`lib/main.dart`)

- Initializes NotificationService before app runs
- Ensures notification system is ready when providers start

## How It Works

### Scheduling Logic

1. When app starts or at midnight, all prayer times are calculated
2. For each prayer (Fajr, Dhuhr, Asr, Maghrib, Isha):
   - Checks if notifications are enabled in settings
   - Calculates notification time (5 minutes before prayer)
   - Schedules notification if time hasn't passed yet
   - Skips if time has already passed

### Settings Respect

- Notifications only send if BOTH settings are enabled:
  - `notificationsEnabled` = true
  - `prayerReminders` = true
- Settings are stored in SharedPreferences and persist across app restarts
- Toggling either setting will cancel or reschedule all notifications

### Notification Details

- **Channel**: "Prayer Reminders"
- **Title**: "Prayer Time: [Prayer Name]"
- **Body**: "Upcoming prayer at [Time]"
- **Timing**: 5 minutes before actual prayer time
- **Sound**: Default notification sound (can be customized)
- **Vibration**: Enabled
- **Priority**: High (ensures notification is shown)

## Testing the System

### Method 1: Wait for Prayer Time

1. Open the app and ensure notifications are enabled in Settings
2. Check the Prayers screen for next prayer time
3. Wait until 5 minutes before prayer time
4. You should receive a notification

### Method 2: Debug Logs

Check console logs for:

- `✓ Scheduled notification for [Prayer Name] at [Time]`
- `⚠ Notifications disabled - skipping scheduling for [Prayer Name]`
- `⚠ Skipped scheduling for [Prayer Name] - time has already passed`

### Method 3: Manual Testing

You can modify the notification timing in `_scheduleNotifications()` method:

```dart
// Change from 5 minutes to 1 minute for faster testing
final scheduledTime = prayerDateTime.subtract(const Duration(minutes: 1));
```

## Required Permissions

### Android

- `POST_NOTIFICATIONS` (Android 13+) - Automatically requested by plugin
- `USE_EXACT_ALARM` - For precise scheduling (included in manifest)

### iOS

- Alert, Badge, Sound permissions - Requested on first app launch

## Dependencies Added

```yaml
flutter_local_notifications: ^17.1.0 # Core notification functionality
timezone: ^0.9.2 # Timezone-aware scheduling
```

## File Structure

```
lib/
├── main.dart                          # Initializes NotificationService
├── services/
│   └── notification_service.dart      # Handles all notification logic
├── providers/
│   └── prayer_provider.dart           # Schedules prayer notifications
└── ui/
    └── screens/
        └── settings_screen.dart       # Controls notification settings
```

## Troubleshooting

### Notifications Not Appearing

1. Check if both settings are enabled:
   - Go to Settings → Notifications = ON
   - Go to Settings → Prayer Reminders = ON
2. Verify prayer time hasn't passed (check console logs)
3. Ensure device notification permissions are granted
4. Check if device is in Do Not Disturb mode

### Notifications Showing at Wrong Time

- The app uses local device timezone
- Verify location services are enabled
- Check if prayer times are correct on Prayers screen

### App Crashes on Notification

- Ensure `flutter pub get` was run after adding dependencies
- Check Android manifest includes notification permissions
- Verify Flutter Local Notifications plugin is properly configured

## Future Enhancements (Optional)

1. Custom notification sounds (Adhan audio)
2. Adjustable notification timing (5, 10, 15 minutes before)
3. Different notifications for different prayers
4. Notification actions (Mark as prayed, Snooze)
5. Persistent notification showing next prayer countdown
6. Notification history/log

## Notes

- Notifications are scheduled daily and auto-refresh at midnight
- Changing location re-schedules all notifications
- Settings changes take immediate effect
- The system is lightweight and doesn't drain battery
- Works even when app is closed (scheduled notifications persist)
