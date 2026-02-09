# Dark Mode Quick Reference - How to Update Any Screen

## Step-by-Step Guide

### 1. Add Imports (if not already present)

```dart
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
```

### 2. Get isDarkMode in build() method

```dart
@override
Widget build(BuildContext context) {
  final isDarkMode = context.watch<SettingsProvider>().darkMode;
  // ... rest of widget tree
}
```

### 3. Use AppColors adaptive methods

Replace all hardcoded colors with adaptive methods:

```dart
// BEFORE (hardcoded):
Scaffold(
  backgroundColor: AppColors.background,  // Always light
  body: Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)

// AFTER (adaptive):
Scaffold(
  backgroundColor: AppColors.getBackgroundColor(isDarkMode),
  body: Text(
    'Hello',
    style: TextStyle(
      color: AppColors.getTextPrimaryColor(isDarkMode),
    ),
  ),
)
```

## Available Adaptive Methods

| Method                    | Light Color   | Dark Color     | Usage                     |
| ------------------------- | ------------- | -------------- | ------------------------- |
| `getPrimaryColor()`       | Islamic Green | Bright Green   | Primary elements, buttons |
| `getPrimary1Color()`      | Deep Green    | Medium Green   | Accent elements           |
| `getSecondaryColor()`     | Dark Green    | Teal           | Secondary elements        |
| `getTertiaryColor()`      | Light Green   | Light Teal     | Tertiary elements         |
| `getBackgroundColor()`    | Cream         | Deep Dark Blue | Screen background         |
| `getSurfaceColor()`       | White         | Dark Surface   | Surfaces                  |
| `getCardColor()`          | White         | Dark Card      | Cards, containers         |
| `getTextPrimaryColor()`   | Dark Gray     | Light Gray     | Main text                 |
| `getTextSecondaryColor()` | Medium Gray   | Light Gray     | Secondary text            |
| `getBorderColor()`        | Light Gray    | Dark Gray      | Borders                   |

## Common Patterns

### Simple Text

```dart
Text(
  'Title',
  style: TextStyle(
    color: AppColors.getTextPrimaryColor(isDarkMode),
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
)
```

### Container with Border

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.getCardColor(isDarkMode),
    border: Border.all(
      color: AppColors.getBorderColor(isDarkMode),
      width: 1,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text('Content'),
)
```

### List Item

```dart
Container(
  color: AppColors.getCardColor(isDarkMode),
  child: ListTile(
    title: Text(
      'Item Title',
      style: TextStyle(
        color: AppColors.getTextPrimaryColor(isDarkMode),
      ),
    ),
    subtitle: Text(
      'Subtitle',
      style: TextStyle(
        color: AppColors.getTextSecondaryColor(isDarkMode),
      ),
    ),
  ),
)
```

### Dialog/Popup

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: AppColors.getCardColor(isDarkMode),
    title: Text(
      'Title',
      style: TextStyle(
        color: AppColors.getTextPrimaryColor(isDarkMode),
      ),
    ),
    content: Text(
      'Content',
      style: TextStyle(
        color: AppColors.getTextSecondaryColor(isDarkMode),
      ),
    ),
  ),
)
```

## Things to Remember

1. ✅ Call `context.watch<SettingsProvider>()` once in build method
2. ✅ Pass the `isDarkMode` boolean to all AppColors methods
3. ✅ No need to pass `isDarkMode` through helper methods - they can call `context.watch()` locally
4. ✅ Test colors in both light and dark modes
5. ✅ Keep text contrast ratios sufficient in both modes

## Testing

After updating a screen:

1. Open the Settings screen
2. Toggle Dark Mode ON
3. Navigate to the updated screen
4. Verify all colors change appropriately
5. Check text readability
6. Toggle Dark Mode OFF
7. Verify colors return to light theme

## Files Reference

| File                                   | Purpose                                             |
| -------------------------------------- | --------------------------------------------------- |
| `lib/core/constants/app_colors.dart`   | All color definitions and adaptive methods          |
| `lib/providers/settings_provider.dart` | Dark mode state management                          |
| `lib/ui/screens/settings_screen.dart`  | Dark mode toggle control (reference implementation) |
| `lib/ui/screens/tasbeeh_screen.dart`   | Complete example of dark mode implementation        |

## Example: Complete Screen Update

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch for dark mode changes
    final isDarkMode = context.watch<SettingsProvider>().darkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: AppColors.getBackgroundColor(isDarkMode),
        title: Text(
          'Example Screen',
          style: TextStyle(
            color: AppColors.getTextPrimaryColor(isDarkMode),
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: AppColors.getCardColor(isDarkMode),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Primary Text',
                  style: TextStyle(
                    color: AppColors.getTextPrimaryColor(isDarkMode),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Secondary Text',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

That's it! This pattern is used across the entire app for consistent dark mode support.
