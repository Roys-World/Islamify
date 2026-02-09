import 'package:http/http.dart' as http;
import 'dart:convert';

class IslamicDateService {
  static const String _primaryUrl = 'https://api.aladhan.com/v1/gToH';
  static const String _secondaryUrl =
      'https://api.aladhan.com/v1/gToH'; // Same primary as backup

  // cache
  static String? _cachedDate;
  static DateTime? _cacheDate;

  // fetch (primary → secondary → local)
  static Future<String> getIslamicDate(DateTime gregorianDate) async {
    // same-day cache
    if (_cacheDate != null &&
        _cacheDate!.day == gregorianDate.day &&
        _cacheDate!.month == gregorianDate.month &&
        _cacheDate!.year == gregorianDate.year &&
        _cachedDate != null) {
      print('Using cached Islamic date: $_cachedDate');
      return _cachedDate!;
    }

    try {
      // Try primary API first
      final result = await _tryPrimaryAPI(gregorianDate);
      if (result != null) {
        _cachedDate = result;
        _cacheDate = gregorianDate;
        return result;
      }
    } catch (e) {
      print('Primary API failed: $e');
    }

    try {
      // Try secondary API
      final result = await _trySecondaryAPI(gregorianDate);
      if (result != null) {
        _cachedDate = result;
        _cacheDate = gregorianDate;
        return result;
      }
    } catch (e) {
      print('Secondary API failed: $e');
    }

    // fallback (local)
    print('Using fallback local calculation');
    final result = _getIslamicDateFallback(gregorianDate);
    _cachedDate = result;
    _cacheDate = gregorianDate;
    return result;
  }

  // primary (Aladhan)
  static Future<String?> _tryPrimaryAPI(DateTime gregorianDate) async {
    try {
      final day = gregorianDate.day.toString().padLeft(2, '0');
      final month = gregorianDate.month.toString().padLeft(2, '0');
      final year = gregorianDate.year.toString();

      final url = Uri.parse('$_primaryUrl?date=$day-$month-$year');

      print('Fetching Islamic date from: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final hijri = data['data']?['hijri'];

        if (hijri != null) {
          final day = hijri['day'] ?? '1';
          final monthData = hijri['month'];
          final year = hijri['year'] ?? '1446';

          String monthName = _getMonthName(monthData);
          final result = '$day $monthName, $year';
          print('Successfully fetched Islamic date: $result');
          return result;
        } else {
          print('No hijri data in response');
        }
      } else {
        print('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Primary API error: $e');
      rethrow;
    }
    return null;
  }

  // secondary (Aladhan backup)
  static Future<String?> _trySecondaryAPI(DateTime gregorianDate) async {
    try {
      final day = gregorianDate.day.toString().padLeft(2, '0');
      final month = gregorianDate.month.toString().padLeft(2, '0');
      final year = gregorianDate.year.toString();

      final url = Uri.parse('$_secondaryUrl?date=$day-$month-$year');

      print('Fetching Islamic date from secondary: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      print('Secondary API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final hijri = data['data']?['hijri'];

        if (hijri != null) {
          final day = hijri['day'] ?? '1';
          final monthData = hijri['month'];
          final year = hijri['year'] ?? '1446';

          String monthName = _getMonthName(monthData);
          final result = '$day $monthName, $year';
          print('Successfully fetched from secondary API: $result');
          return result;
        }
      }
    } catch (e) {
      print('Secondary API error: $e');
      rethrow;
    }
    return null;
  }

  // month (en)
  static String _getMonthName(dynamic monthData) {
    const monthNames = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];

    if (monthData is Map) {
      return monthData['en'] ?? monthData['number']?.toString() ?? '1';
    } else if (monthData is int) {
      return monthData > 0 && monthData <= 12
          ? monthNames[monthData - 1]
          : monthData.toString();
    }
    return 'Unknown';
  }

  // local calc (Kuwaiti)
  static String _getIslamicDateFallback(DateTime gregorianDate) {
    final year = gregorianDate.year;
    final month = gregorianDate.month;
    final day = gregorianDate.day;

    // Kuwaiti algorithm for Islamic date
    int a = ((14 - month) / 12).floor();
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    int jdn =
        day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;

    int N = jdn - 1948440 + 1;
    int Q = (N / 10631).floor();
    int R = N % 10631;
    int A = ((R + 1) / 354).floor();
    int W = (R % 354) + 30 * A + 6;

    int islamicYear = 30 * Q + A + 1;
    int islamicMonth = ((W ~/ 354 + 3) ~/ 30).floor() + 1;
    int islamicDay = (W % 30) + 1;

    if (islamicMonth > 12) islamicMonth = 12;
    if (islamicDay > 30) islamicDay = 30;

    const monthNames = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];

    return '$islamicDay ${monthNames[islamicMonth - 1]}, $islamicYear';
  }

  // arabic date
  static Future<String> getIslamicDateArabic(DateTime gregorianDate) async {
    // Return cached date if same day
    if (_cacheDate != null &&
        _cacheDate!.day == gregorianDate.day &&
        _cacheDate!.month == gregorianDate.month &&
        _cacheDate!.year == gregorianDate.year &&
        _cachedDate != null) {
      return _cachedDate!;
    }

    try {
      // Try primary API first with Arabic month names
      final day = gregorianDate.day.toString();
      final month = gregorianDate.month.toString();
      final year = gregorianDate.year.toString();

      final url = Uri.parse('$_primaryUrl?date=$day-$month-$year');

      final response = await http.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final hijri = data['data']?['hijri'];

        if (hijri != null) {
          final day = hijri['day'];
          final monthData = hijri['month'];
          final year = hijri['year'];

          String monthAr = _getArabicMonthName(monthData);
          _cachedDate = '$day $monthAr, $year';
          _cacheDate = gregorianDate;
          return _cachedDate!;
        }
      }
    } catch (e) {
      print('Arabic date API failed: $e');
    }

    // fallback
    final result = _getIslamicDateFallback(gregorianDate);
    _cachedDate = result;
    _cacheDate = gregorianDate;
    return result;
  }

  // month (ar)
  static String _getArabicMonthName(dynamic monthData) {
    const arabicMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الثانية',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];

    if (monthData is Map) {
      return monthData['ar'] ?? monthData['number']?.toString() ?? '1';
    } else if (monthData is int) {
      return monthData > 0 && monthData <= 12
          ? arabicMonths[monthData - 1]
          : monthData.toString();
    }
    return 'Unknown';
  }
}
