import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// ScrollCacheExtent غير مُصدَّرة عبر material.dart/widgets.dart
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_quick_view_popup.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_colors_panel.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import 'package:trydos/common/helper/dev_log.dart';

class FeaturedProductsPage extends StatefulWidget {
  const FeaturedProductsPage({Key? key}) : super(key: key);

  @override
  State<FeaturedProductsPage> createState() => _FeaturedProductsPageState();
}

class _FeaturedProductsPageState extends State<FeaturedProductsPage> {
  // final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
  //    ValueNotifier(Tuple2(-1, -1));
  late BoutiqueBloc boutiqueBloc;
  List<filter.Products> products = [];
  final ScrollController scrollController = ScrollController();
  ValueNotifier<int> tapIndexToAddProductToCart = ValueNotifier(-1);
  final PanelController panelControllerForCart = PanelController();
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  late AuthBloc authBloc;

  late HomeBloc homeBloc;
  final ValueNotifier<String?> productNotAvailableNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<bool> finishRedeem = ValueNotifier(false);
  final ValueNotifier<bool> visibleFlashDeal = ValueNotifier(false);
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final ValueNotifier<bool> loadingForRquestProductDetails = ValueNotifier(
    false,
  );

  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  Map<String, Key> reRenderingListViewKey = {};
  Map<String, int> lastIndexRequestedInEachMainCategoryForPrefetchBoutiques =
      {};

  String selectedCategorySlug = "Empty";
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final PageController pageController = PageController();
  final PanelController colorImagesPanelController = PanelController();
  final ValueNotifier<bool> showShadowForColorImages = ValueNotifier(false);
  final FocusNode focusNode = FocusNode();
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  final ValueNotifier<int> tapIndexToShowColorImages = ValueNotifier(-1);
  Timer? debounce;

  /// هل نافذة تفاصيل/شراء المنتج مفتوحة حالياً (لمنع فتح مسارين).
  bool _isQuickViewOpen = false;

  /// يفتح نافذة تفاصيل/شراء المنتج كـ popup منفصل عند الضغط على منتج.
  ///
  /// المنطق كاملاً في [ProductQuickViewPopup]؛ هنا نتكفّل فقط بفتح المسار مرة
  /// واحدة، وباستعادة حالة الصفحة عند إغلاقه مهما كان السبب (زر الرجوع مثلاً).
  void _handleQuickViewRequest() {
    if (!mounted || _isQuickViewOpen) return;
    if (tapIndexToAddProductToCart.value == -1) return;

    _isQuickViewOpen = true;
    ProductQuickViewPopup.show(
      context: context,
      tapIndexToAddProductToCart: tapIndexToAddProductToCart,
      finishRedeem: finishRedeem,
      visibleFlashDeal: visibleFlashDeal,
      showShadowForPanel: showShadowForPanel,
      loadingForRquestProductDetails: loadingForRquestProductDetails,
      currentActiveTab: currentActiveTab,
      addToBagButtonShapeNotifier: addToBagButtonShapeNotifier,
      productNotAvailableNotifier: productNotAvailableNotifier,
      panelController: panelControllerForCart,
      // مصدر واحد ثابت (*featured*) ولا شريط تنقّل سفلي في هذه الصفحة.
      hideBottomNavigationBar: false,
    ).whenComplete(() {
      _isQuickViewOpen = false;
      if (!mounted) return;
      showShadowForPanel.value = false;
      if (tapIndexToAddProductToCart.value != -1) {
        tapIndexToAddProductToCart.value = -1;
      }
      currentActiveTab.value = 0;
    });
  }

  void _listenToScroll() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(const Duration(milliseconds: 600), () {
      // videoProductInListingController.forEach((key, value) => value.pause());
      //  if (setThisEnabledNotifier.value.item1 != -1) {
      //    setThisEnabledNotifier.value = Tuple2(-1, -1);
      //  }
      if (scrollController.hasClients &&
          scrollController.offset >=
              (scrollController.position.maxScrollExtent * 0.6)) {
        if (boutiqueBloc.state.isGettingProductListingWithPagination) return;
        if (boutiqueBloc
                .state
                .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"] ==
            null) {
          return;
        }
        if (boutiqueBloc
            .state
            .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]!
            .hasReachedMax) {
          return;
        }

        boutiqueBloc.add(
          GetProductsWithFiltersEvent(
            limit: 10,
            cashedOrginalBoutique: true,
            boutiqueSlug: "*featured*",
            getWithPagination: true,
            offset: 2,
          ),
        );
      }
    });
  }

  @override
  void initState() {
    LastPagesTracker.push("FeaturedProducts Page");
    authBloc = BlocProvider.of<AuthBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    //productIdToSaveRedeemTimer = [];

    scrollController.addListener(_listenToScroll);
    tapIndexToAddProductToCart.addListener(_handleQuickViewRequest);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // productSlugToSaveVideoTimer = [];
    scrollController.removeListener(_listenToScroll);
    tapIndexToAddProductToCart.removeListener(_handleQuickViewRequest);
    scrollController.dispose();
    //  clearvideoProductInListingController(productSlug: "");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () async {
        try {
          if (colorImagesPanelController.isPanelOpen) {
            colorImagesPanelController.close();
            showShadowForColorImages.value = false;
            return false;
          }
        } catch (e) {
          devLog('featued_products_page.dart: ignored error', e);
        }
        prefsRepository.setTagsInUrlToFilter([]);
        try {
          if (panelControllerForCart.isPanelOpen) {
            panelControllerForCart.close();
            return await Future.value(false);
          }
        } catch (e) {
          devLog('featued_products_page.dart: ignored error', e);
        }
        return Future.value(true);
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    width: 150.w,
                    height: 30.h,
                    child: MyTextWidget(
                      textAlign: TextAlign.start,
                      "${LocaleKeys.feature_product.tr()}",
                      style: TextStyle(color: Colors.black, fontSize: 14.sp),
                    ),
                  ),
                  BlocBuilder<BoutiqueBloc, BoutiqueState>(
                    buildWhen: (previous, current) =>
                        previous
                                .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                                ?.paginationStatus !=
                            current
                                .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                                ?.paginationStatus ||
                        previous.isGettingProductListingWithPagination !=
                            current.isGettingProductListingWithPagination,
                    builder: (context, state) {
                      products =
                          state.getProductListingWithFiltersPaginationModels["*featured*withoutFilter"] ==
                              null
                          ? []
                          : state
                                .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]!
                                .items;
                      return products.isNullOrEmpty
                          ? const SizedBox.shrink()
                          : Container(
                              width: 1.sw,
                              height:
                                  state.isGettingProductListingWithPagination
                                  ? 1.sh - 100.h
                                  : 1.sh - 70.h,
                              child: /* ValueListenableBuilder<Tuple2<int, int>>(
                                    valueListenable: setThisEnabledNotifier,
                                    builder: (context, slidingMode, _) {
                                      return*/ LayoutBuilder(
                                builder: (context, constraints) {
                                  if (kDebugMode)
                                    devLog(
                                      "DDDDDDDDDDDDDD................${products.length}",
                                    );
                                  // حساب عرض العنصر مع مراعاة المسافات (مثلاً 16 بكسل)
                                  const double spacing = 5;
                                  const int crossAxisCount = 2;
                                  const double totalSpacing =
                                      spacing * (crossAxisCount + 1);
                                  final double itemWidth =
                                      (constraints.maxWidth - totalSpacing) /
                                      crossAxisCount;
                                  double itemHeight = 375.h;

                                  return Column(
                                    children: [
                                      Expanded(
                                        child: GridView.builder(
                                          addAutomaticKeepAlives: false,
                                          addSemanticIndexes: false,
                                          // صفّ كامل مسبقاً — مشتقّ من
                                          // itemHeight أعلاه بدل رقم ثابت
                                          scrollCacheExtent:
                                              ScrollCacheExtent.pixels(
                                                itemHeight + spacing,
                                              ),
                                          controller: scrollController,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                mainAxisSpacing: spacing,
                                                crossAxisSpacing: spacing,
                                                childAspectRatio:
                                                    itemWidth / itemHeight,
                                              ),
                                          itemCount: products.length,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                GetIt.I<HomeBloc>().add(
                                                  const ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                                    isStatusInitaial: true,
                                                  ),
                                                );
                                                homeBloc.add(
                                                  AddCurrentSelectedColorEvent(
                                                    currentSelectedColor: 0,
                                                    productSlug: products[index]
                                                        .slug
                                                        .toString(),
                                                  ),
                                                );

                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  () => Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          ProductDetailsPageNew(
                                                            productItem:
                                                                products[index],
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ProductItem(
                                                colorImagesPanelController:
                                                    colorImagesPanelController,
                                                showShadowForColorImages:
                                                    showShadowForColorImages,
                                                tapIndexToShowColorImages:
                                                    tapIndexToShowColorImages,
                                                finishRedeem: finishRedeem,
                                                tapIndexToAddProductToCart:
                                                    tapIndexToAddProductToCart,
                                                key: TestVariables.kTestMode
                                                    ? Key(
                                                        '"featuresPtoduct"$index',
                                                      )
                                                    : null,
                                                productItem: products[index],
                                                itemIndex: index,
                                                /*   slidingModeItem:
                                                              slidingMode,
                                                          setThisEnabled: (int
                                                                  index,
                                                              int slideMode) {
                                                            setThisEnabledNotifier
                                                                    .value =
                                                                Tuple2(index,
                                                                    slideMode);
                                                          },*/
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );

                      //      }),
                    },
                  ),
                  BlocBuilder<BoutiqueBloc, BoutiqueState>(
                    buildWhen: (previous, current) =>
                        previous.isGettingProductListingWithPagination !=
                        current.isGettingProductListingWithPagination,
                    builder: (context, state) {
                      if (state.isGettingProductListingWithPagination) {
                        return Center(child: TrydosLoader());
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              shadowForPanel(),
              panelWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget shadowForPanel() {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForColorImages,
      builder: (context, isShowShadowForPanel, _) {
        return !isShowShadowForPanel
            ? const SizedBox.shrink()
            : InkWell(
                onTap: () {
                  showShadowForColorImages.value = false;
                  Future.delayed(const Duration(microseconds: 300), () {
                    colorImagesPanelController.close();
                    showShadowForColorImages.value = false;
                  });
                },
                child: Container(
                  height: 1.sh,
                  width: 1.sw,
                  color: const Color.fromRGBO(29, 29, 29, 0.6),
                ),
              );
      },
    );
  }

  Widget panelWidget() {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForColorImages,
      builder: (context, isShowPanel, _) {
        return Positioned(
          bottom: 0,
          child: Container(
            width: 1.sw,
            height: isShowPanel ? (1.sh - 100.h) : 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r),
              ),
            ),
            child: SlidingUpPanel(
              controller: colorImagesPanelController,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r),
              ),
              onPanelClosed: () {
                showShadowForColorImages.value = false;
              },
              onPanelOpened: () {},
              minHeight: 0,
              maxHeight: (1.sh - 100.h),
              panelBuilder: (sc) => panelBuilderContent(sc),
            ),
          ),
        );
      },
    );
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
          children: [
            Container(
              margin: EdgeInsets.all(10.h),
              height: 2.h,
              width: 40.w,
              decoration: const BoxDecoration(color: Color(0xffC4C2C2)),
            ),
            SizedBox(height: 5.h),
            ValueListenableBuilder<bool>(
              valueListenable: finishRedeem,
              builder: (context, _finishRedeem, _) => ValueListenableBuilder<int>(
                valueListenable: tapIndexToShowColorImages,
                builder: (context, _tapIndexToShowColorImages, _) {
                  // اللوحة تُبنى قبل اختيار أي منتج، وقيمة المؤشّر الابتدائية \u200E-1
                  // (وقد تكون القائمة فارغة قبل وصول البيانات) — فبدون هذا الفحص
                  // يُرمى RangeError من products[-1] في كل بناء للصفحة.
                  if (_tapIndexToShowColorImages < 0 ||
                      _tapIndexToShowColorImages >= products.length) {
                    return const SizedBox.shrink();
                  }
                  final selectedProduct = products[_tapIndexToShowColorImages];
                  return Expanded(
                    child: GridView.builder(
                      controller: sc,
                      addAutomaticKeepAlives: false,

                      addSemanticIndexes: false,
                      // صفّ كامل مسبقاً. ارتفاع الخانة مشتقّ من
                      // childAspectRatio أدناه فيساوي 392.h تقريباً
                      scrollCacheExtent: ScrollCacheExtent.pixels(392.h + 5.h),
                      itemCount: selectedProduct.syncColorImages?.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 5.h,
                        crossAxisSpacing: 5.w,
                        childAspectRatio: 1.sw / (392.h * 2),
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          GetIt.I<HomeBloc>().add(
                            const ChangeStatusOFGetProductsDetailsToSuccessEvent(
                              isStatusInitaial: true,
                            ),
                          );
                          homeBloc.add(
                            AddCurrentSelectedColorEvent(
                              currentSelectedColor: index,
                              productSlug: selectedProduct.slug.toString(),
                            ),
                          );

                          Future.delayed(
                            const Duration(milliseconds: 300),
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ProductDetailsPageNew(
                                  productItem: selectedProduct,
                                ),
                              ),
                            ),
                          );
                        },
                        child: ProductColorPanal(
                          colorImages:
                              selectedProduct.syncColorImages?[index].images
                                  ?.map((e) => e.filePath ?? "")
                                  .toList() ??
                              [],
                          visibleRedeem: visibleRedeem,
                          productItem: selectedProduct,
                          tapIndexToAddProductToCart:
                              tapIndexToAddProductToCart,
                          itemIndex: _tapIndexToShowColorImages,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
