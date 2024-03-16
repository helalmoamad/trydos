import 'package:flutter/material.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';

import '../../../app/app_draggable_sheet.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (error) {
      debugPrint(error.toString());
    };
    return DragToPop(
      xValueToStartPoping: 70,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Scaffold(
              appBar: TrydosAppBar(
                appBarParams: AppBarParams(
                    backIconColor: Colors.black, withShadow: false),
              ),
              backgroundColor: Color(0xffF4F4F4),
              body: Container()),
             ProductDetailsBottomSheet()
        ],
      ),
    );
  }
}
