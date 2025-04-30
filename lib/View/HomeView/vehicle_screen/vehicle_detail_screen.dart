import 'dart:developer';
import 'dart:io';
import 'package:mtaanidriver/View/AuthScreen/login_screen.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/support_controller.dart';
import '../../../controller/vehicle_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import '../membership_view/membership_screen.dart';

class VehicleDetail extends StatefulWidget {
  const VehicleDetail({Key? key}) : super(key: key);

  @override
  State<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends State<VehicleDetail> {
  VehicleController controller = Get.put(VehicleController());
  AuthController controllers = Get.find<AuthController>();

  TextEditingController vehicleNameCtr = TextEditingController();
  TextEditingController vehicleNumberCtr = TextEditingController();
  TextEditingController vehicleYear = TextEditingController();
  TextEditingController vehicleColour = TextEditingController();
  TextEditingController fitnessDateCtr = TextEditingController();
  TextEditingController LicenceDateCtr = TextEditingController();
  TextEditingController registrationDateCtr = TextEditingController();
  TextEditingController InsuranceDateCtr = TextEditingController();
  TextEditingController idProofImageExpiry = TextEditingController();

  FilePickerResult? result;
  String fitnessFileName = "";
  File? fitnessDisplayFile;
  String fitnessType = "";
  String LicenceFileName = "";
  File? LicenceDisplayFile;
  String LicenceType = "";
  String registrationFileName = "";
  File? registrationDisplayFile;
  String registrationType = "";
  String InsuranceFileName = "";
  File? InsuranceDisplayFile;
  String InsuranceType = "";
  String IdProofImageName = "";
  File? IdProofImageDisplayFile;
  String IdProofImageType = "";

  String carId = "";

  @override
  void initState() {
    carId = Get.arguments["carId"];
    print("carId ==== $carId");
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
        backgroundColor: MyColors.primary,
        title: Text("Vehicle Details".tr,style: TextStyle(
            fontFamily: "Poppins",
            color: MyColors.white,
            fontSize: 15),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              custom_textfield(
                manditory: "*",
                labletext: "Vehicle Make".tr,
                textEditingController: vehicleNameCtr,
                textInputType: TextInputType.text,
              ),
              custom_textfield(
                manditory: "*",
                labletext: "Vehicle Model".tr,
                textEditingController: vehicleNumberCtr,
                textInputType: TextInputType.text,
              ),
              custom_textfield(
                isEmail: true,
                manditory: "*",
                labletext: "Vehicle Year".tr,
                textEditingController: vehicleYear,
                textInputType: TextInputType.number,
              ),
              custom_textfield(
                manditory: "*",
                labletext: "Vehicle Colour".tr,
                textEditingController: vehicleColour,
                textInputType: TextInputType.text,
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  controller.status.value = "0";
                  filePicker();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 20,
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  decoration: BoxDecoration(
                    color: MyColors.TextField,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("Choose Fitness".tr),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              fitnessDisplayFile == null
                  ? SizedBox.shrink()
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: fitnessDisplayFile == null ||
                            fitnessType == "pdf" ||
                            fitnessType == "docx"
                            ? Image.asset(
                          "assets/images/pdf.png",
                          fit: BoxFit.fill,
                          height: 50,
                        )
                            : Image.file(
                          fitnessDisplayFile!,
                          fit: BoxFit.fill,
                          height: 50,
                        ),
                      ),
                    ),
                    title: Text(
                      "$fitnessFileName",
                      style: TextStyle(fontSize: 18),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      size: 30,
                      color: Color(0xff0CBB70),
                    ),
                  ),
                ),
              ),
              fitnessDisplayFile == null
                  ? SizedBox.shrink()
                  :InkWell(
                onTap: (){
                  controller.status.value = "0";
                  datePicker();
                },
                child: IgnorePointer(
                  child: custom_textfield(
                    manditory: "*",
                    labletext: "Fitness Expiry Date".tr,
                    textInputType: TextInputType.datetime,
                    textEditingController: fitnessDateCtr,
                    icon: Icon(
                      Icons.date_range,
                      color: MyColors.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 15,
              ),
              Divider(color: Colors.grey.shade300,),
              fitnessDisplayFile == null
                  ? SizedBox.shrink()
                  :InkWell(
                onTap: () {
                  controller.status.value = "1";
                  filePicker();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 20,
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  decoration: BoxDecoration(
                    color: MyColors.TextField,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("Choose driving  Licence".tr),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              LicenceDisplayFile == null
                  ? SizedBox.shrink()
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: LicenceDisplayFile == null ||
                            LicenceType == "pdf" ||
                            LicenceType == "docx"
                            ? Image.asset(
                          "assets/images/pdf.png",
                          fit: BoxFit.fill,
                          height: 50,
                        )
                            : Image.file(
                          LicenceDisplayFile!,
                          fit: BoxFit.fill,
                          height: 50,
                        ),
                      ),
                    ),
                    title: Text(
                      "$LicenceFileName",
                      style: TextStyle(fontSize: 18),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      size: 30,
                      color: Color(0xff0CBB70),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              LicenceDisplayFile == null
              ? SizedBox.shrink()
              : InkWell(
                onTap: (){
                  controller.status.value = "1";
                  datePicker();
                },
                child: IgnorePointer(
                  child: custom_textfield(
                    manditory: "*",
                    labletext: "Licence Expiry Date".tr,
                    textInputType: TextInputType.datetime,
                    textEditingController: LicenceDateCtr,
                    icon: Icon(
                      Icons.date_range,
                      color: MyColors.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 15,
              ),
              LicenceDisplayFile == null
                  ? SizedBox.shrink()
                   :InkWell(
                onTap: () {
                  controller.status.value = "2";
                  filePicker();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 20,
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  decoration: BoxDecoration(
                    color: MyColors.TextField,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("Choose Registration".tr),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              registrationDisplayFile == null
                  ? SizedBox.shrink()
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: registrationDisplayFile == null ||
                            registrationType == "pdf" ||
                            registrationType == "docx"
                            ? Image.asset(
                          "assets/images/pdf.png",
                          fit: BoxFit.fill,
                          height: 50,
                        )
                            : Image.file(
                          registrationDisplayFile!,
                          fit: BoxFit.fill,
                          height: 50,
                        ),
                      ),
                    ),
                    title: Text(
                      "$registrationFileName",
                      style: TextStyle(fontSize: 18),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      size: 30,
                      color: Color(0xff0CBB70),
                    ),
                  ),
                ),
              ),
              registrationDisplayFile == null
                  ? SizedBox.shrink()
                  : InkWell(
                onTap: (){
                  controller.status.value = "2";
                  datePicker();
                },
                child: IgnorePointer(
                  child: custom_textfield(
                    manditory: "*",
                    labletext: "Registration Expiry Date".tr,
                    textInputType: TextInputType.datetime,
                    textEditingController: registrationDateCtr,
                    icon: Icon(
                      Icons.date_range,
                      color: MyColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              registrationDisplayFile == null
                  ? SizedBox.shrink()
                  :InkWell(
                onTap: () {
                  controller.status.value = "3";
                  filePicker();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 20,
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  decoration: BoxDecoration(
                    color: MyColors.TextField,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("Choose Insurance".tr),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              InsuranceDisplayFile == null
                  ? SizedBox.shrink()
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: InsuranceDisplayFile == null ||
                            InsuranceType == "pdf" ||
                            InsuranceType == "docx"
                            ? Image.asset(
                          "assets/images/pdf.png",
                          fit: BoxFit.fill,
                          height: 50,
                        )
                            : Image.file(
                          InsuranceDisplayFile!,
                          fit: BoxFit.fill,
                          height: 50,
                        ),
                      ),
                    ),
                    title: Text(
                      "$InsuranceFileName",
                      style: TextStyle(fontSize: 18),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      size: 30,
                      color: Color(0xff0CBB70),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              InsuranceDisplayFile == null
                  ? SizedBox.shrink()
                  : InkWell(
                onTap: (){
                  controller.status.value = "3";
                  datePicker();
                },
                child: IgnorePointer(
                  child: custom_textfield(
                    manditory: "*",
                    labletext: "Insurance Expiry Date".tr,
                    textInputType: TextInputType.datetime,
                    textEditingController: InsuranceDateCtr,
                    icon: Icon(
                      Icons.date_range,
                      color: MyColors.primary,
                    ),
                  ),
                ),
              ),




              SizedBox(height: 15,),
              InsuranceDisplayFile == null
                  ? SizedBox.shrink()
                  :InkWell(
                onTap: () {
                  controller.status.value = "4";
                  filePicker();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 20,
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  decoration: BoxDecoration(
                    color: MyColors.TextField,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("Choose ID Proof Image".tr),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              IdProofImageDisplayFile == null
                  ? SizedBox.shrink()
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: IdProofImageDisplayFile == null ||
                            IdProofImageType == "pdf" ||
                            IdProofImageType == "docx"
                            ? Image.asset(
                          "assets/images/pdf.png",
                          fit: BoxFit.fill,
                          height: 50,
                        )
                            : Image.file(
                          IdProofImageDisplayFile!,
                          fit: BoxFit.fill,
                          height: 50,
                        ),
                      ),
                    ),
                    title: Text(
                      "$IdProofImageName",
                      style: TextStyle(fontSize: 18),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      size: 30,
                      color: Color(0xff0CBB70),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              IdProofImageDisplayFile == null
                  ? SizedBox.shrink()
                  : InkWell(
                onTap: (){
                  controller.status.value = "4";
                  datePicker();
                },
                child: IgnorePointer(
                  child: custom_textfield(
                    manditory: "*",
                    labletext: "Id Proof Expiry Date".tr,
                    textInputType: TextInputType.datetime,
                    textEditingController: idProofImageExpiry,
                    icon: Icon(
                      Icons.date_range,
                      color: MyColors.primary,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Obx((){
            if(controllers.signUpLoader.value || controllers.otpLoader.value){
              return Center(child: myIndicator(),);
            }else {
              return custom_buttons(
              voidCallback: () {
                if (valid() == true) {
                  controllers.signupOtp( "", () async {
                    var result =  await Get.toNamed(RouteHelper.getSignupOTPScreen());
                    if(result == "back"){
                      controllers.driverSignUp(
                          carId,
                          vehicleNameCtr.text,
                          vehicleNumberCtr.text,
                          LicenceDateCtr.text,
                          LicenceDisplayFile,
                          fitnessDisplayFile,
                          fitnessDateCtr.text,
                          registrationDisplayFile,
                          registrationDateCtr.text,
                          InsuranceDisplayFile,
                          InsuranceDateCtr.text,
                          vehicleYear.text,
                          vehicleColour.text,
                          IdProofImageDisplayFile,
                          idProofImageExpiry.text,
                              () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>MemberShipScreen(type: 'signup',)));
                            /* showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        content: Text("Vehicle Added Successfully. Once the Details are verified by our Mtaani Driver"
                            "driver Support Team. We will contact you & get you onboarded.".tr),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Get.offAllNamed(RouteHelper.getLoginScreenRoute());
                              },
                              child: Text(
                                "Ok".tr,
                                style: TextStyle(color: Colors.blue),
                              ))
                        ],
                      ),
                    );*/
                          });
                    }
                  });

                }
              },
              text: "Next".tr,
            );
            }}
          )),
    );
  }

  datePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2100),

        builder: (context,child) =>  Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: MyColors.primary,
                onPrimary: MyColors.white,
                onSurface: MyColors.DarkBlue,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  backgroundColor: MyColors.white, // button text color
                ),
              ),
            ),
            child: child!)

    );

    if (pickedDate != null) {
      print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      print(formattedDate); //formatted date output using intl package =>  2021-03-16
      setState(() {
        if(controller.status.value == "0"){
          fitnessDateCtr.text = formattedDate;
        }else if(controller.status.value == "1"){
          LicenceDateCtr.text = formattedDate;
        }else if(controller.status.value == "2"){
          registrationDateCtr.text = formattedDate;
        }else if(controller.status.value == "3"){
          InsuranceDateCtr.text = formattedDate;
        }else if(controller.status.value == "4"){
          idProofImageExpiry.text = formattedDate;
        }
        //set output date to TextField value.
      });
    } else {}
  }

  /*void filePicker() async {
    print('status------------${ controller.status.value}');
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
        allowMultiple: false, // 2MB in bytes
      );
      if (result != null && controller.status.value == "0") {
        fitnessFileName = result!.files.first.name;
        fitnessDisplayFile = File(result!.files.single.path.toString());
        log("RcDisplayFile---------" + fitnessDisplayFile.toString());
        fitnessType = result!.files.first.extension.toString();
      }else if(result != null && controller.status.value == "1"){
        LicenceFileName = result!.files.first.name;
        LicenceDisplayFile = File(result!.files.single.path.toString());
        log("LicenceDisplayFile---------" + LicenceDisplayFile.toString());
        LicenceType = result!.files.first.extension.toString();
        log("lctype---------" + LicenceType.toString());
      }else if(result != null && controller.status.value == "2"){
        registrationFileName = result!.files.first.name;
        registrationDisplayFile = File(result!.files.single.path.toString());
        log("registrationDisplayFile---------" + registrationDisplayFile.toString());
        registrationType = result!.files.first.extension.toString();
      }else if(result != null && controller.status.value == "3"){
        InsuranceFileName = result!.files.first.name;
        InsuranceDisplayFile = File(result!.files.single.path.toString());
        InsuranceType = result!.files.first.extension.toString();
      }else if(result != null && controller.status.value == "4"){
        IdProofImageName = result!.files.first.name;
        IdProofImageDisplayFile = File(result!.files.single.path.toString());
        IdProofImageType = result!.files.first.extension.toString();
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }*/

  void filePicker() async {
    print('status------------${controller.status.value}');
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result!.files.single.path!);
        int maxSizeBytes = 2 * 1024 * 1024; // 2MB in bytes
        int fileSize = await file.length();

        // Check if file size exceeds the limit
        if (fileSize <= maxSizeBytes) {
          switch (controller.status.value) {
            case "0":
              fitnessFileName = result!.files.first.name;
              fitnessDisplayFile = file;
              fitnessType = result!.files.first.extension!;
              break;
            case "1":
              LicenceFileName = result!.files.first.name;
              LicenceDisplayFile = file;
              LicenceType = result!.files.first.extension!;
              break;
            case "2":
              registrationFileName = result!.files.first.name;
              registrationDisplayFile = file;
              registrationType = result!.files.first.extension!;
              break;
            case "3":
              InsuranceFileName = result!.files.first.name;
              InsuranceDisplayFile = file;
              InsuranceType = result!.files.first.extension!;
              break;
            case "4":
              IdProofImageName = result!.files.first.name;
              IdProofImageDisplayFile = file;
              IdProofImageType = result!.files.first.extension!;
              break;
            default:
              break;
          }
          setState(() {});
        } else {
          // File size exceeds the limit, notify the user
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('File size exceeds 2MB limit.'),
          ));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  bool valid() {
    if (vehicleNameCtr.text.isEmpty) {
      customSnackBar("Please Enter Vehicle Make".tr);
    } else if (vehicleNumberCtr.text.isEmpty) {
      customSnackBar("Please Enter Vehicle Model".tr);
    } else if (vehicleYear.text.isEmpty) {
      customSnackBar("Please Enter Vehicle Year".tr);
    }else if (vehicleColour.text.isEmpty) {
      customSnackBar("Please Enter Vehicle Colour".tr);
    }else if (fitnessDisplayFile == null) {
      customSnackBar("Please Choose Fitness Image".tr);
    } else if (fitnessDateCtr.text.isEmpty) {
      customSnackBar("Please Enter Fitness Expiry Date".tr);
    }  else if (LicenceDisplayFile == null) {
      customSnackBar("Please Choose Licence Image".tr);
    }  else if (LicenceDateCtr.text.isEmpty) {
      customSnackBar("Please Enter Licence Expiry Date".tr);
    }  else if (registrationDisplayFile == null) {
      customSnackBar("Please Choose Registration Image".tr);
    }else if(registrationDateCtr.text.isEmpty){
      customSnackBar("Please Enter Registration Expiry Date".tr);
    } else if (InsuranceDisplayFile == null) {
      customSnackBar("Please Choose Insurance Image".tr);
    }else if(InsuranceDateCtr.text.isEmpty){
      customSnackBar("Please Enter Insurance Expiry Date".tr);
    } else if (IdProofImageDisplayFile == null) {
      customSnackBar("Please Choose IDProof Image".tr);
    }else if(idProofImageExpiry.text.isEmpty){
      customSnackBar("Please Enter Id Expiry Date".tr);
    }
    else {
      return true;
    }
    return false;
  }
}
