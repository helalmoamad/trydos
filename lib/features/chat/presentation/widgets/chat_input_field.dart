import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mime/mime.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/form_state_mixin.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../app/app_widgets/app_text_field.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_cached_network_image.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    Key? key,
    required this.onSendMessage,
    required this.onSendFile,
  }) : super(key: key);
  final void Function(String message) onSendMessage;
  final void Function(File file) onSendFile;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ThemeState<ChatInputField>
    with FormStateMinxin {
  final ValueNotifier<bool> thereTextNotifier = ValueNotifier(false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      form.controllers[0].addListener(() {
        thereTextNotifier.value = form.controllers[0].text.isNotEmpty;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            state.thereIsReply
                ? Container(
                    height: 103,
                    width: 1.sw,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        color: state.replyOnMe
                            ? const Color(0xffF1FDE3)
                            : const Color(0xffD5F6E6),
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(0, 2),
                              color: colorScheme.black.withOpacity(0.16),
                              blurRadius: 10)
                        ]),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: state.replyType == 'text'
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                20.horizontalSpace,
                                SvgPicture.asset(
                                  AppAssets.replyOnMessageSvg,
                                  width: 20.w,
                                  height: 20,
                                ),
                                15.horizontalSpace,
                                InkWell(
                                  onTap: () {
                                    BlocProvider.of<AppBloc>(context).add(
                                        RefreshChatInputField(
                                            false, '', false));
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.closeSvg,
                                    width: 15.w,
                                    height: 15,
                                  ),
                                ),
                                20.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    state.message.toString(),
                                    style: textTheme.caption?.lr.copyWith(
                                        color: colorScheme.grey200,
                                        height: 1.66),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                10.horizontalSpace,
                                Container(
                                  width: 30.sp,
                                  height: 30.sp,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(state.replyOnMe
                                            ? AppAssets.chatProfileJpg
                                            : AppAssets.chatProfile2Jpg),
                                        fit: BoxFit.cover,
                                        opacity: 0.8),
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.colorScheme.black
                                            .withOpacity(0.16),
                                        offset: const Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                20.horizontalSpace,
                              ],
                            )
                          : state.replyType == 'image'
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    20.horizontalSpace,
                                    SvgPicture.asset(
                                      AppAssets.replyOnMessageSvg,
                                      width: 20.w,
                                      height: 20,
                                    ),
                                    15.horizontalSpace,
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<AppBloc>(context).add(
                                            RefreshChatInputField(
                                                false, '', false));
                                      },
                                      child: SvgPicture.asset(
                                        AppAssets.closeSvg,
                                        width: 15.w,
                                        height: 15,
                                      ),
                                    ),
                                    20.horizontalSpace,
                                    state.imageUrl!.contains('images/test')
                                        ? MyCachedNetworkImage(
                                            height: 40.sp,
                                            width: 40.sp,
                                            imageUrl:
                                                Urls.baseUrl + state.imageUrl!,
                                          )
                                        : Container(
                                            width: 40.sp,
                                            height: 40.sp,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image:
                                                    AssetImage(state.imageUrl!),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: context
                                                      .colorScheme.black
                                                      .withOpacity(0.05),
                                                  offset: const Offset(0, 3),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                    10.horizontalSpace,
                                    Text(
                                      'Photo',
                                      style: textTheme.caption?.lr.copyWith(
                                          color: colorScheme.grey200,
                                          height: 1.66),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 30.sp,
                                      height: 30.sp,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(state.replyOnMe
                                                ? AppAssets.chatProfileJpg
                                                : AppAssets.chatProfile2Jpg),
                                            fit: BoxFit.cover,
                                            opacity: 0.8),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.colorScheme.black
                                                .withOpacity(0.16),
                                            offset: const Offset(0, 3),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    20.horizontalSpace,
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    20.horizontalSpace,
                                    SvgPicture.asset(
                                      AppAssets.replyOnMessageSvg,
                                      width: 20.w,
                                      height: 20,
                                    ),
                                    15.horizontalSpace,
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<AppBloc>(context).add(
                                            RefreshChatInputField(
                                                false, '', false));
                                      },
                                      child: SvgPicture.asset(
                                        AppAssets.closeSvg,
                                        width: 15.w,
                                        height: 15,
                                      ),
                                    ),
                                    20.horizontalSpace,
                                    SvgPicture.asset(
                                      AppAssets.voicePlayedSvg,
                                      width: 40.sp,
                                      height: 40.sp,
                                    ),
                                    10.horizontalSpace,
                                    Text(
                                      'Voice',
                                      style: textTheme.caption?.lr.copyWith(
                                          color: colorScheme.grey200,
                                          height: 1.66),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 30.sp,
                                      height: 30.sp,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(state.replyOnMe
                                                ? AppAssets.chatProfileJpg
                                                : AppAssets.chatProfile2Jpg),
                                            fit: BoxFit.cover,
                                            opacity: 0.8),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.colorScheme.black
                                                .withOpacity(0.16),
                                            offset: const Offset(0, 3),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    20.horizontalSpace,
                                  ],
                                ),
                    ),
                  )
                : const SizedBox.shrink(),
            ValueListenableBuilder<bool>(
                valueListenable: thereTextNotifier,
                builder: (context, thereText, _) {
                  return Container(
                    height: 50,
                    width: 1.sw,
                    color: const Color(0xffF6F6F6),
                    child: Row(
                      children: [
                        13.horizontalSpace,
                        SvgPicture.asset(
                          AppAssets.addStickersSvg,
                          width: 43.w,
                          height: 40,
                        ),
                        5.horizontalSpace,
                        Expanded(
                          child: Padding(
                            padding: HWEdgeInsets.symmetric(vertical: 7.0),
                            child: AppTextField(
                              controller: form.controllers[0],
                              contentPadding:
                                  HWEdgeInsets.symmetric(horizontal: 12)
                                    ..copyWith(right: 0),
                            ),
                          ),
                        ),
                        5.horizontalSpace,
                        if (!thereText) ...{
                          InkWell(
                            onTap: () async {
                              AssetEntity? assetEntity =
                                  await HelperFunctions.getAssetFromCamera(
                                      context);
                              if (assetEntity != null) {
                                File file = (await assetEntity.file)!;
                                String mimeStr =
                                    lookupMimeType(file.absolute.path ?? '') ??
                                        '';
                                var fileType = mimeStr.split('/');
                                log(fileType.toString());
                                if (fileType[0] == 'image') {
                                  widget.onSendFile.call(file);
                                }
                              }
                            },
                            child: SvgPicture.asset(
                              AppAssets.takePictureSvg,
                              width: 50.w,
                              height: 40,
                            ),
                          ),
                          10.horizontalSpace,
                          SvgPicture.asset(
                            AppAssets.recordVoiceSvg,
                            width: 70.w,
                            height: 40,
                          ),
                        } else ...{
                          InkWell(
                            onTap: () {
                              String message = form.controllers[0].text;
                              form.controllers[0].text = '';
                              widget.onSendMessage.call(message);
                            },
                            child: SvgPicture.asset(
                              AppAssets.sendMessageSvg,
                              width: 58.w,
                              height: 40,
                            ),
                          ),
                        },
                        5.horizontalSpace,
                      ],
                    ),
                  );
                })
          ],
        );
      },
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
