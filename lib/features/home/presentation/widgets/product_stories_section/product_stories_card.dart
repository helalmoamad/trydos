import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/presentation/widgets/product_stories_section/product_story_video_item.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/my_text_widget.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_state.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ProductStoriesCard extends StatelessWidget {
  const ProductStoriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.getStoriesForProductStatus != c.getStoriesForProductStatus,
        builder: (context, state) {
          if (state.storiesForProduct == null) {
            return SizedBox.shrink();
          }
          if (state.storiesForProduct.isNullOrEmpty) {
            return SizedBox.shrink();
          }
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HelperFunctions.showDescriptionForProductDetails(
                              context: context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 30.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppAssets.storyFilmSvg,
                                height: 20,
                                width: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              MyTextWidget(
                                '"${LocaleKeys.product_story.tr()}"',
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(color: Color(0xff8D8D8D)),
                              ),
                              SvgPicture.asset(
                                AppAssets.registerInfoSvg,
                                height: 12,
                                width: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Stack(
                        alignment: LanguageService.rtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        children: [
                          SizedBox(
                            height: 194,
                            child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return ProductStoryVideoItem(
                                    videoUrl: state.storiesForProduct![index]
                                        .fullVideoPath,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    width: 5,
                                  );
                                },
                                itemCount: state.storiesForProduct!.length),
                          ),
                          Container(
                            width: 30,
                            height: 194,
                            color: Colors.transparent,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          );
        });
  }
}
