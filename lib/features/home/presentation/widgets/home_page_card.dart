import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../service/language_service.dart';

class HomePageCard extends StatelessWidget {
  const HomePageCard({Key? key, required this.showWhite}) : super(key: key);
  final bool showWhite;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Stack(
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundJpg),
                fit: BoxFit.fill,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          Container(
            height: 6,
            width: 1.sw,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(1, 1),
                end: const Alignment(1, -3),
                colors: [
                  const Color(0x00ffffff),
                  const Color(0x00ffffff).withOpacity(0.6),
                  const Color(0x00ffffff).withOpacity(0.3)
                ],
                stops: const [0.0, 0.559, 1.0],
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.0, 0),
                end: const Alignment(0.0, 1.0),
                colors: showWhite
                    ? [
                        const Color(0x00ffffff),
                        const Color(0xcbffffff),
                        const Color(0xe5ffffff)
                      ]
                    : [const Color(0x00000000), const Color(0xb2000000)],
                stops: showWhite ? [0.0, 0.559, 1.0] : [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          Positioned(
            right: LanguageService.languageCode == 'ar' ? 0 : null,
            left: LanguageService.languageCode != 'ar' ? 0 : null,
            child: Container(
              width: 75,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: LanguageService.languageCode == 'ar'
                      ? const Alignment(-1, 0)
                      : const Alignment(1, 0),
                  end: LanguageService.languageCode == 'ar'
                      ? const Alignment(1, 0)
                      : const Alignment(-1, 0),
                  colors: showWhite
                      ? [
                          const Color(0x00ffffff),
                          const Color(0xcbffffff),
                          const Color(0xe5ffffff)
                        ]
                      : [const Color(0x00000000), const Color(0xb2000000)],
                  stops: showWhite ? [0.0, 0.559, 1.0] : [0.0, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                      LanguageService.languageCode == 'ar' ? 0 : 20.0),
                  bottomLeft: Radius.circular(
                      LanguageService.languageCode == 'ar' ? 0 : 20.0),
                  bottomRight: Radius.circular(
                      LanguageService.languageCode != 'ar' ? 0 : 20.0),
                  topRight: Radius.circular(
                      LanguageService.languageCode != 'ar' ? 0 : 20.0),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              child: Transform.translate(
                  offset: Offset(20.w, -30),
                  child: SvgPicture.asset(
                    AppAssets.textSvg,
                    color: showWhite
                        ? const Color(0xff137AC9)
                        : context.colorScheme.white,
                    width: 200.w,
                    height: 30,
                  )))
        ],
      ),
    );
  }
}
