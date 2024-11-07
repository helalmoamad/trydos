import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_collection_in_cart_page2.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/my_gallery3d_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';

import '../../../../service/language_service.dart';

class CartPage2 extends StatelessWidget {
  final GetCartShippingItemsModel getCartShippingItemsModel;

  const CartPage2({Key? key, required this.getCartShippingItemsModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> changeCartCollections = ValueNotifier(false);

    int indexes = 0;
    List<String> groupCartkeys = [];
    List<String> groupOLdCartkeys = [];
    int? tapIndex;
    bool visibleAllCollection = true;
    List<String> visibleCollectionCartGroups = [];
    List<String> visibleCollectionOldCartGroups = [];
    TextEditingController quantityController = TextEditingController();
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            if (previous.cartCollection!.values.length !=
                    current.cartCollection!.values.length ||
                previous.cartCollection!.values.length !=
                    current.cartCollection!.values.length) {
              visibleAllCollection = true;
              return true;
            }
            return previous.getCartItemsStatus != current.getCartItemsStatus ||
                previous.getCurrencyForCountryModel !=
                    current.getCurrencyForCountryModel ||
                previous.deleteItemInCartStatus !=
                    current.deleteItemInCartStatus ||
                previous.convertItemFromOldcartToCartStatus !=
                    current.convertItemFromOldcartToCartStatus ||
                previous.addItemInCartStatus != current.addItemInCartStatus ||
                previous.updateItemInCartStatus !=
                    current.updateItemInCartStatus ||
                previous.cartCollection!.values !=
                    current.cartCollection!.values ||
                previous.hideItemInOldCartStatus !=
                    current.hideItemInOldCartStatus ||
                previous.getOldCartItemsStatus !=
                    current.getOldCartItemsStatus ||
                previous.oldcartCollection?.values !=
                    current.oldcartCollection?.values;
          },
          builder: (context, state) {
            double totlaPrice = 0;
            String? priceSymbol;
            state.cartCollection!.values.toList().forEach((element) {
              priceSymbol =
                  state.getCurrencyForCountryModel!.data!.currency!.symbol ??
                      "";
              // (element.first.priceFormatted?.split(' ') ?? ['\$', '\$'])[1];
              element.forEach((element) {
                totlaPrice =
                    totlaPrice + element.offerPrice! * element.quantity!;
              });
            });
            totlaPrice = totlaPrice *
                state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;
            if (state.getCartItemsStatus == GetCartItemsStatus.failure &&
                (state.cartCollection == null ||
                    state.cartCollection!.isEmpty)) {
              return Center(child: TryAgainWidget(tryAgain: () {
                BlocProvider.of<HomeBloc>(context).add(GetCartItemEvent());
              }));
            }

            if (state.getCartShippingItemsModel == null &&
                state.getCartItemsStatus != GetCartItemsStatus.success) {
              return Center(
                child: TrydosLoader(),
              );
            }
            groupCartkeys = state.cartCollection!.keys.toList();
            groupOLdCartkeys = state.oldcartCollection!.keys.toList();
            if (visibleAllCollection) {
              visibleCollectionCartGroups = state.cartCollection!.keys.toList();
              visibleCollectionOldCartGroups =
                  state.oldcartCollection!.keys.toList();
              visibleAllCollection = false;
            }

            return ValueListenableBuilder<bool>(
                valueListenable: changeCartCollections,
                builder: (context, visible, _child) {
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 60),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: 1.sw - 20,
                        height: 85.h,
                        child: Column(
                          children: [
                            DottedBorder(
                              radius: Radius.circular(10),
                              borderType: BorderType.RRect,
                              strokeCap: StrokeCap.round,
                              strokeWidth: 0.5,
                              color: Color(0xff707070),
                              dashPattern: [3, 3],
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: 40.h,
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: SvgPicture.asset(
                                        AppAssets.backIconArrowSvg,
                                        height: 20,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "      Your Shopping Bag",
                                      style: context.textTheme.bodyMedium?.ra
                                          .copyWith(
                                              color: const Color(0xff505050),
                                              letterSpacing: 0.18,
                                              fontSize: 13,
                                              height: 1.33),
                                    ),
                                    Spacer(),
                                    SvgPicture.asset(
                                      AppAssets.bagsSvg,
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xffF8F8F8)),
                              margin: EdgeInsets.only(top: 5.h),
                              height: 30.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AppAssets.countItemSvg),
                                  Text(" ${state.cartCollection!.length} ",
                                      style: context.textTheme.bodyMedium?.mr
                                          .copyWith(
                                              fontSize: 13,
                                              color: const Color(0xff5D5C5D),
                                              letterSpacing: 0.18,
                                              height: 1.33)),
                                  Text(
                                    "item ",
                                    style: context.textTheme.bodyMedium?.la
                                        .copyWith(
                                            fontSize: 13,
                                            color: const Color(0xff8D8D8D),
                                            letterSpacing: 0.18,
                                            height: 1.33),
                                  ),
                                  Text(
                                    "${totlaPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} ",
                                    style: context.textTheme.bodyMedium?.mr
                                        .copyWith(
                                            fontSize: 13,
                                            color: const Color(0xff5D5C5D),
                                            letterSpacing: 0.18,
                                            height: 1.33),
                                  ),
                                  Text(
                                    " ${priceSymbol ?? '\$'} ",
                                    style: context.textTheme.bodyMedium?.la
                                        .copyWith(
                                            fontSize: 13,
                                            color: const Color(0xff8D8D8D),
                                            letterSpacing: 0.18,
                                            height: 1.33),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 49.h,
                        color: Color(0xffF4F4F4),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.topCenter,
                        color: Color(0xffFEFEFE),
                        width: 1.sw - 20,
                        height: 720.h,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            if (state.cartCollection == null ||
                                state.cartCollection!.isEmpty) ...{
                              Center(
                                child: Container(
                                  height: 40,
                                  child: MyTextWidget("no item in cart"),
                                ),
                              )
                            } else ...{
                              productCollectionInCartPage2(
                                cartCollection: state.cartCollection,
                                changeCartCollections: changeCartCollections,
                                oldcartCollection: state.oldcartCollection,
                                groupCartkeys: groupCartkeys,
                                indexes: indexes,
                                priceSymbol: priceSymbol,
                                isOLdCart: false,
                                quantityController: quantityController,
                                tapIndexs: tapIndex ?? 0,
                                visibleCollectionGroups:
                                    visibleCollectionCartGroups,
                              )
                            },
                            SizedBox(
                              height: 20,
                            ),
                            state.oldcartCollection != null
                                ? !state.oldcartCollection!.isEmpty
                                    ? Center(
                                        child: MyTextWidget(
                                        "Old Cart",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 24),
                                      ))
                                    : SizedBox.shrink()
                                : SizedBox.shrink(),
                            state.oldcartCollection != null
                                ? !state.oldcartCollection!.isEmpty
                                    ? Container(
                                        height: 70.h,
                                        padding: EdgeInsets.all(20.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  GetIt.I<HomeBloc>().add(
                                                      HideItemInOldCartEvent(
                                                    hideAll: true,
                                                  ));
                                                },
                                                child: MyTextWidget(
                                                  "Hide All",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 14),
                                                ))
                                          ],
                                        ))
                                    : SizedBox.shrink()
                                : SizedBox.shrink(),
                            productCollectionInCartPage2(
                              cartCollection: state.cartCollection,
                              changeCartCollections: changeCartCollections,
                              oldcartCollection: state.oldcartCollection,
                              groupCartkeys: groupOLdCartkeys,
                              isOLdCart: true,
                              indexes: indexes,
                              priceSymbol: priceSymbol,
                              quantityController: quantityController,
                              tapIndexs: tapIndex ?? 0,
                              visibleCollectionGroups:
                                  visibleCollectionOldCartGroups,
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}
