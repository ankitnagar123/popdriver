import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../controller/my_ride_controller.dart';
class RideHistoryTab extends StatefulWidget {
  final startDate,endDate;
  const RideHistoryTab({super.key, this.startDate, this.endDate});

  @override
  State<RideHistoryTab> createState() => _RideHistoryTabState();
}

class _RideHistoryTabState extends State<RideHistoryTab> {
  int selectedTab = 0;
  MyRidesController controller = Get.find<MyRidesController>();

  final List<String> tabs = ["All", "Completed","Cancelled"];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            bool isSelected = selectedTab == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                    controller.rideHistory("", "", tabs[selectedTab],);
                  });
                },
                child: IntrinsicWidth(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.teal : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tabs[index],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: isSelected ? Colors.teal : Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );

  }
}
