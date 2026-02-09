class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  final String textArabic;
  final int surahNumber;

  Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.textArabic,
    required this.surahNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'numberInSurah': numberInSurah,
      'text': text,
      'textArabic': textArabic,
      'surahNumber': surahNumber,
    };
  }

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] as int? ?? 0,
      numberInSurah: json['numberInSurah'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      textArabic: json['textArabic'] as String? ?? '',
      surahNumber: json['surahNumber'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'Ayah($numberInSurah)';
}
