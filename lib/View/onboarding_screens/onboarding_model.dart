
import 'package:get/get.dart';

class onboardingData
{

  String? middleImage;
  String? title;

  onboardingData({this.middleImage,this.title,});
}
List<onboardingData> items=[
  onboardingData(

    middleImage:"assets/images/onboarding1.png",
    title:"Safe, convenient, and Reliable transportation with Mtaani Driver".tr,
  ),
  onboardingData(

    middleImage:"assets/images/onboarding2.png",
    title:"Get to your destination on time, every time with Mtaani Driver".tr,

  ),
  onboardingData(

    middleImage:"assets/images/onboarding3.png",
    title:"See all ride request in your area".tr,

  ),
];

