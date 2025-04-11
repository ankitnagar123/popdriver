String patttern = r'^[a-zA-Z_,\.;]+$';
RegExp regExp = new RegExp(patttern);

/*

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ColumbiaTaxi/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

String patttern = r'^[a-zA-Z_,\.;]+$';
RegExp regExp = new RegExp(patttern);


ZegoUIKitPrebuiltCallController? callController;

/// on user login
void onUserLogin(String Id ,String name) async {
  log("name ----------$name");
  callController ??= ZegoUIKitPrebuiltCallController();

  /// 4/5. initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: 850516225, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
    appSign: "bb2061fef4ebd40f781ed03b8f4927bf96bbfbaff1b11e0a18814ae0f74bdfe3"*/
/*"20b23965a2a7d0fddf9e62967a8f9af388a5cc52943e675db6f09ff2e264604a"*//*
, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.

    userID:  Id,
    userName: name,
    notifyWhenAppRunningInBackgroundOrQuit: true,
    plugins: [ZegoUIKitSignalingPlugin()],
    controller: callController,
    requireConfig: (ZegoCallInvitationData data) {
      final config = (data.invitees.length > 1)
          ? ZegoCallType.videoCall == data.type
          ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
          : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
          : ZegoCallType.videoCall == data.type
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

     */
/* config.avatarBuilder = customAvatarBuilder;*//*


      /// support minimizing, show minimizing button
      config.topMenuBarConfig.isVisible = true;
      config.topMenuBarConfig.buttons
          .insert(0, ZegoMenuBarButtonName.minimizingButton);

      return config;
    },
  );
}

void onUserLogout() {
  callController = null;

  /// 5/5. de-initialization ZegoUIKitPrebuiltCallInvitationService when account is logged out
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}




Widget customAvatarBuilder(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
    ) {
  return CachedNetworkImage(
    imageUrl: 'https://robohash.org/${user?.id}.png',
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        CircularProgressIndicator(value: downloadProgress.progress),
    errorWidget: (context, url, error) {
      ZegoLoggerService.logInfo(
        '$user avatar url is invalid',
        tag: 'live audio',
        subTag: 'live page',
      );
      return ZegoAvatar(user: user, avatarSize: size);
    },
  );
}

List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText ,String username) {
  final invitees = <ZegoUIKitUser>[];

  final inviteeIDs = textCtrlText.trim().replaceAll('，', '');
  inviteeIDs.split(',').forEach((inviteeUserID) {
    if (inviteeUserID.isEmpty) {
      return;
    }

    invitees.add(ZegoUIKitUser(
      id: inviteeUserID,
      name: username,
    ));
  });

  return invitees;
}

void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvitees,
    ) {
  if (errorInvitees.isNotEmpty) {
    var userIDs = '';
    for (var index = 0; index < errorInvitees.length; index++) {
      if (index >= 5) {
        userIDs += '... ';
        break;
      }

      final userID = errorInvitees.elementAt(index);
      userIDs += '$userID ';
    }
    if (userIDs.isNotEmpty) {
      userIDs = userIDs.substring(0, userIDs.length - 1);
    }

    var message = "User doesn't exist or is offline: $userIDs";
    if (code.isNotEmpty) {
      message += ', code: $code, message:$message';
    }
    // showToast(
    //   message,
    //   position: StyledToastPosition.top,
    //   context: context,
    // );
  } else if (code.isNotEmpty) {
    // showToast(
    //   'code: $code, message:$message',
    //   position: StyledToastPosition.top,
    //   context: context,
    // );
  }

}*/
