import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart'
as inset_shadow;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_state.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';

class MyCachedNetworkImage extends StatelessWidget {
  MyCachedNetworkImage({Key? key,
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
    this.circleDimensions})
      : super(key: key) {
    currentUrl = imageUrl;
  }

  final ValueNotifier<int> rebuildImage = ValueNotifier(0);

  String currentUrl = '';
  bool enable = true;
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
  final ImageWidgetBuilder? imageBuilder;
  final double? circleDimensions;
  final Color? imageColor;
  final void Function()? callWhenDisplayImage;
  final void Function()? callWhenLoadingImage;

  final Widget? progressIndicatorBuilderWidget;

  @override
  Widget build(BuildContext context) {
    String url = addSuitableWidthAndHeightToImage(
        imageUrl: currentUrl,
        ordinalWidth: ordinalwidth,
        ordinalHeight: ordinalHeight,
        height: (imageHeight ?? height),
        width: (imageWidth ?? width));

    return ValueListenableBuilder<int>(
        valueListenable: rebuildImage,
        builder: (context, count, _) {
          return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: withImageShadow
                    ? [
                  BoxShadow(
                    color: context.colorScheme.black.withOpacity(0.16),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ]
                    : null,
              ),
              child: BlocBuilder<PreCachingImageBloc, PreCachingImageState>(
                buildWhen: (p,c)=> p.cachedImages[url] == false && c.cachedImages[url] == true,
                builder: (context, state) {
                  if(state.cachedImages[url] == false){
                    return progressIndicatorBuilderWidget ??
                        TrydosShimmerLoading(
                          width: width,
                          height: height,
                          logoTextHeight: logoTextHeight ?? 14,
                          logoTextWidth: logoTextWidth ?? 48.w,
                          circleDimensions: circleDimensions,
                        );
                  }
                  return CachedNetworkImage(
                      imageUrl: url,
                      key: ValueKey(url),
                      fit: imageFit,
                      width: width,
                      color: imageColor,
                      height: height,
                      fadeInDuration: Duration(milliseconds: 0),
                      fadeOutDuration: Duration(milliseconds: 0),
                      //cacheKey: CustomCacheManager.key,
                      cacheManager: CustomCacheManager(),

                      progressIndicatorBuilder: (context, _, progress) {
                        callWhenLoadingImage?.call();
                        return progressIndicatorBuilderWidget ??
                            TrydosShimmerLoading(
                              width: width,
                              height: height,
                              logoTextHeight: logoTextHeight ?? 14,
                              logoTextWidth: logoTextWidth ?? 48.w,
                              circleDimensions: circleDimensions,
                            );
                      },
                      imageBuilder: imageBuilder ??
                              (ctx, image) {
                            callWhenDisplayImage?.call();
                            return ClipRRect(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: width,
                                          height: height,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: image,
                                              fit: imageFit,
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(radius),
                                          ),
                                        ),
                                        withInnerShadow
                                            ? Container(
                                          decoration:
                                          inset_shadow.BoxDecoration(
                                            boxShadow: [
                                              inset_shadow.BoxShadow(
                                                offset: Offset(
                                                    0, innerShadowYOffset!),
                                                blurRadius: 20,
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                inset: true,
                                              ),
                                            ],
                                          ),
                                        )
                                            : SizedBox.shrink()
                                      ],
                                    )));
                          },
                      errorWidget: (context, url, error) {
                        if (enable) {
                          enable = false;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            currentUrl = imageUrl;
                            rebuildImage.value++;
                          });
                        }
                        return Material(
                          color:  Colors.transparent,
                          child: InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () async {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                currentUrl = '';
                                enable = true;
                                rebuildImage.value++;
                              });
                            },
                            child: Center(
                              child: Icon(Icons.refresh,
                                  color: const Color(0xffff5f61),
                                  size: min(25, height)),
                            ),
                          ),
                        );
                      });
                },
              ));
        });
  }
}

class CustomCacheManager extends CacheManager {
  static const key = 'customCache';

  static CustomCacheManager? _instance;

  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._();
    return _instance!;
  }

  CustomCacheManager._()
      : super(Config(
    key,
    maxNrOfCacheObjects: 600,
    stalePeriod: const Duration(days: 30),
  ));
}

String addSuitableWidthAndHeightToImage({required String imageUrl,
  double? ordinalHeight,
  double? ordinalWidth,
  required double width,
  required double height}) {
  if(!imageUrl.contains('upload')){
    return imageUrl;
  }
  List<String> list;
  String url = '';
  list = imageUrl.split('upload');
  if (ordinalHeight != null && ordinalWidth != null) {
    url = ordinalWidth >= ordinalHeight
        ? list[0] +
        'upload/c_scale,h_${2 * height.toInt()}' +
        list[1]
        : list[0] +
        'upload/c_scale,w_${2 * width.toInt()}' +
        list[1];
  } else {
    url = list[0] +
        'upload/c_scale,h_${2 * height.toInt()}' +
        list[1];
  }
  return url;
}
