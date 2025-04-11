import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CustomButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? fontColor;
  final double radius;
  const CustomButtonWidget({super.key, this.onPressed, required this.buttonText, this.transparent = false, this.margin, this.width, this.height,
    this.fontSize, this.icon, this.backgroundColor, this.fontColor, this.radius = Dimensions.radiusSmall});

  @override
  Widget build(BuildContext context) {

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null ? Theme.of(context).disabledColor : transparent
          ? Colors.transparent : backgroundColor ?? Theme.of(context).primaryColor,
      minimumSize: Size(width != null ? width! : 1170, height != null ? height! : 50),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    );

    return Padding(
      padding: margin == null ? const EdgeInsets.all(0) : margin!,
      child: TextButton(
        onPressed: onPressed as void Function()?,
        style: flatButtonStyle,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

          icon != null ? Icon(
            icon, color: transparent ? Theme.of(context).primaryColor : Theme.of(context).cardColor, size: 20,
          ) : const SizedBox(),
          SizedBox(width: icon != null ? Dimensions.paddingSizeExtraSmall : 0),

          Text(buttonText, textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),

        ]),
      ),
    );
  }
}

class CustomAlertDialogWidget extends StatelessWidget {
  final String description;
  final Function onOkPressed;
  const CustomAlertDialogWidget({super.key, required this.description, required this.onOkPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Icon(Icons.info, size: 80, color: Theme.of(context).primaryColor),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Text(
              description, textAlign: TextAlign.center,

            ),
          ),

          CustomButtonWidget(
            buttonText: 'ok'.tr,
            onPressed: onOkPressed,
            height: 40,
          ),

        ]),
      ),
    );
  }
}

class ConfirmationDialogWidget extends StatelessWidget {
  final String icon;
  final double iconSize;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isLogOut;
  final bool hasCancel;
  const ConfirmationDialogWidget({super.key, required this.icon, this.iconSize = 50, this.title, required this.description, required this.onYesPressed,
    this.isLogOut = false, this.hasCancel = true});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Image.asset(icon, width: iconSize, height: iconSize),
          ),

          title != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(
              title!, textAlign: TextAlign.center,
            ),
          ) : const SizedBox(),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Text(description,  textAlign: TextAlign.center),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // TextButton(
          //    onPressed: () =>  onYesPressed() ,
          //    style: TextButton.styleFrom(
          //      backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3), minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
          //      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
          //    ),
          //    child: Text(
          //    'no'.tr, textAlign: TextAlign.center,
          //    ),
          //  ),
          SizedBox(width: Dimensions.paddingSizeLarge),

          CustomButtonWidget(

            buttonText:  'ok'.tr,

            onPressed: () =>  onYesPressed(),
            height: 40,
            width: 100,
          ),

        ]),
      ),
    );
  }
}

class Dimensions {
  static const double fontSizeExtraSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeDefault = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  static const double fontSizeOverLarge = 24.0;

  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeDefault = 15.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 25.0;

  static const double radiusSmall = 5.0;
  static const double radiusDefault = 10.0;
  static const double radiusLarge = 15.0;
  static const double radiusExtraLarge = 20.0;

  static const int messageInputLength = 250;
  static const double webMaxWidth = 1170;
}