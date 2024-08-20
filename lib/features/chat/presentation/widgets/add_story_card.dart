import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/story/data/models/get_stories_model.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../app/my_text_widget.dart';
import 'chat_widgets/no_image_widget.dart';

class AddStoryCard extends StatelessWidget {
  const AddStoryCard({Key? key, required this.collectionStoryModel})
      : super(key: key);
  final CollectionStoryModel collectionStoryModel;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      debugPrint(error.toString());
    };

    return SizedBox(
        height: 100.h,
        width: 1.sw,
        child: GestureDetector(
            onTap: () {},
            child: Stack(
              children: [
                Container(
                  padding: HWEdgeInsets.only(left: 15.w, right: 10.w),
                  color: context.colorScheme.white,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        collectionStoryModel.photoPath == null
                            ? NoImageWidget(
                                width: 60.r,
                                height: 60.r,
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
                        18.horizontalSpace,
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child: Row(
                                children: [
                                  MyTextWidget(
                                    LocaleKeys.my_stories.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            height: 1.33,
                                            color: const Color(0xff505050)),
                                  ),
                                  const Spacer(),
                                ],
                              )),
                              Flexible(
                                  child: Row(
                                children: [
                                  MyTextWidget(
                                    LocaleKeys.click_to_add_story.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            height: 1.33,
                                            color: const Color(0xff505050)),
                                  ),
                                  const Spacer(),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ]),
                )
              ],
            )));
  }
}
