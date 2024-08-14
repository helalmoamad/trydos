import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/cart_page2.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';

class CartPage extends StatefulWidget {
  final bool? fromeFilters;
  const CartPage({Key? key, this.fromeFilters});
  @override
  State<CartPage> createState() => _CartPageState();
}

final ValueNotifier<bool> changeCartCollections = ValueNotifier(false);

class _CartPageState extends State<CartPage> {
  late HomeBloc homeBloc;
  late AppBloc appBloc;
  List<String> groupCartkeys = [];
  int? tapIndex;
  List<String> visibleCollectionGroups = [];
  TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.getCartItemsStatus != current.getCartItemsStatus ||
                  previous.cartCollection!.values !=
                      current.cartCollection!.values ||
                  previous.getCurrencyForCountryModel !=
                      current.getCurrencyForCountryModel,
              builder: (context, state) {
                if (state.getCartItemsStatus == GetCartItemsStatus.failure &&
                    (state.cartCollection == null ||
                        state.cartCollection!.isEmpty)) {
                  return Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: TryAgainWidget(tryAgain: () {
                      BlocProvider.of<HomeBloc>(context)
                          .add(GetCartItemEvent());
                    })),
                  );
                }
                if (state.cartCollection == null ||
                    state.cartCollection!.isEmpty) {
                  return Center(
                    child: Container(
                      child: MyTextWidget("no item in cart"),
                    ),
                  );
                }
                if (state.getCartShippingItemsModel == null &&
                    state.getCartItemsStatus != GetCartItemsStatus.success) {
                  return Center(
                    child: TrydosLoader(),
                  );
                }
                groupCartkeys = state.cartCollection!.keys.toList();
                visibleCollectionGroups = state.cartCollection!.keys.toList();
                double totlaPrice = 0;
                state.cartCollection!.values.toList().forEach((element) {
                  element.forEach((element) {
                    totlaPrice =
                        totlaPrice + element.offerPrice! * element.quantity!;
                  });
                });
                totlaPrice = totlaPrice *
                    state.getCurrencyForCountryModel!.data!.currency!
                        .exchangeRate!;
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 40.h,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if ((widget.fromeFilters ??
                                                false)) {
                                              context.pop();
                                            } else {
                                              appBloc.add(ChangeBasePage(0));
                                            }
                                          },
                                          child: SvgPicture.asset(
                                            AppAssets.backIconArrowSvg,
                                            height: 20,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          "      Your Shopping Bag",
                                          style: context.textTheme.subtitle1?.ra
                                              .copyWith(
                                                  color:
                                                      const Color(0xff505050),
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
                                      InkWell(
                                          onTap: () {
                                            HelperFunctions.slidingNavigation(
                                                context,
                                                CartPage2(
                                                  getCartShippingItemsModel: state
                                                      .getCartShippingItemsModel!,
                                                ));
                                          },
                                          child: SvgPicture.asset(
                                              AppAssets.countItemSvg)),
                                      Text(" ${state.cartCollection!.length} ",
                                          style: context.textTheme.subtitle1?.mr
                                              .copyWith(
                                                  fontSize: 13,
                                                  color:
                                                      const Color(0xff5D5C5D),
                                                  letterSpacing: 0.18,
                                                  height: 1.33)),
                                      Text(
                                        "item ",
                                        style: context.textTheme.subtitle1?.la
                                            .copyWith(
                                                fontSize: 13,
                                                color: const Color(0xff8D8D8D),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                      ),
                                      Text(
                                        "${totlaPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} ",
                                        style: context.textTheme.subtitle1?.mr
                                            .copyWith(
                                                fontSize: 13,
                                                color: const Color(0xff5D5C5D),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                      ),
                                      Text(
                                        "${state.getCurrencyForCountryModel!.data!.currency!.symbol ?? ""} ",
                                        style: context.textTheme.subtitle1?.la
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
                            height: 50.h,
                            color: Color(0xffF4F4F4),
                          ),
                          Container(
                            color: Color.fromARGB(255, 255, 255, 255),
                            child: Container(
                              height: 648.h,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 0),
                                shrinkWrap: true,
                                itemCount: state.cartCollection!.length,
                                itemBuilder: (context, index) {
                                  double price = 0;
                                  state.cartCollection!.values
                                      .toList()[index]
                                      .forEach((element) {
                                    price = price +
                                        element.offerPrice! * element.quantity!;
                                  });
                                  price = price *
                                      state.getCurrencyForCountryModel!.data!
                                          .currency!.exchangeRate!;
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          tapIndex = index;
                                          if (visibleCollectionGroups.any(
                                              (element) =>
                                                  element ==
                                                  groupCartkeys[tapIndex!])) {
                                            visibleCollectionGroups.removeWhere(
                                                (element) =>
                                                    element ==
                                                    groupCartkeys[tapIndex!]);
                                          } else {
                                            visibleCollectionGroups
                                                .add(groupCartkeys[tapIndex!]);
                                          }

                                          changeCartCollections.value =
                                              !changeCartCollections.value;
                                        },
                                        child: Container(
                                            width: 1.sw - 20,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            margin: EdgeInsets.only(
                                                top: 5, bottom: 0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Color(0xffF8F8F8)),
                                            height: 48.h,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  child: SvgNetworkWidget(
                                                    svgUrl: state
                                                            .cartCollection!
                                                            .values
                                                            .toList()[index][0]
                                                            .boutique!
                                                            .icon!
                                                            .filePath ??
                                                        "",
                                                    height: 30,
                                                  ),
                                                ),
                                                Spacer(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        AppAssets.countItemSvg),
                                                    Text(
                                                        "  ${state.cartCollection!.values.toList()[index].length} ",
                                                        style: context.textTheme
                                                            .subtitle1?.mr
                                                            .copyWith(
                                                                fontSize: 13,
                                                                color: const Color(
                                                                    0xff5D5C5D),
                                                                letterSpacing:
                                                                    0.18,
                                                                height: 1.33)),
                                                    Text(
                                                      "item ",
                                                      style: context.textTheme
                                                          .subtitle1?.la
                                                          .copyWith(
                                                              fontSize: 13,
                                                              color: const Color(
                                                                  0xff8D8D8D),
                                                              letterSpacing:
                                                                  0.18,
                                                              height: 1.33),
                                                    ),
                                                    Text(
                                                      " ${price.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}",
                                                      style: context.textTheme
                                                          .subtitle1?.mr
                                                          .copyWith(
                                                              fontSize: 13,
                                                              color: const Color(
                                                                  0xff5D5C5D),
                                                              letterSpacing:
                                                                  0.18,
                                                              height: 1.33),
                                                    ),
                                                    Text(
                                                      " ${state.getCurrencyForCountryModel!.data!.currency!.symbol ?? ""}",
                                                      style: context.textTheme
                                                          .subtitle1?.la
                                                          .copyWith(
                                                              fontSize: 13,
                                                              color: const Color(
                                                                  0xff8D8D8D),
                                                              letterSpacing:
                                                                  0.18,
                                                              height: 1.33),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: visibleCollectionGroups.any(
                                                  (element) =>
                                                      element ==
                                                      groupCartkeys[index])
                                              ? Color(0xffFFF4B5)
                                              : Colors.white,
                                        ),
                                        margin: EdgeInsets.only(top: 10),
                                        width: visibleCollectionGroups.any(
                                                (element) =>
                                                    element ==
                                                    groupCartkeys[index])
                                            ? 420.w
                                            : 0,
                                        height: visibleCollectionGroups.any(
                                                (element) =>
                                                    element ==
                                                    groupCartkeys[index])
                                            ? state
                                                        .cartCollection![
                                                            groupCartkeys[
                                                                index]]!
                                                        .length *
                                                    180.h +
                                                15.h
                                            : 0,
                                        child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: false,
                                          padding: EdgeInsets.only(top: 0),
                                          itemCount: state
                                              .cartCollection![
                                                  groupCartkeys[index]]!
                                              .length,
                                          itemBuilder: (context, indexes) {
                                            int quantity = state
                                                .cartCollection![groupCartkeys[
                                                    index]]![indexes]
                                                .quantity!;

                                            return visibleCollectionGroups.any(
                                                    (element) =>
                                                        element ==
                                                        groupCartkeys[index])
                                                ? InkWell(
                                                    onDoubleTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: MyTextWidget(
                                                                  "Change Quatity In Cart",
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr),
                                                              actions: <Widget>[
                                                                SingleChildScrollView(
                                                                  child: Column(
                                                                    children: [
                                                                      TextFormField(
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter
                                                                              .digitsOnly
                                                                        ],
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        controller:
                                                                            quantityController,
                                                                        enabled:
                                                                            true,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          AppElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              homeBloc.add(UpdateItemInCartEvent(currentSize: !state.cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty ? state.cartCollection![groupCartkeys[index]]![indexes].variations![0].size ?? "" : "", colorName: !state.cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty ? state.cartCollection![groupCartkeys[index]]![indexes].variations![0].color ?? "" : "", productId: state.cartCollection![groupCartkeys[index]]![indexes].productId.toString(), quantity: int.tryParse(quantityController.text)!, image: state.cartCollection?[groupCartkeys[index]]![indexes].image ?? "", cartId: state.cartCollection![groupCartkeys[index]]![indexes].id.toString(), boutiqueId: state.cartCollection![groupCartkeys[index]]![indexes].boutique!.id.toString()));
                                                                              Navigator.pop(context);
                                                                            },
                                                                            text:
                                                                                "Yes",
                                                                          ),
                                                                          AppElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            text:
                                                                                'Not Now',
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    },
                                                    onLongPress: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: MyTextWidget(
                                                                  "Delete Item From Cart",
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr),
                                                              actions: <Widget>[
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    AppElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        homeBloc.add(RemoveItemFormCartEvent(
                                                                            image: state.cartCollection![groupCartkeys[index]]![indexes].image ??
                                                                                '',
                                                                            currentSize: !state.cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty
                                                                                ? state.cartCollection![groupCartkeys[index]]![indexes].variations![0].size ?? ""
                                                                                : "",
                                                                            ColoName: !state.cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty ? state.cartCollection![groupCartkeys[index]]![indexes].variations![0].color ?? "" : "",
                                                                            productId: state.cartCollection![groupCartkeys[index]]![indexes].productId.toString(),
                                                                            itemId: state.cartCollection![groupCartkeys[index]]![indexes].id.toString(),
                                                                            boutiqueId: state.cartCollection![groupCartkeys[index]]![indexes].boutique!.id.toString()));
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      text:
                                                                          "Yes",
                                                                    ),
                                                                    AppElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      text:
                                                                          'Not Now',
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    },
                                                    onTap: () {
                                                      HelperFunctions
                                                          .slidingNavigation(
                                                              context,
                                                              ProductDetailsPage(
                                                                productItem: state.productITemForCart![state
                                                                    .cartCollection![
                                                                        groupCartkeys[
                                                                            index]]![
                                                                        indexes]
                                                                    .productId
                                                                    .toString()]!,
                                                              ));
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: index ==
                                                                  state.cartCollection![groupCartkeys[index]]!
                                                                          .length -
                                                                      1 //length
                                                              ? 30
                                                              : 0),
                                                      width: 1.sw,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(indexes ==
                                                                    state
                                                                            .getCartShippingItemsModel!
                                                                            .data!
                                                                            .cart!
                                                                            .length -
                                                                        1 //length
                                                                ? 15
                                                                : 15),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              offset: Offset(
                                                                  0,
                                                                  indexes == 0
                                                                      ? 0
                                                                      : indexes ==
                                                                              state.cartCollection![groupCartkeys[index]]!.length -
                                                                                  1
                                                                          ? -10
                                                                          : 10),
                                                              blurRadius: indexes ==
                                                                      state.cartCollection![groupCartkeys[index]]!.length -
                                                                          1
                                                                  ? 0
                                                                  : 5,
                                                              color: Color(
                                                                  0xffF3F3F3),
                                                              spreadRadius: indexes ==
                                                                      0
                                                                  ? 5
                                                                  : indexes ==
                                                                          state.cartCollection![groupCartkeys[index]]!.length -
                                                                              1
                                                                      ? 0
                                                                      : 10),
                                                        ],
                                                      ),
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                          bottom: 10.h,
                                                        ),
                                                        width: 400.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        height: 161.h,
                                                        child: Stack(
                                                          children: [
                                                            Positioned(
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  color: Color(
                                                                      0x707070),
                                                                ),
                                                                width: 110.w,
                                                                height: 161.h,
                                                                child:
                                                                    ProductDetailsImageWidget(
                                                                  withBackGroundShadow:
                                                                      false,
                                                                  withInnerShadow:
                                                                      false,
                                                                  imageFit:
                                                                      BoxFit
                                                                          .cover,
                                                                  imageUrl: state
                                                                      .cartCollection![
                                                                          groupCartkeys[
                                                                              index]]![
                                                                          indexes]
                                                                      .image,
                                                                  width: 110.w,
                                                                  height: 161.h,
                                                                  radius: 15,
                                                                ),
                                                              ),
                                                              left: 0,
                                                            ),
                                                            Positioned(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                10),
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    width: 50,
                                                                    height: 10,
                                                                    child: state.cartCollection![groupCartkeys[index]]![indexes].brand !=
                                                                            null
                                                                        ? SvgPicture
                                                                            .network(
                                                                            state.cartCollection![groupCartkeys[index]]![indexes].brand!.image!,
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            color:
                                                                                Color(
                                                                              0xff1A171B,
                                                                            ),
                                                                          )
                                                                        : SizedBox
                                                                            .shrink(),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    width:
                                                                        200.w,
                                                                    height: 16,
                                                                    child: Text(
                                                                        state.cartCollection![groupCartkeys[index]]![indexes].name ??
                                                                            "",
                                                                        style: context.textTheme.subtitle1?.ra.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color: const Color(
                                                                                0xff505050),
                                                                            letterSpacing:
                                                                                0.18,
                                                                            height:
                                                                                1.33)),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      width:
                                                                          200,
                                                                      height:
                                                                          16,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          SvgPicture
                                                                              .asset(
                                                                            color:
                                                                                Color(0xff8D8D8D),
                                                                            AppAssets.dressSvg,
                                                                            height:
                                                                                12,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            " Composed Of ${state.cartCollection![groupCartkeys[index]]![indexes].quantity} Piece",
                                                                            style: context.textTheme.subtitle1?.la.copyWith(
                                                                                fontWeight: FontWeight.w100,
                                                                                fontSize: 12,
                                                                                color: const Color(0xff707070),
                                                                                letterSpacing: 0.18,
                                                                                height: 1.33),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                  state
                                                                          .cartCollection![
                                                                              groupCartkeys[index]]![
                                                                              indexes]
                                                                          .variations
                                                                          .isNullOrEmpty
                                                                      ? SizedBox
                                                                          .shrink()
                                                                      : (state.cartCollection![groupCartkeys[index]]![indexes].variations![0].color == "" ||
                                                                              state.cartCollection![groupCartkeys[index]]![indexes].variations![0].color ==
                                                                                  null)
                                                                          ? SizedBox
                                                                              .shrink()
                                                                          : Container(
                                                                              margin: EdgeInsets.only(top: 5),
                                                                              alignment: Alignment.centerLeft,
                                                                              width: 200,
                                                                              height: 15,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    AppAssets.colorPickerSvg,
                                                                                    height: 12,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    "Color, ",
                                                                                    style: context.textTheme.subtitle1?.la.copyWith(fontWeight: FontWeight.normal, fontSize: 12, color: const Color(0xff505050), letterSpacing: 0.18, height: 1.33),
                                                                                  ),
                                                                                  Text(
                                                                                    !state.cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty ? state.cartCollection![groupCartkeys[index]]![indexes].variations![0].color ?? "" : "",
                                                                                    style: context.textTheme.subtitle1?.ra.copyWith(
                                                                                      fontSize: 13,
                                                                                      color: const Color((0xff505050)),
                                                                                      letterSpacing: 0.18,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                  state
                                                                          .cartCollection![
                                                                              groupCartkeys[index]]![
                                                                              indexes]
                                                                          .variations
                                                                          .isNullOrEmpty
                                                                      ? SizedBox
                                                                          .shrink()
                                                                      : (state.cartCollection![groupCartkeys[index]]![indexes].variations![0].size == "" ||
                                                                              state.cartCollection![groupCartkeys[index]]![indexes].variations![0].size ==
                                                                                  null)
                                                                          ? SizedBox
                                                                              .shrink()
                                                                          : Container(
                                                                              margin: EdgeInsets.only(top: 5),
                                                                              alignment: Alignment.centerLeft,
                                                                              width: 200,
                                                                              height: 15,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    AppAssets.sizeIconSvg,
                                                                                    height: 12,
                                                                                    color: Color(0xff48C8A8),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    "Size, ",
                                                                                    style: context.textTheme.subtitle1?.la.copyWith(fontWeight: FontWeight.normal, fontSize: 12, color: const Color(0xff505050), letterSpacing: 0.18, height: 1.33),
                                                                                  ),
                                                                                  Text(
                                                                                    !state.cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty ? state.cartCollection![groupCartkeys[index]]![indexes].variations![0].size ?? "" : "",
                                                                                    style: context.textTheme.subtitle1?.ra.copyWith(
                                                                                      fontSize: 13,
                                                                                      color: const Color((0xff505050)),
                                                                                      letterSpacing: 0.18,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                ],
                                                              ),
                                                              left: 130,
                                                            ),
                                                            Positioned(
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    (state.cartCollection![groupCartkeys[index]]![indexes].price! *
                                                                            quantity *
                                                                            state
                                                                                .getCurrencyForCountryModel!.data!.currency!.exchangeRate!)
                                                                        .toStringAsFixed(
                                                                            state.startingSetting?.decimalPointSetting ??
                                                                                2),
                                                                    style: context.textTheme.subtitle1?.ra.copyWith(
                                                                        decorationColor:
                                                                            Color(
                                                                                0xffC4C2C2),
                                                                        fontSize:
                                                                            18,
                                                                        color: Color(
                                                                            0xffC4C2C2),
                                                                        decoration:
                                                                            TextDecoration.lineThrough),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                      "${(state.cartCollection![groupCartkeys[index]]![indexes].offerPrice! * quantity * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} ",
                                                                      style: context
                                                                          .textTheme
                                                                          .subtitle1
                                                                          ?.br
                                                                          .copyWith(
                                                                        decorationColor:
                                                                            Color(0xff505050),
                                                                        fontSize:
                                                                            18,
                                                                        color: Color(
                                                                            0xff505050),
                                                                      )),
                                                                  Text(
                                                                    state
                                                                            .getCurrencyForCountryModel!
                                                                            .data!
                                                                            .currency!
                                                                            .symbol ??
                                                                        "",
                                                                    style: context
                                                                        .textTheme
                                                                        .subtitle1
                                                                        ?.ra
                                                                        .copyWith(
                                                                      decorationColor:
                                                                          Color(
                                                                              0xffc4c2c2),
                                                                      fontSize:
                                                                          9,
                                                                      color: Color(
                                                                          0xffc4c2c2),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              bottom: 15,
                                                              right: 10,
                                                            ),
                                                            Positioned(
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                width: 30,
                                                                height: 30,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            0.5,
                                                                        color: Color(
                                                                            0xff8D8D8D)),
                                                                    borderRadius:
                                                                        BorderRadiusDirectional.circular(
                                                                            20)),
                                                                child: Text(
                                                                  "${indexes + 1}",
                                                                  style: context
                                                                      .textTheme
                                                                      .subtitle1
                                                                      ?.ra
                                                                      .copyWith(
                                                                    decorationColor:
                                                                        Color(
                                                                            0xff8D8D8D),
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0xff8D8D8D),
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              top: 5,
                                                              right: 5,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox.shrink();
                                          },
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      );
                    });
              },
            )),
      ),
    );
  }
}
