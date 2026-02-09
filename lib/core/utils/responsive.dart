import 'package:flutter/material.dart';

class Responsive {
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return getWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return getWidth(context) >= 600 && getWidth(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return getWidth(context) >= 1200;
  }

  // Responsive font sizes
  static double getFontSize(
    BuildContext context,
    double mobile,
    double tablet,
    double desktop,
  ) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // Responsive padding
  static double getPadding(
    BuildContext context,
    double mobile,
    double tablet,
    double desktop,
  ) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // Responsive grid count
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 4;
    if (isTablet(context)) return 6;
    return 8;
  }
}
