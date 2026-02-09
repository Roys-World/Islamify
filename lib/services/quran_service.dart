import '../models/quran_models.dart';

class QuranService {
  // Static Quranic data - 114 Surahs with basic info
  static final List<Surah> surahs = [
    Surah(
      number: 1,
      name: 'Al-Fatiha',
      nameArabic: 'الفاتحة',
      nameTranslation: 'The Opening',
      ayahCount: 7,
      revelation: 'Meccan',
    ),
    Surah(
      number: 2,
      name: 'Al-Baqarah',
      nameArabic: 'البقرة',
      nameTranslation: 'The Cow',
      ayahCount: 286,
      revelation: 'Medinan',
    ),
    Surah(
      number: 3,
      name: 'Ali Imran',
      nameArabic: 'آل عمران',
      nameTranslation: 'The Family of Imran',
      ayahCount: 200,
      revelation: 'Medinan',
    ),
    Surah(
      number: 4,
      name: 'An-Nisa',
      nameArabic: 'النساء',
      nameTranslation: 'The Women',
      ayahCount: 176,
      revelation: 'Medinan',
    ),
    Surah(
      number: 5,
      name: 'Al-Maidah',
      nameArabic: 'المائدة',
      nameTranslation: 'The Table',
      ayahCount: 120,
      revelation: 'Medinan',
    ),
    Surah(
      number: 6,
      name: 'Al-Anam',
      nameArabic: 'الأنعام',
      nameTranslation: 'The Cattle',
      ayahCount: 165,
      revelation: 'Meccan',
    ),
    Surah(
      number: 7,
      name: 'Al-Araf',
      nameArabic: 'الأعراف',
      nameTranslation: 'The Heights',
      ayahCount: 206,
      revelation: 'Meccan',
    ),
    Surah(
      number: 8,
      name: 'Al-Anfal',
      nameArabic: 'الأنفال',
      nameTranslation: 'The Spoils of War',
      ayahCount: 75,
      revelation: 'Medinan',
    ),
    Surah(
      number: 9,
      name: 'At-Taubah',
      nameArabic: 'التوبة',
      nameTranslation: 'The Repentance',
      ayahCount: 129,
      revelation: 'Medinan',
    ),
    Surah(
      number: 10,
      name: 'Yunus',
      nameArabic: 'يونس',
      nameTranslation: 'Jonah',
      ayahCount: 109,
      revelation: 'Meccan',
    ),
    // Add more as needed - this is a sample
  ];

  // Static Parah data (30 Parahs)
  static final List<Parah> parahs = [
    Parah(number: 1, startSurah: 1, startAyah: 1, endSurah: 1, endAyah: 141),
    Parah(number: 2, startSurah: 1, startAyah: 142, endSurah: 2, endAyah: 252),
    Parah(number: 3, startSurah: 2, startAyah: 253, endSurah: 3, endAyah: 14),
    Parah(number: 4, startSurah: 3, startAyah: 15, endSurah: 4, endAyah: 147),
    Parah(number: 5, startSurah: 4, startAyah: 148, endSurah: 5, endAyah: 81),
    Parah(number: 6, startSurah: 5, startAyah: 82, endSurah: 6, endAyah: 110),
    Parah(number: 7, startSurah: 6, startAyah: 111, endSurah: 7, endAyah: 87),
    Parah(number: 8, startSurah: 7, startAyah: 88, endSurah: 8, endAyah: 40),
    Parah(number: 9, startSurah: 8, startAyah: 41, endSurah: 9, endAyah: 92),
    Parah(number: 10, startSurah: 9, startAyah: 93, endSurah: 11, endAyah: 5),
    // Add remaining 20 parahs as needed
  ];

  /// Get all Surahs
  static List<Surah> getAllSurahs() {
    return surahs;
  }

  /// Get all Parahs
  static List<Parah> getAllParahs() {
    return parahs;
  }

  /// Get a specific Surah by number
  static Surah? getSurahByNumber(int number) {
    try {
      return surahs.firstWhere((s) => s.number == number);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific Parah by number
  static Parah? getParahByNumber(int number) {
    try {
      return parahs.firstWhere((p) => p.number == number);
    } catch (e) {
      return null;
    }
  }
}
