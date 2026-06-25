import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/controller/booking_controller.dart';
import 'package:mtaanidriver/controller/rating_controller.dart';
import 'package:mtaanidriver/utils/colors.dart';
import 'package:mtaanidriver/utils/snackBar.dart';

/// Shown after ride ends — driver rates the passenger.
class RatingScreen extends StatefulWidget {
  final String? userId;
  final String? bookigid;

  const RatingScreen({
    super.key,
    required this.userId,
    required this.bookigid,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _reviewController = TextEditingController();
  final RatingController ratingController = Get.put(RatingController());
  double _ratingValue = 0.0;
  late TabController _tabController;

  final Map<String, bool> _positivePointsForUser = {
    'Polite': false,
    'On-Time': false,
    'Respectful': false,
    'Clear Communication': false,
  };

  final Map<String, bool> _negativePointsForUser = {
    'Impolite': false,
    'Late': false,
    'No Show': false,
    'Poor Communication': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
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
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Get.find<BookingController>().rideNowBooking();
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            Expanded(
              child: Text(
                'Rate Passenger'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRatingCard(),
            const SizedBox(height: 16),
            _buildPointsCard(),
            const SizedBox(height: 16),
            _buildReviewField(),
            const SizedBox(height: 20),
            Obx(() {
              if (ratingController.addLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        color: MyColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit Rating'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        children: [
          Text(
            _ratingValue == 0
                ? 'How was your passenger?'.tr
                : '${_ratingValue.toInt()} ${'stars'.tr}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _ratingValue == 0 ? Colors.grey.shade600 : MyColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          RatingBar.builder(
            itemSize: 42,
            initialRating: _ratingValue,
            minRating: 1,
            maxRating: 5,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
            unratedColor: Colors.grey.shade300,
            itemBuilder: (context, _) => const Icon(
              Icons.star_rounded,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() => _ratingValue = rating);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
            labelColor: MyColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: MyColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Nice points'.tr),
              Tab(text: 'Negative Points'.tr),
            ],
          ),
          SizedBox(
            height: 130,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPointsList(_positivePointsForUser, isPositive: true),
                _buildPointsList(_negativePointsForUser, isPositive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsList(Map<String, bool> items, {required bool isPositive}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.entries.map((entry) {
          final selected = entry.value;
          final color = isPositive ? const Color(0xFF0CBB70) : Colors.red.shade600;
          return FilterChip(
            label: Text(entry.key),
            selected: selected,
            onSelected: (_) {
              setState(() => items[entry.key] = !selected);
            },
            selectedColor: color.withValues(alpha: 0.15),
            checkmarkColor: color,
            labelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: selected ? color : MyColors.DarkBlue,
            ),
            side: BorderSide(color: selected ? color : Colors.grey.shade300),
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewField() {
    return TextField(
      controller: _reviewController,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Write a short review (optional)'.tr,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MyColors.primary, width: 1.5),
        ),
      ),
    );
  }

  String _selectedCsv(Map<String, bool> items) {
    return items.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(', ');
  }

  void _submitReview() {
    if (_ratingValue == 0.0) {
      customSnackBar('Please provide rating'.tr);
      return;
    }

    ratingController.rateToUser(
      widget.bookigid.toString(),
      _ratingValue,
      _selectedCsv(_positivePointsForUser),
      _selectedCsv(_negativePointsForUser),
      _reviewController.text.trim(),
      context,
    );
  }
}
