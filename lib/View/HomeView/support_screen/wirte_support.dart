import '../../../controller/support_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../route_helper/route_helper.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';

class WriteSupport extends StatefulWidget {
  const WriteSupport({Key? key}) : super(key: key);

  @override
  State<WriteSupport> createState() => _WriteSupportState();
}

class _WriteSupportState extends State<WriteSupport> {

  SupportController controller = Get.put(SupportController());

  TextEditingController nameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController subCtr = TextEditingController();
  TextEditingController messageCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchQuery("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title:  Row(
          children: [
            Image.asset(
              'assets/images/headLogo.png',
              height: 28,
            ),  Image.asset(
              color: Colors.white,
              'assets/images/stearing.png',
              height: 35,
            ),

          ],
        ),
        centerTitle: true,

      ),
      body: Obx(() {
        if(controller.fetchQueryLoader.value){
          return Center(child: CircularProgressIndicator(),);
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(" Write Support".tr,
                  style: TextStyle(fontSize: 18, color: MyColors.black),),
              ),

              /* custom_textfield(
              labletext: "Full Name".tr,
              textEditingController: nameCtr,
              textInputType: TextInputType.text,
            ),*/
              custom_textfield(
                isEmail: true,
                labletext: "Email Address".tr,
                textEditingController: emailCtr,
                textInputType: TextInputType.text,
              ),
              custom_textfield(
                labletext: "Subject Line*".tr,
                textEditingController: subCtr,
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 15,),
              Text("Message*".tr),
              SizedBox(height: 10,),
              TextFormField(
                enableInteractiveSelection: false,
                toolbarOptions: ToolbarOptions(
                  copy: true,
                  cut: true,
                  paste: false,
                  selectAll: false,
                ),
                controller: messageCtr,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: MyColors.TextField,
                  hintText: "Write your Messages/Feedback/Enquiry".tr,
                  hintStyle: TextStyle(fontSize: 12,color: Colors.grey),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1, color: MyColors.TextField,),
                  ),

                ),
              ),
              SizedBox(height: 20,),
              Obx(() =>
              controller.writeSupportLoader.value ?
              Center(child: myIndicator(),) :
              custom_buttons(voidCallback: () {
                valid();
              }, text: "Submit".tr)),
              SizedBox(height: 20,),
              if(controller.fetchQueryList.length !=0 )
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(width: 1),
                  columnSpacing: 30,
                  columns: const [
                    DataColumn(label: Text('Complain No.'), numeric: false),
                    DataColumn(label: Text('Subject'), numeric: false),
                    DataColumn(label: Text('Time'), numeric: false),
                    DataColumn(label: Text('Status'), numeric: false),
                  ],
                  rows: List.generate(
                    controller.fetchQueryList.length,
                        (index) {
                      var data = controller.fetchQueryList[index];
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              /* width: Get.width/2,*/
                                child: Text(data.complainNumber.toString(),
                                  softWrap: true, maxLines: 2,)),
                          ),
                          DataCell(
                            Container(
                                width: Get.width / 2,
                                child: Text(
                                  data.subject.toString(), softWrap: true,
                                  maxLines: 2,)),
                          ),
                          DataCell(
                            Container(
                              /* width: Get.width/2,*/
                                child: Text(
                                  data.time.toString(), softWrap: true,
                                  maxLines: 2,)),
                          ),
                          DataCell(
                            Container(
                              /*  width: Get.width/2,*/
                                child: InkWell(
                                    onTap: () {
                                      if (data.status == "opened") {
                                        Get.toNamed(
                                            RouteHelper.getSingleQueryScreen(),
                                            arguments: {
                                              'status': data.status,
                                              "number": data.complainNumber
                                            });
                                      } else {
                                        Get.toNamed(
                                            RouteHelper.getSingleQueryScreen(),
                                            arguments: {
                                              'status': data.status,
                                              "number": data.complainNumber
                                            });
                                      }
                                    },
                                    child: Text(
                                      data.status.toString(), softWrap: true,
                                      maxLines: 2,
                                      style: TextStyle(
                                          color: data.status == "opened"
                                              ? Colors.green
                                              : Colors.red),))),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                  showBottomBorder: true,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> valid() async {
     if (emailCtr.text.isEmpty) {
      customSnackBar("Please Enter Email Address".tr);
    } else if (EmailValidator.validate(emailCtr.text.toString()) != true) {
      customSnackBar("Enter Valid Email Address".tr);
    } else if (subCtr.text.isEmpty) {
      customSnackBar("Please Write Subject".tr);
    } else if (messageCtr.text.isEmpty) {
      customSnackBar("Please Write Your Message".tr);
    } else {
      controller.writeSupport(context,emailCtr.text, subCtr.text, messageCtr.text);
      emailCtr.text = "";
      subCtr.text = "";
      messageCtr.text = "";
      setState(() {

      });
    }
  }

}
