import '../../../controller/notification_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationController controller = Get.put(NotificationController());

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    controller.notification("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: MyColors.white),
        backgroundColor: MyColors.primary,
        title: Text(
          "Notification".tr,
          style: TextStyle(
            fontSize: 20,
            color: MyColors.white,
            fontFamily: "Poppins",
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.notificationLoader.value) {
          return Center(
            child: myIndicator(),
          );
        } else if (controller.notificationList.length == 0)
          return Center(
            child: Text("No Notification".tr),
          );
        else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: controller.notificationList.length,
              itemBuilder: (context, index) {
                var reverseList = controller.notificationList.reversed.toList();
                var list = reverseList[index];
                return Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () {
                                  delete(list.id);
                                },
                                child: Icon(
                                  Icons.delete_outline,
                                  color: MyColors.black,
                                ),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              list.title == "New booking request".tr
                                  ? Icon(
                                      Icons.check_circle,
                                      size: 35,
                                      color: MyColors.primary,
                                    )
                                  : list.title == "Booking Cancellation".tr
                                      ? Icon(
                                          Icons.close,
                                          size: 35,
                                          color: Colors.red,
                                        )
                                      : list.title == "Booking Accepted".tr
                                          ? Icon(
                                              Icons.check_circle,
                                              size: 35,
                                              color: MyColors.buttonColor,
                                            )
                                          : list.title ==
                                                  "Driver is start ride".tr
                                              ? Icon(
                                                  Icons.check_circle,
                                                  size: 35,
                                                  color: MyColors.buttonColor,
                                                )
                                              : list.title ==
                                                      "Regarding Booking".tr
                                                  ? Icon(Icons.check_circle,
                                                      size: 35,
                                                      color: Color(0xff0CBB70))
                                                  : SizedBox(),
                              Expanded(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      list.title,
                                      maxLines: 1,
                                      softWrap: true,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      list.message,
                                      maxLines: 1,
                                      softWrap: true,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 12,
                                          color: Colors.black45),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                list.date,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black45),
                              )),
                        ],
                      ),
                    ));
              },
            ),
          );
        }
      }),
    );
  }

  void delete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Confirmation',style: TextStyle(
                fontSize: 14,
                color: MyColors.black,
                fontFamily: "Poppins",
              ),),
            ],
          ),
          content: Text('Are you sure you want to delete?',style: TextStyle(
            fontSize: 12,
            color: MyColors.black,
            fontFamily: "Poppins",
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: "Poppins",
              ),),
            ),
            Obx(() {
              if (controller.notificationDeleteLoader.value) {
                return Center(
                  child: myIndicator(),
                );
              } else {
                return TextButton(
                    onPressed: () {
                      controller.deleteNotification(id);
                    },
                    child: Text('Delete', style: TextStyle(color: Colors.red)));
              }
            })
          ],
        );
      },
    );
  }
}
