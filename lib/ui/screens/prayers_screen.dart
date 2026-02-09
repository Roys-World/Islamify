import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../location_service.dart';
import '../../providers/settings_provider.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  double _latitude = 0.0;
  double _longitude = 0.0;

  late Future<LocationFetchStatus> _locationFuture;
  late Timer _timer;
  DateTime _now = DateTime.now();

  // Static cache variables
  static double? _cachedLatitude;
  static double? _cachedLongitude;
  static DateTime? _lastFetchDate;
  static LocationFetchStatus? _cachedStatus;

  @override
  void initState() {
    super.initState();

    // Check if we have valid cached data
    if (_isCacheValid()) {
      // Use cached location immediately
      _latitude = _cachedLatitude!;
      _longitude = _cachedLongitude!;
      _locationFuture = Future.value(_cachedStatus!);
    } else {
      // Fetch fresh location
      _locationFuture = _getLocation();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  bool _isCacheValid() {
    // Cache is valid if we have data and it's from today
    if (_cachedLatitude == null ||
        _cachedLongitude == null ||
        _lastFetchDate == null ||
        _cachedStatus != LocationFetchStatus.success) {
      return false;
    }

    final now = DateTime.now();
    final cacheDate = _lastFetchDate!;

    // Check if it's the same day
    return now.year == cacheDate.year &&
        now.month == cacheDate.month &&
        now.day == cacheDate.day;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<LocationFetchStatus> _getLocation() async {
    try {
      final result =
          await LocationService.getCurrentLocationWithStatus(
            accuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          ).timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              return const LocationResult(status: LocationFetchStatus.error);
            },
          );

      if (result.status == LocationFetchStatus.success &&
          result.position != null) {
        if (!mounted) return result.status;

        setState(() {
          _latitude = result.position!.latitude;
          _longitude = result.position!.longitude;
        });

        // Cache the successful location fetch
        _cachedLatitude = result.position!.latitude;
        _cachedLongitude = result.position!.longitude;
        _lastFetchDate = DateTime.now();
        _cachedStatus = LocationFetchStatus.success;
      } else {
        // Cache the status even if not successful
        _cachedStatus = result.status;
      }

      return result.status;
    } catch (e) {
      print('Error fetching location in prayers screen: $e');
      _cachedStatus = LocationFetchStatus.error;
      return LocationFetchStatus.error;
    }
  }

  Future<void> _handleLocationAction(LocationFetchStatus status) async {
    if (status == LocationFetchStatus.serviceDisabled) {
      await Geolocator.openLocationSettings();
    } else if (status == LocationFetchStatus.permissionDeniedForever) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.requestPermission();
    }

    if (!mounted) return;

    // Clear cache and force fresh fetch
    _cachedLatitude = null;
    _cachedLongitude = null;
    _lastFetchDate = null;
    _cachedStatus = null;

    setState(() {
      _locationFuture = _getLocation();
    });
  }

  String _formatTime(DateTime time) => DateFormat.Hm().format(time);

  String _remainingTime(DateTime target) {
    final diff = target.difference(_now);
    if (diff.isNegative) return '00:00:00';

    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Prayers'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: FutureBuilder(
            future: _locationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data != LocationFetchStatus.success) {
                final status = snapshot.data ?? LocationFetchStatus.error;
                final message = switch (status) {
                  LocationFetchStatus.serviceDisabled =>
                    'Location services are disabled. Enable them to get accurate prayer times.',
                  LocationFetchStatus.permissionDenied =>
                    'Location permission is denied. Please allow it to get accurate prayer times.',
                  LocationFetchStatus.permissionDeniedForever =>
                    'Location permission is permanently denied. Enable it from app settings.',
                  _ => 'Unable to fetch location. Please try again.',
                };

                final actionLabel = switch (status) {
                  LocationFetchStatus.serviceDisabled => 'Enable Location',
                  LocationFetchStatus.permissionDeniedForever =>
                    'Open Settings',
                  _ => 'Retry',
                };

                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(
                      Responsive.getPadding(context, 16, 20, 24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: Responsive.getFontSize(context, 48, 56, 64),
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(
                              context,
                              14,
                              16,
                              18,
                            ),
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _handleLocationAction(status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(actionLabel),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // fallback (Makkah)
              final lat = _latitude == 0.0 ? 21.3891 : _latitude;
              final lon = _longitude == 0.0 ? 39.8579 : _longitude;

              final coordinates = Coordinates(lat, lon);
              final params = CalculationMethod.karachi.getParameters()
                ..madhab = Madhab.hanafi;

              final prayers = PrayerTimes.today(coordinates, params);
              final nextPrayer = prayers.nextPrayer();

              late final DateTime nextPrayerTime;
              late final String nextPrayerName;

              if (nextPrayer == Prayer.none) {
                final tomorrow = _now.add(const Duration(days: 1));
                final tomorrowPrayers = PrayerTimes(
                  coordinates,
                  DateComponents.from(tomorrow),
                  params,
                );
                nextPrayerTime = tomorrowPrayers.fajr;
                nextPrayerName = 'Fajr';
              } else {
                nextPrayerTime = prayers.timeForPrayer(nextPrayer)!;
                nextPrayerName = nextPrayer.name;
              }

              return ListView(
                padding: EdgeInsets.all(
                  Responsive.getPadding(context, 12, 16, 20),
                ),
                children: [
                  _ReflectionCard(
                    remaining: _remainingTime(nextPrayerTime),
                    nextPrayerName: nextPrayerName.toUpperCase(),
                    currentTime: DateFormat.Hm().format(_now),
                    nextPrayerTime: _formatTime(nextPrayerTime),
                  ),
                  SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),
                  _PrayerTile(
                    name: 'Fajr',
                    time: _formatTime(prayers.fajr),
                    imagePath: 'assets/Icons/fajr1.png',
                  ),
                  _PrayerTile(
                    name: 'Zuhr',
                    time: _formatTime(prayers.dhuhr),
                    imagePath: 'assets/Icons/zuhr.png',
                  ),
                  _PrayerTile(
                    name: 'Asr',
                    time: _formatTime(prayers.asr),
                    imagePath: 'assets/Icons/asr.png',
                  ),
                  _PrayerTile(
                    name: 'Maghrib',
                    time: _formatTime(prayers.maghrib),
                    imagePath: 'assets/Icons/Vector.png',
                  ),
                  _PrayerTile(
                    name: 'Isha',
                    time: _formatTime(prayers.isha),
                    imagePath: 'assets/Icons/isha.png',
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final String remaining;
  final String nextPrayerName;
  final String currentTime;
  final String nextPrayerTime;

  const _ReflectionCard({
    required this.remaining,
    required this.nextPrayerName,
    required this.currentTime,
    required this.nextPrayerTime,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final overlayColor = isDarkMode
            ? Colors.black.withOpacity(0.7)
            : const Color(0xFF0B2E1B).withOpacity(0.85);
        final overlayColorEnd = isDarkMode
            ? Colors.black.withOpacity(0.4)
            : const Color(0xFF0B2E1B).withOpacity(0.45);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage('assets/Icons/mosquebg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [overlayColor, overlayColorEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prayer times for today',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 20, 22, 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Next Prayer: $nextPrayerName',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 18, 20, 22),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white54),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Next Time',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nextPrayerTime,
                                style: TextStyle(
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    22,
                                    24,
                                    26,
                                  ),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Remaining',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                remaining,
                                style: TextStyle(
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    22,
                                    24,
                                    26,
                                  ),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current time: $currentTime',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final String name;
  final String time;
  final String imagePath;

  const _PrayerTile({
    required this.name,
    required this.time,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final borderColor = isDarkMode
            ? Theme.of(context).primaryColor.withOpacity(0.5)
            : const Color(0xFF1E6033);
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(imagePath, width: 28, height: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 16, 18, 20),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 16, 18, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
