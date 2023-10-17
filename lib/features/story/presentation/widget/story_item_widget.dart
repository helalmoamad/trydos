import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../chat/presentation/widgets/chat_widgets/no_image_widget.dart';

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
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
      bool isLastStoryShowed = state.stories[index].stories!.length ==
          (firstWhereNotShowedStoryCollection(state.stories[index].stories!));

      return SizedBox(
        height: resize ? 190 : 150,
        width: resize ? 150 : 110,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
//todo just in case you to show the behavior of last  story have been seen
// Container(width: 90,height:90,
// child: Text('${state.stories[index].stories!.length}'),
// ),
// // SizedBox(:)
// Padding(
//   padding: const EdgeInsets.all(28.0),
//   child:   Container(width: 90,height:90,
//   child: Text('${firstWhereNotShowedStoryCollection(state.stories[index].stories!)}'),
//   ),
// )

                Container(
                  clipBehavior: Clip.hardEdge,
                  height: resize ? 190 : 150,
                  width: resize ? 140 : 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Shimmer.fromColors(
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          height: 150,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.blue),
                        ),
                        baseColor: Colors.white,
                        highlightColor: Colors.grey),
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
                      child: state.stories[index].photoPath == null
                          ? Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(180),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x4dffffff),
                              offset: Offset(0, 0),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child:  NoImageWidget(
                            height: 40,
                            width: 40,
                            textStyle: context.textTheme.subtitle1?.br
                                .copyWith(
                                color: const Color(0xff6638FF),
                                letterSpacing: 0.18,
                                height: 1.33),
                            name:state.stories[index]
                                .name==null?'UK':
                            HelperFunctions.getTheFirstTwoLettersOfName(
                                state.stories[index]
                                    .name!)),
                      )
                          : CachedNetworkImage(
                        imageUrl: state.stories[index].photoPath,
                        fit: BoxFit.cover,
                      ),
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
                            width: 3),
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
