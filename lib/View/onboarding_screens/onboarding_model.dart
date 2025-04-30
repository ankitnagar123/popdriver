
import 'package:get/get.dart';

class onboardingData
{

  String? middleImage;
  String? title;

  onboardingData({this.middleImage,this.title,});
}
List<onboardingData> items=[
  onboardingData(
    middleImage: "assets/images/onboarding1.png",
    title: "🚗 Safe, Easy & Reliable rides — Mtaani Driver’s got you covered!".tr,
  ),
  onboardingData(
    middleImage: "assets/images/onboarding2.png",
    title: "🕒 Always on time, every time — Ride smart with Mtaani Driver!".tr,
  ),
  onboardingData(
    middleImage: "assets/images/onboarding3.png",
    title: "📍 Discover ride requests around you — Earn more with ease!".tr,
  ),

];

