import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../../../controller/auth_controller.dart';

import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route_helper/route_helper.dart';
import '../../../utils/snackBar.dart';
import 'membership_flow.dart';

class MemberShipScreen extends StatefulWidget {
  String type = "";

  MemberShipScreen({super.key, required this.type});

  @override
  State<MemberShipScreen> createState() => _MemberShipScreenState();
}

class _MemberShipScreenState extends State<MemberShipScreen> {
  String membership = "";
  String amount = "";
  AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    controller.memberShip();
    membership = MyColors.MemberShipId;
    print("member ------${MyColors.MemberShipId}");
    log("Initial member: $membership");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              if (widget.type == "signup") {
                Get.offAllNamed(RouteHelper.getLoginScreenRoute());
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Icon(Icons.arrow_back, color: Colors.white)),
        backgroundColor: MyColors.primary,
        title: Text(
          "MemberShip".tr,
          style: TextStyle(
              fontSize: 20, color: MyColors.white, fontFamily: "Poppins"),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.memberShipLoader.value) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (controller.memberShipList.isEmpty) {
          return Center(
            child: Text("Plane not found".tr),
          );
        } else {
          return Column(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:/* ListView.separated(
                    itemCount: controller.memberShipList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {

                      final plan = controller.memberShipList[index];
                      final isSelected = membership == plan.membershipId;

                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff019ba5), Color(0xff017f91)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipOval(
                                    child: Image.asset(
                                  'assets/images/background.png',
                                  fit: BoxFit.contain,
                                  height: 40,
                                )),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: plan.membershipType == "Gold" ||
                                              plan.membershipType == "gold"
                                          ? Colors.orangeAccent
                                          : plan.membershipType == "Silver"
                                              ? Colors.grey.shade400
                                              : plan.membershipType == "Bronze"
                                                  ? Color(0xffCE8946)
                                                  : Colors.white24,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      plan.membershipType,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),

                            Text(
                              plan.name,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              plan.price == "0" ? "FREE" : " KSh ${plan.price}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),


                            Row(
                              children: [
                                Text(
                                  "Government Tax (VAT) : ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  plan.tax,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Commission : ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  plan.commission,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Text(
                              plan.description,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected ? MyColors.black : Colors.white,
                                  foregroundColor: isSelected ? Colors.black87 : MyColors.primary,
                                    shape: StadiumBorder(),
                                  padding:  EdgeInsets.symmetric(
                                      horizontal: 10, vertical:isSelected?15:10),
                                  elevation: 5,
                                ),
                                onPressed: isSelected
                                    ? null
                                    : () {
                                  setState(() {
                                    membership = plan.membershipId;
                                    amount = plan.price;
                                    MyColors.MemberShipId = plan.membershipId;  // assign to global here
                                    log("membership selected -> $membership");
                                  });
                                },

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isSelected ? 'Selected ${plan.name}' : 'Choose ${plan.name}',
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color:  isSelected ? Colors.white:Colors.black87),
                                    ),
                                    Icon(Icons.check_circle,
                                      color: isSelected ?  Colors.white:MyColors.DarkBlue,size: isSelected ? 30:20, ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),*/
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    itemCount: controller.memberShipList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final plan = controller.memberShipList[index];
                      final isSelected = membership == plan.membershipId;

                      return Container(
                           decoration: _getPlanDecoration(plan.membershipType),
/*BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff019ba5), Color(0xff017f91)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),*/
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Top Row — Image and Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    'assets/images/background.png',
                                    fit: BoxFit.cover,
                                    height: 40,
                                    width: 40,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: plan.membershipType.toLowerCase() == "gold"
                                        ? Colors.orangeAccent
                                        : plan.membershipType.toLowerCase() == "silver"
                                        ? Colors.grey.shade400
                                        : plan.membershipType.toLowerCase() == "bronze"
                                        ? const Color(0xffCE8946)
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    plan.membershipType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// Plan Name
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 5),

                            /// Price
                            Text(
                              plan.price == "0" ? "FREE" : "KSh ${plan.price}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Tax & Commission
                            _buildInfoRow("Government Tax (VAT) :", "${plan.tax}%"),
                            _buildInfoRow("Commission :", "${plan.commission}%"),

                            const SizedBox(height: 10),

                            /// Description
                            Text(
                              plan.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// Select Button
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected ? Colors.black : Colors.white,
                                  foregroundColor: isSelected ? Colors.white : Colors.black,
                                  shape: const StadiumBorder(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: isSelected ? 15 : 12,
                                  ),
                                  elevation: isSelected ? 2 : 5,
                                ),
                                onPressed: isSelected
                                    ? null
                                    : () {
                                  setState(() {
                                    membership = plan.membershipId;
                                    amount = plan.price;
                                    MyColors.MemberShipId = plan.membershipId;
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isSelected ? 'Selected ${plan.name}' : 'Choose ${plan.name}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.check_circle,
                                      size: isSelected ? 26 : 22,
                                      color: isSelected ? Colors.white : MyColors.DarkBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      }),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Obx(() {
          return custom_buttons(
              loading: controller.memberShipLoader1.value,
              voidCallback: () {
                  if(membership == ""){

                  customSnackBar("please select any plan".tr);
                }else{
                    showMpesaPaymentSheet(context,amount,membership,widget.type);
                  /*  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MPesaPaymentFlow()),
                    );*/
                  /*  MyColors.MemberShipId = membership;  // ensure global value is also synced
                  controller.buyMemberShip(membership.toString(),"numberadd kro",amount, widget.type,"Membership");*/
                }
              },
              text: "Get ".tr);
        }),
      ),
    );
  }

  /// Helper widget for info rows
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  BoxDecoration _getPlanDecoration(String type) {
    switch (type.toLowerCase()) {
      case "gold":
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFF9A602)], // gold shades
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        );

      case "silver":
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)], // silver shades
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        );

      case "bronze":
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFCD7F32), Color(0xFFAD6F25)], // bronze shades
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        );

      default:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff019ba5), Color(0xff017f91)], // default blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        );
    }
  }




}

void showMpesaPaymentSheet(BuildContext context,String amount,membershipId,screeType) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>  MpesaPaymentSheet(amount: amount,screenType: screeType,membershipId: membershipId,),
  );
}

class MpesaPaymentSheet extends StatefulWidget {
  final String amount,membershipId,screenType;
  const MpesaPaymentSheet({super.key, required this.amount, required this.membershipId, required this.screenType});

  @override
  State<MpesaPaymentSheet> createState() => _MpesaPaymentSheetState();
}

class _MpesaPaymentSheetState extends State<MpesaPaymentSheet> {
  AuthController controller = Get.find<AuthController>();

  final TextEditingController _mobileController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Obx(
          () {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                _buildHeader(theme),

                // Payment Details
                _buildPaymentDetails(theme),

                // Mobile Input
                _buildMobileInput(theme),

                // Payment Button
                _buildPaymentButton(theme, size),

                const SizedBox(height: 24),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Text(
            'M-Pesa Payment',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Please enter your M-Pesa mobile number',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.amount} KSh',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }



  Widget _buildMobileInput(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile Number',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter mobile number', // Changed to Kenyan format
              prefixIcon: const Icon(Icons.smartphone_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => _mobileController.clear(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant,
              errorText: _errorText,
            ),
            style: theme.textTheme.bodyLarge,
            onChanged: (value) => setState(() => _errorText = null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mobile number';
              }
            /*  if (!RegExp(r'^\+254\d{9}$').hasMatch(value)) { // Updated regex
                return 'Invalid Kenyan number'; // Updated error message
              }*/
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll receive a request to enter your PIN to complete payment',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _handlePayment() async {
    if (_mobileController.text.isEmpty) {
      setState(() => _errorText = 'Please enter mobile number');
      return;
    }

   /* if (!RegExp(r'^\+254\d{9}$').hasMatch(_mobileController.text)) { // Updated regex
      setState(() => _errorText = 'Invalid Kenyan number'); // Updated error message
      return;
    }*/

    controller.buyMemberShip(widget.membershipId.toString(),widget.amount.toString(),_mobileController.text, widget.screenType,"Membership");

  }
  Widget _buildPaymentButton(ThemeData theme, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.memberShipLoader1.value ? null : _handlePayment,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 2,
          ),
          icon: controller.memberShipLoader1.value
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(Icons.payment_rounded),
          label: Text(
            controller.memberShipLoader1.value ? 'Processing...' : 'Pay by M-Pesa',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }

}

