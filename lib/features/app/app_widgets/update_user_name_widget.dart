import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';

import '../../../common/constant/design/assets_provider.dart';
import '../../../core/utils/responsive_padding.dart';
import '../../../generated/locale_keys.g.dart';
import '../../authentication/presentation/widgets/name_from_field.dart';
import '../my_text_widget.dart';

class UpdateUserNameWidget extends StatelessWidget {
  UpdateUserNameWidget({super.key, this.updateForStoriesServer = false});

  final bool updateForStoriesServer;
  final ValueNotifier<bool> displaySubmit = ValueNotifier(false);
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (context.canPop()) {
            Navigator.pop(context);
            showMessage('Name Saved Successfully',
                showInRelease: true, foreGroundColor: Colors.green);
          }
        },
        listenWhen: (p, c) =>
            (updateForStoriesServer &&
                p.updateStoriesUserStatus != c.updateStoriesUserStatus &&
                c.updateStoriesUserStatus == UpdateStoriesUserStatus.success) ||
            (!updateForStoriesServer &&
                p.updateChatUserNameStatus != c.updateChatUserNameStatus &&
                c.updateChatUserNameStatus == UpdateChatUserNameStatus.success),
        buildWhen: (p, c) =>
        (updateForStoriesServer &&
            p.updateChatUserNameStatus != c.updateStoriesUserStatus) || (!updateForStoriesServer &&
            p.updateChatUserNameStatus != c.updateStoriesUserStatus),
        builder: (context, state) {
          if (state.updateStoriesUserStatus ==
              UpdateStoriesUserStatus.loading) {
            return TrydosLoader();
          }
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyTextWidget(
                    LocaleKeys.insert_name_to_continue.tr(),
                    style: context.textTheme.subtitle2,
                  ),
                  10.verticalSpace,
                  Padding(
                      padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                      child: ValueListenableBuilder<bool>(
                          valueListenable: displaySubmit,
                          builder: (context, display, _) {
                            return NameFormField(
                              autoFocus: false,
                              ready: display,
                              onChange: (String? text) {
                                displaySubmit.value = text!.length > 8;
                              },
                              controller: controller,
                              suffixIcon: Padding(
                                padding:
                                    HWEdgeInsets.only(right: 20.0, top: 22),
                                child: !display
                                    ? SizedBox(
                                        width: 22,
                                        height: 15,
                                      )
                                    : InkWell(
                                        onTap: () {
                                          BlocProvider.of<AuthBloc>(context)
                                              .add(UpdateStoriesUserEvent(
                                                  name: controller.text));
                                        },
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                AppAssets.submitArrowSvg,
                                                width: 10,
                                                height: 20,
                                              ),
                                            ]),
                                      ),
                              ),
                            );
                          })),
                ],
              ),
              Transform.translate(
                  offset: Offset(10, -10),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.cancel_outlined)))
            ],
          );
        },
      ),
    );
  }
}
