import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:tuple/tuple.dart';

class ProductListingSimpleSlider extends StatefulWidget {
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final int itemIndex;
  final bool displayImageColors;
  final bool fromHomePage;
  final String? imageSource;
  final bool? fromFlashDeal;
  final productListingModel.Products productItem;

  const ProductListingSimpleSlider({
    Key? key,
    required this.itemIndex,
    this.fromHomePage = false,
    this.imageSource,
    required this.tapIndexToAddProductToCart,
    required this.productItem,
    this.fromFlashDeal,
    required this.displayImageColors,
  }) : super(key: key);

  @override
  State<ProductListingSimpleSlider> createState() =>
      _ProductListingSimpleSliderState();
}

class _ProductListingSimpleSliderState
    extends State<ProductListingSimpleSlider> {
  int selectedColorIndex = 0;
  int selectedImageIndex = 0;
  int slideModeIndex = 0;

  List<String> getCurrentImages() {
    if (widget.displayImageColors &&
        (widget.productItem.syncColorImages?.isNotEmpty ?? false)) {
      final colorImages =
          widget.productItem.syncColorImages![selectedColorIndex].images;
      return colorImages
              ?.map((e) => e.filePath ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [];
    } else {
      return widget.productItem.images
              ?.map((e) => e.filePath ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final images = getCurrentImages();
    final hasColors = widget.displayImageColors &&
        (widget.productItem.syncColorImages?.isNotEmpty ?? false);
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasColors)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    slideModeIndex = 0;
                  });
                },
                child: Text('صور',
                    style: TextStyle(
                        color:
                            slideModeIndex == 0 ? Colors.blue : Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    slideModeIndex = 1;
                  });
                },
                child: Text('ألوان',
                    style: TextStyle(
                        color:
                            slideModeIndex == 1 ? Colors.blue : Colors.grey)),
              ),
            ],
          ),
        // شريط الصور
        if (slideModeIndex == 0 || !hasColors)
          Column(
            children: [
              SizedBox(
                height: 170,
                child: PageView.builder(
                  itemCount: images.length,
                  controller: PageController(initialPage: selectedImageIndex),
                  onPageChanged: (index) {
                    setState(() => selectedImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        homeBloc.add(
                            ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                isStatusInitaial: true));
                        widget.tapIndexToAddProductToCart.value =
                            widget.itemIndex;
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: selectedImageIndex == index
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40),
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // مؤشرات دائرية أسفل الصور
              if (images.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 4),
                      width: selectedImageIndex == index ? 12 : 8,
                      height: selectedImageIndex == index ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedImageIndex == index
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                    );
                  }),
                ),
            ],
          ),
        // شريط الألوان
        if (hasColors && slideModeIndex == 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.productItem.syncColorImages!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, colorIndex) {
                  final color = widget.productItem.colors != null &&
                          widget.productItem.colors!.length > colorIndex
                      ? widget.productItem.colors![colorIndex].color
                      : null;
                  Color displayColor = Colors.grey;
                  if (color != null &&
                      color.length == 7 &&
                      color.startsWith('#')) {
                    displayColor =
                        Color(int.parse('0xff${color.substring(1)}'));
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColorIndex = colorIndex;
                        selectedImageIndex = 0;
                      });
                      homeBloc.add(AddCurrentSelectedColorEvent(
                          currentSelectedColor: colorIndex,
                          productSlug: widget.productItem.slug.toString()));
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: displayColor,
                        border: Border.all(
                          color: selectedColorIndex == colorIndex
                              ? Colors.blue
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: selectedColorIndex == colorIndex
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
