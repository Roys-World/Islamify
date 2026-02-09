class Supplication {
  final String titleArabic;
  final String titleEnglish;
  final String textArabic;
  final String textEnglish;
  final String category; // 'Quranic' or 'Sunnah'
  final String? transliteration;

  Supplication({
    required this.titleArabic,
    required this.titleEnglish,
    required this.textArabic,
    required this.textEnglish,
    required this.category,
    this.transliteration,
  });
}
