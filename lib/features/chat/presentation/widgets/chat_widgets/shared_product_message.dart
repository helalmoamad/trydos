import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
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
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/text_message.dart';
import '../../../../../common/helper/file_saving.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../data/models/ImageDetail.dart';
import '../../manager/chat_event.dart';
import '../../manager/chat_state.dart';
import 'no_image_widget.dart';

class SharedProductMessage extends StatefulWidget {
  SharedProductMessage(
      {Key? key,
      this.isForwarded = false,
      this.isLocalMessage = true,
      required this.isSent,
      required this.isRead,
      required this.senderId,
      required this.productName,
      required this.productDescription,
      this.userMessagePhoto,
      this.isSlopRight = true,
      this.imageUrl,
      this.imageFile,
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
  final bool isLocalMessage;
  final String? imageUrl;
  File? imageFile;
  final DateTime? receivedAt;
  final DateTime? createAt;
  final String channelId;
  final DateTime? watchedAt;
  final String productName;
  final String productDescription;

  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  bool isRead;
  bool isReceived;
  final int senderId;
  final String? userMessagePhoto;
  final String userMessageName;

  @override
  State<SharedProductMessage> createState() => _SharedProductMessageState();
}

class _SharedProductMessageState extends State<SharedProductMessage> {
  int? width;
  bool timer = false;
  int? height;
  late ChatBloc chatBloc;
  final ValueNotifier<int> _loadingImage = ValueNotifier(0);

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    Timer(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          timer = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
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
                      imageUrl: widget.imageUrl,
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
                      imageUrl: widget.imageUrl,
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
                  Container(
                    decoration: BoxDecoration(
                      color: widget.isSent
                          ? const Color(0xffFFF9B4)
                          : const Color(0xffB4FFD9),
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: !(state.isSlpoing &&
                                  state.slopMessageId!
                                      .contains(widget.messageId) &&
                                  (widget.isReceived || widget.isRead))
                              ? Offset(0, 0)
                              : widget.senderId ==
                                      widget._prefsRepository.myChatId
                                  ? Offset(50.w, 0)
                                  : Offset(-50.w, 0),
                          child: Stack(
                            alignment: widget.isSent
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            children: [
                              if (widget.imageFile == null) ...{
                                Container(
                                    width: 1.sw - 100,
                                    height: 464,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        width: 3.0,
                                        color: widget.isSent
                                            ? const Color(0xffFFF9B4)
                                            : const Color(0xffB4FFD9),
                                      ),
                                    ),
                                    child: Center(
                                        child: ValueListenableBuilder<int>(
                                            valueListenable: _loadingImage,
                                            builder: (context, status, _) {
                                              FileSaving()
                                                  .downloadFileToLocalStorage(
                                                      widget.imageUrl! +
                                                          '?width=${1.sw - 100}&height=464',
                                                      widget.channelId,
                                                      action: (File? file) {
                                                // _loadingImage.value = 2;
                                                if (file != null) {
                                                  widget.imageFile = file;
                                                  if (mounted) {
                                                    setState(() {});
                                                  }
                                                }
                                              });
                                              return CircularProgressIndicator(
                                                backgroundColor:
                                                    Colors.grey.shade100,
                                                color: const Color(0xff388CFF),
                                              );
                                            }))),
                              } else ...{
                                // FutureBuilder(
                                //   future: loadWidthAndHeightForImage(
                                //       ImageFile: widget.imageFile!),
                                //   builder: (context, snapshot) {
                                //     if (snapshot.connectionState ==
                                //         ConnectionState.done)
                                //       return
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      width: 1.sw - 100,
                                      height: 464,
                                      // (snapshot.data!.width.w < 200.w)
                                      //     ? snapshot.data!.width.toDouble()
                                      //     : 200.w

                                      // (snapshot.data!.width.w / 3 >
                                      //             200.w)
                                      //         ? 200.w.toDouble()
                                      //         : snapshot.data!.width / 3
                                      // (snapshot.data!.height.h <
                                      //         200.h)
                                      //     ? snapshot.data!.height.toDouble()
                                      //     : 200.h

                                      // snapshot.data!.height / 3

                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(widget.imageFile!),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          width: 3.0,
                                          color: widget.isSent
                                              ? const Color(0xffFFF9B4)
                                              : const Color(0xffB4FFD9),
                                        ),
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(0, -3),
                                      child: Container(
                                        height: 40.h,
                                        width: 1.sw - 100,
                                        // (snapshot.data!.width.w < 200.w)
                                        //     ? snapshot.data!.width.toDouble()
                                        //     : 200.w,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment(0.0, 0),
                                            end: Alignment(0.0, 1.0),
                                            colors: [
                                              Color(0x00000000),
                                              Color(0xb2000000)
                                            ],
                                            stops: [0.0, 1.0],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              MyTextWidget(
                                                !widget.createAt!.isUtc
                                                    ? HelperFunctions
                                                        .getDateInFormat(
                                                            widget.createAt!)
                                                    : HelperFunctions
                                                        .getZonedDateInFormat(
                                                            widget.createAt!),
                                                style: context
                                                    .textTheme.titleSmall?.rr
                                                    .copyWith(
                                                        color: context
                                                            .colorScheme.white),
                                              ),
                                              if (widget.isSent) ...{
                                                10.horizontalSpace,
                                                (state.currentFailedMessage
                                                        .contains(
                                                            widget.messageId))
                                                    ? Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                chatBloc.add(ResendMessageEvent(
                                                                    messageType:
                                                                        "image",
                                                                    channelId:
                                                                        widget
                                                                            .channelId,
                                                                    messageId:
                                                                        widget
                                                                            .messageId));
                                                              },
                                                              child: Icon(
                                                                Icons.refresh,
                                                                size: 27.w,
                                                              )),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 5.w),
                                                            child: SvgPicture
                                                                .asset(
                                                              AppAssets
                                                                  .messageFailedSvg,
                                                              width: 10.sp,
                                                              height: 10.sp,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : SvgPicture.asset(
                                                        widget.isRead
                                                            ? AppAssets
                                                                .messageReadArrowSvg
                                                            : widget.isReceived
                                                                ? AppAssets
                                                                    .messageDeliveredArrowSvg
                                                                : (state.currentMessage
                                                                        .contains(widget
                                                                            .messageId))
                                                                    ? timer
                                                                        ? (state.currentMessage.contains(widget
                                                                                .messageId))
                                                                            ? AppAssets
                                                                                .sandClockSvg
                                                                            : AppAssets
                                                                                .messageSentArrowSvg
                                                                        : ""
                                                                    : AppAssets
                                                                        .messageSentArrowSvg,
                                                        width: 10.sp,
                                                        height: 10.sp,
                                                      )
                                              },
                                              if (widget.isForwarded) ...{
                                                10.horizontalSpace,
                                                SvgPicture.asset(
                                                  AppAssets.forwardedSvg,
                                                  width: 10.sp,
                                                  height: 10.sp,
                                                )
                                              }
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  //     );
                                  //   return CircularProgressIndicator();
                                  // },
                                ),
                              },
                              //todo until i solve the translate
                              widget.isFirstMessage
                                  ? Transform.translate(
                                      offset: Offset(
                                          widget.isSent ? 30.w : -30.w, 0),
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
                                                  color:
                                                      const Color(0xffEBFFF8),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              Container(
                                                width: 20.w,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xffEBFFF8),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ],
                                          ),
                                          widget.userMessagePhoto != null
                                              ? MyCachedNetworkImage(
                                                  imageUrl: ChatUrls.baseUrl +
                                                      widget.userMessagePhoto!,
                                                  imageFit: BoxFit.fitWidth,
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
                                                          color: const Color(
                                                              0xff6638FF),
                                                          letterSpacing: 0.18,
                                                          height: 1.33),
                                                  radius: 8,
                                                  name: widget.userMessageName),
                                        ],
                                        //     );
                                        //   return CircularProgressIndicator();
                                        // },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              state.isSlpoing &&
                                      state.slopMessageId!
                                          .contains(widget.messageId)
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
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: 1.sw - 100,),
                          child: MyTextWidget(
                            widget.productName,
                            style: context.textTheme.labelSmall?.mr,
                          ),
                        ),
                        10.verticalSpace,
                        Container(
                          constraints: BoxConstraints(maxWidth: 1.sw - 100,),
                          child: Html(
                            shrinkWrap: true,
                            data: widget.productDescription,
                            style: {
                              "body": Style(margin: Margins.all(0)),
                              "p": Style(
                                maxLines: 1,
                                margin: Margins.all(0),
                              ),
                            },
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
    );
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
    } catch (e, s) {
      // GetIt.I<StoryBloc>().add(LoadFailureEvent());
    }
    return completer.future;
  }
}
