import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// صفحة مقارنة منتجَين جنباً إلى جنب.
///
/// البحث يعيش في [BoutiqueBloc] وتفاصيل المنتج في [HomeBloc] — لأن كل حالة
/// استخدام مُسجَّلة في بلوكها. والعمودان مستقلّان تماماً: لكل واحد حالة بحث
/// وحالة تفاصيل خاصّة به، فالتحميل في أحدهما لا يمسّ الآخر.
class CompareProductsPage extends StatefulWidget {
  const CompareProductsPage({super.key});

  @override
  State<CompareProductsPage> createState() => _CompareProductsPageState();
}

class _CompareProductsPageState extends State<CompareProductsPage> {
  /// عمودان: 0 و1.
  static const List<int> _sides = <int>[0, 1];

  final Map<int, TextEditingController> _controllers = {
    0: TextEditingController(),
    1: TextEditingController(),
  };
  final Map<int, FocusNode> _focusNodes = {0: FocusNode(), 1: FocusNode()};

  /// مؤقّت تهدئة لكل عمود: البحث مع كل حرف يُغرق الخادم بطلبات لا تُقرأ.
  final Map<int, Timer?> _debouncers = {0: null, 1: null};

  /// العمود الذي تُعرض قائمة اقتراحاته الآن (واحد على الأكثر).
  int? _openSuggestionsSide;

  @override
  void initState() {
    LastPagesTracker.push('CompareProductsPage');
    super.initState();
  }

  @override
  void dispose() {
    for (final Timer? timer in _debouncers.values) {
      timer?.cancel();
    }
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    for (final FocusNode node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _onQueryChanged(int side, String value) {
    _debouncers[side]?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _openSuggestionsSide = null);
      context.read<BoutiqueBloc>().add(ClearCompareSearchEvent(side));
      return;
    }
    setState(() => _openSuggestionsSide = side);
    _debouncers[side] = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<BoutiqueBloc>().add(
        SearchProductsForCompareEvent(query: value, side: side),
      );
    });
  }

  void _onProductSelected(int side, Products product) {
    _controllers[side]!.text = product.name ?? '';
    _focusNodes[side]!.unfocus();
    setState(() => _openSuggestionsSide = null);
    context.read<BoutiqueBloc>().add(ClearCompareSearchEvent(side));
    context.read<HomeBloc>().add(
      GetProductDetailsForCompareEvent(
        productSlug: product.slug ?? '',
        side: side,
      ),
    );
  }

  void _onClearSide(int side) {
    _controllers[side]!.clear();
    setState(() => _openSuggestionsSide = null);
    context.read<BoutiqueBloc>().add(ClearCompareSearchEvent(side));
    context.read<HomeBloc>().add(ClearCompareProductEvent(side));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TrydosAppBar(
        appBarParams: AppBarParams(
          backgroundColor: const Color(0x000000),
          action: [
            const Spacer(),
            MyTextWidget(
              LocaleKeys.compare_products.tr(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: const Color(0xff1D1D1D),
                fontSize: 14.sp,
              ),
            ),
            const Spacer(),
          ],
          scrolledUnderElevation: 0,
          backIconColor: Colors.black,
          withShadow: false,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchRow(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: _buildComparisonTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── حقلا البحث ───────────────────────────

  Widget _buildSearchRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSearchField(0)),
          SizedBox(width: 10.w),
          Expanded(child: _buildSearchField(1)),
        ],
      ),
    );
  }

  Widget _buildSearchField(int side) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: const Color(0xffF7F8FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffE3E6EA)),
          ),
          child: Row(
            children: [
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: _controllers[side],
                  focusNode: _focusNodes[side],
                  onChanged: (value) => _onQueryChanged(side, value),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: LocaleKeys.search_for_product.tr(),
                    hintStyle: context.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xff9AA0A6),
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 20,
                  color: Color(0xff9AA0A6),
                ),
                onPressed: () => _onClearSide(side),
              ),
              SizedBox(width: 6.w),
            ],
          ),
        ),
        if (_openSuggestionsSide == side) _buildSuggestions(side),
      ],
    );
  }

  /// قائمة الاقتراحات تحت حقل البحث الخاص بالعمود.
  Widget _buildSuggestions(int side) {
    return BlocBuilder<BoutiqueBloc, BoutiqueState>(
      buildWhen: (p, c) =>
          p.compareSearchStatus[side] != c.compareSearchStatus[side] ||
          p.compareSearchResults[side] != c.compareSearchResults[side],
      builder: (context, state) {
        final SearchProductsForCompareStatus status =
            state.compareSearchStatus[side] ??
            SearchProductsForCompareStatus.init;
        if (status == SearchProductsForCompareStatus.init) {
          return const SizedBox.shrink();
        }

        final List<Products> results =
            state.compareSearchResults[side] ?? const <Products>[];

        return Container(
          margin: EdgeInsets.only(top: 4.h),
          constraints: BoxConstraints(maxHeight: 240.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffE3E6EA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: status == SearchProductsForCompareStatus.loading
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : results.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: MyTextWidget(
                      LocaleKeys.no_products_found.tr(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xff9AA0A6),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final Products product = results[index];
                    return InkWell(
                      onTap: () => _onProductSelected(side, product),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          children: [
                            _thumb(product, size: 34),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MyTextWidget(
                                    product.name ?? '',
                                    maxLines: 1,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          fontSize: 12.sp,
                                          color: const Color(0xff2C6ECB),
                                        ),
                                  ),
                                  MyTextWidget(
                                    product.offerPriceFormatted ??
                                        product.priceFormatted ??
                                        '',
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 11.sp,
                                          color: const Color(0xff6B7280),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _thumb(Products product, {required double size}) {
    final String? url = product.images?.isNotEmpty ?? false
        ? product.images!.first.filePath
        : null;
    if (url == null || url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xffF1F2F4),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: MyCachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        imageFit: BoxFit.cover,
      ),
    );
  }

  // ─────────────────────────── جدول المقارنة ───────────────────────────

  Widget _buildComparisonTable() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.compareProducts != c.compareProducts ||
          p.compareProductDetailsStatus != c.compareProductDetailsStatus,
      builder: (context, state) {
        // الجدول يُعرض دائماً — حتى بلا منتجات مختارة. كان يُستبدل برسالة
        // إرشادية، فيظهر للمستخدم كأن الصفحة فارغة ولا يرى ما سيُقارَن أصلاً.
        // بقاء الهيكل يوضّح الحقول ويجعل امتلاء الأعمدة تدريجياً مفهوماً.
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffE3E6EA)),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _row(
                state,
                LocaleKeys.product_name.tr(),
                (p) => MyTextWidget(
                  p.name ?? '',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xff2C6ECB),
                    fontSize: 12.sp,
                  ),
                ),
                shimmerHeight: 16,
              ),
              _row(
                state,
                LocaleKeys.product_image.tr(),
                (p) => Center(child: _thumb(p, size: 90)),
                shimmerHeight: 90,
              ),
              _row(
                state,
                LocaleKeys.product_colors.tr(),
                _colorsCell,
                shimmerHeight: 20,
              ),
              _row(
                state,
                LocaleKeys.product_sizes.tr(),
                _sizesCell,
                shimmerHeight: 24,
              ),
              _row(
                state,
                LocaleKeys.product_price.tr(),
                (p) => MyTextWidget(
                  _formatPrice(state, p.price),
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                  ),
                ),
                shimmerHeight: 16,
              ),
              _row(
                state,
                LocaleKeys.product_offer_price.tr(),
                (p) => MyTextWidget(
                  _formatPrice(state, p.offerPrice),
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: const Color(0xff1E9E5A),
                  ),
                ),
                shimmerHeight: 16,
              ),
              _row(
                state,
                LocaleKeys.product_details.tr(),
                // الوصف يأتي من الخادم بصيغة HTML (<p>, <strong> …). نستخرج
                // نصّه بنفس أداة صفحة تفاصيل المنتج بدل عرض الوسوم خاماً.
                (p) => MyTextWidget(
                  HtmlParser.parseHTML(p.details ?? '').text,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: const Color(0xff8A6D3B),
                    height: 1.4,
                  ),
                ),
                shimmerHeight: 40,
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  /// نصّ السعر — بنفس دالة التنسيق المستعملة في صفحة تفاصيل المنتج
  /// (`HelperFunctions.formatNumber`)، فيتطابق العرض بين الشاشتين.
  ///
  /// كان الاعتماد على `priceFormatted` وحده، وهو غير مُعبَّأ في استجابة تفاصيل
  /// المنتج — فتظهر خانة السعر فارغة. الصواب بناؤه من `price` مضروباً في سعر
  /// الصرف كما تفعل صفحة التفاصيل.
  String _formatPrice(HomeState state, double? value) {
    if (value == null) return '';

    final currency = state.getCurrencyForCountryModel?.data?.currency;
    final double rate = (currency?.exchangeRate ?? 1).toDouble();
    final String symbol = currency?.symbol ?? '';

    final String amount = HelperFunctions.formatNumber(
      numberToFormate: value * rate,
    );
    return '$amount $symbol'.trim();
  }

  /// صفّ واحد: عنوان الحقل ثم خليّة لكل عمود.
  ///
  /// كل خليّة تقرأ **حالة عمودها وحده** — فالـ shimmer يظهر في جهة المنتج قيد
  /// التحميل فقط، بينما يبقى العمود الآخر معروضاً كما هو.
  Widget _row(
    HomeState state,
    String label,
    Widget Function(Products) cellBuilder, {
    required double shimmerHeight,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 90.w,
            color: const Color(0xffDCE9FB),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
            alignment: AlignmentDirectional.centerStart,
            child: MyTextWidget(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 12.sp,
                color: const Color(0xff1F3A63),
              ),
            ),
          ),
          for (final int side in _sides)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border(
                    left: const BorderSide(color: Color(0xffE3E6EA)),
                    bottom: isLast
                        ? BorderSide.none
                        : const BorderSide(color: Color(0xffE3E6EA)),
                  ),
                ),
                child: _cell(state, side, cellBuilder, shimmerHeight),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(
    HomeState state,
    int side,
    Widget Function(Products) cellBuilder,
    double shimmerHeight,
  ) {
    final GetCompareProductDetailsStatus status =
        state.compareProductDetailsStatus[side] ??
        GetCompareProductDetailsStatus.init;

    if (status == GetCompareProductDetailsStatus.loading) {
      return _shimmerBox(shimmerHeight);
    }

    final Products? product = state.compareProducts[side];
    if (product == null) return SizedBox(height: shimmerHeight);

    return cellBuilder(product);
  }

  Widget _shimmerBox(double height) {
    return Shimmer.fromColors(
      baseColor: const Color(0xffE6E6E6),
      highlightColor: const Color(0xffF5F5F5),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xffE6E6E6),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  // ─────────────────────────── خلايا خاصّة ───────────────────────────

  Widget _colorsCell(Products product) {
    final List<ProductColor> colors = product.colors ?? const <ProductColor>[];
    if (colors.isEmpty) return const SizedBox.shrink();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: colors.map((ProductColor color) {
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: _parseColor(color.color),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xffD9D9D9)),
          ),
        );
      }).toList(),
    );
  }

  Widget _sizesCell(Products product) {
    final List<String> sizes = product.sizes ?? const <String>[];
    if (sizes.isEmpty) return const SizedBox.shrink();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: sizes.map((String size) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xffF1F2F4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: MyTextWidget(
            size,
            style: context.textTheme.bodySmall?.copyWith(fontSize: 11.sp),
          ),
        );
      }).toList(),
    );
  }

  /// يحوّل لون الخادم (`#RRGGBB` أو `RRGGBB`) إلى [Color].
  /// أي صيغة غير متوقّعة تعطي رمادياً بدل أن ترمي.
  Color _parseColor(String? raw) {
    if (raw == null || raw.isEmpty) return const Color(0xffD9D9D9);
    final String hex = raw.replaceAll('#', '').trim();
    if (hex.length != 6) return const Color(0xffD9D9D9);
    final int? value = int.tryParse('FF$hex', radix: 16);
    return value == null ? const Color(0xffD9D9D9) : Color(value);
  }
}
