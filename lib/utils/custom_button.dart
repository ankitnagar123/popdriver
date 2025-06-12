
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart';

class custom_button extends StatelessWidget {
  VoidCallback voidCallback;
  String text;
  final bool loading;


  custom_button({super.key,required this.voidCallback,required this.text,this.loading = false,}):super() ;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: context.width,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor:MyColors.buttonColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),), ),
        onPressed: voidCallback,
        child: loading ? myIndicator():Text(text,style: TextStyle(color: MyColors.white),),
      ),
    );
  }
}

class custom_buttons extends StatelessWidget {
  VoidCallback voidCallback;
  String text;
  final bool loading;

  custom_buttons({super.key,required this.voidCallback,required this.text,this.loading = false,}):super() ;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: context.width,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor:MyColors.black,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),), ),
        onPressed: voidCallback,
        child: loading ? myIndicator():Text(text,style: TextStyle(color: MyColors.white,letterSpacing: 1,fontWeight: FontWeight.w600),),
      ),
    );
  }
}

Widget myIndicator(){
  return Center(
    child: CupertinoActivityIndicator(
      radius: 14,
      color: MyColors.primary.withOpacity(0.5),
    ),
  );
   /* CircularProgressIndicator(color: MyColors.white,strokeWidth: 2,backgroundColor: Colors.blue[200],);*/
}
