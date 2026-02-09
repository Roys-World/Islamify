import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../models/parah.dart';
import '../models/ayah.dart';
import '../data/repositories/quran_repository.dart';

class QuranProvider extends ChangeNotifier {
  final _repository = QuranRepository();

  List<Surah> _surahs = [];
  List<Parah> _parahs = [];
  List<Surah> _filteredSurahs = [];
  List<Parah> _filteredParahs = [];

  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  Surah? _selectedSurah;
  Parah? _selectedParah;

  String _searchQuery = '';
  bool _showingSurahs = true; // Toggle between Surahs and Parahs view

  // Getters
  List<Surah> get surahs => _surahs;
  List<Parah> get parahs => _parahs;
  List<Surah> get filteredSurahs => _filteredSurahs;
  List<Parah> get filteredParahs => _filteredParahs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Surah? get selectedSurah => _selectedSurah;
  Parah? get selectedParah => _selectedParah;
  String get searchQuery => _searchQuery;
  bool get showingSurahs => _showingSurahs;
  bool get isInitialized => _isInitialized;

  QuranProvider();

  // init quran data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _error = null;

      // Load Surahs on startup
      _surahs = await _repository.getSurahs();
      _filteredSurahs = _surahs;

      // Load Parahs on startup
      _parahs = await _repository.getParahs(forceRefresh: true);
      _filteredParahs = _parahs;

      print(
        '✓ Quran data loaded: ${_surahs.length} Surahs, ${_parahs.length} Parahs',
      );

      _isInitialized = true;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load Quran data: $e';
      print('✗ Error initializing Quran data: $e');
      _isInitialized = true;
      _setLoading(false);
      notifyListeners();
    }
  }

  // search surahs
  Future<void> searchSurahs(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredSurahs = _surahs;
    } else {
      _filteredSurahs = await _repository.searchSurahs(query);
    }

    notifyListeners();
  }

  // select surah
  void selectSurah(Surah surah) {
    _selectedSurah = surah;
    notifyListeners();
  }

  // select parah
  void selectParah(Parah parah) {
    _selectedParah = parah;
    notifyListeners();
  }

  // toggle view
  void toggleView() {
    _showingSurahs = !_showingSurahs;
    _searchQuery = '';
    _filteredSurahs = _surahs;
    _filteredParahs = _parahs;
    notifyListeners();
  }

  // get surah
  Future<Surah?> getSurah(int number) async {
    try {
      return await _repository.getSurah(number);
    } catch (e) {
      print('Error getting Surah: $e');
      return null;
    }
  }

  // get parah
  Future<Parah?> getParah(int number) async {
    try {
      return await _repository.getParah(number);
    } catch (e) {
      print('Error getting Parah: $e');
      return null;
    }
  }

  // get ayahs (by surah)
  Future<List<Ayah>> getAyahsBySurah(
    int surahNumber, {
    bool forceRefresh = false,
  }) async {
    try {
      return await _repository.getAyahsBySurah(
        surahNumber,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      print('Error getting Ayahs: $e');
      return [];
    }
  }

  // refresh all
  Future<void> refreshData() async {
    try {
      _setLoading(true);
      _error = null;

      await _repository.refreshQuranData();
      await initialize();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh data: $e';
      print('Error refreshing data: $e');
      _setLoading(false);
      notifyListeners();
    }
  }

  // clear cache
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();
      _surahs = [];
      _parahs = [];
      _filteredSurahs = [];
      _filteredParahs = [];
      _selectedSurah = null;
      _selectedParah = null;
      _searchQuery = '';
      notifyListeners();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
