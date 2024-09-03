import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/constant/configuration/stories_url_routes.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../core/utils/responsive_padding.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../app/app_elvated_button.dart';
import '../../../app/app_widgets/app_text_field.dart';
import '../../../app/my_text_widget.dart';

class EditUrlsPage extends StatefulWidget {
  EditUrlsPage({super.key});

  @override
  State<EditUrlsPage> createState() => _EditUrlsPageState();
}

class _EditUrlsPageState extends State<EditUrlsPage> {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  final TextEditingController marketController = TextEditingController();

  final TextEditingController storyController = TextEditingController();

  final TextEditingController chatController = TextEditingController();
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    marketController.text = MarketUrls.baseUrl;
    storyController.text = StoriesUrls.baseUrl;
    chatController.text = ChatUrls.baseUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.colorScheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Market Url:'),
                AppTextField(
                  controller: marketController,
                  filledColor: context.colorScheme.grey50,
                  bordersColor: context.colorScheme.grey50,
                  hintTextStyle: context.textTheme.bodySmall?.lr
                      .copyWith(color: const Color(0xffD3D3D3)),
                  contentPadding:
                      HWEdgeInsetsDirectional.fromSTEB(20.w, 10, 20.w, 10),
                ),
                15.verticalSpace,
                Text('Chat Url:'),
                AppTextField(
                  controller: chatController,
                  filledColor: context.colorScheme.grey50,
                  bordersColor: context.colorScheme.grey50,
                  hintTextStyle: context.textTheme.bodySmall?.lr
                      .copyWith(color: const Color(0xffD3D3D3)),
                  contentPadding:
                      HWEdgeInsetsDirectional.fromSTEB(20.w, 10, 20.w, 10),
                ),
                15.verticalSpace,
                Text('Story Url:'),
                AppTextField(
                  controller: storyController,
                  filledColor: context.colorScheme.grey50,
                  bordersColor: context.colorScheme.grey50,
                  hintTextStyle: context.textTheme.bodySmall?.lr
                      .copyWith(color: const Color(0xffD3D3D3)),
                  contentPadding:
                      HWEdgeInsetsDirectional.fromSTEB(20.w, 10, 20.w, 10),
                ),
                30.verticalSpace,
                AppElevatedButton(
                    text: 'Save',
                    onPressed: () async {
                      _prefsRepository.setMarketUrl(marketController.text);
                      _prefsRepository.setStoryUrl(storyController.text);
                      _prefsRepository.setChatUrl(chatController.text);
                    }),
                30.verticalSpace,
                AppElevatedButton(
                    text: 'Clear tokens',
                    onPressed: () async {
                      _prefsRepository.clearTokenForMarket();
                      _prefsRepository.clearTokensForChatAndStory();
                    }),
              ],
            ),
          ),
        ));
  }
}
