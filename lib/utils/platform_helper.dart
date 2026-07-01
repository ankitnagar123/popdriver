import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Safe platform checks for mobile + web (never uses `dart:io` [Platform]).
bool get isWeb => kIsWeb;

bool get isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool get isMobile => isAndroid || isIOS;
