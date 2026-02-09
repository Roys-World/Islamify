import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/arabic_numerals.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import 'surah_detail_screen.dart';
import 'parah_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
        title: Text(
          'Quran',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 20, 22, 24),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Surahs'),
            Tab(text: 'Parahs'),
          ],
        ),
      ),
      body: Consumer<QuranProvider>(
        builder: (context, quranProvider, child) {
          // wait init
          if (!quranProvider.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Quran data...'),
                ],
              ),
            );
          }

          if (quranProvider.isLoading && quranProvider.surahs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quranProvider.error != null && quranProvider.surahs.isEmpty) {
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
                  Text(
                    quranProvider.error ?? 'An error occurred',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => quranProvider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Surahs Tab
              _buildSurahsTab(context, quranProvider),

              // Parahs Tab
              _buildParahsTab(context, quranProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSurahsTab(BuildContext context, QuranProvider provider) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => provider.searchSurahs(value),
              decoration: InputDecoration(
                hintText: 'Search Surahs...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          provider.searchSurahs('');
                        },
                        child: const Icon(
                          Icons.clear,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Responsive.getPadding(context, 12, 14, 16),
                  vertical: Responsive.getPadding(context, 10, 12, 14),
                ),
              ),
            ),
          ),
        ),
        // Surahs List
        Expanded(
          child: provider.filteredSurahs.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'No Surahs found'
                        : 'No results for "${_searchController.text}"',
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(
                    Responsive.getPadding(context, 12, 14, 16),
                  ),
                  itemCount: provider.filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = provider.filteredSurahs[index];
                    return _buildSurahCard(context, surah);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildParahsTab(BuildContext context, QuranProvider provider) {
    return provider.parahs.isEmpty
        ? const Center(child: Text('No Parahs available'))
        : ListView.builder(
            padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
            itemCount: provider.parahs.length,
            itemBuilder: (context, index) {
              final parah = provider.parahs[index];
              return _buildParahCard(context, parah);
            },
          );
  }

  Widget _buildSurahCard(BuildContext context, dynamic surah) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final cardBackgroundColor = AppColors.getCardColor(isDarkMode);
        final textPrimary = AppColors.getTextPrimaryColor(isDarkMode);
        final textSecondary = AppColors.getTextSecondaryColor(isDarkMode);
        final primaryColor = AppColors.getPrimaryColor(isDarkMode);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(surah: surah),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(
              bottom: Responsive.getPadding(context, 12, 14, 16),
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardBackgroundColor, primaryColor.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primaryColor.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Surah Number Circle with Arabic numerals
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.12),
                    border: Border.all(color: primaryColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      toArabicNumerals(surah.number),
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 16, 18, 20),
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.getPadding(context, 12, 14, 16)),

                // Surah Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.englishName,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 14, 16, 18),
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
                      Row(
                        children: [
                          Text(
                            surah.englishNameTranslation,
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                12,
                                13,
                                14,
                              ),
                              color: textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${surah.verses} verses',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                12,
                                13,
                                14,
                              ),
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.getPadding(context, 8, 10, 12)),

                // Arabic Name + Revelation Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      surah.name,
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 14, 16, 18),
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        surah.revelationType,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 11, 12, 13),
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildParahCard(BuildContext context, dynamic parah) {
    return Consumer<QuranProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            // Navigate to Parah detail screen showing all Surahs in range
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ParahDetailScreen(parah: parah),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(
              bottom: Responsive.getPadding(context, 12, 14, 16),
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppColors.secondary.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.secondary.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Parah Number Circle with Arabic numerals
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.12),
                    border: Border.all(color: AppColors.secondary, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      toArabicNumerals(parah.number),
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 16, 18, 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.getPadding(context, 12, 14, 16)),

                // Parah Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parah.name,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 14, 16, 18),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: Responsive.getPadding(context, 4, 6, 8)),
                      Text(
                        'Surah ${parah.startSurah}:${parah.startVerse} to ${parah.endSurah}:${parah.endVerse}',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 12, 13, 14),
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }
}
