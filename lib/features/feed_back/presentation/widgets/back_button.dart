
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../service/language_service.dart';

class DefaultBackButton extends StatelessWidget {
  const DefaultBackButton({
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: HelperFunctions.changeSvgColor(AppAssets.backButtonSvg,"EB6713"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              height: 35.h,
              width: 35.h,
              child: LanguageService.languageCode == 'en'
                  ? Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.rotationY(math.pi),
                child: SvgPicture.string(
                  snapshot.data!,
                  fit: BoxFit.contain,
                ),
              )
                  : SvgPicture.string(
                snapshot.data!,
                fit: BoxFit.contain,
              ),
            ),
          );
        });
  }
}