import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/parah.dart';
import '../../models/ayah.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';

class ParahDetailScreen extends StatefulWidget {
  final Parah parah;

  const ParahDetailScreen({super.key, required this.parah});

  @override
  State<ParahDetailScreen> createState() => _ParahDetailScreenState();
}

class _ParahDetailScreenState extends State<ParahDetailScreen> {
  late Future<List<Ayah>> _ayahsFuture;

  @override
  void initState() {
    super.initState();
    _ayahsFuture = _fetchAyahsInRange();
  }

  // fetch ayahs (range)
  Future<List<Ayah>> _fetchAyahsInRange() async {
    final provider = context.read<QuranProvider>();
    final List<Ayah> allAyahs = [];

    try {
      print('🔄 Fetching Ayahs for ${widget.parah.name}');
      print(
        '   Range: Surah ${widget.parah.startSurah}:${widget.parah.startVerse} to Surah ${widget.parah.endSurah}:${widget.parah.endVerse}',
      );

      // surahs in range
      final surahsInParah = provider.surahs
          .where(
            (surah) =>
                surah.number >= widget.parah.startSurah &&
                surah.number <= widget.parah.endSurah,
          )
          .toList();

      if (surahsInParah.isEmpty) {
        print('⚠ No Surahs found in range');
        return [];
      }

      print('✓ Found ${surahsInParah.length} Surahs in range');

      // fetch per surah
      for (final surah in surahsInParah) {
        print('   Fetching Surah ${surah.number}...');
        final ayahs = await provider.getAyahsBySurah(
          surah.number,
          forceRefresh: false,
        );

        int addedCount = 0;

        // filter by range
        for (final ayah in ayahs) {
          bool shouldInclude = true;

          // start surah: from startVerse
          if (surah.number == widget.parah.startSurah) {
            if (ayah.numberInSurah < widget.parah.startVerse) {
              shouldInclude = false;
            }
          }

          // end surah: up to endVerse
          if (surah.number == widget.parah.endSurah) {
            if (ayah.numberInSurah > widget.parah.endVerse) {
              shouldInclude = false;
            }
          }

          if (shouldInclude) {
            allAyahs.add(ayah);
            addedCount++;
          }
        }

        print('   ✓ Added $addedCount Ayahs from Surah ${surah.number}');
      }

      print('✓ Total ${allAyahs.length} Ayahs loaded for ${widget.parah.name}');
      return allAyahs;
    } catch (e) {
      print('✗ Error fetching Ayahs: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B6B45), Color(0xFF2D8A5F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.parah.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Surah ${widget.parah.startSurah}:${widget.parah.startVerse} - Surah ${widget.parah.endSurah}:${widget.parah.endVerse}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Ayah>>(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Parah verses...'),
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
                ],
              ),
            );
          }

          final ayahs = snapshot.data ?? [];

          if (ayahs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No Verses found in this Parah'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              return _buildAyahCard(context, ayahs[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildAyahCard(BuildContext context, Ayah ayah) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final cardBackgroundColor = AppColors.getCardColor(isDarkMode);
        final primaryColor = AppColors.getPrimaryColor(isDarkMode);
        return Container(
          margin: EdgeInsets.only(
            bottom: Responsive.getPadding(context, 12, 14, 16),
          ),
          padding: EdgeInsets.all(Responsive.getPadding(context, 12, 14, 16)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardBackgroundColor,
                primaryColor.withOpacity(isDarkMode ? 0.08 : 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.getBorderColor(isDarkMode).withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(isDarkMode ? 0.16 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Surah ${ayah.surahNumber}:${ayah.numberInSurah}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(height: Responsive.getPadding(context, 6, 8, 10)),

              // Arabic Text with ending marker
              SizedBox(height: Responsive.getPadding(context, 6, 8, 10)),

              // Arabic Text
              Container(
                padding: EdgeInsets.all(
                  Responsive.getPadding(context, 12, 14, 16),
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.getSurfaceColor(isDarkMode)
                      : const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getBorderColor(
                      isDarkMode,
                    ).withOpacity(0.6),
                  ),
                ),
                child: Text(
                  ayah.textArabic,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 17, 19, 22),
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimaryColor(isDarkMode),
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
              SizedBox(height: Responsive.getPadding(context, 8, 10, 12)),

              // English Translation
              Container(
                padding: EdgeInsets.all(
                  Responsive.getPadding(context, 10, 12, 14),
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.getSurfaceColor(isDarkMode)
                      : const Color(0xFFF1F8F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getBorderColor(
                      isDarkMode,
                    ).withOpacity(0.6),
                  ),
                ),
                child: Text(
                  ayah.text,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 12, 13, 15),
                    color: AppColors.getTextPrimaryColor(isDarkMode),
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
