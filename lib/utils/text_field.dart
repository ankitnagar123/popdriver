
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'colors.dart';

class custom_textfield extends StatelessWidget {
  String labletext;
  Widget? icon;
  final String manditory ;
  Widget? icons;
  final bool ishide;
  TextInputType? textInputType;
  TextEditingController? textEditingController;
  int? maxlenth;
  bool readOnly;
  final bool allowSpecialCharacters;
  final bool isEmail;

  custom_textfield(
      {super.key,
        this.labletext = "",
        this.icon,
        this.icons,
        this.manditory = "",
        this.textInputType,
        this.textEditingController,
        this.ishide = false,
        this.maxlenth,
        this.readOnly = false,
        this.allowSpecialCharacters = true,
        this.isEmail = false
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                Text(labletext.tr,style: TextStyle(color: MyColors.DarkBlue,fontSize: 14)),
                  SizedBox(width: 5,),
                  Text(manditory == ""?"":manditory.tr,
                    style: TextStyle(
                        color: Colors.red
                    ),)
                ],
              )),

          Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 10, top: 0),
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  10,
                ),
                color: MyColors.TextField,
                border: Border.all(color: MyColors.TextField, width: 1)),
            child: TextFormField(

              toolbarOptions: ToolbarOptions(
                copy: true,
                cut: true,
                paste: false,
                selectAll: false,
              ),
              enableInteractiveSelection: false,
              readOnly: readOnly,
              controller: textEditingController,
              obscureText: ishide,
              maxLength: maxlenth,
              keyboardType: textInputType,
              inputFormatters: isEmail
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]'))] // Allow all characters if allowSpecialCharacters is true
                  : allowSpecialCharacters ?[ FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))]: null,
              decoration: InputDecoration(

                counterText: "",
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: labletext,
                  suffixIcon: icon,
                  prefixIcon: icons,
                  hintStyle:
                  const TextStyle(color: MyColors.DarkBlue, fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }
}