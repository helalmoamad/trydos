import 'package:easy_localization/easy_localization.dart' as translate;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:local_hero/local_hero.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_comments_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_header.dart';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_more_options_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_share_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/select_size_sheet.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../../trydos_application.dart';
import '../../manager/home_bloc.dart';
import '../product_details_body/product_details_image_widget.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../product_listing/product_listing_image_widget.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final productListingModel.Products productItem;
  final int currentColor;
  final int boutiqueId;
  final int? qtyForproductWithoutVariant;
  final String boutiqueIcon;
  final String currentColorName;
  final String productSlugForTopic;
  final String productDescription;
  final String currentColornum;
  final PanelController panelController;
  final String productIdForCashData;
  final int countOfPieces;
  final bool? fromListingPage;
  final bool collectedAfterOrdering;
  final String maxAllowedToAddCart;
  final ValueNotifier<int> addToBagButtonShapeNotifier;
  final ValueNotifier<int>? tapIndexToAddProductToCart;
  final ValueNotifier<int> currentActiveTab;

  const ProductDetailsBottomSheet(
      {super.key,
      required this.productItem,
      this.tapIndexToAddProductToCart,
      required this.productIdForCashData,
      required this.collectedAfterOrdering,
      required this.panelController,
      required this.addToBagButtonShapeNotifier,
      required this.currentActiveTab,
      required this.boutiqueIcon,
      this.fromListingPage = false,
      required this.productSlugForTopic,
      required this.productDescription,
      required this.qtyForproductWithoutVariant,
      required this.maxAllowedToAddCart,
      required this.countOfPieces,
      required this.currentColornum,
      required this.boutiqueId,
      required this.currentColor,
      required this.currentColorName});

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  final ValueNotifier<List<String>> idsOfChatCardsToShare = ValueNotifier([]);

  final ValueNotifier<double> workOnBlurNotifier = ValueNotifier(10);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<String?> sizeIsNotAvailableNotifier = ValueNotifier(null);
  final ValueNotifier<String?> colorIsNotAvailableNotifier =
      ValueNotifier(null);
  final PageController pageController = PageController();
  List<String> colorsForEachProduct = [];
  List<String> sizesForEachProduct = [];
  bool requestToNotifyMeFormFirstSize = true;
  List<int> colorsQuantityForEachProduct = [];
  Gallery3DController? gallery3dControllerForCircles;
  List<productListingModel.SyncColorImage> syncColorImageList = [];
  List<String> images = [];
  late int currentIndexInSlider;
  final GlobalKey colorsGallerySliderKey = GlobalKey();
  Offset? offsetOfColorsGallerySlider;
  double valueOfBlur = 10;
  late HomeBloc homeBloc;
  List<double>? orginalHeight;
  List<double>? orginalWidth;
  bool isMoving = false;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);

    int currentColor = homeBloc.state.currentSelectedColorForEveryProduct[
            widget.productItem.productId.toString()] ??
        (widget.productItem.syncColorImages?.length ?? 0) ~/ 2;
    syncColorImageList = widget.productItem.syncColorImages ?? [];
    syncColorImageList.removeWhere((element) => element.images.isNullOrEmpty);
    syncColorImageList = [
      ...syncColorImageList,
      ...syncColorImageList,
    ];
    images = syncColorImageList.map((e) => e.images![0].filePath!).toList();
    orginalHeight = syncColorImageList
        .map((e) => double.parse(e.images![0].originalHeight!))
        .toList();
    orginalWidth = syncColorImageList
        .map((e) => double.parse(e.images![0].originalWidth!))
        .toList();

    gallery3dControllerForCircles =
        syncColorImageList.isNullOrEmpty || syncColorImageList.length < 3
            ? null
            : Gallery3DController(
                itemCount: syncColorImageList.length,
                autoLoop: false,
                minScale: (syncColorImageList.length) == 4
                    ? 0.7
                    : (syncColorImageList.length) <= 8
                        ? 0.55
                        : 0.4,
                initialIndex: currentColor,
                primaryshiftingOffsetDivision: (syncColorImageList.length) == 4
                    ? 4.5
                    : (syncColorImageList.length) <= 8
                        ? 1.6
                        : 1.6,
                scrollTime: 1);
    _focusNode.addListener(_onFocusChange);
    currentIndexInSlider = widget.currentColor;

    /*if (syncColorImageList.length <= 8) {
      currentIndexInSlider = 0;
    } else {
      currentIndexInSlider = syncColorImageList.length ~/ 4;
    }*/

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.addListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  final _focusNode = FocusNode();

  bool userWantToScrollHorizontally = false;

  bool firstOpenOfPanel = true;
  bool hide = false;

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
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.changeSizesForEveryProduct !=
          current.changeSizesForEveryProduct,
      builder: (context, state) {
        colorsQuantityForEachProduct =
            state.colorsQuantitiesForEachProduct ?? [];
        colorsForEachProduct = state.colorsForEachProduct ?? [];
        sizesForEachProduct = state.sizesForEachColor ?? [];
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ValueListenableBuilder<int>(
                valueListenable: widget.currentActiveTab,
                builder: (context, currentTab, _) {
                  return ValueListenableBuilder<double>(
                      valueListenable: workOnBlurNotifier,
                      child: SlidingUpPanel(
                        denyVericalSliding: currentTab == 3
                            ? (currentPosition) {
                                if (widget.panelController.panelPosition != 1) {
                                  return false;
                                }
                                if (gallery3dControllerForCircles != null) {
                                  if (offsetOfColorsGallerySlider == null) {
                                    final RenderBox renderBox =
                                        colorsGallerySliderKey.currentContext!
                                            .findRenderObject() as RenderBox;
                                    offsetOfColorsGallerySlider =
                                        renderBox.localToGlobal(Offset.zero);
                                  }
                                  if (currentPosition.dx >=
                                          offsetOfColorsGallerySlider!.dx &&
                                      currentPosition.dx <=
                                          (offsetOfColorsGallerySlider!.dx +
                                              200) &&
                                      currentPosition.dy >=
                                          (288.h + (35.w + 10.h)) &&
                                      currentPosition.dy <=
                                          (288.h + (70.w + 70.w + 10.h))) {
                                    userWantToScrollHorizontally = true;
                                  }
                                }
                                return userWantToScrollHorizontally;
                              }
                            : null,
                        controller: widget.panelController,
                        maxHeight: currentTab == -1
                            ? 78
                            : _focusNode.hasFocus
                                ? 575
                                : currentTab == 3
                                    ? 1.sh - 179 //330.h + 70.w + 305
                                    : 433,
                        minHeight: (widget.fromListingPage ?? false) ? 0 : 78,
                        onPanelClosed: () {
                          widget.tapIndexToAddProductToCart?.value = -1;
                          widget.addToBagButtonShapeNotifier.value = 0;

                          /*   if ((prefsRepository.isTokenExpired ??
                                      false ||
                                          prefsRepository.marketToken == "" ||
                                          prefsRepository.marketToken == null) &&
                                  GetIt.I<AuthBloc>().state.registerGuestStatus !=
                                      RegisterGuestStatus.loading) {
                                Future.delayed(
                                    Duration(seconds: 1),
                                    () => showDialog(
                                          context: context,
                                          builder: (context) => Center(
                                              child: Container(
                                            alignment: Alignment.center,
                                            width: 400,
                                            height: 300,
                                            child: AlertDialog(
                                              title: MyTextWidget(
                                                "${LocaleKeys.it_has_been_along_time_since_your_account.tr()}",
                                              ),
                                              actions: <Widget>[
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 300,
                                                  child: Row(
                                                    mainAxisAlignment: (prefsRepository
                                                                .isVerifiedPhonePeforeExpiredToken ??
                                                            false)
                                                        ? MainAxisAlignment.center
                                                        : MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      (prefsRepository
                                                                  .isVerifiedPhonePeforeExpiredToken ??
                                                              false)
                                                          ? SizedBox.shrink()
                                                          : Container(
                                                              alignment:
                                                                  Alignment.center,
                                                              width: 130,
                                                              child:
                                                                  AppElevatedButton(
                                                                textStyle: TextStyle(
                                                                    fontSize: 16),
                                                                onPressed: () async {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  String? deviceId =
                                                                      await HelperFunctions
                                                                          .getDeviceId();
            
                                                                  GetIt.I<AuthBloc>().add(RegisterGuestEvent(
                                                                      oldGuestUserId:
                                                                          prefsRepository
                                                                              .myMarketId
                                                                              .toString(),
                                                                      deviceId:
                                                                          deviceId!));
                                                                },
                                                                text:
                                                                    "${LocaleKeys.reset_your_count.tr()}",
                                                              ),
                                                            ),
                                                      Container(
                                                        alignment: Alignment.center,
                                                        width: 130,
                                                        child: AppElevatedButton(
                                                          textStyle:
                                                              TextStyle(fontSize: 16),
                                                          onPressed: () {
                                                            Navigator.of(context)
                                                                .pop();
            
                                                            Navigator.of(context)
                                                                .push(
                                                                    PageRouteBuilder(
                                                              pageBuilder: (context,
                                                                      animation,
                                                                      secondaryAnimation) =>
                                                                  RegistrationPage(
                                                                fromExpiredToken:
                                                                    true,
                                                              ),
                                                            ));
                                                          },
                                                          text:
                                                              '${LocaleKeys.go_to_log_in.tr()}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                                        ));
                                return;
                              }*/
                          /*homeBloc.add(
                            AddMultiItemsToCartEvent(
                              maxAllowed: widget.maxAllowedToAddCart,
                              boutiqueIcon: widget.boutiqueIcon,
                              productSlugForTopic: widget.productSlugForTopic,
                              boutiqueId: widget.boutiqueId,
                              products: widget.productItem,
                              id: widget.productItem.productId.toString(),
                            ),
                          );*/
                          /*   homeBloc.add(UpdateListOfItemForAddToCartEvent(
                                  imageForAddToCart: ImageForAddToCart(),
                                  operation: "remove",
                                  productId: widget.productItem.id.toString(),
                                  resetTheList: true));*/
                          sizeIsNotAvailableNotifier.value = null;
                          colorIsNotAvailableNotifier.value = null;
                          firstOpenOfPanel = true;
                          denySlidingBackForSlidingUpPanels.value = false;
                          widget.currentActiveTab.value = -1;
                        },
                        onPanelOpened: () {
                          if (sizesForEachProduct.length == 0) {
                            if (!colorsQuantityForEachProduct.isNullOrEmpty) {
                              if (colorsQuantityForEachProduct[
                                          widget.currentColor] ==
                                      0 &&
                                  !widget.collectedAfterOrdering) {
                                Future.delayed(
                                    Duration(milliseconds: 300),
                                    () => colorIsNotAvailableNotifier.value =
                                        colorsForEachProduct[
                                            widget.currentColor]);
                              } else {
                                colorIsNotAvailableNotifier.value = null;
                              }
                            } else {
                              colorIsNotAvailableNotifier.value = null;
                            }
                            if (!colorsQuantityForEachProduct.isNullOrEmpty) {
                              if (colorsQuantityForEachProduct[
                                          widget.currentColor] ==
                                      0 &&
                                  !widget.collectedAfterOrdering) {
                                Future.delayed(
                                    Duration(milliseconds: 300),
                                    () => colorIsNotAvailableNotifier.value =
                                        colorsForEachProduct[
                                            widget.currentColor]);
                              } else {
                                colorIsNotAvailableNotifier.value = null;
                              }
                            } else {
                              colorIsNotAvailableNotifier.value = null;
                            }
                          }
                          denySlidingBackForSlidingUpPanels.value = true;
                          firstOpenOfPanel = false;
                        },
                        color:
                            currentTab == 3 ? Colors.transparent : Colors.white,
                        boxShadow: [
                          CustomBoxShadow(
                              color: Colors.transparent,
                              offset: Offset(10.0, 10.0),
                              blurRadius: 10.0,
                              blurStyle: BlurStyle.outer)
                        ],
                        isDraggable: (currentTab == -1 ? false : true),
                        onPanelSlide: currentTab == 3
                            ? (percentOfOpenPart) {
                                workOnBlurNotifier.value =
                                    20 * (percentOfOpenPart - 0.6);
                                if (!firstOpenOfPanel &&
                                    percentOfOpenPart <=
                                        1 - ((290) / (330.h + 70.w + 305)) &&
                                    percentOfOpenPart >= 0.1) {
                                  widget.currentActiveTab.value = -1;
                                  return;
                                }
                                if (percentOfOpenPart == 1) {
                                  userWantToScrollHorizontally = false;
                                }
                              }
                            : null,
                        panelBuilder: (controller) => SingleChildScrollView(
                          child: Column(
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentTab == 3) ...{
                                Container(
                                    alignment: Alignment.center,
                                    width: 1.sw,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: ProductDetailsImageWidget(
                                            width: 198.w,
                                            height: 280.h,
                                            imageWidth: 320,
                                            imageHeight: 464,
                                            orginalWidth: double.tryParse(
                                                gallery3dControllerForCircles !=
                                                        null
                                                    ? orginalWidth![
                                                            currentIndexInSlider]
                                                        .toString()
                                                    : widget
                                                        .productItem
                                                        .images![0]
                                                        .originalWidth
                                                        .toString()),
                                            orginalHeight: double.tryParse(
                                                gallery3dControllerForCircles !=
                                                        null
                                                    ? orginalHeight![
                                                            currentIndexInSlider]
                                                        .toString()
                                                    : widget
                                                        .productItem
                                                        .images![0]
                                                        .originalHeight
                                                        .toString()),
                                            imageUrl:
                                                gallery3dControllerForCircles !=
                                                        null
                                                    ? images[
                                                        currentIndexInSlider]
                                                    : widget.productItem
                                                        .images![0].filePath,
                                          ),
                                        ),
                                        AnimatedPositioned(
                                            duration:
                                                Duration(milliseconds: 1700),
                                            top: isMoving ? -300 : 0,
                                            left:
                                                LanguageService.languageCode ==
                                                        "ar"
                                                    ? isMoving
                                                        ? -300
                                                        : (1.sw / 2) - 100.w
                                                    : null,
                                            right:
                                                LanguageService.languageCode !=
                                                        "ar"
                                                    ? isMoving
                                                        ? -300
                                                        : (1.sw / 2) - 100.w
                                                    : null,
                                            child: AnimatedOpacity(
                                              duration: Duration(seconds: 0),
                                              opacity: isMoving ? 1 : 0,
                                              child: ProductDetailsImageWidget(
                                                width: 200.w,
                                                height: 280.h,
                                                imageWidth: 320,
                                                imageHeight: 464,
                                                orginalWidth: double.tryParse(
                                                    gallery3dControllerForCircles !=
                                                            null
                                                        ? orginalWidth![
                                                                currentIndexInSlider]
                                                            .toString()
                                                        : widget
                                                            .productItem
                                                            .images![0]
                                                            .originalWidth
                                                            .toString()),
                                                orginalHeight: double.tryParse(
                                                    gallery3dControllerForCircles !=
                                                            null
                                                        ? orginalHeight![
                                                                currentIndexInSlider]
                                                            .toString()
                                                        : widget
                                                            .productItem
                                                            .images![0]
                                                            .originalHeight
                                                            .toString()),
                                                imageUrl:
                                                    gallery3dControllerForCircles !=
                                                            null
                                                        ? images[
                                                            currentIndexInSlider]
                                                        : widget
                                                            .productItem
                                                            .images![0]
                                                            .filePath,
                                              ),
                                            ))
                                      ],
                                    )),
                                5.verticalSpace,
                                Material(
                                  color: Colors.transparent,
                                  child: gallery3dControllerForCircles != null
                                      ? Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Gallery3D(
                                              key: colorsGallerySliderKey,
                                              // key: ValueKey('gallery3dControllerForCircles${widget.itemIndex}'),
                                              controller:
                                                  gallery3dControllerForCircles!,
                                              denyScrolling: false,
                                              width: 200,
                                              stopScrollingOnEdges:
                                                  (double primaryDelta) {
                                                return (primaryDelta <= 0 &&
                                                        gallery3dControllerForCircles!
                                                                .currentIndex ==
                                                            (syncColorImageList
                                                                        .length ~/
                                                                    2 -
                                                                1)) ||
                                                    (primaryDelta >= 0 &&
                                                        gallery3dControllerForCircles!
                                                                .currentIndex ==
                                                            0);
                                              },
                                              changingPagesScrollOffset: 0.1,
                                              isClip: false,
                                              onItemChanged: (index) {
                                                sizeIsNotAvailableNotifier
                                                    .value = null;
                                                colorIsNotAvailableNotifier
                                                    .value = null;

                                                Future.delayed(
                                                  Duration(milliseconds: 300),
                                                  () {
                                                    if (sizesForEachProduct
                                                            .length !=
                                                        0) {
                                                      requestToNotifyMeFormFirstSize =
                                                          true;
                                                    }

                                                    if (sizesForEachProduct
                                                            .length ==
                                                        0) {
                                                      if (colorsQuantityForEachProduct[
                                                                  index] ==
                                                              0 &&
                                                          !widget
                                                              .collectedAfterOrdering) {
                                                        colorIsNotAvailableNotifier
                                                                .value =
                                                            colorsForEachProduct[
                                                                index];
                                                      } else {
                                                        colorIsNotAvailableNotifier
                                                            .value = null;
                                                      }
                                                    }
                                                  },
                                                );

                                                currentIndexInSlider = index;
                                                homeBloc.add(
                                                    AddCurrentSelectedColorEvent(
                                                        currentSelectedColor:
                                                            index %
                                                                (syncColorImageList
                                                                        .length ~/
                                                                    2),
                                                        productId: widget
                                                            .productItem
                                                            .productId
                                                            .toString()));
                                              },
                                              itemConfig: GalleryItemConfig(
                                                  width: 70.w,
                                                  height: 70.w,
                                                  radius: 180,
                                                  isShowTransformMask: false,
                                                  shadows: const [
                                                    BoxShadow(
                                                      color: Color(0x19000000),
                                                      offset: Offset(0, 3),
                                                      blurRadius: 6,
                                                    ),
                                                  ]),
                                              itemBuilder: (context, index) {
                                                return Visibility(
                                                  visible: ((gallery3dControllerForCircles
                                                                      ?.currentIndex ??
                                                                  0) <
                                                              (syncColorImageList
                                                                      .length ~/
                                                                  2) &&
                                                          index <
                                                              (syncColorImageList
                                                                      .length ~/
                                                                  2)) ||
                                                      ((gallery3dControllerForCircles
                                                                      ?.currentIndex ??
                                                                  0) >=
                                                              (syncColorImageList
                                                                      .length ~/
                                                                  2) &&
                                                          index >=
                                                              (syncColorImageList
                                                                      .length ~/
                                                                  2)),
                                                  child:
                                                      ProductListingImageWidget(
                                                    // orginalHeight:
                                                    //     orginalHeight![index],
                                                    // orginalWidth:
                                                    //     orginalWidth![index],
                                                    width: 70.w,
                                                    height: 70.w,
                                                    imageWidth: 70,
                                                    imageHeight: 70,
                                                    imageUrl: images[index],
                                                    innerShadowYOffset: 4,
                                                    borderColor: index ==
                                                            currentIndexInSlider
                                                        ? Color(int.parse(
                                                            '0xff${widget.productItem.colors![currentIndexInSlider % widget.productItem.colors!.length].color!.substring(1)}'))
                                                        : Colors.white,
                                                    circleShape: true,
                                                  ),
                                                );
                                              }),
                                        )
                                      : SizedBox(
                                          height: 70.w,
                                        ),
                                ),
                                5.verticalSpace,
                              },
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  BlocBuilder<HomeBloc, HomeState>(
                                      buildWhen: (previous, current) =>
                                          previous.getCurrencyForCountryModel != current.getCurrencyForCountryModel ||
                                          previous.currentColorSizeForCart?[
                                                  "size"] !=
                                              current.currentColorSizeForCart?[
                                                  "size"] ||
                                          previous.currentSelectedColorForEveryProduct !=
                                              current
                                                  .currentSelectedColorForEveryProduct ||
                                          previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                                              current
                                                  .getProductDetailWithoutSimilarRelatedProductsStatus,
                                      builder: (context, state) {
                                        print(
                                            "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${widget.productItem.price!}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!}");
                                        return ProductDetailsSheetHeader(
                                          shippingCost:
                                              widget.productItem.shippingCost ??
                                                  0,
                                          decimalPoint: state.startingSetting
                                                  ?.decimalPointSettings ??
                                              2,
                                          priceSymbol: state
                                                  .getCurrencyForCountryModel!
                                                  .data!
                                                  .currency!
                                                  .symbol ??
                                              "",
                                          addToBagButtonShapeNotifier: widget
                                              .addToBagButtonShapeNotifier,
                                          price: (widget.productItem.price! *
                                                  state
                                                      .getCurrencyForCountryModel!
                                                      .data!
                                                      .currency!
                                                      .exchangeRate!)
                                              .toString(),
                                          offerPrice: (widget
                                                      .productItem.offerPrice! *
                                                  state
                                                      .getCurrencyForCountryModel!
                                                      .data!
                                                      .currency!
                                                      .exchangeRate!)
                                              .toString(),
                                        );
                                      }),
                                  currentTab != -1
                                      ? Positioned(
                                          top: 7,
                                          child: SvgPicture.asset(
                                            AppAssets.minusMarkSvg,
                                            width: 25,
                                            color: Colors.grey.shade200,
                                          ))
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              currentTab < 3 && currentTab >= 0
                                  ? SizedBox(
                                      height: 358.h,
                                      child: PageView(
                                        physics: const cupertino
                                            .ClampingScrollPhysics(),
                                        scrollBehavior: const cupertino
                                            .CupertinoScrollBehavior(),
                                        controller: pageController,
                                        onPageChanged: (index) {
                                          widget.currentActiveTab.value = index;
                                          if (idsOfChatCardsToShare
                                              .value.isNotEmpty) {
                                            idsOfChatCardsToShare.value = [];
                                          }
                                        },
                                        children: [
                                          ProductDetailsSheetCommentsContent(
                                              productSlugForTopic:
                                                  widget.productSlugForTopic,
                                              productSlug:
                                                  widget.productItem.slug ?? "",
                                              productId: widget
                                                  .productItem.productId
                                                  .toString(),
                                              scrollController: currentTab == 0
                                                  ? controller
                                                  : null),
                                          BlocBuilder<HomeBloc, HomeState>(
                                              buildWhen: (p, c) =>
                                                  p.currentColorSizeForCart?[
                                                      "size"] !=
                                                  c.currentColorSizeForCart?[
                                                      "size"],
                                              builder: (context, state) {
                                                return ProductDetailsSheetShareContent(
                                                    currentSize: state
                                                                .currentColorSizeForCart !=
                                                            null
                                                        ? state.currentColorSizeForCart![
                                                                "size"] ??
                                                            ""
                                                        : "",
                                                    currentColor:
                                                        widget.currentColorName,
                                                    productDescription: widget
                                                        .productDescription,
                                                    productItem:
                                                        widget.productItem,
                                                    focusNode: _focusNode,
                                                    scrollController:
                                                        currentTab == 1
                                                            ? controller
                                                            : null,
                                                    idsOfChatCardsToShare:
                                                        idsOfChatCardsToShare);
                                              }),
                                          ProductDetailsSheetMoreOptionsContent(
                                            productSlugForTopic:
                                                widget.productSlugForTopic,
                                            productSlug:
                                                widget.productItem.slug ?? "",
                                            scrollController: currentTab == 2
                                                ? controller
                                                : null,
                                            productId: widget
                                                .productItem.productId
                                                .toString(),
                                          )
                                        ],
                                      ),
                                    )
                                  : currentTab == 3
                                      ? BlocBuilder<HomeBloc, HomeState>(
                                          buildWhen: (p, c) =>
                                              p.currentSelectedColorForEveryProduct[
                                                      widget
                                                          .productItem.productId
                                                          .toString()] !=
                                                  c.currentSelectedColorForEveryProduct[
                                                      widget
                                                          .productItem.productId
                                                          .toString()] ||
                                              p.currentColorSizeForCart?[
                                                      "size"] !=
                                                  c.currentColorSizeForCart?[
                                                      "size"],
                                          builder: (context, state) {
                                            return SelectSizeContent(
                                              requestToNotifyMeFormFirstSize:
                                                  requestToNotifyMeFormFirstSize,
                                              collectedAfterOrdering:
                                                  widget.collectedAfterOrdering,
                                              colorIsNotAvailableNotifier:
                                                  colorIsNotAvailableNotifier,
                                              productId: widget
                                                  .productItem.productId
                                                  .toString(),
                                              sizes:
                                                  state.sizesForEachColor ?? [],
                                              sizesQuantities: state
                                                      .sizesQuantitiesForEachColor ??
                                                  [],
                                              scrollController: controller,
                                              selectedColorName: widget
                                                      .productItem
                                                      .colors
                                                      .isNullOrEmpty
                                                  ? null
                                                  : widget
                                                      .productItem
                                                      .colors![state
                                                                  .currentSelectedColorForEveryProduct[
                                                              widget.productItem
                                                                  .productId
                                                                  .toString()] ??
                                                          (widget
                                                                      .productItem
                                                                      .syncColorImages
                                                                      ?.length ??
                                                                  0) ~/
                                                              2]
                                                      .name
                                                      .toString(),
                                              selectedColor: widget.productItem
                                                      .colors.isNullOrEmpty
                                                  ? null
                                                  : Color(int.parse(
                                                      '0xff${widget.productItem.colors![state.currentSelectedColorForEveryProduct[widget.productItem.productId.toString()] ?? (widget.productItem.syncColorImages?.length ?? 0) ~/ 2].color!.substring(1)}')),
                                              sizeIsNotAvailableNotifier:
                                                  sizeIsNotAvailableNotifier,
                                              addToBagButtonShapeNotifier: widget
                                                  .addToBagButtonShapeNotifier,
                                            );
                                          },
                                        )
                                      : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0)),
                      ),
                      builder: (context, blurValue, child) {
                        return Stack(
                          children: [
                            ClipRect(
                              child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(
                                      sigmaX: currentTab == 3 ? blurValue : 0,
                                      sigmaY: currentTab == 3 ? blurValue : 0),
                                  child: child!),
                            ),
                          ],
                        );
                      });
                }),
            ValueListenableBuilder<int>(
                valueListenable: widget.currentActiveTab,
                builder: (context, currentTab, _) {
                  return currentTab == 3
                      ? const SizedBox.shrink()
                      : Divider(
                          height: 0.h,
                          color: const Color(0xffE6E6E6),
                        );
                }),
            ValueListenableBuilder<List<String>>(
                valueListenable: idsOfChatCardsToShare,
                builder: (context, channelIds, _) {
                  return channelIds.isEmpty
                      ? BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (p, c) =>
                              p.currentColorSizeForCart?["size"] !=
                              c.currentColorSizeForCart?["size"],
                          builder: (context, state) {
                            return ProductDetailsSheetBottomBar(
                                products: widget.productItem,
                                collectedAfterOrder:
                                    widget.collectedAfterOrdering,
                                qtyForproductWithoutVariant:
                                    widget.qtyForproductWithoutVariant,
                                colorIsNotAvailableNotifier:
                                    colorIsNotAvailableNotifier,
                                productSlug: widget.productItem.slug ?? "",
                                countOfPieces: widget.countOfPieces,
                                colorNum: widget.currentColornum,
                                size: state.currentColorSizeForCart != null
                                    ? state.currentColorSizeForCart!["size"] ??
                                        ""
                                    : "",
                                colorName: widget.currentColorName,
                                productIdForCashproducts:
                                    widget.productIdForCashData,
                                productIdForRequestApi:
                                    widget.productItem.productId.toString(),
                                imageUrl: !widget.productItem.syncColorImages
                                        .isNullOrEmpty
                                    ? widget
                                            .productItem
                                            .syncColorImages![
                                                widget.currentColor]
                                            .images![0]
                                            .filePath ??
                                        ""
                                    : widget
                                            .productItem
                                            .images![widget.currentColor]
                                            .filePath ??
                                        "",
                                onFinishBuying: (quantity) {
                                  /*   if ((prefsRepository.isTokenExpired ??
                                              false ||
                                                  prefsRepository.marketToken == "" ||
                                                  prefsRepository.marketToken ==
                                                      null) &&
                                          GetIt.I<AuthBloc>()
                                                  .state
                                                  .registerGuestStatus !=
                                              RegisterGuestStatus.loading) {
                                        Future.delayed(
                                            Duration(seconds: 1),
                                            () => showDialog(
                                                  context: context,
                                                  builder: (context) => Center(
                                                      child: Container(
                                                    alignment: Alignment.center,
                                                    width: 400,
                                                    height: 300,
                                                    child: AlertDialog(
                                                      title: MyTextWidget(
                                                        "${LocaleKeys.it_has_been_along_time_since_your_account.tr()}",
                                                      ),
                                                      actions: <Widget>[
                                                        Container(
                                                          alignment: Alignment.center,
                                                          width: 300,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                (prefsRepository
                                                                            .isVerifiedPhonePeforeExpiredToken ??
                                                                        false)
                                                                    ? MainAxisAlignment
                                                                        .center
                                                                    : MainAxisAlignment
                                                                        .spaceAround,
                                                            children: [
                                                              (prefsRepository
                                                                          .isVerifiedPhonePeforeExpiredToken ??
                                                                      false)
                                                                  ? SizedBox.shrink()
                                                                  : Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      width: 130,
                                                                      child:
                                                                          AppElevatedButton(
                                                                        textStyle:
                                                                            TextStyle(
                                                                                fontSize:
                                                                                    16),
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.of(
                                                                                  context)
                                                                              .pop();
                                                                          String?
                                                                              deviceId =
                                                                              await HelperFunctions
                                                                                  .getDeviceId();
            
                                                                          GetIt.I<AuthBloc>().add(RegisterGuestEvent(
                                                                              oldGuestUserId: prefsRepository
                                                                                  .myMarketId
                                                                                  .toString(),
                                                                              deviceId:
                                                                                  deviceId!));
                                                                        },
                                                                        text:
                                                                            "${LocaleKeys.reset_your_count.tr()}",
                                                                      ),
                                                                    ),
                                                              Container(
                                                                alignment:
                                                                    Alignment.center,
                                                                width: 130,
                                                                child:
                                                                    AppElevatedButton(
                                                                  textStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
            
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                            PageRouteBuilder(
                                                                      pageBuilder: (context,
                                                                              animation,
                                                                              secondaryAnimation) =>
                                                                          RegistrationPage(
                                                                        fromExpiredToken:
                                                                            true,
                                                                      ),
                                                                    ));
                                                                  },
                                                                  text:
                                                                      '${LocaleKeys.go_to_log_in.tr()}',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )),
                                                ));
                                        return;
                                      }*/
                                  /*homeBloc.add(
                                    AddMultiItemsToCartEvent(
                                      maxAllowed: widget.maxAllowedToAddCart,
                                      boutiqueIcon: widget.boutiqueIcon,
                                      productSlugForTopic:
                                          widget.productSlugForTopic,
                                      boutiqueId: widget.boutiqueId,
                                      products: widget.productItem,
                                      id: widget.productItem.productId
                                          .toString(),
                                    ),
                                  );*/
                                  Future.delayed(
                                      Duration(milliseconds: 300),
                                      () => setState(() {
                                            isMoving = true;
                                          }));

                                  Future.delayed(
                                      Duration(seconds: 2),
                                      () => setState(() {
                                            isMoving = false;
                                          }));
                                },
                                panelController: widget.panelController,
                                clickOnComments: () {
                                  widget.panelController.open();
                                  widget.currentActiveTab.value = 0;
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) {
                                      pageController.jumpToPage(0);
                                    },
                                  );
                                  //////////////////////////////
                                  FirebaseAnalyticsService.logEventForSession(
                                    eventName:
                                        AnalyticsEventsConst.buttonClicked,
                                    executedEventName:
                                        AnalyticsExecutedEventNameConst
                                            .showCommentsButton,
                                  );
                                },
                                clickOnFavorite: () {
                                  widget.currentActiveTab.value = -1;
                                  //////////////////////////////
                                  FirebaseAnalyticsService.logEventForSession(
                                    eventName:
                                        AnalyticsEventsConst.buttonClicked,
                                    executedEventName:
                                        AnalyticsExecutedEventNameConst
                                            .likeProductButton,
                                  );
                                },
                                clickOnMoreOptions: () {
                                  widget.panelController.open();
                                  widget.currentActiveTab.value = 2;
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) {
                                      pageController.jumpToPage(2);
                                    },
                                  );
                                  //////////////////////////////
                                  FirebaseAnalyticsService.logEventForSession(
                                    eventName:
                                        AnalyticsEventsConst.buttonClicked,
                                    executedEventName:
                                        AnalyticsExecutedEventNameConst
                                            .moreOptionsButton,
                                  );
                                },
                                clickOnShare: () {
                                  widget.panelController.open();
                                  widget.currentActiveTab.value = 1;
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) {
                                      pageController.jumpToPage(1);
                                    },
                                  );
                                  if (GetIt.I<PrefsRepository>().chatToken !=
                                      null) {
                                    BlocProvider.of<ChatBloc>(context)
                                        .add(GetChatsEvent());
                                    BlocProvider.of<ChatBloc>(context)
                                        .add(SaveContactsEvent());
                                  }
                                  //////////////////////////////
                                  FirebaseAnalyticsService.logEventForSession(
                                    eventName:
                                        AnalyticsEventsConst.buttonClicked,
                                    executedEventName:
                                        AnalyticsExecutedEventNameConst
                                            .shareProductButton,
                                  );
                                },
                                currentActiveTab: widget.currentActiveTab,
                                sizeIsNotAvailableNotifier:
                                    sizeIsNotAvailableNotifier,
                                addToBagButtonShapeNotifier:
                                    widget.addToBagButtonShapeNotifier);
                          })
                      : ShareButton(
                          onTap: () {
                            BlocProvider.of<ChatBloc>(context).add(
                                ShareProductWithContactsOrChannelsEvent(
                                    productId:
                                        widget.productItem.productId.toString(),
                                    productName:
                                        widget.productItem.name.toString(),
                                    productSlug:
                                        widget.productItem.slug.toString(),
                                    productDescription:
                                        widget.productItem.details.toString(),
                                    originalImageWidth:
                                        gallery3dControllerForCircles != null
                                            ? (orginalWidth?[currentIndexInSlider])
                                                .toString()
                                            : widget.productItem.images![0]
                                                .originalWidth,
                                    originalImageHeight:
                                        gallery3dControllerForCircles != null
                                            ? (orginalHeight?[
                                                    currentIndexInSlider])
                                                .toString()
                                            : widget.productItem.images![0]
                                                .originalHeight,
                                    productImageUrl:
                                        gallery3dControllerForCircles != null
                                            ? images[currentIndexInSlider]
                                            : widget
                                                .productItem.images![0].filePath
                                                .toString(),
                                    channelIds: channelIds));
                            idsOfChatCardsToShare.value = [];
                            widget.currentActiveTab.value = -1;
                            //////////////////////////////
                            FirebaseAnalyticsService.logEventForSession(
                              eventName: AnalyticsEventsConst.buttonClicked,
                              executedEventName: AnalyticsExecutedEventNameConst
                                  .sendProductToChatButton,
                            );
                          },
                        );
                }),
          ],
        );
      },
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        12.verticalSpace,
        Material(
          color: Colors.transparent,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: onTap,
            child: Container(
              padding: HWEdgeInsets.symmetric(vertical: 20),
              margin: HWEdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xff3c3c3c),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1a000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.shareSvg,
                      color: Colors.white,
                      height: 20,
                    ),
                    10.horizontalSpace,
                    MyTextWidget(
                      '${LocaleKeys.send.tr()}',
                      style: context.textTheme.bodyLarge?.rq
                          .copyWith(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomBoxShadow extends BoxShadow {
  final BlurStyle blurStyle;

  const CustomBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.blurStyle = BlurStyle.normal,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(this.blurStyle, blurSigma);
    assert(() {
      if (debugDisableShadows) result.maskFilter = null;
      return true;
    }());
    return result;
  }
}
