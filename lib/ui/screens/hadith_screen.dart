import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/settings_provider.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final cardColor = AppColors.getCardColor(isDarkMode);
        final borderColor = AppColors.getBorderColor(isDarkMode);
        final textPrimary = AppColors.getTextPrimaryColor(isDarkMode);
        final textSecondary = AppColors.getTextSecondaryColor(isDarkMode);
        final primaryColor = AppColors.getPrimaryColor(isDarkMode);

        final collections = _hadithCollections;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Hadith Collections',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: EdgeInsets.all(Responsive.getPadding(context, 12, 16, 20)),
            children: [
              _buildHeader(
                context,
                cardColor: cardColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              SizedBox(height: Responsive.getPadding(context, 16, 20, 24)),
              ...collections.map(
                (collection) => Padding(
                  padding: EdgeInsets.only(
                    bottom: Responsive.getPadding(context, 12, 14, 16),
                  ),
                  child: _buildHadithCard(
                    context,
                    collection,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryColor: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.getPadding(context, 12, 16, 20)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Authentic Hadith Books',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 18, 20, 24),
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
          Text(
            'The most authentic and recognized collections of Hadith in Islamic tradition.',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 12, 13, 14),
              color: textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(
    BuildContext context,
    _HadithCollection collection, {
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
  }) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  Responsive.getPadding(context, isMobile ? 8 : 10, 10, 12),
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  collection.icon,
                  color: primaryColor,
                  size: Responsive.getFontSize(context, 20, 24, 28),
                ),
              ),
              SizedBox(width: Responsive.getPadding(context, 10, 12, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.englishName,
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 15, 16, 18),
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.getPadding(context, 2, 3, 4)),
                    Text(
                      collection.arabicName,
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 14, 15, 16),
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          Divider(color: borderColor.withOpacity(0.5)),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          Text(
            'Author',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 11, 12, 13),
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                collection.englishAuthor,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 13, 14, 15),
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                collection.arabicAuthor,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 13, 14, 15),
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          Text(
            collection.description,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 12, 13, 14),
              color: textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor.withOpacity(0.12),
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.getPadding(context, 8, 10, 12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${collection.englishName} details coming soon',
                    ),
                    backgroundColor: primaryColor,
                  ),
                );
              },
              child: Text(
                'Learn More',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 12, 13, 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithCollection {
  const _HadithCollection({
    required this.englishName,
    required this.arabicName,
    required this.englishAuthor,
    required this.arabicAuthor,
    required this.description,
    required this.icon,
  });

  final String englishName;
  final String arabicName;
  final String englishAuthor;
  final String arabicAuthor;
  final String description;
  final IconData icon;
}

const List<_HadithCollection> _hadithCollections = [
  _HadithCollection(
    englishName: 'Sahih Al-Bukhari',
    arabicName: 'الجامع الصحيح',
    englishAuthor: 'Muhammad al-Bukhari',
    arabicAuthor: 'الإمام محمد البخاري',
    description: 'Most authentic collection with 7,563 hadith',
    icon: Icons.star,
  ),
  _HadithCollection(
    englishName: 'Sahih Muslim',
    arabicName: 'صحيح مسلم',
    englishAuthor: 'Muslim ibn al-Hajjaj',
    arabicAuthor: 'مسلم بن الحجاج',
    description: 'Second most authentic with 5,033 hadith',
    icon: Icons.star,
  ),
  _HadithCollection(
    englishName: 'Sunan Abu Dawud',
    arabicName: 'سنن أبي داود',
    englishAuthor: 'Abu Dawud al-Sijistani',
    arabicAuthor: 'أبو داود السجستاني',
    description: 'Collection of 5,274 hadith with focus on jurisprudence',
    icon: Icons.menu_book,
  ),
  _HadithCollection(
    englishName: 'Sunan At-Tirmidhi',
    arabicName: 'سنن الترمذي',
    englishAuthor: 'Al-Tirmidhi',
    arabicAuthor: 'الترمذي',
    description: 'Contains 3,956 hadith with authentication grades',
    icon: Icons.menu_book,
  ),
  _HadithCollection(
    englishName: 'Sunan An-Nasai',
    arabicName: 'سنن النسائي',
    englishAuthor: 'Al-Nasai',
    arabicAuthor: 'النسائي',
    description: 'Collection of 5,761 hadith with strong verification',
    icon: Icons.menu_book,
  ),
  _HadithCollection(
    englishName: 'Sunan Ibn Majah',
    arabicName: 'سنن ابن ماجه',
    englishAuthor: 'Ibn Majah',
    arabicAuthor: 'ابن ماجه',
    description: 'Sixth prominent collection with 4,341 hadith',
    icon: Icons.menu_book,
  ),
  _HadithCollection(
    englishName: 'Muwatta Malik',
    arabicName: 'موطأ مالك',
    englishAuthor: 'Malik ibn Anas',
    arabicAuthor: 'مالك بن أنس',
    description: 'Early collection known for legal application of hadith',
    icon: Icons.gavel,
  ),
  _HadithCollection(
    englishName: 'Musnad Ahmad',
    arabicName: 'مسند أحمد',
    englishAuthor: 'Ahmad ibn Hanbal',
    arabicAuthor: 'أحمد بن حنبل',
    description: 'Large collection with 27,000+ hadith by companion',
    icon: Icons.collections,
  ),
];
