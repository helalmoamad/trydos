import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ProductListingImageWidget extends StatelessWidget {
  const ProductListingImageWidget({
    super.key,
    this.width,
    this.height,
    this.imageHeight,
    this.imageWidth,
    this.orginalHeight,
    this.orginalWidth,
    required this.innerShadowYOffset,
    this.borderColor,
    this.withBackGroundShadow = false,
    required this.circleShape,
    required this.imageUrl,
  });

  final double? imageWidth;
  final double? imageHeight;
  final double? width;
  final double? height;
  final bool circleShape;
  final double? orginalWidth;
  final double? orginalHeight;
  final bool withBackGroundShadow;
  final double innerShadowYOffset;
  final Color? borderColor;
  final String imageUrl;

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
    return Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(circleShape ? 180.0 : 15)),
          border: Border.all(
              width: (width == 20 || width == 200) ? 0.5 : 1,
              color: borderColor ?? const Color(0xffffffff)),
          boxShadow: withBackGroundShadow
              ? [
                  BoxShadow(
                    color: Color(0x19000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ]
              : null),
      child: ClipRRect(
          borderRadius:
              BorderRadius.all(Radius.circular(circleShape ? 180.0 : 15)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              imageUrl.contains('assets')
                  ? Image.asset(imageUrl,
                      width: width!, fit: BoxFit.cover, height: height!)
                  : MyCachedNetworkImage(
                      imageUrl: imageUrl,
                      width: width!,
                      ordinalwidth: orginalWidth,
                      ordinalHeight: orginalHeight,
                      imageHeight: imageHeight,
                      imageWidth: imageWidth,
                      imageFit: BoxFit.contain,
                      innerShadowYOffset: innerShadowYOffset,
                      withInnerShadow: true,
                      height: height!),
              //Image.asset(imageUrl , fit: BoxFit.cover, width: width, height: height,),
            ],
          )),
    );
  }
}
