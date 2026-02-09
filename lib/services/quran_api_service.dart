import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/surah.dart';
import '../models/parah.dart';
import '../models/ayah.dart';

class QuranApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  // surahs (with meta)
  static Future<List<Surah>> fetchSurahs() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/surah'))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Surah API timeout');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> surahList = data['data'] ?? [];

        return surahList
            .map(
              (json) => Surah(
                number: json['number'] as int? ?? 0,
                name: json['name'] as String? ?? '',
                nameArabic: json['name'] as String? ?? '',
                verses: json['numberOfAyahs'] as int? ?? 0,
                revelationType: json['revelationType'] as String? ?? '',
                englishName: json['englishName'] as String? ?? '',
                englishNameTranslation:
                    json['englishNameTranslation'] as String? ?? '',
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to fetch Surahs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Surahs: $e');
      rethrow;
    }
  }

  // parahs (hardcoded)
  static Future<List<Parah>> fetchParahs() async {
    try {
      // Since the API doesn't have a direct endpoint for Parahs,
      // we'll use hardcoded data or create a custom endpoint
      // For now, returning hardcoded Parah data
      return _getHardcodedParahs();
    } catch (e) {
      print('Error fetching Parahs: $e');
      return _getHardcodedParahs();
    }
  }

  // parah list (30)
  static List<Parah> _getHardcodedParahs() {
    return [
      Parah(
        number: 1,
        name: 'Parah 1',
        startSurah: 1,
        startVerse: 1,
        endSurah: 2,
        endVerse: 141,
      ),
      Parah(
        number: 2,
        name: 'Parah 2',
        startSurah: 2,
        startVerse: 142,
        endSurah: 2,
        endVerse: 252,
      ),
      Parah(
        number: 3,
        name: 'Parah 3',
        startSurah: 2,
        startVerse: 253,
        endSurah: 3,
        endVerse: 92,
      ),
      Parah(
        number: 4,
        name: 'Parah 4',
        startSurah: 3,
        startVerse: 93,
        endSurah: 4,
        endVerse: 23,
      ),
      Parah(
        number: 5,
        name: 'Parah 5',
        startSurah: 4,
        startVerse: 24,
        endSurah: 4,
        endVerse: 147,
      ),
      Parah(
        number: 6,
        name: 'Parah 6',
        startSurah: 4,
        startVerse: 148,
        endSurah: 5,
        endVerse: 81,
      ),
      Parah(
        number: 7,
        name: 'Parah 7',
        startSurah: 5,
        startVerse: 82,
        endSurah: 6,
        endVerse: 110,
      ),
      Parah(
        number: 8,
        name: 'Parah 8',
        startSurah: 6,
        startVerse: 111,
        endSurah: 7,
        endVerse: 87,
      ),
      Parah(
        number: 9,
        name: 'Parah 9',
        startSurah: 7,
        startVerse: 88,
        endSurah: 8,
        endVerse: 40,
      ),
      Parah(
        number: 10,
        name: 'Parah 10',
        startSurah: 8,
        startVerse: 41,
        endSurah: 9,
        endVerse: 92,
      ),
      Parah(
        number: 11,
        name: 'Parah 11',
        startSurah: 9,
        startVerse: 93,
        endSurah: 11,
        endVerse: 5,
      ),
      Parah(
        number: 12,
        name: 'Parah 12',
        startSurah: 11,
        startVerse: 6,
        endSurah: 12,
        endVerse: 25,
      ),
      Parah(
        number: 13,
        name: 'Parah 13',
        startSurah: 12,
        startVerse: 26,
        endSurah: 12,
        endVerse: 111,
      ),
      Parah(
        number: 14,
        name: 'Parah 14',
        startSurah: 13,
        startVerse: 1,
        endSurah: 14,
        endVerse: 52,
      ),
      Parah(
        number: 15,
        name: 'Parah 15',
        startSurah: 15,
        startVerse: 1,
        endSurah: 16,
        endVerse: 128,
      ),
      Parah(
        number: 16,
        name: 'Parah 16',
        startSurah: 17,
        startVerse: 1,
        endSurah: 18,
        endVerse: 74,
      ),
      Parah(
        number: 17,
        name: 'Parah 17',
        startSurah: 18,
        startVerse: 75,
        endSurah: 20,
        endVerse: 135,
      ),
      Parah(
        number: 18,
        name: 'Parah 18',
        startSurah: 21,
        startVerse: 1,
        endSurah: 22,
        endVerse: 78,
      ),
      Parah(
        number: 19,
        name: 'Parah 19',
        startSurah: 23,
        startVerse: 1,
        endSurah: 25,
        endVerse: 20,
      ),
      Parah(
        number: 20,
        name: 'Parah 20',
        startSurah: 25,
        startVerse: 21,
        endSurah: 27,
        endVerse: 93,
      ),
      Parah(
        number: 21,
        name: 'Parah 21',
        startSurah: 28,
        startVerse: 1,
        endSurah: 29,
        endVerse: 45,
      ),
      Parah(
        number: 22,
        name: 'Parah 22',
        startSurah: 29,
        startVerse: 46,
        endSurah: 33,
        endVerse: 30,
      ),
      Parah(
        number: 23,
        name: 'Parah 23',
        startSurah: 33,
        startVerse: 31,
        endSurah: 36,
        endVerse: 27,
      ),
      Parah(
        number: 24,
        name: 'Parah 24',
        startSurah: 36,
        startVerse: 28,
        endSurah: 39,
        endVerse: 31,
      ),
      Parah(
        number: 25,
        name: 'Parah 25',
        startSurah: 39,
        startVerse: 32,
        endSurah: 41,
        endVerse: 46,
      ),
      Parah(
        number: 26,
        name: 'Parah 26',
        startSurah: 41,
        startVerse: 47,
        endSurah: 46,
        endVerse: 10,
      ),
      Parah(
        number: 27,
        name: 'Parah 27',
        startSurah: 46,
        startVerse: 11,
        endSurah: 51,
        endVerse: 30,
      ),
      Parah(
        number: 28,
        name: 'Parah 28',
        startSurah: 51,
        startVerse: 31,
        endSurah: 66,
        endVerse: 12,
      ),
      Parah(
        number: 29,
        name: 'Parah 29',
        startSurah: 67,
        startVerse: 1,
        endSurah: 77,
        endVerse: 50,
      ),
      Parah(
        number: 30,
        name: 'Parah 30',
        startSurah: 78,
        startVerse: 1,
        endSurah: 114,
        endVerse: 6,
      ),
    ];
  }

  // ayahs (ar + en)
  static Future<List<Ayah>> fetchAyahsBySurah(int surahNumber) async {
    try {
      // arabic
      final arabicResponse = await http
          .get(Uri.parse('$_baseUrl/surah/$surahNumber'))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Arabic Ayah API timeout');
            },
          );

      // english
      final englishResponse = await http
          .get(Uri.parse('$_baseUrl/surah/$surahNumber/en.sahih'))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('English translation API timeout');
            },
          );

      if (arabicResponse.statusCode == 200 &&
          englishResponse.statusCode == 200) {
        final Map<String, dynamic> arabicData = jsonDecode(arabicResponse.body);
        final Map<String, dynamic> englishData = jsonDecode(
          englishResponse.body,
        );

        final Map<String, dynamic> arabicSurah = arabicData['data'] ?? {};
        final Map<String, dynamic> englishSurah = englishData['data'] ?? {};

        final List<dynamic> arabicAyahs = arabicSurah['ayahs'] ?? [];
        final List<dynamic> englishAyahs = englishSurah['ayahs'] ?? [];

        if (arabicAyahs.isEmpty) {
          print('⚠ No ayahs found in API response for Surah $surahNumber');
        }

        // merge (skip bismillah)
        final List<Ayah> mergedAyahs = [];
        for (int i = 0; i < arabicAyahs.length; i++) {
          final arabicAyah = arabicAyahs[i];
          final numberInSurah = arabicAyah['numberInSurah'] as int? ?? 0;

          // Skip Bismillah (numberInSurah == 0)
          if (numberInSurah == 0) continue;

          final englishAyah = i < englishAyahs.length ? englishAyahs[i] : null;

          mergedAyahs.add(
            Ayah(
              number: arabicAyah['number'] as int? ?? 0,
              numberInSurah: numberInSurah,
              text:
                  englishAyah?['text'] as String? ??
                  'Translation not available',
              textArabic: arabicAyah['text'] as String? ?? '',
              surahNumber: surahNumber,
            ),
          );
        }

        print('✓ Fetched ${mergedAyahs.length} Ayahs with translations');
        return mergedAyahs;
      } else {
        print(
          'API Error - Arabic: ${arabicResponse.statusCode}, English: ${englishResponse.statusCode}',
        );
        throw Exception(
          'Failed to fetch Ayahs: Arabic(${arabicResponse.statusCode}), English(${englishResponse.statusCode})',
        );
      }
    } catch (e) {
      print('✗ Error fetching Ayahs for Surah $surahNumber: $e');
      rethrow;
    }
  }
}
