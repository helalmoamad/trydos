import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/calls/data/models/my_calls.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/bloc/story_state.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../calls/presentation/widgets/calls_card.dart';
import '../../../home/presentation/widgets/sliver_list_seprated.dart';
import '../widgets/add_story_card.dart';
import '../widgets/story_card.dart';

class StoriesForChatPageContent extends StatefulWidget {
  const StoriesForChatPageContent({Key? key}) : super(key: key);

  @override
  State<StoriesForChatPageContent> createState() =>
      _StoriesForChatPageContentState();
}

class _StoriesForChatPageContentState
    extends ThemeState<StoriesForChatPageContent> {
  late ChatBloc chatBloc;
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    super.initState();
  }

  bool thereIsAddStoryCard = false;
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      chatBloc.add(SendErrorChatToServerEvent(
          error: error.toString(), lastPage: "Stories_For_Chat_Page_Content"));
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      debugPrint(error.toString());
    };

    return BlocBuilder<StoryBloc, StoryState>(
      // buildWhen: (previous, current) {
      //   return previous.getStoriesStatus != current.getStoriesStatus &&
      //       current.getStoriesStatus == GetStoriesStatus.success;
      // },
      builder: (context, state) {
        if (state.storiesCollections.isEmpty) {
          return SliverToBoxAdapter(
              child: SizedBox(
            height: 1.sh - 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TrydosLoader(),
              ],
            ),
          ));
        }
        return SliverMainAxisGroup(slivers: [
          SliverToBoxAdapter(
              child: Container(
                  width: 1.sw,
                  color: colorScheme.white,
                  child: state.getStoriesStatus != GetStoriesStatus.success
                      ? TrydosLoader()
                      : const SizedBox.shrink())),
          sliverListSeparated(
            itemBuilder: (_, index) {
              if (index == 0 &&
                  state.storiesCollections[index].stories!.first.userId !=
                      GetIt.I<PrefsRepository>().myStoriesId) {
                thereIsAddStoryCard = true;
                return AddStoryCard(
                  collectionStoryModel: state.storiesCollections[index],
                );
              }

              return StoryCard(
                index: thereIsAddStoryCard ? (index - 1) : index,
                collectionStoryModel: state.storiesCollections[index],
              );
            },
            separator: Divider(
              color: Colors.grey.shade300,
              height: 1.h,
            ),
            childCount: state.storiesCollections.length,
          )
        ]);
      },
    );
  }
}
