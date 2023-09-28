import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';

import '../../../../common/constant/design/assets_provider.dart';

class StoryItemWidget extends StatelessWidget {
  const StoryItemWidget({Key? key , required this.resize,required this.stories}) : super(key: key);
  final bool resize;
  final List<Story> stories;
  @override
  Widget build(BuildContext context) {
    return InkWell(child: SizedBox(
      width: resize ? 150 : 110,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                height: resize ? 208 : 150,
                width:resize ? 140 : 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
//                  image: DecorationImage(
//                    image:  AssetImage(AppAssets.storyImageJpg),
//                    fit: BoxFit.fill,
//                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x805d5d5d),
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: CachedNetworkImage(imageUrl: stories[firstWhereNotShowed(stories)].photoPath!,),
              ),
              Container(
                height: resize ? 208 : 150,
                width:resize ? 140 : 100,
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
              Positioned(
                left: 0,
                top: 0,
                child: Transform.translate(
                  offset: Offset(-10,-10),
                  child: Container(
                    height: resize ? 100 : 30,
                    width:resize ? 100 : 30,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image:  AssetImage(resize ? AppAssets.storyImageJpg :AppAssets.storyImageMinJpg),
                          fit: BoxFit.fill
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
              ),
            ],
          ),
        ),
      ),
    ),onTap:(){} ,);
  }
}
