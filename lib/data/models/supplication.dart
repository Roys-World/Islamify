class Supplication {
  final String titleEnglish;
  final String titleArabic;
  final String textArabic;
  final String translationEnglish;
  final String? source; // Reference (e.g., Surah, Hadith)

  Supplication({
    required this.titleEnglish,
    required this.titleArabic,
    required this.textArabic,
    required this.translationEnglish,
    this.source,
  });
}
