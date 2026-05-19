import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mtaanidriver/Model/driver_ride_history_model.dart';

import '../../../../controller/my_ride_controller.dart';
import '../../../../route_helper/route_helper.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/custom_button.dart';
import '../my_ride_screen.dart' show showErrorDialog;

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  final MyRidesController controller = Get.find<MyRidesController>();

  static const List<String> _filters = ['All', 'Completed', 'Cancelled'];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    controller.rideHistory('', '', 'All');
    controller.driverTotalBooking();
  }

  Future<void> _refresh() async {
    controller.driverTotalBooking();
    controller.rideHistory(
      _dateOrEmpty(controller.HistoryStartDate.value),
      _dateOrEmpty(controller.HistoryEndDate.value),
      _filters[_selectedFilter],
    );
    var attempts = 0;
    while ((controller.historyLoader.value || controller.rideLoader.value) &&
        attempts < 60) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  void _applyFilter(int index) {
    setState(() => _selectedFilter = index);
    controller.rideHistory(
      _dateOrEmpty(controller.HistoryStartDate.value),
      _dateOrEmpty(controller.HistoryEndDate.value),
      _filters[index],
    );
  }

  String _dateOrEmpty(String value) =>
      value == 'Select' || value.isEmpty ? '' : value;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 72;

    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: MyColors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF02B3BE),
                Color(0xFF019BA5),
                Color(0xFF017A82),
              ],
            ),
          ),
        ),
        title: Text(
          'Ride History'.tr,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
   
      ),
      body: Obx(() {
        final statsLoading =
            controller.rideLoader.value && controller.totalBooking.value.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderSection(statsLoading),
            _buildFilterChips(),
            _buildDateFilters(),
            const SizedBox(height: 8),
            Expanded(
              child: _buildHistoryBody(bottomInset),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderSection(bool statsLoading) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF017A82),
            Color(0xFF019BA5),
            Color(0xFF02B3BE),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: MyColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: statsLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          : Row(
              children: [
                _buildStatTile(
                  icon: Icons.directions_car_rounded,
                  label: 'Total Rides'.tr,
                  value: controller.displayTotalRides,
                ),
                const SizedBox(width: 8),
                _buildStatTile(
                  icon: Icons.payments_rounded,
                  label: 'Earnings'.tr,
                  value: '\$ ${controller.displayTotalEarnings}',
                ),
              ],
            ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            final selected = _selectedFilter == index;
            return Padding(
              padding: EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
              child: FilterChip(
                label: Text(_filters[index].tr),
                selected: selected,
                onSelected: (_) => _applyFilter(index),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                selectedColor: MyColors.primary.withValues(alpha: 0.15),
                checkmarkColor: MyColors.primary,
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? MyColors.primary : MyColors.DarkBlue,
                ),
                side: BorderSide(
                  color: selected ? MyColors.primary : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDateFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDatePickerField(
                  label: 'From'.tr,
                  value: controller.HistoryStartDate.value,
                  onTap: () => _handleDatePicker(0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDatePickerField(
                  label: 'To'.tr,
                  value: controller.HistoryEndDate.value,
                  onTap: () => _handleDatePicker(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  text: 'Submit'.tr,
                  onPressed: () => controller.rideHistory(
                    _dateOrEmpty(controller.HistoryStartDate.value),
                    _dateOrEmpty(controller.HistoryEndDate.value),
                    _filters[_selectedFilter],
                  ),
                  isLoading: controller.historyLoader.value,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFilterButton(
                  text: 'Reset'.tr,
                  onPressed: () {
                    controller.HistoryEndDate.value = 'Select';
                    controller.HistoryStartDate.value = 'Select';
                    setState(() => _selectedFilter = 0);
                    controller.rideHistory('', '', 'All');
                  },
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryBody(double bottomInset) {
    if (controller.historyLoader.value && controller.historyList.isEmpty) {
      return Center(child: myIndicator());
    }

    if (controller.historyList.isEmpty) {
      return _buildEmptyState(bottomInset);
    }

    final rides = controller.historyList.reversed.toList();

    return RefreshIndicator(
      color: MyColors.primary,
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset),
        itemCount: rides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildRideCard(rides[index]),
      ),
    );
  }

  Widget _buildEmptyState(double bottomInset) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomInset),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
        Icon(Icons.history_toggle_off_rounded,
            size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'No ride history found'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try changing the date range or filter'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildRideCard(DriverRideHistoryModel ride) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _handleRideTap(ride),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${ride.bookingId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MyColors.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ride.carTypeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    _buildStatusChip(ride.status),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${ride.rideDate} • ${ride.rideTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.payments_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      ride.paymentMode,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildLocationRow(
                  icon: Icons.trip_origin,
                  address: ride.sourceAdd,
                  color: Colors.green,
                  label: 'Pickup'.tr,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Container(
                    height: 20,
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
                _buildLocationRow(
                  icon: Icons.place_rounded,
                  address: ride.destinationAdd,
                  color: MyColors.primary,
                  label: 'Drop'.tr,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildMetaChip(
                      icon: Icons.route_outlined,
                      text: '${ride.distance} km',
                    ),
                    const SizedBox(width: 8),
                    _buildMetaChip(
                      icon: Icons.schedule_outlined,
                      text: ride.duration,
                    ),
                    const Spacer(),
                    Text(
                      '\$ ${ride.totalPrice}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Get.toNamed(
                      RouteHelper.getReportScreenRout(),
                      arguments: {'id': ride.bookingId},
                    ),
                    icon: const Icon(Icons.flag_outlined, size: 12),
                    label: Text(
                      'Report Issue'.tr,
                      style: const TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: MyColors.primary,
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      backgroundColor:
                          MyColors.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final normalized = status.toLowerCase();
    Color bgColor;
    Color textColor;
    IconData icon;

    if (normalized.contains('complete')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle_outline;
    } else if (normalized.contains('cancel')) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.cancel_outlined;
    } else {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.tr,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String address,
    required Color color,
    required String label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleDatePicker(int status) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: MyColors.primary,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: MyColors.primary),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null) return;

    final formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
    setState(() {
      if (status == 0) {
        controller.HistoryStartDate.value = formattedDate;
      } else {
        controller.HistoryEndDate.value = formattedDate;
        if (controller.HistoryStartDate.value != 'Select') {
          final format = DateFormat('dd-MM-yyyy');
          final start = format.parse(controller.HistoryStartDate.value);
          final end = format.parse(formattedDate);
          if (start.isAfter(end)) {
            showErrorDialog(
              'Invalid date range: Start date must be before end date'.tr,
              context,
            );
          }
        }
      }
    });
  }

  Widget _buildDatePickerField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isPlaceholder = value == 'Select' || value.isEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 16, color: MyColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isPlaceholder ? label : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isPlaceholder ? Colors.grey : Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    Color? color,
  }) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? MyColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minimumSize: const Size(0, 34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }

  void _handleRideTap(DriverRideHistoryModel ride) {
    controller.fetchDriverBookingDetails(ride.bookingId, () {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildRideDetailsSheet(),
      );
    });
  }

  Widget _buildRideDetailsSheet() {
    return Obx(() {
      if (controller.fetchBookLoader.value || controller.bookingDetailsModel == null) {
        return Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Center(child: myIndicator()),
        );
      }

      final details = controller.bookingDetailsModel!;

      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ride Details'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: MyColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Vehicle Type'.tr, details.carTypeName),
                _buildDetailRow('Date'.tr, '${details.rideDate} ${details.rideTime}'),
                _buildDetailRow('Ride ID'.tr, details.bookingId),
                _buildDetailRow('Total Cost'.tr, '\$ ${details.totalPrice}'),
                _buildDetailRow('Payment Mode'.tr, details.paymentMode),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: details.image.trim().isNotEmpty
                          ? NetworkImage(details.image.trim())
                          : null,
                      child: details.image.trim().isEmpty
                          ? const Icon(Icons.person, color: MyColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        details.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLocationRow(
                  icon: Icons.trip_origin,
                  address: details.sourceAdd,
                  color: Colors.green,
                  label: 'Pickup'.tr,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Container(
                    height: 20,
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
                _buildLocationRow(
                  icon: Icons.place_rounded,
                  address: details.destinationAdd,
                  color: MyColors.primary,
                  label: 'Drop'.tr,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('${details.distance} km', 'Distance'.tr),
                    _buildStatItem(details.duration, 'Duration'.tr),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close'.tr,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
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
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.black87,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
