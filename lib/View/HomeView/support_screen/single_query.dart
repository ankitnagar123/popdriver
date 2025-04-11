import 'dart:async';

import '../../../controller/auth_controller.dart';
import '../../../controller/support_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../utils/shared_preferences.dart';
import '../../../utils/snackBar.dart';

class FetchSingleQuery extends StatefulWidget {
  const FetchSingleQuery({super.key});

  @override
  State<FetchSingleQuery> createState() => _FetchSingleQueryState();
}

class _FetchSingleQueryState extends State<FetchSingleQuery> {

  SupportController controller = Get.put(SupportController());
  TextEditingController messageCtr = TextEditingController();

  String status = "";
  String complainNumber = "";
  String loader = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    controller.fetchSingleQuery(Get.arguments['number'],loader);
    status = Get.arguments['status'];
    complainNumber = Get.arguments['number'];

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      loader = "second";
      controller.fetchSingleQuery(complainNumber,loader);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text("Subject", style: TextStyle(color: MyColors.white),),
        centerTitle: true,
        backgroundColor: MyColors.primary,
      ),
      body: Obx(() {
        if (controller.fetchSingleQueryLoader.value) {
          return Center(child: CircularProgressIndicator(),);
        }else if(controller.fetchSingleQueryList.length == 0){
          return Center(child: Text("No Reply Found"),);
        } else {
          return Column(
            children: [
              Expanded(
                  flex: 2,
                  child: ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: controller.fetchSingleQueryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var reversedList = controller.fetchSingleQueryList;
                      return Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment:
                          reversedList[index].role == "customer"
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
                                color: reversedList[index].role == "customer"
                                    ? MyColors.primary
                                    : Colors.grey,
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
                  )),
              SizedBox(height: 20,),
              status == "opened"?
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: custom_buttons(voidCallback: () {
                    dialogueBox(context, complainNumber);
                  },
                      text: "Reply",
                     )
              ):SizedBox.shrink(),
              status == "opened"?
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                child: Obx(() {
                  if (controller.closeQueryLoader.value) {
                    return Center(child: CircularProgressIndicator(),);
                  } else {
                    return custom_button(voidCallback: () {
                      controller.closeTicket(complainNumber);
                    },
                        text: "Close Ticket",
                       );
                  }
                }),
              ):SizedBox.shrink()
            ],
          );
        }
      }),
    );
  }

  SharedPreferencesCrDriver   sp = SharedPreferencesCrDriver();
  String ID = "";
/*  Future<void> getData() async {
    ID = (await sp.getStringValue(sp.USER_ID.toString()))??"";
    setState(() {

    });
  }*/

  void dialogueBox(BuildContext context,String complain) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations
          .of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 2.2,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 20),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(alignment: Alignment.topRight,
                              child: IconButton(onPressed: () {
                                Navigator.of(context).pop();
                              }, icon: Icon(Icons.clear, color: Colors.black,)),
                            ),
                            Text("Write your message",
                              style: TextStyle(fontSize: 18),),
                            SizedBox(height: 8.0,),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  toolbarOptions: ToolbarOptions(
                                    copy: true,
                                    cut: true,
                                    paste: false,
                                    selectAll: false,
                                  ),
                                  enableInteractiveSelection: false,
                                  maxLines: 4,
                                  style: TextStyle(color: Colors.black,
                                      decoration: TextDecoration.none),
                                  keyboardType: TextInputType.text,
                                  controller: messageCtr,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))
                                  ],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "write your message",
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15,),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0),
                              child: Obx(() {
                                if(controller.replyLoader.value){
                                  return Center(child: CircularProgressIndicator(),);
                                }else{
                                  return custom_button(voidCallback: () {
                                    if(messageCtr.text.isEmpty){
                                      customSnackBar("please write your message");
                                    }else{
                                      controller.replyThread(complain, messageCtr.text);
                                      messageCtr.text = "";
                                    }
                                  },
                                      text: "Submit",
                                     );
                                }
                              }
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
