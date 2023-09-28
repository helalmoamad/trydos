import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/widget/story_item_widget.dart';

class StoriesList extends StatelessWidget {
  StoriesList({super.key});

  final ScrollController listViewController = ScrollController();
  final ValueNotifier<int> resizeStories = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc,StoryState>(builder: (context, state) {

      return ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),
        child :
        ValueListenableBuilder<int>(
            valueListenable: resizeStories,
            builder: (context , focused , _) {
              return GestureDetector(

                onLongPressStart: (details){
                  print(listViewController.offset);
                  resizeStories.value = (details.globalPosition.dx  + listViewController.offset ) ~/115;
                },
                onLongPressUp: (){
                  resizeStories.value=-1;
                },
                onLongPressMoveUpdate: (details){
                  print(listViewController.offset);
                  resizeStories.value = (details.globalPosition.dx + listViewController.offset) ~/115;
                },
                child: SizedBox(
                  height: focused == -1 ? 170 : 228,
                  child: ListView.separated(
                      controller: listViewController,
                      itemBuilder: (context, index) {
                        return StoryItemWidget(resize: index==focused,stories: state.stories[index].stories!,);
                      },
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsetsDirectional.only(start: 10),
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) => SizedBox(
                        width: 5,
                      ),
                      itemCount: state.stories.length),
                ),
              );
            }
        ),
      );

    });
  }
}
