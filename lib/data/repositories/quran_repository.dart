import '../../models/surah.dart';
import '../../models/parah.dart';
import '../../models/ayah.dart';
import '../../services/quran_database_service.dart';
import '../../services/quran_api_service.dart';

class QuranRepository {
  final _databaseService = QuranDatabaseService();

  Future<List<Surah>> getSurahs() async {
    try {
      final cachedSurahs = await _databaseService.getSurahs();

      if (cachedSurahs.isNotEmpty) {
        print('Loading Surahs from local database');
        return cachedSurahs;
      }

      print('Fetching Surahs from API');
      final apiSurahs = await QuranApiService.fetchSurahs();

      if (apiSurahs.isNotEmpty) {
        await _databaseService.saveSurahs(apiSurahs);
        print('Saved ${apiSurahs.length} Surahs to database');
      }

      return apiSurahs;
    } catch (e) {
      print('Error in getSurahs: $e');
      return await _databaseService.getSurahs();
    }
  }

  Future<Surah?> getSurah(int number) async {
    try {
      return await _databaseService.getSurah(number);
    } catch (e) {
      print('Error getting Surah $number: $e');
      return null;
    }
  }

  Future<List<Surah>> searchSurahs(String query) async {
    try {
      final allSurahs = await getSurahs();
      final lowerQuery = query.toLowerCase();

      return allSurahs.where((surah) {
        return surah.name.toLowerCase().contains(lowerQuery) ||
            surah.englishName.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching Surahs: $e');
      return [];
    }
  }

  Future<List<Parah>> getParahs({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedParahs = await _databaseService.getParahs();

        if (cachedParahs.isNotEmpty) {
          print('✓ Loading Parahs from local database');
          return cachedParahs;
        }
      } else {
        print('🔄 Force refreshing Parahs from API...');
      }

      print('Fetching Parahs from API');
      final apiParahs = await QuranApiService.fetchParahs();

      if (apiParahs.isNotEmpty) {
        await _databaseService.saveParahs(apiParahs);
        print('✓ Saved ${apiParahs.length} Parahs to database');
      }

      return apiParahs;
    } catch (e) {
      print('Error in getParahs: $e');
      return await _databaseService.getParahs();
    }
  }

  Future<Parah?> getParah(int number) async {
    try {
      return await _databaseService.getParah(number);
    } catch (e) {
      print('Error getting Parah $number: $e');
      return null;
    }
  }

  Future<bool> isQuranDataCached() async {
    try {
      return await _databaseService.isQuranDataCached();
    } catch (e) {
      print('Error checking cache: $e');
      return false;
    }
  }

  Future<void> refreshQuranData() async {
    try {
      print('Refreshing Quran data from API');
      final surahs = await QuranApiService.fetchSurahs();
      final parahs = await QuranApiService.fetchParahs();

      await _databaseService.saveSurahs(surahs);
      await _databaseService.saveParahs(parahs);

      print('Quran data refreshed successfully');
    } catch (e) {
      print('Error refreshing Quran data: $e');
      rethrow;
    }
  }

  Future<void> clearCache() async {
    try {
      await _databaseService.clearAllData();
      print('Quran cache cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<List<Ayah>> getAyahsBySurah(
    int surahNumber, {
    bool forceRefresh = false,
  }) async {
    try {
      print('=== Getting Ayahs for Surah $surahNumber ===');

      if (!forceRefresh) {
        final cachedAyahs = await _databaseService.getAyahsBySurah(surahNumber);

        if (cachedAyahs.isNotEmpty) {
          print(
            '✓ Loaded ${cachedAyahs.length} Ayahs for Surah $surahNumber from database',
          );
          return cachedAyahs;
        }
      }

      print('⚠ Ayahs not in cache, fetching from API...');

      print('Fetching Ayahs for Surah $surahNumber from API');
      final apiAyahs = await QuranApiService.fetchAyahsBySurah(surahNumber);

      print('✓ API returned ${apiAyahs.length} Ayahs');

      if (apiAyahs.isNotEmpty) {
        await _databaseService.saveAyahs(apiAyahs);
        print(
          '✓ Saved ${apiAyahs.length} Ayahs for Surah $surahNumber to database',
        );
      } else {
        print('⚠ API returned 0 Ayahs for Surah $surahNumber');
      }

      return apiAyahs;
    } catch (e) {
      print('✗ Error in getAyahsBySurah: $e');

      final fallbackAyahs = await _databaseService.getAyahsBySurah(surahNumber);
      if (fallbackAyahs.isNotEmpty) {
        print('✓ Returning ${fallbackAyahs.length} cached Ayahs as fallback');
        return fallbackAyahs;
      }

      print('✗ No fallback cache available');
      return [];
    }
  }
}
