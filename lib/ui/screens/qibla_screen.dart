import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/settings_provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _direction = 0; // heading (degrees)
  bool _compassAvailable = true;
  String _errorMessage = '';
  double _qiblaDirection = 0; // Qibla direction from north
  double _userLatitude = 0;
  double _userLongitude = 0;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
        _qiblaDirection = _calculateQiblaDirection(
          position.latitude,
          position.longitude,
        );
      });
    } catch (e) {
      // Use default location (Makkah) if location fails
      setState(() {
        _userLatitude = 21.422487; // Default to exact Kaaba location
        _userLongitude = 39.826206;
        _qiblaDirection = _calculateQiblaDirection(
          _userLatitude,
          _userLongitude,
        );
      });
    }
  }

  double _calculateQiblaDirection(double userLat, double userLon) {
    // Exact Kaaba coordinates (Holy Kaaba in Mecca)
    const double kaabaLat = 21.422487;
    const double kaabaLon = 39.826206;

    // Convert to radians
    double lat1 = userLat * math.pi / 180;
    double lon1 = userLon * math.pi / 180;
    double lat2 = kaabaLat * math.pi / 180;
    double lon2 = kaabaLon * math.pi / 180;

    double dLon = lon2 - lon1;

    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    bearing = bearing * 180 / math.pi;
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  void _initializeCompass() {
    try {
      FlutterCompass.events?.listen(
        (event) {
          if (event.heading != null && mounted) {
            setState(() {
              _direction = event.heading!;
              _compassAvailable = true;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _compassAvailable = false;
              _errorMessage = 'Compass not available on this device';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _compassAvailable = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDarkMode = settings.darkMode;
        final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
        final cardColor = AppColors.getCardColor(isDarkMode);
        final borderColor = AppColors.getBorderColor(isDarkMode);
        final textPrimary = AppColors.getTextPrimaryColor(isDarkMode);
        final textSecondary = AppColors.getTextSecondaryColor(isDarkMode);
        final primaryColor = AppColors.getPrimaryColor(isDarkMode);

        // Calculate rotation for compass (north arrow)
        double compassRotation = (_direction) * (math.pi / 180) * -1;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text('Qibla Direction'),
            backgroundColor: primaryColor,
            elevation: 0,
          ),
          body: !_compassAvailable
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.compass_calibration,
                        size: 64,
                        color: textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(
                        height: Responsive.getPadding(context, 16, 18, 20),
                      ),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 16, 18, 20),
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Compass Heading Display
                      Text(
                        'Current Heading',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 14, 16, 18),
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getPadding(context, 8, 10, 12),
                      ),
                      Text(
                        '${_direction.toStringAsFixed(1)}°',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 32, 36, 40),
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getPadding(context, 24, 28, 32),
                      ),

                      // Compass with rotation
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cardColor,
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Transform.rotate(
                              angle: compassRotation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Compass rose
                                  SizedBox(
                                    width: 280,
                                    height: 280,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Compass background circle
                                        Container(
                                          width: 280,
                                          height: 280,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: backgroundColor,
                                            border: Border.all(
                                              color: primaryColor.withOpacity(
                                                0.3,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        // North marker (static arrow pointing up)
                                        Positioned(
                                          top: 20,
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.arrow_upward,
                                                color: primaryColor,
                                                size: 28,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'N',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Qibla marker positioned based on qibla direction
                                        Positioned(
                                          top:
                                              140 -
                                              (120 *
                                                  math.cos(
                                                    _qiblaDirection *
                                                        math.pi /
                                                        180,
                                                  )),
                                          left:
                                              140 +
                                              (120 *
                                                  math.sin(
                                                    _qiblaDirection *
                                                        math.pi /
                                                        180,
                                                  )),
                                          child: Transform.rotate(
                                            angle:
                                                _qiblaDirection * math.pi / 180,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Arrow pointing to Qibla
                                                Icon(
                                                  Icons.arrow_upward,
                                                  color: Colors.green,
                                                  size: 32,
                                                ),
                                                const SizedBox(height: 4),
                                                // Kaaba icon at tail
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 4,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  child: Image.asset(
                                                    'assets/Icons/iQibla.png',
                                                    width: 32,
                                                    height: 32,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 20,
                                          child: Text(
                                            'E',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          child: Text(
                                            'S',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 20,
                                          child: Text(
                                            'W',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        // Center mosque icon
                                        Center(
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primaryColor,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryColor
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.mosque,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getPadding(context, 24, 28, 32),
                      ),

                      // Qibla Direction Display
                      Text(
                        'Qibla Direction: ${_qiblaDirection.toStringAsFixed(1)}°',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 14, 16, 18),
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getPadding(context, 16, 18, 20),
                      ),

                      // Information
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: Responsive.getPadding(
                            context,
                            16,
                            20,
                            24,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Hold your phone level and rotate it to find the Qibla direction',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        12,
                                        13,
                                        14,
                                      ),
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
