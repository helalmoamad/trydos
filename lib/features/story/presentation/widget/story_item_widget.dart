import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';

import '../../../../common/constant/design/assets_provider.dart';

class StoryItemWidget extends StatelessWidget {
  StoryItemWidget(
      {required this.index,
      Key? key,
      required this.resize,
      this.firstPhotoNotShowed,
      this.videoData})
      : super(key: key);

  final bool resize;
  int index;
  Uint8List? videoData;
  final String? firstPhotoNotShowed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
      bool isLastStoryShowed = state.stories[index].stories!.length ==
          firstWhereNotShowed(state.stories[index].stories!) + 1;

      return SizedBox(
        height: resize ? 190 : 150,
        width: resize ? 150 : 110,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
               Container(
                 clipBehavior: Clip.hardEdge,
                  height: resize ? 190 : 150,
                  width: resize ? 140 : 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
//                  image: DecorationImage(
//                    image:  AssetImage(AppAssets.storyImageJpg),
//                  ),
//                    boxShadow: [
//                      BoxShadow(
//                        color: const Color(0x805d5d5d),
//                        offset: Offset(0, 3),
//                        blurRadius: 6,
//                      ),
//                    ],
                  ),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: firstPhotoNotShowed!,
                  ),
                ),


                Positioned(
                  left: 0,
                  top: 0,
                  child: Transform.translate(
                    offset: resize ? Offset(-10, -5) : Offset(-10, -10),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      child:state.stories[index].photoPath==null?Image.asset('assets/images/default_story_avatar.png',fit: BoxFit.cover,)
                      :CachedNetworkImage(   imageUrl:state.stories[index].photoPath,fit: BoxFit.cover,)
                    ,
                      height: resize ? 50 : 30,
                      width: resize ? 50 : 30,
                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(180),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x4dffffff),
                            offset: Offset(0, 0),
                            blurRadius: 6,
                          ),
                        ],
                        border: Border.all(
                            color: isLastStoryShowed
                                ? Colors.white
                                : const Color(0xffffab62),
                            width: 1.5),
                      ),
                      margin: EdgeInsets.all(1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
