import 'dart:ffi';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../chat/presentation/widgets/chat_widgets/no_image_widget.dart';
import '../bloc/story_state.dart';
import '../pages/story_collection.dart';

class StoryItemWidget extends StatefulWidget {
  const StoryItemWidget(
      {required this.index,
      Key? key,
      required this.resize,
      required this.onTapOnStoryAction,
      required this.resizeUserImage,
      required this.onTapOnUserImage,
      this.firstPhotoNotShowed,
      this.videoData})
      : super(key: key);

  final bool resize;
  final bool resizeUserImage;
  final int index;
  final Uint8List? videoData;
  final String? firstPhotoNotShowed;
  final void Function() onTapOnUserImage;
  final void Function() onTapOnStoryAction;

  @override
  State<StoryItemWidget> createState() => _StoryItemWidgetState();
}

class _StoryItemWidgetState extends ThemeState<StoryItemWidget> {
  ValueNotifier<bool> resizeUserImageOnClick = ValueNotifier(false);
  ValueNotifier<bool> transactionOnOpenedStory = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    resizeUserImageOnClick.value = false;
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
        print(error.toString());
    };
    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
      print("${state.storiesCollections[widget.index].name}" +
          "11111111111111111111111111111111111555555555555555555555555555555555555555555555555555555");

      bool isLastStoryShowed =
          state.storiesCollections[widget.index].stories!.length ==
              (firstWhereNotShowedStoryCollection(
                  state.storiesCollections[widget.index].stories!));

      return Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () async {
            transactionOnOpenedStory.value = true;
            await Future.delayed(Duration(milliseconds: 100));
            transactionOnOpenedStory.value = false;
            await Future.delayed(Duration(milliseconds: 100));
            widget.onTapOnStoryAction.call();
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: transactionOnOpenedStory,
            builder: (context, build, child) {
              return AnimatedScale(
                scale: build ? 0.95 : 1,
                duration: Duration(milliseconds: 100),
                child: child,
              );
            },
            child: Container(
              margin: EdgeInsets.only(top: 20, bottom: 10),
              child: Hero(
                tag: widget.index,
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  final Hero toHero = toHeroContext.widget as Hero;
                  return SizeTransition(
                    sizeFactor: animation,
                    child: toHero.child,
                  );
                },
                createRectTween: HeroAnimationAsset.customTweenRect,
                child: Align(
                  child: AnimatedScale(
                    scale: widget.resize ? 1.3 : 1,
                    alignment: Alignment.centerLeft,
                    curve: Curves.fastEaseInToSlowEaseOut,
                    duration: Duration(milliseconds: 200),
                    child: Stack(
                      children: [
                        //todo just in case you to show the behavior of last  story have been seen
                        // Container(width: 90,height:90,
                        // child: MyTextWidget('${state.stories[index].stories!.length}'),
                        // ),
                        // // SizedBox(:)
                        // Padding(
                        //   padding: const EdgeInsets.all(28.0),
                        //   child:   Container(width: 90,height:90,
                        //   child: MyTextWidget('${firstWhereNotShowedStoryCollection(state.stories[index].stories!)}'),
                        //   ),
                        // )
                        MyCachedNetworkImage(
                          width: 100,
                          height: 150,
                          withImageShadow: false,
                          logoTextHeight: 14,
                          imageFit: BoxFit.cover,
                          logoTextWidth: 48.w,
                          imageBuilder: (ctx, image) {
                            return Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  height: 150,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xff000000)
                                              .withOpacity(0.2),
                                          offset: Offset(0, 3),
                                          blurRadius: 6,
                                        )
                                      ],
                                      image: DecorationImage(
                                        image: image,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                Container(
                                  height: 150,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(0.0, -1.0),
                                      end: Alignment(0.0, 2.026),
                                      colors: [
                                        const Color(0x00000000),
                                        const Color(0xff000000)
                                      ],
                                      stops: [0.0, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: MyTextWidget(
                                    state.storiesCollections[widget.index]
                                            .name ?? state.storiesCollections[widget.index]
                                .mobilePhone ??
                                        LocaleKeys.unknown_user.tr(),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: !widget.resize
                                        ? textTheme.titleMedium?.rr.copyWith(
                                            letterSpacing: 0.036,
                                            height: 3,
                                            color: Colors.white)
                                        : textTheme.displayMedium?.rr.copyWith(
                                            letterSpacing: 0.048,
                                            height: 2.25,
                                            color: Colors.white),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.onTapOnUserImage,
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      child: Transform.translate(
                                        offset: Offset(-10, -10),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            AnimatedScale(
                                              alignment: Alignment.topLeft,
                                              scale: widget.resizeUserImage
                                                  ? 2.33
                                                  : widget.resize
                                                      ? 1.4
                                                      : 1,
                                              duration:
                                                  Duration(milliseconds: 50),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: isLastStoryShowed
                                                            ? Colors.white
                                                            : const Color(
                                                                0xffffab62),
                                                        width: widget
                                                                .resizeUserImage
                                                            ? 0.4
                                                            : widget.resize
                                                                ? 0.6
                                                                : 1),
                                                    shape: BoxShape.circle),
                                                child: state
                                                            .storiesCollections[
                                                                widget.index]
                                                            .photoPath ==
                                                        null
                                                    ? NoImageWidget(
                                                        height: 28,
                                                        width: 28,
                                                        radius: 180,
                                                        textStyle: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.br
                                                            .copyWith(
                                                                color: const Color(
                                                                    0xff6638FF),
                                                                letterSpacing:
                                                                    0.18,
                                                                height: 1.33),
                                                        name: state.storiesCollections[widget.index].name ==
                                                                null
                                                            ? LocaleKeys.uk.tr()
                                                            : HelperFunctions.getTheFirstTwoLettersOfName(state
                                                                .storiesCollections[
                                                                    widget.index]
                                                                .name!))
                                                    : MyCachedNetworkImage(
                                                        height: 28,
                                                        width: 28,
                                                        imageUrl: state
                                                            .storiesCollections[
                                                                widget.index]
                                                            .photoPath,
                                                        imageFit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          imageUrl: widget.firstPhotoNotShowed!,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
