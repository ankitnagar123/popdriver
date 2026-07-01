import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../controller/my_ride_controller.dart';
import '../route_helper/route_helper.dart';
import 'web_auth_layout.dart';

/// Shared logout / delete-account dialogs for menu and web sidebar.
class DriverMenuActions {
  DriverMenuActions._();

  static void showLogoutDialog(BuildContext context) {
    final auth = Get.find<AuthController>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return WebAuthLayout.dialog(
          context: context,
          maxWidth: 400,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirmation'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to logout?'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  if (auth.logoutLoader.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text('Cancel'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                          ),
                          onPressed: () async {
                            await auth.driverLogout('', () {
                              Future.delayed(Duration.zero, () {
                                Get.find<HomeController>()
                                    .streamSubscription
                                    .cancel();
                              });
                              Get.find<HomeController>().updateDriverLatLong(
                                '0',
                                '0',
                                '0',
                                'UnAvailable',
                              );
                              Get.offAllNamed(
                                RouteHelper.getLoginScreenRoute(),
                              );
                            });
                          },
                          child: Text(
                            'Logout'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showDeleteAccountDialog(BuildContext context) {
    final auth = Get.find<AuthController>();
    final booking = Get.find<BookingController>();
    final canDelete = booking.deleteId.value.isEmpty &&
        Get.find<MyRidesController>().rideLaterScreenList.isEmpty;
    final dialogTitle = canDelete
        ? 'Are you sure you want to delete account?'.tr
        : 'You cannot delete your account because you have an active booking'
            .tr;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WebAuthLayout.dialog(
        context: context,
        maxWidth: 440,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                canDelete ? Icons.warning_amber_rounded : Icons.error_outline,
                color: canDelete ? Colors.orange : Colors.red,
                size: 44,
              ),
              const SizedBox(height: 16),
              Text(
                dialogTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (auth.deleteLoader.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text('Cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              canDelete ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          if (canDelete) {
                            auth.deleteAccount();
                          } else {
                            Navigator.pop(dialogContext);
                          }
                        },
                        child: Text(
                          'Confirm'.tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
