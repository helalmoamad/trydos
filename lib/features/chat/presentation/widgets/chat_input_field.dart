import 'dart:async';
import 'dart:developer';
import 'dart:io';
// `easy_localization` يصدّر `TextDirection` خاصّته (من `intl`) فيحجب التي في
// Flutter، والمطلوب هنا اتجاه الودجت لقياس سحب التسجيل.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_icons_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/composer_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/toast_v2.dart';
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
import '../../../../common/helper/show_message.dart';
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
import 'chat_image_preview_widget.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    Key? key,
    required this.onSendMessage,
    required this.onSendFile,
    required this.channelId,
    required this.senderName,
    required this.senderUserImage,
    this.receiverName = '',
  }) : super(key: key);
  final void Function(String message) onSendMessage;
  final void Function(File file, String type) onSendFile;
  final String channelId;
  final String? senderUserImage;
  final String senderName;

  /// اسم الطرف الآخر — تكتبه حبّةُ الردّ حين يكون الردُّ على رسالته.
  final String receiverName;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ThemeState<ChatInputField>
    with FormStateMinxin {
  final ValueNotifier<bool> thereTextNotifier = ValueNotifier(false);
  final ValueNotifier<bool> recordingNotifier = ValueNotifier(false);
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  Timer _typingTimer = Timer(const Duration(microseconds: 1), () {});

  // متغيرات إدارة معاينة الصورة
  bool _showImagePreview = false;
  File? _imageToPreview;

  // دوال معالجة معاينة الصورة
  void _showImagePreviewScreen(File image) {
    if (mounted) {
      // إخفاء لوحة المفاتيح أولاً
      FocusScope.of(context).unfocus();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _imageToPreview = image;
            _showImagePreview = true;
          });
        }
      });
    }
  }

  void _hideImagePreview() {
    if (mounted) {
      setState(() {
        _showImagePreview = false;
        _imageToPreview = null;
      });

      // إعادة التركيز على حقل النص بعد إغلاق المعاينة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      form.controllers[0].addListener(() {
        thereTextNotifier.value =
            form.controllers[0].text.isNotEmpty &&
            form.controllers[0].text.replaceAll(" ", "").length > 0;
      });
    });
    //initializeRecorder();
    super.initState();
  }

  bool recorderReady = false;
  bool _isInitializing = false;

  // ===========================================================================
  // إيماءة التسجيل، كما في الويب (`Composer.tsx`):
  //
  // > اضغط الميكروفون مطوّلاً، فيتحوّل الحقل إلى نقطةٍ حمراء نابضة وساعةٍ مع
  // > «‹ اسحب للإلغاء»؛ أفلِت لترسل، واسحب يساراً لتُلغي.
  //
  // وثلاثة شروط من الملف: السحب يُحسب نحو البداية وحدها، والإلغاء عند 90،
  // وضغطةٌ أقصر من 600 لا تُرسل شيئاً بل تُنبّه «اضغط مطوّلاً».
  // ===========================================================================

  /// س إصبعِ البداية، لقياس السحب منه.
  double _recordStartX = 0;

  /// لحظة بدء الضغط — منها تُحسب المدّة والساعة.
  DateTime? _recordSince;

  /// ما سحبه الإصبع نحو البداية، سالباً. يبدأ صفراً.
  double _recordSlide = 0;

  /// الساعة تُحدَّث كل نصف ثانية أثناء الضغط.
  Timer? _recordTicker;

  /// التسجيل أُلغي بالسحب، فإفلات الإصبع بعده لا يُرسل.
  bool _recordCancelled = false;

  /// ما يُعرض الآن من حالة التسجيل، أو `null` إن لم يكن تسجيلٌ جارياً.
  ComposerRecording? get _recordingState {
    final DateTime? since = _recordSince;
    if (since == null) return null;
    return ComposerRecording(
      elapsed: DateTime.now().difference(since),
      slide: _recordSlide,
    );
  }

  /// الإصبع نزل على الميكروفون: يبدأ التسجيل فوراً.
  ///
  /// الإذن والتهيئة قد يتأخّران، فتُفتح الساعة قبلهما ليرى المستخدم استجابةً
  /// فورية كما في الويب. وإن رُفض الإذن يُطوى الشريط.
  Future<void> _onRecordDown(Offset position) async {
    _recordStartX = position.dx;
    _recordCancelled = false;
    _recordSlide = 0;
    _recordSince = DateTime.now();
    _recordTicker?.cancel();
    _recordTicker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted && _recordSince != null) setState(() {});
    });
    setState(() {});

    if (!recorderReady) {
      final bool ready = await initializeRecorder();
      if (!ready) {
        _endRecordingUi();
        return;
      }
    }
    // أُفلِت الإصبع أو أُلغي قبل أن تجهز التهيئة.
    if (_recordSince == null) return;
    if (recorder.isRecording) return;

    FirebasePresence.sendUserTransaction(
      channelId: widget.channelId,
      description: LocaleKeys.recording.tr(),
    );
    await recorder.startRecorder(toFile: 'audio${const Uuid().v4()}.aac');
  }

  /// الإصبع يتحرّك: السحب نحو البداية وحده، والإلغاء عند 90.
  void _onRecordMove(Offset position) {
    if (_recordSince == null || _recordCancelled) return;
    // الاتجاه منطقيٌّ لا هندسي: «يساراً» في الإنجليزية هي «يميناً» في
    // العربية. والقياس بجهة البداية يجعل الإيماءة واحدةً في اللغتين.
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double raw = position.dx - _recordStartX;
    final double towardStart = rtl ? -raw : raw;
    final double slide = towardStart > 0 ? 0 : towardStart;

    if (slide <= -ComposerV2.cancelSlide) {
      _recordCancelled = true;
      _discardRecording();
      return;
    }
    setState(() => _recordSlide = rtl ? -slide : slide);
  }

  /// الإصبع أُفلِت: يُرسل إن طال الضغط، ويُنبّه إن قصُر.
  Future<void> _onRecordUp() async {
    final DateTime? since = _recordSince;
    if (since == null || _recordCancelled) return;
    final Duration held = DateTime.now().difference(since);
    _endRecordingUi();

    if (held < ComposerV2.minRecord) {
      await _stopAndDeleteRecording();
      if (mounted) ToastV2.show(context, LocaleKeys.hold_to_record.tr());
      return;
    }

    FirebasePresence.deleteUserTransaction(channelId: widget.channelId);

    // الإصبع قد يُفلَت قبل أن يتمّ `startRecorder` — فتهيئةُ المسجّل تطلب
    // إذناً وتستغرق وقتاً. وإيقافُ مسجّلٍ لم يبدأ يرمي، فنتثبّت أوّلاً.
    if (!recorderReady || !recorder.isRecording) return;
    final String? path = await _stopRecorderSafely();
    if (path == null) return;
    widget.onSendFile(File(path), 'voice');
  }

  /// يُلغي التسجيل ويمحو ملفّه.
  Future<void> _discardRecording() async {
    _endRecordingUi();
    FirebasePresence.deleteUserTransaction(channelId: widget.channelId);
    await _stopAndDeleteRecording();
  }

  Future<void> _stopAndDeleteRecording() async {
    final String? path = await _stopRecorderSafely();
    if (path != null) recorder.deleteRecord(fileName: path);
  }

  /// يوقف المسجّل ويُرجع مسار ملفّه، أو `null` إن لم يكن يسجّل.
  ///
  /// المسجّل قد يكون في طور التهيئة حين يُفلَت الإصبع — فإيقافه حينها يرمي.
  Future<String?> _stopRecorderSafely() async {
    if (!recorderReady || !recorder.isRecording) return null;
    try {
      return await recorder.stopRecorder();
    } catch (e) {
      debugPrint('stopRecorder: $e');
      return null;
    }
  }

  /// يطوي شريط التسجيل ويوقف ساعته.
  void _endRecordingUi() {
    _recordTicker?.cancel();
    _recordTicker = null;
    _recordSince = null;
    _recordSlide = 0;
    if (mounted) setState(() {});
  }

  Future<bool> initializeRecorder() async {
    if (recorderReady || _isInitializing) return recorderReady;
    _isInitializing = true;

    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
      await recorder.openRecorder();
      if (!mounted) {
        await recorder.closeRecorder();
        return false;
      }
      await recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
      recorderReady = true;
      return true;
    } catch (e) {
      debugPrint("Recorder initialization error: $e");
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    if (recorderReady) {
      recorder.closeRecorder();
    }
    _typingTimer.cancel();
    _recordTicker?.cancel();
    super.dispose();
  }

  /// غلاف شريط التسجيل: حبّة 38 بنصف قطر 12 ولون `#F8F8F8`، كما في الملف.
  ///
  /// وما داخلها يبقى كما هو — المؤقّت والموجات وزرّا الإلغاء والإرسال. الويب
  /// يُلغي بالسحب ويُرسل بالإفلات، وتسجيلُنا لا يعرف هذه الإيماءة، فتبديلُ
  /// الزرّين بها تغييرُ سلوكٍ لا تلوينُ شكل — يُترك لمهمّةٍ على حدة.
  Widget _recordingShell(Widget child) {
    if (!kChatDesignV2) return child;
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }

  /// حبّة الاقتباس فوق الشريط: الردُّ المعروض أثناء الكتابة.
  ///
  /// صاحبُ الرسالة المقتبسة لا **مُرسِلُ** الردّ: `replyOnMe` يقول إن
  /// الرسالة لي فيُكتب «أنا»، وإلّا فاسم الطرف الآخر. وكان يُكتب اسمي في
  /// الحالتين لأن `senderName` اسمي أنا.
  Widget _replyPill(AppState state) {
    return Container(
      width: 1.sw,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: ChatDesign.headerShadow,
      ),
      // 5 تحتها: بلاها تلتصق بحقل الكتابة.
      padding: EdgeInsets.only(bottom: 5.h),
      child: ComposerContextBarV2(
        data: ComposerReply(
          name: state.replyOnMe ? LocaleKeys.me.tr() : widget.receiverName,
          text: state.message.toString(),
        ),
        onClose: () => BlocProvider.of<AppBloc>(
          context,
        ).add(RefreshChatInputField(false, '', false)),
      ),
    );
  }

  /// القرص البنفسجي في نهاية الشريط: 38 دائريٌّ، يحمل الميكروفون ما دام
  /// الحقل فارغاً وسهم الإرسال متى صارت فيه حروف. أرقامه من `composer_v2.dart`.
  Widget _roundPurpleButton(Widget icon) {
    return Container(
      width: 38.w,
      height: 38.h,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: ContactDesign.purple,
        shape: BoxShape.circle,
      ),
      child: icon,
    );
  }

  /// يفتح منتقي الصور والفيديو — الكاميرا أو المعرض.
  ///
  /// مُستخرَجةٌ من `onTap` الكاميرا كما كانت، بلا تغيير في عملها: التصميم
  /// الجديد يضع الكاميرا **داخل** الحقل والقديم يضعها بجانبه، فلزم موضعان
  /// لفعلٍ واحد. والاستخراج أولى من نسخ مئة سطر في الموضعين.
  void _pickPhotoOrVideo() {
    FirebasePresence.sendUserTransaction(
      channelId: widget.channelId,
      description: LocaleKeys.sending_file.tr(),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GalleryAndCameraDialogWidget(
          fromChat: true,
          onChooseFileFromGalleryAction: (AssetEntity? assetEntity) async {
            if (assetEntity != null) {
              // originFile يرجع null للملفات غير المقروءة.
              final File? pickedFile = await assetEntity.originFile;
              if (pickedFile == null) {
                if (!context.mounted) return;
                showWarningMessage(context, LocaleKeys.error_picking_file.tr());
                return;
              }
              File file = pickedFile;
              String mimeStr = lookupMimeType(file.absolute.path) ?? '';
              var fileType = mimeStr.split('/');
              log(fileType.toString());
              if (fileType[0] == 'image') {
                widget.onSendFile.call(file, 'image');
              } else {
                widget.onSendFile.call(file, 'video');
              }
            }
          },
          onChooseFileFromCameraAction: (File? file) {
            if (file != null) {
              String mimeStr = lookupMimeType(file.absolute.path) ?? '';
              var fileType = mimeStr.split('/');
              log(fileType.toString());
              if (fileType[0] == 'image') {
                widget.onSendFile.call(file, 'image');
              } else {
                widget.onSendFile.call(file, 'video');
              }
            }
          },
          onImagePreviewAction: (File image) {
            _showImagePreviewScreen(image);
          },
        );
      },
    ).then((value) {
      FirebasePresence.deleteUserTransaction(channelId: widget.channelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (p, c) =>
          p.thereIsReply != c.thereIsReply || p.messageId != c.messageId,
      builder: (context, state) {
        debugPrint('imageUrl:  ${state.imageUrl}');

        return SafeArea(
          child: Container(
            // Add bottom padding to account for keyboard (إلا عند عرض المعاينة)
            padding: EdgeInsets.only(
              bottom: _showImagePreview
                  ? 0
                  : MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // شاشة معاينة الصورة
                if (_showImagePreview && _imageToPreview != null)
                  ChatImagePreviewWidget(
                    imageFile: _imageToPreview!,
                    onSend: (File file) {
                      widget.onSendFile.call(file, 'image');
                      _hideImagePreview();
                    },
                    onCancel: _hideImagePreview,
                  ),
                // حبّة الاقتباس فوق الحقل بالتصميم الجديد: بنفسجيةٌ من خارج
                // و`#EFEBFF` من داخل، فيها الاسم والحروف وعلامة الإغلاق.
                // وكانت شريطاً أخضر بارتفاع 103.
                if (!kChatDesignV2 && state.thereIsReply)
                  Container(
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
                          color: const Color.fromARGB(
                            41,
                            255,
                            255,
                            255,
                          ).withValues(),
                          //                              colorScheme.black.withOpacity(0.16)
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: state.replyType == 'text'
                          ? Row(
                              key: TestVariables.kTestMode
                                  ? const Key(WidgetsKeys.replayTextKey)
                                  : null,
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
                                      RefreshChatInputField(false, '', false),
                                    );
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
                                    style: textTheme.titleMedium?.lq.copyWith(
                                      color: colorScheme.grey200,
                                      height: 1.66,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                10.horizontalSpace,
                                widget.senderUserImage != null
                                    ? MyCachedNetworkImage(
                                        imageUrl:
                                            (widget.senderUserImage
                                                    .toString()
                                                    .contains("media_server")
                                                ? ""
                                                : "${dotenv.env['Media_S3_Server']}") +
                                            widget.senderUserImage!,
                                        imageFit: BoxFit.cover,
                                        progressIndicatorBuilderWidget:
                                            TrydosLoader(),
                                        radius: 8,
                                        width: 30.sp,
                                        height: 30.sp,
                                      )
                                    : NoImageWidget(
                                        width: 30.sp,
                                        height: 30.sp,
                                        textStyle: context
                                            .textTheme
                                            .titleMedium
                                            ?.bq
                                            .copyWith(
                                              color: const Color(0xff6638FF),
                                              letterSpacing: 0.18,
                                              height: 1.33,
                                            ),
                                        radius: 8,
                                        name: widget.senderName,
                                      ),
                                20.horizontalSpace,
                              ],
                            )
                          : state.replyType == 'image'
                          ? Row(
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
                                      RefreshChatInputField(false, '', false),
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.closeSvg,
                                    width: 15.w,
                                    height: 15,
                                  ),
                                ),
                                20.horizontalSpace,
                                state.imageUrl?.contains('trydos.s3') ?? false
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
                                              File(state.imageUrl!),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromARGB(1, 0, 0, 0),
                                              //                                                  context
                                              //                                                      .colorScheme.black
                                              //                                                      .withOpacity(0.05)
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                10.horizontalSpace,
                                MyTextWidget(
                                  LocaleKeys.photo.tr(),
                                  style: textTheme.titleMedium?.lq.copyWith(
                                    color: colorScheme.grey200,
                                    height: 1.66,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                widget.senderUserImage != null
                                    ? MyCachedNetworkImage(
                                        imageUrl:
                                            (widget.senderUserImage
                                                    .toString()
                                                    .contains("media_server")
                                                ? ""
                                                : "${dotenv.env['Media_S3_Server']}") +
                                            widget.senderUserImage!,
                                        imageFit: BoxFit.cover,
                                        progressIndicatorBuilderWidget:
                                            TrydosLoader(),
                                        radius: 8,
                                        width: 30.sp,
                                        height: 30.sp,
                                      )
                                    : NoImageWidget(
                                        width: 30.sp,
                                        height: 30.sp,
                                        textStyle: context
                                            .textTheme
                                            .titleMedium
                                            ?.bq
                                            .copyWith(
                                              color: const Color(0xff6638FF),
                                              letterSpacing: 0.18,
                                              height: 1.33,
                                            ),
                                        radius: 8,
                                        name: widget.senderName,
                                      ),
                                20.horizontalSpace,
                              ],
                            )
                          : state.replyType == 'product'
                          ? Row(
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
                                      RefreshChatInputField(false, '', false),
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.closeSvg,
                                    width: 15.w,
                                    height: 15,
                                  ),
                                ),
                                20.horizontalSpace,
                                state.imageUrl?.contains('trydos.s3') ?? false
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
                                              File(state.imageUrl!),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromARGB(1, 0, 0, 0),
                                              //                                                  context
                                              //                                                      .colorScheme.black
                                              //                                                      .withOpacity(0.05)
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                10.horizontalSpace,
                                MyTextWidget(
                                  LocaleKeys.product.tr(),
                                  style: textTheme.titleMedium?.lq.copyWith(
                                    color: colorScheme.grey200,
                                    height: 1.66,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                widget.senderUserImage != null
                                    ? MyCachedNetworkImage(
                                        imageUrl:
                                            (widget.senderUserImage
                                                    .toString()
                                                    .contains("media_server")
                                                ? ""
                                                : "${dotenv.env['Media_S3_Server']}") +
                                            widget.senderUserImage!,
                                        imageFit: BoxFit.cover,
                                        progressIndicatorBuilderWidget:
                                            TrydosLoader(),
                                        radius: 8,
                                        width: 30.sp,
                                        height: 30.sp,
                                      )
                                    : NoImageWidget(
                                        width: 30.sp,
                                        height: 30.sp,
                                        textStyle: context
                                            .textTheme
                                            .titleMedium
                                            ?.bq
                                            .copyWith(
                                              color: const Color(0xff6638FF),
                                              letterSpacing: 0.18,
                                              height: 1.33,
                                            ),
                                        radius: 8,
                                        name: widget.senderName,
                                      ),
                                20.horizontalSpace,
                              ],
                            )
                          : state.replyType == 'file'
                          ? Row(
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
                                      RefreshChatInputField(false, '', false),
                                    );
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
                                    style: textTheme.titleMedium?.lq.copyWith(
                                      color: colorScheme.grey200,
                                      height: 1.66,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                widget.senderUserImage != null
                                    ? MyCachedNetworkImage(
                                        imageUrl:
                                            (widget.senderUserImage
                                                    .toString()
                                                    .contains("media_server")
                                                ? ""
                                                : "${dotenv.env['Media_S3_Server']}") +
                                            widget.senderUserImage!,
                                        imageFit: BoxFit.cover,
                                        progressIndicatorBuilderWidget:
                                            TrydosLoader(),
                                        radius: 8,
                                        width: 30.sp,
                                        height: 30.sp,
                                      )
                                    : NoImageWidget(
                                        width: 30.sp,
                                        height: 30.sp,
                                        textStyle: context
                                            .textTheme
                                            .titleMedium
                                            ?.bq
                                            .copyWith(
                                              color: const Color(0xff6638FF),
                                              letterSpacing: 0.18,
                                              height: 1.33,
                                            ),
                                        radius: 8,
                                        name: widget.senderName,
                                      ),
                                20.horizontalSpace,
                              ],
                            )
                          : state.replyType == 'video'
                          ? Row(
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
                                      RefreshChatInputField(false, '', false),
                                    );
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
                                    style: textTheme.titleMedium?.lq.copyWith(
                                      color: colorScheme.grey200,
                                      height: 1.66,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                widget.senderUserImage != null
                                    ? MyCachedNetworkImage(
                                        imageUrl:
                                            (widget.senderUserImage
                                                    .toString()
                                                    .contains("media_server")
                                                ? ""
                                                : "${dotenv.env['Media_S3_Server']}") +
                                            widget.senderUserImage!,
                                        imageFit: BoxFit.cover,
                                        withImageShadow: true,
                                        progressIndicatorBuilderWidget:
                                            TrydosLoader(),
                                        radius: 8,
                                        width: 30.sp,
                                        height: 30.sp,
                                      )
                                    : NoImageWidget(
                                        width: 30.sp,
                                        height: 30.sp,
                                        textStyle: context
                                            .textTheme
                                            .titleMedium
                                            ?.bq
                                            .copyWith(
                                              color: const Color(0xff6638FF),
                                              letterSpacing: 0.18,
                                              height: 1.33,
                                            ),
                                        radius: 8,
                                        name: widget.senderName,
                                      ),
                                20.horizontalSpace,
                              ],
                            )
                          : Row(
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
                                      RefreshChatInputField(false, '', false),
                                    );
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
                                  style: textTheme.titleMedium?.lq.copyWith(
                                    color: colorScheme.grey200,
                                    height: 1.66,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                widget.senderUserImage != null
                                    ? MyCachedNetworkImage(
                                        imageUrl:
                                            (widget.senderUserImage
                                                    .toString()
                                                    .contains("media_server")
                                                ? widget.senderUserImage!
                                                : "${dotenv.env['Media_S3_Server']}") +
                                            widget.senderUserImage!,
                                        imageFit: BoxFit.cover,
                                        radius: 8,
                                        progressIndicatorBuilderWidget:
                                            TrydosLoader(),
                                        width: 30.sp,
                                        height: 30.sp,
                                      )
                                    : NoImageWidget(
                                        width: 30.sp,
                                        height: 30.sp,
                                        textStyle: context
                                            .textTheme
                                            .titleMedium
                                            ?.bq
                                            .copyWith(
                                              color: const Color(0xff6638FF),
                                              letterSpacing: 0.18,
                                              height: 1.33,
                                            ),
                                        radius: 8,
                                        name: widget.senderName,
                                      ),
                                20.horizontalSpace,
                              ],
                            ),
                    ),
                  ),
                // الحبّة **فوق** الشريط لا خلفه.
                //
                // `Stack` يجعلهما شقيقين متراكبين عند الأسفل: الحبّة القديمة
                // بارتفاع 103 كانت تعلو الشريط فتُرى، وحبّةُ التصميم الجديد
                // قصيرةٌ فتختفي خلفه تماماً. والعمود يضعها فوقه كما في الملف.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (kChatDesignV2 && state.thereIsReply) _replyPill(state),
                    ValueListenableBuilder<bool>(
                      valueListenable: thereTextNotifier,
                      builder: (context, thereText, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: recordingNotifier,
                          builder: (context, recording, _) {
                            return Container(
                              // شريط التصميم الجديد: 54 أبيض بظلّ الترويسة
                              // `0 0 3` أسود 10٪، بدل 50 رمادية `#F6F6F6`.
                              // الأرقام من `composer_v2.dart`.
                              // 54 حدٌّ أدنى لا ثابت: الحقل يكبر إلى خمسة أسطر
                              // فيكبر الشريط معه، كما في الويب.
                              constraints: kChatDesignV2
                                  ? BoxConstraints(
                                      minHeight: ComposerV2.height.h,
                                    )
                                  : const BoxConstraints.tightFor(height: 50),
                              width: 1.sw,
                              decoration: kChatDesignV2
                                  ? const BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: ChatDesign.headerShadow,
                                    )
                                  : const BoxDecoration(
                                      color: Color(0xffF6F6F6),
                                    ),
                              padding: kChatDesignV2
                                  ? EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 8.h,
                                    )
                                  : EdgeInsets.zero,
                              // شريط التصميم الجديد يظهر بإيماءة الإمساك، وشريط
                              // التصميم القديم بـ`recordingNotifier`.
                              child: kChatDesignV2 && _recordingState != null
                                  ? RecordingStripV2(
                                      recording: _recordingState!,
                                      slideToCancelText: LocaleKeys
                                          .slide_to_cancel
                                          .tr(),
                                    )
                                  : recording
                                  ? _recordingShell(
                                      Row(
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
                                                  HelperFunctions.twoDigits(
                                                    duration.inSeconds
                                                        .remainder(60),
                                                  );

                                              return MyTextWidget(
                                                '$minutes:$seconds',
                                                style: textTheme.bodyMedium?.rq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff404040,
                                                      ),
                                                      letterSpacing: 0.18,
                                                      height: 1.11,
                                                    ),
                                              );
                                            },
                                          ),
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
                                                  (await recorder
                                                      .stopRecorder())!;
                                              recorder.deleteRecord(
                                                fileName: path,
                                              );
                                            },
                                            child: MyTextWidget(
                                              LocaleKeys.cansel.tr(),
                                              style: textTheme.titleLarge?.rq
                                                  .copyWith(
                                                    letterSpacing: 0.14,
                                                    height: 1.4285714285714286,
                                                    color: const Color(
                                                      0xff404040,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            focusColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            onTap: () async {
                                              final path = await recorder
                                                  .stopRecorder();
                                              final audioFile = File(path!);
                                              FirebasePresence.deleteUserTransaction(
                                                channelId: widget.channelId,
                                              );
                                              widget.onSendFile(
                                                audioFile,
                                                'voice',
                                              );
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
                                      ),
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
                                              description: LocaleKeys
                                                  .sending_file
                                                  .tr(),
                                            );
                                            File? file =
                                                await HelperFunctions.pickDocumentFile();
                                            FirebasePresence.deleteUserTransaction(
                                              channelId: widget.channelId,
                                            );
                                            if (file != null) {
                                              // المنتقي من نوع any، فقد يعود
                                              // بصورة أو فيديو. يُعامَل كلٌّ بنوعه
                                              // بدل إرساله مستنداً: الصورة تمرّ
                                              // بالمعاينة أولاً، والفيديو يُرسل
                                              // رسالةَ فيديو، وما عداهما مستند.
                                              switch (HelperFunctions.mediaTypeOfPath(
                                                file.path,
                                              )) {
                                                case 'image':
                                                  _showImagePreviewScreen(file);
                                                  break;
                                                case 'video':
                                                  {
                                                    // المعرض يرفض ما يتجاوز ٦٠
                                                    // ثانية عبر AssetEntity.duration،
                                                    // ومنتقي الملفات لا يحمل هذه
                                                    // البيانات — فنقيسها هنا
                                                    // ليتوحّد الحدّ في المسارين.
                                                    final NavigatorState
                                                    navigator = Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    );
                                                    showDialog<void>(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      barrierColor:
                                                          Colors.black26,
                                                      builder: (_) => Center(
                                                        child: TrydosLoader(),
                                                      ),
                                                    );
                                                    final Duration? duration =
                                                        await HelperFunctions.videoDurationOf(
                                                          file,
                                                        );
                                                    // الـ navigator مُلتقَط قبل
                                                    // الانتظار: context الحوار
                                                    // يصبح مُفكَّكاً بعده.
                                                    navigator.pop();
                                                    if (duration != null &&
                                                        duration.inSeconds >
                                                            59) {
                                                      showMessage(
                                                        LocaleKeys
                                                            .video_length_limit
                                                            .tr(),
                                                        hasError: true,
                                                      );
                                                      return;
                                                    }
                                                    widget.onSendFile(
                                                      file,
                                                      'video',
                                                    );
                                                  }
                                                  break;
                                                default:
                                                  widget.onSendFile(
                                                    file,
                                                    'file',
                                                  );
                                              }
                                            }
                                          },
                                          // علامة الجمع 38×38 كما في الملف، بدل
                                          // أيقونة الملصقات 43×40.
                                          child: kChatDesignV2
                                              ? SizedBox(
                                                  width: 38.w,
                                                  height: 38.h,
                                                  child: Center(
                                                    child: ChatIconsV2.plus(
                                                      color:
                                                          ContactDesign.purple,
                                                    ),
                                                  ),
                                                )
                                              : SvgPicture.asset(
                                                  AppAssets.addStickersSvg,
                                                  width: 43.w,
                                                  height: 40,
                                                ),
                                        ),
                                        // 4 بين الجمع والحقل في الملف، لا 5.
                                        if (kChatDesignV2)
                                          SizedBox(width: 4.w)
                                        else
                                          5.horizontalSpace,
                                        Expanded(
                                          child: Padding(
                                            // الحقل في الملف يملأ ارتفاع الشريط
                                            // الداخلي (38) بلا هامشٍ عمودي.
                                            padding: kChatDesignV2
                                                ? EdgeInsets.zero
                                                : HWEdgeInsets.symmetric(
                                                    vertical: 7.0,
                                                  ),
                                            child: AppTextField(
                                              // حقل الملف: 38 بنصف قطر 12 ولون
                                              // `#F8F8F8`، ونصّه 14 Regular
                                              // وشبحُه `#8D8D8D`. ويكبر إلى خمسة
                                              // أسطر كما في الويب.
                                              filledColor: kChatDesignV2
                                                  ? const Color(0xFFF8F8F8)
                                                  : null,
                                              bordersColor: kChatDesignV2
                                                  ? const Color(0xFFF8F8F8)
                                                  : null,
                                              roundingCornersValue:
                                                  kChatDesignV2 ? 12 : null,
                                              minLines: kChatDesignV2
                                                  ? 1
                                                  : null,
                                              maxLines: kChatDesignV2
                                                  ? 5
                                                  : null,
                                              textStyle: kChatDesignV2
                                                  ? TextStyle(
                                                      fontFamily:
                                                          'Quicksand-Regular',
                                                      fontSize: 14.sp,
                                                      height:
                                                          ContactDesign.lineBox(
                                                            14,
                                                          ) /
                                                          14,
                                                      color: ContactDesign.ink,
                                                    )
                                                  : null,
                                              hintTextStyle: kChatDesignV2
                                                  ? TextStyle(
                                                      fontFamily:
                                                          'Quicksand-Regular',
                                                      fontSize: 14.sp,
                                                      color: ContactDesign.grey,
                                                    )
                                                  : null,
                                              key: TestVariables.kTestMode
                                                  ? const Key(
                                                      WidgetsKeys
                                                          .sendMessageTextFieldKey,
                                                    )
                                                  : null,
                                              controller: form.controllers[0],
                                              enabled:
                                                  !_showImagePreview, // تعطيل الحقل عند عرض المعاينة
                                              onChange: (text) {
                                                _typingTimer.cancel();
                                                try {
                                                  FirebasePresence.sendUserTransaction(
                                                    channelId: widget.channelId,
                                                    description: LocaleKeys
                                                        .typing
                                                        .tr(),
                                                  );
                                                  // pusherChatService
                                                  //     .sendActivityEvent(
                                                  //         widget.channelId,
                                                  //         'Typing...');
                                                } catch (e) {
                                                  debugPrint(e.toString());
                                                }
                                                _typingTimer = Timer(
                                                  const Duration(seconds: 1),
                                                  () {
                                                    FirebasePresence.deleteUserTransaction(
                                                      channelId:
                                                          widget.channelId,
                                                    );
                                                  },
                                                );
                                              },
                                              // الكاميرا داخل الحقل في النهاية:
                                              // 36×38 على بعد 4، كما في الملف.
                                              suffixIcon:
                                                  kChatDesignV2 && !thereText
                                                  ? GestureDetector(
                                                      onTap: _pickPhotoOrVideo,
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      child: Container(
                                                        margin:
                                                            EdgeInsetsDirectional.only(
                                                              end: 4.w,
                                                            ),
                                                        width: 36.w,
                                                        height: 38.h,
                                                        alignment:
                                                            Alignment.center,
                                                        child:
                                                            ChatIconsV2.camera(
                                                              color:
                                                                  ContactDesign
                                                                      .purple,
                                                            ),
                                                      ),
                                                    )
                                                  : null,
                                              contentPadding:
                                                  HWEdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  )..copyWith(right: 0),
                                            ),
                                          ),
                                        ),
                                        // 8 بين الحقل والقرص في الملف، لا 5.
                                        if (kChatDesignV2)
                                          SizedBox(width: 8.w)
                                        else
                                          5.horizontalSpace,
                                        if (!thereText) ...{
                                          // الكاميرا في التصميم الجديد داخل
                                          // الحقل لا بجانبه، فتُرسم هناك
                                          // (`suffixIcon`) وتُحذف من الصفّ.
                                          if (!kChatDesignV2) ...[
                                            InkWell(
                                              focusColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: _pickPhotoOrVideo,
                                              child: SvgPicture.asset(
                                                AppAssets.takePictureSvg,
                                                width: 50.w,
                                                height: 40,
                                              ),
                                            ),
                                            10.horizontalSpace,
                                          ],
                                          // الميكروفون: يُمسَك فيسجّل، ويُفلَت
                                          // فيُرسل، ويُسحب نحو البداية فيُلغي.
                                          // والإيماءة على الزرّ نفسه كما في
                                          // الويب — `Listener` لا `GestureDetector`
                                          // لأن الثاني يسلّم السحب الأفقي إلى
                                          // المحادثة فينفلت الإصبع من الزرّ.
                                          if (kChatDesignV2)
                                            Listener(
                                              onPointerDown: (e) =>
                                                  _onRecordDown(e.position),
                                              onPointerMove: (e) =>
                                                  _onRecordMove(e.position),
                                              onPointerUp: (_) => _onRecordUp(),
                                              onPointerCancel: (_) =>
                                                  _discardRecording(),
                                              child: _roundPurpleButton(
                                                ChatIconsV2.mic(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          else
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
                                                  description: LocaleKeys
                                                      .recording
                                                      .tr(),
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
                                                ? const Key(
                                                    WidgetsKeys
                                                        .sendMessageInChatButtonKey,
                                                  )
                                                : null,
                                            focusColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            onTap: () {
                                              String message =
                                                  form.controllers[0].text;
                                              form.controllers[0].text = '';
                                              widget.onSendMessage.call(
                                                message,
                                              );
                                            },
                                            child: kChatDesignV2
                                                ? _roundPurpleButton(
                                                    ChatIconsV2.send(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : SvgPicture.asset(
                                                    AppAssets.sendMessageSvg,
                                                    width: 58.w,
                                                    height: 40,
                                                  ),
                                          ),
                                        },
                                        // 8 بين الحقل والقرص في الملف، ولا فراغ
                                        // بعده: حشو الشريط يكفيه.
                                        if (!kChatDesignV2) 5.horizontalSpace,
                                      ],
                                    ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
