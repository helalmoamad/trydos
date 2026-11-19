import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:video_player/video_player.dart';

import 'my_text_widget.dart';
import 'video_player_full.dart';

class MYVideoPlayer extends StatefulWidget {
  const MYVideoPlayer({
    Key? key,
    this.videoUrl,
    this.videoFile,
    required this.chatId,
    this.playGlyph,
  }) : super(key: key);
  final String? videoUrl;
  final File? videoFile;
  final String chatId;

  /// اسم أيقونة التشغيل في `assets/svg/chat_v2/` — تصميم المحادثة الجديد.
  ///
  /// بطاقة الفيديو الجديدة ترسم الإطار والحبّات، ويبقى قرص التشغيل هنا لأن
  /// المنطق تحته (تنزيلٌ ثم تشغيل) يخصّ هذا المشغّل وحده. وغيابه يُبقي
  /// السهم القديم لبقية من يستدعي المشغّل.
  final String? playGlyph;

  @override
  State<MYVideoPlayer> createState() => _MYVideoPlayerState();
}

class _MYVideoPlayerState extends State<MYVideoPlayer> {
  VideoPlayerController? _controller;
  Duration? videoDuration;
  String? imageUrl;

  // الملف المشغَّل فعلياً (الوارد مع الودجت، أو المستخرَج من الكاش، أو المنزَّل).
  // كانت الشاشة الكاملة تتلقّى widget.videoFile وحده — وهو null للفيديو الوارد.
  File? _localFile;

  // كان late: حين يكون videoUrl و videoFile كلاهما null لا يُسنَد أبداً،
  // فيصل البناء إلى FutureBuilder ويقع LateInitializationError.
  Future<void>? initializeVideo;
  ValueNotifier<double> downloadingProgress = ValueNotifier(0);

  /// البايتات المستلمة — تُعرض حين يتعذّر حساب النسبة (لا Content-Length).
  /// بدونها يبقى المؤشّر جامداً فيبدو التنزيل معلّقاً وهو يعمل.
  ValueNotifier<int> downloadedBytes = ValueNotifier(0);
  ValueNotifier<bool> isDownloading = ValueNotifier(false);
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    imageUrl = _thumbnailUrlFor(widget.videoUrl);
    if (widget.videoFile != null) {
      _localFile = widget.videoFile;
      _controller = VideoPlayerController.file(widget.videoFile!);
      initializeController();
    } else if (widget.videoUrl != null) {
      // فحص متزامن أولاً: بدونه يومض المصغَّر ثم يظهر المشغّل في كل تمرير،
      // فيبدو وكأن الفيديو يُعاد تحميله من جديد.
      final File? ready = FileSaving().cachedMediaFileSync(widget.videoUrl!);
      if (ready != null) {
        _localFile = ready;
        _controller = VideoPlayerController.file(ready);
        initializeController();
      } else {
        _adoptCachedVideo();
      }
    }
    super.initState();
  }

  /// فيديو سبق تنزيله يُشغَّل مباشرةً دون مطالبة المستخدم بتنزيله ثانيةً —
  /// فحص قرص فقط، بلا شبكة، حفاظاً على سياسة «لا تنزيل تلقائي».
  Future<void> _adoptCachedVideo() async {
    final File? cached = await FileSaving().cachedMediaFile(widget.videoUrl!);
    if (cached == null || !mounted) return;
    setState(() {
      _localFile = cached;
      _controller = VideoPlayerController.file(cached);
      initializeController();
    });
  }

  /// يستبدل امتداد الفيديو وحده بـ JPG. الصيغة السابقة كانت
  /// `replaceFirst(url.split('.').last, 'JPG')` — تستبدل أول ظهور للنص في
  /// الرابط كلّه (النطاق أو المسار)، لا الامتداد.
  String? _thumbnailUrlFor(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return null;
    final int lastDot = videoUrl.lastIndexOf('.');
    final int lastSlash = videoUrl.lastIndexOf('/');
    if (lastDot <= lastSlash) return null; // لا امتداد في الجزء الأخير
    return '${videoUrl.substring(0, lastDot)}.JPG?w=300&h=300';
  }

  /// [autoPlay] للتنزيل الذي طلبه المستخدم بضغطة صريحة فقط. الفيديو المستخرَج
  /// من الكاش عند بناء الودجت لا يُشغَّل تلقائياً، وإلا انطلقت الفيديوهات
  /// وحدها أثناء التمرير في الدردشة.
  void initializeController({bool autoPlay = false}) {
    initializeVideo = _controller!.initialize().then((_) {
      if (!mounted) return;
      if (autoPlay) _controller!.play();
      setState(() {});
    });
    // كان هنا addListener(() => setState(...)) — إعادة بناء الشجرة كاملة مع كل
    // إطار فيديو داخل قائمة الدردشة. الأجزاء المتغيّرة تستمع وحدها الآن عبر
    // ValueListenableBuilder على الـ controller.
    _controller!.addListener(_restartWhenFinished);
  }

  void _restartWhenFinished() {
    final VideoPlayerValue? value = _controller?.value;
    if (value == null || !value.isInitialized) return;
    // كان هذا الفحص داخل build() — أثر جانبي يُنفَّذ في كل إعادة بناء.
    if (value.position >= value.duration && value.duration > Duration.zero) {
      _controller?.seekTo(Duration.zero);
    }
  }

  @override
  void dispose() {
    if (!cancelToken.isCancelled) cancelToken.cancel();
    _controller?.removeListener(_restartWhenFinished);
    _controller?.dispose();
    downloadingProgress.dispose();
    downloadedBytes.dispose();
    isDownloading.dispose();
    super.dispose();
  }

  String getPosition() {
    final Duration duration;
    if (_controller!.value.isPlaying) {
      duration = Duration(
        milliseconds: _controller!.value.position.inMilliseconds.round(),
      );
    } else {
      duration = Duration(
        milliseconds: _controller!.value.duration.inMilliseconds.round(),
      );
    }

    return [duration.inHours, duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':')
        .padLeft(2, '0');
  }

  /// المصغَّر — يُستعمل قبل التنزيل وأثناء تهيئة المشغّل معاً، فلا يرى
  /// المستخدم فراغاً ولا مؤشّر تحميل عند العودة إلى فيديو منزَّل مسبقاً.
  Widget _thumbnailImage() {
    if (imageUrl == null) return _thumbnailFallback();
    return CachedNetworkImage(
      memCacheWidth: 200,
      memCacheHeight: 300,
      maxHeightDiskCache: 300,
      maxWidthDiskCache: 200,
      imageUrl: imageUrl!,
      // بلا مقاسٍ في التصميم الجديد: المصغَّر يملأ الإطار ويُغطّيه، فلا يبقى
      // فراغ عند الأطراف. و200×300 الثابتة كانت تُبقيه أضيقَ من الإطار.
      width: _fills ? null : 200,
      height: _fills ? null : 300,
      fit: BoxFit.cover,
      // الخادم قد لا يملك مصغَّراً بجانب الفيديو؛ بدون هذين تبقى المساحة
      // بيضاء فارغة بلا أي دلالة.
      placeholder: (context, url) => _thumbnailFallback(),
      errorWidget: (context, url, error) => _thumbnailFallback(),
    );
  }

  /// خلفية سوداء صافية حين لا يوفّر الخادم مصغَّراً — بلا أيقونة كاميرا، لأن
  /// زرّ التشغيل يعلوها وهو الدلالة الكافية. كانت black26 فوق grey.shade200
  /// فتظهر بمظهر رمادي باهت.
  Widget _thumbnailFallback() =>
      Container(width: 200, height: 300, color: Colors.black);

  Future<void> _startDownload() async {
    // رمز إلغاء جديد لكل محاولة: إعادة استخدام رمز مُلغى كانت تُفشل كل
    // تنزيل لاحق فوراً بعد أول إلغاء.
    cancelToken = CancelToken();
    downloadingProgress.value = 0;
    isDownloading.value = true;
    final File? file = await FileSaving().getOrDownloadMedia(
      widget.videoUrl!,
      widget.chatId,
      cancelToken: cancelToken,
      onProgress: (percent, receivedBytes) {
        downloadingProgress.value = percent;
        downloadedBytes.value = receivedBytes;
      },
      // ضغطة صريحة من المستخدم: لا تنتظر خلف تحميل صور الدردشة التلقائي.
      priority: true,
    );
    if (!mounted) return;
    // كانت تبقى true عند الفشل أو الإلغاء فيدور المؤشّر إلى الأبد.
    isDownloading.value = false;
    if (file == null) return;
    setState(() {
      _localFile = file;
      _controller = VideoPlayerController.file(file);
      // الضغطة الأولى تكفي: ينتهي التنزيل فيبدأ التشغيل بلا ضغطة ثانية.
      initializeController(autoPlay: true);
    });
  }

  /// المشغّل يملأ إطاراً يرسمه من فوقه.
  ///
  /// التصميم الجديد يرسم الإطار (300×225 بزوايا الفقاعة) ويقصّه، فالمشغّل
  /// يملؤه ولا يحمل مقاساً خاصّاً. والقديم يحمل مقاساته كما كانت.
  bool get _fills => widget.playGlyph != null;

  /// قرص التشغيل كما يرسمه تصميم المحادثة الجديد: 56 أبيض، وعلامةٌ 30
  /// مزاحةٌ 3 إلى اليمين — مركز المثلّث البصري ليس مركزه الهندسي.
  Widget _designPlayDisc(String glyph) {
    return Container(
      width: 56.w,
      height: 56.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: 3.w),
        child: SvgPicture.asset(
          'assets/svg/chat_v2/$glyph.svg',
          width: 30.w,
          height: 30.h,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // سياسة الفيديو كسياسة واتساب: لا تنزيل تلقائي — مصغَّر وزر تنزيل،
    // والمشغّل لا يُنشأ إلا بعد اكتمال التنزيل. الشرط على المشغّل وحده حتى
    // لا ينتهي فيديو بلا مصغَّر إلى FutureBuilder بلا future.
    return _controller == null
        ? SizedBox(
            // التصميم الجديد يرسم الإطار بنفسه (300×225 بزوايا الفقاعة)،
            // فالمشغّل يملؤه. و300×300 الثابتة كانت تُبقيه غيرَ مالئ قبل
            // التشغيل: أعرضَ من الإطار وأطولَ منه.
            width: _fills ? double.infinity : 300,
            height: _fills ? double.infinity : 300,
            child: Stack(
              alignment: Alignment.center,
              fit: _fills ? StackFit.expand : StackFit.loose,
              children: [
                _thumbnailImage(),
                ValueListenableBuilder<bool>(
                  valueListenable: isDownloading,
                  builder: (context, downloading, _) {
                    return !downloading
                        ? InkWell(
                            onTap: widget.videoUrl == null
                                ? null
                                : _startDownload,
                            child: widget.playGlyph == null
                                ? const Icon(
                                    Icons.play_arrow,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : _designPlayDisc(widget.playGlyph!),
                          )
                        : ValueListenableBuilder<double>(
                            valueListenable: downloadingProgress,
                            builder: (context, progress, _) {
                              debugPrint('progress: $progress');
                              return InkWell(
                                onTap: () {
                                  isDownloading.value = false;
                                  cancelToken.cancel();
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  // نصّ الحجم يقع أسفل الحلقة خارج حدودها،
                                  // والقصّ الافتراضي كان سيخفيه.
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircularProgressIndicator(
                                      // null = مؤشّر دوّار غير محدَّد. تمرير
                                      // 0 كان يرسم قوساً بطول صفر، فلا يظهر
                                      // إلا حرف X ويبدو أن شيئاً لم يحدث —
                                      // والتقدّم يبقى صفراً حتى يصل أول قياس
                                      // من الخادم (أو دائماً إن لم يرسل
                                      // content-length).
                                      value: progress > 0
                                          ? progress / 100
                                          : null,
                                      strokeWidth: 5,
                                      backgroundColor: Colors.grey,
                                      color: const Color(0xff388CFF),
                                    ),
                                    MyTextWidget(
                                      'X',
                                      style: context.textTheme.bodyLarge?.bq
                                          .copyWith(color: Colors.white),
                                    ),
                                    // حين تتعذّر النسبة نعرض ما نزل فعلاً —
                                    // رقم يتحرّك يفرّق «يعمل» عن «معلّق».
                                    if (progress < 0)
                                      Positioned(
                                        bottom: -22,
                                        child: ValueListenableBuilder<int>(
                                          valueListenable: downloadedBytes,
                                          builder: (context, bytes, _) =>
                                              MyTextWidget(
                                                '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                                                style: context
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                  },
                ),
              ],
            ),
          )
        : FutureBuilder(
            future: initializeVideo,
            builder: (context, snapShot) {
              // `done` يشمل الاكتمال **بخطأ**: ملف محذوف من المخزن، أو مسار
              // مؤقّت مسحه النظام، أو ترميز غير مدعوم. وبلا هذا الفحص يُرسم
              // VideoPlayer على مشغّل غير مهيّأ فيظهر مربّع أسود صامت لا
              // يفرّقه المستخدم عن التحميل.
              if (snapShot.hasError ||
                  (snapShot.connectionState == ConnectionState.done &&
                      !(_controller?.value.isInitialized ?? false))) {
                return SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _thumbnailFallback(),
                      Icon(
                        Icons.videocam_off_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                );
              }
              if (snapShot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // كان التنقّل ملفوفاً داخل setState — أثر جانبي في غير موضعه.
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MYVideoPlayerFull(
                        chatId: widget.chatId,
                        // الملف المشغَّل فعلاً لا الوارد مع الودجت.
                        videoFile: _localFile ?? widget.videoFile,
                        videoUrl: widget.videoUrl,
                        key: widget.key,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    // التصميم الجديد: المشغّل يملأ إطارَه. وكانت 250×400
                    // ثابتة، و`AspectRatio` يُحيط الفيديو بفراغٍ عند
                    // الأطراف، و`ClipRRect` بنصف قطر 12 داخل إطارٍ له نصفُ
                    // قطرٍ آخر — فيبقى الفراغ عند الزوايا.
                    height: _fills ? double.infinity : 400.h,
                    width: _fills ? double.infinity : 250.w,
                    child: Stack(
                      alignment: Alignment.center,
                      fit: _fills ? StackFit.expand : StackFit.loose,
                      children: [
                        if (_fills)
                          // `cover` يملأ الإطار ويقصّ الزائد، فلا فراغ. وقصُّ
                          // الزوايا يفعله الإطار نفسه.
                          FittedBox(
                            fit: BoxFit.cover,
                            clipBehavior: Clip.hardEdge,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          )
                        else
                          Container(
                            width: 1.sw,
                            height: 1.sh,
                            child: AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              // Use the VideoPlayer widget to display the video.
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          ),
                        // هذان وحدهما يتغيّران مع تقدّم التشغيل، فيستمعان
                        // مباشرةً بدل إعادة بناء الشجرة كلها مع كل إطار.
                        ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller!,
                          builder: (context, value, _) => value.isPlaying
                              ? const SizedBox.shrink()
                              : Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: Colors.grey.shade300,
                                ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 25,
                          child: ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: _controller!,
                            builder: (context, value, _) => MyTextWidget(
                              getPosition(),
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // مؤشّر تحميل أثناء التهيئة (بطلب المستخدم). المصغَّر البديل
              // الرمادي كان يظهر هنا لأن الخادم لا يوفّر مصغَّراً للفيديو،
              // فبدا أسوأ من المؤشّر. التهيئة سريعة لأن الملف محلّي.
              return Container(
                width: 300,
                height: 300,
                color: Colors.black,
                alignment: Alignment.center,
                child: TrydosLoader(),
              );
            },
          );
  }
}
