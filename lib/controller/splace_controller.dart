import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class SplashController extends GetxController{



  VideoPlayerController? _controller;
  VideoPlayerController get playerController=>_controller!;



  @override
  void onInit() {
    super.onInit();
    initVideo();
  }

  Future<void> initVideo()async{
    _controller = VideoPlayerController.asset("assets/video/splash.mp4");
    _controller!.initialize().then((_) {
      _controller!.setLooping(false);
      update();
    });
  }

  void videoPlay(){
    _controller!.play();
    update();
  }

}