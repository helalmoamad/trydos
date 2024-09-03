import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';

import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/file_saving.dart';

import 'package:trydos/config/theme/my_color_scheme.dart';

import 'package:trydos/core/utils/form_state_mixin.dart';

import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';

import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/app/vedio_player.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';

import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';

import '../manager/chat_bloc.dart';

import '../manager/chat_state.dart';

class MediaInProfile extends StatefulWidget {
  final List<String>? files;
  const MediaInProfile({
    Key? key,
    required this.files,
  }) : super(key: key);

  @override
  State<MediaInProfile> createState() => _MediaInProfileState();
}

class _MediaInProfileState extends ThemeState<MediaInProfile> {
  final ScrollController scrollController = ScrollController();
  late ChatBloc chatBloc;
  void saveUserContacts() async {}

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      chatBloc.add(SendErrorChatToServerEvent(
          error: error.toString(), lastPage: "Media_In_Profile"));
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      print(error);
    };
    List<Widget> chatPages = [
      ImageInProfile(
        files: widget.files ?? null,
      ),
      VideoInProfile(
        files: widget.files ?? null,
      ),
      FilesInProfile(
        files: widget.files ?? null,
      )
    ];
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: TrydosAppBar(
        appBarParams: AppBarParams(
            backIconColor: Colors.black38,
            dividerBottom: false,
            hasLeading: false,
            surfaceTintColor: Colors.transparent,
            elevation: 1,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        GoRouter.of(context).pop();
                      },
                      child: Padding(
                        padding:
                            HWEdgeInsetsDirectional.fromSTEB(20.w, 15, 0, 15),
                        child: SvgPicture.asset(
                          AppAssets.backFromCallSvg,
                          width: 8.w,
                          color: const Color(0xff388CFF),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      width: 400.w,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          BlocBuilder<ChatBloc, ChatState>(
                            buildWhen: (p, c) =>
                                p.unReadMessagesFromAllChats !=
                                c.unReadMessagesFromAllChats,
                            builder: (context, state) {
                              return ChatTabItem(
                                  index: 0, text: LocaleKeys.images.tr());
                            },
                          ),
                          ChatTabItem(
                            index: 1,
                            text: LocaleKeys.videos.tr(),
                          ),
                          ChatTabItem(
                            index: 2,
                            text: LocaleKeys.files.tr(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
      body: Container(
        color: Color.fromARGB(255, 216, 214, 210),
        width: 1.sw,
        height: 1.sh,
        child: BlocBuilder<AppBloc, AppState>(
            buildWhen: (p, c) => p.tabIndex != c.tabIndex,
            builder: (context, state) {
              return chatPages[state.tabIndex == -1 ? 0 : state.tabIndex];
            }),
      ),
    );
  }
}

class ChatTabItem extends StatelessWidget {
  const ChatTabItem({
    Key? key,
    required this.text,
    required this.index,
  }) : super(key: key);
  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    appBloc.add(ChangeTab(0));
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
              ));
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
    List<String> images = [];
    print(widget.files);
    widget.files!.forEach((element) {
      String mimeStr = element.split(" ")[0];

      if (mimeStr.split('/').contains("image")) {
        images.add(element.split(" ")[1]);
      }
    });
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return widget.files == null
        ? SizedBox.shrink()
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
            shrinkWrap: false,
            scrollDirection: Axis.vertical,
            itemCount: images.length,
            itemBuilder: (context, index) {
              File file = File(images[index]);
              return FullScreenWidget(
                backgroundColor: const Color(0xffB4FFD9),
                child: Hero(
                  tag: "hero${DateTime.now()}",
                  child: Container(
                    width: 200.w,
                    height: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(file),
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
            },
          );
  }
}

class VideoInProfile extends StatefulWidget {
  final List<String>? files;
  const VideoInProfile({Key? key, required this.files}) : super(key: key);

  @override
  State<VideoInProfile> createState() => _VideoInProfileState();
}

class _VideoInProfileState extends ThemeState<VideoInProfile> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> videos = [];
    widget.files!.forEach((element) {
      String mimeStr = element.split(" ")[0];

      if (mimeStr.split('/').contains("video") &&
          !mimeStr.split('.').contains("aac")) {
        videos.add(element.split(" ")[1]);
      }
    });
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return widget.files == null
        ? SizedBox.shrink()
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2),
            shrinkWrap: false,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                height: 200,
                child: Center(
                  child: MYVideoPlayer(
                    chatId: "",
                    videoFile: File(videos[index]),
                  ),
                ),
                color: Colors.black,
                margin: EdgeInsets.all(2),
              );
            },
          );
  }
}

class FilesInProfile extends StatefulWidget {
  final List<String>? files;
  const FilesInProfile({Key? key, required this.files}) : super(key: key);

  @override
  State<FilesInProfile> createState() => _FilesInProfileState();
}

class _FilesInProfileState extends ThemeState<FilesInProfile> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> files = [];
    widget.files!.forEach((element) {
      String mimeStr = element.split(" ")[0];
      if (mimeStr.split('/').contains("files")) {
        files.add(element.split(" ")[1]);
      }
    });
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return widget.files == null
        ? SizedBox.shrink()
        : ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: files.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  OpenFile.open(files[index]);
                },
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              AppAssets.documentSvg,
                              width: 1.sw - 20,
                              height: 60.h,
                            ),
                            10.horizontalSpace,
                            Text(files[index].split("/").last)
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
