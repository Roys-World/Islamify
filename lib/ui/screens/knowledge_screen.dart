import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Hadith Collections',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.getPadding(context, 12, 16, 20)),
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(Responsive.getPadding(context, 12, 16, 20)),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Authentic Hadith Books',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 18, 20, 24),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
                Text(
                  'The most authentic and recognized collections of Hadith in Islamic tradition.',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 12, 13, 14),
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.getPadding(context, 16, 20, 24)),

          // Sahih Al-Bukhari
          _buildHadithCard(
            context,
            'Sahih Al-Bukhari',
            'الجامع الصحيح',
            'Muhammad al-Bukhari',
            'الإمام محمد البخاري',
            'Most authentic collection with 7,563 hadith',
            Icons.star,
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // Sahih Muslim
          _buildHadithCard(
            context,
            'Sahih Muslim',
            'صحيح مسلم',
            'Muslim ibn al-Hajjaj',
            'مسلم بن الحجاج',
            'Second most authentic with 5,033 hadith',
            Icons.star,
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // Sunan Abu Dawud
          _buildHadithCard(
            context,
            'Sunan Abu Dawud',
            'سنن أبي داود',
            'Abu Dawud al-Sijistani',
            'أبو داود السجستاني',
            'Collection of 5,274 hadith with focus on Islamic jurisprudence',
            Icons.menu_book,
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // Sunan At-Tirmidhi
          _buildHadithCard(
            context,
            'Sunan At-Tirmidhi',
            'سنن الترمذي',
            'Al-Tirmidhi',
            'الترمذي',
            'Contains 3,956 hadith with authentication grades',
            Icons.menu_book,
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // Sunan An-Nasai
          _buildHadithCard(
            context,
            'Sunan An-Nasai',
            'سنن النسائي',
            'Al-Nasai',
            'النسائي',
            'Collection of 5,761 hadith with strong chain verification',
            Icons.menu_book,
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // Sunan Ibn Majah
          _buildHadithCard(
            context,
            'Sunan Ibn Majah',
            'سنن ابن ماجه',
            'Ibn Majah',
            'ابن ماجه',
            'Sixth prominent collection with 4,341 hadith',
            Icons.menu_book,
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // Muwatta Malik
          _buildHadithCard(
            context,
            'Muwatta Malik',
            'موطأ مالك',
            'Malik ibn Anas',
            'مالك بن أنس',
            'Early collection known for legal application of hadith',
            Icons.gavel,
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // Musnad Ahmad
          _buildHadithCard(
            context,
            'Musnad Ahmad',
            'مسند أحمد',
            'Ahmad ibn Hanbal',
            'أحمد بن حنبل',
            'Large collection with 27,000+ hadith arranged by companion',
            Icons.collections,
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),
        ],
      ),
    );
  }

  Widget _buildHadithCard(
    BuildContext context,
    String englishName,
    String arabicName,
    String englishAuthor,
    String arabicAuthor,
    String description,
    IconData icon,
  ) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        SizedBox(
                          width: Responsive.getPadding(context, 10, 12, 14),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                englishName,
                                style: TextStyle(
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    15,
                                    16,
                                    18,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(
                                height: Responsive.getPadding(context, 2, 3, 4),
                              ),
                              Text(
                                arabicName,
                                style: TextStyle(
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    14,
                                    15,
                                    16,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        Responsive.getPadding(context, 10, 12, 14),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primary,
                        size: Responsive.getFontSize(context, 24, 28, 32),
                      ),
                    ),
                    SizedBox(width: Responsive.getPadding(context, 12, 16, 20)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            englishName,
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                16,
                                18,
                                20,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(
                            height: Responsive.getPadding(context, 2, 3, 4),
                          ),
                          Text(
                            arabicName,
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                15,
                                16,
                                17,
                              ),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
          Divider(color: AppColors.border.withOpacity(0.5)),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),

          // Author Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Author',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 11, 12, 13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    englishAuthor,
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 13, 14, 15),
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    arabicAuthor,
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 13, 14, 15),
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 12, 13, 14),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),

          // Learn More Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
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
                    content: Text('$englishName details coming soon'),
                    backgroundColor: AppColors.primary,
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
