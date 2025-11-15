import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/vedio_player.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/pages/media_in_profile.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../service/language_service.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../calls/presentation/bloc/calls_bloc.dart';
import '../../../calls/presentation/utils/caller_info.dart';
import '../widgets/chat_widgets/no_image_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    required this.receiverName,
    required this.receiverPhone,
    required this.senderPhoto,
    required this.fullReceiverName,
    required this.dataLength,
    required this.senderName,
    required this.receiverPhoto,
    required this.chatId,
  }) : super(key: key);
  final String receiverName;
  final String receiverPhone;
  final String chatId;
  final String senderName;
  final int dataLength;
  final String? senderPhoto;
  final String fullReceiverName;
  final String? receiverPhoto;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ChatBloc chatBloc;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  List<String>? images = [];

  int imagess = 0;
  late String mimeStr;
  int filess = 0;
  int videoss = 0;
  @override
  void initState() {
    LastPagesTracker.push('ProfilePage');
    images = _prefsRepository.getTheLocalPathForChannel(widget.chatId) ?? [];
    chatBloc = BlocProvider.of<ChatBloc>(context);
    print(images);
    images!.forEach((element) {
      mimeStr = element.split(" ")[0];
      if (mimeStr.split('/').contains("video") &&
          !mimeStr.split('.').contains("aac")) {
        videoss++;
      } else if (mimeStr.split('/').contains("image")) {
        imagess = imagess + 1;
      } else if (mimeStr.split('/').contains("files")) {
        filess++;
      } else {}
    });

    chatBloc.add(
      AddMediaCountEvent(images: imagess, videos: videoss, file: filess),
    );
    super.initState();
  }

  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        error: error.toString(),
      );
    };
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: Stack(
          alignment: LanguageService.languageCode == 'ar'
              ? AlignmentDirectional.topEnd
              : AlignmentDirectional.topStart,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    50.verticalSpace,
                    widget.receiverPhoto != null
                        ? Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(2, 0, 0, 0),
                                  //                            colorScheme.black.withOpacity(0.16)
                                  offset: Offset(0, 3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: MyCachedNetworkImage(
                              imageUrl:
                                  (widget.receiverPhoto.toString().contains(
                                        "cloudinary",
                                      )
                                      ? ""
                                      : "${dotenv.env['Images_Url']}") +
                                  widget.receiverPhoto!,
                              imageFit: BoxFit.cover,
                              progressIndicatorBuilderWidget: TrydosLoader(),
                              height: 150.h,
                              width: 150.w,
                            ),
                          )
                        : NoImageWidget(
                            height: 150.h,
                            width: 150.w,
                            textStyle: context.textTheme.bodyMedium?.bq
                                .copyWith(
                                  color: const Color(0xff6638FF),
                                  letterSpacing: 0.18,
                                  height: 1.33,
                                ),
                            name: widget.receiverName,
                          ),
                    17.verticalSpace,
                    MyTextWidget(
                      widget.fullReceiverName,
                      style: textTheme.headlineSmall?.rq.copyWith(
                        color: const Color(0xff5D5C5D),
                      ),
                    ),
                    8.verticalSpace,
                    MyTextWidget(
                      widget.receiverPhone,
                      style: textTheme.titleLarge?.rq.copyWith(
                        color: const Color(0xff5D5C5D),
                      ),
                    ),
                  ],
                ),
                50.verticalSpace,
                Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 70.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          try {
                            List<Map<String, dynamic>> info = callerInfo(
                              channelId: widget.chatId,
                            );
                            PermissionStatus microphone = await Permission
                                .microphone
                                .request();
                            var status2 = await Permission.mediaLibrary
                                .request();
                            if (microphone.isGranted && status2.isGranted) {
                              //todo we have the receiver id so the chat dose not exist
                              if (info[0].containsKey('currentReceiver')) {
                                debugPrint(
                                  'currentReceiver${info[0]['currentReceiver']}',
                                );

                                GetIt.I<CallsBloc>().add(
                                  MakeCallEvent(
                                    receiverUserId: info[0]['currentReceiver']
                                        .toString(),
                                    receiverCallName: widget.fullReceiverName,
                                    chatId: info[1]['channelId'],
                                    isVideo: false,
                                    payload: info[1],
                                  ),
                                );

                                // GetIt.I<CallsBloc>().add(VideoCallEvent(
                                //     receiverUserId: info[0]['currentReceiver'],
                                //     payload: info[1]));
                                //todo we need to wait the response to get the new chat id and join the video call so the navigation will be in the listener
                              }
                              //todo else the chat already exist so we don't have the receiver id just the chat id
                              else {
                                debugPrint('widget.chatId${widget.chatId}');
                                debugPrint('info[0]${info[0]}');

                                GetIt.I<CallsBloc>().add(
                                  MakeCallEvent(
                                    isVideo: false,
                                    receiverCallName: widget.fullReceiverName,
                                    chatId: info[0]['channelId'],
                                    payload: info[0],
                                  ),
                                );
                                //todo we have the id of the chat so we can move to the call immediately
                              }
                            } else if (microphone.isDenied ||
                                status2.isDenied) {
                              showWarningMessage(
                                context,
                                LocaleKeys.permission_denied.tr(),
                              );
                              openAppSettings();
                            }
                          } catch (e, st) {
                            print(e);
                            print(st);
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.callingSvg,
                              // ignore: deprecated_member_use
                              color: const Color(0xff388CFF),
                              width: 25.sp,
                              height: 25.sp,
                            ),
                            10.verticalSpace,
                            MyTextWidget(
                              LocaleKeys.call.tr(),
                              style: textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xff5D5C5D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          List<Map<String, dynamic>> info = callerInfo(
                            channelId: widget.chatId,
                          );
                          PermissionStatus microphone = await Permission
                              .microphone
                              .request();
                          var status2 = await Permission.mediaLibrary.request();
                          PermissionStatus camera = await Permission.camera
                              .request();
                          if (microphone.isGranted &&
                              status2.isGranted &&
                              camera.isGranted) {
                            if (info[0].containsKey('currentReceiver')) {
                              GetIt.I<CallsBloc>().add(
                                MakeCallEvent(
                                  receiverUserId: info[0]['currentReceiver']
                                      .toString(),
                                  receiverCallName: widget.fullReceiverName,
                                  chatId: info[1]['channelId'],
                                  isVideo: true,
                                  payload: info[1],
                                ),
                              );
                            } else {
                              GetIt.I<CallsBloc>().add(
                                MakeCallEvent(
                                  isVideo: true,
                                  receiverCallName: widget.fullReceiverName,
                                  chatId: info[0]['channelId'],
                                  payload: info[0],
                                ),
                              );
                              //todo we have the id of the chat so we can move to the call immediately
                            }
                          } else if (microphone.isDenied ||
                              status2.isDenied ||
                              camera.isDenied) {
                            showWarningMessage(
                              context,
                              LocaleKeys.permission_denied.tr(),
                            );
                            openAppSettings();
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.videoCallSvg,
                              width: 25.sp,
                              height: 25.sp,
                            ),
                            10.verticalSpace,
                            MyTextWidget(
                              LocaleKeys.video.tr(),
                              style: textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xff5D5C5D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => SinglePageChat(
                                chatId: widget.chatId,
                                fullReceiverName: widget.fullReceiverName,
                                receiverName: widget.receiverName,
                                senderName: widget.senderName,
                                dataLength: widget.dataLength,
                                senderPhoto: widget.senderPhoto,
                                receiverPhoto: widget.receiverPhoto,
                                fromSearch: true,
                                receiverPhone: widget.receiverPhone,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.searchSvg,
                              // ignore: deprecated_member_use
                              color: const Color(0xff388CFF),
                              width: 25.sp,
                              height: 25.sp,
                            ),
                            10.verticalSpace,
                            MyTextWidget(
                              LocaleKeys.search.tr(),
                              style: textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xff5D5C5D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                50.verticalSpace,
                Container(
                  height: 95.h,
                  width: 1.sw,
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F4F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: HWEdgeInsets.fromLTRB(15, 15, 20, 15),
                  margin: HWEdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.gallerySvg,
                        width: 25.sp,
                        height: 25.sp,
                      ),
                      20.horizontalSpace,
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextWidget(
                              LocaleKeys.media_files.tr(),
                              style: textTheme.displayMedium?.rq.copyWith(
                                color: const Color(0xff5D5C5D),
                              ),
                            ),
                            10.verticalSpace,
                            BlocBuilder<ChatBloc, ChatState>(
                              buildWhen: (p, c) =>
                                  p.imageCountInEachChat !=
                                      c.imageCountInEachChat ||
                                  p.fileCountInEachChat !=
                                      c.fileCountInEachChat ||
                                  p.videoCountInEachChat !=
                                      c.videoCountInEachChat,
                              builder: (context, state) {
                                return Flexible(
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.imageGallerySvg,
                                            width: 15.sp,
                                            height: 15.sp,
                                          ),
                                          5.horizontalSpace,
                                          MyTextWidget(
                                            key: TestVariables.kTestMode
                                                ? const Key(
                                                    WidgetsKeys
                                                        .imageCountInEachChatKey,
                                                  )
                                                : null,
                                            state.imageCountInEachChat
                                                .toString(),
                                            style: textTheme.titleMedium?.lq
                                                .copyWith(
                                                  color: const Color(
                                                    0xff5D5C5D,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.videoGallerySvg,
                                            width: 15.sp,
                                            height: 15.sp,
                                          ),
                                          5.horizontalSpace,
                                          MyTextWidget(
                                            key: TestVariables.kTestMode
                                                ? const Key(
                                                    WidgetsKeys
                                                        .videoCountInEachChatKey,
                                                  )
                                                : null,
                                            state.videoCountInEachChat
                                                .toString(),
                                            style: textTheme.titleMedium?.lq
                                                .copyWith(
                                                  color: const Color(
                                                    0xff5D5C5D,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.fileGallerySvg,
                                            width: 15.sp,
                                            height: 15.sp,
                                          ),
                                          5.horizontalSpace,
                                          MyTextWidget(
                                            key: TestVariables.kTestMode
                                                ? const Key(
                                                    WidgetsKeys
                                                        .fileCountInEachChatKey,
                                                  )
                                                : null,
                                            state.fileCountInEachChat
                                                .toString(),
                                            style: textTheme.titleMedium?.lq
                                                .copyWith(
                                                  color: const Color(
                                                    0xff5D5C5D,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(flex: 4),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.see_all.tr()),
                            SizedBox(width: 2.w),
                            SvgPicture.asset(
                              AppAssets.forwardArrowRight,
                              width: 10.w,
                              height: 20.h,
                            ),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MediaInProfile(files: images ?? []),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                10.verticalSpace,
                Container(
                  alignment: Alignment.center,
                  width: 1.sw - 20.w,
                  height: 150.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images!.length,
                    itemBuilder: (context, index) {
                      String mimeStr = images![index].split(" ")[0];
                      if (mimeStr.split('/').contains("video") &&
                          !mimeStr.split('.').contains("aac")) {
                        return Container(
                          margin: const EdgeInsets.all(2),
                          width: 200.w,
                          child: MYVideoPlayer(
                            videoFile: File(images![index].split(" ")[1]),
                            chatId: widget.chatId,
                          ),
                        );
                      }
                      if (mimeStr.split('/').contains("image")) {
                        return FullScreenWidget(
                          backgroundColor: const Color(0xffB4FFD9),
                          child: Hero(
                            tag: "hero${DateTime.now()}",
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 150.w,
                              height: 400.h,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(
                                    File(images![index].split(" ")[1]),
                                  ),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  width: 3.0,
                                  color: const Color(0xffB4FFD9),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
                10.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F4F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: HWEdgeInsets.fromLTRB(15, 15, 20, 15),
                  margin: HWEdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.saveToGallerySvg,
                        width: 25.sp,
                        height: 25.sp,
                      ),
                      20.horizontalSpace,
                      MyTextWidget(
                        LocaleKeys.save_to_gallery.tr(),
                        style: textTheme.displayMedium?.rq.copyWith(
                          color: const Color(0xff5D5C5D),
                        ),
                      ),
                      const Spacer(),
                      MyTextWidget(
                        LocaleKeys.never.tr(),
                        style: textTheme.displayMedium?.lq.copyWith(
                          color: const Color(0xff5D5C5D),
                        ),
                      ),
                      36.horizontalSpace,
                      Transform(
                        alignment: Alignment.center,
                        transform: (Matrix4.identity()
                          // ignore: deprecated_member_use
                          ..scale(
                            LanguageService.languageCode == 'ar' ? -1.0 : 1.0,
                            1.0,
                            1.0,
                          )),
                        child: SvgPicture.asset(
                          AppAssets.forwardArrowRight,
                          width: 3.w,
                          height: 12.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 15.h, 20.w, 0),
              child: InkWell(
                key: TestVariables.kTestMode
                    ? const Key(WidgetsKeys.backFromProfileKey)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  AppAssets.backFromCallSvg,
                  height: 20,
                  // ignore: deprecated_member_use
                  color: const Color(0xff388CFF),
                  width: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
