/*
import 'package:ColumbiaTaxi/controller/wallet_controller/wallet_controller.dart';
import 'package:ColumbiaTaxi/utils/colors.dart';
import 'package:ColumbiaTaxi/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletHistory extends StatefulWidget {
  const WalletHistory({Key? key}) : super(key: key);

  @override
  State<WalletHistory> createState() => _WalletHistoryState();
}

class _WalletHistoryState extends State<WalletHistory> {

  WalletController controller = Get.put(WalletController());

  @override
  void initState() {
    controller.fetchTransaction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: MyColors.primary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(Icons.arrow_back, color: Colors.white,),
              ),
              Center(
                  child: Text("View All Transactions",
                    style: TextStyle(color: Colors.white),)
              ),
              SizedBox(
                width: 10,
              )
            ],
          ),
          elevation: 0.0,
        ),

        body: Obx(() {
          if(controller.walletFetchHistoryLoader.value)
            return Center(
              child: myIndicator(),
            );
          else if(controller.transactionList.length == 0)
            return Center(
              child: Text("No Data Found"),
            );
          else
          return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.transactionList.length,
              itemBuilder: (context, index) {
                var list = controller.transactionList[index];
                return Card(
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                    side: new BorderSide(color: MyColors.primary, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.status, style: TextStyle(color: Colors
                            .grey, fontWeight: FontWeight.w700),)
                        ,
                        Align(
                          alignment: Alignment.topRight,
                          child: Text("Amount", style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400),),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              children: [
                                Text("Balance:", style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800),),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text("KSh ${list.walletAmount}", style: TextStyle(
                                    color: MyColors.primary,
                                    fontWeight: FontWeight.w800),),
                              ],
                            )
                            ,
                            Text("KSh ${list.paidAmount}", style: TextStyle(
                                color: MyColors.primary,
                                fontWeight: FontWeight.w600),),
                          ],
                        ),
                        Wrap(
                          children: [
                            Text(list.date, style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800),),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(list.time, style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800),),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
        })
    );
  }
}
*/
