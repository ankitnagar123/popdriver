
import 'package:get/get.dart';

class onboardingData
{

  String? middleImage;
  String? title;
  String? subTitle;

  onboardingData({this.middleImage,this.title,this.subTitle});
}
List<onboardingData> items=[
  onboardingData(
    middleImage: "assets/images/onboarding1.png",
    title: "Register Vehicle".tr,
    subTitle: "🚗 Quick and simple vehicle registration to get you started on the road.".tr,
  ),
  onboardingData(
    middleImage: "assets/images/onboarding2.png",
    title: "Upload Documents".tr,
    subTitle: "📄 Securely upload your documents — drive with confidence and compliance.".tr,
  ),
  onboardingData(
    middleImage: "assets/images/onboarding3.png",
    title: "No commission and more earnings".tr,
    subTitle: "💸 Start accepting ride requests nearby — boost your income effortlessly.".tr,
  ),


];

