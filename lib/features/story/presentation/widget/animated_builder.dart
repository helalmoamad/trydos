import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../bloc/story_bloc.dart';
import '../bloc/story_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int collectionIndex;

  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.collectionIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context1, state) {
        return Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.5.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: <Widget>[
                    _buildContainer(
                      double.infinity,
                      position <
                              state
                                  .currentStoryInEachCollection[collectionIndex]!
                          ? Colors.white
                          // ignore: deprecated_member_use
                          : Colors.white.withOpacity(0.5),
                    ),
                    position ==
                            state.currentStoryInEachCollection[collectionIndex]
                        ? AnimatedBuilder(
                            animation: animController,
                            builder: (context, child) {
                              return _buildContainer(
                                constraints.maxWidth * animController.value,
                                Colors.white,
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Container _buildContainer(double width, Color color) {
  return Container(
    height: 5.h,
    width: width,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: Colors.black26, width: 0.8.w),
      borderRadius: BorderRadius.circular(3.r),
    ),
  );
}
