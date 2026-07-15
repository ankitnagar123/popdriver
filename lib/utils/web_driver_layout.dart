import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Responsive layout helpers for driver home (web only — mobile unchanged).
class WebDriverLayout {
  WebDriverLayout._();

  static const double sidebarWidth = 272;
  static const double panelWidth = 420;
  static const double wideBreakpoint = 900;

  static bool isWeb(BuildContext context) => kIsWeb;

  static bool isWidePanel(BuildContext context) {
    if (!kIsWeb) return false;
    return MediaQuery.sizeOf(context).width >= wideBreakpoint;
  }

  /// Native app, or web on phone/tablet — bottom nav + full-width map.
  static bool isMobileLayout(BuildContext context) {
    if (!kIsWeb) return true;
    return MediaQuery.sizeOf(context).width < wideBreakpoint;
  }

  static double slideButtonWidth(BuildContext context) {
    if (!kIsWeb) return MediaQuery.sizeOf(context).width - 32;
    return panelWidth - 48;
  }
}
