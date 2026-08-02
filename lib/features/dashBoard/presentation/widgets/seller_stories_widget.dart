import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mime_type/mime_type.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart'
    as products_model;
import 'package:trydos/features/dashBoard/presentation/widgets/StoryVideoPopup.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../bloc/dashBoard_bloc.dart';
import 'empty_state_widget.dart';

// ---------------------------------------------------------------------------
// Design tokens (picked to match the mockups)
// ---------------------------------------------------------------------------
const Color _kDarkPill = Color(0xFF2E3440);
const Color _kBlue = Color(0xFF3366FF);
const Color _kGreen = Color(0xFF1E9E5A);
const Color _kLightGrey = Color(0xFFF1F2F4);
const Color _kBorderGrey = Color(0xFFD7DAE0);
const Color _kRed = Color(0xFFE9564F);

/// Backend limit for a story file (10 MB).
const int _kMaxStoryFileBytes = 10 * 1024 * 1024;

/// Stories tab of the seller dashboard.
///
/// Story creation: pick image/video -> [CreateSellerStoryEvent], which uploads
/// the media to the media server (folder `stories`) and then posts
/// `add-seller-story` with the returned url, before refreshing the list.
class SellerStoriesWidget extends StatefulWidget {
  const SellerStoriesWidget({Key? key}) : super(key: key);

  @override
  State<SellerStoriesWidget> createState() => _SellerStoriesWidgetState();
}

class _SellerStoriesWidgetState extends State<SellerStoriesWidget> {
  late DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);

    if (_dashboardBloc.state.storiesStatus == GetSellerStoriesStatus.init) {
      _dashboardBloc.add(GetSellerStoriesEvent());
    }
  }

  @override
  void dispose() {
    // The bloc is a singleton, so clear the create/delete statuses to avoid a
    // stale success being observed the next time the tab is opened.
    _dashboardBloc.add(ResetCreateStoryStateEvent());
    super.dispose();
  }

  Future<void> _openAddStoryDialog() async {
    final result = await showDialog<_AddStoryDialogResult>(
      context: context,
      builder: (_) => const _AddStoryDialog(),
    );

    if (result == null) return;

    _dashboardBloc.add(
      CreateSellerStoryEvent(
        file: File(result.filePath),
        isVideo: result.isVideo,
        link: result.link,
        productId: result.product?.id,
        productSlug: result.product?.slug,
      ),
    );
  }

  Future<void> _confirmDelete(SellerStoryModel story) async {
    if (story.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteStoryDialog(),
    );

    if (confirmed == true) {
      _dashboardBloc.add(DeleteSellerStoryEvent(storyId: story.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashBoardState>(
      buildWhen: (previous, current) =>
          previous.storiesStatus != current.storiesStatus ||
          previous.createStoryStatus != current.createStoryStatus ||
          previous.deleteStoryStatus != current.deleteStoryStatus ||
          previous.stories != current.stories,
      builder: (context, state) {
        final isBusy =
            state.createStoryStatus == CreateSellerStoryStatus.uploading ||
            state.createStoryStatus == CreateSellerStoryStatus.loading ||
            state.deleteStoryStatus == DeleteSellerStoryStatus.loading;

        return Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent(state)),
              ],
            ),
            if (isBusy) _buildUploadOverlay(state),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          Icon(Icons.menu_book_outlined, size: 20.sp, color: Colors.black87),
          SizedBox(width: 8.w),
          Text(
            LocaleKeys.stories.tr(),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          _DarkPillButton(
            icon: Icons.add,
            label: LocaleKeys.add_story.tr(),
            onPressed: _openAddStoryDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DashBoardState state) {
    final stories = state.stories ?? const <SellerStoryModel>[];

    if (state.storiesStatus == GetSellerStoriesStatus.loading &&
        stories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.storiesStatus == GetSellerStoriesStatus.failure &&
        stories.isEmpty) {
      return EmptyStateWidget(
        message: LocaleKeys.failed_to_load_stories.tr(),
        icon: Icons.error_outline,
        actionText: LocaleKeys.try_again.tr(),
        onActionPressed: () => _dashboardBloc.add(GetSellerStoriesEvent()),
      );
    }

    if (stories.isEmpty) {
      return EmptyStateWidget(
        title: LocaleKeys.no_stories_yet.tr(),
        message: LocaleKeys.click_to_add_story.tr(),
        icon: Icons.auto_stories_outlined,
        actionText: LocaleKeys.add_story.tr(),
        onActionPressed: _openAddStoryDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _dashboardBloc.add(GetSellerStoriesEvent()),
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 190.w,
          crossAxisSpacing: 14.w,
          mainAxisSpacing: 14.h,
          childAspectRatio: 0.45,
        ),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return SellerStoryCard(
            story: stories[index],
            onDelete: () => _confirmDelete(stories[index]),
          );
        },
      ),
    );
  }

  Widget _buildUploadOverlay(DashBoardState state) {
    final String label;
    if (state.deleteStoryStatus == DeleteSellerStoryStatus.loading) {
      label = LocaleKeys.delete_story.tr();
    } else if (state.createStoryStatus == CreateSellerStoryStatus.uploading) {
      label = LocaleKeys.upload_document.tr();
    } else {
      label = LocaleKeys.add_story.tr();
    }

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  label,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Story card
// ---------------------------------------------------------------------------

class SellerStoryCard extends StatelessWidget {
  final SellerStoryModel story;
  final VoidCallback onDelete;

  const SellerStoryCard({Key? key, required this.story, required this.onDelete})
    : super(key: key);

  String get _formattedDate {
    final raw = story.createdAt;
    if (raw == null || raw.isEmpty) return '';
    try {
      final date = DateTime.parse(raw);
      final mm = date.month.toString().padLeft(2, '0');
      final dd = date.day.toString().padLeft(2, '0');
      return '${date.year}-$mm-$dd';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = story.mediaUrl ?? '';
    final isVideo = story.isVideoStory;

    print('imageUrl @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ $imageUrl');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isVideo && imageUrl.isNotEmpty) {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black87,
                    builder: (_) => StoryVideoPopup(
                      videoUrl: story.fullVideoPath!,
                      thumbnailUrl: imageUrl,
                    ),
                  );
                } else if (imageUrl.isNotEmpty) {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black87,
                    builder: (_) => StoryImagePopup(imageUrl: imageUrl),
                  );
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isEmpty)
                    ColoredBox(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                        size: 28.sp,
                      ),
                    )
                  else
                    MyCachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 1.sw,
                      height: 1.sh,
                      imageFit: BoxFit.cover,
                      fromStory: true,
                    ),

                  // Type badge (top-left)
                  Positioned(
                    left: 6.w,
                    top: 6.h,
                    child: _InfoBadge(
                      icon: isVideo
                          ? Icons.videocam_outlined
                          : Icons.photo_outlined,
                      label: isVideo
                          ? LocaleKeys.video.tr()
                          : LocaleKeys.photo.tr(),
                    ),
                  ),

                  // Views badge (top-right)
                  Positioned(
                    right: 6.w,
                    top: 6.h,
                    child: _InfoBadge(
                      icon: Icons.remove_red_eye_outlined,
                      label: (story.viewersCount ?? 0).toString(),
                    ),
                  ),

                  // Play icon overlay for videos
                  if (isVideo)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),

                  // Date (bottom-left)
                  if (_formattedDate.isNotEmpty)
                    Positioned(
                      left: 6.w,
                      bottom: 6.h,
                      child: Text(
                        _formattedDate,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Linked product + delete
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
            child: Column(
              children: [
                if (story.hasLinkedProduct) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 13.sp,
                        color: _kGreen,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          // The list endpoint only returns the product id/slug;
                          // the name is used when the backend expands it.
                          story.productName ??
                              story.productSlug ??
                              LocaleKeys.linked_product.tr(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _kGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kRed,
                      side: BorderSide(color: _kRed.withValues(alpha: 0.5)),
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(Icons.delete_outline, size: 15.sp),
                    label: Text(
                      LocaleKeys.delete.tr(),
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: Colors.white),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _DarkPillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kDarkPill,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delete confirmation dialog
// ---------------------------------------------------------------------------

class _DeleteStoryDialog extends StatelessWidget {
  const _DeleteStoryDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: _kRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: _kRed, size: 26.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              LocaleKeys.delete_story.tr(),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              LocaleKeys.delete_story_confirmation.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 22.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _kLightGrey,
                      foregroundColor: Colors.black87,
                      side: BorderSide.none,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: Icon(Icons.delete_outline, size: 16.sp),
                    label: Text(
                      LocaleKeys.delete.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Story dialog
// ---------------------------------------------------------------------------

class _AddStoryDialogResult {
  final String filePath;
  final String fileName;
  final bool isVideo;
  final String? link;
  final products_model.Product? product;

  _AddStoryDialogResult({
    required this.filePath,
    required this.fileName,
    required this.isVideo,
    this.link,
    this.product,
  });
}

class _AddStoryDialog extends StatefulWidget {
  const _AddStoryDialog();

  @override
  State<_AddStoryDialog> createState() => _AddStoryDialogState();
}

class _AddStoryDialogState extends State<_AddStoryDialog> {
  final TextEditingController _linkController = TextEditingController();

  String? _filePath;
  String? _fileName;
  bool _isVideo = false;
  products_model.Product? _selectedProduct;

  bool get _hasMedia => _filePath != null;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.media);
    final path = result?.files.single.path;
    if (path == null) return;

    final name = result!.files.single.name;
    final mimeType = mime(name) ?? '';

    // Backend limit: a story file may not exceed 10 MB.
    final lengthInBytes = await File(path).length();
    if (lengthInBytes > _kMaxStoryFileBytes) {
      showMessage(
        LocaleKeys.photo_or_video_up_to_10mb.tr(),
        hasError: true,
        showInRelease: true,
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _filePath = path;
      _fileName = name;
      _isVideo = mimeType.startsWith('video/');
    });
  }

  Future<void> _pickProduct() async {
    final product = await showDialog<products_model.Product>(
      context: context,
      builder: (_) => const _SelectProductDialog(),
    );
    if (product != null) {
      setState(() => _selectedProduct = product);
    }
  }

  void _submit() {
    if (!_hasMedia) return;
    Navigator.of(context).pop(
      _AddStoryDialogResult(
        filePath: _filePath!,
        fileName: _fileName!,
        isVideo: _isVideo,
        link: _linkController.text,
        product: _selectedProduct,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book_outlined, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    LocaleKeys.add_story.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    splashRadius: 18,
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                LocaleKeys.preview.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 8.h),
              _buildPreviewBox(),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickMedia,
                  icon: Icon(Icons.file_upload_outlined, size: 17.sp),
                  label: Text(LocaleKeys.upload_photo_video.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kBlue,
                    side: BorderSide(color: _kBlue.withValues(alpha: 0.5)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                LocaleKeys.link.tr(),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: _linkController,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: LocaleKeys.add_link_hint.tr(),
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.link,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  ),
                  filled: true,
                  fillColor: _kLightGrey,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                LocaleKeys.linked_product.tr(),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: _pickProduct,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: _kLightGrey,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 17.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _selectedProduct?.name ??
                              LocaleKeys.link_to_product.tr(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: _selectedProduct == null
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        _selectedProduct == null
                            ? Icons.add
                            : Icons.check_circle,
                        size: 18.sp,
                        color: _selectedProduct == null
                            ? Colors.grey.shade500
                            : _kGreen,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _kLightGrey,
                        foregroundColor: Colors.black87,
                        side: BorderSide.none,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        LocaleKeys.cancel.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _hasMedia ? _submit : null,
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(
                        LocaleKeys.share_story.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasMedia
                            ? _kDarkPill
                            : Colors.grey.shade300,
                        foregroundColor: _hasMedia
                            ? Colors.white
                            : Colors.grey.shade500,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewBox() {
    return CustomPaint(
      painter: _DashedBorderPainter(color: _kBorderGrey, radius: 12.r),
      child: Container(
        width: double.infinity,
        height: 220.h,
        alignment: Alignment.center,
        child: _hasMedia
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: _isVideo
                    ? Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam,
                              size: 32.sp,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(height: 6.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                _fileName ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.sp),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.file(
                        File(_filePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: const BoxDecoration(
                      color: _kLightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.file_upload_outlined,
                      color: Colors.grey.shade600,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    LocaleKeys.no_media_selected.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    LocaleKeys.photo_or_video_up_to_10mb.tr(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Simple dashed rounded-rect border, drawn manually to avoid pulling in an
/// extra dependency just for the "Preview" placeholder box.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth = 6;
  final double dashSpace = 4;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.7, 0.7, size.width - 1.4, size.height - 1.4),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashedPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

// ---------------------------------------------------------------------------
// Select Product dialog
// ---------------------------------------------------------------------------

class _SelectProductDialog extends StatefulWidget {
  const _SelectProductDialog();

  @override
  State<_SelectProductDialog> createState() => _SelectProductDialogState();
}

class _SelectProductDialogState extends State<_SelectProductDialog> {
  late DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    if (_dashboardBloc.state.getProductsStatus == GetProductsStatus.init) {
      _dashboardBloc.add(GetProductsEvent());
    }
  }

  void _loadMore() {
    final nextPage = (_dashboardBloc.state.productsMeta?.currentPage ?? 1) + 1;
    _dashboardBloc.add(GetProductsEvent(page: nextPage));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w, maxHeight: 560.h),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    LocaleKeys.select_product.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    splashRadius: 18,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: BlocBuilder<DashboardBloc, DashBoardState>(
                  buildWhen: (previous, current) =>
                      previous.getProductsStatus != current.getProductsStatus ||
                      previous.products != current.products,
                  builder: (context, state) {
                    final products =
                        state.products ?? const <products_model.Product>[];

                    if (state.getProductsStatus == GetProductsStatus.loading &&
                        products.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (products.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: Text(
                            LocaleKeys.no_products_found.tr(),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  childAspectRatio: 0.50,
                                ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _ProductGridItem(
                                product: product,
                                onTap: () => Navigator.of(context).pop(product),
                              );
                            },
                          ),
                          SizedBox(height: 14.h),
                          if (state.getProductsStatus ==
                              GetProductsStatus.loading)
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            OutlinedButton(
                              onPressed: _loadMore,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _kBlue,
                                side: BorderSide(
                                  color: _kBlue.withValues(alpha: 0.5),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 10.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              child: Text(LocaleKeys.load_more.tr()),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final products_model.Product product;
  final VoidCallback onTap;

  const _ProductGridItem({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = product.images ?? const <String>[];
    final imageUrl = images.isNotEmpty ? images.first : '';
    final name = product.name ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _kBorderGrey),
          borderRadius: BorderRadius.circular(10.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: imageUrl.isEmpty
                  ? ColoredBox(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                      ),
                    )
                  : MyCachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 1.sw,
                      height: 1.sh,
                      imageFit: BoxFit.cover,
                    ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
              color: _kLightGrey,
              child: Text(
                name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
