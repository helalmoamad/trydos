import 'dart:math';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../app/my_text_widget.dart';
import '../../../story/helper_functions/check_showing_stories.dart';
import '../../../story/presentation/bloc/story_bloc.dart';
import '../../../story/presentation/pages/story_collection_page_view.dart';
import 'chat_widgets/no_image_widget.dart';

class StoryCard extends StatelessWidget {
  const StoryCard(
      {Key? key, required this.collectionStoryModel, required this.index})
      : super(key: key);
  final CollectionStoryModel collectionStoryModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    print("" +
        "111111111${collectionStoryModel.name}1111111111111111111111111111111111111");
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      debugPrint(error.toString());
    };
    return InkWell(
      onTap: () {
        int indexOfInitialStory;
        if (GetIt.I<PrefsRepository>().myStoriesId ==
            collectionStoryModel.stories![0].userId) {
          indexOfInitialStory = collectionStoryModel.stories!
              .lastIndexWhere((element) => element.isSeen == false);
          indexOfInitialStory =
              indexOfInitialStory == -1 ? 0 : indexOfInitialStory;
        } else {
          indexOfInitialStory =
              firstWhereNotShowed(collectionStoryModel.stories!);
        }
        GetIt.I<StoryBloc>().add(StorySelectedEvent(
            collectionIndex: index,
            currentPage: index,
            selectedStoryIndexInCollection: indexOfInitialStory));

        pushOverscrollRoute(
            context: context,
            child: StoryCollectionPageView(initialPage: index),
            dragToPopDirection: DragToPopDirection.toBottom,
            fullscreenDialog: true);
      },
      child: SizedBox(
          height: 80.h,
          width: 1.sw,
          child: Stack(
            children: [
              Container(
                padding:
                    HWEdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
                color: context.colorScheme.white,
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularStepProgressIndicator(
                        totalSteps: collectionStoryModel.stories!.length,
                        startingAngle: pi,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: collectionStoryModel.photoPath == null
                              ? NoImageWidget(
                                  width: 60.r,
                                  height: 60.r,
                                  radius: 180,
                                  textStyle: context.textTheme.bodyMedium?.br
                                      .copyWith(
                                          color: const Color(0xff6638FF),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                  name: collectionStoryModel.name == null
                                      ? LocaleKeys.uk.tr()
                                      : HelperFunctions
                                          .getTheFirstTwoLettersOfName(
                                              collectionStoryModel.name!))
                              : MyCachedNetworkImage(
                                  height: 60.r,
                                  width: 60.r,
                                  imageUrl: collectionStoryModel.photoPath,
                                  imageFit: BoxFit.cover,
                                ),
                        ),
                        width: 70.r,
                        height: 90.r,
                        stepSize: 5.r,
                        customColor: (index) {
                          if (collectionStoryModel.stories![index].isSeen ??
                              false) return Colors.grey;
                          return Colors.green;
                        },
                        roundedCap: (index, isSelected) => true,
                      ),
                      18.horizontalSpace,
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Row(
                                children: [
                                  MyTextWidget(
                                    collectionStoryModel.name ??
                                        LocaleKeys.unknown_user.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            height: 1.33,
                                            color: const Color(0xff505050)),
                                  ),
                                  const Spacer(),
                                ],
                              ))
                            ],
                          ),
                        ),
                      ),
                    ]),
              )
            ],
          )),
    );
  }
}
