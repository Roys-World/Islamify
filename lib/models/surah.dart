class Surah {
  final int number;
  final String name;
  final String nameArabic;
  final int verses;
  final String revelationType; // Makki or Madini
  final String englishName;
  final String englishNameTranslation;

  Surah({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.verses,
    required this.revelationType,
    required this.englishName,
    required this.englishNameTranslation,
  });

  // Convert Surah to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'nameArabic': nameArabic,
      'verses': verses,
      'revelationType': revelationType,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
    };
  }

  // Create Surah from JSON
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameArabic: json['nameArabic'] as String? ?? '',
      verses: json['verses'] as int? ?? 0,
      revelationType: json['revelationType'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      englishNameTranslation: json['englishNameTranslation'] as String? ?? '',
    );
  }

  @override
  String toString() => 'Surah($number: $name)';
}
