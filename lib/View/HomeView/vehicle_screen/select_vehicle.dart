import 'dart:developer';

import '../../../../controller/vehicle_controller.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/custom_button.dart';
import '../../../../utils/shared_preferences.dart';
import '../../../../utils/snackBar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route_helper/route_helper.dart';


class SelectVehicle extends StatefulWidget {
  const SelectVehicle({Key? key}) : super(key: key);

  @override
  State<SelectVehicle> createState() => _SelectVehicleState();
}

class _SelectVehicleState extends State<SelectVehicle> {
  SecureStorageService secure = SecureStorageService();
  VehicleController controller = Get.put(VehicleController());


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
            fontSize: 18),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(child:Obx((){
              if(controller.vehicleFetchLoader.value){
                return Center(child: myIndicator(),);
              }else if(controller.vehicleList.length == 0){
                return Center(child: Text("No Vehicle Available".tr),);
              }else{
                return ListView.builder(
                  itemCount: controller.vehicleList.length,
                  itemBuilder: (context, index) {
                    final vehicle = controller.vehicleList[index];
                    return Obx(() {
                      final isSelected = controller.selectedIndex.value == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: InkWell(
                          onTap: () {
                            controller.selectedIndex.value = index;
                            controller.CarId.value=vehicle.carId;
                            log("Car ID-----${controller.CarId.value}");

                          },
                          borderRadius: BorderRadius.circular(15),
                          splashColor: Colors.blue.withOpacity(0.1),
                          highlightColor: Colors.transparent,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue[50] : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected ? const Color(0xff0CBB70) : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              trailing: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                    Icons.check_circle,
                                    size: 28,
                                    color: isSelected ? const Color(0xff0CBB70) : Colors.grey.shade300),
                              ),
                              minVerticalPadding: 0,
                              visualDensity: VisualDensity.compact,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade100,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: FadeInImage.assetNetwork(

                                    placeholder: "assets/images/placeholder.gif",
                                    image: vehicle.carImage.toString(),
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.car_repair, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              title: Text(
                                vehicle.carName,
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF1A2B47),
                                ),
                              ),
                              subtitle: Text(
                                "Available Now",
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 12,
                                    color: Colors.grey.shade600),
                              ),
                            ),),

                        ),
                      );
                    });
                  },

                );
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
