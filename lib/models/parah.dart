class Parah {
  final int number;
  final String name;
  final int startSurah;
  final int startVerse;
  final int endSurah;
  final int endVerse;

  Parah({
    required this.number,
    required this.name,
    required this.startSurah,
    required this.startVerse,
    required this.endSurah,
    required this.endVerse,
  });

  // Convert Parah to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'startSurah': startSurah,
      'startVerse': startVerse,
      'endSurah': endSurah,
      'endVerse': endVerse,
    };
  }

  // Create Parah from JSON
  factory Parah.fromJson(Map<String, dynamic> json) {
    return Parah(
      number: json['number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      startSurah: json['startSurah'] as int? ?? 0,
      startVerse: json['startVerse'] as int? ?? 0,
      endSurah: json['endSurah'] as int? ?? 0,
      endVerse: json['endVerse'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'Parah($number: $name)';
}
