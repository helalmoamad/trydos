import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/falsh_deal_counter.dart';
import 'package:trydos/generated/locale_keys.g.dart' show LocaleKeys;
import 'package:trydos/service/language_service.dart';

class ProductDetailsImageWidget extends StatelessWidget {
  const ProductDetailsImageWidget(
      {super.key,
      this.width,
      this.imageUrl,
      this.withBackGroundShadow = true,
      this.withInnerShadow = true,
      this.borderRadius,
      this.borderColor,
      this.imageFit,
      this.imageHeight,
      this.flashDealTime,
      this.lableNames,
      this.orginalHeight,
      this.blurRadius = 10,
      this.imageWidth,
      this.orginalWidth,
      this.height,
      this.radius});

  final double? width;
  final String? flashDealTime;
  final List<String>? lableNames;
  final double? height;
  final double? imageWidth;
  final double? imageHeight;
  final double? blurRadius;
  final double? orginalWidth;
  final double? orginalHeight;
  final double? radius;
  final String? imageUrl;
  final BoxFit? imageFit;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final bool withBackGroundShadow;

  final bool withInnerShadow;

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
    print(imageUrl);
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.1,
      maxScale: 4.0,
      child: Stack(
        children: [
          Container(
            height: (height ?? 464),
            width: (width ?? 320),
            decoration: BoxDecoration(
              borderRadius:
                  borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
              border: Border.all(
                  width: 0.5, color: borderColor ?? context.colorScheme.white),
              boxShadow: withBackGroundShadow
                  ? [
                      BoxShadow(
                        color: context.colorScheme.black.withOpacity(0.01),
                        offset: Offset(0, 0),
                        blurRadius: blurRadius ?? 10,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
                borderRadius:
                    borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
                child: (imageUrl?.contains('assets') ?? true)
                    ? Image.asset('assets/images/address2.png',
                        fit: imageFit ?? BoxFit.cover)
                    : MyCachedNetworkImage(
                        ordinalHeight: orginalHeight,
                        ordinalwidth: orginalWidth,
                        imageUrl: imageUrl!,
                        imageWidth: imageWidth,
                        imageHeight: imageHeight,
                        height: height ?? 464,
                        width: width ?? 320,
                        imageFit: BoxFit.fitWidth,
                      )),
          ),
          Container(
            height: (height ?? 464),
            width: (width ?? 320),
            decoration: BoxDecoration(
              borderRadius:
                  borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
              boxShadow: withInnerShadow
                  ? [
                      BoxShadow(
                          color: context.colorScheme.white,
                          offset: Offset(0, 3),
                          blurRadius: 6,
                          inset: true),
                    ]
                  : null,
            ),
          ),
          (flashDealTime == null || flashDealTime == "")
              ? SizedBox.shrink()
              : Positioned(
                  left: LanguageService.languageCode == "ar" ? null : 5,
                  right: LanguageService.languageCode != "ar" ? null : 0,
                  top: (flashDealTime != null) ? 10 : 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 2),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 50,
                    width: 110,
                    constraints: BoxConstraints(maxWidth: 150),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(234, 255, 65, 40),
                            Color.fromARGB(255, 255, 119, 40)
                          ]),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              LanguageService.languageCode == "ar"
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Text(
                              "${LocaleKeys.flash_deal.tr()}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                            SvgPicture.asset(
                              AppAssets.flashDealSvg,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        FlashDealCountdownTimerWidget(
                          endDateString: flashDealTime ?? "",
                        )
                      ],
                    ),
                  )),
          Positioned(
              left: LanguageService.languageCode != "ar" ? null : 5,
              right: LanguageService.languageCode == "ar" ? null : 5,
              top: (flashDealTime == null || flashDealTime == "") ? 10 : 55,
              child: Column(
                children: [
                  ...List.generate(
                      (lableNames?.length ?? 0) > 3
                          ? 3
                          : (lableNames?.length ?? 0),
                      (index) => Container(
                            margin: EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            height: 30,
                            constraints: BoxConstraints(maxWidth: 160),
                            decoration: BoxDecoration(
                              gradient: ((index % 2) == 0)
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                          Color.fromARGB(255, 255, 119, 40),
                                          Color.fromARGB(162, 255, 119, 40)
                                        ])
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                          Color.fromARGB(255, 79, 40, 255),
                                          Color.fromARGB(106, 79, 40, 255)
                                        ]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.lableSvg,
                                  height: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  lableNames?[index] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      context.textTheme.bodyMedium?.rr.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ))
                ],
              )),
        ],
      ),
    );
  }
}
