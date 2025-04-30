// import '../../../controller/notification_controller.dart';
// import '../../../utils/colors.dart';
// import '../../../utils/custom_button.dart';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }
//
// class _NotificationScreenState extends State<NotificationScreen> {
//   NotificationController controller = Get.put(NotificationController());
//
//   @override
//   void initState() {
//     WidgetsFlutterBinding.ensureInitialized();
//     controller.notification("");
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: MyColors.white),
//         backgroundColor: MyColors.primary,
//         title: Text(
//           "Notification".tr,
//           style: TextStyle(
//             fontSize: 20,
//             color: MyColors.white,
//             fontFamily: "Poppins",
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Obx(() {
//         if (controller.notificationLoader.value) {
//           return Center(
//             child: myIndicator(),
//           );
//         } else if (controller.notificationList.length == 0)
//           return Center(
//             child: Text("No Notification".tr),
//           );
//         else {
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ListView.builder(
//               itemCount: controller.notificationList.length,
//               itemBuilder: (context, index) {
//                 var reverseList = controller.notificationList.reversed.toList();
//                 var list = reverseList[index];
//                 return Card(
//                     elevation: 3,
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Column(
//                         children: [
//                           Align(
//                               alignment: Alignment.topRight,
//                               child: InkWell(
//                                 onTap: () {
//                                   delete(list.id);
//                                 },
//                                 child: Icon(
//                                   Icons.delete_outline,
//                                   color: MyColors.black,
//                                 ),
//                               )),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               list.title == "New booking request".tr
//                                   ? Icon(
//                                       Icons.check_circle,
//                                       size: 35,
//                                       color: MyColors.primary,
//                                     )
//                                   : list.title == "Booking Cancellation".tr
//                                       ? Icon(
//                                           Icons.close,
//                                           size: 35,
//                                           color: Colors.red,
//                                         )
//                                       : list.title == "Booking Accepted".tr
//                                           ? Icon(
//                                               Icons.check_circle,
//                                               size: 35,
//                                               color: MyColors.buttonColor,
//                                             )
//                                           : list.title ==
//                                                   "Driver is start ride".tr
//                                               ? Icon(
//                                                   Icons.check_circle,
//                                                   size: 35,
//                                                   color: MyColors.buttonColor,
//                                                 )
//                                               : list.title ==
//                                                       "Regarding Booking".tr
//                                                   ? Icon(Icons.check_circle,
//                                                       size: 35,
//                                                       color: Color(0xff0CBB70))
//                                                   : SizedBox(),
//                               Expanded(
//                                   child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 5),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       list.title,
//                                       maxLines: 1,
//                                       softWrap: true,
//                                       style: TextStyle(
//                                           fontFamily: "Poppins",
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500),
//                                     ),
//                                     SizedBox(
//                                       height: 5,
//                                     ),
//                                     Text(
//                                       list.message,
//                                       maxLines: 1,
//                                       softWrap: true,
//                                       style: TextStyle(
//                                           fontFamily: "Poppins",
//                                           fontSize: 12,
//                                           color: Colors.black45),
//                                     ),
//                                   ],
//                                 ),
//                               )),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 10,
//                           ),
//                           Align(
//                               alignment: Alignment.bottomRight,
//                               child: Text(
//                                 list.date,
//                                 style: TextStyle(
//                                     fontSize: 10, color: Colors.black45),
//                               )),
//                         ],
//                       ),
//                     ));
//               },
//             ),
//           );
//         }
//       }),
//     );
//   }
//
//   void delete(String id) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.warning, color: Colors.red),
//               SizedBox(width: 10),
//               Text('Delete Confirmation',style: TextStyle(
//                 fontSize: 14,
//                 color: MyColors.black,
//                 fontFamily: "Poppins",
//               ),),
//             ],
//           ),
//           content: Text('Are you sure you want to delete?',style: TextStyle(
//             fontSize: 12,
//             color: MyColors.black,
//             fontFamily: "Poppins",
//           ),),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel', style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//                 fontFamily: "Poppins",
//               ),),
//             ),
//             Obx(() {
//               if (controller.notificationDeleteLoader.value) {
//                 return Center(
//                   child: myIndicator(),
//                 );
//               } else {
//                 return TextButton(
//                     onPressed: () {
//                       controller.deleteNotification(id);
//                     },
//                     child: Text('Delete', style: TextStyle(color: Colors.red)));
//               }
//             })
//           ],
//         );
//       },
//     );
//   }
// }
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
  final NotificationController controller = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    controller.notification("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: MyColors.white),
        backgroundColor: MyColors.primary,
        elevation: 4,
        shadowColor: MyColors.primary.withOpacity(0.2),
        title: Image.asset('assets/images/headLogo.png',height: 28,),/*Text(
          "Notification".tr,
          style: const TextStyle(
            fontSize: 20,
            color: MyColors.white,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
          ),
        ),*/
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5,),
            Text(
              "Notifications".tr,
              style: TextStyle(
                fontSize: 18,
                color: MyColors.black,
                fontFamily: "Poppins",
              ),
            ),

            Obx(() {
              if (controller.notificationLoader.value) {
                return Center(
                  child: myIndicator(),
                );
              } else if (controller.notificationList.isEmpty) {
                return _buildEmptyState();
              } else {
                return _buildNotificationList();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: MyColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No Notifications".tr,
            style: TextStyle(
              fontSize: 18,
              color: MyColors.black.withOpacity(0.5),
              fontFamily: "Poppins",
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll notify you when something arrives".tr,
            style: TextStyle(
              fontSize: 14,
              color: MyColors.black.withOpacity(0.4),
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    final reverseList = controller.notificationList.reversed.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: reverseList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = reverseList[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNotificationIcon(notification.title),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MyColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          color: MyColors.black.withOpacity(0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildDeleteButton(notification.id),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  notification.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: MyColors.black.withOpacity(0.5),
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String title) {
    IconData icon;
    Color color;

    switch (title) {
      case "New booking request":
        icon = Icons.notifications_active_outlined;
        color = MyColors.primary;
        break;
      case "Booking Cancellation":
        icon = Icons.cancel_outlined;
        color = Colors.red;
        break;
      case "Booking Accepted":
        icon = Icons.check_circle_outline;
        color = MyColors.buttonColor;
        break;
      case "Driver is start ride":
        icon = Icons.directions_car_filled_outlined;
        color = Color(0xff0CBB70);
        break;
      default:
        icon = Icons.notifications_outlined;
        color = MyColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28, color: color),
    );
  }

  Widget _buildDeleteButton(String id) {
    return InkWell(
      onTap: () => delete(id),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.delete_outline,
          color: MyColors.black.withOpacity(0.6),
          size: 24,
        ),
      ),
    );
  }

  void delete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
              const SizedBox(width: 12),
              Text(
                'Delete Notification'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: MyColors.black,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this notification?'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: MyColors.black,
              fontFamily: "Poppins",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel'.tr,
                style: TextStyle(
                  color: MyColors.black.withOpacity(0.7),
                  fontFamily: "Poppins",
                ),
              ),
            ),
            Obx(() {
              if (controller.notificationDeleteLoader.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return ElevatedButton(
                onPressed: () => controller.deleteNotification(id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Delete'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}