// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// class MPesaPaymentFlow extends StatefulWidget {
//   const MPesaPaymentFlow({super.key});
//
//   @override
//   State<MPesaPaymentFlow> createState() => _MPesaPaymentFlowState();
// }
//
// class _MPesaPaymentFlowState extends State<MPesaPaymentFlow> {
//   final _formKey = GlobalKey<FormState>();
//   final _pinController = TextEditingController();
//   int _currentStep = 0;
//   final double amountTsh = 83495.28;
//   final double amountCad = 47.50;
//   final String recipient = 'GreatShop.com';
//   final String mobileNumber = '+255 736 826 092';
//   final String receiptNo = '00012345678';
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('M-Pesa Payment'),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             Widget content;
//             switch (_currentStep) {
//               case 0:
//                 content = _buildPaymentConfirmation();
//                 break;
//               case 1:
//                 content = _buildPinEntry();
//                 break;
//               case 2:
//                 content = _buildProcessing();
//                 break;
//               case 3:
//                 content = _buildSuccessScreen();
//                 break;
//               default:
//                 content = _buildPaymentConfirmation();
//             }
//
//             if (constraints.maxWidth > 600) {
//               return Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: constraints.maxWidth * 0.2,
//                 ),
//                 child: content,
//               );
//             }
//             return content;
//           },
//         ),
//       ),
//     );
//   }
//
//   // Keep all the _build* methods exactly the same as previous version
//   // (payment confirmation, pin entry, processing, success screen)
//   // ...
//
//   void _submitPayment() {
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() => _currentStep = 2);
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           setState(() => _currentStep = 3);
//         }
//       });
//     }
//   }
// }
//   Widget _buildPinEntry() {
//     return Form(
//       key: _formKey,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Enter M-Pesa PIN to confirm:',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _pinController,
//               keyboardType: TextInputType.number,
//               obscureText: true,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(4),
//               ],
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: '4-digit PIN',
//                 prefixIcon: Icon(Icons.lock_outline),
//               ),
//               validator: (value) {
//                 if (value?.length != 4) {
//                   return 'Please enter a valid 4-digit PIN';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _submitPayment,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text('COMPLETE PAYMENT'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProcessing() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 20),
//           Text(
//             'Transaction in progress...',
//             style: TextStyle(fontSize: 18),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSuccessScreen() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.check_circle,
//             color: Colors.green[700],
//             size: 80,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Payment of ${NumberFormat.currency(symbol: 'TSh ', decimalDigits: 2).format(amountTsh)} to $recipient has been made successfully.',
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 30),
//           _buildDetailRow('Mobile Number:', mobileNumber),
//           _buildDetailRow('Receipt Number:', receiptNo),
//           const SizedBox(height: 40),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('CLOSE'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(width: 10),
//           Text(value),
//         ],
//       ),
//     );
//   }
//
//   void _submitPayment() {
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() => _currentStep = 2);
//       // Simulate payment processing
//       Future.delayed(const Duration(seconds: 2), () {
//         setState(() => _currentStep = 3);
//       });
//     }
//   }
