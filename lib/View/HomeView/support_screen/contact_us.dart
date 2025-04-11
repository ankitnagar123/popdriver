/*
import 'package:ColumbiaTaxi/route_helper/route_helper.dart';
import 'package:ColumbiaTaxi/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/colors.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: AppBar(
          backgroundColor: MyColors.primary,
          flexibleSpace: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: Get.height/7.5,
                    ),
                    Text(
                      "Contact Us".tr,
                      style: TextStyle(fontSize: 25, color: MyColors.white),
                    ),
                  ],
                ),
              )),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
        child: Column(
          children: [

            InkWell(
              onTap: (){

              },
              child: Container(
                height: 50,
                width: Get.width,
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.DarkBlue),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(child: Text("Write Support".tr,style: TextStyle(color: MyColors.black),),),
              ),
            )
          ],
        ),
      ),

    );
  }
}
*/
