import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;

import 'package:trydos/features/home/presentation/widgets/product_listing/product_colors_panel.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ColorImagesPanel extends StatelessWidget {
  const ColorImagesPanel(
      {super.key,
      required this.panelController,
      required this.productItem,
      required this.currentActiveTab,
      required this.panelControllerForCart,
      required this.visibleRedeem});
  final ValueNotifier<bool> visibleRedeem;
  final PanelController panelController;
  final PanelController panelControllerForCart;
  final product.Products productItem;
  final ValueNotifier<int> currentActiveTab;
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return SlidingUpPanel(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        minHeight: 0,
        controller: panelController,
        maxHeight: 1.sh - 70,
        backdropEnabled: true,
        panelBuilder: (scrollController) {
          return panelBuilderContent(scrollController);
        });
  }

  Widget panelBuilderContent(ScrollController sc) {
    final ValueNotifier<bool> visibleRedeem = ValueNotifier(false);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30.r)),
        color: Colors.white,
      ),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                height: 2,
                width: 40,
                decoration: BoxDecoration(color: Color(0xffC4C2C2)),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                  child: GridView.builder(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                addSemanticIndexes: false,
                cacheExtent: 0,
                controller: sc,
                itemCount: productItem.syncColorImages?.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1.sw / (397 * 2),
                    crossAxisCount: 2),
                itemBuilder: (context, index) => Material(
                  color: Colors.transparent,
                  child: ProductColorPanal(
                    panelController: panelController,
                    panelControllerForCart: panelControllerForCart,
                    currentActiveTab: currentActiveTab,
                    colorImages: productItem.syncColorImages?[index].images
                            ?.map((e) => e.filePath ?? "")
                            .toList() ??
                        [],
                    visibleRedeem: visibleRedeem,
                    productItem: productItem,
                    fromDetailsPage: true,
                  ),
                ),
              ))
            ],
          )),
    );
  }
}
