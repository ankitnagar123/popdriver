import 'dart:developer';
import 'dart:io';

import '../../../controller/auth_controller.dart';
import '../../../controller/profile_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_number/phone_number.dart';
import 'package:photo_view/photo_view.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/vehicle_controller.dart';
import '../../../Model/vehicle_fetch_model.dart';
import '../../../utils/colors.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final controller = Get.put(ProfileController());
  VehicleController controllers = Get.put(VehicleController());
  AuthController authController = Get.find<AuthController>();

  TextEditingController firstNameCtr = TextEditingController();
  TextEditingController identityNoCtr = TextEditingController();
  TextEditingController lastNameCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController currentPassCtr = TextEditingController();
  TextEditingController newPassCtr = TextEditingController();
  TextEditingController reNewPassCtr = TextEditingController();
  TextEditingController vehicleNameCtr = TextEditingController();
  TextEditingController vehicleNumberCtr = TextEditingController();
  TextEditingController vehicleYear = TextEditingController();
  TextEditingController vehicleColour = TextEditingController();
  TextEditingController fitnessDateCtr = TextEditingController();
  TextEditingController LicenceDateCtr = TextEditingController();
  TextEditingController registrationDateCtr = TextEditingController();
  TextEditingController InsuranceDateCtr = TextEditingController();
  TextEditingController idExpiry = TextEditingController();
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
  String type = "";

  String countryCode = "";
  String CountryFlag = "";
  bool isVisible = true;
  bool isHide = true;
  bool isHides = true;

  var companyValue = null;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.fetchDriverDetail();
      controllers.fetchVehicle();
      /* authController.fetchTaxiCompany();*/
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.resultVar.value == 1) {
        controller.resultVar.value = 0;
        identityNoCtr.text = controller.identityNo.value;
        firstNameCtr.text = controller.Name.value;
        lastNameCtr.text = controller.lastName.value;
        phoneCtr.text = controller.Contact.value;
        emailCtr.text = controller.Email.value;
        countryCode = controller.CountryCode.value;
        CountryFlag = controller.flags.value;
        fitnessDateCtr.text = controller.fitnessExpiry.value;
        LicenceDateCtr.text = controller.licenceDate.value;
        idExpiry.text = controller.IdProofExpiry.value;
        registrationDateCtr.text = controller.registrationDate.value;
        InsuranceDateCtr.text = controller.insuranceDate.value;
        vehicleNameCtr.text = controller.vehiclemake.value;
        vehicleNumberCtr.text = controller.vehicleModel.value;
        vehicleYear.text = controller.year.value;
        vehicleColour.text = controller.color.value;

        controllers.selectedCarId.value = controller.carId.value;

        companyValue = controller.vehicleModel.value;
        log('id date------>${idExpiry.text}');
      }
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: MyColors.white
          ),
          backgroundColor: MyColors.primary,
          title:   Row(
            children: [
              Image.asset(
                'assets/images/headLogo.png',
                height: 28,
              ),  Image.asset(
                color: Colors.white,
                'assets/images/stearing.png',
                height: 37,
              ),

            ],
          ),
          centerTitle: true,

        ),

        body: controller.fetchDetailLoader.value
            ? Center(
                child: myIndicator(),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text("Edit Profile".tr,
                        style: TextStyle(fontSize: 18, color: MyColors.black,fontFamily: "Poppins"),),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: custom_textfield(
                            manditory: "*",
                            labletext: "First Name".tr,
                            textInputType: TextInputType.text,
                            textEditingController: firstNameCtr,
                          ),
                        ),
                        SizedBox(width: 8,),
                        Expanded(
                          child: custom_textfield(
                            manditory: "*",
                            labletext: "Last Name".tr,
                            textInputType: TextInputType.text,
                            textEditingController: lastNameCtr,
                          ),
                        ),
                      ],
                    ),
                  
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Column(
                        children: [
                          Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                children: [
                                  Text(
                                    'Enter Mobile No.'.tr,
                                    style: TextStyle(color: MyColors.DarkBlue),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "*",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              )),
                          Container(
                            height: 50,
                            width: context.width,
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.only(left: 10,top: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: MyColors.TextField),
                            child: IntlPhoneField(
                              flagsButtonMargin: EdgeInsets.only(bottom: 8),
                              enabled: false,
                              style: TextStyle(
                                color: MyColors.DarkBlue
                              ),
                              controller: phoneCtr,
                              textInputAction: TextInputAction.next,
                              showDropdownIcon: false,
                              autovalidateMode: AutovalidateMode.disabled,
                              initialCountryCode:
                                  CountryFlag == "" ? 'CO' : CountryFlag,
                              decoration: InputDecoration(
                                  counterText: "",
                                  hintStyle: TextStyle(
                                      color: MyColors.DarkBlue, fontSize: 12),
                                  hintText: 'Enter Mobile No.'.tr,
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none),
                              onChanged: (phone) {
                                countryCode = phone.countryCode;
                                CountryFlag = phone.countryISOCode;
                                print(countryCode);
                              },
                              onCountryChanged: (country) {
                                countryCode = '${country.dialCode}';
                                CountryFlag = country.code;
                                print(countryCode);
                                print("-------" + CountryFlag);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    custom_textfield(
                      readOnly: true,
                      manditory: "*",
                      labletext: "Email Address".tr,
                      textInputType: TextInputType.text,
                      textEditingController: emailCtr,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    custom_textfield(
                      manditory: "*",
                      labletext: "Vehicle Number".tr,
                      textEditingController: vehicleNumberCtr,
                      textInputType: TextInputType.text,
                    ), custom_textfield(
                      readOnly: true,
                      manditory: "*",
                      labletext: "Identity Number".tr,
                      textEditingController: identityNoCtr,
                      textInputType: TextInputType.text,
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    _buildCarListDropdown(controllers),



                    /*custom_textfield(
                      manditory: "*",
                      labletext: "Vehicle Model".tr,
                      textEditingController: vehicleNumberCtr,
                      textInputType: TextInputType.text,
                    ),
                    *//*SizedBox(
                height: 10,
              ),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      color: MyColors.TextField),
                  child: Obx(
                        () => authController.companyLoader.value
                        ? Center(
                      child: myIndicator(),
                    )
                        : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: MyColors.primary,
                        hint: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Company',
                            style: TextStyle(
                                color: MyColors.DarkBlue, fontSize: 12),
                          ),
                        ),
                        value: companyValue == ""?null:companyValue,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 25,
                        ),
                        isExpanded: true,
                        items: authController.companyList.map(
                              (value) {
                            return DropdownMenuItem<String>(
                              value: value.companyId,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  value.companyName,
                                  style: TextStyle(color: MyColors.black),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(
                                () {
                              companyValue = value;
                              print("companyValue===>$companyValue");
                            },
                          );
                        },
                      ),
                    ),
                  )),*//*
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
                        controllers.status.value = "0";
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
                    Padding(
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
                              child: fitnessDisplayFile == null
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (_) {
                                          return DetailScreen(
                                            file: fitnessDisplayFile,
                                            image: controller.fitnessImage.value,

                                          );
                                        }));
                                      },
                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/loader.gif',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        image: '${controller.fitnessImage.value}',
                                        imageErrorBuilder: (c, o, s){
                                          return Image.asset("assets/images/pdf.png",
                                              height: 50, fit: BoxFit.fill);
                                        }
                                      ),
                                    )
                                  : fitnessType == "pdf" ||
                                          fitnessType == "docx"
                                      ? Image.asset("assets/images/pdf.png",
                                          height: 50, fit: BoxFit.fill)
                                      : InkWell(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (_) {
                                              return DetailScreen(
                                                file: fitnessDisplayFile,
                                                image: controller
                                                    .fitnessImage.value,
                                              );
                                            }));
                                          },
                                          child: Image.file(
                                            fitnessDisplayFile!,
                                            fit: BoxFit.fill,
                                            height: 50,
                                          ),
                                        ),
                            ),
                          ),
                          title: Text(
                            "Fitness",
                            style: TextStyle(fontSize: 18),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.check_circle,
                            size: 30,
                            color: controller.fitnessImage.value.isEmpty
                                ? Colors.grey
                                : Color(0xff0CBB70),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controllers.status.value = "0";
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
                    InkWell(
                      onTap: () {
                        controllers.status.value = "1";
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
                    Padding(
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
                              child: LicenceDisplayFile == null
                                  ? InkWell(
                                   onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return DetailScreen(
                                          file: LicenceDisplayFile,
                                          image:
                                          controller.licenceImage.value,
                                        );
                                      }));
                                },
                                    child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/loader.gif',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        image: '${controller.licenceImage.value}',
                                        imageErrorBuilder: (c, o, s) =>
                                            Image.asset("assets/images/pdf.png",
                                                height: 50, fit: BoxFit.fill),
                                      ),
                                  )
                                  : LicenceType == "pdf" ||
                                          LicenceType == "docx"
                                      ? Image.asset("assets/images/pdf.png",
                                          height: 50, fit: BoxFit.fill)
                                      : InkWell(
                                      onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return DetailScreen(
                                          file: LicenceDisplayFile,
                                          image:
                                          controller.licenceImage.value,
                                        );
                                      }));
                                },
                                        child: Image.file(
                                            LicenceDisplayFile!,
                                            fit: BoxFit.fill,
                                            height: 50,
                                          ),
                                      ),
                            ),
                          ),
                          title: Text(
                            "Licence".tr,
                            style: TextStyle(fontSize: 18),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.check_circle,
                            size: 30,
                            color: controller.licenceImage.value.isEmpty
                                ? Colors.grey
                                : Color(0xff0CBB70),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        controllers.status.value = "1";
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
                    InkWell(
                      onTap: () {
                        controllers.status.value = "2";
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
                    Padding(
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
                              child: registrationDisplayFile == null
                                  ? InkWell(
                                    onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return DetailScreen(
                                          file: registrationDisplayFile,
                                          image:
                                          controller.registrationImage.value,
                                        );
                                      }));
                                },
                                    child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/loader.gif',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        image:
                                            '${controller.registrationImage.value}',
                                        imageErrorBuilder: (c, o, s) =>
                                            Image.asset("assets/images/pdf.png",
                                                height: 50, fit: BoxFit.fill),
                                      ),
                                  )
                                  : registrationType == "pdf" ||
                                          registrationType == "docx"
                                      ? Image.asset("assets/images/pdf.png",
                                          height: 50, fit: BoxFit.fill)
                                      : InkWell(
                                        onTap: () {
                                        Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return DetailScreen(
                                          file: registrationDisplayFile,
                                          image:
                                          controller.registrationImage.value,
                                        );
                                      }));
                                },
                                        child: Image.file(
                                            registrationDisplayFile!,
                                            fit: BoxFit.fill,
                                            height: 50,
                                          ),
                                      ),
                            ),
                          ),
                          title: Text(
                            "Registration".tr,
                            style: TextStyle(fontSize: 18),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.check_circle,
                            size: 30,
                            color: controller.registrationImage.value.isEmpty
                                ? Colors.grey
                                : Color(0xff0CBB70),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controllers.status.value = "2";
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
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        controllers.status.value = "3";
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
                    Padding(
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
                              child: InsuranceDisplayFile == null
                                  ? InkWell(
                                  onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return DetailScreen(
                                          file: InsuranceDisplayFile,
                                          image:
                                          controller.insuranceImage.value,
                                        );
                                      }));
                                },
                                    child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/loader.gif',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        image:
                                            '${controller.insuranceImage.value}',
                                        imageErrorBuilder: (c, o, s) =>
                                            Image.asset("assets/images/pdf.png",
                                                height: 50, fit: BoxFit.fill),
                                      ),
                                  )
                                  : InsuranceType == "pdf" ||
                                          InsuranceType == "docx"
                                      ? Image.asset("assets/images/pdf.png",
                                          height: 50, fit: BoxFit.fill)
                                      : InkWell(
                                       onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return DetailScreen(
                                          file: InsuranceDisplayFile,
                                          image:
                                          controller.insuranceImage.value,
                                        );
                                      }));
                                },
                                        child: Image.file(
                                            InsuranceDisplayFile!,
                                            fit: BoxFit.fill,
                                            height: 50,
                                          ),
                                      ),
                            ),
                          ),
                          title: Text(
                            "Insurance".tr,
                            style: TextStyle(fontSize: 18),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.check_circle,
                            size: 30,
                            color: controller.insuranceImage.value.isEmpty
                                ? Colors.grey
                                : Color(0xff0CBB70),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        controllers.status.value = "3";
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
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        controllers.status.value = "4";
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
                    Padding(
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
                              child: IdProofImageDisplayFile == null
                                  ? InkWell(
                                      onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return DetailScreen(
                                          file: IdProofImageDisplayFile,
                                          image:
                                          controller.IdProofImage.value,
                                        );
                                      }));
                                },
                                    child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/loader.gif',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        image: '${controller.IdProofImage.value}',
                                        imageErrorBuilder: (c, o, s) =>
                                            Image.asset("assets/images/pdf.png",
                                                height: 50, fit: BoxFit.fill),
                                      ),
                                  )
                                  : IdProofImageType == "pdf" ||
                                          IdProofImageType == "docx"
                                      ? Image.asset("assets/images/pdf.png",
                                          height: 50, fit: BoxFit.fill)
                                      : InkWell(
                                         onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return DetailScreen(
                                          file: IdProofImageDisplayFile,
                                          image:
                                          controller.IdProofImage.value,
                                        );
                                      }));
                                },
                                        child: Image.file(
                                            IdProofImageDisplayFile!,
                                            fit: BoxFit.fill,
                                            height: 50,
                                          ),
                                      ),
                            ),
                          ),
                          title: Text(
                            "Id Proof",
                            style: TextStyle(fontSize: 18),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.check_circle,
                            size: 30,
                            color: controller.IdProofImage.value.isEmpty
                                ? Colors.grey
                                : Color(0xff0CBB70),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        controllers.status.value = "4";
                        datePicker();
                      },
                      child: IgnorePointer(
                        child: custom_textfield(
                          manditory: "*",
                          labletext: "Id Proof Expiry Date".tr,
                          textInputType: TextInputType.datetime,
                          textEditingController: idExpiry,
                          icon: Icon(
                            Icons.date_range,
                            color: MyColors.primary,
                          ),
                        ),
                      ),
                    ),*/
                    SizedBox(
                      height: 25,
                    ),
                    custom_buttons(
                        loading: controller.updateDetailLoader.value,
                        voidCallback: () {
                          valid();
                        },
                        text: "Update".tr)
                  ],
                ),
              ),
      );
    });
  }

  datePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2100),
        builder: (context, child) => Theme(
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
            child: child!));

    if (pickedDate != null) {
      print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      print(
          formattedDate); //formatted date output using intl package =>  2021-03-16
      setState(() {
        if (controllers.status.value == "0") {
          fitnessDateCtr.text = formattedDate;
        } else if (controllers.status.value == "1") {
          LicenceDateCtr.text = formattedDate;
        } else if (controllers.status.value == "2") {
          registrationDateCtr.text = formattedDate;
        } else if (controllers.status.value == "3") {
          InsuranceDateCtr.text = formattedDate;
        } else if (controllers.status.value == "4") {
          idExpiry.text = formattedDate;
        }
        //set output date to TextField value.
      });
    } else {}
  }

  void filePicker() async {
    print('status------------${controllers.status.value}');
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
        allowMultiple: false,
      );
      if (result != null && controllers.status.value == "0") {
        fitnessFileName = result!.files.first.name;
        fitnessDisplayFile = File(result!.files.single.path.toString());
        log("RcDisplayFile---------" + fitnessDisplayFile.toString());
        fitnessType = result!.files.first.extension.toString();
      } else if (result != null && controllers.status.value == "1") {
        LicenceFileName = result!.files.first.name;
        LicenceDisplayFile = File(result!.files.single.path.toString());
        log("LicenceDisplayFile---------" + LicenceDisplayFile.toString());
        LicenceType = result!.files.first.extension.toString();
        log("lctype---------" + LicenceType.toString());
      } else if (result != null && controllers.status.value == "2") {
        registrationFileName = result!.files.first.name;
        registrationDisplayFile = File(result!.files.single.path.toString());
        log("registrationDisplayFile---------" +
            registrationDisplayFile.toString());
        registrationType = result!.files.first.extension.toString();
      } else if (result != null && controllers.status.value == "3") {
        InsuranceFileName = result!.files.first.name;
        InsuranceDisplayFile = File(result!.files.single.path.toString());
        log("insurance---------" + InsuranceDisplayFile.toString());
        InsuranceType = result!.files.first.extension.toString();
        print("InsuranceType-------->$InsuranceType");
      } else if (result != null && controllers.status.value == "4") {
        IdProofImageName = result!.files.first.name;
        IdProofImageDisplayFile = File(result!.files.single.path.toString());
        log("id image---------" + InsuranceDisplayFile.toString());
        IdProofImageType = result!.files.first.extension.toString();
        print("id type-------->$InsuranceType");
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> valid() async {
    /*String _numberWithCountryCode = countryCode + phoneCtr.text;
    bool _isValid = GetPlatform.isWeb ? true : false;
    if (!GetPlatform.isWeb) {
      try {
        var phoneNumber = await PhoneNumberUtil().parse(_numberWithCountryCode);
        _numberWithCountryCode =
            '+' + phoneNumber.countryCode + phoneNumber.nationalNumber;
        _isValid = true;
      } catch (e) {}
    }
    try {
      String springFieldUSA = countryCode + phoneCtr.text;
      // Validate
      bool isValid = await PhoneNumberUtil().validate(springFieldUSA);
      print("phone validation==>");
      print(isValid);
    } catch (e) {
      print(e);
    }*/

    if (firstNameCtr.text.isEmpty) {
      customSnackBar("Please Enter First Name".tr);
    } else if (lastNameCtr.text.isEmpty) {
      customSnackBar("Please Enter Last Name".tr);
    } else if (emailCtr.text.isEmpty) {
      customSnackBar("Please Enter Email Address".tr);
    } else if (EmailValidator.validate(emailCtr.text.toString()) != true) {
      customSnackBar("Enter Valid Email Address".tr);
    } else if (phoneCtr.text.isEmpty) {
      customSnackBar("Please Enter Mobile Number".tr);
    } else if (vehicleNumberCtr.text.isEmpty) {
      customSnackBar("Please Enter Vehicle Registration Number".tr);
    }else if (controllers.selectedCarId.value.isEmpty) {
      customSnackBar("Please Enter Vehicle Type".tr);
    }else{
      controller.driverProfileUpdate(controllers.selectedCarId.value, vehicleNumberCtr.text,
          firstNameCtr.text, lastNameCtr.text, countryCode, CountryFlag, phoneCtr.text, emailCtr.text, () {

          },);
    }
   /*   controller.updateDriveDetail(
          firstNameCtr.text,
          lastNameCtr.text,
          emailCtr.text,
          phoneCtr.text,
          currentPassCtr.text,
          newPassCtr.text,
          countryCode.toString(),
          CountryFlag,
          vehicleNameCtr.text,
          vehicleNumberCtr.text,
          vehicleYear.text,
          vehicleColour.text,
          LicenceDateCtr.text,
          registrationDateCtr.text,
          fitnessDateCtr.text,
          InsuranceDateCtr.text,
          fitnessDisplayFile,
          registrationDisplayFile,
          LicenceDisplayFile,
          InsuranceDisplayFile,
          IdProofImageDisplayFile,
          idExpiry.text,
          carId, () {
        Navigator.pop(context);
      });*/

    }
  }


  Widget _buildCarListDropdown(VehicleController controllers) {
    return Obx(() {
      /// API / timing: profile can set car_id before `vehicleList` loads, or
      /// duplicate `car_id` rows break DropdownButton ("exactly one item" assertion).
      final uniqueByCarId = <String, VehicleFetchModel>{};
      for (final make in controllers.vehicleList) {
        final id = make.carId.trim();
        uniqueByCarId.putIfAbsent(id, () => make);
      }
      final items = uniqueByCarId.entries
          .map(
            (e) => DropdownMenuItem<String>(
              value: e.key,
              child: Text(
                e.value.carName,
                style: TextStyle(fontFamily: "Poppins"),
              ),
            ),
          )
          .toList();

      final sel = controllers.selectedCarId.value.trim();
      final String? fieldValue =
          sel.isNotEmpty && uniqueByCarId.containsKey(sel) ? sel : null;

      return DropdownButtonFormField<String>(


        decoration: InputDecoration(
          filled: true,
          fillColor: MyColors.TextField,
          labelText: "Select Vehicle Type",
          labelStyle: TextStyle(fontSize: 13),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          // reduced height
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        value: fieldValue,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        isExpanded: true,
        items: items,
        onChanged: (value) {
          if (value != null) {
            controllers.selectedCarId.value = value;
            log("------------$value");
          }
        },
      );
    });

}

class DetailScreen extends StatefulWidget {
  File? file;
  String image = "";

  DetailScreen({Key? key, required this.file, required this.image,})
      : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  ProfileController controller = Get.put(ProfileController());

  late File? profileImageFile;


  @override
  Widget build(BuildContext context) {
    if (widget.file != null) {
      profileImageFile = File(widget.file!.path);
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
          width: double.infinity,
          child: widget.file == null
              ? PhotoView(
                  imageProvider: NetworkImage(widget.image),
                  minScale: PhotoViewComputedScale.contained * 1,
                  maxScale: PhotoViewComputedScale.covered * 1,
                  enableRotation: false,
                  initialScale: PhotoViewComputedScale.contained * 1,
                )
              : PhotoView(
                  imageProvider: FileImage(profileImageFile!),
                  minScale: PhotoViewComputedScale.contained * 1,
                  maxScale: PhotoViewComputedScale.covered * 1,
                  enableRotation: false,
                  initialScale: PhotoViewComputedScale.contained * 1,
                )),
    );

    /* DoubleTappableInteractiveViewer(
        scaleDuration: const Duration(milliseconds: 600),
    child: Image.network(controller.Image.value,height: double.infinity,width: double.infinity,));*/
  }
}
