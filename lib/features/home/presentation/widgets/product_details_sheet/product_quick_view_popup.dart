import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart'
    as productDetail;
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet_new.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// مصدر قائمة المنتجات التي يُفهرَس فيها `tapIndex`.
///
/// تستعمله الصفحات ذات المصدر الواحد؛ أما الصفحات التي يتبدّل مصدرها أثناء
/// التصفّح (كالصفحة الرئيسية) فتمرّر `productIsFlashDeal`/`productIsRecommend`
/// وتتجاهل هذا المُعامل.
enum QuickViewProductSource {
  featured("*featured*withoutFilter"),
  recommended("*recommended*withoutFilter"),
  flashDeal("*flashDeal*withoutFilter");

  const QuickViewProductSource(this.paginationKey);

  final String paginationKey;
}

/// نافذة منبثقة (popup) تعرض لوحة تفاصيل/شراء المنتج قادمةً من أسفل الشاشة.
///
/// كانت هذه الكتلة مضمّنة سابقاً داخل `Stack` الخاص بـ `HomePage`
/// (طبقة الظل + سلسلة `ValueListenableBuilder` المتداخلة). نُقلت هنا كما هي
/// ليصبح العرض عبر مسار (route) مستقل يُفتح عند الضغط على منتج ويُغلق عند
/// انتهاء التعامل معه — دون أي تعديل على [ProductDetailsBottomSheetNew] أو
/// أي من ملفات صفحة التفاصيل.
///
/// كل الـ `ValueNotifier`s والـ [PanelController] تبقى مملوكة للصفحة المستدعية
/// (دورة حياتها ومسؤولية `dispose` لم تتغيّر)، وتُمرَّر هنا كمعاملات فقط.
class ProductQuickViewPopup extends StatefulWidget {
  const ProductQuickViewPopup({
    super.key,
    required this.tapIndexToAddProductToCart,
    required this.finishRedeem,
    required this.visibleFlashDeal,
    required this.showShadowForPanel,
    required this.loadingForRquestProductDetails,
    required this.currentActiveTab,
    required this.addToBagButtonShapeNotifier,
    required this.productNotAvailableNotifier,
    required this.panelController,
    this.productIsFlashDeal,
    this.productIsRecommend,
    this.source = QuickViewProductSource.featured,
    this.productsResolver,
    this.hideBottomNavigationBar = true,
  });

  /// فهرس المنتج المضغوط ضمن [products]؛ القيمة `-1` تعني "لا يوجد منتج مفتوح"
  /// وهي إشارة إغلاق النافذة.
  final ValueNotifier<int> tapIndexToAddProductToCart;

  /// مصدر قائمة المنتجات: عرض فلاش / موصى به / مميّز (الافتراضي).
  ///
  /// الصفحات ذات المصدر الواحد تتركهما `null` وتحدّد [source] بدلاً منهما.
  final ValueNotifier<bool>? productIsFlashDeal;
  final ValueNotifier<bool>? productIsRecommend;

  /// المصدر الثابت المستعمَل حين لا تُمرَّر مؤشّرات المصدر أعلاه.
  final QuickViewProductSource source;

  /// مُزوِّد قائمة خارجي يتقدّم على [source] و[productIsFlashDeal]/[productIsRecommend].
  ///
  /// تستعمله الصفحات التي تشتقّ قائمتها من مفتاح غير ثابت (صفحة قوائم البوتيك
  /// مثلاً: slug البوتيك + الفلاتر + التصنيف) فتمرّر `() => products`.
  final List<filter.Products> Function()? productsResolver;

  /// هل نُخفي شريط التنقّل السفلي أثناء فتح النافذة؟ الصفحات المستقلة
  /// (التي لا شريط تنقّل فيها) تمرّر `false`.
  final bool hideBottomNavigationBar;

  final ValueNotifier<bool> finishRedeem;
  final ValueNotifier<bool> visibleFlashDeal;

  /// يتحكّم بظهور الطبقة السوداء خلف اللوحة (يضبطه اللوح نفسه عند فتحه/إغلاقه).
  final ValueNotifier<bool> showShadowForPanel;

  /// مؤشر تحميل قصير يظهر ريثما تصل تفاصيل المنتج.
  final ValueNotifier<bool> loadingForRquestProductDetails;

  /// التبويب الفعّال داخل اللوحة: \u200E-1 مغلق، 0 تعليقات، 1 مشاركة، 2 خيارات، 3 شراء.
  final ValueNotifier<int> currentActiveTab;

  final ValueNotifier<int> addToBagButtonShapeNotifier;
  final ValueNotifier<String?> productNotAvailableNotifier;

  final PanelController panelController;

  /// يعرض النافذة فوق الـ root navigator كنافذة منبثقة شفافة بملء الشاشة.
  ///
  /// الطبقة السوداء والسحب يتكفّل بهما محتوى النافذة نفسه
  /// (`showShadowForPanel` + `SlidingUpPanel`)، لذلك حاجز المسار شفاف
  /// و `enableDrag` معطّل حتى لا يتنازع مع سحب اللوحة.
  static Future<void> show({
    required BuildContext context,
    required ValueNotifier<int> tapIndexToAddProductToCart,
    required ValueNotifier<bool> finishRedeem,
    required ValueNotifier<bool> visibleFlashDeal,
    required ValueNotifier<bool> showShadowForPanel,
    required ValueNotifier<bool> loadingForRquestProductDetails,
    required ValueNotifier<int> currentActiveTab,
    required ValueNotifier<int> addToBagButtonShapeNotifier,
    required ValueNotifier<String?> productNotAvailableNotifier,
    required PanelController panelController,
    ValueNotifier<bool>? productIsFlashDeal,
    ValueNotifier<bool>? productIsRecommend,
    QuickViewProductSource source = QuickViewProductSource.featured,
    List<filter.Products> Function()? productsResolver,
    bool hideBottomNavigationBar = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      elevation: 0,
      builder: (_) => ProductQuickViewPopup(
        tapIndexToAddProductToCart: tapIndexToAddProductToCart,
        productIsFlashDeal: productIsFlashDeal,
        productIsRecommend: productIsRecommend,
        finishRedeem: finishRedeem,
        visibleFlashDeal: visibleFlashDeal,
        showShadowForPanel: showShadowForPanel,
        loadingForRquestProductDetails: loadingForRquestProductDetails,
        currentActiveTab: currentActiveTab,
        addToBagButtonShapeNotifier: addToBagButtonShapeNotifier,
        productNotAvailableNotifier: productNotAvailableNotifier,
        panelController: panelController,
        source: source,
        productsResolver: productsResolver,
        hideBottomNavigationBar: hideBottomNavigationBar,
      ),
    );
  }

  @override
  State<ProductQuickViewPopup> createState() => _ProductQuickViewPopupState();
}

class _ProductQuickViewPopupState extends State<ProductQuickViewPopup> {
  late final AppBloc appBloc;
  late final HomeBloc homeBloc;
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  /// قائمة المنتجات المعروضة حالياً (تُحدَّد حسب المصدر: فلاش/موصى/مميّز).
  List<filter.Products> products = [];

  int currentSelectedColor = -1;
  bool changeAppearSizeForProduct = true;

  /// لتفادي إرسال أحداث Bloc في كل rebuild — نرسل فقط عند تغيّر tapIndex.
  int _lastDispatchedTapIndex = -2;

  /// يمنع تكرار طلب الإغلاق (تُطلق إشارة الإغلاق من أكثر من مسار).
  bool _closeRequested = false;

  /// مصدرا القائمة: نستعمل ما تمرّره الصفحة، وإلا نُنشئ بديلاً ثابتاً مشتقّاً
  /// من [ProductQuickViewPopup.source] (نملكه فنتكفّل بـ dispose) ليبقى بناء
  /// الشجرة موحّداً للحالتين.
  late final ValueNotifier<bool> _flashDealSource;
  late final ValueNotifier<bool> _recommendSource;
  ValueNotifier<bool>? _ownedFlashDealSource;
  ValueNotifier<bool>? _ownedRecommendSource;

  @override
  void initState() {
    super.initState();
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    _flashDealSource =
        widget.productIsFlashDeal ??
        (_ownedFlashDealSource = ValueNotifier<bool>(
          widget.source == QuickViewProductSource.flashDeal,
        ));
    _recommendSource =
        widget.productIsRecommend ??
        (_ownedRecommendSource = ValueNotifier<bool>(
          widget.source == QuickViewProductSource.recommended,
        ));
    widget.tapIndexToAddProductToCart.addListener(_onTapIndexChanged);
  }

  @override
  void dispose() {
    widget.tapIndexToAddProductToCart.removeListener(_onTapIndexChanged);
    _ownedFlashDealSource?.dispose();
    _ownedRecommendSource?.dispose();
    super.dispose();
  }

  /// إشارة الإغلاق: عندما يعود الفهرس إلى \u200E-1 نُغلق المسار.
  void _onTapIndexChanged() {
    if (widget.tapIndexToAddProductToCart.value == -1) {
      _closePopup();
    }
  }

  void _closePopup() {
    if (_closeRequested || !mounted) return;
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    _closeRequested = true;
    if (route.isCurrent) {
      Navigator.of(context).pop();
    } else {
      // مسار آخر مفتوح فوقنا (مثلاً لوحة اختيار المقاس) — نُزيل مسارنا مباشرةً.
      Navigator.of(context).removeRoute(route);
    }
  }

  /// فلترة عروض الفلاش حسب تاريخ الانتهاء (خارج الـ builder لتحسين الأداء).
  static List<filter.Products> _filterFlashDealProductsByEndDate(
    List<filter.Products> raw,
  ) {
    final now = DateTime.now();
    final List<filter.Products> result = [];
    for (final element in raw) {
      DateTime endDate;
      try {
        endDate = tran.DateFormat(
          'MM/dd/yyyy',
          'en_US',
        ).parse(element.flashDealEndDate ?? '');
        endDate = endDate.add(const Duration(days: 1));
      } catch (e) {
        endDate = now;
      }
      final duration = endDate.difference(now);
      if (!duration.isNegative && duration.inSeconds >= 1) {
        result.add(element);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 1.sh,
      child: Stack(
        clipBehavior: Clip.none,
        children: [_shadowLayer(), _panelLayer()],
      ),
    );
  }

  /// الطبقة السوداء خلف اللوحة — الضغط عليها يُغلق اللوحة.
  Widget _shadowLayer() {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.showShadowForPanel,
      builder: (context, _showShadowForPanel, _) {
        return _showShadowForPanel
            ? GestureDetector(
                onTap: () {
                  widget.showShadowForPanel.value = false;
                  widget.currentActiveTab.value = -1;
                  widget.panelController.close();
                },
                child: Container(
                  height: 1.sh,
                  width: 1.sw,
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.55),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _panelLayer() {
    return ValueListenableBuilder<bool>(
      valueListenable: _recommendSource,
      builder: (context, _productIsRecommend, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _flashDealSource,
          builder: (context, _productIsFlashDeal, _) {
            return BlocBuilder<BoutiqueBloc, BoutiqueState>(
              buildWhen: (previous, current) {
                return previous
                            .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                            ?.paginationStatus !=
                        current
                            .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                            ?.paginationStatus ||
                    previous
                            .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                            ?.paginationStatus !=
                        current
                            .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                            ?.paginationStatus ||
                    previous
                            .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                            ?.paginationStatus !=
                        current
                            .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                            ?.paginationStatus;
              },
              builder: (context, state) {
                final resolver = widget.productsResolver;
                if (resolver != null) {
                  products = resolver();
                } else if (_productIsFlashDeal) {
                  final raw =
                      state
                          .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                          ?.items ??
                      [];
                  products = _filterFlashDealProductsByEndDate(raw);
                } else if (_productIsRecommend) {
                  products =
                      state.getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"] ==
                          null
                      ? []
                      : state
                            .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]!
                            .items;
                } else {
                  products =
                      state.getProductListingWithFiltersPaginationModels["*featured*withoutFilter"] ==
                          null
                      ? []
                      : state
                            .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]!
                            .items;
                }

                return ValueListenableBuilder<int>(
                  valueListenable: widget.tapIndexToAddProductToCart,
                  builder: (context, tapIndex, _) {
                    // إرسال الأحداث مرة واحدة عند تغيّر tapIndex فقط (تحسين أداء)
                    if (tapIndex != -1) {
                      if (tapIndex != _lastDispatchedTapIndex &&
                          products.isNotEmpty &&
                          tapIndex < products.length) {
                        _lastDispatchedTapIndex = tapIndex;
                        if (widget.hideBottomNavigationBar) {
                          appBloc.add(HideBottomNavigationBar(true));
                        }
                        homeBloc.add(
                          const IsChangedVariationWhenQtyZeroEvent(
                            isChangedVariationWhenQtyZero: false,
                          ),
                        );
                        changeAppearSizeForProduct = true;
                        homeBloc.add(
                          GetProductDatailsWithoutRelatedProductsEvent(
                            fromListingPage: true,
                            productSlug: products[tapIndex].slug,
                            productId: products[tapIndex].productId.toString(),
                          ),
                        );
                        widget.loadingForRquestProductDetails.value = true;
                        Future.delayed(
                          const Duration(milliseconds: 600),
                          () => widget.loadingForRquestProductDetails.value =
                              false,
                        );
                      }
                    } else {
                      if (_lastDispatchedTapIndex != -1) {
                        _lastDispatchedTapIndex = -1;
                        if (widget.hideBottomNavigationBar) {
                          appBloc.add(HideBottomNavigationBar(false));
                        }
                        widget.currentActiveTab.value = 0;
                      }
                      return const SizedBox.shrink();
                    }

                    // حارس حدود: القائمة قد تتغيّر (تحديث/انتهاء عرض فلاش)
                    // بينما النافذة مفتوحة — نتجنّب RangeError.
                    if (products.isEmpty || tapIndex >= products.length) {
                      return const SizedBox.shrink();
                    }

                    return ValueListenableBuilder<bool>(
                      valueListenable: widget.loadingForRquestProductDetails,
                      builder: (context, _loadingForRquestProductDetails, _) {
                        return Positioned(
                          bottom: -5,
                          child: _loadingForRquestProductDetails
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: TrydosLoader(size: 15),
                                )
                              : SizedBox(
                                  height: tapIndex == -1 ? 0 : 1.sh,
                                  width: 1.sw,
                                  child: BlocBuilder<HomeBloc, HomeState>(
                                    buildWhen: (previous, current) =>
                                        previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                                            current
                                                .getProductDetailWithoutSimilarRelatedProductsStatus ||
                                        previous.getCartOverviewStatus !=
                                            current.getCartOverviewStatus ||
                                        previous.authProductDetailsStatus !=
                                            current.authProductDetailsStatus ||
                                        previous.currentSelectedColorForEveryProduct !=
                                            current
                                                .currentSelectedColorForEveryProduct ||
                                        previous.enableAddToCardAfterChangeVariantZero !=
                                            current
                                                .enableAddToCardAfterChangeVariantZero ||
                                        previous.isChangedvariationWhenQtyZero !=
                                            current
                                                .isChangedvariationWhenQtyZero ||
                                        previous.cartCollection !=
                                            current.cartCollection,
                                    builder: (context, state) =>
                                        _buildSheet(context, state, tapIndex),
                                  ),
                                ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSheet(BuildContext context, HomeState state, int tapIndex) {
    List<filter.ProductColor>? productColors = [];
    if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
            GetProductDetailWithoutSimilarRelatedProductsStatus.success &&
        state.authProductDetailsStatus == AuthProductDetailsStatus.success) {
      productColors = state
          .cachedProductWithoutRelatedProductsModel[products[tapIndex].productId
              .toString()]!
          .product!
          .colors;
    }

    String productId = products[tapIndex].productId.toString();
    String productSlug = products[tapIndex].slug.toString();
    currentSelectedColor =
        state.currentSelectedColorForEveryProduct[productSlug] ??
        (products[tapIndex].syncColorImages?.length ?? 0) ~/ 2;
    String currentSelectedColorOption = ((productColors?.length ?? 0) > 0)
        ? productColors![currentSelectedColor].option ?? ""
        : "";

    String currentVariantType =
        "${currentSelectedColorOption != "" ? currentSelectedColorOption : ""}" +
        "${(state.currentColorSizeForCart?["choiceOption"] != null && !(state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.sizes?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["choiceOption"] != "") && (currentSelectedColorOption != "") ? "-" : ""}" +
        "${(state.currentColorSizeForCart?["choiceOption"] != null && !(state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.sizes?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["choiceOption"] != "") ? "${state.currentColorSizeForCart?["choiceOption"]}" : ""}";

    productDetail.Variation? currentVariation = state
        .authProductDetailsModel
        ?.data
        ?.variation
        ?.firstWhere(
          (element) => element.type!.contains(currentVariantType),
          orElse: () {
            return productDetail.Variation();
          },
        );
    String currentVariationId = currentVariation?.id ?? "";

    currentSelectedColor =
        state.currentSelectedColorForEveryProduct[productSlug] ??
        (products[tapIndex].syncColorImages?.length ?? 0) ~/ 2;

    if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                GetProductDetailWithoutSimilarRelatedProductsStatus.failure ||
            state.authProductDetailsStatus ==
                AuthProductDetailsStatus.failure) &&
        (prefsRepository.marketToken == "" ||
            prefsRepository.marketToken == null)) {
      Future.delayed(const Duration(seconds: 5), () {
        homeBloc.add(
          GetProductDatailsWithoutRelatedProductsEvent(
            fromListingPage: true,
            productSlug: products[tapIndex].slug,
            productId: products[tapIndex].productId.toString(),
          ),
        );
      });
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
              GetProductDetailWithoutSimilarRelatedProductsStatus.success &&
          state.authProductDetailsStatus == AuthProductDetailsStatus.success &&
          tapIndex != -1)) {
        if (state
                .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                    .productId
                    .toString()]
                ?.product
                ?.countryIsRestricted ==
            true) {
          widget.productNotAvailableNotifier.value = LocaleKeys
              .product_is_not_available_in_your_country
              .tr();
        } else if (state
                .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                    .productId
                    .toString()]
                ?.product
                ?.isActive ==
            false) {
          widget.productNotAvailableNotifier.value = LocaleKeys
              .this_product_is_not_available_in_store
              .tr();
        } else {
          widget.productNotAvailableNotifier.value = null;
        }
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
              GetProductDetailWithoutSimilarRelatedProductsStatus.failure ||
          state.authProductDetailsStatus == AuthProductDetailsStatus.failure) {
        widget.tapIndexToAddProductToCart.value = -1;
      }
    });
    homeBloc.add(
      AddSizesForColorsEvent(
        currentColorName: !(productColors.isNullOrEmpty)
            ? productColors![currentSelectedColor].option ?? ""
            : "",
        variation: state.authProductDetailsModel?.data != null
            ? state.authProductDetailsModel?.data!.variation
            : null,
      ),
    );
    if (productId != "" &&
        tapIndex != -1 &&
        state.getProductDetailWithoutSimilarRelatedProductsStatus ==
            GetProductDetailWithoutSimilarRelatedProductsStatus.success &&
        state.authProductDetailsStatus == AuthProductDetailsStatus.success &&
        changeAppearSizeForProduct) {
      if (!state.cachedProductWithoutRelatedProductsModel.containsKey(
            productId,
          ) ||
          (state.cachedProductWithoutRelatedProductsModel[productId] != null
              ? state
                            .cachedProductWithoutRelatedProductsModel[productId]!
                            .product !=
                        null
                    ? state
                          .cachedProductWithoutRelatedProductsModel[productId]!
                          .product!
                          .sizes
                          .isNullOrEmpty
                    : true
              : true)) {
        homeBloc.add(AddCurrentColorSizeEvent());
      } else if (!(state.cachedProductWithoutRelatedProductsModel[productId] !=
              null
          ? state
                        .cachedProductWithoutRelatedProductsModel[productId]!
                        .product !=
                    null
                ? state
                      .cachedProductWithoutRelatedProductsModel[productId]!
                      .product!
                      .sizes
                      .isNullOrEmpty
                : true
          : true)) {
        String sizeSelect =
            (state
                        .cachedProductWithoutRelatedProductsModel[productId]!
                        .product!
                        .sizes
                        ?.length ??
                    0) ==
                0
            ? ""
            : state
                  .cachedProductWithoutRelatedProductsModel[productId]!
                  .product!
                  .sizes![(state
                          .cachedProductWithoutRelatedProductsModel[productId]!
                          .product
                          ?.sizes
                          ?.length ??
                      0) ~/
                  2];
        String sizeOptionSelect =
            (state
                        .cachedProductWithoutRelatedProductsModel[productId]!
                        .product!
                        .sizes
                        ?.length ??
                    0) ==
                0
            ? ""
            : state
                  .cachedProductWithoutRelatedProductsModel[productId]!
                  .product!
                  .sizes![(state
                          .cachedProductWithoutRelatedProductsModel[productId]!
                          .product
                          ?.sizes
                          ?.length ??
                      0) ~/
                  2];

        homeBloc.add(
          AddCurrentColorSizeEvent(
            choice_1: sizeSelect,
            choiceOption: sizeOptionSelect,
          ),
        );
      }
      homeBloc.add(
        const IsChangedVariationWhenQtyZeroEvent(
          isChangedVariationWhenQtyZero: true,
        ),
      );

      widget.currentActiveTab.value = 3;
      Future.delayed(const Duration(milliseconds: 600), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.panelController.open();
          changeAppearSizeForProduct = false;
        });
      });
    }

    return state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                GetProductDetailWithoutSimilarRelatedProductsStatus.loading ||
            state.authProductDetailsStatus ==
                AuthProductDetailsStatus.loading ||
            state.enableAddToCardAfterChangeVariantZero !=
                EnableAddToCardAfterChangeVariantZero.success ||
            state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                    .productId
                    .toString()] ==
                null
        ? Container(
            width: 1.sw,
            height: 1.sh,
            color: const Color.fromRGBO(0, 0, 0, 0.3),
            child: TrydosLoader(size: 25),
          )
        : ValueListenableBuilder<int>(
            valueListenable: widget.currentActiveTab,
            builder: (context, activeTab, _) {
              // التبويب \u200E-1 يعني أن اللوحة مُغلقة (أو في طريقها للإغلاق: يضبطه
              // onPanelClosed فوراً بينما يصل tapIndex إلى \u200E-1 بعد 300ms).
              // من دون هذا الحارس ينكمش المحتوى في تلك الفجوة، وبما أن جذر
              // ProductDetailsBottomSheetNew هو SingleChildScrollView فإنه
              // يحاذي المحتوى الأقصر من الـ viewport (1.sh) إلى الأعلى، فيومض
              // الإطار السفلي أعلى الشاشة للحظة قبل أن تُغلق النافذة.
              if (activeTab == -1) return const SizedBox.shrink();
              return ValueListenableBuilder<bool>(
                valueListenable: widget.finishRedeem,
                builder: (context, _finishRedeem, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: widget.visibleFlashDeal,
                    builder: (context, _visibleFlashDeal, _) {
                      bool isFlashDealEnded = false;
                      DateTime endDate;
                      Duration _duration = const Duration();
                      final now = DateTime.now();
                      try {
                        endDate = tran.DateFormat('MM/dd/yyyy', 'en_US').parse(
                          state
                                  .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                      .productId
                                      .toString()]
                                  ?.product
                                  ?.flashDealEndDate ??
                              "",
                        );
                        endDate = endDate.add(const Duration(days: 1));
                      } catch (e) {
                        endDate = DateTime.now();
                        if (kDebugMode) print('Error parsing date: $e');
                      }
                      _duration = endDate.difference(now);
                      if (_duration.isNegative || _duration.inSeconds < 1) {
                        isFlashDealEnded = true;
                      }

                      return ProductDetailsBottomSheetNew(
                        showShadowForPanel: widget.showShadowForPanel,
                        currentVariant: currentVariantType,
                        visibleRedeemNotifier: widget.finishRedeem,
                        variationId: currentVariationId,
                        visibleFlashDeal: widget.visibleFlashDeal,
                        isFlashDealEnded: isFlashDealEnded,
                        flashDealEndDate:
                            state
                                .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                    .productId
                                    .toString()]
                                ?.product
                                ?.flashDealEndDate ??
                            "",
                        redeemVariantPrice:
                            (currentVariation?.luckPrice != null)
                            ? currentVariation?.luckPrice ?? 0
                            : state
                                      .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                          .productId
                                          .toString()]
                                      ?.product
                                      ?.redeemPrice ??
                                  0,
                        isRedeem:
                            (prefsRepository
                                        .getRedeemDateForProduct(
                                          products[tapIndex].productId
                                              .toString(),
                                        )
                                        ?.isAfter(
                                          DateTime.now().add(
                                            const Duration(seconds: 1),
                                          ),
                                        ) ==
                                    true &&
                                state
                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                            .productId
                                            .toString()]
                                        ?.product
                                        ?.isRedeem ==
                                    true) ||
                            (GetIt.I<PrefsRepository>()
                                        .getRedeemSecondRemainingForProduct(
                                          products[tapIndex].productId
                                              .toString(),
                                        ) ??
                                    0) >
                                0,
                        redeemPrice:
                            state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                    .productId
                                    .toString()] !=
                                null
                            ? state
                                          .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                              .productId
                                              .toString()]!
                                          .product !=
                                      null
                                  ? state
                                            .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                .productId
                                                .toString()]!
                                            .product!
                                            .redeemPrice ??
                                        0
                                  : 0
                            : 0,
                        initOfferPrice: (products[tapIndex].offerPrice ?? 0),
                        initPrice: (products[tapIndex].price ?? 0),
                        isGetFullProductDetails: false,
                        currentColorOption: productColors.isNullOrEmpty
                            ? ''
                            : productColors?[currentSelectedColor].option ??
                                  products[tapIndex]
                                      .colors![currentSelectedColor]
                                      .option ??
                                  "",
                        productNotAvailableNotifier:
                            widget.productNotAvailableNotifier,
                        currentActiveTab: widget.currentActiveTab,
                        collectedAfterOrdering:
                            state
                                .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                    .productId
                                    .toString()]
                                ?.product
                                ?.collectedAfterOrdering ==
                            1,
                        tapIndexToAddProductToCart:
                            widget.tapIndexToAddProductToCart,
                        fromListingPage: true,
                        productIdForCashData: products[tapIndex].productId
                            .toString(),
                        panelController: widget.panelController,
                        productSlugForTopic:
                            state
                                .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                    .productId
                                    .toString()]
                                ?.product
                                ?.slug ??
                            "",
                        productDescription: HtmlParser.parseHTML(
                          products[tapIndex].details ?? "",
                        ).text,
                        countOfPieces:
                            state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                    .productId
                                    .toString()] !=
                                null
                            ? state
                                          .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                              .productId
                                              .toString()]!
                                          .product !=
                                      null
                                  ? state
                                            .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                .productId
                                                .toString()]!
                                            .product!
                                            .countOfPieces ??
                                        0
                                  : 0
                            : 0,
                        addToBagButtonShapeNotifier:
                            widget.addToBagButtonShapeNotifier,
                        currentColornum: productColors.isNullOrEmpty
                            ? ''
                            : productColors?[currentSelectedColor].color ?? "",
                        boutiqueIcon:
                            state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                    .productId
                                    .toString()] !=
                                null
                            ? state
                                          .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                              .productId
                                              .toString()]!
                                          .product !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                    .productId
                                                    .toString()]!
                                                .product!
                                                .boutique !=
                                            null
                                        ? state
                                                      .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                          .productId
                                                          .toString()]!
                                                      .product!
                                                      .boutique!
                                                      .icon !=
                                                  null
                                              ? state
                                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                            .productId
                                                            .toString()]!
                                                        .product!
                                                        .boutique!
                                                        .icon!
                                                        .filePath ??
                                                    ""
                                              : ""
                                        : ""
                                  : ""
                            : "",
                        boutiqueId:
                            state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                    .productId
                                    .toString()] !=
                                null
                            ? state
                                          .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                              .productId
                                              .toString()]!
                                          .product !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                    .productId
                                                    .toString()]!
                                                .product!
                                                .boutique !=
                                            null
                                        ? state
                                              .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                  .productId
                                                  .toString()]!
                                              .product!
                                              .boutique!
                                              .id!
                                        : 0
                                  : 0
                            : 0,
                        currentColorName: productColors.isNullOrEmpty
                            ? ''
                            : productColors?[currentSelectedColor].name ?? "",
                        productItem: products[tapIndex].copyWith(
                          price: currentVariation?.price != null
                              ? currentVariation?.price
                              : state
                                    .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                        .productId
                                        .toString()]!
                                    .product
                                    ?.price,
                          offerPrice: currentVariation?.offerPrice != null
                              ? currentVariation?.offerPrice
                              : state
                                    .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                        .productId
                                        .toString()]!
                                    .product
                                    ?.offerPrice,
                          variation:
                              state.authProductDetailsModel?.data?.variation,

                          availableQuantity:
                              state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                      .productId
                                      .toString()] ==
                                  null
                              ? 0
                              : state
                                    .authProductDetailsModel
                                    ?.data
                                    ?.availableQuantity,
                          sizes:
                              state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                      .productId
                                      .toString()] ==
                                  null
                              ? []
                              : state
                                    .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                        .productId
                                        .toString()]!
                                    .product
                                    ?.sizes,
                          colors: state
                              .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                  .productId
                                  .toString()]!
                              .product
                              ?.colors,
                          images:
                              state.cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                      .productId
                                      .toString()] ==
                                  null
                              ? []
                              : state
                                    .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                        .productId
                                        .toString()]!
                                    .product
                                    ?.images,
                          syncColorImages: state
                              .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                  .productId
                                  .toString()]!
                              .product
                              ?.syncColorImages,
                        ),
                        currentColor: currentSelectedColor,
                        maxAllowedToAddCart:
                            state
                                .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                    .productId
                                    .toString()]
                                ?.product
                                ?.maxAllowedQty ??
                            "0",
                      );
                    },
                  );
                },
              );
            },
          );
  }
}
