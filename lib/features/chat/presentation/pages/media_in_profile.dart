import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/common/helper/media_registry_entry.dart';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';

import 'package:trydos/common/constant/constant.dart';

import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';

import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/app/vedio_player.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';

import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';

import '../manager/chat_bloc.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../manager/chat_state.dart';

class MediaInProfile extends StatefulWidget {
  final List<String>? files;

  /// لازم لإعادة تنزيل مستند لم يعد موجوداً محلياً (وللتسجيل في سجلّ الوسائط).
  final String chatId;
  const MediaInProfile({Key? key, required this.files, this.chatId = ''})
    : super(key: key);

  @override
  State<MediaInProfile> createState() => _MediaInProfileState();
}

class _MediaInProfileState extends ThemeState<MediaInProfile> {
  final ScrollController scrollController = ScrollController();
  late ChatBloc chatBloc;
  void saveUserContacts() async {}

  @override
  void initState() {
    LastPagesTracker.push('MediaInProfile');
    chatBloc = BlocProvider.of<ChatBloc>(context);
    // tabIndex مشترك مع شريط تبويبات التطبيق، وقد يحمل قيمة خارج مدى هذه
    // الشاشة (ثلاث صفحات فقط). نبدأ من الصور مرّة واحدة عند الدخول.
    BlocProvider.of<AppBloc>(context).add(ChangeTab(0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    List<Widget> chatPages = [
      ImageInProfile(files: widget.files ?? null),
      VideoInProfile(files: widget.files ?? null, chatId: widget.chatId),
      FilesInProfile(files: widget.files ?? null, chatId: widget.chatId),
    ];
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: TrydosAppBar(
        appBarParams: AppBarParams(
          backIconColor: Colors.black38,
          hasLeading: false,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      GoRouter.of(context).pop();
                    },
                    child: Padding(
                      padding: HWEdgeInsetsDirectional.fromSTEB(
                        20.w,
                        15,
                        0,
                        15,
                      ),
                      child: SvgPicture.asset(
                        AppAssets.backFromCallSvg,
                        width: 8.w,
                        // ignore: deprecated_member_use
                        color: const Color(0xff388CFF),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    width: 400.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BlocBuilder<ChatBloc, ChatState>(
                          buildWhen: (p, c) =>
                              p.unReadMessagesFromAllChats !=
                              c.unReadMessagesFromAllChats,
                          builder: (context, state) {
                            return ChatTabItem(
                              index: 0,
                              text: LocaleKeys.images.tr(),
                            );
                          },
                        ),
                        ChatTabItem(index: 1, text: LocaleKeys.videos.tr()),
                        ChatTabItem(index: 2, text: LocaleKeys.files.tr()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 216, 214, 210),
        width: 1.sw,
        height: 1.sh,
        child: BlocBuilder<AppBloc, AppState>(
          buildWhen: (p, c) => p.tabIndex != c.tabIndex,
          builder: (context, state) {
            // القيمة مشتركة مع شريط تبويبات التطبيق وقد تتجاوز عدد صفحات هذه
            // الشاشة، فالقصّ يمنع RangeError.
            return chatPages[state.tabIndex.clamp(0, chatPages.length - 1)];
          },
        ),
      ),
    );
  }
}

class ChatTabItem extends StatelessWidget {
  const ChatTabItem({Key? key, required this.text, required this.index})
    : super(key: key);
  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    // أُزيل add(ChangeTab(0)) من هنا: إرسال حدث داخل build يعني أن أي إعادة
    // بناء تُعيد التبويب إلى الصور — وهو ما كان يحدث عند العودة من التطبيق
    // الخارجي بعد فتح مستند. التصفير صار مرّة واحدة في initState.
    return InkWell(
      onTap: () => appBloc.add(ChangeTab(index)),
      child: BlocBuilder<AppBloc, AppState>(
        buildWhen: (p, c) => p.tabIndex != c.tabIndex,
        builder: (context, state) {
          return SizedBox(
            width: 60.w,
            height: 28,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: state.tabIndex == index ? 20.sp : 14.sp,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageInProfile extends StatefulWidget {
  final List<String>? files;
  const ImageInProfile({Key? key, required this.files}) : super(key: key);

  @override
  State<ImageInProfile> createState() => _ImageInProfileState();
}

class _ImageInProfileState extends ThemeState<ImageInProfile> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // يُحتفظ بالمدخل كاملاً (رابط + مسار): الملف قد يكون قد حُذف من المخزن،
    // وعندها نستعيد الصورة من رابطها بدل عرض فراغ.
    final List<MediaRegistryEntry> images = [];
    widget.files!.forEach((element) {
      final MediaRegistryEntry? entry = MediaRegistryEntry.tryParse(element);
      if (entry == null) return;
      // النوع من امتداد الملف المحلي لا من شكل الرابط.
      if (HelperFunctions.mediaTypeOfPath(entry.path) == 'image') {
        images.add(entry);
      }
    });
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

    return widget.files == null
        ? const SizedBox.shrink()
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final MediaRegistryEntry entry = images[index];
              final File file = File(entry.path);
              return FullScreenWidget(
                backgroundColor: const Color(0xffB4FFD9),
                child: Hero(
                  tag: "hero${DateTime.now()}",
                  child: Container(
                    width: 200.w,
                    height: 400,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      // خلفية صريحة: مع DecorationImage كان فشل الرسم يترك
                      // الإطار شفافاً فيبدو أبيض بلا أي دلالة.
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        width: 3.0,
                        color: const Color(0xffB4FFD9),
                      ),
                    ),
                    // الملف المحلي قد يحذفه تنظيف المخزن بينما يبقى مدخله في
                    // السجلّ — نستعيد الصورة من رابطها بدل عرض فراغ صامت.
                    child: file.existsSync()
                        ? Image.file(
                            file,
                            fit: BoxFit.fill,
                            errorBuilder: (_, __, ___) => MyCachedNetworkImage(
                              imageUrl: entry.url,
                              imageFit: BoxFit.fill,
                              width: 200.w,
                              height: 400,
                            ),
                          )
                        : MyCachedNetworkImage(
                            imageUrl: entry.url,
                            imageFit: BoxFit.fill,
                            width: 200.w,
                            height: 400,
                          ),
                  ),
                ),
              );
            },
          );
  }
}

class VideoInProfile extends StatefulWidget {
  final List<String>? files;

  /// لازم لتسجيل أي فيديو يُستعاد من رابطه في سجلّ الوسائط.
  final String chatId;
  const VideoInProfile({Key? key, required this.files, this.chatId = ''})
    : super(key: key);

  @override
  State<VideoInProfile> createState() => _VideoInProfileState();
}

class _VideoInProfileState extends ThemeState<VideoInProfile> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // يُحتفظ بالمدخل كاملاً (رابط + مسار) لا بالمسار وحده: الملف قد يكون قد
    // حُذف من المخزن، وعندها نحتاج الرابط ليستعيده المشغّل.
    final List<MediaRegistryEntry> videos = [];
    widget.files!.forEach((element) {
      final MediaRegistryEntry? entry = MediaRegistryEntry.tryParse(element);
      if (entry == null) return;
      // الصوت (aac) يُستبعد تلقائياً — لا يطابق video.
      if (HelperFunctions.mediaTypeOfPath(entry.path) == 'video') {
        videos.add(entry);
      }
    });
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

    return widget.files == null
        ? const SizedBox.shrink()
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                height: 200,
                child: Center(
                  child: MYVideoPlayer(
                    // كان "" — ومعرّف فارغ يُفسد تسجيل أي ملف يُستعاد لاحقاً.
                    chatId: widget.chatId,
                    videoFile: File(videos[index].path).existsSync()
                        ? File(videos[index].path)
                        : null,
                    videoUrl: videos[index].url,
                  ),
                ),
                color: Colors.black,
                margin: const EdgeInsets.all(2),
              );
            },
          );
  }
}

class FilesInProfile extends StatefulWidget {
  final List<String>? files;
  final String chatId;
  const FilesInProfile({Key? key, required this.files, this.chatId = ''})
    : super(key: key);

  @override
  State<FilesInProfile> createState() => _FilesInProfileState();
}

class _FilesInProfileState extends ThemeState<FilesInProfile> {
  void initState() {
    super.initState();
  }

  Future<void> _openDocument(MediaRegistryEntry entry) async {
    File file = File(entry.path);

    if (!file.existsSync()) {
      // المستند المرسَل يُسجَّل بمسار الملف المؤقّت الذي اختاره المستخدم، وقد
      // يمسحه النظام لاحقاً. نستعيده من الرابط بدل الاكتفاء بلا استجابة.
      //
      // ومؤشّر أثناء الاستعادة: بدونه تمرّ ثوانٍ صامتة بعد الضغط فتبدو
      // الضغطة بلا أثر — وهو ما يدفع المستخدم للضغط مراراً.
      final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black26,
        builder: (_) => Center(child: TrydosLoader()),
      );

      final File? restored = await FileSaving().getOrDownloadMedia(
        entry.url,
        widget.chatId,
        // ضغطة صريحة والمستخدم ينتظر أمام الشاشة: لا تقف خلف تحميل الصور.
        priority: true,
      );

      // الـ navigator مُلتقَط قبل الانتظار: context يصبح مُفكَّكاً بعده.
      navigator.pop();

      if (restored == null) {
        showMessage(LocaleKeys.error_picking_file.tr(), hasError: true);
        return;
      }
      file = restored;
    }

    final OpenResult result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      // كان الفشل صامتاً تماماً: لا فتح ولا رسالة، فتبدو الضغطة بلا أثر.
      debugPrint('OpenFile failed (${result.type}): ${result.message}');
      showMessage(LocaleKeys.error_picking_file.tr(), hasError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // نحتفظ بالرابط مع المسار: المستند المرسَل يُسجَّل بمسار الملف المؤقّت
    // الذي اختاره المستخدم، وقد يمسحه النظام لاحقاً — فنحتاج الرابط لإعادة
    // تنزيله عند الفتح بدل فشل صامت.
    final List<MediaRegistryEntry> files = [];
    widget.files!.forEach((element) {
      final MediaRegistryEntry? entry = MediaRegistryEntry.tryParse(element);
      if (entry == null) return;
      // كل ما ليس صورة أو فيديو أو صوت يُعدّ مستنداً.
      if (HelperFunctions.mediaTypeOfPath(entry.path) == 'file') {
        files.add(entry);
      }
    });
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

    return widget.files == null
        ? const SizedBox.shrink()
        : ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: files.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _openDocument(files[index]),
                child: Container(
                  height: 60.h,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  color: const Color.fromARGB(255, 206, 173, 74),
                  constraints: const BoxConstraints(minHeight: 48),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.documentSvg,
                              width: 1.sw - 20,
                              height: 60.h,
                            ),
                            10.horizontalSpace,
                            Text(files[index].path.split("/").last),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
