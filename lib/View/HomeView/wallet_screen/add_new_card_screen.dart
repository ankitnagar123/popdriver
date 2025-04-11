/*
import 'dart:math' as math;
import 'package:ColumbiaTaxi/controller/wallet_controller/payment_controller.dart';
import 'package:ColumbiaTaxi/utils/colors.dart';
import 'package:ColumbiaTaxi/utils/custom_button.dart';
import 'package:ColumbiaTaxi/utils/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';


class AddNewCardScreen extends StatefulWidget {
  AddNewCardScreen({Key? key}) : super(key: key);

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {

  PaymentController controller = Get.put(PaymentController());

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String cvv = '';
  bool showBack = false;

  late FocusNode _focusNode;
  TextEditingController cardNumberCtrl = TextEditingController();
  TextEditingController expiryFieldCtrl = TextEditingController();

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }


  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 110.0,
              backgroundColor: MyColors.primary,
              floating: false,
              pinned: true,
              centerTitle: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: Text(
                  "Add New Card",
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      CreditCardWidget(
                        glassmorphismConfig:
                        useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        bankName: ' ',
                        frontCardBorder:
                        !useGlassMorphism
                            ? Border.all(color: Colors.grey)
                            : null,
                        backCardBorder:
                        !useGlassMorphism
                            ? Border.all(color: Colors.grey)
                            : null,
                        showBackView: isCvvFocused,
                        obscureCardNumber: true,
                        obscureCardCvv: true,
                        isHolderNameVisible: true,
                        cardBgColor: MyColors.primary,
                        backgroundImage:
                        useBackgroundImage ? 'assets/card_bg.png' : null,
                        isSwipeGestureEnabled: true,
                        onCreditCardWidgetChange:
                            (CreditCardBrand creditCardBrand) {},
                        customCardTypeIcons: <CustomCardTypeIcon>[
                          // CustomCardTypeIcon(
                          //   cardType: CardType.mastercard,
                          //   cardImage: Image.asset(
                          //     'assets/mastercard.png',
                          //     height: 48,
                          //     width: 48,
                          //   ),
                          // ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: TextFormField(
                              controller: cardNumberCtrl,
                              decoration: InputDecoration(
                                hintText: 'Card Number',
                                counter: Offstage(),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: MyColors.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: MyColors.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 16,
                              onChanged: (value) {
                                final newCardNumber = value.trim();
                                var newStr = '';
                                final step = 4;

                                for (var i = 0; i < newCardNumber.length;
                                i += step) {
                                  newStr += newCardNumber.substring(
                                      i,
                                      math.min(i + step, newCardNumber.length));
                                  if (i + step < newCardNumber.length)
                                    newStr += ' ';
                                }

                                setState(() {
                                  cardNumber = newStr;
                                });
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5
                            ),
                            child: TextFormField(
                              controller: expiryFieldCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Card Expiry'
                                ,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: MyColors.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: MyColors.primary,
                                    width: 2.0,
                                  ),
                                ),),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                DateTextFormatter()
                              ],
                              onChanged: (value) {
                                List<int> expiryDates = getExpiryDate(value!);


                                print("month card=${expiryDates[0]}");
                                print("year card=${expiryDates[1]}");

                                setState(() {
                                  print("month card=${expiryDates[0]}");
                                  print("year card=${expiryDates[1]}");
                                  String data = "${expiryDates[0]}" + "/" +
                                      "${expiryDates[1]}";

                                  expiryDate = data;
                                });
                              },
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Card Holder Name',

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: MyColors.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: MyColors.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  cardHolderName = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: TextFormField(

                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(hintText: 'CVV',
                                counter: Offstage(),
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  borderSide: new BorderSide(
                                    color: MyColors.primary,
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: MyColors.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: MyColors.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              maxLength: 3,
                              onChanged: (value) {
                                setState(() {
                                  cvv = value;
                                });
                              },
                              focusNode: _focusNode,
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Obx(() {
                            return InkWell(
                              onTap: () {
                                _onValidate();
                              },
                              child:controller.addLoader.value?
                              Center(
                                child: myIndicator(),
                              ):
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: MyColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15),
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    package: 'flutter_credit_card',
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),

                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _onValidate() {
    print(expiryDate);
    String? datecheck = validateDate(expiryDate);

    if (cardNumber.isEmpty) {
      customSnackBar("Enter card number");
    } else if (expiryDate.isEmpty) {
      customSnackBar("Enter expiry date");
    } else if (datecheck != null) {
      customSnackBar("${datecheck}");
    }
    else if (cardHolderName.isEmpty) {
      customSnackBar("Enter card holder name");
    } else if (cvv.isEmpty) {
      customSnackBar("Enter cvv code");
    } else {
      controller.addCard(context,cardHolderName, cvv, expiryDate, cardNumber);
    }
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.fieldReq;
    }
    int year;
    int month;
    // The value contains a forward slash if the month and year has been
    // entered.
    if (value.contains(new RegExp(r'(/)'))) {
      var split = value.split(new RegExp(r'(/)'));
      // The value before the slash is the month while the value to right of
      // it is the year.
      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      // Only the month was entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }

    if ((month < 1) || (month > 12)) {
      // A valid month is between 1 (January) and 12 (December)
      return 'Expiry month is invalid';
    }

    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      // We are assuming a valid should be between 1 and 2099.
      // Note that, it's valid doesn't mean that it has not expired.
      return 'Expiry year is invalid';
    }

    if (!hasDateExpired(month, year)) {
      return "Card has expired";
    }
    return null;
  }

  static bool hasDateExpired(int month, int year) {
    return isNotExpired(year, month);
  }

  static bool isNotExpired(int year, int month) {
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(new RegExp(r'(/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month
    // has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    // The year has passed if the year we are currently is more than card's
    // year
    return fourDigitsYear < now.year;
  }

  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

}

class Strings {
  static const String appName = 'Payment Card Demo';
  static const String fieldReq = 'This field is required';
  static const String numberIsInvalid = 'Card is invalid';
  static const String pay = 'Validate';
}

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
    final newValueString = newValue.text;
    String valueToReturn = '';

    for (int i = 0; i < newValueString.length; i++) {
      if (newValueString[i] != '/') valueToReturn += newValueString[i];
      var nonZeroIndex = i + 1;
      final contains = valueToReturn.contains(RegExp(r'\/'));
      if (nonZeroIndex % 2 == 0 &&
          nonZeroIndex != newValueString.length &&
          !(contains)) {
        valueToReturn += '/';
      }
    }
    return newValue.copyWith(
      text: valueToReturn,
      selection: TextSelection.fromPosition(
        TextPosition(offset: valueToReturn.length),
      ),
    );
  }
}

//
// SizedBox(
// height: 50.0,
// ),
// CustomTextField(
// controller: cardNoController,
// hintText: "Enter Card Number",
// secureText: false,textCapitalization: TextCapitalization.none,
// icon: Icon(
// Icons.payment,
// color: secondryColor,
// ),
// keyboardType: TextInputType.number,
// ),
// SizedBox(
// height: 20.0,
// ),
// CustomTextField(
// controller: cardOwnerController,
// hintText: "Card Owner",
// secureText: false,textCapitalization: TextCapitalization.none,
// icon: Icon(
// Icons.person,
// color: secondryColor,
// ),
// ),*/
