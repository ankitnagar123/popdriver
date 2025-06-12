/*
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
//
// import '../../../controller/wallet_controller/wallet_controller.dart';
//
// class Earninglist extends StatelessWidget {
//   final WalletController controller = Get.put(WalletController());
//
//   @override
//   Widget build(BuildContext context) {
//     controller.fetchTransaction1();
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Wallet History")),
//       body: Obx(() {
//         // if (controller.walletFetchHistoryLoader.value) {
//         //   return Center(child: CircularProgressIndicator());
//         // }
//
//         final chartData = controller.transactionList.map((e) => ChartData(
//           date: e.date,
//           earning: double.tryParse(e.driverEarning) ?? 0.0,
//         )).toList();
//
//         return Column(
//           children: [
//             // Graph
//             SizedBox(
//               height: 250,
//               child: SfCartesianChart(
//                 primaryXAxis: CategoryAxis(),
//                 title: ChartTitle(text: 'Earnings Graph'),
//                 series: <ChartSeries>[
//                   LineSeries<ChartData, String>(
//                     dataSource: chartData,
//                     xValueMapper: (ChartData data, _) => data.date,
//                     yValueMapper: (ChartData data, _) => data.earning,
//                     markerSettings: MarkerSettings(isVisible: true),
//                   )
//                 ],
//               ),
//             ),
//
//             // Transaction List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: controller.transactionList.length,
//                 itemBuilder: (context, index) {
//                   final item = controller.transactionList[index];
//                   return ListTile(
//                     title: Text("Booking ID: ${item.bookingId}"),
//                     subtitle: Text("Earning: $${item.driverEarning} • Status: ${item.status}"),
//                     trailing: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(item.date),
//                         Text(item.time, style: TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
//
// class ChartData {
//   final String date;
//   final double earning;
//
//   ChartData({required this.date, required this.earning});
// }
//
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mtaanidriver/utils/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../controller/wallet_controller/wallet_controller.dart';

class Earninglist extends StatelessWidget {
  final WalletController controller = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    controller.fetchTransaction();

    return Scaffold(
      appBar: AppBar(backgroundColor: MyColors.primary,
          centerTitle: true,
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/headLogo.png',
                height: 40,
              ),  Image.asset(
                color: Colors.white,
                'assets/images/stearing.png',
                height: 37,
              ),

            ],
          ),),
      body: Obx(() {
        // if (controller.walletFetchHistoryLoader.value) {
        //   return Center(child: CircularProgressIndicator());
        // }

        final chartData = controller.transactionList.map((e) => ChartData(
          date: _formatDate(e.date),
          earning: double.tryParse(e.driverEarning) ?? 0.0,
          bookingId: e.bookingId,
          time: e.time,
        )).toList();

        return Column(
          children: [
            // Interactive Graph
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: Colors.white,
                  header: '',
                  textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  format: 'point.x\nEarning: \$point.y',
                ),
                primaryXAxis: CategoryAxis(
                  labelRotation: -45,
                  majorGridLines: MajorGridLines(width: 0),
                  labelStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  axisLine: AxisLine(width: 1, color: Colors.grey[300]!),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                    text: 'Earnings (\$)',
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                  axisLine: AxisLine(width: 1, color: Colors.grey[300]!),
                  majorGridLines: MajorGridLines(
                    color: Colors.grey[100]!,
                    width: 1,
                  ),
                ),
                title: ChartTitle(
                  text: 'Daily Earnings Overview',
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primary
                  ),
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true,
                  enablePinching: true,
                ),
                series: <ChartSeries>[
                  LineSeries<ChartData, String>(
                    onPointTap: (pointInteractionDetails) {
                      if (pointInteractionDetails.pointIndex != null &&
                          pointInteractionDetails.seriesIndex != null &&
                          chartData.isNotEmpty) {
                        final data = chartData[pointInteractionDetails.pointIndex!];
                        _showPointDetails(context, data);
                      }
                    },
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.date,
                    yValueMapper: (ChartData data, _) => data.earning,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.diamond,
                      borderWidth: 2,
                      borderColor: Colors.blue[800]!,
                      color: Colors.white,
                      height: 8,
                      width: 8,
                    ),
                    color: Colors.blue[400]!,
                    width: 2.5,
               */
/*     gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade100,
                        Colors.blue.shade400,
                      ],
                      stops: [0.1, 0.9],
                    ),*//*

                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                      textStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    animationDuration: 1500,
                  )
                ],
                crosshairBehavior: CrosshairBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  lineType: CrosshairLineType.both,
                  lineColor: Colors.blue[100]!,
                  lineWidth: 2,
                ),
              ),
            ),

            // Transaction List
            Expanded(
              child: ListView.separated(
                itemCount: controller.transactionList.length,
                padding: EdgeInsets.all(12),
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = controller.transactionList[index];

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Handle item tap
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Indicator
                            Container(
                              width: 4,
                              height: 60,
                              decoration: BoxDecoration(
                                color:  Colors.green,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 16),

                            // Main Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.confirmation_number,
                                          size: 16,
                                          color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text(
                                        "Booking #${item.bookingId}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.euro_symbol,
                                          size: 12,
                                          color: Colors.green),
                                      SizedBox(width: 4),
                                      Text(
                                        "Earning \$${item.driverEarning}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),

                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:  Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                       Icons.check_circle
                                             ,
                                          size: 12,
                                          color: Colors.green
                                            ,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          item.status,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:Colors.green
                                               ,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Date & Time
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatDate(item.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    return date != null
        ? '${_monthAbbreviation[date.month]} ${date.day}'
        : dateString;
  }

  void _showPointDetails(BuildContext context, ChartData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Transaction Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Booking ID: ${data.bookingId}"),
            SizedBox(height: 8),
            Text("Date: ${data.date}"),
            SizedBox(height: 8),
            Text("Time: ${data.time}"),
            SizedBox(height: 8),
            Text("Earnings: \$${data.earning.toStringAsFixed(2)}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  final _monthAbbreviation = {
    1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
    7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
  };
}

class ChartData {
  final String date;
  final double earning;
  final String bookingId;
  final String time;

  ChartData({
    required this.date,
    required this.earning,
    required this.bookingId,
    required this.time,
  });
}
*/
