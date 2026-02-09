import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../location_service.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/islamic_date_service.dart';
import '../../providers/daily_tasks_provider.dart';
import 'supplication_screen.dart';
import 'azkaar_screen.dart';
import 'daily_tasks_screen.dart';
import 'tasbeeh_screen.dart';
import 'qibla_screen.dart';
import 'prayers_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _location = 'Islamabad, Pakistan';
  String _currentTime = '00:00:00';
  String _gregorianDate = '-- ---, ----';
  String _islamicDate = '-- ----, ----';
  late Timer _timer;
  late Timer? _maghribCheckTimer;
  DateTime? _cachedIslamicDateDay;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _startTimer();

    // init Quran only
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<QuranProvider>().initialize();
      } catch (e) {
        print('Error initializing Quran: $e');
      }
    });

    // load location immediately
    _loadLocationInBackground();

    // fetch islamic date immediately and schedule for Maghrib
    _fetchAndCacheIslamicDate();
    _startMaghribCheckTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final now = DateTime.now();
        final newTime = DateFormat('HH:mm:ss').format(now);
        final newDate = DateFormat('d MMM, yyyy').format(now);

        // update if changed
        if (newTime != _currentTime || newDate != _gregorianDate) {
          setState(() {
            _currentTime = newTime;
            _gregorianDate = newDate;
          });
        }
      }
    });
  }

  void _updateDateTime() {
    if (mounted) {
      final now = DateTime.now();
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(now);
        _gregorianDate = DateFormat('d MMM, yyyy').format(now);
      });
    }
  }

  // fetch and cache islamic date for the day
  Future<void> _fetchAndCacheIslamicDate({DateTime? forDate}) async {
    final dateToFetch = forDate ?? DateTime.now();

    // skip if already fetched for this day
    if (_cachedIslamicDateDay != null &&
        _cachedIslamicDateDay!.day == dateToFetch.day &&
        _cachedIslamicDateDay!.month == dateToFetch.month &&
        _cachedIslamicDateDay!.year == dateToFetch.year) {
      return;
    }

    try {
      final islamicDate = await IslamicDateService.getIslamicDate(dateToFetch);
      if (mounted) {
        setState(() {
          _islamicDate = islamicDate;
          _cachedIslamicDateDay = dateToFetch;
        });
      }
    } catch (e) {
      print('Error fetching Islamic date: $e');
    }
  }

  // schedule check at Maghrib to fetch tomorrow's date
  void _startMaghribCheckTimer() {
    _maghribCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      try {
        if (!mounted) return;

        final prayerProvider = context.read<PrayerProvider>();
        final currentPrayer = prayerProvider.currentPrayer;

        // when Maghrib is current prayer, fetch tomorrow's Islamic date
        if (currentPrayer != null &&
            currentPrayer.name.toLowerCase() == 'maghrib') {
          final tomorrow = DateTime.now().add(const Duration(days: 1));

          // only fetch if we haven't fetched for tomorrow yet
          if (_cachedIslamicDateDay?.day != tomorrow.day) {
            _fetchAndCacheIslamicDate(forDate: tomorrow);
          }
        }

        // also check if we crossed midnight (new day)
        final now = DateTime.now();
        if (_cachedIslamicDateDay != null &&
            _cachedIslamicDateDay!.day != now.day) {
          // new day, fetch updated Islamic date if not already fetched at Maghrib
          if (_cachedIslamicDateDay?.day != now.day) {
            _fetchAndCacheIslamicDate();
          }
        }
      } catch (e) {
        // ignore errors in timer
      }
    });
  }

  // load location (bg)
  Future<void> _loadLocationInBackground() async {
    if (_isLoadingLocation) return;

    _isLoadingLocation = true;

    try {
      final result = await LocationService.getCurrentLocationWithStatus(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!mounted) {
        _isLoadingLocation = false;
        return;
      }

      if (result.status == LocationFetchStatus.success &&
          result.position != null) {
        final position = result.position!;

        // get city
        LocationService.getCityName(position)
            .timeout(const Duration(seconds: 3))
            .then((cityName) {
              if (mounted) {
                setState(() {
                  _location = cityName ?? 'Islamabad, Pakistan';
                });
              }
            })
            .catchError((_) {
              if (mounted) {
                setState(() {
                  _location = 'Islamabad, Pakistan';
                });
              }
            });

        // update prayer
        try {
          context.read<PrayerProvider>().setLocation(
            position.latitude,
            position.longitude,
          );
        } catch (e) {
          print('Error updating prayer provider: $e');
        }
      } else {
        setState(() {
          _location = 'Islamabad, Pakistan';
        });
      }
    } catch (e) {
      print('Location error: $e');
      if (mounted) {
        setState(() {
          _location = 'Islamabad, Pakistan';
        });
      }
    } finally {
      _isLoadingLocation = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _maghribCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<SettingsProvider>().darkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      appBar: _buildAppBar(),
      body: ListView(
        padding: EdgeInsets.all(Responsive.getPadding(context, 12, 16, 20)),
        children: [
          _reflectionCard(),
          SizedBox(height: Responsive.getPadding(context, 16, 18, 24)),
          _nextPrayerAlert(),
          SizedBox(height: Responsive.getPadding(context, 16, 18, 24)),
          _islamicFeatures(),
          SizedBox(height: Responsive.getPadding(context, 16, 18, 24)),
          _dailyTasks(),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.getBackgroundColor(
        context.watch<SettingsProvider>().darkMode,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assalam o Alaikum,',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 11, 13, 14),
              color: AppColors.getTextSecondaryColor(
                context.watch<SettingsProvider>().darkMode,
              ),
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            widget.userName,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 18, 20, 24),
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryColor(
                context.watch<SettingsProvider>().darkMode,
              ),
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => _showNotificationsPopup(),
          child: _iconButton(Icons.notifications_outlined),
        ),
        GestureDetector(
          onTap: () => _showCalendarPopup(),
          child: _iconButton(Icons.calendar_month_outlined),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  static Widget _iconButton(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.card,
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }

  // ================= REFLECTION CARD (ENHANCED) =================
  Widget _reflectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: Responsive.getFontSize(context, 16, 18, 20),
                    ),
                    SizedBox(width: Responsive.getPadding(context, 4, 6, 8)),
                    Expanded(
                      child: Text(
                        _location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.getFontSize(context, 12, 13, 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _currentTime,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, 14, 15, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),

          // Dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gregorian',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    _gregorianDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(height: 40, width: 1, color: Colors.white30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Islamic',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    _islamicDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Responsive.getPadding(context, 12, 14, 16)),

          // Reflection Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Reflection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, 16, 18, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Build your daily direction with reflection and mindfulness',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: Responsive.getFontSize(context, 12, 13, 14),
                ),
              ),
              SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getPadding(context, 20, 24, 28),
                    vertical: Responsive.getPadding(context, 8, 10, 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DailyTasksScreen()),
                  );
                },
                child: Text(
                  'Start Reflection',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 13, 14, 15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= NEXT PRAYER ALERT (ENHANCED) =================
  Widget _nextPrayerAlert() {
    return Consumer<PrayerProvider>(
      builder: (context, prayerProvider, _) {
        final currentPrayer = prayerProvider.currentPrayer;
        final nextPrayer = prayerProvider.nextPrayer;
        final countdown = prayerProvider.countdown;

        final currentPrayerTime = currentPrayer != null
            ? prayerProvider.getPrayerTimeRange(currentPrayer)
            : 'N/A';

        final nextPrayerTime = nextPrayer != null
            ? prayerProvider.getPrayerTimeRange(nextPrayer)
            : 'N/A';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Current Prayer
              _prayerInfoRow(
                'Current Prayer',
                currentPrayer?.name ?? 'N/A',
                currentPrayerTime,
                _getPrayerIcon(currentPrayer?.name),
                true,
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.border.withOpacity(0.5)),
              const SizedBox(height: 12),

              // Next Prayer with Countdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Prayer',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _getPrayerIconWidget(nextPrayer?.name),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextPrayer?.name ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    nextPrayerTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            countdown,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'Countdown',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrayersScreen()),
                    );
                  },
                  child: const Text(
                    'View Prayer Details',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _prayerInfoRow(
    String label,
    String prayerName,
    String time,
    IconData icon,
    bool isCurrent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isCurrent) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Get prayer-specific icon based on prayer name
  IconData _getPrayerIcon(String? prayerName) {
    switch (prayerName?.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
      case 'zuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.cloud;
      case 'maghrib':
        return Icons.brightness_2;
      case 'isha':
        return Icons.brightness_3;
      default:
        return Icons.mosque;
    }
  }

  /// Get prayer-specific icon widget (image or icon) based on prayer name
  Widget _getPrayerIconWidget(String? prayerName) {
    final iconPath = _getPrayerIconPath(prayerName);
    if (iconPath != null) {
      return Image.asset(iconPath, width: 28, height: 28);
    } else {
      return Icon(
        _getPrayerIcon(prayerName),
        color: AppColors.primary,
        size: 24,
      );
    }
  }

  /// Get prayer icon path based on prayer name
  String? _getPrayerIconPath(String? prayerName) {
    switch (prayerName?.toLowerCase()) {
      case 'fajr':
        return 'assets/Icons/fajr1.png';
      case 'dhuhr':
      case 'zuhr':
        return 'assets/Icons/zuhr.png';
      case 'asr':
        return 'assets/Icons/asr.png';
      case 'maghrib':
        return 'assets/Icons/Vector.png';
      case 'isha':
        return 'assets/Icons/isha.png';
      default:
        return null;
    }
  }

  // ================= ISLAMIC FEATURES (NEW) =================
  Widget _islamicFeatures() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDarkMode = settings.darkMode;
        final features = [
          ('Tasbeeh', 'assets/Icons/iTasbeeh.png', AppColors.primary),
          (
            'Qibla Direction',
            'assets/Icons/iQibla.png',
            const Color.fromRGBO(27, 94, 32, 1),
          ),
          ('Supplication', 'assets/Icons/iPray.png', const Color(0xFF2D9B6E)),
          ('Azkaar', 'assets/Icons/iAzkaar.png', AppColors.secondary),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'More Features',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.getFontSize(context, 14, 16, 18),
              ),
            ),
            SizedBox(height: Responsive.getPadding(context, 10, 12, 14)),
            GridView.count(
              crossAxisCount: Responsive.getGridCrossAxisCount(context),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Responsive.getPadding(context, 10, 12, 14),
              crossAxisSpacing: Responsive.getPadding(context, 10, 12, 14),
              children: List.generate(features.length, (index) {
                final feature = features[index];
                return _featureCard(
                  feature.$1,
                  feature.$2,
                  feature.$3,
                  isDarkMode,
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _featureCard(
    String label,
    String imagePath,
    Color color,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: () {
        if (label == 'Tasbeeh') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TasbeehScreen()),
          );
        } else if (label == 'Qibla Direction') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QiblaScreen()),
          );
        } else if (label == 'Supplication') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupplicationScreen()),
          );
        } else if (label == 'Azkaar') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AzkaarScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.getCardColor(isDarkMode)
              : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode
                ? AppColors.border.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? color.withOpacity(0.3)
                    : color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                imagePath,
                width: 24,
                height: 24,
                color: isDarkMode ? Colors.white.withOpacity(0.9) : null,
                colorBlendMode: isDarkMode ? BlendMode.modulate : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.getTextPrimaryColor(isDarkMode)
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DAILY TASKS (IMPROVED) =================
  Widget _dailyTasks() {
    return Consumer<DailyTasksProvider>(
      builder: (context, tasksProvider, _) {
        final isDarkMode = context.watch<SettingsProvider>().darkMode;
        final tasks = tasksProvider.tasks;
        final completedCount = tasksProvider.completedTasksCount;
        final totalCount = tasksProvider.totalTasksCount;
        final progress = tasksProvider.progress;

        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyTasksScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(
                          isDarkMode,
                        ).withOpacity(isDarkMode ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '$completedCount/$totalCount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.getPrimaryColor(isDarkMode),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit,
                            size: 14,
                            color: AppColors.getPrimaryColor(isDarkMode),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.getBorderColor(isDarkMode),
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.getPrimaryColor(isDarkMode),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tasks List
              if (tasks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 48,
                          color: AppColors.getTextSecondaryColor(
                            isDarkMode,
                          ).withOpacity(0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No tasks yet',
                          style: TextStyle(
                            color: AppColors.getTextSecondaryColor(isDarkMode),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...tasks.take(4).toList().asMap().entries.map((entry) {
                  int index = entry.key;
                  var task = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < tasks.take(4).length - 1 ? 12 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => tasksProvider.toggleTask(task.id),
                      child: _checkItem(task.title, task.isCompleted),
                    ),
                  );
                }),
              if (tasks.length > 4) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyTasksScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View all ${tasks.length} tasks',
                      style: TextStyle(
                        color: AppColors.getPrimaryColor(isDarkMode),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _checkItem(String text, bool done) {
    final isDarkMode = context.watch<SettingsProvider>().darkMode;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.getPrimaryColor(isDarkMode)
                : Colors.transparent,
            border: done
                ? null
                : Border.all(
                    color: AppColors.getBorderColor(isDarkMode),
                    width: 2,
                  ),
          ),
          child: Icon(done ? Icons.check : null, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              decoration: done ? TextDecoration.lineThrough : null,
              color: done
                  ? AppColors.getTextSecondaryColor(isDarkMode)
                  : AppColors.getTextPrimaryColor(isDarkMode),
              fontWeight: done ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ================= CALENDAR POPUP =================
  void _showCalendarPopup() {
    final now = DateTime.now();
    int selectedMonth = now.month;
    int selectedYear = now.year;
    final isDarkMode = context.read<SettingsProvider>().darkMode;
    final cardColor = AppColors.getCardColor(isDarkMode);
    final borderColor = AppColors.getBorderColor(isDarkMode);
    final textPrimary = AppColors.getTextPrimaryColor(isDarkMode);
    final textSecondary = AppColors.getTextSecondaryColor(isDarkMode);
    final primaryColor = AppColors.getPrimaryColor(isDarkMode);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
            final lastDayOfMonth = DateTime(selectedYear, selectedMonth + 1, 0);
            final daysInMonth = lastDayOfMonth.day;
            final firstWeekday =
                firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month and Year Header (Gregorian)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: primaryColor),
                          onPressed: () {
                            setModalState(() {
                              if (selectedMonth == 1) {
                                selectedMonth = 12;
                                selectedYear--;
                              } else {
                                selectedMonth--;
                              }
                            });
                          },
                        ),
                        Column(
                          children: [
                            Text(
                              '${_getMonthName(selectedMonth)} $selectedYear',
                              style: TextStyle(
                                fontSize: Responsive.getFontSize(
                                  context,
                                  16,
                                  18,
                                  20,
                                ),
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<String>(
                              future: IslamicDateService.getIslamicDate(
                                DateTime(selectedYear, selectedMonth, 15),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  // Extract just the month and year from Islamic date
                                  final parts = snapshot.data!.split(' ');
                                  final monthYear = parts.length >= 3
                                      ? '${parts[1]} ${parts[2].replaceAll(',', '')}'
                                      : snapshot.data!;
                                  return Text(
                                    monthYear,
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        11,
                                        12,
                                        13,
                                      ),
                                      color: textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: primaryColor),
                          onPressed: () {
                            setModalState(() {
                              if (selectedMonth == 12) {
                                selectedMonth = 1;
                                selectedYear++;
                              } else {
                                selectedMonth++;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Weekday Headers
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.2,
                      children:
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                              .map(
                                (day) => Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        12,
                                        13,
                                        14,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 8),

                    // Calendar Days
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      children: [
                        // Empty cells before first day
                        ...List.generate(
                          firstWeekday - 1,
                          (index) => const SizedBox(),
                        ),
                        // Day cells
                        ...List.generate(daysInMonth, (index) {
                          final day = index + 1;
                          final isToday =
                              day == now.day &&
                              selectedMonth == now.month &&
                              selectedYear == now.year;
                          final date = DateTime(
                            selectedYear,
                            selectedMonth,
                            day,
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FutureBuilder<String>(
                                future: IslamicDateService.getIslamicDate(date),
                                builder: (context, snapshot) {
                                  String islamicDay = '';
                                  if (snapshot.hasData) {
                                    // Extract just the day number from Islamic date
                                    final parts = snapshot.data!.split(' ');
                                    islamicDay = parts.isNotEmpty
                                        ? parts[0]
                                        : '';
                                  }

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        day.toString(),
                                        style: TextStyle(
                                          fontSize: Responsive.getFontSize(
                                            context,
                                            13,
                                            14,
                                            15,
                                          ),
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isToday
                                              ? Colors.white
                                              : textPrimary,
                                        ),
                                      ),
                                      if (islamicDay.isNotEmpty)
                                        Text(
                                          islamicDay,
                                          style: TextStyle(
                                            fontSize: Responsive.getFontSize(
                                              context,
                                              9,
                                              10,
                                              11,
                                            ),
                                            color: isToday
                                                ? Colors.white.withOpacity(0.8)
                                                : textSecondary,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Today Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setModalState(() {
                            selectedMonth = now.month;
                            selectedYear = now.year;
                          });
                        },
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(
                              context,
                              13,
                              14,
                              15,
                            ),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Show Notifications Popup
  void _showNotificationsPopup() {
    final prayerProvider = context.read<PrayerProvider>();
    final isDarkMode = context.read<SettingsProvider>().darkMode;
    final cardColor = AppColors.getCardColor(isDarkMode);
    final borderColor = AppColors.getBorderColor(isDarkMode);
    final textPrimary = AppColors.getTextPrimaryColor(isDarkMode);
    final textSecondary = AppColors.getTextSecondaryColor(isDarkMode);
    final primaryColor = AppColors.getPrimaryColor(isDarkMode);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: primaryColor,
                        size: Responsive.getFontSize(context, 24, 26, 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prayer Alerts',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                18,
                                20,
                                22,
                              ),
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'Upcoming prayer reminders',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                11,
                                12,
                                13,
                              ),
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: borderColor),
                const SizedBox(height: 12),

                // Notifications List
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Next Prayer Alert
                      if (prayerProvider.nextPrayer != null)
                        _buildNotificationCard(
                          icon: Icons.access_time,
                          title: '${prayerProvider.nextPrayer!.name} Prayer',
                          subtitle:
                              'Upcoming at ${prayerProvider.nextPrayer!.displayTime}',
                          time: prayerProvider.countdown,
                          iconColor: primaryColor,
                          isDarkMode: isDarkMode,
                          isHighlighted: true,
                        ),

                      const SizedBox(height: 12),

                      // Today's Prayers Summary
                      _buildNotificationCard(
                        icon: Icons.calendar_today,
                        title: 'Today\'s Prayers',
                        subtitle:
                            '${prayerProvider.prayerTimes.length} prayers for today',
                        time: _gregorianDate,
                        iconColor: AppColors.getSecondaryColor(isDarkMode),
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 12),

                      // Islamic Date Notification
                      _buildNotificationCard(
                        icon: Icons.wb_twilight,
                        title: 'Islamic Calendar',
                        subtitle: _islamicDate,
                        time: 'Today',
                        iconColor: AppColors.getTertiaryColor(isDarkMode),
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 12),

                      // Location Notification
                      _buildNotificationCard(
                        icon: Icons.location_on,
                        title: 'Location',
                        subtitle: _location,
                        time: 'Active',
                        iconColor: AppColors.getSecondaryColor(isDarkMode),
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 12),

                      // App Info
                      _buildNotificationCard(
                        icon: Icons.info_outline,
                        title: 'Welcome to Islamify',
                        subtitle: 'Stay connected with your prayers',
                        time: 'v1.0.0',
                        iconColor: AppColors.getPrimaryColor(isDarkMode),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Settings Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to settings if needed
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'Notification Settings',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 13, 14, 15),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color iconColor,
    required bool isDarkMode,
    bool isHighlighted = false,
  }) {
    final cardColor = AppColors.getCardColor(isDarkMode);
    final borderColor = AppColors.getBorderColor(isDarkMode);
    final textPrimary = AppColors.getTextPrimaryColor(isDarkMode);
    final textSecondary = AppColors.getTextSecondaryColor(isDarkMode);
    final primaryColor = AppColors.getPrimaryColor(isDarkMode);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? primaryColor.withOpacity(0.08) : cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? primaryColor.withOpacity(0.3) : borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 13, 14, 15),
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 11, 12, 13),
                    color: textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 10, 11, 12),
              color: isHighlighted ? primaryColor : textSecondary,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // ================= COMMON CARD =================
  Widget _card(Widget child) {
    final isDarkMode = context.watch<SettingsProvider>().darkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
      ),
      child: child,
    );
  }
}
