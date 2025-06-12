import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/controller/rating_controller.dart';
import 'package:mtaanidriver/utils/colors.dart';
import 'package:mtaanidriver/utils/snackBar.dart';


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
  double _ratingValue = 0.0;
  late TabController _tabController;

  RatingController ratingController = RatingController();

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColors.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Center(
              child: Text(
                "Rating & Review".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Rating Bar
            RatingBar.builder(
              itemSize: 45.0,
              initialRating: 0,
              minRating: 0,
              maxRating: 5.0,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
              const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                _ratingValue = rating;
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              dividerColor: Colors.black54,
              labelStyle: TextStyle(fontFamily: "Poppins"),
              tabs: [
                Tab(text: 'Nice points'.tr.toUpperCase()),
                Tab(text: 'Negative Points'.tr.toUpperCase()),
              ],
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black26,
              indicatorColor: MyColors.primary,
            ),
            SizedBox(height: 20,),
            SizedBox(
              height: 120, // Fixed height for the tab content
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPointsList(_positivePointsForUser),
                  _buildPointsList(_negativePointsForUser),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Review Text Field
            TextField(
              controller: _reviewController,
              keyboardType: TextInputType.text,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300)
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300)
                ),
                hintText: "Review".tr,
                hintStyle: const TextStyle(color: Colors.black54),

              ),),
            SizedBox(height: 20,),
            // Submit Button
            Obx(() {
              if(ratingController.addLoading.value){
                return CupertinoActivityIndicator();
              }
              return ElevatedButton(
                onPressed: () {
                  _submitReview();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  backgroundColor: MyColors.primary,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 100),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
                child: Text(
                  "Submit".tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              );
            }),
          ],
        ),
      ),

    );
  }

  Widget _buildPointsList(Map<String, bool> items) {
    return Wrap(
      spacing: 8.0, // horizontal spacing between items
      runSpacing: 8.0, // vertical spacing between lines
      children: items.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;

        return GestureDetector(
          onTap: () {
            setState(() {
              items[key] = !value;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: value ? MyColors.primary.withOpacity(0.2) : Colors
                  .grey[200],
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: value ? MyColors.primary : Colors.grey[300]!,
              ),
            ),
            child: Text(
              key,
              style: TextStyle(
                  color: value ? MyColors.primary : Colors.black,
                  fontFamily: "Poppins"
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String getSelectedItems(Map<String, bool> items) {
    return items.entries
        .where((entry) => entry.value) // Filter only selected items
        .map((entry) => entry.key) // Get only the keys (text)
        .join(', '); // Join with comma separator
  }

  void _submitReview() {
    if (_ratingValue == 0.0) {
      customSnackBar("Please provide rating".tr);
      return;
    }


    final positiveSelected = getSelectedItems(_positivePointsForUser);
    final negativeSelected = getSelectedItems(_negativePointsForUser);

    if (positiveSelected.isNotEmpty) {
      print("Nice points: $positiveSelected");
    }
    if (negativeSelected.isNotEmpty) {
      print("Negative points: $negativeSelected");
    }

    ratingController.rateToUser(
        widget.bookigid.toString(), _ratingValue, positiveSelected,
        negativeSelected, context);
  }
}
