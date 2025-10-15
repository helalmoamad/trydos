import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:get_it/get_it.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';
import 'package:easy_localization/easy_localization.dart' as tr;
import '../../../../../common/helper/file_saving.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../data/models/ImageDetail.dart';
import '../../manager/chat_event.dart';
import '../../manager/chat_state.dart';
import 'no_image_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

// ignore: must_be_immutable
class ImageMessage extends StatefulWidget {
  ImageMessage(
      {Key? key,
      this.isForwarded = false,
      this.isLocalMessage = true,
      required this.isSent,
      required this.isRead,
      required this.senderId,
      this.userMessagePhoto,
      this.imageFile,
      this.isSlopRight = true,
      this.imageUrl,
      required this.userMessageName,
      required this.messageId,
      required this.isReceived,
      required this.isFirstMessage,
      this.receivedAt,
      this.createAt,
      this.watchedAt,
      required this.channelId})
      : super(key: key);
  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  bool isSlopRight;
  final String messageId;
  bool timer = false;
  File? imageFile;
  final bool isLocalMessage;
  final String? imageUrl;
  final DateTime? receivedAt;
  final DateTime? createAt;
  final String channelId;
  final DateTime? watchedAt;

  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  bool isRead;
  bool isReceived;
  final int senderId;
  final String? userMessagePhoto;
  final String userMessageName;

  @override
  State<ImageMessage> createState() => _ImageMessageState();
}

class _ImageMessageState extends State<ImageMessage>
    with AutomaticKeepAliveClientMixin {
  int? width;
  bool timer = false;
  int? height;
  late ChatBloc chatBloc;
  final ValueNotifier<int> _loadingImage = ValueNotifier(0);

  // إضافة متغيرات لحفظ حالة الصورة
  bool _isImageLoaded = false;
  bool _isDownloading = false;

  File? _cachedImageFile; // ✅ حفظ مرجع للصورة المحملة
  bool _isFullScreenActive = false; // ✅ تتبع حالة FullScreen

  @override
  bool get wantKeepAlive => true; // ✅ الحفاظ على حالة Widget

  @override
  void initState() {
    debugPrint(
        "🎯 ImageMessage initState - imageFile: ${widget.imageFile?.path ?? 'null'}, imageUrl: '${widget.imageUrl ?? 'null'}'");

    // ✅ تحديد حالة الصورة الأولية بدقة
    if (widget.imageFile != null && widget.imageFile!.existsSync()) {
      debugPrint("📁 Image already exists as file");
      _cachedImageFile = widget.imageFile; // ✅ حفظ نسخة احتياطية
      _isImageLoaded = true;
      _loadingImage.value = 2; // تم التحميل بالفعل
    } else if (widget.imageUrl.isNullOrEmpty ||
        widget.imageUrl!.trim().isEmpty) {
      debugPrint("❌ No valid imageUrl - setting error state");
      _loadingImage.value = -1; // خطأ مباشرة - لا يوجد URL صالح
      _isImageLoaded = false;
    } else {
      debugPrint(
          "🔗 Image URL available, ready to download: '${widget.imageUrl}'");
      _loadingImage.value = 0; // جاهز للتحميل
    }

    if (widget.isSent) {
      // FileSaving().downloadFileToLocalStorage(
      //   widget.imageUrl ??
      //       widget.imageFile!.path + '?width=${200.w}&height=400',
      //   widget.channelId,
      // );
    }
    chatBloc = BlocProvider.of<ChatBloc>(context);
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          timer = true;
        });
      }
    });

    // ✅ بدء تحميل الصورة فقط إذا لم تكن محملة ولديها URL صالح
    if (!_isImageLoaded &&
        !widget.imageUrl.isNullOrEmpty &&
        widget.imageUrl!.trim().isNotEmpty) {
      debugPrint("🚀 Starting image initialization");
      _initializeImage();
    }

    super.initState();
  }

  // دالة لتهيئة الصورة مرة واحدة فقط
  void _initializeImage() {
    // ✅ التحقق من أن الـ Widget ما زال موجوداً
    if (!mounted) {
      debugPrint("❌ Widget disposed - skipping image initialization");
      return;
    }

    debugPrint(
        "🔄 _initializeImage called - isDownloading: $_isDownloading, isLoaded: $_isImageLoaded, imageUrl: '${widget.imageUrl ?? 'null'}'");

    // ✅ فحص URL فارغ أو null أولاً
    if (widget.imageUrl.isNullOrEmpty || widget.imageUrl!.trim().isEmpty) {
      debugPrint("❌ Invalid imageUrl - setting error state");
      _isImageLoaded = false;
      if (mounted) {
        _loadingImage.value = -1; // خطأ - URL غير صالح
      }
      if (mounted) setState(() {});
      return;
    }

    // ✅ فحوصات قوية لمنع التحميل المتكرر
    if (_isDownloading || _isImageLoaded) {
      debugPrint("⏭️ Skipping download - already downloading or loaded");
      return;
    }

    // ✅ التحقق من وجود صورة محفوظة مسبقاً
    if (_cachedImageFile != null && _cachedImageFile!.existsSync()) {
      debugPrint("📁 Using cached image file");
      widget.imageFile = _cachedImageFile;
      _isImageLoaded = true;
      if (mounted) {
        _loadingImage.value = 2;
      }
      if (mounted) setState(() {});
      return;
    }

    debugPrint("⬇️ Starting download from URL: ${widget.imageUrl}");
    _isDownloading = true;
    if (mounted) {
      _loadingImage.value = 1; // حالة التحميل
    }

    // ✅ إضافة timeout للتحميل (30 ثانية)
    Timer(const Duration(seconds: 30), () {
      if (_isDownloading && _loadingImage.value == 1) {
        debugPrint("⏰ Download timeout - switching to error state");
        _isDownloading = false;
        _isImageLoaded = false;
        if (mounted) {
          _loadingImage.value = -1;
        }
        if (mounted) setState(() {});
      }
    });

    FileSaving().downloadFileToLocalStorage(widget.imageUrl!, widget.channelId,
        action: (File? file) {
      debugPrint("✅ Download completed - file: ${file?.path}");

      // ✅ إعادة تعيين حالة التحميل دائماً أولاً
      _isDownloading = false;

      if (file != null && file.existsSync()) {
        debugPrint("✅ File exists and is valid");
        widget.imageFile = file;
        _cachedImageFile = file; // ✅ حفظ نسخة احتياطية
        _isImageLoaded = true;
        if (mounted) {
          _loadingImage.value = 2; // تم التحميل بنجاح
        }
        if (mounted) setState(() {});
      } else {
        debugPrint("❌ Download failed - file is null or doesn't exist");
        // ✅ التأكد من إعادة تعيين جميع الحالات عند الفشل
        _isImageLoaded = false;
        _cachedImageFile = null; // مسح أي كاش معطل
        if (mounted) {
          _loadingImage.value = -1; // فشل التحميل
        }
        if (mounted) {
          setState(() {}); // ✅ إجبار إعادة بناء UI لإظهار زر إعادة المحاولة
        }
      }
    });
  }

  @override
  void didUpdateWidget(ImageMessage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إعادة تحميل الصورة فقط إذا تغير URL
    if (oldWidget.imageUrl != widget.imageUrl) {
      _isImageLoaded = false;
      _isDownloading = false;
      if (mounted) {
        _loadingImage.value = 0;
      }
      _initializeImage();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ إعادة تعيين حالة FullScreen عند تغيير التبعيات
    if (_isFullScreenActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isFullScreenActive = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ مطلوب لـ AutomaticKeepAliveClientMixin

    debugPrint(widget.imageFile.toString());
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    debugPrint('widget.isLocalMessage ${widget.isLocalMessage}');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (p, c) =>
            p.changeMessageStateFromPusherStatus !=
                c.changeMessageStateFromPusherStatus &&
            c.changeMessageStateFromPusherStatus !=
                ChangeMessageStateFromPusherStatus.init,
        listener: (context, state) {
          if (state.changeMessageStateFromPusherStatus ==
              ChangeMessageStateFromPusherStatus.watched) {
            if (widget.isRead) {
              return;
            }
            setState(() {
              widget.isRead = true;
            });
          } else if (!widget.isReceived) {
            setState(() {
              widget.isReceived = true;
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: HWEdgeInsets.only(
                right: widget.isSent ? 25.w : 0,
                left: widget.isSent ? 0 : 25.w),
            child: SwipeTo(
              onLeftSwipe: () {
                if (widget.senderId == widget._prefsRepository.myChatId) {
                  if ((state.sendMessageStatus == SendMessageStatus.loading &&
                      state.currentMessage.contains(widget.messageId))) {
                    return;
                  }
                  BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                      true, 'image', widget.isSent,
                      senderParentMessageId: widget.senderId,
                      imageUrl: widget.imageUrl ?? widget.imageFile!.path,
                      messageId: widget.messageId,
                      time: widget.createAt,
                      message: 'Photo'));
                } else {}
              },
              iconSize: 0,
              animationDuration: const Duration(milliseconds: 100),
              offsetDx: 0.15,
              onRightSwipe: () {
                if (widget.senderId == widget._prefsRepository.myChatId) {
                  BlocProvider.of<ChatBloc>(context)
                      .add(ChangeSlop(messageId: widget.messageId));
                } else {
                  if ((state.sendMessageStatus == SendMessageStatus.loading &&
                      state.currentMessage.contains(widget.messageId))) {
                    return;
                  }
                  BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                      true, 'image', widget.isSent,
                      senderParentMessageId: widget.senderId,
                      imageUrl: widget.imageUrl ?? widget.imageFile!.path,
                      messageId: widget.messageId,
                      time: widget.createAt,
                      message: 'Photo'));
                }
              },
              child: Row(
                mainAxisAlignment: widget.isSent
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: !(state.isSlpoing &&
                            state.slopMessageId!.contains(widget.messageId) &&
                            (widget.isReceived || widget.isRead))
                        ? const Offset(0, 0)
                        : widget.senderId == widget._prefsRepository.myChatId
                            ? Offset(50.w, 0)
                            : Offset(-50.w, 0),
                    child: Stack(
                      alignment: widget.isSent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      children: [
                        // ✅ منطق بسيط وواضح لعرض الصورة
                        _buildImageWidget(),
                        //todo until i solve the translate
                        widget.isFirstMessage
                            ? Transform.translate(
                                offset: Offset(widget.isSent ? 15.w : -15.w, 0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Stack(
                                      alignment: widget.isSent
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      children: [
                                        Container(
                                          width: 40.w,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffEBFFF8),
                                            border: Border.all(
                                              width: 3.0,
                                              color: widget.isSent
                                                  ? const Color(0xffFFF9B4)
                                                  : const Color(0xffB4FFD9),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        Container(
                                          width: 20.w,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffEBFFF8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    widget.userMessagePhoto != null
                                        ? MyCachedNetworkImage(
                                            imageUrl: (widget.userMessagePhoto
                                                    .toString()
                                                    .contains("cloudinary")
                                                ? widget.userMessagePhoto!
                                                : ("${dotenv.env['Images_Url']}") +
                                                    widget.userMessagePhoto!),
                                            imageFit: BoxFit.contain,
                                            progressIndicatorBuilderWidget:
                                                TrydosLoader(),
                                            radius: 8,
                                            width: 30.w,
                                            height: 30,
                                          )
                                        : NoImageWidget(
                                            width: 30.w,
                                            height: 30,
                                            textStyle: context
                                                .textTheme.titleMedium?.br
                                                .copyWith(
                                                    color:
                                                        const Color(0xff6638FF),
                                                    letterSpacing: 0.18,
                                                    height: 1.33),
                                            radius: 8,
                                            name: widget.userMessageName),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                        state.isSlpoing &&
                                state.slopMessageId!.contains(widget.messageId)
                            ? Transform.translate(
                                offset: widget.senderId ==
                                        widget._prefsRepository.myChatId
                                    ? Offset(-220.w, 0)
                                    : Offset(110.w, 0),
                                child: SendRecieveWatchTime(
                                  isRead: widget.isRead,
                                  isReceived: widget.isReceived,
                                  receivedAt: widget.receivedAt,
                                  watchedAt: widget.watchedAt,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // ✅ إيقاف أي عمليات تحميل جارية
    _isDownloading = false;
    _isImageLoaded = false;

    // ✅ تنظيف ValueNotifier
    _loadingImage.dispose();
    super.dispose();
  }

  Future<ChatImageDetail> loadWidthAndHeightForImage(
      {required File ImageFile, Function? onError}) async {
    Completer<ChatImageDetail> completer = Completer<ChatImageDetail>();

    completer = Completer<ChatImageDetail>();
    Image image;
    image = Image.file(ImageFile);
    try {
      image.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener(
            (
              ImageInfo imageInfo,
              bool _,
            ) {
              final dimensions = ChatImageDetail(
                width: imageInfo.image.width,
                height: imageInfo.image.height,
              );
              if (completer.isCompleted == false) {
                completer.complete(dimensions);
              }
            },
            onError: (exception, stackTrace) {
              if (onError != null) onError();
            },
          ));
    } catch (e) {
      // GetIt.I<StoryBloc>().add(LoadFailureEvent());
    }
    return completer.future;
  }

  // ✅ دالة للتحقق من وجود صورة صالحة للعرض

  // ✅ دالة لبناء widget الصورة بمنطق مبسط
  Widget _buildImageWidget() {
    // تحديد الصورة المتاحة
    final hasImageFile =
        widget.imageFile != null && widget.imageFile!.existsSync();
    final hasCachedFile =
        _cachedImageFile != null && _cachedImageFile!.existsSync();

    if (hasImageFile || hasCachedFile) {
      final displayFile = widget.imageFile ?? _cachedImageFile!;
      return _buildLoadedImage(displayFile);
    } else {
      return _buildLoadingOrError();
    }
  }

  // ✅ دالة لبناء الصورة المحملة
  Widget _buildLoadedImage(File imageFile) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FullScreenWidget(
          backgroundColor:
              widget.isSent ? const Color(0xffFFF9B4) : const Color(0xffB4FFD9),
          disposeLevel: DisposeLevel.High, // ✅ حماية أقوى من الاختفاء
          child: Hero(
            tag: "hero_${widget.messageId}",
            child: Container(
              key: ValueKey("image_${widget.messageId}"),
              width: 250.w,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // ✅ في حالة الخطأ، log فقط - لا تغيير للحالة
                    debugPrint("Image display error: $exception");
                  },
                ),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  width: 3.0,
                  color: widget.isSent
                      ? const Color(0xffFFF9B4)
                      : const Color(0xffB4FFD9),
                ),
              ),
            ),
          ),
        ),
        _buildImageOverlay(),
      ],
    );
  }

  // ✅ دالة لبناء حالة التحميل أو الخطأ
  Widget _buildLoadingOrError() {
    return Container(
      width: 200.w,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          width: 3.0,
          color:
              widget.isSent ? const Color(0xffFFF9B4) : const Color(0xffB4FFD9),
        ),
      ),
      child: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: _loadingImage,
          builder: (context, status, _) {
            // ✅ فحص URL فارغ أو null أولاً
            if (widget.imageUrl.isNullOrEmpty ||
                widget.imageUrl!.trim().isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined,
                      size: 50, color: Colors.red.shade400),
                  const SizedBox(height: 10),
                  MyTextWidget(
                    LocaleKeys.invalid_image_url.tr(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            // ✅ بدء التحميل مرة واحدة فقط - بدون تكرار
            if (status == 0 &&
                !_isDownloading &&
                !_isImageLoaded &&
                !widget.imageUrl.isNullOrEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _loadingImage.value == 0) {
                  _initializeImage();
                }
              });
            }

            // عرض حالة التحميل
            if (status == 1) {
              return CircularProgressIndicator(
                backgroundColor: Colors.grey.shade100,
                color: const Color(0xff388CFF),
              );
            }

            // عرض خطأ مع زر إعادة المحاولة
            if (status == -1) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 50, color: Colors.red.shade400),
                  const SizedBox(height: 10),
                  MyTextWidget(
                    LocaleKeys.image_load_failed.tr(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint("🔄 Retry button pressed");
                      // ✅ إعادة تعيين جميع الحالات بشكل صحيح
                      setState(() {
                        _loadingImage.value = 0; // جاهز للتحميل
                        _isDownloading = false; // ليس في حالة تحميل
                        _isImageLoaded = false; // لم يتم التحميل بعد
                        _cachedImageFile = null; // مسح الكاش المعطل
                      });
                      // بدء التحميل مرة أخرى
                      _initializeImage();
                    },
                    child: Text(LocaleKeys.retry_download.tr()),
                  ),
                ],
              );
            }

            // حالة افتراضية - لا يجب الوصول إليها
            return CircularProgressIndicator(
              backgroundColor: Colors.grey.shade100,
              color: const Color(0xff388CFF),
            );
          },
        ),
      ),
    );
  }

  // ✅ دالة لبناء overlay الصورة (الوقت والحالة)
  Widget _buildImageOverlay() {
    return Transform.translate(
      offset: const Offset(0, -3),
      child: Container(
        height: 40.h,
        width: 200.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.0, 0),
            end: Alignment(0.0, 1.0),
            colors: [Color(0x00000000), Color(0xb2000000)],
            stops: [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyTextWidget(
                !widget.createAt!.isUtc
                    ? HelperFunctions.getDateInFormat(widget.createAt!)
                    : HelperFunctions.getZonedDateInFormat(widget.createAt!),
                style: context.textTheme.titleSmall?.rr.copyWith(
                  color: context.colorScheme.white,
                ),
              ),
              if (widget.isSent) ...{
                10.horizontalSpace,
                SvgPicture.asset(
                  widget.isRead
                      ? AppAssets.messageReadArrowSvg
                      : widget.isReceived
                          ? AppAssets.messageDeliveredArrowSvg
                          : AppAssets.messageSentArrowSvg,
                  width: 10.sp,
                  height: 10.sp,
                ),
              },
              if (widget.isForwarded) ...{
                10.horizontalSpace,
                SvgPicture.asset(
                  AppAssets.forwardedSvg,
                  width: 10.sp,
                  height: 10.sp,
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
