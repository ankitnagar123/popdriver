import 'dart:developer';
import '../../../controller/support_controller.dart';
import '../../../controller/vehicle_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../../utils/shared_preferences.dart';
import '../../../utils/snackBar.dart';

class SelectVehicle extends StatefulWidget {
  const SelectVehicle({Key? key}) : super(key: key);

  @override
  State<SelectVehicle> createState() => _SelectVehicleState();
}

class _SelectVehicleState extends State<SelectVehicle> {
  SecureStorageService secure = SecureStorageService();
  VehicleController controller = Get.put(VehicleController());

  String companyId = "";

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    getValue();
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
        title: Text("Select Vehicle".tr,style: TextStyle(
          fontFamily: "Poppins",
          color: MyColors.white,
        fontSize: 15),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Vehicle".tr,style: TextStyle(
                fontFamily: "Poppins",
                color: MyColors.black,
                fontSize: 17),),
            Expanded(child:Obx((){
              if(controller.vehicleFetchLoader.value){
                return Center(child: myIndicator(),);
              }else if(controller.vehicleList.length == 0){
                return Center(child: Text("No Vehicle Available".tr),);
              }else{
                return  ListView.builder(
                  itemCount: controller.vehicleList.length,
                  itemBuilder: (context, index) {
                    var list = controller.vehicleList[index];
                    return Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: InkWell(
                        onTap: (){
                          controller.selectedIndex.value = index;
                          controller.CarId.value = list.carId;
                          log(controller.CarId.value+"car Id----");
                        },
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60)
                              ),
                              child: FadeInImage.assetNetwork(
                                placeholder: "assets/images/placeholder.gif",
                                placeholderFit: BoxFit.fill,
                                image: "${list.carImage.toString()}",
                                fit: BoxFit.contain,
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return Image.asset("assets/images/logo.png",fit: BoxFit.fill,height: 50,);
                                },
                              ),
                            ),
                            title: Text("${list.carName}",style: TextStyle(
                                fontFamily: "Poppins",
                                color: MyColors.DarkBlue,
                                fontSize: 17),),
                            trailing: Icon(
                              Icons.check_circle,
                              size: 30,
                              color: controller.selectedIndex.value == index?
                              Color(0xff0CBB70):
                              MyColors.DarkBlue,),
                          ),
                        ),
                      ),
                    ),);
                  },);
              }
            }))
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: custom_buttons(voidCallback: (){
          if(controller.CarId.value == ""){
            customSnackBar("Please Select Vehicle".tr);
          }else{
            Get.toNamed(RouteHelper.getVehicleDetailScreenRoute(),arguments: {
              "carId" : controller.CarId.value
            });
          }

        }, text: "Next".tr),
      ),
    );
  }

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  void getValue()async{
    log("userId-----${await secure.readData(secure.user_id)}");
    controller.fetchVehicle();
    setState(() {
    });
  }
}
