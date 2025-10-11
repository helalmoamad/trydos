import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import '../../data/models/get_orders_model.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class OrderWidget extends StatelessWidget {
  final List<OrderListModel> orders;
  final int index;
  final void Function() onTapViewDetails;
  const OrderWidget(
      {super.key,
      required this.orders,
      required this.index,
      required this.onTapViewDetails});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Container(
        width: double.infinity,
        color: (index % 2 == 0)
            ? const Color.fromARGB(255, 231, 231, 231)
            : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 28,
              width: double.infinity,
              color: const Color.fromARGB(255, 99, 99, 99),
              child: Center(
                child: Text(
                  '# ${index + 1}  ${'Order Summary'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1,
                  ),
                ),
              ),
            ),

            ///////////////////
            const SizedBox(
              height: 15,
            ),
            ////
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${'Payment Status'} : ${orders[index].paymentStatus}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: context.textTheme.bodyMedium?.br.copyWith(
                    color: (orders[index].paymentStatus.toString() == 'paid') ||
                            (orders[index].paymentStatus.toString() ==
                                'partial_paid')
                        ? Colors.green
                        : Colors.red,
                    letterSpacing: 0.18,
                    fontSize: 13,
                    height: 1,
                  ),
                ),
              ),
            ),
            ////////////////
            const SizedBox(
              height: 8,
            ),
            ///////////////////////////
            buildOrderFirstDetailsWidget(
              context: context,
              title: 'Shipping Cost :',
              isBold: true,
              value: orders[index].shippingCost == null
                  ? 'No Data Now'
                  : orders[index].shippingCost.toString() == ''
                      ? 'No Data Now'
                      : orders[index].shippingCost.toString(),
            ),
            const SizedBox(
              height: 8,
            ),
            /////////////////////////
            buildOrderFirstDetailsWidget(
                context: context,
                title: '${'Order Status'} :',
                value: orders[index].orderStatus.toString()),
            ///////////////////////
            const SizedBox(
              height: 8,
            ),
            ///////////////////////////
            buildOrderFirstDetailsWidget(
              context: context,
              title: '${'Order Amount'} :',
              value: orders[index].orderAmount.toString(),
            ),

            ///
            const SizedBox(
              height: 8,
            ),
            ////
            buildOrderFirstDetailsWidget(
              context: context,
              title: '${'Payment Method'} :',
              value: orders[index].paymentMethod.toString(),
            ),

            ///
            const SizedBox(
              height: 8,
            ),
            ////
            buildOrderFirstDetailsWidget(
              context: context,
              title: '${'Order unique id'} :',
              value: orders[index].id.toString(),
            ),

            ///
            const SizedBox(
              height: 8,
            ),
            ////
            buildOrderFirstDetailsWidget(
              context: context,
              title: '${'Created At'} :',
              value: orders[index].createdAt.toString().isEmpty
                  ? ''
                  : DateFormat("yyyy-MM-dd HH:mm:ss").format(
                      DateTime.parse(orders[index].createdAt.toString())
                          .toLocal()),
            ),

            ///
            const SizedBox(
              height: 25,
            ),
            ////
            Container(
              height: 40,
              width: double.infinity,
              color: const Color.fromARGB(255, 193, 164, 4),
              child: InkWell(
                onTap: onTapViewDetails,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: context.textTheme.bodyMedium?.br.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.18,
                        fontSize: 14,
                        height: 1,
                      ),
                    ),

                    //////////////////////////////
                    const SizedBox(
                      width: 10,
                    ),
                    //////////////////////////////////
                    const Icon(
                      Icons.visibility,
                      color: Colors.white,
                    ),
                    //////////////////////////////////
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget buildOrderFirstDetailsWidget({
    required String title,
    required String value,
    required BuildContext context,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: context.textTheme.bodyMedium?.br.copyWith(
                color: Colors.black,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.18,
                fontSize: 13,
                height: 1,
              ),
            ),
          ),
          /////
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: context.textTheme.bodyMedium?.br.copyWith(
                color: Colors.grey,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.18,
                fontSize: 13,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
