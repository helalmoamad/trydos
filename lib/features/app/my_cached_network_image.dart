import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart'
    as inset_shadow;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';

class MyCachedNetworkImage extends StatefulWidget {
  const MyCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    this.logoTextWidth,
    this.ordinalHeight,
    this.ordinalwidth,
    this.logoTextHeight,
    this.imageWidth,
    this.imageHeight,
    required this.imageFit,
    this.imageBuilder,
    this.imageColor,
    this.progressIndicatorBuilderWidget,
    this.callWhenDisplayImage,
    this.callWhenLoadingImage,
    this.radius = 12,
    this.innerShadowYOffset,
    this.withImageShadow = false,
    this.withInnerShadow = false,
    required this.height,
    this.fromStory,
    this.circleDimensions,
  }) : super(key: key);

  final String imageUrl;
  final double width;
  final double? logoTextWidth;
  final double? imageWidth;
  final double? imageHeight;
  final double height;
  final double? ordinalHeight;
  final double? ordinalwidth;
  final double? logoTextHeight;
  final BoxFit imageFit;
  final double radius;
  final double? innerShadowYOffset;
  final bool withImageShadow;
  final bool withInnerShadow;
  final bool? fromStory;
  final ImageWidgetBuilder? imageBuilder;
  final double? circleDimensions;
  final Color? imageColor;
  final void Function()? callWhenDisplayImage;
  final void Function()? callWhenLoadingImage;
  final Widget? progressIndicatorBuilderWidget;

  @override
  State<MyCachedNetworkImage> createState() => _MyCachedNetworkImageState();
}

class _MyCachedNetworkImageState extends State<MyCachedNetworkImage>
    with AutomaticKeepAliveClientMixin {
  late String currentUrl;
  bool enable = true;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    currentUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(covariant MyCachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        currentUrl = widget.imageUrl;
        enable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int pixelRatio = MediaQuery.of(context).devicePixelRatio.round();
    super.build(context);
    String url = addSuitableWidthAndHeightToImage(
      imageUrl: currentUrl,
      ordinalWidth: widget.ordinalwidth,
      ordinalHeight: widget.ordinalHeight,
      height: (widget.imageHeight ?? widget.height),
      width: (widget.imageWidth ?? widget.width),
    );

    return Container(
      key: ValueKey(url),
      alignment: Alignment.center,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.withImageShadow
            ? [
                BoxShadow(
                  color: context.colorScheme.white.withOpacity(0.1),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: widget.imageFit,
          width: widget.width,
          color: widget.imageColor,
          useOldImageOnUrlChange: true,
          height: widget.height,
          memCacheHeight: widget.height.round() * pixelRatio,
          memCacheWidth: widget.width.round() * pixelRatio,
          fadeInDuration: Duration(milliseconds: 0),
          fadeOutDuration: Duration(milliseconds: 0),
          progressIndicatorBuilder: (context, _, progress) {
            widget.callWhenLoadingImage?.call();

            if ((widget.progressIndicatorBuilderWidget != null)) {
              return widget.progressIndicatorBuilderWidget!;
            }
            return TrydosShimmerLoading(
              width: widget.width,
              height: widget.height,
              logoTextHeight: widget.logoTextHeight ?? 14,
              logoTextWidth: widget.logoTextWidth ?? 48.w,
              circleDimensions: widget.circleDimensions,
            );
          },
          imageBuilder: widget.imageBuilder ??
              (ctx, image) {
                Future.delayed(const Duration(milliseconds: 300),
                    () => widget.callWhenDisplayImage?.call());
                return ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: widget.width,
                          height: widget.height,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: image,
                              fit: widget.imageFit,
                            ),
                            borderRadius: BorderRadius.circular(widget.radius),
                          ),
                        ),
                        widget.withInnerShadow
                            ? Container(
                                alignment: Alignment.center,
                                decoration: inset_shadow.BoxDecoration(
                                  boxShadow: [
                                    inset_shadow.BoxShadow(
                                      offset: Offset(
                                          0, widget.innerShadowYOffset ?? 0),
                                      blurRadius: 20,
                                      color: Colors.white.withOpacity(0.7),
                                      inset: true,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                );
              },
          errorWidget: (context, url, error) {
            if (enable) {
              enable = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  currentUrl = widget.imageUrl;
                });
              });
            }
            return Material(
              color: Colors.transparent,
              child: InkWell(
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () async {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      currentUrl = '';
                      enable = true;
                    });
                  });
                },
                child: Center(
                  child: Icon(Icons.refresh,
                      color: const Color(0xffff5f61),
                      size: min(25, widget.height)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// باقي الكود كما هو (CustomCacheManagers و clearCustomCashe و addSuitableWidthAndHeightToImage)
/*class CustomCacheManagers extends CacheManager {
  static const key = 'customCaches';
  static CustomCacheManagers? _instance;

  factory CustomCacheManagers() {
    return _instance ??= CustomCacheManagers._internal();
  }

  CustomCacheManagers._internal()
      : super(Config(key,
            maxNrOfCacheObjects: 300, stalePeriod: const Duration(days: 3)));
}
*/
class CustomCacheManagers extends DefaultCacheManager {
  static CustomCacheManagers? _instance;

  factory CustomCacheManagers() {
    return _instance!;
  }
}

void clearCustomCashe() async {
  await CustomCacheManagers().emptyCache();
}

String addSuitableWidthAndHeightToImage({
  required String imageUrl,
  double? ordinalHeight,
  double? ordinalWidth,
  required double width,
  required double height,
}) {
  int fHeight = 0;
  int fWidth = 0;
  if (height > 200 && width > 200) {
    fWidth = (width * 1.5).toInt();
    fHeight = (height * 1.5).toInt();
  } else {
    fWidth = (width * 2).toInt();
    fHeight = (height * 2).toInt();
  }

  if (!imageUrl.contains('upload')) {
    return imageUrl;
  }
  List<String> list;
  String url = '';
  list = imageUrl.split('upload');
  if (ordinalHeight != null &&
      ordinalWidth != null &&
      ordinalHeight != 0 &&
      ordinalWidth != 0) {
    url = ordinalWidth >= ordinalHeight
        ? list[0] + 'upload/c_scale,h_${fHeight}' + list[1]
        : list[0] + 'upload/c_scale,w_${fWidth}' + list[1];
  } else {
    url = list[0] + 'upload/f_auto,q_auto,c_scale,h_${fHeight}' + list[1];
  }
  return url;
}
