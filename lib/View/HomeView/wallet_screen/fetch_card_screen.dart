
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/wallet_controller/payment_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';

class FetchCard extends StatefulWidget {
  const FetchCard({Key? key}) : super(key: key);

  @override
  State<FetchCard> createState() => _FetchCardState();
}

class _FetchCardState extends State<FetchCard> {
  PaymentController controller = Get.put(PaymentController());

  String cardid = '';
  String? payment = '';
  String cardNumber = " XXXX XXXX XXXX";
  String CardId = "";
  String Price = "";

  @override
  void initState() {
    Price = Get.arguments['Price'];
    controller.fetchCart();
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
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Center(
                child: Text(
              "Wallet",
              style: TextStyle(color: Colors.white),
            )),
            SizedBox(
              width: 10,
            )
          ],
        ),
        elevation: 0.0,
      ),
      body: Obx(() {
        if (controller.fetchLoader.value)
          return Center(
            child: myIndicator(),
          );
        else {
          return Column(
            children: [
              Container(
                height: Get.height / 8,
                width: Get.width,
                child: Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        height: 20,
                        width: Get.width,
                        color: MyColors.buttonColor,
                        child: Text(
                          "Payment Option",
                          style: TextStyle(color: MyColors.white),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(RouteHelper.getAddCardScreenRout());
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.credit_card,
                                color: MyColors.buttonColor,
                                size: 40,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Credit Or Debit Card",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(Icons.arrow_forward_ios_outlined),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: controller.cardList.length,
                    itemBuilder: (context, index) {
                      var list = controller.cardList[index];
                      CardId = list.cardId;
                      return controller.cardList.length == 0
                          ? Center(
                              child: Text('No Card Added'),
                            )
                          : Card(
                              elevation: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.deleteCard(
                                          context, CardId.toString());
                                    },
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: controller.deleteLoader.value
                                          ? myIndicator()
                                          : Icon(Icons.delete_outline_outlined),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Radio<String>(
                                        value: index.toString(),
                                        groupValue: payment,
                                        onChanged: (value) {
                                          setState(() {
                                            payment = value!;
                                            print(payment);
                                            cardid = list.cardId;
                                            print('cardid----------$cardid');
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(list.accountHolderName,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            Text(
                                                '${cardNumber + list.cardNo.substring(14)}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                    }),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: custom_button(voidCallback: () {}, text: "Add"),
              )
            ],
          );
        }
      }),
    );
  }
}
