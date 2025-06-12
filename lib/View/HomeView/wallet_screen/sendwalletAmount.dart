import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../controller/wallet_controller/wallet_controller.dart';
import '../../../utils/colors.dart';

class Driver {
  final String id;
  final String name;
  final String phone;

  Driver({required this.id, required this.name, required this.phone});
}

class SendWalletAmount extends StatefulWidget {
  const SendWalletAmount({super.key});

  @override
  State<SendWalletAmount> createState() => _SendWalletAmountState();
}

class _SendWalletAmountState extends State<SendWalletAmount> {
  final TextEditingController _searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  final TextEditingController _amountController = TextEditingController();

  WalletController controller = Get.put(WalletController());


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.walletFetch();
      controller.fetchDriverListApi();
    },);

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

            Row(
              children: [
                Image.asset(
                  'assets/images/headLogo.png',
                  height: 40,
                ), Image.asset(
                  color: Colors.white,
                  'assets/images/stearing.png',
                  height: 37,
                ),

              ],
            ),

            SizedBox(
              width: 10,
            )
          ],
        ),
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Center(
              child: Text(
                "Send Wallet Amount".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: MyColors.black,
                  fontFamily: "Poppins",
                ),
              )),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MyColors.primary,
                    MyColors.primary.withOpacity(0.5)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Account Balance',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 10),
                  Row(
                    spacing: 10,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 50,
                        color: MyColors.white,
                      ),
                      Obx(() {
                        return Text(
                          controller.walletBalance.value == ""
                              ? "\$ 0"
                              : "\$ ${controller.walletBalance.value}",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              decoration: controller
                                  .walletBalance.value
                                  .contains("-")
                                  ? TextDecoration.underline
                                  : null,
                              decorationColor: Colors.red,
                              wordSpacing: 1.5,
                              color: MyColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              focusNode: searchFocus,
              controller: _searchController,
              onChanged: (value) => controller.filterDrivers(value),

              decoration: InputDecoration(
                hintText: 'Search by name,contact,email',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.fetchDriverLoader.value) {
              return Center(
                  heightFactor: 8,
                  child: CupertinoActivityIndicator());
            }
            return Expanded(
              child: ListView.builder(
                itemCount: controller.driverList.length,
                itemBuilder: (context, index) {
                  final driver = controller.driverList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/loader.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          image: driver.image,
                          imageErrorBuilder: (c, o, s) =>
                              Image.asset(
                                "assets/images/logo.png",
                                fit: BoxFit.cover,
                              ),
                        ),
                      ),
                    ),
                    title: Text("${driver.firstName} ${driver.lastName}"),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${driver.countryCode} ${driver.contact}",
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54),),
                        Text("${driver.email}", style: TextStyle(
                            fontSize: 12, color: Colors.black54),),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        searchFocus.unfocus();
                        _showTransferBottomSheet(driver.firstName, driver.id);
                      },
                      // onPressed: onTransfer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Send'),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showTransferBottomSheet(String name, id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This is important for scrollable content
      builder: (context) =>
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom, // Handle keyboard overlap
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Transfer to ${name}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Amount',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (_amountController.text.isNotEmpty) {
                            controller.sendWalletAmountToDriver(
                              id, _amountController.text,
                                  () {
                                controller.walletFetch();
                                setState(() {

                                });
                                Navigator.pop(context);
                              },);

                            _amountController.clear();
                          }
                        },
                        child: const Text(
                            'Send', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom > 0 ? 100 : 0),
                    // Add extra space when keyboard is visible
                  ],
                ),
              ),
            ),
          ),
    );
  }

}


