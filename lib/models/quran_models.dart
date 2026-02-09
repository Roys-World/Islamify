class Ayah {
  final int number;
  final String text;
  final String textArabic;
  final int numberInSurah;

  Ayah({
    required this.number,
    required this.text,
    required this.textArabic,
    required this.numberInSurah,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      textArabic: json['text'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
    );
  }
}

class Surah {
  final int number;
  final String name;
  final String nameArabic;
  final String nameTranslation;
  final int ayahCount;
  final String revelation;
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.nameTranslation,
    required this.ayahCount,
    required this.revelation,
    this.ayahs = const [],
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      nameArabic: json['name_arabic'] ?? '',
      nameTranslation: json['name_translation'] ?? '',
      ayahCount: json['ayah_count'] ?? 0,
      revelation: json['revelation'] ?? 'Unknown',
      ayahs: [],
    );
  }
}

class Parah {
  final int number;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;

  Parah({
    required this.number,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });

  factory Parah.fromJson(Map<String, dynamic> json) {
    return Parah(
      number: json['number'] ?? 0,
      startSurah: json['start_surah'] ?? 1,
      startAyah: json['start_ayah'] ?? 1,
      endSurah: json['end_surah'] ?? 1,
      endAyah: json['end_ayah'] ?? 1,
    );
  }
}
