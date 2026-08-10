import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mime/mime.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/search/presentation/widgets/search_image_preview_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/core/utils/media_display_url.dart';
import 'package:trydos/service/language_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class StarRatingWidget extends StatefulWidget {
  final double initialRating;
  final String initialComment;
  final Function(double, String, List<String>) onRatingChanged;
  final bool isInteractive;
  final Color starColor;
  final Color emptyStarColor;
  final List<String>? initialImages;
  const StarRatingWidget({
    Key? key,
    this.initialRating = 0.0,
    this.initialComment = "",
    required this.onRatingChanged,
    this.initialImages = const [],
    this.emptyStarColor = Colors.white,
    this.isInteractive = true,
    this.starColor = const Color(0xFF402CDD),
  }) : super(key: key);

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late double _currentRating;
  late double _previousRating;
  Timer? _debounceTimer;
  late OrderBloc orderBloc;
  final TextEditingController _commentController = TextEditingController();

  // إضافة ValueNotifier للتحكم في حالة الزر
  late ValueNotifier<bool> _isCommentEmptyNotifier;
  final ValueNotifier<List<String>> orderPhotos = ValueNotifier([]);
  @override
  void initState() {
    super.initState();

    orderBloc = BlocProvider.of<OrderBloc>(context);

    _currentRating = widget.initialRating;
    _previousRating = widget.initialRating;
    _commentController.text = widget.initialComment;

    // تهيئة ValueNotifier
    _isCommentEmptyNotifier = ValueNotifier<bool>(true);

    // إضافة listener للتحقق من نص التعليق
    _commentController.addListener(_checkCommentEmpty);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _commentController.removeListener(_checkCommentEmpty);
    _commentController.dispose();
    _isCommentEmptyNotifier.dispose();
    orderPhotos.dispose();
    super.dispose();
  }

  // دالة للتحقق من أن التعليق فارغ أم لا
  void _checkCommentEmpty() {
    _isCommentEmptyNotifier.value =
        (_commentController.text.trim().isEmpty ||
        (_commentController.text == widget.initialComment &&
            _currentRating == widget.initialRating &&
            (widget.initialImages?.length == orderPhotos.value.length)));
  }

  @override
  void didUpdateWidget(StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating ||
        widget.initialComment != _commentController.text) {
      _currentRating = widget.initialRating;
      _previousRating = widget.initialRating;
      _commentController.text = widget.initialComment;
    }
  }

  void _debouncedRatingUpdate(double rating) {
    // إلغاء Timer السابق إذا كان موجود
    _debounceTimer?.cancel();

    // إنشاء Timer جديد لمدة ثانية واحدة
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (widget.initialImages?.isNotEmpty ?? false) {
        orderBloc.add(RemoveImagesForCommentEvent(-1, widget.initialImages));
      } else {
        orderBloc.add(const RemoveImagesForCommentEvent(-1, []));
      }

      _showCommentBottomSheet();
    });
  }

  void _showCommentBottomSheet() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // ignore: deprecated_member_use
      builder: (context) => WillPopScope(
        onWillPop: () async {
          if (mounted) {
            setState(() {
              _currentRating = _previousRating;
            });
            // إلغاء Timer إذا كان موجود
            _debounceTimer?.cancel();
          }
          return true;
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (!mounted) return;
                          setState(() {
                            _currentRating = _previousRating;
                          });
                          _debounceTimer?.cancel();
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    LocaleKeys.add_comment_for_rating.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  RatingBar.builder(
                    initialRating: _currentRating,
                    minRating: 1,
                    //allowHalfRating: false,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => SvgPicture.asset(
                      AppAssets.starFilledSvg,
                      width: 24.0,
                      height: 24.0,
                      colorFilter: ColorFilter.mode(
                        widget.starColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    unratedColor: Colors.grey[400],
                    onRatingUpdate: (rating) {
                      if (!mounted) return;
                      setState(() {
                        _currentRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.write_your_comment_here.tr(),
                      counterText:
                          "", // Hide the default counter if you want, but the requirement is just max limit.
                      // Actually, let's keep the counter or just set the limit.
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: widget.starColor),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 1.sw,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 0.5,
                    decoration: BoxDecoration(
                      color: const Color(0xffC4C2C2),
                      border: Border.all(color: const Color(0xffC4C2C2)),
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  BlocBuilder<OrderBloc, OrderState>(
                    buildWhen: (previous, current) =>
                        previous.uploadImagesToCloudinaryStatus !=
                        current.uploadImagesToCloudinaryStatus,
                    builder: (context, state) {
                      if (state.uploadImagesToCloudinaryStatus ==
                          UploadImagesToCloudinaryStatus.success) {
                        Future.delayed(
                          const Duration(milliseconds: 50),
                          () => orderPhotos.value = [
                            ...state.imagesForComment ?? [],
                          ],
                        );
                      }
                      return ValueListenableBuilder<List<String?>?>(
                        valueListenable: orderPhotos,
                        builder: (context, _orderPhotos, _) {
                          // Defer the check to after the build phase completes
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _checkCommentEmpty();
                          });
                          return SizedBox(
                            height: 175.h,
                            width: 1.sw,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 1.sw,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF8F8F8),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.r),
                                    ),
                                    border: (_orderPhotos?.length ?? 0) > 0
                                        ? null
                                        : Border.all(
                                            color: const Color(0xff402CDD),
                                          ),
                                  ),
                                  child:
                                      (_orderPhotos?.length ?? 0) > 0 ||
                                          (state.uploadImagesToCloudinaryStatus ==
                                              UploadImagesToCloudinaryStatus
                                                  .loading)
                                      ? Stack(
                                          children: [
                                            (state.uploadImagesToCloudinaryStatus ==
                                                    UploadImagesToCloudinaryStatus
                                                        .loading)
                                                ? ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        orderPhotos
                                                            .value
                                                            .length +
                                                        1,
                                                    itemBuilder: (context, index) {
                                                      if (index ==
                                                          orderPhotos
                                                              .value
                                                              .length) {
                                                        return Shimmer.fromColors(
                                                          baseColor: Colors
                                                              .grey
                                                              .shade300,
                                                          highlightColor: Colors
                                                              .grey
                                                              .shade50,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        15.r,
                                                                      ),
                                                                ),
                                                            width: 57,
                                                            height: 80,
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        width: 57,

                                                        height: 80,
                                                        margin: EdgeInsets.only(
                                                          right:
                                                              LanguageService
                                                                      .languageCode ==
                                                                  "ar"
                                                              ? 0
                                                              : 5,
                                                          left:
                                                              LanguageService
                                                                      .languageCode !=
                                                                  "ar"
                                                              ? 0
                                                              : 5,
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius.all(
                                                                    Radius.circular(
                                                                      12,
                                                                    ),
                                                                  ),
                                                              child: MyCachedNetworkImage(
                                                                imageUrl:
                                                                    mediaDisplayUrl(
                                                                      _orderPhotos![index]!,
                                                                      legacyFolder:
                                                                          'rating_orders',
                                                                    ),
                                                                imageFit:
                                                                    BoxFit.fill,
                                                                width: 57,
                                                                height: 80,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  orderBloc.add(
                                                                    RemoveImagesForCommentEvent(
                                                                      index,
                                                                      const [],
                                                                    ),
                                                                  );
                                                                },
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        2,
                                                                      ),
                                                                  width: 15,
                                                                  height: 15,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),

                                                                  child: SvgPicture.asset(
                                                                    AppAssets
                                                                        .cancelSvg,

                                                                    // ignore: deprecated_member_use
                                                                    height: 5,
                                                                    width: 5,
                                                                  ),
                                                                ),
                                                              ),
                                                              right: 0,
                                                              top: 0,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: orderPhotos
                                                        .value
                                                        .length,
                                                    itemBuilder: (context, index) {
                                                      return Container(
                                                        width: 57,
                                                        height: 80,
                                                        margin: EdgeInsets.only(
                                                          right:
                                                              LanguageService
                                                                      .languageCode ==
                                                                  "ar"
                                                              ? 0
                                                              : 5,
                                                          left:
                                                              LanguageService
                                                                      .languageCode !=
                                                                  "ar"
                                                              ? 0
                                                              : 5,
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius.all(
                                                                    Radius.circular(
                                                                      12,
                                                                    ),
                                                                  ),
                                                              child: MyCachedNetworkImage(
                                                                imageUrl:
                                                                    mediaDisplayUrl(
                                                                      _orderPhotos![index]!,
                                                                      legacyFolder:
                                                                          'rating_orders',
                                                                    ),
                                                                imageFit:
                                                                    BoxFit.fill,
                                                                width: 57,
                                                                height: 80,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  orderBloc.add(
                                                                    RemoveImagesForCommentEvent(
                                                                      index,
                                                                      const [],
                                                                    ),
                                                                  );
                                                                },
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        2,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  width: 15,
                                                                  height: 15,
                                                                  child: SvgPicture.asset(
                                                                    AppAssets
                                                                        .cancelSvg,

                                                                    // ignore: deprecated_member_use
                                                                    height: 5,
                                                                    width: 5,
                                                                  ),
                                                                ),
                                                              ),
                                                              right: 0,
                                                              top: 0,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                            Positioned(
                                              right:
                                                  LanguageService
                                                          .languageCode ==
                                                      "ar"
                                                  ? null
                                                  : 20,
                                              left:
                                                  LanguageService
                                                          .languageCode !=
                                                      "ar"
                                                  ? null
                                                  : 20,
                                              top: 30,
                                              child: InkWell(
                                                onTap: () async {
                                                  void _showImagePreview(
                                                    File imageFile,
                                                  ) {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext context) {
                                                        return SearchImagePreviewWidget(
                                                          imageFile: imageFile,
                                                          onSend: (File file) {
                                                            orderBloc.add(
                                                              UploadImagesToCloudinaryEvent(
                                                                file,
                                                              ),
                                                            );
                                                          },
                                                          onCancel: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                        );
                                                      },
                                                    );
                                                  }

                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return GalleryAndCameraDialogWidget(
                                                        fromChat:
                                                            true, // تفعيل معاينة الصور
                                                        onChooseFileFromGalleryAction:
                                                            (
                                                              AssetEntity?
                                                              assetEntity,
                                                            ) async {
                                                              if (assetEntity !=
                                                                  null) {
                                                                // originFile
                                                                // يرجع null
                                                                // للملفات غير
                                                                // المقروءة.
                                                                final File?
                                                                pickedFile =
                                                                    await assetEntity
                                                                        .originFile;
                                                                if (pickedFile ==
                                                                    null) {
                                                                  showWarningMessage(
                                                                    context,
                                                                    LocaleKeys
                                                                        .error_picking_file
                                                                        .tr(),
                                                                  );
                                                                  return;
                                                                }
                                                                File file =
                                                                    pickedFile;
                                                                String mimeStr =
                                                                    lookupMimeType(
                                                                      file
                                                                          .absolute
                                                                          .path,
                                                                    ) ??
                                                                    '';
                                                                var fileType =
                                                                    mimeStr
                                                                        .split(
                                                                          '/',
                                                                        );

                                                                if (fileType[0] !=
                                                                    'image') {
                                                                  showErrorMessage(
                                                                    context,
                                                                    LocaleKeys
                                                                        .video_file_not_supported
                                                                        .tr(),
                                                                  );
                                                                } else {
                                                                  // إغلاق ديالوج الاختيار
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                  // تأخير صغير لضمان إغلاق الديالوج
                                                                  await Future.delayed(
                                                                    const Duration(
                                                                      milliseconds:
                                                                          100,
                                                                    ),
                                                                  );
                                                                  // عرض معاينة الصورة
                                                                  _showImagePreview(
                                                                    file,
                                                                  );
                                                                }
                                                              }
                                                            },
                                                        onChooseFileFromCameraAction: (File? file) async {
                                                          if (file != null) {
                                                            String mimeStr =
                                                                lookupMimeType(
                                                                  file
                                                                      .absolute
                                                                      .path,
                                                                ) ??
                                                                '';
                                                            var fileType =
                                                                mimeStr.split(
                                                                  '/',
                                                                );
                                                            if (fileType[0] !=
                                                                'image') {
                                                              showErrorMessage(
                                                                context,
                                                                LocaleKeys
                                                                    .video_file_not_supported
                                                                    .tr(),
                                                              );
                                                            } else {
                                                              // إغلاق ديالوج الاختيار
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                              // تأخير صغير لضمان إغلاق الديالوج
                                                              await Future.delayed(
                                                                const Duration(
                                                                  milliseconds:
                                                                      100,
                                                                ),
                                                              );
                                                              // عرض معاينة الصورة
                                                              _showImagePreview(
                                                                file,
                                                              );
                                                            }
                                                          }
                                                        },
                                                        onImagePreviewAction:
                                                            (File image) {
                                                              // هذا سيتم استدعاؤه تلقائياً من GalleryAndCameraDialogWidget
                                                              // عندما fromChat = true
                                                              _showImagePreview(
                                                                image,
                                                              );
                                                            },
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      AppAssets.addPhotoSvg,
                                                      // ignore: deprecated_member_use
                                                      color: const Color(
                                                        0xff402CDD,
                                                      ),
                                                      width: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : InkWell(
                                          onTap: () async {
                                            void _showImagePreview(
                                              File imageFile,
                                            ) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return SearchImagePreviewWidget(
                                                    imageFile: imageFile,
                                                    onSend: (File file) {
                                                      orderBloc.add(
                                                        UploadImagesToCloudinaryEvent(
                                                          file,
                                                        ),
                                                      );
                                                    },
                                                    onCancel: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                  );
                                                },
                                              );
                                            }

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return GalleryAndCameraDialogWidget(
                                                  fromChat:
                                                      true, // تفعيل معاينة الصور
                                                  onChooseFileFromGalleryAction:
                                                      (
                                                        AssetEntity?
                                                        assetEntity,
                                                      ) async {
                                                        if (assetEntity !=
                                                            null) {
                                                          // originFile يرجع
                                                          // null للملفات غير
                                                          // المقروءة.
                                                          final File?
                                                          pickedFile =
                                                              await assetEntity
                                                                  .originFile;
                                                          if (pickedFile ==
                                                              null) {
                                                            showWarningMessage(
                                                              context,
                                                              LocaleKeys
                                                                  .error_picking_file
                                                                  .tr(),
                                                            );
                                                            return;
                                                          }
                                                          File file =
                                                              pickedFile;
                                                          String mimeStr =
                                                              lookupMimeType(
                                                                file
                                                                    .absolute
                                                                    .path,
                                                              ) ??
                                                              '';
                                                          var fileType = mimeStr
                                                              .split('/');

                                                          if (fileType[0] !=
                                                              'image') {
                                                            showErrorMessage(
                                                              context,
                                                              LocaleKeys
                                                                  .video_file_not_supported
                                                                  .tr(),
                                                            );
                                                          } else {
                                                            // إغلاق ديالوج الاختيار
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            // تأخير صغير لضمان إغلاق الديالوج
                                                            await Future.delayed(
                                                              const Duration(
                                                                milliseconds:
                                                                    100,
                                                              ),
                                                            );
                                                            // عرض معاينة الصورة
                                                            _showImagePreview(
                                                              file,
                                                            );
                                                          }
                                                        }
                                                      },
                                                  onChooseFileFromCameraAction:
                                                      (File? file) async {
                                                        if (file != null) {
                                                          String mimeStr =
                                                              lookupMimeType(
                                                                file
                                                                    .absolute
                                                                    .path,
                                                              ) ??
                                                              '';
                                                          var fileType = mimeStr
                                                              .split('/');
                                                          if (fileType[0] !=
                                                              'image') {
                                                            showErrorMessage(
                                                              context,
                                                              LocaleKeys
                                                                  .video_file_not_supported
                                                                  .tr(),
                                                            );
                                                          } else {
                                                            // إغلاق ديالوج الاختيار
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            // تأخير صغير لضمان إغلاق الديالوج
                                                            await Future.delayed(
                                                              const Duration(
                                                                milliseconds:
                                                                    100,
                                                              ),
                                                            );
                                                            // عرض معاينة الصورة
                                                            _showImagePreview(
                                                              file,
                                                            );
                                                          }
                                                        }
                                                      },
                                                  onImagePreviewAction:
                                                      (File image) {
                                                        // هذا سيتم استدعاؤه تلقائياً من GalleryAndCameraDialogWidget
                                                        // عندما fromChat = true
                                                        _showImagePreview(
                                                          image,
                                                        );
                                                      },
                                                );
                                              },
                                            );
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                AppAssets.addPhotoSvg,
                                                // ignore: deprecated_member_use
                                                color: const Color(0xff402CDD),
                                                width: 20,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "${LocaleKeys.add_photo.tr()}",
                                                textAlign: TextAlign.center,
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff402CDD,
                                                      ),
                                                      letterSpacing: 0.18,
                                                      fontSize: 10,
                                                      height: 1.3,
                                                    ),
                                              ),
                                            ],
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (!mounted) return;
                            setState(() {
                              _currentRating = _previousRating;
                            });
                            _debounceTimer?.cancel();
                          },
                          child: Text(
                            LocaleKeys.cancel.tr(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BlocBuilder<OrderBloc, OrderState>(
                          buildWhen: (previous, current) =>
                              previous.uploadImagesToCloudinaryStatus !=
                              current.uploadImagesToCloudinaryStatus,
                          builder: (context, state) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: _isCommentEmptyNotifier,
                              builder: (context, isCommentEmpty, child) {
                                if (state.uploadImagesToCloudinaryStatus ==
                                    UploadImagesToCloudinaryStatus.loading) {
                                  return ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isCommentEmpty
                                          ? Colors.grey[400]
                                          : widget.starColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: TrydosLoader(size: 16),
                                  );
                                }
                                return ElevatedButton(
                                  onPressed: isCommentEmpty
                                      ? null
                                      : () {
                                          Navigator.pop(context);
                                          if (!mounted) return;
                                          widget.onRatingChanged(
                                            _currentRating,
                                            _commentController.text,
                                            orderPhotos.value,
                                          );
                                          _previousRating = _currentRating;
                                          _commentController.clear();
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCommentEmpty
                                        ? Colors.grey[400]
                                        : widget.starColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.initialRating > 0
                                            ? LocaleKeys.edit.tr()
                                            : LocaleKeys.add.tr(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.send, size: 18),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return SizedBox(
      width: 80,
      height: 26,
      child: RatingBar.builder(
        initialRating: _currentRating,
        maxRating: 5,
        wrapAlignment: WrapAlignment.center,

        itemSize: 16,
        ignoreGestures: !widget.isInteractive,
        itemBuilder: (context, index) {
          // حساب التقييم الحالي لهذه النجمة
          final starValue = index + 1.0;
          final isFullStar = _currentRating >= starValue;
          final isHalfStar =
              _currentRating >= (starValue - 0.5) && _currentRating < starValue;

          if (isFullStar || isHalfStar) {
            // نجمة ممتلئة أو نصف ممتلئة
            return Container(
              width: 20.0, // منطقة لمس أكبر
              height: 20.0,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.starFilledSvg,
                  width: 16.0,
                  height: 16.0,
                  colorFilter: ColorFilter.mode(
                    widget.starColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            );
          } else {
            return Container(
              width: 20, // منطقة لمس أكبر
              height: 20,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.starOutlineSvg,
                  width: 16.0,
                  height: 16.0,
                ),
              ),
            );
          }
        },
        onRatingUpdate: (rating) {
          // حفظ التقييم السابق قبل التحديث
          _previousRating = _currentRating;
          setState(() {
            _currentRating = rating;
          });
          _debouncedRatingUpdate(rating);
        },
      ),
    );
  }
}
