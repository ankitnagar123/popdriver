import 'dart:developer';

import '../../controller/auth_controller.dart';

import '../../utils/colors.dart';
import '../../utils/custom_button.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../route_helper/route_helper.dart';
import '../../utils/snackBar.dart';

class MemberShipScreen extends StatefulWidget {
  String type = "";

  MemberShipScreen({super.key, required this.type});

  @override
  State<MemberShipScreen> createState() => _MemberShipScreenState();
}

class _MemberShipScreenState extends State<MemberShipScreen> {
  String membership = "";
  AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    controller.memberShip();
    membership = MyColors.MemberShipId;
    print("member ------${MyColors.MemberShipId}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              if (widget.type == "signup") {
                Get.offAllNamed(RouteHelper.getLoginScreenRoute());
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Icon(Icons.arrow_back, color: Colors.white)),
        backgroundColor: MyColors.primary,
        title: Text(
          "MemberShip".tr,
          style: TextStyle(
              fontSize: 20, color: MyColors.white, fontFamily: "Poppins"),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.memberShipLoader.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (controller.memberShipList.isEmpty) {
          return Center(
            child: Text("Plane not found".tr),
          );
        } else {
          return Column(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.separated(
                    itemCount: controller.memberShipList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {

                      final plan = controller.memberShipList[index];
                      final isSelected = membership == plan.membershipId;

                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff019ba5), Color(0xff017f91)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipOval(
                                    child: Image.asset(
                                  'assets/images/background.png',
                                  fit: BoxFit.contain,
                                  height: 40,
                                )),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: plan.membershipType == "Gold" ||
                                              plan.membershipType == "gold"
                                          ? Colors.orangeAccent
                                          : plan.membershipType == "Silver"
                                              ? Colors.grey.shade400
                                              : plan.membershipType == "Bronze"
                                                  ? Color(0xffCE8946)
                                                  : Colors.white24,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      plan.membershipType,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),

                            Text(
                              plan.name,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              plan.price == "0" ? "FREE" : " KSh ${plan.price}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),


                           /* Row(
                              children: [
                                Text(
                                  "Government Tax (VAT) : ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  plan.tax,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Service Fee : ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  plan.commission,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),*/
                            SizedBox(height: 5,),
                            Text(
                              plan.description,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected ? MyColors.black : Colors.white,
                                  foregroundColor: isSelected ? Colors.black87 : MyColors.primary,
                                    shape: StadiumBorder(),
                                  padding:  EdgeInsets.symmetric(
                                      horizontal: 10, vertical:isSelected?15:10),
                                  elevation: 5,
                                ),
                                onPressed: isSelected
                                    ? null // disable if selected
                                    : () {
                                  setState(() {

                                  });
                                  membership = plan.membershipId;

                                  log("membership---------------$membership");
                                  // You can also call any other method here if needed
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isSelected ? 'Selected ${plan.name}' : 'Choose ${plan.name}',
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color:  isSelected ? Colors.white:Colors.black87),
                                    ),
                                    Icon(Icons.check_circle,
                                      color: isSelected ?  Colors.white:MyColors.DarkBlue,size: isSelected ? 30:20, ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
/*
              Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.memberShipList.length,
                    itemBuilder: (context, index) {
                      var list = controller.memberShipList[index];
                      return Card(
                        child: RadioListTile<String>(
                          secondary: Image.asset('assets/images/background.png',fit: BoxFit.fill,height: 60,),
                          value: list.membershipId,
                          groupValue: membership,
                          onChanged: (value) {
                            setState(() {
                              membership = value!;
                              print(membership);
                            });
                          },
                          title: Text(
                            list.name,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 17,

                            ),
                          ),
                          subtitle: Column(
                            children: [
                              Text("Price : ${list.price}"),
                              Text("Price : ${list.description}"),
                            ],
                          ),

                        ),
                      );
                    },
                  ))
*/
            ],
          );
        }
      }),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: Obx(() {
          return custom_buttons(
              loading: controller.memberShipLoader1.value,
              voidCallback: () {
                  if(membership == ""){
                  customSnackBar("please select any plan".tr);
                }else{
                  controller.buyMemberShip(membership.toString(), widget.type,"Membership");
                }
              },
              text: "Submit".tr);
        }),
      ),
    );
  }
}

