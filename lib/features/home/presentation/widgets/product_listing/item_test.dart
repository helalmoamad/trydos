import 'dart:math';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as listing;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:tuple/tuple.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../../../../../core/utils/theme_state.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/my_text_widget.dart';
import 'my_gallery3d_widget.dart';

/// 🚀 نسخة محسنة من ProductListing3DSlider مع أداء فائق والمحافظة على التصميم
class ProductListing3DSliderOptimized extends StatefulWidget {
  const ProductListing3DSliderOptimized({
    super.key,
    required this.setThisEnabled,
    required this.slidingModeItem,
    required this.itemIndex,
    this.fromHomePage = false,
    this.imageSource,
    required this.tapIndexToAddProductToCart,
    required this.productItem,
    this.productIsFlashDeal,
    this.fromFlashDeal,
    required this.displayImageColors,
    required this.currentChosenColor,
  });

  final Tuple2<int, int> slidingModeItem;
  final void Function(int, int) setThisEnabled;
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final int itemIndex;
  final bool displayImageColors;
  final bool fromHomePage;
  final String? imageSource;
  final bool? fromFlashDeal;
  final productListingModel.Products productItem;
  final ValueNotifier<int> currentChosenColor;
  final ValueNotifier<bool>? productIsFlashDeal;

  @override
  State<ProductListing3DSliderOptimized> createState() =>
      _ProductListing3DSliderOptimizedState();
}

class _ProductListing3DSliderOptimizedState
    extends ThemeState<ProductListing3DSliderOptimized>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // 🎯 Optimized State Management
  late SliderStateOptimized _sliderState;
  late HomeBloc _homeBloc;
  late AnimationController _animationController;

  // 🎮 Minimal Controllers - Only Essential Ones
  late Gallery3DController _colorController;
  late Gallery3DController _imageController;
  late CarouselSliderController _carouselController;

  // 💾 Cached Data - Computed Once
  List<productListingModel.SyncColorImage>? _processedColorImages;
  List<String>? _cachedImages;
  List<double>? _cachedOriginalWidths;
  List<double>? _cachedOriginalHeights;

  // 🎭 Visual State
  int _currentSlidingMode = 0;
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => false; // Allow disposal when not visible

  // 🛡️ COMPREHENSIVE RANGE ERROR PROTECTION HELPERS

  /// 🔒 Safe Index Access Helper
  int _getSafeColorIndex(int index) {
    if (_processedColorImages?.isEmpty ?? true) return 0;
    return index.clamp(0, _processedColorImages!.length - 1);
  }

  /// 🔒 Safe Image Index Access Helper
  int _getSafeImageIndex(int index, List<dynamic>? list) {
    if (list?.isEmpty ?? true) return 0;
    return index.clamp(0, list!.length - 1);
  }

  /// 🔒 Safe Array Access Helper
  T? _safeArrayAccess<T>(List<T>? array, int index, {T? defaultValue}) {
    if (array?.isEmpty ?? true) return defaultValue;
    if (index < 0 || index >= array!.length) return defaultValue;
    return array[index];
  }

  @override
  void initState() {
    super.initState();
    _initializeOptimizedSlider();
  }

  /// 🚀 Optimized Initialization
  void _initializeOptimizedSlider() {
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 🎯 Process data once and cache
    _processColorImagesData();
    _initializeControllers();
    _initializeState();
  }

  /// 📊 Smart Data Processing - No Duplication
  void _processColorImagesData() {
    final originalImages = widget.productItem.syncColorImages;
    if (originalImages == null || originalImages.isEmpty) {
      _processedColorImages = [];
      return;
    }

    // 🔧 Filter and prepare data smartly
    _processedColorImages = originalImages
        .where((element) => element.images?.isNotEmpty == true)
        .toList();

    // 🎯 Smart duplication only when needed for circular effect
    if (_processedColorImages!.length > 1) {
      final originalLength = _processedColorImages!.length;
      final duplicatedImages =
          List<productListingModel.SyncColorImage>.from(_processedColorImages!);

      // Add only necessary duplicates for smooth circular scrolling
      _processedColorImages!.addAll(duplicatedImages);

      // Add one more copy only if we have exactly 1 color for smooth animation
      if (originalLength == 1) {
        _processedColorImages!.addAll(duplicatedImages);
      }
    }

    // 📦 Cache image URLs and dimensions
    _cacheImageData();
  }

  /// 🗂️ Cache Image Data for Performance
  void _cacheImageData() {
    if (_processedColorImages?.isEmpty ?? true) return;

    _cachedImages =
        _processedColorImages!.map((e) => e.images!.first.filePath!).toList();

    _cachedOriginalHeights = _processedColorImages!
        .map((e) =>
            double.tryParse(e.images!.first.originalHeight ?? '200') ?? 200.0)
        .toList();

    _cachedOriginalWidths = _processedColorImages!
        .map((e) =>
            double.tryParse(e.images!.first.originalWidth ?? '200') ?? 200.0)
        .toList();
  }

  /// 🎮 Initialize Controllers Efficiently - FIXED: إيقاف الحركة التلقائية
  void _initializeControllers() {
    _carouselController = CarouselSliderController();

    // 🎯 Smart controller setup based on data
    final imageCount = max(3, (widget.productItem.images?.length ?? 0));
    final colorCount = _processedColorImages?.length ?? 0;

    _imageController = Gallery3DController(
      itemCount: imageCount,
      autoLoop: false, // إيقاف الحركة التلقائية
      minScale: 0.8,
      initialIndex: 0,
      scrollTime: 30,
    );

    // 🎯 Always initialize _colorController - NO AUTO MOVEMENT
    _colorController = Gallery3DController(
      itemCount: max(3, colorCount),
      autoLoop: false, // 🔥 إيقاف الحركة التلقائية نهائياً
      minScale: colorCount >= 3 ? _calculateMinScale(colorCount) : 0.8,
      initialIndex: 0, // 🔥 البدء من 0 دائماً بدلاً من حساب معقد
      primaryshiftingOffsetDivision:
          colorCount >= 3 ? _calculateDivision(colorCount) : 2.0,
      scrollTime: 20,
    );
  }

  /// 📐 Smart Scale and Division Calculation
  double _calculateMinScale(int count) {
    if (count == 4) return 0.7;
    if (count <= 8) return 0.6;
    return 0.4;
  }

  double _calculateDivision(int count) {
    if (count == 4) return 4.5;
    if (count <= 8) return 2.8;
    return 1.6;
  }

  /// 🎯 Initialize State - FIXED: منع الحركة التلقائية
  void _initializeState() {
    final colorCount = _processedColorImages?.length ?? 0;
    // 🛡️ Safe initial index calculation to prevent RangeError
    _sliderState = SliderStateOptimized(
      currentColorIndex: 0, // 🔥 البدء من 0 دائماً - بدون حركة
      currentImageIndex: 0,
      totalColors: colorCount,
      totalImages: widget.productItem.images?.length ?? 0,
    );

    // 🎭 Set initial sliding mode
    _currentSlidingMode = widget.itemIndex == widget.slidingModeItem.item1
        ? widget.slidingModeItem.item2
        : 0;

    // 📡 Notify HomeBloc with delay to avoid blocking UI
    _debounceNotifyColorChange();
  }

  /// 📡 Debounced Color Change Notification
  void _debounceNotifyColorChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _homeBloc.add(AddCurrentSelectedColorEvent(
          currentSelectedColor: _sliderState.currentColorIndex,
          productSlug: widget.productItem.slug.toString(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: _buildOptimizedSliderContent(),
      ),
    );
  }

  /// 🏗️ Main Content Builder - FIXED: منع Bottom Overflow
  Widget _buildOptimizedSliderContent() {
    return SizedBox(
      height: widget.fromHomePage ? 350 : 400, // ارتفاع محدد لمنع overflow
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🖼️ المحتوى الرئيسي (الصور)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: widget.fromHomePage ? 250 : 300, // مساحة للصور
              child: _buildMainImageArea(),
            ),
          ),

          // 🎨 Color Selector (فقط إذا لم نكن في وضع الصور)
          if (_currentSlidingMode != 2 &&
              _processedColorImages?.isNotEmpty == true)
            Positioned(
              bottom: widget.fromHomePage
                  ? 80
                  : 90, // مساحة كافية للمعلومات السفلية
              child: _buildColorSelectorWidget(),
            ),

          // 💰 Product Info Section (في الأسفل)
          Positioned(
            bottom: 5, // مساحة آمنة من الأسفل
            left: 0,
            right: 0,
            child: _buildProductInfoWidget(),
          ),
        ],
      ),
    );
  }

  /// 🎨 Widget منفصل لـ Color Selector
  Widget _buildColorSelectorWidget() {
    return AnimatedScale(
      scale: _currentSlidingMode == 0 ? 0.625 : 1,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onPanStart: (details) {
          if (_currentSlidingMode == 0) {
            widget.setThisEnabled(widget.itemIndex, 1);
          }
        },
        onPanDown: (details) {
          if (_currentSlidingMode == 0) {
            widget.setThisEnabled(widget.itemIndex, 1);
          }
        },
        child: _buildColorCircles(),
      ),
    );
  }

  /// 💰 Widget منفصل لـ Product Info (بدون Positioned داخلي)
  Widget _buildProductInfoWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min, // تقليل المساحة المستخدمة
      children: [
        // معلومات المنتج
        SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: LanguageService.languageCode == "ar"
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Brand Icon
                _buildBrandIcon(),
                const SizedBox(height: 3), // تقليل المسافة
                // Product Name and Category
                _buildProductNameRow(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5), // تقليل المسافة
        // Price Section
        _buildPriceSection(),
      ],
    );
  }

  /// 🖼️ Optimized Main Image Area
  Widget _buildMainImageArea() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Different modes handling
        if (_currentSlidingMode != 0)
          _buildSlidingModeContent()
        else
          _buildDefaultImageView(),
      ],
    );
  }

  /// 🎭 Sliding Mode Content
  Widget _buildSlidingModeContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 📸 Image Thumbnails (Mode 2)
        if (_currentSlidingMode == 2) _buildImageThumbnails(),

        // 🖼️ 3D Image Gallery (Mode 2)
        if (_currentSlidingMode == 2) _buildImageGallery(),

        // 🎨 3D Color Gallery (Mode 1)
        if (_currentSlidingMode == 1) _buildColorGallery(),

        // 🏷️ Color Name Display (Mode 1)
        if (_currentSlidingMode == 1) _buildColorNameDisplay(),
      ],
    );
  }

  /// 📸 Optimized Image Thumbnails
  Widget _buildImageThumbnails() {
    if (_processedColorImages?.isEmpty ?? true) return const SizedBox();

    // 🛡️ Safe index access with bounds checking
    final safeColorIndex = _sliderState.currentColorIndex
        .clamp(0, (_processedColorImages?.length ?? 1) - 1);
    final currentColorImages = _processedColorImages!.length > safeColorIndex
        ? (_processedColorImages![safeColorIndex].images ?? [])
        : <listing.Thumbnail>[];

    if (currentColorImages.isEmpty) return const SizedBox();

    return SizedBox(
      height: 45,
      width: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: currentColorImages.length,
        padding: const EdgeInsets.only(left: 5, top: 5),
        itemBuilder: (context, index) {
          // 🛡️ Safe array access
          if (index >= currentColorImages.length) return const SizedBox();
          return _buildThumbnailItem(currentColorImages[index], index);
        },
        separatorBuilder: (context, index) =>
            index == currentColorImages.length - 1
                ? const SizedBox.shrink()
                : const SizedBox(width: 2),
      ),
    );
  }

  /// 🖼️ Thumbnail Item Builder - FIXED: استجابة صحيحة للمس
  Widget _buildThumbnailItem(listing.Thumbnail image, int index) {
    return InkWell(
      onTap: () {
        // 🔥 إصلاح: الذهاب للصورة الصحيحة بدلاً من 0 دائماً
        _imageController.animateTo(index, true);
        setState(() {
          _sliderState = _sliderState.copyWith(currentImageIndex: index);
        });
      },
      child: Container(
        width: 30,
        height: 40,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              offset: const Offset(0, 3),
              inset: true,
              blurRadius: 6,
            )
          ],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              width: index == _sliderState.currentImageIndex ? 2.0 : 0.5,
              color: index == _sliderState.currentImageIndex
                  ? Colors.blue
                  : Colors.grey.shade400),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              MyCachedNetworkImage(
                imageSource: widget.imageSource,
                imageUrl: image.filePath!,
                height: 40,
                width: 30,
                logoTextHeight: 15,
                logoTextWidth: 20,
                circleDimensions: 7,
                imageFit: BoxFit.cover,
              ),
              Container(
                height: 40,
                width: 30,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      offset: const Offset(0, 3),
                      inset: true,
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🖼️ Optimized Image Gallery - FIXED: تفاعل محسن
  Widget _buildImageGallery() {
    final productImages = widget.productItem.images ?? [];
    if (productImages.isEmpty) return const SizedBox();

    return MyGallery3DWidget(
      key: UniqueKey(),
      gallery3dController: _imageController,
      gallery3dControllerForCircles: _imageController,
      stopScrollingOnEdges: (primaryDelta) =>
          false, // تحسين: السماح بالتمرير دائماً
      itemWidth: 170.w,
      threeImages: _buildThreeImagesList(productImages),
      onItemClick: (index) {
        // تحسين: التعامل مع النقر بشكل صحيح
        setState(() {
          _sliderState = _sliderState.copyWith(currentImageIndex: index);
        });
        widget.setThisEnabled(-1, -1);
      },
      galleryHeight: 240,
      itemHeight: 240,
      onItemChanged: _handleImageChanged,
      galleryWidth: 200,
      radius: 15,
      itemCount: productImages.length,
    );
  }

  /// 🎨 Optimized Color Gallery - FIXED: منع الحركة التلقائية + عرض جميع الألوان
  Widget _buildColorGallery() {
    if (_processedColorImages?.isEmpty ?? true) return const SizedBox();

    final colorCount = _processedColorImages!.length;

    return Transform.translate(
      offset: const Offset(-5, 0),
      child: Center(
        child: MyGallery3DWidget(
          gallery3dController: _colorController,
          gallery3dControllerForCircles: _colorController,
          stopScrollingOnEdges: (primaryDelta) => false,
          itemWidth: widget.fromHomePage ? 150.w : 170.w,
          itemHeight: widget.fromHomePage ? 200 : 240,
          threeImages: _buildThreeColorsList(),
          onItemClick: (index) {
            // تحسين: التعامل مع النقر بشكل صحيح
            final safeIndex = index.clamp(0, (colorCount - 1));
            setState(() {
              _sliderState =
                  _sliderState.copyWith(currentColorIndex: safeIndex);
            });
            _debounceNotifyColorChange();
            widget.setThisEnabled(-1, -1);
          },
          galleryHeight: widget.fromHomePage ? 200 : 240,
          onItemChanged: _handleColorChanged,
          galleryWidth: widget.fromHomePage ? 170 : 200,
          radius: 15,
          itemCount: colorCount, // 🔥 استخدام العدد الفعلي للألوان
        ),
      ),
    );
  }

  /// 🏷️ Color Name Display
  Widget _buildColorNameDisplay() {
    if (_processedColorImages?.isEmpty ?? true) return const SizedBox();

    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 50)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _debounceNotifyColorChange();
        }

        // 🛡️ Safe index access with bounds checking
        final safeColorIndex = _sliderState.currentColorIndex
            .clamp(0, (_processedColorImages?.length ?? 1) - 1);
        final colorName = _processedColorImages!.length > safeColorIndex
            ? (_processedColorImages![safeColorIndex].colorName ?? '')
            : '';

        final colorHex = widget.productItem.colors?.isNotEmpty == true
            ? widget
                .productItem
                .colors![safeColorIndex % widget.productItem.colors!.length]
                .color
            : null;

        return MyTextWidget(
          colorName,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.mq.copyWith(
            color: colorHex != null
                ? Color(int.parse('0xff${colorHex.substring(1)}'))
                : Colors.black,
          ),
        );
      },
    );
  }

  /// 🖼️ Default Image View (Carousel)
  Widget _buildDefaultImageView() {
    // 🛡️ Safe index access with bounds checking
    final safeColorIndex = _sliderState.currentColorIndex
        .clamp(0, (_processedColorImages?.length ?? 1) - 1);
    final currentColorImages = _processedColorImages?.isNotEmpty == true
        ? (_processedColorImages!.length > safeColorIndex
            ? _processedColorImages![safeColorIndex].images
            : widget.productItem.images)
        : widget.productItem.images;

    if (currentColorImages?.isEmpty ?? true) return const SizedBox();

    return SizedBox(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main carousel
          SizedBox(
            height: widget.fromHomePage ? 220 : 290,
            width: widget.fromHomePage ? 170 : 200,
            child: CarouselSlider.builder(
              key: UniqueKey(),
              itemCount: widget.fromHomePage ? 1 : currentColorImages!.length,
              carouselController: _carouselController,
              options: CarouselOptions(
                initialPage: _sliderState.currentImageIndex,
                height: 290,
                onPageChanged: _handleCarouselPageChanged,
                enableInfiniteScroll: false,
                viewportFraction: 1,
              ),
              itemBuilder: (context, index, _) {
                // 🛡️ Safe array access
                if (index >= (currentColorImages?.length ?? 0)) {
                  return const SizedBox();
                }
                return _buildCarouselItem(currentColorImages![index]);
              },
            ),
          ),

          // Image indicators
          if (currentColorImages!.length > 1)
            Positioned(
              top: 0,
              child: _buildImageIndicators(currentColorImages.length),
            ),

          // Interaction overlay
          Positioned(
            top: 0,
            child: _buildImageModeButton(),
          ),
        ],
      ),
    );
  }

  /// 🎠 Carousel Item Builder
  Widget _buildCarouselItem(listing.Thumbnail image) {
    return ProductListingImageWidget(
      orginalHeight: double.tryParse(image.originalHeight ?? '290') ?? 290,
      orginalWidth: double.tryParse(image.originalWidth ?? '200') ?? 200,
      width: 200,
      imageUrl: image.filePath!,
      height: 290,
      circleShape: false,
      innerShadowYOffset: 3,
    );
  }

  /// 🔘 Optimized Image Indicators
  Widget _buildImageIndicators(int itemCount) {
    return InkWell(
      onTap: () => widget.setThisEnabled(widget.itemIndex, 2),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: List.generate(itemCount, (index) {
            final isActive = index == _sliderState.currentImageIndex;
            final indicatorSize = _calculateIndicatorSize(index, itemCount);

            return Container(
              margin: EdgeInsets.only(
                right: index != (itemCount - 1) ? 2 : 0,
              ),
              width: indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(180),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Color(0xfff53c3c), Color(0xffff9696)],
                        stops: [0, 1],
                      )
                    : null,
                border: Border.all(
                  width: 0.3,
                  color: const Color(0xff3c3c3c),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 📐 Calculate Indicator Size
  double _calculateIndicatorSize(int index, int itemCount) {
    if (index <= (itemCount ~/ 2)) {
      return (index * 2 + 2).toDouble();
    } else {
      return ((index - ((index - (itemCount ~/ 2)) * 2)) * 2 + 2)
          .abs()
          .toDouble();
    }
  }

  /// 🎯 Image Mode Button
  Widget _buildImageModeButton() {
    return InkWell(
      onTap: () => widget.setThisEnabled(widget.itemIndex, 2),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        child: const Icon(
          Icons.photo_library_outlined,
          size: 16,
          color: Colors.white54,
        ),
      ),
    );
  }

  /// ⭕ Optimized Color Circles - FIXED: منع الحركة التلقائية
  Widget _buildColorCircles() {
    if (_processedColorImages?.isEmpty ?? true) return const SizedBox();

    final colorCount = _processedColorImages!.length;

    return Gallery3D(
      controller: _colorController,
      width: 200.w,
      stopScrollingOnEdges: (primaryDelta) => false,
      changingPagesScrollOffset: 0.2, // 🔥 تقليل الحساسية لمنع الحركة العفوية
      isClip: false,
      onItemChanged: _handleColorCircleChanged,
      itemConfig: const GalleryItemConfig(
        width: 40,
        height: 40,
        radius: 360,
        isShowTransformMask: false,
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      onClickItem: _handleColorCircleClick,
      itemBuilder: (context, index) =>
          _buildColorCircle(index, _shouldShowColorCircle(index)),
    );
  }

  /// ⭕ Color Circle Item Builder - FIXED: عرض صور صحيحة لجميع الحالات
  Widget _buildColorCircle(int index, bool isVisible) {
    return Visibility(
      visible: isVisible,
      child: ProductListingImageWidget(
        orginalHeight: _getColorImageHeight(index),
        orginalWidth: _getColorImageWidth(index),
        width: 40,
        height: 40,
        imageUrl: _getColorImageUrl(index),
        innerShadowYOffset: 4,
        borderColor: _getBorderColorForCircle(index),
        circleShape: true,
      ),
    );
  }

  /// 🎨 Helper: الحصول على رابط الصورة للدائرة مع التعامل مع جميع الحالات
  String _getColorImageUrl(int index) {
    // الحالة 1: إذا كان هناك cached images متاحة
    if (_cachedImages?.isNotEmpty == true && index < _cachedImages!.length) {
      return _cachedImages![index];
    }

    // الحالة 2: إذا كان هناك معلومات ألوان
    if (_processedColorImages?.isNotEmpty == true) {
      final safeIndex = index.clamp(0, _processedColorImages!.length - 1);
      final colorImages = _processedColorImages![safeIndex].images;
      if (colorImages?.isNotEmpty == true) {
        return colorImages!.first.filePath ?? '';
      }
    }

    // الحالة 3: استخدام أول صورة من images كبديل
    if (widget.productItem.images?.isNotEmpty == true) {
      return widget.productItem.images!.first.filePath ?? '';
    }

    return ''; // إرجاع فارغ كخيار أخير
  }

  /// 📐 Helper: الحصول على ارتفاع الصورة للدائرة
  double _getColorImageHeight(int index) {
    if (_cachedOriginalHeights?.isNotEmpty == true &&
        index < _cachedOriginalHeights!.length) {
      return _cachedOriginalHeights![index];
    }

    // بديل من معلومات المنتج
    if (widget.productItem.images?.isNotEmpty == true) {
      final firstImage = widget.productItem.images!.first;
      return double.tryParse(firstImage.originalHeight ?? '40') ?? 40.0;
    }

    return 40.0; // قيمة افتراضية
  }

  /// 📐 Helper: الحصول على عرض الصورة للدائرة
  double _getColorImageWidth(int index) {
    if (_cachedOriginalWidths?.isNotEmpty == true &&
        index < _cachedOriginalWidths!.length) {
      return _cachedOriginalWidths![index];
    }

    // بديل من معلومات المنتج
    if (widget.productItem.images?.isNotEmpty == true) {
      final firstImage = widget.productItem.images!.first;
      return double.tryParse(firstImage.originalWidth ?? '40') ?? 40.0;
    }

    return 40.0; // قيمة افتراضية
  }

  /// 🏷️ Brand Icon
  Widget _buildBrandIcon() {
    final brandIcon = widget.productItem.brand?.icon?.filePath;
    if (brandIcon == null) return const SizedBox.shrink();

    return SvgNetworkWidget(
      svgUrl: brandIcon,
      width: 30.w,
      height: 15,
    );
  }

  /// 📝 Product Name Row
  Widget _buildProductNameRow() {
    return Row(
      mainAxisAlignment: LanguageService.languageCode == "ar"
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        const SizedBox(width: 2),
        // Category Icon
        _buildCategoryIcon(),
        const SizedBox(width: 3),
        // Product Name
        Flexible(
          child: MyTextWidget(
            widget.productItem.name.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.rq.copyWith(
              color: const Color(0xff3c3c3c),
            ),
          ),
        ),
      ],
    );
  }

  /// 🏷️ Category Icon
  Widget _buildCategoryIcon() {
    final categoryIcon = widget.productItem.category?.flatPhotoPath?.filePath;
    if (categoryIcon == null) return const SizedBox.shrink();

    return SizedBox(
      height: 10,
      child: Transform.translate(
        offset: const Offset(0, 1),
        child: SvgNetworkWidget(
          svgUrl: categoryIcon,
          height: 10,
        ),
      ),
    );
  }

  /// 💰 Optimized Price Section - FIXED: تقليل المساحة
  Widget _buildPriceSection() {
    return SizedBox(
      width: 200, // تقليل العرض
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15), // تقليل padding
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.getCurrencyForCountryModel !=
              current.getCurrencyForCountryModel,
          builder: (context, state) {
            final price = widget.productItem.price ?? 0;
            final offerPrice = widget.productItem.offerPrice ?? 0;
            final exchangeRate = state
                    .getCurrencyForCountryModel?.data?.currency?.exchangeRate ??
                1;
            final currencySymbol =
                state.getCurrencyForCountryModel?.data?.currency?.symbol ?? '';

            return Directionality(
              textDirection: LanguageService.languageCode == "ar"
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع أفضل
                children: [
                  // Price Row
                  Flexible(
                    // منع overflow بـ Flexible
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyTextWidget(
                          HelperFunctions.formatNumber(
                              number: price * exchangeRate),
                          style: textTheme.titleSmall?.lq.copyWith(
                            // تقليل حجم الخط
                            color: const Color(0xff3c3c3c),
                            decoration: TextDecoration.lineThrough,
                            height: 1.0, // تقليل الارتفاع
                          ),
                        ),
                        const SizedBox(width: 2),
                        MyTextWidget(
                          HelperFunctions.formatNumber(
                              number: offerPrice * exchangeRate),
                          style: textTheme.titleSmall?.bq.copyWith(
                            // تقليل حجم الخط
                            color: const Color(0xff3c3c3c),
                            height: 1.0, // تقليل الارتفاع
                          ),
                        ),
                        const SizedBox(width: 2),
                        MyTextWidget(
                          currencySymbol,
                          style: const TextStyle(fontSize: 8), // تقليل حجم الخط
                        ),
                      ],
                    ),
                  ),
                  // Buy Button
                  _buildCompactBuyButton(), // زر مضغوط
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🛒 Compact Buy Button - FIXED: زر مضغوط لتوفير المساحة
  Widget _buildCompactBuyButton() {
    return InkWell(
      onTap: () {
        _homeBloc.add(const ChangeStatusOFGetProductsDetailsToSuccessEvent(
          isStatusInitaial: true,
        ));
        widget.productIsFlashDeal?.value = widget.fromFlashDeal ?? false;

        Future.delayed(
          const Duration(milliseconds: 600),
          () => widget.tapIndexToAddProductToCart.value = widget.itemIndex,
        );
      },
      child: Container(
        height: 25, // تقليل الارتفاع
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x1D1D1D),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTextWidget(
              '${LocaleKeys.buy.tr()}',
              style: textTheme.titleSmall?.lq.copyWith(
                color: const Color(0xff414141),
                height: 1.2, // تقليل الارتفاع
                fontSize: 12, // تقليل حجم الخط
              ),
            ),
            const SizedBox(width: 3),
            SvgPicture.asset(
              AppAssets.bagSvg,
              height: 12, // تقليل حجم الأيقونة
              width: 12,
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 Helper Methods

  /// 🛑 Should Stop Image Scrolling - FIXED: تمرير محسن
  bool _shouldStopImageScrolling(double primaryDelta) {
    final productImages = widget.productItem.images ?? [];
    if (productImages.isEmpty) return true;

    final maxIndex = productImages.length - 1;
    final currentIndex = _imageController.currentIndex.clamp(0, maxIndex);

    // 🔥 تحسين: السماح بالتمرير الدائري مع حماية الحدود
    return false; // السماح بالتمرير دائماً للحصول على تجربة أفضل
  }

  /// 🛑 Should Stop Color Scrolling - FIXED: تمرير محسن للألوان
  bool _shouldStopColorScrolling(double primaryDelta) {
    if (_processedColorImages?.isEmpty ?? true) return true;

    final colorCount = _processedColorImages!.length;
    if (colorCount <= 3) return false; // السماح بالتمرير للقوائم القصيرة

    final currentIndex = _colorController.currentIndex.clamp(0, colorCount - 1);

    // 🚀 تحسين: تقليل القيود لتحسين التجربة
    return (primaryDelta <= 0 && currentIndex >= colorCount - 2) ||
        (primaryDelta >= 0 && currentIndex <= 1);
  }

  /// 👁️ Should Show Color Circle - FIXED: إظهار جميع الدوائر المتاحة
  bool _shouldShowColorCircle(int index) {
    if (_processedColorImages?.isEmpty ?? true) return false;

    final colorCount = _processedColorImages!.length;

    // 🔥 إظهار جميع الدوائر المتاحة دائماً (لا توجد قيود)
    return index < colorCount;
  }

  /// 🎨 Get Border Color for Circle
  Color _getBorderColorForCircle(int index) {
    if (widget.productItem.colors?.isEmpty ?? true) return Colors.white;

    if (index == _sliderState.currentColorIndex) {
      // 🛡️ Safe index access with bounds checking
      final safeIndex = index % (widget.productItem.colors?.length ?? 1);
      if (safeIndex < (widget.productItem.colors?.length ?? 0)) {
        final colorHex = widget.productItem.colors![safeIndex].color;
        if (colorHex != null && colorHex.isNotEmpty && colorHex.length > 1) {
          return Color(int.parse('0xff${colorHex.substring(1)}'));
        }
      }
    }
    return Colors.white;
  }

  /// 📋 Build Three Images List
  List<String> _buildThreeImagesList(List<listing.Thumbnail> images) {
    if (images.length < 3) return images.map((e) => e.filePath!).toList();

    final List<String> imageUrls = images.map((e) => e.filePath!).toList();
    final duplicated = [...imageUrls, ...imageUrls];

    if (duplicated.length == 2) {
      duplicated.add(duplicated[0]);
    }

    // 🛡️ Safe list manipulation to prevent RangeError
    List<String> threeImages = [];
    if (duplicated.isNotEmpty) {
      threeImages.add(duplicated.removeAt(0));
    }
    if (duplicated.isNotEmpty) {
      threeImages.add(duplicated.removeAt(0));
    }
    if (duplicated.isNotEmpty) {
      threeImages.add(duplicated.removeLast());
    }

    return threeImages;
  }

  /// 🎨 Build Three Colors List - FIXED: معالجة شاملة لجميع الحالات
  List<String> _buildThreeColorsList() {
    if (_cachedImages?.isEmpty ?? true) {
      // إذا لم تكن هناك صور ألوان، استخدم صور المنتج العادية
      if (widget.productItem.images?.isNotEmpty == true) {
        final productImages =
            widget.productItem.images!.map((e) => e.filePath!).toList();

        if (productImages.length == 1) {
          return [productImages[0], productImages[0], productImages[0]];
        } else if (productImages.length == 2) {
          return [productImages[0], productImages[1], productImages[0]];
        } else {
          return productImages.take(3).toList();
        }
      }
      return [];
    }

    final images = _cachedImages!;

    // 🔥 الحالة 1: لون واحد فقط
    if (images.length == 1) {
      return [images[0], images[0], images[0]]; // تكرار نفس اللون 3 مرات
    }

    // 🔥 الحالة 2: لونان فقط
    if (images.length == 2) {
      return [images[0], images[1], images[0]]; // تناوب بين اللونين
    }

    // 🔥 الحالة 3: ثلاثة ألوان بالضبط
    if (images.length == 3) {
      return images; // إرجاع الثلاثة كما هم
    }

    // 🔥 الحالة 4: أكثر من 3 ألوان - اختيار 3 متتالية من البداية
    return images.take(3).toList();
  }

  // 🎭 Event Handlers

  /// 🖼️ Handle Image Changed
  void _handleImageChanged(int index) {
    // Update current image index logic
    widget.currentChosenColor.value = index;

    setState(() {
      _sliderState = _sliderState.copyWith(currentImageIndex: index);
    });
  }

  /// 🎨 Handle Color Changed
  void _handleColorChanged(int index) {
    // 🛡️ Ensure index is within valid bounds to prevent RangeError
    if (_processedColorImages?.isEmpty ?? true) return;

    final safeIndex = index.clamp(0, (_processedColorImages!.length - 1));

    setState(() {
      _sliderState = _sliderState.copyWith(currentColorIndex: safeIndex);
    });

    _debounceNotifyColorChange();
  }

  /// 🎠 Handle Carousel Page Changed
  void _handleCarouselPageChanged(int page, CarouselPageChangedReason reason) {
    // 🛡️ Safe page index handling
    final currentColorImages = _processedColorImages?.isNotEmpty == true
        ? _processedColorImages![_sliderState.currentColorIndex
                .clamp(0, (_processedColorImages?.length ?? 1) - 1)]
            .images
        : widget.productItem.images;

    final maxPages = (currentColorImages?.length ?? 1) - 1;
    final safePage = page.clamp(0, maxPages);

    setState(() {
      _sliderState = _sliderState.copyWith(currentImageIndex: safePage);
    });

    if (widget.slidingModeItem.item1 != -1) {
      widget.setThisEnabled(-1, -1);
    }
  }

  /// ⭕ Handle Color Circle Changed - FIXED: منع الحركة التلقائية
  void _handleColorCircleChanged(int index) {
    // 🛡️ Bounds checking for element 23 and other indices
    if (_processedColorImages?.isEmpty ?? true) return;

    // 🔥 منع التحديث التلقائي - فقط عند التفاعل اليدوي
    final safeIndex = index.clamp(0, (_processedColorImages!.length - 1));
    widget.currentChosenColor.value = safeIndex;

    setState(() {
      _sliderState = _sliderState.copyWith(currentColorIndex: safeIndex);
    });

    _debounceNotifyColorChange();
  }

  /// 🖱️ Handle Color Circle Click
  void _handleColorCircleClick(int index) {
    // 🛡️ Safe index handling for clicks
    if (_processedColorImages?.isEmpty ?? true) return;

    final safeIndex = index.clamp(0, (_processedColorImages!.length - 1));
    if (safeIndex == _sliderState.currentColorIndex) return;

    // Navigate to specific color with animation
    _colorController.animateTo(safeIndex, false);

    setState(() {
      _sliderState = _sliderState.copyWith(currentColorIndex: safeIndex);
    });

    _debounceNotifyColorChange();
  }

  @override
  void dispose() {
    // 🧹 Comprehensive Cleanup
    _debounceTimer?.cancel();
    _animationController.dispose();

    // 🔥 FIXED: Gallery3DController doesn't need explicit disposal
    // Let Dart's garbage collector handle controllers automatically

    super.dispose();
  }
}

/// 🎯 Optimized Slider State Class
class SliderStateOptimized {
  final int currentColorIndex;
  final int currentImageIndex;
  final int totalColors;
  final int totalImages;

  const SliderStateOptimized({
    required this.currentColorIndex,
    required this.currentImageIndex,
    required this.totalColors,
    required this.totalImages,
  });

  SliderStateOptimized copyWith({
    int? currentColorIndex,
    int? currentImageIndex,
    int? totalColors,
    int? totalImages,
  }) {
    return SliderStateOptimized(
      currentColorIndex: currentColorIndex ?? this.currentColorIndex,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      totalColors: totalColors ?? this.totalColors,
      totalImages: totalImages ?? this.totalImages,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SliderStateOptimized &&
        other.currentColorIndex == currentColorIndex &&
        other.currentImageIndex == currentImageIndex &&
        other.totalColors == totalColors &&
        other.totalImages == totalImages;
  }

  @override
  int get hashCode {
    return currentColorIndex.hashCode ^
        currentImageIndex.hashCode ^
        totalColors.hashCode ^
        totalImages.hashCode;
  }
}
