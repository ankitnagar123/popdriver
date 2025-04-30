
import 'package:get/get_navigation/src/routes/get_route.dart';
import '../View/AuthScreen/forgot_password_screen.dart';
import '../View/AuthScreen/login_screen.dart';
import '../View/AuthScreen/otp_screen.dart';
import '../View/AuthScreen/password_change_successful.dart';
import '../View/AuthScreen/select_location.dart';
import '../View/AuthScreen/set_new_password.dart';
import '../View/AuthScreen/signup_otp.dart';
import '../View/AuthScreen/signup_screen.dart';
import '../View/AuthScreen/splace_screen.dart';
import '../View/HomeView/HomeScreenBottomNav/HomeScreenBottomNav.dart';
import '../View/HomeView/bank_details/add_bank_details.dart';
import '../View/HomeView/cancel_booking_screen.dart';
import '../View/HomeView/drawer_tab_screen/invite_friend_screen.dart';
import '../View/HomeView/drawer_tab_screen/my_ride_screen.dart';
import '../View/HomeView/drawer_tab_screen/notification_screen.dart';
import '../View/HomeView/drawer_tab_screen/rating_screen.dart';
import '../View/HomeView/drawer_tab_screen/ride_history/ride_history.dart';
import '../View/HomeView/home_screen.dart';
import '../View/HomeView/message_screen.dart';
import '../View/HomeView/profile_screens/edit_profile_screen.dart';
import '../View/HomeView/profile_screens/profile.dart';
import '../View/HomeView/report_Page.dart';
import '../View/HomeView/ride_start/ready_ride_screen.dart';
import '../View/HomeView/ride_start/start_ride_otp.dart';
import '../View/HomeView/support_screen/frequently_screen.dart';
import '../View/HomeView/support_screen/privacy_policy.dart';
import '../View/HomeView/support_screen/single_query.dart';
import '../View/HomeView/support_screen/support_sceen.dart';
import '../View/HomeView/support_screen/term_condition.dart';
import '../View/HomeView/support_screen/wirte_support.dart';
import '../View/HomeView/vehicle_screen/select_vehicle.dart';
import '../View/HomeView/vehicle_screen/vehicle_detail_screen.dart';
import '../View/HomeView/wallet_screen/fetch_card_screen.dart';
import '../View/HomeView/wallet_screen/wallet_screen.dart';
import '../View/onboarding_screens/onboarding_screen.dart';
import '../View/single_complane_screen.dart';
import '../permission.dart';

class RouteHelper {

  static const String initial = '/';
  static const String splash = '/splash';
  static const String onBoarding = '/onBoarding';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String forgetPassword = '/forgetPassword';
  static const String otp = '/otp';
  static const String setPassword = '/setPassword';
  static const String changePassSuccess = '/changePassSuccess';
  static const String selectAddress = '/selectAddress';
  static const String homeScreen = '/homeScreen';
  static const String readyForRide = '/readyForRide';
  static const String notificationScreen = '/notificationScreen';
  static const String walletScreen = '/walletScreen';
  static const String myRide = '/myRide';
  static const String rating = '/rating';
  static const String inviteFriend = '/inviteFriend';
  static const String profileScreen = '/profileScreen';
  static const String editProfileScreen = '/editProfileScreen';
  static const String rideHistory = '/rideHistory';
  static const String supportScreen = '/supportScreen';
  static const String contactUs = '/contactUs';
  static const String writeSupport = '/writeSupport';
  static const String frequently = '/frequently';
  static const String privacyPolicy = '/privacyPolicy';
  static const String termCondition = '/termCondition';
  static const String cancelBooking = '/cancelBooking';
  static const String startRideOtp = '/startRideOtp';
  static const String addBankDetails = '/addBankDetails';
  static const String selectVehicle = '/selectVehicle';
  static const String vehicleDetail = '/vehicleDetail';
  static const String wallet = '/wallet';
  static const String wallethistory = '/wallethistory';
  static const String addCard = '/addCard';
  static const String fetchCard = '/fetchCard';
  static const String report = '/report';
  static const String message = '/message';
  static const String fetchSingleQuery = '/fetchSingleQuery';
  static const String fetchSingleCom = '/fetchSingleCom';
  static const String locationPermissionPage = '/locationPermissionPage';
  static const String signupOTP = '/signupOTP';



  static String getInitialRoute()=>initial;
  static getSplashScreenRoute()=>splash;
  static getOnBoardingScreenRoute()=>onBoarding;
  static getLoginScreenRoute()=>login;
  static getSignUpScreenRoute()=>signUp;
  static getForgotPasswordScreenRoute()=>forgetPassword;
  static getOtpScreenRoute()=>otp;
  static getSetPasswordScreenRoute()=>setPassword;
  static getPasswordChangeSuccessScreenRoute()=>changePassSuccess;
  static getSelectAddressScreenRoute()=>selectAddress;
  static getHomeScreenScreenRoute()=>homeScreen;
  static getReadyForRideScreenRoute()=>readyForRide;
  static getNotificationScreenRoute()=>notificationScreen;
  static getWalletScreenScreenRoute()=>walletScreen;
  static getMyRideScreenScreenRoute()=>myRide;
  static getRatingScreenScreenRoute()=>rating;
  static getInviteFriendScreenScreenRoute()=>inviteFriend;
  static getProfileScreenScreenRoute()=>profileScreen;
  static getEditProfileScreenRoute()=>editProfileScreen;
  static getRideHistoryScreenRoute()=>rideHistory;
  static getSupportScreenRoute()=>supportScreen;
  static getContactUsScreenRoute()=>contactUs;
  static getWriteSupportScreenRoute()=>writeSupport;
  static getFrequentlyScreenScreenRoute()=>frequently;
  static getPrivacyPolicyScreenRoute()=>privacyPolicy;
  static getTermConditionScreenRoute()=>termCondition;
  static getCancelBookingScreenRoute()=>cancelBooking;
  static getStartRideOtpScreenRoute()=>startRideOtp;
  static getAddBankDetailsScreenRoute()=>addBankDetails;
  static getSelectVehicleScreenRoute()=>selectVehicle;
  static getVehicleDetailScreenRoute()=>vehicleDetail;
  static getWallletScreenRout()=>wallet;
  static getWallletHistoryScreenRout()=>wallethistory;
  static getAddCardScreenRout()=>addCard;
  static getFetchCardScreenRout()=>fetchCard;
  static getReportScreenRout()=>report;
  static getMessageScreenRout()=>message;
  static getSingleQueryScreen()=>fetchSingleQuery;
  static getSingleQueryComScreen()=>fetchSingleCom;
  static getLocationPermissionPageScreen()=>locationPermissionPage;
  static getSignupOTPScreen()=>signupOTP;


  static  List<GetPage> routes = [

  GetPage(name: splash, page: ()=>  SplashScreen()),
  GetPage(name: onBoarding, page: ()=> const OnboardingScreen()),
  GetPage(name: login, page: ()=> const LoginScreen()),
  GetPage(name: signUp, page: ()=> const SignUpScreen()),
  GetPage(name: forgetPassword, page: ()=> const ForgotPassword()),
  GetPage(name: otp, page: ()=> const OtpScreen()),
  GetPage(name: setPassword, page: ()=> const SetPassword()),
  GetPage(name: changePassSuccess, page: ()=> const PasswordChangeSuccess()),
  GetPage(name: selectAddress, page: ()=> const SelectAddress()),
  GetPage(name: homeScreen, page: ()=> const BottomNavScreen()),
  GetPage(name: readyForRide, page: ()=> const ReadyForRide()),
  GetPage(name: notificationScreen, page: ()=> const NotificationScreen()),
 /* GetPage(name: walletScreen, page: ()=> const WalletScreen()),*/
  GetPage(name: myRide, page: ()=> const MyRideScreen()),
  GetPage(name: rating, page: ()=> const RatingScreen()),
  GetPage(name: inviteFriend, page: ()=> const InviteFriendScreen()),
  GetPage(name: profileScreen, page: ()=> const ProfileScreen()),
  GetPage(name: editProfileScreen, page: ()=> const EditProfile()),
  GetPage(name: rideHistory, page: ()=> const RideHistory()),
  GetPage(name: supportScreen, page: ()=> const Support()),
  /*GetPage(name: contactUs, page: ()=> const ContactUs()),*/
  GetPage(name: writeSupport, page: ()=> const WriteSupport()),
  GetPage(name: frequently, page: ()=> const FrequentlyScreen()),
  GetPage(name: privacyPolicy, page: ()=> const PrivacyPolicy()),
  GetPage(name: termCondition, page: ()=> const TermCondition()),
  GetPage(name: cancelBooking, page: ()=> const CancelBooking()),
  GetPage(name: startRideOtp, page: ()=> const StartRideOtp()),
  GetPage(name: addBankDetails, page: ()=> const AddBankDetails()),
  GetPage(name: selectVehicle, page: ()=> const SelectVehicle()),
  GetPage(name: vehicleDetail, page: ()=> const VehicleDetail()),
  GetPage(name: wallet, page: ()=> const WalletScreen()),
  /*GetPage(name: wallethistory, page: ()=> const WalletHistory()),*/
  /*GetPage(name: addCard, page: ()=>  AddNewCardScreen()),*/
  GetPage(name: fetchCard, page: ()=>  FetchCard()),
  GetPage(name: report, page: ()=>  ReportPage()),
  GetPage(name: message, page: ()=>  Messages()),
  GetPage(name: fetchSingleQuery, page: ()=>  FetchSingleQuery()),
  GetPage(name: fetchSingleCom, page: ()=>  FetchSingleComplane()),
  GetPage(name: locationPermissionPage, page: ()=>  LocationPermissionPage()),
  GetPage(name: signupOTP, page: ()=>  SignupOTP()),

  ];


}