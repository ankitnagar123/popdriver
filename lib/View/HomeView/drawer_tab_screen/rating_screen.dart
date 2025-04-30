import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../../Model/rating_model.dart';
import '../../../controller/rating_controller.dart';
import '../../../utils/colors.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({Key? key}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  RatingController controller = Get.put(RatingController());

  @override
  void initState() {
    controller.rating();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: MyColors.primary,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        title:  Row(
          children: [
            Image.asset(
              'assets/images/headLogo.png',
              height: 28,
            ),  Image.asset(
              color: Colors.white,
              'assets/images/stearing.png',
              height: 37,
            ),

          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyColors.primary)),
          );
        } else {
          var list = controller.ratingList.value!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Center(
                    child: Text("Rate & Reviews".tr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,)),
                  ),
                  // Overall Rating Card
                  _buildOverallRating(list),
                  const SizedBox(height: 24),
                  // Rating Distribution
                  _buildRatingDistribution(list),
                  const SizedBox(height: 24),
                  // Reviews List
                  _buildReviewsHeader(),
                  const SizedBox(height: 16),
                  _buildReviewsList(list),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildOverallRating(list) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Overall Rating",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(list.totalRating,
                    style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: MyColors.primary)),

              ],
            ),
            const Spacer(),
            Column(
              children: [
                RatingBarIndicator(
                  rating: double.parse(list.totalRating),
                  itemBuilder: (context, index) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 32.0,
                ),
                const SizedBox(height: 8),

                Text("Based on ${controller.ratingList.value!.list.length} Rating",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rating Distribution",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildDistributionRow('Excellent', double.parse(list.rating5), Colors.green),
            _buildDistributionRow('Very Good', double.parse(list.rating4), Colors.lightGreen),
            _buildDistributionRow('Good', double.parse(list.rating3), Colors.orange),
            _buildDistributionRow('Average', double.parse(list.rating2), Colors.orangeAccent),
            _buildDistributionRow('Poor', double.parse(list.rating1), Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildDistributionRow(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Icon(Icons.star, size: 18, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) => AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    width: constraints.maxWidth * (pct / 100),
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${pct.toStringAsFixed(0)}',
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader() {
    return const Text("User Reviews",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
  }

  Widget _buildReviewsList(list) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),  // Disable inner scroll
    shrinkWrap: true,
      itemCount: list.list.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        var reverseList = list.list.reversed.toList();
        var review = reverseList[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(ListElement review) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    review.image,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        "${review.date} • ${review.time}",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Rating and Ride ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RatingBarIndicator(
                      rating: double.parse(review.rating),
                      itemBuilder: (context, index) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20,
                    ),
                    const SizedBox(height: 4),
                    Text("Ride ID: ${review.rateId}",
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
            // Feedback and Points
            if (review.feedback.isNotEmpty ||
                review.positivePointList.isNotEmpty ||
                review.negativePointList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 60, top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feedback Text
                    if (review.feedback.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MyColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          review.feedback,
                          style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87),
                        ),
                      ),
                    // Positive Points
                    if (review.positivePointList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: review.positivePointList.map((point) => Chip(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            label: Text(point.positivePoint,
                                style: const TextStyle(color: Colors.green)),
                            avatar: const Icon(Icons.check_circle,
                                size: 16,
                                color: Colors.green),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          )).toList(),
                        ),
                      ),
                    // Negative Points
                    if (review.negativePointList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: review.negativePointList.map((point) => Chip(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            label: Text(point.negativePoint,
                                style: const TextStyle(color: Colors.red)),
                            avatar: const Icon(Icons.cancel,
                                size: 16,
                                color: Colors.red),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          )).toList(),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }}