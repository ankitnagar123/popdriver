import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/ride_now_booking_model.dart';
import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../route_helper/route_helper.dart';
import '../utils/colors.dart';

/// Rapido-style incoming booking card — shown on top of any screen.
class BookingIncomingPopup extends StatelessWidget {
  const BookingIncomingPopup({
    super.key,
    required this.booking,
  });

  final RideNowBookingModel booking;

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<BookingController>();

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_taxi, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'New ride request'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Text(
                              '#${booking.bookingId}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Offer \$ ${booking.userOfferPrice}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _chip(Icons.directions_car, booking.distance),
                            const SizedBox(width: 8),
                            _chip(Icons.access_time, booking.duration),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _locationRow(
                          icon: Icons.trip_origin,
                          color: Colors.green,
                          label: 'Pickup'.tr,
                          address: booking.sourceAdd,
                        ),
                        const SizedBox(height: 10),
                        _locationRow(
                          icon: Icons.flag,
                          color: MyColors.primary,
                          label: 'Drop'.tr,
                          address: booking.destinationAdd,
                        ),
                        const Spacer(),
                        Obx(() {
                          final accepting = bookingController
                                  .acceptBookLoader.value &&
                              bookingController.rideNowList.any(
                                (b) => b.bookingId == booking.bookingId,
                              );
                          final passing =
                              bookingController.cancelBookLoader.value;

                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: accepting
                                      ? null
                                      : () => _onAccept(context),
                                  child: accepting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Accept'.tr,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(color: Colors.grey.shade400),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: passing
                                      ? null
                                      : () => _onPass(context),
                                  child: Text(
                                    'Pass'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MyColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: MyColors.primary),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required Color color,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onAccept(BuildContext context) {
    final bookingController = Get.find<BookingController>();
    final idx = bookingController.rideNowList.indexWhere(
      (b) => b.bookingId == booking.bookingId,
    );
    Get.find<HomeController>().bookingIndex = idx >= 0 ? idx : 0;

    bookingController.acceptBooking(booking.bookingId, () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      Get.toNamed(RouteHelper.getReadyForRideScreenRoute());
    });
  }

  void _onPass(BuildContext context) {
    Get.find<BookingController>().cancelBooking(
      booking.bookingId,
      '',
      () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        Get.find<BookingController>().rideNowBooking();
      },
    );
  }
}
