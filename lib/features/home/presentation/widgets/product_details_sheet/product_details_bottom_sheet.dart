import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_hero/local_hero.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_comments_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_header.dart';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_more_options_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_share_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/select_size_sheet.dart';
import '../../../../../trydos_application.dart';
import '../../manager/home_bloc.dart';
import '../product_details_body/product_details_image_widget.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../product_listing/product_listing_image_widget.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final productListingModel.Products productItem;
  final int currentColor;
  final String currentColorName;
  const ProductDetailsBottomSheet(
      {super.key,
      required this.productItem,
      required this.currentColor,
      required this.currentColorName});

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  final ValueNotifier<List<int>> indicesOfChatCardsToShare = ValueNotifier([]);
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final ValueNotifier<double> workOnBlurNotifier = ValueNotifier(10);
  final ValueNotifier<int> currentImageTab = ValueNotifier(0);

  final ValueNotifier<String?> sizeIsNotAvailableNotifier = ValueNotifier(null);
  final PageController pageController = PageController();
  final PanelController panelController = PanelController();
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

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);

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
                initialIndex: widget.currentColor,
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
  String tag = '';

  @override
  Widget build(BuildContext context) {
    return LocalHeroScope(
      duration: Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ValueListenableBuilder<int>(
              valueListenable: currentActiveTab,
              builder: (context, currentTab, _) {
                return ValueListenableBuilder<double>(
                    valueListenable: workOnBlurNotifier,
                    child: SlidingUpPanel(
                      denyVericalSliding: currentTab == 3
                          ? (currentPosition) {
                              if (panelController.panelPosition != 1) {
                                return false;
                              }
                              if (offsetOfColorsGallerySlider == null) {
                                final RenderBox renderBox =
                                    colorsGallerySliderKey.currentContext!
                                        .findRenderObject() as RenderBox;
                                offsetOfColorsGallerySlider =
                                    renderBox.localToGlobal(Offset.zero);
                              }
                              if (currentPosition.dy > (288.h + 70.w + 10.h)) {
                                if (currentPosition.dy <=
                                        (288.h + 70.w + 30.h + 125 + 100) &&
                                    currentPosition.dy >=
                                        (288.h + 70.w + 30.h + 125)) {
                                  userWantToScrollHorizontally = true;
                                }
                              } else if (currentPosition.dx >=
                                      offsetOfColorsGallerySlider!.dx &&
                                  currentPosition.dx <=
                                      (offsetOfColorsGallerySlider!.dx + 200) &&
                                  currentPosition.dy <= (288.h + 70.w + 10.h) &&
                                  currentPosition.dy >= (288.h + 10.h)) {
                                userWantToScrollHorizontally = true;
                              }
                              return userWantToScrollHorizontally;
                            }
                          : null,
                      controller: panelController,
                      maxHeight: currentTab == -1
                          ? 78
                          : _focusNode.hasFocus
                              ? 575
                              : currentTab == 3
                                  ? 1.sh - 180 //330.h + 70.w + 305
                                  : 433,
                      minHeight: 78,
                      onPanelClosed: () {
                        sizeIsNotAvailableNotifier.value = null;
                        firstOpenOfPanel = true;
                        denySlidingBackForSlidingUpPanels.value = false;
                        currentActiveTab.value = -1;
                        tag = '';
                      },
                      onPanelOpened: () {
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
                                currentActiveTab.value = -1;
                                return;
                              }
                              if (percentOfOpenPart == 1) {
                                userWantToScrollHorizontally = false;
                              }
                            }
                          : null,
                      panelBuilder: (controller) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentTab == 3) ...{
                            SizedBox(
                              height: 1.sh - (288.h + 70.w + 305) - 180,
                            ),
                            tag == ''
                                ? LocalHero(
                                    tag: 'cart',
                                    child: ValueListenableBuilder<int>(
                                        valueListenable: currentImageTab,
                                        builder: (context, currentImage, _) {
                                          return ProductDetailsImageWidget(
                                            width: 198.w,
                                            height: 288.h,
                                            imageUrl:
                                                images[currentIndexInSlider],
                                          );
                                        }))
                                : SizedBox(
                                    height: 288.h,
                                  ),
                            10.verticalSpace,
                            Material(
                              color: Colors.transparent,
                              child: Gallery3D(
                                  key: colorsGallerySliderKey,
                                  // key: ValueKey('gallery3dControllerForCircles${widget.itemIndex}'),
                                  controller: gallery3dControllerForCircles!,
                                  denyScrolling: false,
                                  width: 200,
                                  stopScrollingOnEdges: (double primaryDelta) {
                                    return (primaryDelta <= 0 &&
                                            gallery3dControllerForCircles!
                                                    .currentIndex ==
                                                (syncColorImageList.length ~/
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
                                    currentIndexInSlider = index;
                                    currentImageTab.value = index;

                                    homeBloc.add(AddCurrentSelectedColorEvent(
                                        currentSelectedColor: index,
                                        productId:
                                            widget.productItem.id.toString()));
                                  },
                                  onClickItem: (index) {},
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
                                                  (syncColorImageList.length ~/
                                                      2) &&
                                              index <
                                                  (syncColorImageList.length ~/
                                                      2)) ||
                                          ((gallery3dControllerForCircles
                                                          ?.currentIndex ??
                                                      0) >=
                                                  (syncColorImageList.length ~/
                                                      2) &&
                                              index >=
                                                  (syncColorImageList.length ~/
                                                      2)),
                                      child: ProductListingImageWidget(
                                        orginalHeight: orginalHeight![index],
                                        orginalWidth: orginalWidth![index],
                                        width: 70.w,
                                        height: 70.w,
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
                            ),
                            10.verticalSpace,
                          },
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              ProductDetailsSheetHeader(
                                addToBagButtonShapeNotifier:
                                    addToBagButtonShapeNotifier,
                                price: widget.productItem.priceFormatted ?? '',
                                offerPrice:
                                    (widget.productItem.offerPrice ?? '')
                                        .toString(),
                              ),
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
                                  height: 358,
                                  child: PageView(
                                    physics:
                                        const cupertino.ClampingScrollPhysics(),
                                    scrollBehavior: const cupertino
                                        .CupertinoScrollBehavior(),
                                    controller: pageController,
                                    onPageChanged: (index) {
                                      currentActiveTab.value = index;
                                      if (indicesOfChatCardsToShare
                                          .value.isNotEmpty) {
                                        indicesOfChatCardsToShare.value = [];
                                      }
                                    },
                                    children: [
                                      ProductDetailsSheetCommentsContent(
                                          productId:
                                              widget.productItem.id.toString(),
                                          scrollController: currentTab == 0
                                              ? controller
                                              : null),
                                      ProductDetailsSheetShareContent(
                                          focusNode: _focusNode,
                                          scrollController: currentTab == 1
                                              ? controller
                                              : null,
                                          indicesOfChatCardsToShare:
                                              indicesOfChatCardsToShare),
                                      ProductDetailsSheetMoreOptionsContent(
                                          scrollController: currentTab == 2
                                              ? controller
                                              : null)
                                    ],
                                  ),
                                )
                              : currentTab == 3
                                  ? SelectSizeContent(
                                      scrollController: controller,
                                      selectedColor: Colors.blue,
                                      sizeIsNotAvailableNotifier:
                                          sizeIsNotAvailableNotifier,
                                      addToBagButtonShapeNotifier:
                                          addToBagButtonShapeNotifier,
                                    )
                                  : const SizedBox.shrink(),
                        ],
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
                          if (currentTab == 3) ...{
                            Positioned(
                              right: 0,
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 10.0),
                                child: Transform.translate(
                                  offset: Offset(0, -50),
                                  child: tag == ''
                                      ? SizedBox.shrink()
                                      : Visibility(
                                          visible: tag == 'cart',
                                          child: LocalHero(
                                            tag: 'cart',
                                            child: SvgPicture.asset(
                                                AppAssets.bagsSvg),
                                          ),
                                        ),
                                ),
                              ),
                            )
                          }
                        ],
                      );
                    });
              }),
          ValueListenableBuilder<int>(
              valueListenable: currentActiveTab,
              builder: (context, currentTab, _) {
                return currentTab == 3
                    ? const SizedBox.shrink()
                    : Divider(
                        height: 0.h,
                        color: const Color(0xffE6E6E6),
                      );
              }),
          ValueListenableBuilder<List<int>>(
              valueListenable: indicesOfChatCardsToShare,
              builder: (context, indices, _) {
                return indices.isEmpty
                    ? ProductDetailsSheetBottomBar(
                        imageUrl: widget
                            .productItem
                            .syncColorImages![widget.currentColor]
                            .images![0]
                            .filePath!,
                        onFinishBuying: (quantity) {
                          homeBloc.add(AddItemToCartEvent(
                              products: widget.productItem,
                              color: widget.currentColorName,
                              quantity: int.parse(quantity),
                              id: widget.productItem.id.toString()));
                          setState(() {
                            tag = 'cart';
                          });
                        },
                        panelController: panelController,
                        clickOnComments: () {
                          panelController.open();
                          currentActiveTab.value = 0;
                          pageController.jumpToPage(0);
                        },
                        clickOnFavorite: () {
                          currentActiveTab.value = -1;
                        },
                        clickOnMoreOptions: () {
                          panelController.open();
                          currentActiveTab.value = 2;
                          pageController.jumpToPage(2);
                        },
                        clickOnShare: () {
                          panelController.open();
                          currentActiveTab.value = 1;
                          pageController.jumpToPage(1);
                        },
                        currentActiveTab: currentActiveTab,
                        sizeIsNotAvailableNotifier: sizeIsNotAvailableNotifier,
                        addToBagButtonShapeNotifier:
                            addToBagButtonShapeNotifier)
                    : ShareButton(
                        onTap: () {},
                      );
              }),
        ],
      ),
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
                      'Send',
                      style: context.textTheme.headline6?.rq
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
