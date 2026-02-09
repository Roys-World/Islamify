import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/settings_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.background;
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.card;
    final borderColor = isDarkMode ? AppColors.darkBorder : AppColors.border;
    final textColor = isDarkMode
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.getPadding(context, 12, 16, 20)),
        children: [
          // general
          _buildSectionHeader('General', textColor),
          SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
          _buildSettingCard(
            context,
            'Notifications',
            'Enable app notifications',
            Icons.notifications_active,
            settings.notificationsEnabled,
            (value) async {
              settings.setNotificationsEnabled(value);
              if (!value) {
                // Cancel all notifications when disabled
                await NotificationService().cancelPrayerNotifications();
              } else {
                // Reschedule notifications when enabled
                final prayerProvider = context.read<PrayerProvider>();
                await prayerProvider.rescheduleNotifications();
              }
            },
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          _buildSettingCard(
            context,
            'Prayer Reminders',
            'Get reminded for prayer times',
            Icons.alarm,
            settings.prayerReminders,
            (value) async {
              settings.setPrayerReminders(value);
              if (!value) {
                // Cancel all notifications when disabled
                await NotificationService().cancelPrayerNotifications();
              } else {
                // Reschedule notifications when enabled
                final prayerProvider = context.read<PrayerProvider>();
                await prayerProvider.rescheduleNotifications();
              }
            },
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          _buildSettingCard(
            context,
            'Islamic Calendar',
            'Use Islamic Hijri calendar',
            Icons.calendar_today,
            settings.islamicCalendar,
            (value) {
              settings.setIslamicCalendar(value);
            },
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 16, 20, 24)),

          // display
          _buildSectionHeader('Display', textColor),
          SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
          _buildDropdownSetting(
            context,
            'Language',
            settings.selectedLanguage,
            ['English', 'Arabic', 'Urdu', 'Spanish'],
            (value) {
              settings.setSelectedLanguage(value);
            },
            Icons.language,
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          _buildSettingCard(
            context,
            'Dark Mode',
            'Enable dark theme',
            Icons.dark_mode,
            settings.darkMode,
            (value) {
              settings.setDarkMode(value);
            },
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 16, 20, 24)),

          // Islamic Settings Section
          _buildSectionHeader('Islamic Settings', textColor),
          SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
          _buildDropdownSetting(
            context,
            'Islamic School (Madhab)',
            settings.selectedSchool,
            ['Hanafi', 'Maliki', 'Shafi\'i', 'Hanbali'],
            (value) {
              settings.setSelectedSchool(value);
            },
            Icons.book,
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 16, 20, 24)),

          // About & Support Section
          _buildSectionHeader('About & Support', textColor),
          SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
          _buildSettingTile(
            context,
            'About Islamify',
            'Version 1.0.0',
            Icons.info,
            () {
              _showAboutDialog();
            },
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          _buildSettingTile(
            context,
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy coming soon')),
              );
            },
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          _buildSettingTile(
            context,
            'Rate App',
            'Leave us a review',
            Icons.star,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening app store...')),
              );
            },
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          _buildSettingTile(
            context,
            'Contact Us',
            'Send feedback or report issues',
            Icons.email,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening email client...')),
              );
            },
            cardColor,
            borderColor,
            textColor,
          ),
          SizedBox(height: Responsive.getPadding(context, 20, 24, 32)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Responsive.getFontSize(context, 16, 18, 20),
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    Color cardColor,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.getPadding(context, 8, 10, 12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: Responsive.getFontSize(context, 20, 24, 28),
            ),
          ),
          SizedBox(width: Responsive.getPadding(context, 12, 14, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 14, 15, 16),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: Responsive.getPadding(context, 2, 4, 6)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 11, 12, 13),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    BuildContext context,
    String title,
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
    IconData icon,
    Color cardColor,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.getPadding(context, 8, 10, 12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: Responsive.getFontSize(context, 20, 24, 28),
            ),
          ),
          SizedBox(width: Responsive.getPadding(context, 12, 14, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 14, 15, 16),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: Responsive.getPadding(context, 6, 8, 10)),
                DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  underline: SizedBox(),
                  items: options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 12, 13, 14),
                          color: textColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      onChanged(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color cardColor,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                Responsive.getPadding(context, 8, 10, 12),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: Responsive.getFontSize(context, 20, 24, 28),
              ),
            ),
            SizedBox(width: Responsive.getPadding(context, 12, 14, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 14, 15, 16),
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 11, 12, 13),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: Responsive.getFontSize(context, 16, 18, 20),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Islamify'),
        content: Text(
          'Islamify - Islamic App\n\nVersion 1.0.0\n\n'
          'A comprehensive Islamic application providing prayer times, Quran, Hadith collections, and more.\n\n'
          '© 2026 Islamify. All rights reserved.',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 12, 13, 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
