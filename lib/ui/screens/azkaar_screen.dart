import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/azkaar.dart';
import '../../providers/settings_provider.dart';

class AzkaarScreen extends StatefulWidget {
  const AzkaarScreen({super.key});

  @override
  State<AzkaarScreen> createState() => _AzkaarScreenState();
}

class _AzkaarScreenState extends State<AzkaarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Morning Azkaars
  final List<Azkaar> morningAzkaars = [
    Azkaar(
      textArabic:
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذَا الْيَوْمِ',
      translationEnglish:
          'We have reached the morning and at this very time all sovereignty belongs to Allah, the Lord of all the worlds. O Allah, I ask You for the good of this day.',
      count: 1,
      benefits: 'Protection from evil',
    ),
    Azkaar(
      textArabic:
          'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
      translationEnglish:
          'Glory be to Allah and praise be to Him, by the number of His creation, by His pleasure, by the weight of His Throne and the extent of His words.',
      count: 3,
      benefits: 'Purification of soul',
    ),
    Azkaar(
      textArabic:
          'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
      translationEnglish:
          'O Allah, grant me health in my body. O Allah, grant me health in my hearing. O Allah, grant me health in my sight.',
      count: 3,
      benefits: 'Health and wellness',
    ),
  ];

  // Evening Azkaars
  final List<Azkaar> eveningAzkaars = [
    Azkaar(
      textArabic:
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذِهِ اللَّيْلَةِ',
      translationEnglish:
          'We have reached the evening and at this very time all sovereignty belongs to Allah, the Lord of all the worlds. O Allah, I ask You for the good of this night.',
      count: 1,
      benefits: 'Safe and peaceful night',
    ),
    Azkaar(
      textArabic:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      translationEnglish:
          'O Allah, by You we have entered the evening, and by You we enter the morning, by You we live, by You we die, and to You is our return.',
      count: 1,
      benefits: 'Complete reliance on Allah',
    ),
    Azkaar(
      textArabic:
          'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
      translationEnglish:
          'I am pleased with Allah as my Lord, Islam as my religion, and Muhammad (PBUH) as my Prophet.',
      count: 3,
      benefits: 'Contentment and gratitude',
    ),
  ];

  // General Azkaars
  final List<Azkaar> generalAzkaars = [
    Azkaar(
      textArabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      translationEnglish:
          'All praise is due to Allah, the Lord of all the worlds.',
      count: null,
      benefits: 'Gratitude and appreciation',
    ),
    Azkaar(
      textArabic: 'سُبْحَانَ اللَّهِ',
      translationEnglish: 'Glory be to Allah.',
      count: null,
      benefits: 'Glorification of Allah',
    ),
    Azkaar(
      textArabic:
          'الْحَمْدُ لِلَّهِ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
      translationEnglish:
          'All praise is due to Allah, with many good and blessed praises.',
      count: null,
      benefits: 'Comprehensive gratitude',
    ),
    Azkaar(
      textArabic:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      translationEnglish:
          'There is no deity worthy of worship except Allah alone, without any partner. To Him belongs the dominion, and to Him belongs all praise, and He is over all things competent.',
      count: null,
      benefits: 'Tawheed and submission',
    ),
  ];

  // Istighfar Azkaars
  final List<Azkaar> istighfarAzkaars = [
    Azkaar(
      textArabic:
          'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      translationEnglish:
          'I seek forgiveness from Allah the Mighty, than whom there is no other god, the Living, the Sustainer of all existence, and I repent to Him.',
      count: null,
      benefits: 'Forgiveness and repentance',
    ),
    Azkaar(
      textArabic: 'سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      translationEnglish:
          'Glory be to You! Indeed, I have been among the wrongdoers.',
      count: null,
      benefits: 'Humility and forgiveness',
    ),
    Azkaar(
      textArabic:
          'رَبِّ اغْفِرْ لِي إِنِّي ظَلَمْتُ نَفْسِي فَلَا تَغْفِرْ إِلَّا أَنْتَ',
      translationEnglish:
          'My Lord, forgive me for I have indeed wronged myself, and none forgives sins except You.',
      count: null,
      benefits: 'Seeking divine forgiveness',
    ),
  ];

  // Dua for family and loved ones
  final List<Azkaar> familyAzkaars = [
    Azkaar(
      textArabic:
          'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      translationEnglish:
          'O my Lord, forgive me and my parents and all believers on the Day of Judgment.',
      count: null,
      benefits: 'Family blessing',
    ),
    Azkaar(
      textArabic:
          'اللَّهُمَّ ارْزُقْنِي وَارْزُقْ أَهْلِي وَوَلَدِي رِزْقًا حَلَالًا طَيِّبًا',
      translationEnglish:
          'O Allah, provide me and my family with lawful and pure sustenance.',
      count: null,
      benefits: 'Sustenance for family',
    ),
    Azkaar(
      textArabic:
          'اللَّهُمَّ احْفَظْ أَهْلِي وَوَلَدِي وَاجْعَلْهُمْ مِنَ الصَّالِحِينَ',
      translationEnglish:
          'O Allah, protect my family and children and make them among the righteous.',
      count: null,
      benefits: 'Family protection',
    ),
  ];

  // Sleep Azkaars
  final List<Azkaar> sleepAzkaars = [
    Azkaar(
      textArabic: 'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا',
      translationEnglish: 'O Allah, by Your name I die and I live.',
      count: 1,
      benefits: 'Peaceful sleep',
    ),
    Azkaar(
      textArabic:
          'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ شَرِّ مَا خَلَقَ',
      translationEnglish:
          'I seek refuge in the complete words of Allah from the evil of what He has created.',
      count: 3,
      benefits: 'Protection at night',
    ),
    Azkaar(
      textArabic:
          'بِسْمِ اللَّهِ وَضَعْتُ جَنْبِي، اللَّهُمَّ اغْفِرْ لِي ذَنْبِي، وَأَطْلِقْ رِقِّي، وَاجْعَلْ لِي مَثْوًى وَسِيعًا',
      translationEnglish:
          'In the name of Allah I lay myself down. O Allah, forgive my sins and loosen my bonds and make for me a wide place (in the grave).',
      count: 1,
      benefits: 'Restful sleep and forgiveness',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
          'Azkaar',
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            Responsive.isMobile(context) ? 48 : 56,
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: Responsive.getFontSize(context, 12, 13, 14),
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Morning'),
              Tab(text: 'Evening'),
              Tab(text: 'General'),
              Tab(text: 'Istighfar'),
              Tab(text: 'Family'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAzkaarList(morningAzkaars),
          _buildAzkaarList(eveningAzkaars),
          _buildAzkaarList(generalAzkaars),
          _buildAzkaarList(istighfarAzkaars),
          _buildAzkaarList(familyAzkaars),
        ],
      ),
    );
  }

  Widget _buildAzkaarList(List<Azkaar> azkaars) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getPadding(context, 10, 12, 14),
        vertical: Responsive.getPadding(context, 8, 10, 12),
      ),
      itemCount: azkaars.length,
      itemBuilder: (context, index) {
        return _buildAzkaarCard(azkaars[index]);
      },
    );
  }

  Widget _buildAzkaarCard(Azkaar azkaar) {
    final color = _getCardColor(0);

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final cardBackgroundColor = AppColors.getCardColor(isDarkMode);
        final textPrimary = AppColors.getTextPrimaryColor(isDarkMode);
        final primaryColor = AppColors.getPrimaryColor(isDarkMode);
        final surfaceColor = AppColors.getSurfaceColor(isDarkMode);
        final borderColor = AppColors.getBorderColor(isDarkMode);
        return Container(
          margin: EdgeInsets.only(
            bottom: Responsive.getPadding(context, 12, 14, 16),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardBackgroundColor, color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.25), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(
                horizontal: Responsive.getPadding(context, 14, 16, 18),
                vertical: Responsive.getPadding(context, 12, 14, 16),
              ),
              childrenPadding: EdgeInsets.fromLTRB(
                Responsive.getPadding(context, 14, 16, 18),
                0,
                Responsive.getPadding(context, 14, 16, 18),
                Responsive.getPadding(context, 12, 14, 16),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Arabic Text with golden background
                  Container(
                    padding: EdgeInsets.all(
                      Responsive.getPadding(context, 12, 14, 16),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [surfaceColor, cardBackgroundColor]
                            : [
                                const Color(0xFFFFF8E7),
                                const Color(0xFFFFF3D9),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      azkaar.textArabic,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: Responsive.getFontSize(context, 17, 18, 20),
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        height: 1.9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: color,
                  size: 24,
                ),
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: color.withOpacity(0.3),
                      height: Responsive.getPadding(context, 12, 14, 16),
                      thickness: 1.5,
                    ),
                    SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
                    // English Translation
                    Container(
                      padding: EdgeInsets.all(
                        Responsive.getPadding(context, 12, 14, 16),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [surfaceColor, cardBackgroundColor]
                              : [
                                  const Color(0xFFE8F5E9),
                                  const Color(0xFFF1F8F2),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.translate,
                                size: Responsive.getFontSize(
                                  context,
                                  16,
                                  18,
                                  20,
                                ),
                                color: primaryColor,
                              ),
                              SizedBox(
                                width: Responsive.getPadding(context, 6, 8, 10),
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
                            height: Responsive.getPadding(context, 8, 10, 12),
                          ),
                          Text(
                            azkaar.translationEnglish,
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                13,
                                14,
                                15,
                              ),
                              color: textPrimary,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Count and Benefits
                    if (azkaar.count != null || azkaar.benefits != null)
                      SizedBox(
                        height: Responsive.getPadding(context, 10, 12, 14),
                      ),
                    if (azkaar.count != null)
                      Container(
                        padding: EdgeInsets.all(
                          Responsive.getPadding(context, 10, 12, 14),
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: _buildInfoRow(
                          Icons.repeat_rounded,
                          'Recite ${azkaar.count} times',
                          color,
                        ),
                      ),
                    if (azkaar.benefits != null)
                      SizedBox(
                        height: Responsive.getPadding(context, 8, 10, 12),
                      ),
                    if (azkaar.benefits != null)
                      Container(
                        padding: EdgeInsets.all(
                          Responsive.getPadding(context, 10, 12, 14),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [surfaceColor, cardBackgroundColor]
                                : [
                                    const Color(0xFFFFF8E7),
                                    const Color(0xFFFFF3D9),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: borderColor.withOpacity(0.6),
                            width: 1.5,
                          ),
                        ),
                        child: _buildInfoRow(
                          Icons.auto_awesome_rounded,
                          azkaar.benefits!,
                          const Color(0xFFB8860B),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: Responsive.getFontSize(context, 16, 18, 20),
            color: color,
          ),
        ),
        SizedBox(width: Responsive.getPadding(context, 10, 12, 14)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 12, 13, 14),
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _getCardColor(int index) {
    final colors = [
      const Color(0xFF2D5A3D), // Dark green
      const Color(0xFF1B7A4D), // Forest green
      const Color(0xFF2D9B6E), // Medium green
      const Color(0xFF7B5BA1), // Purple
      const Color(0xFFD4A574), // Gold
    ];
    return colors[index % colors.length];
  }
}
