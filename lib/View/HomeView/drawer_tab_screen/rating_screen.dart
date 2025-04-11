
import '../../../controller/auth_controller.dart';
import '../../../controller/rating_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';

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
      appBar:AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title: Text("Rate & Reviews".tr,
          style: TextStyle(fontSize: 20, color: MyColors.white),),
        centerTitle: true,

      ),

      body: Obx(() {
        if(controller.isLoading.value){
          return Center(child: myIndicator(),);
        }else{
          var list =  controller.ratingList.value!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(list.totalRating,
                      style: TextStyle(fontSize: 18),),
                    RatingBarIndicator(
                      rating: double.parse(list.totalRating),
                      itemBuilder: (context, index) =>
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                      itemCount: 5,
                      itemSize: 25.0,
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                chartRow(context, '5', double.parse(list.rating5),Colors.green),
                chartRow(context, '4', double.parse(list.rating4),Colors.green),
                chartRow(context, '3', double.parse(list.rating3),Colors.green),
                chartRow(context, '2', double.parse(list.rating2),Colors.green),
                chartRow(context, '1', double.parse(list.rating1),Colors.green),

                SizedBox(
                  height: 20,
                ),
              Expanded(
                  child: ListView.builder(
                    itemCount: list.list.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                      var reverseList = list.list.reversed.toList();
                      var lists = reverseList[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/loader.gif',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    image: lists.image,
                                    imageErrorBuilder: (c, o, s) => Image.asset(
                                      "assets/images/logo.png",
                                      fit: BoxFit.cover,
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(lists.userName),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                lists.date+", "+lists.time,
                                                style: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 12),
                                              ),
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      RatingBarIndicator(
                                                        rating: double.parse(lists.rating),
                                                        itemBuilder: (context, index) =>
                                                            Icon(
                                                              Icons.star,
                                                              color: Colors.amber,
                                                            ),
                                                        itemCount: 5,
                                                        itemSize: 15.0,
                                                        direction: Axis.horizontal,
                                                      ),
                                                      Text(lists.rating)
                                                    ],
                                                  ),
                                                  SizedBox(height: 2.0,),
                                                  Text("Ride ID: ${lists.rateId}".tr,
                                                    style: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize: 12),)
                                                ],
                                              )
                                            ],
                                          ),

                                        ],
                                      ),
                                    ))
                              ],
                            ),
                            SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.only(left: 60),
                              child: Container(
                                width: Get.width/1.5,
                                decoration: BoxDecoration(
                                ),
                                  child: Text(lists.feedback == ""?"":"' ${lists.feedback} '",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15),)),
                            ),
                            SizedBox(height: 10,)
                          ],
                        );
                      },))
              ],
            ),
          );
        }
      }),
    );
  }

  Widget chartRow(BuildContext context, String label, double pct, Color color) {
    return Row(
      children: [
        Text(label,),
        SizedBox(width: 8),
        Icon(Icons.star, color: Colors.green),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 10, 8, 0),
          child:Container(
            width: Get.width * 0.65,
            height: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey,
                value:pct/100,
                valueColor: AlwaysStoppedAnimation<Color>(color)),
              ),
            ),
          ),
        Text('${pct.toStringAsFixed(0)}',),
      ],
    );
  }

}
