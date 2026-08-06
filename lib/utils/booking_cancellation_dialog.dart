import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors.dart';
import 'web_auth_layout.dart';

/// Global popup when passenger cancels an accepted/active booking.
class BookingCancellationDialog {
  static String? _lastShownBookingId;

  /// Driver self-cancel / local reset — ignore delayed FCM / poll popups (esp. iOS).
  static final Set<String> _suppressedByDriver = <String>{};
  static final Map<String, Timer> _suppressTimers = <String, Timer>{};

  static String extractBookingId(RemoteMessage message) {
    final dataId = message.data['booking_id']?.toString() ??
        message.data['bookingId']?.toString() ??
        message.data['bookingid']?.toString() ??
        message.data['meta_id']?.toString() ??
        message.data['ride_id']?.toString() ??
        message.data['id']?.toString() ??
        '';
    if (dataId.trim().isNotEmpty) return dataId.trim();

    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';
    final hashMatch = RegExp(r'#(\d+)').firstMatch(body);
    if (hashMatch != null) return hashMatch.group(1)!;

    final idMatch = RegExp(r'booking\s*#?\s*(\d+)', caseSensitive: false)
        .firstMatch(body);
    if (idMatch != null) return idMatch.group(1)!;

    return '';
  }

  /// Call after driver successfully cancels so late push/poll never re-opens UI.
  static void suppressForDriverCancel(
    String bookingId, {
    Duration ttl = const Duration(minutes: 2),
  }) {
    final id = bookingId.trim();
    if (id.isEmpty) return;
    _suppressedByDriver.add(id);
    _lastShownBookingId = id;
    _suppressTimers[id]?.cancel();
    _suppressTimers[id] = Timer(ttl, () {
      _suppressedByDriver.remove(id);
      _suppressTimers.remove(id);
    });
  }

  static bool isSuppressed(String bookingId) {
    final id = bookingId.trim();
    return id.isNotEmpty && _suppressedByDriver.contains(id);
  }

  static void show(String bookingId) {
    final id = bookingId.trim();
    if (id.isEmpty) return;

    // Driver already cancelled locally — skip FCM/poll "Booking Cancelled".
    if (_suppressedByDriver.contains(id)) return;

    // Avoid duplicate popup for the same cancellation burst.
    if (_lastShownBookingId == id) return;
    _lastShownBookingId = id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialogContext = Get.overlayContext ?? Get.context;
      if (dialogContext == null || !dialogContext.mounted) return;

      // Re-check after frame — suppress may have been set mid-flight.
      if (_suppressedByDriver.contains(id)) return;

      showDialog<void>(
        context: dialogContext,
        barrierDismissible: false,
        builder: (dialogCtx) => WebAuthLayout.dialog(
          context: dialogCtx,
          maxWidth: 400,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  color: Colors.red.shade600,
                  size: 52,
                ),
                const SizedBox(height: 16),
                Text(
                  'Booking Cancelled'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Booking #@id cancelled'.trParams({'id': id}),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: MyColors.DarkBlue.withOpacity(0.9),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Navigator.of(dialogCtx, rootNavigator: true)
                          .canPop()) {
                        Navigator.of(dialogCtx, rootNavigator: true).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  static void clearLastShown() {
    _lastShownBookingId = null;
  }

  /// Force-close any open dialogs (confirm / cancelled) — iOS-safe fallback.
  static void dismissOpenDialogs() {
    try {
      final ctx = Get.overlayContext ?? Get.context;
      if (ctx == null) return;
      final nav = Navigator.of(ctx, rootNavigator: true);
      var guard = 0;
      while (nav.canPop() && guard < 3) {
        // Only pop routes that are dialogs when possible.
        if (Get.isDialogOpen == true || Get.isOverlaysOpen) {
          nav.pop();
        } else {
          break;
        }
        guard++;
      }
    } catch (_) {
      /* ignore */
    }
  }
}
