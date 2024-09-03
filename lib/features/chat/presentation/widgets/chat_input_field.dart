import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/form_state_mixin.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
//import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../app/app_widgets/app_text_field.dart';
import '../../../app/app_widgets/gallery_and_camera_dialog_widget.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../utils/firebase_presence.dart';
import 'chat_widgets/no_image_widget.dart';
import 'chat_widgets/voice_waves_in_recording.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    Key? key,
    required this.onSendMessage,
    required this.onSendFile,
    required this.channelId,
    required this.senderName,
    required this.senderUserImage,
  }) : super(key: key);
  final void Function(String message) onSendMessage;
  final void Function(File file, String type) onSendFile;
  final String channelId;
  final String? senderUserImage;
  final String senderName;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ThemeState<ChatInputField>
    with FormStateMinxin {
  final ValueNotifier<bool> thereTextNotifier = ValueNotifier(false);
  final ValueNotifier<bool> recordingNotifier = ValueNotifier(false);
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  Timer _typingTimer = Timer(
    const Duration(microseconds: 1),
    () {},
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      form.controllers[0].addListener(() {
        thereTextNotifier.value = form.controllers[0].text.isNotEmpty &&
            form.controllers[0].text.replaceAll(" ", "").length > 0;
      });
    });
    //initializeRecorder();
    super.initState();
  }

  bool recorderReady = false;

  Future<bool> initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }
    await recorder.openRecorder();
    await recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    recorderReady = true;
    return true;
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    _typingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (p, c) =>
          p.thereIsReply != c.thereIsReply || p.messageId != c.messageId,
      builder: (context, state) {
        debugPrint('imageUrl:  ${state.imageUrl}');

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
                              color: Color.fromARGB(41, 255, 255, 255),
//                              colorScheme.black.withOpacity(0.16)
                              blurRadius: 10)
                        ]),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: state.replyType == 'text'
                          ? Row(
                              key: TestVariables.kTestMode
                                  ? Key(WidgetsKey.replayTextKey)
                                  : null,
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
                                  focusColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    BlocProvider.of<AppBloc>(context).add(
                                        RefreshChatInputField(false, '', false,
                                            messageId: null,
                                            message: null,
                                            senderParentMessageId: null,
                                            imageUrl: null,
                                            time: null));
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.closeSvg,
                                    width: 15.w,
                                    height: 15,
                                  ),
                                ),
                                20.horizontalSpace,
                                Expanded(
                                  child: MyTextWidget(
                                    state.message.toString(),
                                    style: textTheme.titleMedium?.lr.copyWith(
                                        color: colorScheme.grey200,
                                        height: 1.66),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                10.horizontalSpace,
                                widget.senderUserImage != null
                                    ? MyCachedNetworkImage(
                                        imageUrl: ChatUrls.baseUrl +
                                            widget.senderUserImage!,
                                        imageFit: BoxFit.cover,
                                        progressIndicatorBuilderWidget:
                                            TrydosLoader(),
                                        radius: 8,
                                        width: 30.sp,
                                        height: 30.sp)
                                    : NoImageWidget(
                                        width: 30.sp,
                                        height: 30.sp,
                                        textStyle: context
                                            .textTheme.titleMedium?.br
                                            .copyWith(
                                                color: const Color(0xff6638FF),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                        radius: 8,
                                        name: widget.senderName),
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
                                      focusColor: Colors.transparent,
                                      splashColor: Colors.transparent,
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
                                    state.imageUrl?.contains('cloudinary') ??
                                            false
                                        ? MyCachedNetworkImage(
                                            height: 40.sp,
                                            width: 40.sp,
                                            progressIndicatorBuilderWidget:
                                                TrydosLoader(),
                                            imageFit: BoxFit.cover,
                                            imageUrl: state.imageUrl!,
                                          )
                                        : Container(
                                            width: 40.sp,
                                            height: 40.sp,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: FileImage(
                                                    File(state.imageUrl!)),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      Color.fromARGB(1, 0, 0, 0)
//                                                  context
//                                                      .colorScheme.black
//                                                      .withOpacity(0.05)

                                                  ,
                                                  offset: const Offset(0, 3),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                    10.horizontalSpace,
                                    MyTextWidget(
                                      LocaleKeys.photo.tr(),
                                      style: textTheme.titleMedium?.lr.copyWith(
                                          color: colorScheme.grey200,
                                          height: 1.66),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    widget.senderUserImage != null
                                        ? MyCachedNetworkImage(
                                            imageUrl: ChatUrls.baseUrl +
                                                widget.senderUserImage!,
                                            imageFit: BoxFit.cover,
                                            progressIndicatorBuilderWidget:
                                                TrydosLoader(),
                                            radius: 8,
                                            width: 30.sp,
                                            height: 30.sp)
                                        : NoImageWidget(
                                            width: 30.sp,
                                            height: 30.sp,
                                            textStyle: context
                                                .textTheme.titleMedium?.br
                                                .copyWith(
                                                    color:
                                                        const Color(0xff6638FF),
                                                    letterSpacing: 0.18,
                                                    height: 1.33),
                                            radius: 8,
                                            name: widget.senderName),
                                    20.horizontalSpace,
                                  ],
                                )
                              : state.replyType == 'file'
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        20.horizontalSpace,
                                        SvgPicture.asset(
                                          AppAssets.replyOnMessageSvg,
                                          width: 20.w,
                                          height: 20,
                                        ),
                                        15.horizontalSpace,
                                        InkWell(
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            BlocProvider.of<AppBloc>(context)
                                                .add(RefreshChatInputField(
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
                                          AppAssets.documentSvg,
                                          width: 25,
                                          height: 25,
                                        ),
                                        10.horizontalSpace,
                                        SizedBox(
                                          width: 200.w,
                                          child: MyTextWidget(
                                            state.message.toString(),
                                            style: textTheme.titleMedium?.lr
                                                .copyWith(
                                                    color: colorScheme.grey200,
                                                    height: 1.66),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Spacer(),
                                        widget.senderUserImage != null
                                            ? MyCachedNetworkImage(
                                                imageUrl: ChatUrls.baseUrl +
                                                    widget.senderUserImage!,
                                                imageFit: BoxFit.cover,
                                                progressIndicatorBuilderWidget:
                                                    TrydosLoader(),
                                                radius: 8,
                                                width: 30.sp,
                                                height: 30.sp)
                                            : NoImageWidget(
                                                width: 30.sp,
                                                height: 30.sp,
                                                textStyle: context
                                                    .textTheme.titleMedium?.br
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff6638FF),
                                                        letterSpacing: 0.18,
                                                        height: 1.33),
                                                radius: 8,
                                                name: widget.senderName),
                                        20.horizontalSpace,
                                      ],
                                    )
                                  : state.replyType == 'video'
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            20.horizontalSpace,
                                            SvgPicture.asset(
                                              AppAssets.replyOnMessageSvg,
                                              width: 20.w,
                                              height: 20,
                                            ),
                                            15.horizontalSpace,
                                            InkWell(
                                              focusColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                BlocProvider.of<AppBloc>(
                                                        context)
                                                    .add(RefreshChatInputField(
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
                                              AppAssets.lastMessageVideoSvg,
                                              width: 25,
                                              height: 25,
                                            ),
                                            10.horizontalSpace,
                                            SizedBox(
                                              width: 200.w,
                                              child: MyTextWidget(
                                                state.message.toString(),
                                                style: textTheme.titleMedium?.lr
                                                    .copyWith(
                                                        color:
                                                            colorScheme.grey200,
                                                        height: 1.66),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Spacer(),
                                            widget.senderUserImage != null
                                                ? MyCachedNetworkImage(
                                                    imageUrl: ChatUrls.baseUrl +
                                                        widget.senderUserImage!,
                                                    imageFit: BoxFit.cover,
                                                    withImageShadow: true,
                                                    progressIndicatorBuilderWidget:
                                                        TrydosLoader(),
                                                    radius: 8,
                                                    width: 30.sp,
                                                    height: 30.sp)
                                                : NoImageWidget(
                                                    width: 30.sp,
                                                    height: 30.sp,
                                                    textStyle: context.textTheme
                                                        .titleMedium?.br
                                                        .copyWith(
                                                            color: const Color(
                                                                0xff6638FF),
                                                            letterSpacing: 0.18,
                                                            height: 1.33),
                                                    radius: 8,
                                                    name: widget.senderName),
                                            20.horizontalSpace,
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            20.horizontalSpace,
                                            SvgPicture.asset(
                                              AppAssets.replyOnMessageSvg,
                                              width: 20.w,
                                              height: 20,
                                            ),
                                            15.horizontalSpace,
                                            InkWell(
                                              focusColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                BlocProvider.of<AppBloc>(
                                                        context)
                                                    .add(RefreshChatInputField(
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
                                            MyTextWidget(
                                              LocaleKeys.voice.tr(),
                                              style: textTheme.titleMedium?.lr
                                                  .copyWith(
                                                      color:
                                                          colorScheme.grey200,
                                                      height: 1.66),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            widget.senderUserImage != null
                                                ? MyCachedNetworkImage(
                                                    imageUrl: ChatUrls.baseUrl +
                                                        widget.senderUserImage!,
                                                    imageFit: BoxFit.cover,
                                                    radius: 8,
                                                    progressIndicatorBuilderWidget:
                                                        TrydosLoader(),
                                                    width: 30.sp,
                                                    height: 30.sp)
                                                : NoImageWidget(
                                                    width: 30.sp,
                                                    height: 30.sp,
                                                    textStyle: context.textTheme
                                                        .titleMedium?.br
                                                        .copyWith(
                                                            color: const Color(
                                                                0xff6638FF),
                                                            letterSpacing: 0.18,
                                                            height: 1.33),
                                                    radius: 8,
                                                    name: widget.senderName),
                                            20.horizontalSpace,
                                          ],
                                        ),
                    ),
                  )
                : const SizedBox.shrink(),
            ValueListenableBuilder<bool>(
                valueListenable: thereTextNotifier,
                builder: (context, thereText, _) {
                  return ValueListenableBuilder<bool>(
                      valueListenable: recordingNotifier,
                      builder: (context, recording, _) {
                        return Container(
                          height: 50,
                          width: 1.sw,
                          color: const Color(0xffF6F6F6),
                          child: recording
                              ? Row(
                                  children: [
                                    10.horizontalSpace,
                                    SvgPicture.asset(
                                      AppAssets.recordingVoiceSvg,
                                      width: 43.w,
                                      height: 40,
                                    ),
                                    32.horizontalSpace,
                                    StreamBuilder<RecordingDisposition>(
                                        stream: recorder.onProgress,
                                        builder: (context, snapShot) {
                                          final duration = snapShot.hasData
                                              ? snapShot.data!.duration
                                              : Duration.zero;
                                          final String minutes = duration
                                              .inMinutes
                                              .remainder(60)
                                              .toString();
                                          final String seconds =
                                              HelperFunctions.twoDigits(duration
                                                  .inSeconds
                                                  .remainder(60));

                                          return MyTextWidget(
                                              '$minutes:$seconds',
                                              style: textTheme.bodyMedium?.rr
                                                  .copyWith(
                                                color: const Color(0xff404040),
                                                letterSpacing: 0.18,
                                                height: 1.11,
                                              ));
                                        }),
                                    const Spacer(),
                                    const VoiceWavesInRecording(),
                                    20.horizontalSpace,
                                    InkWell(
                                      focusColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () async {
                                        if (!recorderReady) {
                                          final bool isInitialized =
                                              await initializeRecorder();
                                          if (!isInitialized) return;
                                        }
                                        recordingNotifier.value = false;
                                        FirebasePresence.deleteUserTransaction(
                                          channelId: widget.channelId,
                                        );
                                        final String path =
                                            (await recorder.stopRecorder())!;
                                        recorder.deleteRecord(fileName: path);
                                      },
                                      child: MyTextWidget(
                                          LocaleKeys.cansel.tr(),
                                          style: textTheme.titleLarge?.rr
                                              .copyWith(
                                                  letterSpacing: 0.14,
                                                  height: 1.4285714285714286,
                                                  color:
                                                      const Color(0xff404040))),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      focusColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () async {
                                        final path =
                                            await recorder.stopRecorder();
                                        final audioFile = File(path!);
                                        FirebasePresence.deleteUserTransaction(
                                          channelId: widget.channelId,
                                        );
                                        widget.onSendFile(audioFile, 'voice');
                                        recordingNotifier.value = false;
                                      },
                                      child: Padding(
                                        padding: HWEdgeInsets.all(10.0),
                                        child: SvgPicture.asset(
                                          AppAssets.messageReadArrowSvg,
                                          width: 20.w,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    14.horizontalSpace,
                                  ],
                                )
                              : Row(
                                  children: [
                                    13.horizontalSpace,
                                    InkWell(
                                      focusColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () async {
                                        FirebasePresence.sendUserTransaction(
                                          channelId: widget.channelId,
                                          description:
                                              LocaleKeys.sending_file.tr(),
                                        );
                                        File? file = await HelperFunctions
                                            .pickDocumentFile();
                                        FirebasePresence.deleteUserTransaction(
                                          channelId: widget.channelId,
                                        );
                                        if (file != null) {
                                          widget.onSendFile(file, 'file');
                                        }
                                      },
                                      child: SvgPicture.asset(
                                        AppAssets.addStickersSvg,
                                        width: 43.w,
                                        height: 40,
                                      ),
                                    ),
                                    5.horizontalSpace,
                                    Expanded(
                                      child: Padding(
                                        padding: HWEdgeInsets.symmetric(
                                            vertical: 7.0),
                                        child: AppTextField(
                                          key: TestVariables.kTestMode
                                              ? Key(
                                                  WidgetsKey
                                                      .sendMessageTextFieldKey,
                                                )
                                              : null,
                                          controller: form.controllers[0],
                                          onChange: (text) {
                                            _typingTimer.cancel();
                                            try {
                                              FirebasePresence
                                                  .sendUserTransaction(
                                                channelId: widget.channelId,
                                                description:
                                                    LocaleKeys.typing.tr(),
                                              );
                                              // pusherChatService
                                              //     .sendActivityEvent(
                                              //         widget.channelId,
                                              //         'Typing...');
                                            } catch (e) {
                                              debugPrint(e.toString());
                                            }
                                            _typingTimer = Timer(
                                                const Duration(seconds: 1), () {
                                              FirebasePresence
                                                  .deleteUserTransaction(
                                                channelId: widget.channelId,
                                              );
                                            });
                                          },
                                          contentPadding:
                                              HWEdgeInsets.symmetric(
                                                  horizontal: 12)
                                                ..copyWith(right: 0),
                                        ),
                                      ),
                                    ),
                                    5.horizontalSpace,
                                    if (!thereText) ...{
                                      InkWell(
                                        focusColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () async {
                                          FirebasePresence.sendUserTransaction(
                                            channelId: widget.channelId,
                                            description:
                                                LocaleKeys.sending_file.tr(),
                                          );
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return GalleryAndCameraDialogWidget(
                                                    onChooseFileFromGalleryAction:
                                                        (AssetEntity?
                                                            assetEntity) async {
                                                  if (assetEntity != null) {
                                                    File file =
                                                        (await assetEntity
                                                            .originFile)!;
                                                    String mimeStr =
                                                        lookupMimeType(file
                                                                .absolute
                                                                .path) ??
                                                            '';
                                                    var fileType =
                                                        mimeStr.split('/');
                                                    log(fileType.toString());
                                                    if (fileType[0] ==
                                                        'image') {
                                                      widget.onSendFile
                                                          .call(file, 'image');
                                                    } else {
                                                      widget.onSendFile
                                                          .call(file, 'video');
                                                    }
                                                  }
                                                }, onChooseFileFromCameraAction:
                                                        (File? file) {
                                                  if (file != null) {
                                                    String mimeStr =
                                                        lookupMimeType(file
                                                                .absolute
                                                                .path) ??
                                                            '';
                                                    var fileType =
                                                        mimeStr.split('/');
                                                    log(fileType.toString());
                                                    if (fileType[0] ==
                                                        'image') {
                                                      widget.onSendFile
                                                          .call(file, 'image');
                                                    } else {
                                                      widget.onSendFile
                                                          .call(file, 'video');
                                                    }
                                                  }
                                                });
                                              }).then((value) {
                                            FirebasePresence
                                                .deleteUserTransaction(
                                              channelId: widget.channelId,
                                            );
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          AppAssets.takePictureSvg,
                                          width: 50.w,
                                          height: 40,
                                        ),
                                      ),
                                      10.horizontalSpace,
                                      InkWell(
                                        focusColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () async {
                                          if (!recorderReady) {
                                            bool isInitialized =
                                                await initializeRecorder();
                                            if (!isInitialized) return;
                                          }
                                          if (recorder.isRecording) {
                                            return;
                                          }
                                          FirebasePresence.sendUserTransaction(
                                            channelId: widget.channelId,
                                            description:
                                                LocaleKeys.recording.tr(),
                                          );
                                          await recorder.startRecorder(
                                            toFile:
                                                'audio${const Uuid().v4()}.aac',
                                          );
                                          recordingNotifier.value = true;
                                        },
                                        child: SvgPicture.asset(
                                          AppAssets.recordVoiceSvg,
                                          width: 70.w,
                                          height: 40,
                                        ),
                                      ),
                                    } else ...{
                                      InkWell(
                                        key: TestVariables.kTestMode
                                            ? Key(
                                                WidgetsKey
                                                    .sendMessageInChatButtonKey,
                                              )
                                            : null,
                                        focusColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          String message =
                                              form.controllers[0].text;
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
                      });
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
