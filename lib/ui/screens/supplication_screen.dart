import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/supplication.dart';
import '../../providers/settings_provider.dart';

class SupplicationScreen extends StatefulWidget {
  const SupplicationScreen({super.key});

  @override
  State<SupplicationScreen> createState() => _SupplicationScreenState();
}

class _SupplicationScreenState extends State<SupplicationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Supplication> quranicSupplications = [
    Supplication(
      titleEnglish: 'Morning Supplication',
      titleArabic: 'دعاء الصباح',
      textArabic:
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      translationEnglish:
          'In the name of Allah with whose name nothing on earth or in the sky can cause harm, and He is the All-Hearing, All-Knowing.',
      source: 'At-Tirmidhi',
    ),
    Supplication(
      titleEnglish: 'Evening Supplication',
      titleArabic: 'دعاء المساء',
      textArabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      translationEnglish:
          'O Allah, You are my Lord, there is no god but You. You created me and I am Your slave, and I am upon Your covenant and Your promise as much as I can.',
      source: 'At-Tirmidhi',
    ),
    Supplication(
      titleEnglish: 'Supplication for Forgiveness',
      titleArabic: 'دعاء الاستغفار',
      textArabic:
          'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ، الْحَيُّ الْقَيُّومُ، وَأَتُوبُ إِلَيْهِ',
      translationEnglish:
          'I seek forgiveness from Allah the Mighty, whom there is no god but Him, the Ever-Living, the Self-Subsisting, and I repent to Him.',
      source: 'At-Tirmidhi',
    ),
  ];

  final List<Supplication> sunnahSupplications = [
    Supplication(
      titleEnglish: 'Before Sleeping',
      titleArabic: 'الدعاء قبل النوم',
      textArabic: 'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا',
      translationEnglish: 'O Allah, by Your name do I die and live.',
      source: 'Sahih Al-Bukhari',
    ),
    Supplication(
      titleEnglish: 'Upon Waking',
      titleArabic: 'الحمد الله عند الاستيقاظ',
      textArabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      translationEnglish:
          'All praise is due to Allah who has given us life after He caused us to die, and to Him is our final return.',
      source: 'Sahih Al-Bukhari',
    ),
    Supplication(
      titleEnglish: 'When Entering Home',
      titleArabic: 'الدعاء عند دخول البيت',
      textArabic:
          'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا',
      translationEnglish:
          'In the name of Allah do we enter, and in the name of Allah do we leave, and in our Lord do we place our trust.',
      source: 'At-Tirmidhi',
    ),
    Supplication(
      titleEnglish: 'When Eating',
      titleArabic: 'الدعاء عند الأكل',
      textArabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا، وَجَعَلَنَا مِنَ الْمُسْلِمِينَ',
      translationEnglish:
          'All praise is due to Allah who has fed us and given us drink, and made us among the Muslims.',
      source: 'Sunan Abu Dawud',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Supplications',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 20, 22, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Quranic'),
            Tab(text: 'Sunnah'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSupplicationList(quranicSupplications),
          _buildSupplicationList(sunnahSupplications),
        ],
      ),
    );
  }

  Widget _buildSupplicationList(List<Supplication> supplications) {
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.getPadding(context, 10, 12, 14)),
      itemCount: supplications.length,
      itemBuilder: (context, index) {
        final supplication = supplications[index];
        return _buildSupplicationCard(supplication);
      },
    );
  }

  Widget _buildSupplicationCard(Supplication supplication) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final primaryColor = AppColors.getPrimaryColor(isDarkMode);
        final textPrimary = AppColors.getTextPrimaryColor(isDarkMode);
        final textSecondary = AppColors.getTextSecondaryColor(isDarkMode);
        final surfaceColor = AppColors.getSurfaceColor(isDarkMode);
        return Container(
          margin: EdgeInsets.only(
            bottom: Responsive.getPadding(context, 14, 16, 18),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.getCardColor(isDarkMode),
                AppColors.getCardColor(isDarkMode).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.getBorderColor(isDarkMode).withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(isDarkMode ? 0.18 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(Responsive.getPadding(context, 16, 18, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with English title
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1B6B45),
                        const Color(0xFF2D8A5F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B6B45).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getPadding(context, 14, 16, 18),
                    vertical: Responsive.getPadding(context, 12, 14, 16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: Responsive.getFontSize(context, 18, 20, 22),
                        ),
                      ),
                      SizedBox(
                        width: Responsive.getPadding(context, 12, 14, 16),
                      ),
                      Expanded(
                        child: Text(
                          supplication.titleEnglish,
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(
                              context,
                              16,
                              17,
                              19,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.getPadding(context, 16, 18, 20)),

                // Arabic Text Card - Tappable
                GestureDetector(
                  onTap: () {
                    _showArabicModal(supplication);
                  },
                  child: Container(
                    padding: EdgeInsets.all(
                      Responsive.getPadding(context, 16, 18, 20),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: isDarkMode
                            ? [surfaceColor, AppColors.getCardColor(isDarkMode)]
                            : [
                                const Color(0xFFFFF8E7),
                                const Color(0xFFFFF3D9),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.getBorderColor(
                          isDarkMode,
                        ).withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.15)
                              : const Color(0xFFD4A574).withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(
                                  isDarkMode ? 0.2 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: primaryColor,
                                    size: Responsive.getFontSize(
                                      context,
                                      14,
                                      16,
                                      18,
                                    ),
                                  ),
                                  SizedBox(
                                    width: Responsive.getPadding(
                                      context,
                                      4,
                                      6,
                                      8,
                                    ),
                                  ),
                                  Text(
                                    'Tap to expand',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        11,
                                        12,
                                        13,
                                      ),
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.expand_circle_down_outlined,
                              color: primaryColor,
                              size: Responsive.getFontSize(context, 22, 24, 26),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getPadding(context, 14, 16, 18),
                        ),
                        Text(
                          supplication.textArabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: Responsive.getFontSize(
                              context,
                              18,
                              20,
                              22,
                            ),
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            height: 2.0,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Responsive.getPadding(context, 14, 16, 18)),

                // English Translation
                Container(
                  padding: EdgeInsets.all(
                    Responsive.getPadding(context, 14, 16, 18),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [surfaceColor, AppColors.getCardColor(isDarkMode)]
                          : [const Color(0xFFE8F5E9), const Color(0xFFF1F8F2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.getBorderColor(
                        isDarkMode,
                      ).withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(
                                isDarkMode ? 0.2 : 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.translate,
                              size: Responsive.getFontSize(context, 16, 18, 20),
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(
                            width: Responsive.getPadding(context, 8, 10, 12),
                          ),
                          Text(
                            'Translation',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                13,
                                14,
                                15,
                              ),
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getPadding(context, 10, 12, 14),
                      ),
                      Text(
                        supplication.translationEnglish,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 13, 14, 15),
                          color: textPrimary,
                          height: 1.7,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Source
                if (supplication.source != null) ...[
                  SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getPadding(context, 12, 14, 16),
                      vertical: Responsive.getPadding(context, 8, 10, 12),
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(isDarkMode ? 0.16 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.getBorderColor(
                          isDarkMode,
                        ).withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: Responsive.getFontSize(context, 16, 18, 20),
                          color: primaryColor,
                        ),
                        SizedBox(
                          width: Responsive.getPadding(context, 8, 10, 12),
                        ),
                        Text(
                          'Source: ',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(
                              context,
                              12,
                              13,
                              14,
                            ),
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            supplication.source!,
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                12,
                                13,
                                14,
                              ),
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showArabicModal(Supplication supplication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(
                      Responsive.getPadding(context, 12, 14, 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            supplication.titleEnglish,
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
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            size: Responsive.getFontSize(context, 22, 24, 26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: EdgeInsets.all(
                          Responsive.getPadding(context, 12, 14, 16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Arabic Text - Large and Clear
                            Container(
                              padding: EdgeInsets.all(
                                Responsive.getPadding(context, 14, 16, 18),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                supplication.textArabic,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    18,
                                    20,
                                    24,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 2.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
