import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import 'no_image_widget.dart';

class DocumentMessage extends StatefulWidget {
  DocumentMessage({Key? key,
    this.isForwarded = false,
    this.isLocalMessage = true,
    required this.isSent,
    required this.time,
    required this.isRead,
    required this.senderId,
    required this.fileName,
    this.userMessagePhoto,
    this.documentFile,
    this.documentFileUrl,
    required this.userMessageName,
    required this.messageId,
    required this.isReceived,
    required this.isFirstMessage})
      : super(key: key);
  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  final String messageId;
  File? documentFile;
  final bool isLocalMessage;
  final String? documentFileUrl;
  final DateTime time;
   bool isRead;
   bool isReceived;
  final int senderId;
  final String? userMessagePhoto;
  final String userMessageName;
  final String fileName;

  @override
  State<DocumentMessage> createState() => _DocumentMessageState();
}

class _DocumentMessageState extends State<DocumentMessage> {
  final ValueNotifier<int> _loadingFile = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (p, c) =>
        p.changeMessageStateFromPusherStatus !=
            c.changeMessageStateFromPusherStatus &&
            c.changeMessageStateFromPusherStatus !=
                ChangeMessageStateFromPusherStatus.init,
        listener: (context, state) {
          if (state.changeMessageStateFromPusherStatus==ChangeMessageStateFromPusherStatus.watched){
            if(widget.isRead){
              return;
            }
            setState(() {
              widget.isRead=true;
            });
          }else if(!widget.isReceived){
            setState(() {
              widget.isReceived=true;
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: HWEdgeInsets.only(
                right: widget.isSent ? 25.w : 0,
                left: widget.isSent ? 0 : 25.w),
            child: SwipeTo(
              iconSize: 0,
              animationDuration: const Duration(milliseconds: 100),
              offsetDx: 0.15,
              onRightSwipe: () {
                if ((state.sendMessageStatus ==
                    SendMessageStatus.loading &&
                    state.currentMessage
                        .contains(widget.messageId))) {
                  return;
                }
                print(widget.time);
                BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                    true, 'file', widget.isSent,
                    senderParentMessageId: widget.senderId,
                    messageId: widget.messageId,
                    time: widget.time,
                    message: widget.fileName));
              },
              child: Row(
                mainAxisAlignment:
                widget.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment:
                    widget.isSent ? Alignment.centerRight : Alignment
                        .centerLeft,
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.documentFile != null) {
                            OpenFile.open(widget.documentFile!.path);
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          decoration: BoxDecoration(
                            color: widget.isSent
                                ? const Color(0xffFFF9B4)
                                : const Color(0xffB4FED9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: HWEdgeInsets.only(
                                left: widget.isSent ? 20.w : 40.w,
                                top: 10,
                                right: widget.isSent ? 40.w : 20.w),
                            child: IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: widget.isSent
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.documentSvg,
                                        width: 25,
                                        height: 25,
                                      ),
                                      10.horizontalSpace,
                                      Container(
                                        constraints:
                                        BoxConstraints(maxWidth: 310.w),
                                        child: SizedBox(
                                          width: 200.w,
                                          child: Text(
                                            widget.fileName,
                                            maxLines: 3,
                                            style: context.textTheme.bodyText2
                                                ?.rr
                                                .copyWith(
                                                color:
                                                const Color(0xffC4C2C2),
                                                overflow: TextOverflow.ellipsis,
                                                height: 1.43),
                                          ),
                                        ),
                                      ),
                                      if (widget.documentFile == null) ...{
                                        10.horizontalSpace,
                                        ValueListenableBuilder<int>(
                                            valueListenable: _loadingFile,
                                            builder: (context, status, _) {
                                              if (status == 0) {
                                                return InkWell(
                                                  onTap: () async {
                                                    _loadingFile.value = 1;
                                                  },
                                                  child: Icon(
                                                      Icons
                                                          .save_alt_outlined,
                                                      color: const Color(
                                                          0xff388CFF),
                                                      size: 35.sp),
                                                );
                                              } else if (status == 1) {
                                                FileSaving()
                                                    .downloadFileToLocalStorage(
                                                    widget.documentFileUrl!,
                                                    action: (File? file) {
                                                      _loadingFile.value = 2;
                                                      widget.documentFile =
                                                          file;
                                                      setState(() {

                                                      });
                                                    });
                                                return CircularProgressIndicator(
                                                  backgroundColor: Colors.grey
                                                      .shade100,
                                                  color:
                                                  const Color(0xff388CFF),
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            }),
                                      }
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Text(
                                          !widget.time.isUtc
                                              ? HelperFunctions.getDateInFormat(
                                              widget.time)
                                              : HelperFunctions
                                              .getZonedDateInFormat(
                                              widget.time),
                                          style: context.textTheme.overline?.rr
                                              .copyWith(
                                              color:
                                              const Color(0xffC4C2C2)),
                                        ),
                                        if (widget.isSent) ...{
                                          10.horizontalSpace,
                                          SvgPicture.asset(
                                            (state.currentMessage
                                                .contains(
                                                widget.messageId))
                                                ? AppAssets.sandClockSvg :
                                            (state.currentFailedMessage
                                                .contains(
                                                widget.messageId)) ?
                                            AppAssets.MessageFailedSvg: widget.isRead
                                                ? AppAssets
                                                .messageReadArrowSvg
                                                : widget.isReceived
                                                ? AppAssets
                                                .messageDeliveredArrowSvg
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      widget.isFirstMessage
                          ?
                     Transform.translate(
                       offset: Offset(widget.isSent ? 15.w : -15.w, 0),
                       child:
                        Stack(
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
                              imageUrl:
                              ChatUrls.baseUrl + widget.userMessagePhoto!,
                              progressIndicatorBuilderWidget: TrydosLoader(),
                              imageFit: BoxFit.cover,
                              radius: 8,
                              width: 30.w,
                              height: 30,
                            )
                                : NoImageWidget(
                                width: 30.w,
                                height: 30,
                                textStyle: context
                                    .textTheme.caption?.br
                                    .copyWith(
                                    color:
                                    const Color(0xff6638FF),
                                    letterSpacing: 0.18,
                                    height: 1.33),
                                radius: 8,
                                name: widget.userMessageName)
                          ],
                        )
                       ,
                     )
                          : const SizedBox.shrink()
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
