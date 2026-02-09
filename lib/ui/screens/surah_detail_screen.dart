import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/surah.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.surah.englishName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.surah.name,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.getPadding(context, 12, 16, 20)),
        children: [
          // header
          _buildSurahHeader(context),
          SizedBox(height: Responsive.getPadding(context, 16, 18, 24)),

          // ayahs title
          Text(
            'Verses (Ayahs)',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 16, 18, 20),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // ayahs list (dynamic)
          _buildAyahsList(context),
        ],
      ),
    );
  }

  Widget _buildSurahHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final cardBackgroundColor = AppColors.getCardColor(isDarkMode);
        return Container(
          padding: EdgeInsets.all(Responsive.getPadding(context, 16, 18, 22)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardBackgroundColor,
                AppColors.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // name + arabic
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameSection(),
                        SizedBox(
                          height: Responsive.getPadding(context, 12, 14, 16),
                        ),
                        _buildArabicName(),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildNameSection()),
                        SizedBox(
                          width: Responsive.getPadding(context, 16, 20, 24),
                        ),
                        _buildArabicName(),
                      ],
                    ),
              SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),
              Divider(color: AppColors.primary.withOpacity(0.2)),
              SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),
              // verses + revelation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('Verses', '${widget.surah.verses}'),
                  SizedBox(width: Responsive.getPadding(context, 8, 12, 16)),
                  _buildInfoColumn('Revelation', widget.surah.revelationType),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Surah ${widget.surah.number}',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 11, 12, 13),
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
        Text(
          widget.surah.englishName,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 18, 20, 24),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
        Text(
          widget.surah.englishNameTranslation,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 12, 13, 14),
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildArabicName() {
    return Text(
      widget.surah.name,
      style: TextStyle(
        fontSize: Responsive.getFontSize(context, 22, 26, 32),
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        height: 1.2,
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 11, 12, 13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 13, 14, 16),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAyahsList(BuildContext context) {
    return FutureBuilder<List>(
      future: context.read<QuranProvider>().getAyahsBySurah(
        widget.surah.number,
        // Fetch from cache or API if not cached (lazy loading)
        forceRefresh: false,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Fetching verses...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final ayahs = snapshot.data ?? [];

        if (ayahs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inbox,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text('No Verses available'),
              ],
            ),
          );
        }

        return Column(
          children: List.generate(
            ayahs.length,
            (index) => _buildAyahCard(context, ayahs[index]),
          ),
        );
      },
    );
  }

  Widget _buildAyahCard(BuildContext context, dynamic ayah) {
    final isDarkMode = context.watch<SettingsProvider>().darkMode;
    return Container(
      margin: EdgeInsets.only(
        bottom: Responsive.getPadding(context, 12, 14, 16),
      ),
      padding: EdgeInsets.all(Responsive.getPadding(context, 14, 16, 18)),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.getBorderColor(isDarkMode).withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  'Verse ${ayah.numberInSurah}',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 11, 12, 13),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.copy_rounded,
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    size: 18,
                  ),
                  SizedBox(width: Responsive.getPadding(context, 8, 10, 12)),
                  Icon(
                    Icons.bookmark_border,
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Responsive.getPadding(context, 6, 8, 10)),

          // Arabic Text
          Container(
            padding: EdgeInsets.fromLTRB(
              Responsive.getPadding(context, 14, 16, 18),
              Responsive.getPadding(context, 12, 14, 16),
              Responsive.getPadding(context, 14, 16, 18),
              Responsive.getPadding(context, 4, 6, 8),
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.getSurfaceColor(isDarkMode)
                  : const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDarkMode
                    ? AppColors.getBorderColor(isDarkMode).withOpacity(0.6)
                    : const Color(0xFFD4A574).withOpacity(0.45),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.12)
                      : const Color(0xFFD4A574).withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              ayah.textArabic,
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 18, 20, 24),
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimaryColor(isDarkMode),
                height: 1.6,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 0),

          // English Translation
          Container(
            padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.getSurfaceColor(isDarkMode)
                  : const Color(0xFFF1F8F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.getBorderColor(isDarkMode).withOpacity(0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate,
                      size: Responsive.getFontSize(context, 14, 16, 18),
                      color: AppColors.getPrimaryColor(isDarkMode),
                    ),
                    SizedBox(width: Responsive.getPadding(context, 6, 8, 10)),
                    Text(
                      'Translation',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 12, 13, 14),
                        fontWeight: FontWeight.bold,
                        color: AppColors.getPrimaryColor(isDarkMode),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),
                Text(
                  ayah.text,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 12, 13, 15),
                    color: AppColors.getTextPrimaryColor(isDarkMode),
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
