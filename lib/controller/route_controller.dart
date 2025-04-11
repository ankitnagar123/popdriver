
import 'package:get/get.dart';

class RouteController extends GetxController{

  var buttonStatus = false.obs;
  var  pageIndex = 0.obs;

  var currentPage = 0.obs;


  get  load =>pageIndex.value;

  setValue(int value){
    pageIndex.value = value;
  }
}