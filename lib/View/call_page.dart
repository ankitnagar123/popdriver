/*
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
class AudioCallingPage extends StatelessWidget {
  final String callingId ;
  final String userName;
  final String userId;
  const AudioCallingPage({Key? key, required this.callingId, required this.userName, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: 850516225 ,
          appSign: "bb2061fef4ebd40f781ed03b8f4927bf96bbfbaff1b11e0a18814ae0f74bdfe3",
          userID: userId,
          callID: callingId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            ..topMenuBarConfig.isVisible = true
            ..topMenuBarConfig.buttons = [
              // ZegoMenuBarButtonName.minimizingButton,
              // ZegoMenuBarButtonName.showMemberListButton,
            ]
            ..onOnlySelfInRoom = (context) {
              if (PrebuiltCallMiniOverlayPageState.idle !=
                  ZegoUIKitPrebuiltCallMiniOverlayMachine().state()) {
                ZegoUIKitPrebuiltCallMiniOverlayMachine()
                    .changeState(PrebuiltCallMiniOverlayPageState.idle);
              } else {
                Navigator.of(context).pop();
              }
            },
          userName: userName,
        )
    );
  }
}*/
