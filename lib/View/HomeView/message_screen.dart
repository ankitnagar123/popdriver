import 'dart:async';
import '../../controller/booking_controller.dart';
import '../../controller/home_screen_controller.dart';
import '../../controller/message_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/polyline_handler.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';

class Messages extends StatefulWidget {
  Messages({
    Key? key,
  }) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();

  String ID = "";
  MessageController controller = Get.put(MessageController());
  TextEditingController messageCtr = TextEditingController();
  var isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    getData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.messageList.clear();
      _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        controller.chatFetch(Get.arguments['userId'].toString());
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primary,
        title: Text(
          'Message'.tr,
          style: TextStyle(
              color: MyColors.white, fontSize: 20, fontFamily: "Poppins"),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            if (_timer != null) {
              _timer.cancel();
            } else if (_timer != null) {
              _timer.isBlank;
            }
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: MyColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              height: 300,
              child: Obx(
                () {
                  if (controller.messageList.isEmpty) {
                    return SizedBox();
                  } else {
                    return isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: controller.messageList.length,
                            itemBuilder: (BuildContext context, int index) {
                              var reversedList =
                                  controller.messageList.reversed.toList();
                              return Padding(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      ID == reversedList[index].id
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              45),
                                      margin: EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: ID == reversedList[index].id
                                            ? MyColors.primary
                                            : MyColors.DarkBlue.withOpacity(0.3),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        reversedList[index].message.toString(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        cut: true,
                        paste: false,
                        selectAll: false,
                      ),
                      enableInteractiveSelection: false,
                      style: TextStyle(decorationThickness: 0),
                      controller: messageCtr,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        hintStyle:
                            TextStyle(fontSize: 13, fontFamily: "Poppins"),
                        hintText: 'Type your message'.tr,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    if (messageCtr.text.trim().isNotEmpty) {
                      controller.sendMessage(
                          Get.arguments['userId'].toString(), messageCtr.text,
                          () {
                        controller
                            .chatFetch(Get.arguments['userId'].toString());
                      });
                    } else {
                      print('failed');
                    }
                    messageCtr.clear();
                  },
                  child: CircleAvatar(
                      maxRadius: 25,
                      backgroundColor: MyColors.primary,
                      child: Center(
                          child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 22,
                      )) /*ElevatedButton(

                        onPressed: () {
                          if (messageCtr.text.trim().isNotEmpty) {
                            controller.sendMessage(
                              Get.arguments['userId'].toString(),
                              messageCtr.text,(){
                              controller.chatFetch(Get.arguments['userId'].toString());
                            }
                            );
                          } else {
                            print('failed');
                          }
                          messageCtr.clear();
                        },
                        child: ),*/
                      ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> getData() async {
    ID = (await secure.readData(secure.user_id)) ?? "";
    print("user ID------------>:${await secure.readData(secure.user_id)}");
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });
  }
}
