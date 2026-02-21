import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';

class SearchChip extends StatelessWidget {
  const SearchChip({super.key, required this.title, this.justLogo = false});

  final String title;
  final bool justLogo;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xffC4C2C2), width: 0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyTextWidget(
                  title,
                  style: context.textTheme.titleMedium?.rq.copyWith(
                      color: const Color(0xff505050), height: 15 / 12),
                ),
                SvgPicture.asset(
                  AppAssets.backArrowArabic,
                  // ignore: deprecated_member_use
                  color: const Color(0xffC4C2C2),
                  width: 10,
                  height: 10,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 30,
            child: ScrollConfiguration(
              behavior: const CupertinoScrollBehavior(),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xffF8F8F8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          child: Center(
                            child: justLogo
                                ? SvgPicture.asset(
                                    AppAssets.mangoSvg,
                                    height: 10,
                                  )
                                : Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.qualityBadgeSvg,
                                        width: 15,
                                        height: 15,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      MyTextWidget(
                                        'T-Shirt',
                                        style: context.textTheme.titleLarge?.rq
                                            .copyWith(
                                                height: 18 / 14,
                                                color: const Color(0xff8D8D8D)),
                                      )
                                    ],
                                  ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 10,
                        );
                      },
                      itemCount: 8),
                  // Container(
                  //   height: 28,
                  //   width: 15,
                  //   decoration: BoxDecoration(
                  //     gradient:  LinearGradient(
                  //       begin: const Alignment(-1.0, 0),
                  //       end: const Alignment(0.0, 0.0),
                  //       colors: [
                  //         const Color(0xa0ffffff),
                  //         const Color(0xccffffff),
                  //         const Color(0xe0ffffff),
                  //         const Color(0xffffffff),
                  //       ],
                  //       stops:  [0.0, 0.33 , 0.66, 1.0],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
