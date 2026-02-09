class Azkaar {
  final String textArabic;
  final String translationEnglish;
  final String? transliterationEnglish;
  final int? count; // Number of times to recite
  final String? benefits;

  Azkaar({
    required this.textArabic,
    required this.translationEnglish,
    this.transliterationEnglish,
    this.count,
    this.benefits,
  });
}
