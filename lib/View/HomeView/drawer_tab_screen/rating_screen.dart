import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../../Model/rating_model.dart';
import '../../../controller/rating_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';

/// Drawer — driver ratings & reviews (fetch list).
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final RatingController controller = Get.put(RatingController());

  @override
  void initState() {
    super.initState();
    controller.rating();
  }

  double _safeDouble(String value) => double.tryParse(value.trim()) ?? 0;

  Future<void> _refresh() async {
    await controller.refreshRatings();
    var attempts = 0;
    while (controller.isLoading.value && attempts < 60) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          'Rate & Reviews'.tr,
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
        if (controller.isLoading.value && controller.ratingList.value == null) {
          return Center(child: myIndicator());
        }

        final data = controller.ratingList.value;
        if (data == null) {
          return _buildEmptyBody();
        }

        return RefreshIndicator(
          color: MyColors.primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildOverallCard(data),
              const SizedBox(height: 16),
              _buildDistributionCard(data),
              const SizedBox(height: 16),
              _buildReviewsHeader(data.list.length),
              const SizedBox(height: 10),
              if (data.list.isEmpty)
                _buildNoReviews()
              else
                ...data.list.reversed.map(_buildReviewCard),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyBody() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
        Icon(Icons.star_border_rounded, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          'No ratings yet'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallCard(RatingModel list) {
    final avg = _safeDouble(list.totalRating);
    final count = list.list.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF017A82),
            Color(0xFF019BA5),
            Color(0xFF02B3BE),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Rating'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                '${'Based on'.tr} $count ${'ratings'.tr}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const Spacer(),
          RatingBarIndicator(
            rating: avg.clamp(0, 5),
            itemBuilder: (_, __) =>
                const Icon(Icons.star_rounded, color: Colors.amber),
            itemCount: 5,
            itemSize: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(RatingModel list) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Distribution'.tr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          _buildDistributionRow('Excellent', _safeDouble(list.rating5), Colors.green),
          _buildDistributionRow('Very Good', _safeDouble(list.rating4), Colors.lightGreen),
          _buildDistributionRow('Good', _safeDouble(list.rating3), Colors.orange),
          _buildDistributionRow('Average', _safeDouble(list.rating2), Colors.orangeAccent),
          _buildDistributionRow('Poor', _safeDouble(list.rating1), Colors.red),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(String label, double pct, Color color) {
    final clamped = pct.clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label.tr,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: clamped / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '${clamped.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader(int count) {
    return Row(
      children: [
        Text(
          'User Reviews'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: MyColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: MyColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoReviews() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        'No user reviews yet'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildReviewCard(ListElement review) {
    final stars = _safeDouble(review.rating);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: review.image.trim().isNotEmpty
                    ? NetworkImage(review.image.trim())
                    : null,
                child: review.image.trim().isEmpty
                    ? const Icon(Icons.person, color: MyColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${review.date} • ${review.time}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RatingBarIndicator(
                    rating: stars.clamp(0, 5),
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star_rounded, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${review.rateId}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (review.feedback.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MyColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                review.feedback,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade800,
                  fontFamily: 'Poppins',
                  height: 1.35,
                ),
              ),
            ),
          ],
          if (review.positivePointList.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: review.positivePointList
                  .map(
                    (p) => _tagChip(
                      p.positivePoint,
                      Colors.green.shade700,
                      Colors.green.shade50,
                      Icons.thumb_up_alt_outlined,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (review.negativePointList.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: review.negativePointList
                  .map(
                    (p) => _tagChip(
                      p.negativePoint,
                      Colors.red.shade700,
                      Colors.red.shade50,
                      Icons.thumb_down_alt_outlined,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tagChip(
    String label,
    Color textColor,
    Color bgColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
