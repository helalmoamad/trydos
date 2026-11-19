import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/media_registry_entry.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/pages/media_in_profile.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_body.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/features/chat/presentation/widgets/delete_chat_confirm_dialog.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../common/helper/show_message.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../calls/presentation/bloc/calls_bloc.dart';
import '../../../calls/presentation/utils/caller_info.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/common/helper/dev_log.dart';

// استيرادات الشاشة القديمة المعلَّقة أدناه. تُعاد مع إعادتها:
// dart:io · flutter_svg · full_screen_image_null_safe · test_var ·
// state_ext · vedio_player · assets_provider · widgets_keys ·
// responsive_padding · language_service · my_text_widget

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
  int filess = 0;
  int videoss = 0;
  @override
  void initState() {
    super.initState();
    LastPagesTracker.push('ProfilePage');
    images = _prefsRepository.getTheLocalPathForChannel(widget.chatId) ?? [];
    chatBloc = BlocProvider.of<ChatBloc>(context);
    devLog(images);
    images!.forEach((element) {
      final MediaRegistryEntry? entry = MediaRegistryEntry.tryParse(element);
      if (entry == null) return;
      // النوع من امتداد الملف المحلي لا من شكل الرابط — الصوت (aac) يُستبعد
      // تلقائياً لأنه لا يطابق image ولا video.
      switch (HelperFunctions.mediaTypeOfPath(entry.path)) {
        case 'video':
          videoss++;
          break;
        case 'image':
          imagess++;
          break;
        case 'file':
          filess++;
          break;
      }
    });

    chatBloc.add(
      AddMediaCountEvent(images: imagess, videos: videoss, file: filess),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Posthog().capture(eventName: 'app_opened');
    });
  }

  // ===========================================================================
  // المنطق — مفصولٌ عن الشكل.
  //
  // كان كلّ نداءٍ من هذه مكتوباً داخل `onTap` في شجرة ودجتات عميقة، فاستبدال
  // الشكل كان يعني إعادة كتابة المنطق معه. استخراجه هنا يجعل التصميم الجديد
  // يستدعي نفس الكود حرفاً بحرف.
  // ===========================================================================

  /// مكالمة صوتية. تطلب الإذنين ثم تبثّ `MakeCallEvent`.
  ///
  /// `currentReceiver` يعني أن لا محادثة بعد، فيُرسَل معرّف المستقبِل؛ وغيابه
  /// يعني أن المحادثة قائمة فيكفي معرّفها.
  Future<void> startVoiceCall() async {
    try {
      final List<Map<String, dynamic>> info = callerInfo(
        channelId: widget.chatId,
      );
      final PermissionStatus microphone = await Permission.microphone.request();
      final status2 = await Permission.mediaLibrary.request();
      if (microphone.isGranted && status2.isGranted) {
        if (info[0].containsKey('currentReceiver')) {
          GetIt.I<CallsBloc>().add(
            MakeCallEvent(
              receiverUserId: info[0]['currentReceiver'].toString(),
              receiverCallName: widget.fullReceiverName,
              chatId: info[1]['channelId'],
              isVideo: false,
              payload: info[1],
            ),
          );
        } else {
          GetIt.I<CallsBloc>().add(
            MakeCallEvent(
              isVideo: false,
              receiverCallName: widget.fullReceiverName,
              chatId: info[0]['channelId'],
              payload: info[0],
            ),
          );
        }
      } else if (microphone.isDenied || status2.isDenied) {
        if (!mounted) return;
        showWarningMessage(context, LocaleKeys.permission_denied.tr());
        openAppSettings();
      }
    } catch (e, st) {
      devLog(e);
      devLog(st);
    }
  }

  /// مكالمة فيديو — كالصوتية ومعها إذن الكاميرا.
  Future<void> startVideoCall() async {
    final List<Map<String, dynamic>> info = callerInfo(
      channelId: widget.chatId,
    );
    final PermissionStatus microphone = await Permission.microphone.request();
    final status2 = await Permission.mediaLibrary.request();
    final PermissionStatus camera = await Permission.camera.request();
    if (microphone.isGranted && status2.isGranted && camera.isGranted) {
      if (info[0].containsKey('currentReceiver')) {
        GetIt.I<CallsBloc>().add(
          MakeCallEvent(
            receiverUserId: info[0]['currentReceiver'].toString(),
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
      }
    } else if (microphone.isDenied || status2.isDenied || camera.isDenied) {
      if (!mounted) return;
      showWarningMessage(context, LocaleKeys.permission_denied.tr());
      openAppSettings();
    }
  }

  /// يفتح المحادثة وبحثُها مفعَّل.
  void openSearchInChat() {
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
  }

  /// يفتح صفحة الوسائط والملفات.
  void openMediaAndFiles() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            MediaInProfile(files: images ?? [], chatId: widget.chatId),
      ),
    );
  }

  /// يحذف المحادثة بعد تأكيد — الحذف من الخادم ولا رجعة فيه.
  Future<void> deleteChat() async {
    if (!await confirmDeleteChat(context)) return;
    chatBloc.add(DeleteChatEvent(channelId: widget.chatId));
  }

  /// الطرف الآخر في هذه المحادثة، أو `null` إن لم تُوجَد.
  ///
  /// بـ`orElse` في الموضعين: `firstWhere` العارية كانت ترمي `StateError` متى
  /// فُتحت الشاشة قبل أن تصل المحادثات.
  ChannelMember? otherMember(ChatState state) {
    final Chat? chat = [
      ...state.chats,
      ...state.pinnedChats,
    ].where((element) => element.id == widget.chatId).firstOrNull;
    return chat?.channelMembers
        ?.where((element) => element.userId != _prefsRepository.myChatId)
        .firstOrNull;
  }

  bool isBlocked(ChatState state) => otherMember(state)?.isBlocked == 1;

  /// يحظر الطرف الآخر أو يرفع الحظر.
  void toggleBlock(ChatState state) {
    final ChannelMember? member = otherMember(state);
    if (member == null) return;
    chatBloc.add(
      BlockOrDeleteBlockUserEvent(
        receiverUserId: member.userId.toString(),
        isBlock: member.isBlocked == 0,
        channelId: widget.chatId,
      ),
    );
  }

  /// يشارك الاسم والرقم بورقة مشاركة النظام.
  ///
  /// الملف يرسم الكلمة ولا يعطيها فعلاً، لكن المشاركة لا تحتاج خادماً: ما
  /// يلزمها الاسم والرقم وهما بين يدينا. فتعمل بلا انتظار الطرف الخلفي.
  Future<void> shareContact() async {
    final String phone = widget.receiverPhone;
    await SharePlus.instance.share(
      ShareParams(
        text: phone.isEmpty
            ? widget.fullReceiverName
            : '${widget.fullReceiverName}\n$phone',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // أبيض كما في الويب (`ScreenPage`)، لا `#F8F8F8` القديم.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            return ContactProfileBody(
              photo: _photo(),
              name: widget.fullReceiverName,
              phone: widget.receiverPhone,
              isBlocked: isBlocked(state),
              // ثابتٌ كما في الديمو: لا طلب عندنا لتفعيل المكالمة أو
              // تعطيلها، والويب نفسه يرسم السطر بلا فعل.
              isCallEnabled: true,
              onBack: () => Navigator.pop(context),
              onCall: startVoiceCall,
              onVideo: startVideoCall,
              onSearch: openSearchInChat,
              onMedia: openMediaAndFiles,
              onDeleteChat: deleteChat,
              onToggleBlock: () => toggleBlock(state),
              onShare: shareContact,
              // «دائماً» في الصفّين كلاهما قيمةٌ ثابتة في الملف أيضاً
              // (`value="ALWAYS"` على الصفّين في `ContactScreen.tsx`)، لا
              // إعدادٌ يُقرأ أو يُبدَّل. فتبقى كما هي حتى يصير لها إعداد.
              saveToGalleryValue: LocaleKeys.always.tr(),
              notificationValue: LocaleKeys.always.tr(),
            );
          },
        ),
      ),
    );
  }

  /// صورة الطرف الآخر، أو أوّل حرفين من اسمه حين لا صورة له.
  /// الحرفان من اسمٍ — أوّل حرفٍ من أوّل كلمتين.
  String _initials(String name) {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.characters.take(1).toString().toUpperCase();
    }
    return (words[0].characters.take(1).toString() +
            words[1].characters.take(1).toString())
        .toUpperCase();
  }

  Widget _photo() {
    if (widget.receiverPhoto == null) {
      // الحرفان كما يرسمهما الملف: 28 Medium على خطّ أساس 85 بحبرٍ عاديّ على
      // خلفيّة `C.field`. وكان `NoImageWidget` يرسمهما بنفسجيَّين بمقاس
      // آخر — من التصميم القديم.
      return Container(
        color: const Color(0xFFF8F8F8),
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: ContactDesign.textTop(85, 28).h),
        child: DesignText(
          _initials(widget.receiverName),
          size: 28,
          family: 'Quicksand-Medium',
          center: true,
        ),
      );
    }
    return MyCachedNetworkImage(
      imageUrl:
          (widget.receiverPhoto.toString().contains("media_server")
              ? ""
              : "${dotenv.env['Media_S3_Server']}") +
          widget.receiverPhoto!,
      imageFit: BoxFit.cover,
      progressIndicatorBuilderWidget: TrydosLoader(),
      height: 150.h,
      width: 131.w,
    );
  }

  // ===========================================================================
  // الشاشة القديمة — معلَّقة لا محذوفة.
  //
  // استُبدلت بالتصميم الجديد المنقول من الويب. تبقى هنا لأن فيها عنصراً لا
  // مقابل له في التصميم: معاينة الوسائط بالصور المصغّرة و«عرض الكل» داخل صفّ
  // `Media & Files`. التصميم يكتفي بالصفّ وحده، والمعاينة ما زالت تعمل من
  // صفحة `MediaInProfile` التي يفتحها الصفّ.
  //
  // منطقها كلّه مستخرَجٌ أعلاه في دوالّ مسمّاة، فلا شيء فيها إلّا الشكل.
  // ===========================================================================
  /*
  Widget _legacyBuild(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: Stack(
          alignment: LanguageService.languageCode == 'ar'
              ? AlignmentDirectional.topEnd
              : AlignmentDirectional.topStart,
          children: [
            SingleChildScrollView(
              child: Column(
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
                                          "media_server",
                                        )
                                        ? ""
                                        : "${dotenv.env['Media_S3_Server']}") +
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
                              devLog(e);
                              devLog(st);
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
                            var status2 = await Permission.mediaLibrary
                                .request();
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
                                  MediaInProfile(
                                    files: images ?? [],
                                    chatId: widget.chatId,
                                  ),
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
                        final MediaRegistryEntry? entry =
                            MediaRegistryEntry.tryParse(images![index]);
                        if (entry == null) return const SizedBox.shrink();
                        final String mediaType =
                            HelperFunctions.mediaTypeOfPath(entry.path);
                        if (mediaType == 'video') {
                          return Container(
                            margin: const EdgeInsets.all(2),
                            width: 200.w,
                            // يُمرَّر الرابط دائماً والملف **إن وُجد** فقط.
                            // ملفات المخزن قد يحذفها التنظيف الدوري بينما يبقى
                            // مدخلها في السجلّ؛ وتمرير مسار غير موجود كان
                            // يُفشل تهيئة المشغّل فيظهر مربّع صامت. مع الرابط
                            // يعود المشغّل إلى مصغَّره وزرّ التنزيل تلقائياً.
                            child: MYVideoPlayer(
                              videoFile: File(entry.path).existsSync()
                                  ? File(entry.path)
                                  : null,
                              videoUrl: entry.url,
                              chatId: widget.chatId,
                            ),
                          );
                        }
                        if (mediaType == 'image') {
                          return FullScreenWidget(
                            backgroundColor: const Color(0xffB4FFD9),
                            child: Hero(
                              tag: "hero${DateTime.now()}",
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                width: 150.w,
                                height: 400.h,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  // خلفية صريحة: مع DecorationImage كان فشل
                                  // الرسم يترك الإطار شفافاً فيبدو أبيض.
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    width: 3.0,
                                    color: const Color(0xffB4FFD9),
                                  ),
                                ),
                                // الملف المحلي قد يحذفه تنظيف المخزن بينما
                                // يبقى مدخله في السجلّ. عندها نستعيد الصورة من
                                // رابطها بدل عرض فراغ صامت.
                                child: File(entry.path).existsSync()
                                    ? Image.file(
                                        File(entry.path),
                                        fit: BoxFit.fill,
                                        errorBuilder: (_, __, ___) =>
                                            MyCachedNetworkImage(
                                              imageUrl: entry.url,
                                              imageFit: BoxFit.fill,
                                              width: 150.w,
                                              height: 400.h,
                                            ),
                                      )
                                    : MyCachedNetworkImage(
                                        imageUrl: entry.url,
                                        imageFit: BoxFit.fill,
                                        width: 150.w,
                                        height: 400.h,
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
                  SizedBox(
                    height: 90,
                    width: 1.sw,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BlocListener<ChatBloc, ChatState>(
                          listenWhen: (previous, current) =>
                              previous.deleteChatStatus !=
                              current.deleteChatStatus,

                          listener: (context, state) {
                            if (state.deleteChatStatus ==
                                DeleteChatStatus.success) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          },
                          child: BlocBuilder<ChatBloc, ChatState>(
                            buildWhen: (previous, current) =>
                                previous.deleteChatStatus !=
                                current.deleteChatStatus,
                            builder: (context, state) {
                              return SizedBox(
                                width: 80,
                                height: 80,
                                child:
                                    state.deleteChatStatus ==
                                        DeleteChatStatus.loading
                                    ? Center(child: TrydosLoader(size: 20))
                                    : InkWell(
                                        onTap: () async {
                                          // الحذف يمسح الدردشة من السيرفر ولا
                                          // رجعة فيه، فنسأل قبله.
                                          if (!await confirmDeleteChat(
                                            context,
                                          )) {
                                            return;
                                          }
                                          chatBloc.add(
                                            DeleteChatEvent(
                                              channelId: widget.chatId,
                                            ),
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 80,
                                              width: 80,
                                              child: Column(
                                                children: [
                                                  SvgPicture.asset(
                                                    AppAssets.deletecartSvg,

                                                    // ignore: deprecated_member_use
                                                    color: const Color.fromARGB(
                                                      255,
                                                      255,
                                                      3,
                                                      3,
                                                    ),
                                                    height: 30,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  MyTextWidget(
                                                    LocaleKeys.delete_chat.tr(),
                                                    style: textTheme
                                                        .displayMedium
                                                        ?.lq
                                                        .copyWith(
                                                          color: const Color(
                                                            0xff5D5C5D,
                                                          ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        BlocBuilder<ChatBloc, ChatState>(
                          buildWhen: (previous, current) =>
                              previous.blockOrDeleteBlockUserStatus !=
                              current.blockOrDeleteBlockUserStatus,
                          builder: (context, state) {
                            return SizedBox(
                              width: 80,
                              height: 80,
                              child:
                                  state.blockOrDeleteBlockUserStatus ==
                                      BlockOrDeleteBlockUserStatus.loading
                                  ? Center(child: TrydosLoader(size: 20))
                                  : InkWell(
                                      onTap: () {
                                        chatBloc.add(
                                          BlockOrDeleteBlockUserEvent(
                                            receiverUserId: state.chats
                                                .firstWhere(
                                                  (element) =>
                                                      element.id ==
                                                      widget.chatId,
                                                  orElse: () => state
                                                      .pinnedChats
                                                      .firstWhere(
                                                        (element) =>
                                                            element.id ==
                                                            widget.chatId,
                                                      ),
                                                )
                                                .channelMembers
                                                ?.firstWhere(
                                                  (element) =>
                                                      element.userId !=
                                                      GetIt.I<PrefsRepository>()
                                                          .myChatId,
                                                )
                                                .userId
                                                .toString(),
                                            isBlock:
                                                state.chats
                                                    .firstWhere(
                                                      (element) =>
                                                          element.id ==
                                                          widget.chatId,
                                                      orElse: () => state
                                                          .pinnedChats
                                                          .firstWhere(
                                                            (element) =>
                                                                element.id ==
                                                                widget.chatId,
                                                          ),
                                                    )
                                                    .channelMembers
                                                    ?.firstWhere(
                                                      (element) =>
                                                          element.userId !=
                                                          GetIt.I<
                                                                PrefsRepository
                                                              >()
                                                              .myChatId,
                                                    )
                                                    .isBlocked ==
                                                0,
                                            channelId: widget.chatId,
                                          ),
                                        );
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 80,
                                            width: 80,
                                            child: Column(
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.blockSvg,
                                                  // ignore: deprecated_member_use
                                                  color: const Color.fromARGB(
                                                    255,
                                                    255,
                                                    3,
                                                    3,
                                                  ),
                                                  height: 30,
                                                ),
                                                const SizedBox(height: 5),
                                                MyTextWidget(
                                                  state.chats
                                                              .firstWhere(
                                                                (element) =>
                                                                    element
                                                                        .id ==
                                                                    widget
                                                                        .chatId,
                                                                orElse: () => state
                                                                    .pinnedChats
                                                                    .firstWhere(
                                                                      (
                                                                        element,
                                                                      ) =>
                                                                          element
                                                                              .id ==
                                                                          widget
                                                                              .chatId,
                                                                    ),
                                                              )
                                                              .channelMembers
                                                              ?.firstWhere(
                                                                (element) =>
                                                                    element
                                                                        .userId !=
                                                                    GetIt.I<
                                                                          PrefsRepository
                                                                        >()
                                                                        .myChatId,
                                                              )
                                                              .isBlocked ==
                                                          1
                                                      ? LocaleKeys.un_block.tr()
                                                      : LocaleKeys.block.tr(),
                                                  style: textTheme
                                                      .displayMedium
                                                      ?.lq
                                                      .copyWith(
                                                        fontSize: 14,
                                                        color: const Color(
                                                          0xff5D5C5D,
                                                        ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        ),
      ),
    );
  }
  */
}
