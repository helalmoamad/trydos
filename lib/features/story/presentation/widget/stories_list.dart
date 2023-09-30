import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/story/helper_functions/check_showing_stories.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/pages/story_collection.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';

class StoriesList extends StatelessWidget {
  StoriesList({super.key});

  final ScrollController listViewController = ScrollController();
  final ValueNotifier<int> resizeStories = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
//todo the ScrollConfiguration make behavior to the scroll
      return ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),
        child:
            //todo the ValueListenableBuilder to control the effect when make longPress on the story and other action
            ValueListenableBuilder<int>(
                valueListenable: resizeStories,
                builder: (context, focused, _) {
                  return SizedBox(
                      width: 90,
                      height: 120,
                      child: ListView.separated(
                          controller: listViewController,
                          itemBuilder: (context, index) {
                            var indexOfInitialStory = firstWhereNotShowed(state.stories[index].stories!);

                            var initialStory = state.stories[index].stories![indexOfInitialStory];
                            return GestureDetector(
                              onTap: () async {
                                GetIt.I<StoryBloc>().add(StorySelectedEvent(
                                    selected: index,
                                    initialStory: indexOfInitialStory));

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => StoryCollection(index)));
                              },
                              onLongPressStart: (details) {
                                resizeStories.value =
                                    (details.globalPosition.dx +
                                            listViewController.offset) ~/
                                        115;
                              },
                              onLongPressUp: () {
                                resizeStories.value = -1;
                              },
                              onLongPressMoveUpdate: (details) {
                                resizeStories.value =
                                    (details.globalPosition.dx +
                                            listViewController.offset) ~/
                                        115;
                              },
                              child: SizedBox(
                                  height: focused == -1 ? 170 : 228,
                                  child: (initialStory.isPhoto == 1)
                                      ? StoryItemWidget(
                                          resize: index == focused,
                                          firstPhotoNotShowed: state
                                              .stories[0]
                                              .stories![firstWhereNotShowed(
                                                  state.stories[0].stories!)]
                                              .photoPath!,
                                        )
                                      : Text('ibrahem')
//      }

                                  ),
                            );
                          },
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsetsDirectional.only(start: 10),
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) => SizedBox(
                                width: 5,
                              ),
                          itemCount: state.stories.length));
                }),
      );
    });
  }
}
