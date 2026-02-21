// import 'dart:io';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
// import 'package:get_it/get_it.dart';
// import 'package:swipe_to/swipe_to.dart';
// import 'package:trydos/common/constant/constant.dart';
// import 'package:trydos/common/helper/helper_functions.dart';
// import 'package:trydos/config/theme/my_color_scheme.dart';
// import 'package:trydos/config/theme/typography.dart';
// import 'package:trydos/core/utils/extensions/build_context.dart';
// import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
// import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
// import '../../../../../common/helper/file_saving.dart';
// import '../../../../../core/domin/repositories/prefs_repository.dart';
// import '../../../../../core/utils/responsive_padding.dart';
// import '../../../../app/blocs/app_bloc/app_bloc.dart';
// import '../../../../app/blocs/app_bloc/app_event.dart';
// import '../../../../app/my_cached_network_image.dart';
// import '../../../data/models/ImageDetail.dart';
// import 'features/chat/data/models/ImageDetail.dart';
// import 'no_image_widget.dart';
//
// class ImageMessage extends StatefulWidget {
//   ImageMessage(
//       {Key? key,
//       this.isForwarded = false,
//       this.isLocalMessage = true,
//       required this.isSent,
//       required this.time,
//       required this.isRead,
//       required this.senderId,
//       this.userMessagePhoto,
//       this.imageFile,
//       this.imageUrl,
//       required this.userMessageName,
//       required this.messageId,
//       required this.isReceived,
//       required this.isFirstMessage})
//       : super(key: key);
//   final bool isSent;
//   final bool isFirstMessage;
//   final bool isForwarded;
//   final String messageId;
//   File? imageFile;
//   final bool isLocalMessage;
//   final String? imageUrl;
//   final DateTime time;
//   bool isRead;
//   bool isReceived;
//   final int senderId;
//   final String? userMessagePhoto;
//   final String userMessageName;
//
//   @override
//   State<ImageMessage> createState() => _ImageMessageState();
// }
//
// class _ImageMessageState extends State<ImageMessage> {
//   final ValueNotifier<int> _loadingImage = ValueNotifier(0);
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     debugPrint(widget.imageFile);
//     FlutterError.onError = (FlutterErrorDetails error) {
//       GetIt.I<PrefsRepository>().saveRequestsData(
//           null, null, null, null, null, null, null,
//           error: error.toString());
//     };
//     debugPrint('widget.isLocalMessage ${widget.isLocalMessage}');
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: BlocConsumer<ChatBloc, ChatState>(
//         listenWhen: (p, c) =>
//             p.changeMessageStateFromPusherStatus !=
//                 c.changeMessageStateFromPusherStatus &&
//             c.changeMessageStateFromPusherStatus !=
//                 ChangeMessageStateFromPusherStatus.init,
//         listener: (context, state) {
//           if (state.changeMessageStateFromPusherStatus ==
//               ChangeMessageStateFromPusherStatus.watched) {
//             if (widget.isRead) {
//               return;
//             }
//             setState(() {
//               widget.isRead = true;
//             });
//           } else if (!widget.isReceived) {
//             setState(() {
//               widget.isReceived = true;
//             });
//           }
//         },
//         builder: (context, state) {
//           return Padding(
//             padding: HWEdgeInsets.only(
//                 right: widget.isSent ? 25.w : 0,
//                 left: widget.isSent ? 0 : 25.w),
//             child: SwipeTo(
//               iconSize: 0,
//               animationDuration: const Duration(milliseconds: 100),
//               offsetDx: 0.15,
//               onRightSwipe: () {
//                 if ((state.sendMessageStatus == SendMessageStatus.loading &&
//                     state.currentMessage.contains(widget.messageId))) {
//                   return;
//                 }
//                 BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
//                     true, 'image', widget.isSent,
//                     senderParentMessageId: widget.senderId,
//                     imageUrl: widget.imageUrl ?? widget.imageFile!.path,
//                     messageId: widget.messageId,
//                     time: widget.time,
//                     message: 'Photo'));
//               },
//               child: Row(
//                 mainAxisAlignment: widget.isSent
//                     ? MainAxisAlignment.end
//                     : MainAxisAlignment.start,
//                 children: [
//                   Stack(
//                     alignment: widget.isSent
//                         ? Alignment.centerRight
//                         : Alignment.centerLeft,
//                     children: [
//                       //     if (widget.imageFile == null)
//                       // // debugPrint('asdas');
//
//                       if (widget.imageFile == null) ...{
//                         Container(
//                             width: 300.w,
//                             height: 600,
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(12.0),
//                               border: Border.all(
//                                 width: 3.0,
//                                 color: widget.isSent
//                                     ? const Color(0xffFFF9B4)
//                                     : const Color(0xffB4FFD9),
//                               ),
//                             ),
//                             child: Center(
//                                 child: ValueListenableBuilder<int>(
//                                     valueListenable: _loadingImage,
//                                     builder: (context, status, _) {
//                                       FileSaving().downloadFileToLocalStorage(
//                                           widget.imageUrl!,
//                                           action: (File? file) {
//                                         // _loadingImage.value = 2;
//                                         widget.imageFile = file;
//                                         setState(() {});
//                                       });
//                                       return CircularProgressIndicator(
//                                         backgroundColor: Colors.grey.shade100,
//                                         color: const Color(0xff388CFF),
//                                       );
//                                     })))
//                       } else ...{
//                         FutureBuilder(
//                           future: loadWidthAndHeightForImage(
//                               ImageFile: widget.imageFile!),
//                           builder: (context, snapshot) {
//                             return Stack(
//                               alignment: Alignment.bottomCenter,
//                               children: [
//                                 FullScreenWidget(
//                                   backgroundColor: widget.isSent
//                                       ? const Color(0xffFFF9B4)
//                                       : const Color(0xffB4FFD9),
//                                   child: Hero(
//                                     tag: "hero${DateTime.now()}",
//                                     child: snapshot.connectionState ==
//                                             ConnectionState.waiting
//                                         ? Container(
//                                             width: 300.w,
//                                             height: 600.h,
//                                             decoration: BoxDecoration(
//                                               // image: DecorationImage(
//                                               //   image: FileImage(widget.imageFile!),
//                                               //   fit: BoxFit.fitWidth,
//                                               // ),
//                                               borderRadius:
//                                                   BorderRadius.circular(12.0),
//                                               border: Border.all(
//                                                 width: 3.0,
//                                                 color: widget.isSent
//                                                     ? const Color(0xffFFF9B4)
//                                                     : const Color(0xffB4FFD9),
//                                               ),
//                                             ),
//                                             child: CircularProgressIndicator(),
//                                           )
//                                         : Container(
//                                             decoration: BoxDecoration(
//                                               // image: DecorationImage(
//                                               //   image: FileImage(
//                                               //       widget.imageFile!),
//                                               //   fit: BoxFit.cover,
//                                               // ),
//                                               borderRadius:
//                                                   BorderRadius.circular(12.0),
//                                               border: Border.all(
//                                                 width: 3.0,
//                                                 color: widget.isSent
//                                                     ? const Color(0xffFFF9B4)
//                                                     : const Color(0xffB4FFD9),
//                                               ),
//                                             ),
//                                             child: Image.file(widget.imageFile!,
//                                                 height: snapshot.data!.height
//                                                         .toDouble() /
//                                                     2,
//                                                 width: snapshot.data!.width
//                                                         .toDouble() /
//                                                     2),
//                                           ),
//                                   ),
//                                 ),
//                                 // Transform.translate(
//                                 //   offset: const Offset(0, -3),
//                                 //   child: Container(
//                                 //     height: 50,
//                                 //     width: 300.w - 6,
//                                 //     decoration: BoxDecoration(
//                                 //       gradient: const LinearGradient(
//                                 //         begin: Alignment(0.0, 0),
//                                 //         end: Alignment(0.0, 1.0),
//                                 //         colors: [
//                                 //           Color(0x00000000),
//                                 //           Color(0xb2000000)
//                                 //         ],
//                                 //         stops: [0.0, 1.0],
//                                 //       ),
//                                 //       borderRadius: BorderRadius.circular(12.0),
//                                 //     ),
//                                 //     child: Padding(
//                                 //       padding: const EdgeInsets.symmetric(
//                                 //           vertical: 5, horizontal: 20),
//                                 //       child: Row(
//                                 //         crossAxisAlignment: CrossAxisAlignment.end,
//                                 //         children: [
//                                 //           MyTextWidget(
//                                 //             !widget.time.isUtc
//                                 //                 ? HelperFunctions.getDateInFormat(
//                                 //                 widget.time)
//                                 //                 : HelperFunctions
//                                 //                 .getZonedDateInFormat(
//                                 //                 widget.time),
//                                 //             style: context.textTheme.titleSmall?.rr
//                                 //                 .copyWith(
//                                 //                 color:
//                                 //                 context.colorScheme.white),
//                                 //           ),
//                                 //           if (widget.isSent) ...{
//                                 //             10.horizontalSpace,
//                                 //             SvgPicture.asset(
//                                 //               (state.currentMessage
//                                 //                   .contains(widget.messageId))
//                                 //                   ? AppAssets.sandClockSvg
//                                 //                   : (state.currentFailedMessage
//                                 //                   .contains(
//                                 //                   widget.messageId))
//                                 //                   ? AppAssets.MessageFailedSvg
//                                 //                   : widget.isRead
//                                 //                   ? AppAssets
//                                 //                   .messageReadArrowSvg
//                                 //                   : widget.isReceived
//                                 //                   ? AppAssets
//                                 //                   .messageDeliveredArrowSvg
//                                 //                   : AppAssets
//                                 //                   .messageSentArrowSvg,
//                                 //               color: context.colorScheme.white,
//                                 //               width: 10.sp,
//                                 //               height: 10.sp,
//                                 //             )
//                                 //           },
//                                 //           if (widget.isForwarded) ...{
//                                 //             10.horizontalSpace,
//                                 //             SvgPicture.asset(
//                                 //               AppAssets.forwardedSvg,
//                                 //               width: 10.sp,
//                                 //               height: 10.sp,
//                                 //             )
//                                 //           }
//                                 //         ],
//                                 //       ),
//                                 //     ),
//                                 //   ),
//                                 // ),
//                               ],
//                             );
//                           },
//                         )
//                       },
//                       //todo until i solve the translate
//                       widget.isFirstMessage
//                           ? Transform.translate(
//                               offset: Offset(widget.isSent ? 15.w : -15.w, 0),
//                               child: Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   Stack(
//                                     alignment: widget.isSent
//                                         ? Alignment.centerRight
//                                         : Alignment.centerLeft,
//                                     children: [
//                                       Container(
//                                         width: 40.w,
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xffEBFFF8),
//                                           border: Border.all(
//                                             width: 3.0,
//                                             color: widget.isSent
//                                                 ? const Color(0xffFFF9B4)
//                                                 : const Color(0xffB4FFD9),
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 20.w,
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xffEBFFF8),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   widget.userMessagePhoto != null
//                                       ? MyCachedNetworkImage(
//                                           imageUrl: ChatUrls.baseUrl +
//                                               widget.userMessagePhoto!,
//                                           imageFit: BoxFit.fitWidth,
//                                           radius: 8,
//                                           width: 30.w,
//                                           height: 30,
//                                         )
//                                       : NoImageWidget(
//                                           width: 30.w,
//                                           height: 30,
//                                           textStyle: context
//                                               .textTheme.titleMedium?.br
//                                               .copyWith(
//                                                   color:
//                                                       const Color(0xff6638FF),
//                                                   letterSpacing: 0.18,
//                                                   height: 1.33),
//                                           radius: 8,
//                                           name: widget.userMessageName)
//                                 ],
//                               ),
//                             )
//                           : const SizedBox.shrink()
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<Image> loadWidthAndHeightForImage() async {
//     late File ImageFile = File('asd');
//     await FileSaving().downloadFileToLocalStorage(widget.imageUrl!,
//         action: (File file) {
//       ImageFile = file;
//
//     });
//     Completer<Image> completer = Completer<Image>();
//
//     completer = Completer<Image>();
//     Image image;
//     image = Image.file(ImageFile);
//     try {
//       image.image
//           .resolve(const ImageConfiguration())
//           .addListener(ImageStreamListener(
//             (
//               ImageInfo imageInfo,
//               bool _,
//             ) {
//               final dimensions = Image.file(ImageFile);
//               dimensions.width = imageInfo.image.width;
//               if (completer.isCompleted == false) {
//                 completer.complete(dimensions);
//               }
//             },
//             onError: (exception, stackTrace) {},
//           ));
//     } catch (e, s) {
//       // GetIt.I<StoryBloc>().add(LoadFailureEvent());
//     }
//     return completer.future;
//   }
// }
