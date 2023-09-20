
import 'package:flutter/material.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../common/constant/design/assets_provider.dart';

class StoryItemWidget extends StatelessWidget {
  const StoryItemWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Stack(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image:  AssetImage(AppAssets.storyImageJpg),
                      fit: BoxFit.fill,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x805d5d5d),
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.0, -1.0),
                      end: Alignment(0.0, 2.026),
                      colors: [const Color(0x00000000), const Color(0xff000000)],
                      stops: [0.0, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                Text('Jack Lobe' , style: context.textTheme.caption?.rr.copyWith(
                  letterSpacing: 0.036,
                  height: 3,
                  color: context.colorScheme.white
                ),)
              ],
            ),
            Transform.translate(
              offset: Offset(-10,-10),
              child: Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:  AssetImage(AppAssets.storyImageMinJpg),
                      fit: BoxFit.contain,
                    ),
                    borderRadius: BorderRadius.circular(180),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x4dffffff),
                        offset: Offset(0, 0),
                        blurRadius: 6,
                      ),
                    ],
                    border: Border.all(color: const Color(0xffffab62),width: 1),
                  ),
                  margin: EdgeInsets.all(1.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
