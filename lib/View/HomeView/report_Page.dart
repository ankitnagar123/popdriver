import 'dart:developer';
import 'dart:io';
import '../../controller/booking_controller.dart';
import '../../controller/home_screen_controller.dart';
import '../../controller/painic_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/polyline_handler.dart';
import '../../utils/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

import '../../route_helper/route_helper.dart';
import '../../utils/text_field.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {

  TextEditingController titleCtr = TextEditingController();
  TextEditingController complainCtr = TextEditingController();

  PainButtonController controller = Get.put(PainButtonController());

  String id = "";

  @override
  void initState() {
    id = Get.arguments["id"];
    controller.fetchComp("",Get.arguments["id"]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
Get.back();
            },
            child: Icon(Icons.arrow_back_outlined,color: Colors.white,)),
        centerTitle: true,
        backgroundColor: MyColors.primary,
        title: Text(
          "Driver Complaints".tr, style: TextStyle(color: MyColors.white,fontSize: 18),),
      ),
      body: Obx(() {
        if(controller.fetchComLoader.value){
          return Center(child: CircularProgressIndicator(),);
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                custom_textfield(
                  labletext: "Title..".tr,
                  textEditingController: titleCtr,
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: 20,),
                Text("Complaint".tr),
                SizedBox(height: 5,),
                TextFormField(
                  enableInteractiveSelection: false,
                  toolbarOptions: ToolbarOptions(
                    copy: true,
                    cut: true,
                    paste: false,
                    selectAll: false,
                  ),
                  controller: complainCtr,
                  keyboardType: TextInputType.multiline,
                  maxLines: 7,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
                  decoration: InputDecoration(

                    filled: true,
                    fillColor: MyColors.TextField,
                    hintText: "Describe your complaint".tr,
                    hintStyle: TextStyle(fontSize: 12),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1, color: MyColors.TextField,),
                    ),

                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        takePhoto(ImageSource.gallery);
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: MyColors.primary
                            ),
                            borderRadius: BorderRadius.circular(5),
                            color: MyColors.primary
                        ),
                        child: Center(
                          child: Text("Upload Image".tr, style: TextStyle(
                              color: MyColors.white, fontSize: 12),),
                        ),
                      ),
                    ),
                    SizedBox(width: 15,),
                    Expanded(child: Text(controller.imageName.value))
                  ],
                ),
                SizedBox(height: 25,),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 30),
                    child: Obx(() =>
                    controller.reportLoader.value ?
                    myIndicator() : custom_buttons(voidCallback: () {
                      submit();
                    }, text: "Submit".tr),)
                ),
                if(controller.fetchComplanList.length != 0 )
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(width: 1),
                      columnSpacing: 30,
                      columns: const [
                        DataColumn(label: Text('Complain No.'), numeric: false),
                        DataColumn(label: Text('Title'), numeric: false),
                        DataColumn(label: Text('Time'), numeric: false),
                        DataColumn(label: Text('Image'), numeric: false),
                        DataColumn(label: Text('Status'), numeric: false),
                      ],
                      rows: List.generate(
                        controller.fetchComplanList.length,
                            (index) {
                          var data = controller.fetchComplanList[index];
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
                                InkWell(
                                     onTap:(){
                                     Navigator.push(context, MaterialPageRoute(builder: (_) {
                                     return DetailScreen(image: data.image,);
                                     }));
                                     },
                                  child: Container(
                                    /* width: Get.width/2,*/
                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/loader.gif',
                                        image: data.image,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        imageErrorBuilder: (c, o, s) =>
                                            Image.asset(
                                              width: 80,
                                              height: 80,
                                              "assets/images/logo.png",
                                              fit: BoxFit.cover,
                                            ),
                                      )),
                                ),
                              ),
                              DataCell(
                                Container(
                                  /*  width: Get.width/2,*/
                                    child: InkWell(
                                        onTap: () {
                                          if (data.status == "opened") {
                                            Get.toNamed(
                                                RouteHelper
                                                    .getSingleQueryComScreen(),
                                                arguments: {
                                                  'status': data.status,
                                                  "number": data.complainNumber,
                                                  "booking" : id
                                                });
                                          } else {
                                            Get.toNamed(
                                                RouteHelper
                                                    .getSingleQueryScreen(),
                                                arguments: {
                                                  'status': data.status,
                                                  "number": data.complainNumber
                                                });
                                          }
                                        },
                                        child: Text(
                                          data.status.toString(),
                                          softWrap: true,
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
          ),
        );
      }),
    );
  }

  final ImagePicker picker = ImagePicker();

  void takePhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 60);
    print("picked file ----->$pickedFile");
    if (pickedFile != null) {
      controller.imageString.value = File(pickedFile.path);
      controller.imageName.value = pickedFile.name;
      controller.imageName.value =
          'image_' + new DateTime.now().millisecondsSinceEpoch.toString() +
              '_.jpg';
      ;
      log('image path---------->:${controller.imageString.value}');
      log('image name---------->:${controller.imageName.value}');
      setState(() {});
    } else {
      print('No image selected.');
    }
  }

  Future<void> submit() async {
    if (titleCtr.text.isEmpty) {
      customSnackBar("Please fill Title".tr);
    } else if (complainCtr.text.isEmpty) {
      customSnackBar("Please fill Complain".tr);
    } else if (controller.imageString.value == null) {
      customSnackBar("Please Select Image".tr);
    } else {
      controller.report(Get.arguments["id"], titleCtr.text, complainCtr.text,
          controller.imageString.value);
    }
  }

}

class DetailScreen extends StatefulWidget {
  String image = "";
  DetailScreen({super.key,required this.image});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
          width: double.infinity,
          child: PhotoView(
            imageProvider: NetworkImage(widget.image),
            minScale: PhotoViewComputedScale.contained * 1,
            maxScale: PhotoViewComputedScale.covered * 1,
            enableRotation: false,
            initialScale: PhotoViewComputedScale.contained * 1,

          )
      ),
    );

    /* DoubleTappableInteractiveViewer(
        scaleDuration: const Duration(milliseconds: 600),
    child: Image.network(controller.Image.value,height: double.infinity,width: double.infinity,));*/
  }
}
