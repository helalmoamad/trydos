
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/widgets/product_stories_section/product_story_video_item.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/my_text_widget.dart';

class ProductStoriesCard extends StatelessWidget {
  const ProductStoriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30.0 ,),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.storyFilmSvg,
                    height: 20,
                    width: 20,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  MyTextWidget(
                    'Product Story',
                    style: context.textTheme.bodyText2?.rq
                        .copyWith(color: Color(0xff8D8D8D)),
                  ),
                  SvgPicture.asset(
                    AppAssets.registerInfoSvg,
                    height: 12,
                    width: 12,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Stack(
              alignment: LanguageService.rtl ? Alignment.centerRight : Alignment.centerLeft,
              children: [
                SizedBox(
                  height: 194,
                  child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(left: 30.0 ,),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return ProductStoryVideoItem(videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',);
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          width: 5,
                        );
                      },
                      itemCount: 5),
                ),
                Container(width: 20,height: 194,)
              ],
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
