import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mime_type/mime_type.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../bloc/dashBoard_bloc.dart';
import 'empty_state_widget.dart';

/// Stories tab of the seller dashboard.
///
/// Story creation reuses the shared dashboard upload flow instead of a
/// dedicated one: pick image -> [UploadDocumentEvent] (presigned url + S3 put)
/// -> `uploadedDocumentKey` -> [CreateSellerStoryEvent] -> stories refresh.
class SellerStoriesWidget extends StatefulWidget {
  const SellerStoriesWidget({Key? key}) : super(key: key);

  @override
  State<SellerStoriesWidget> createState() => _SellerStoriesWidgetState();
}

class _SellerStoriesWidgetState extends State<SellerStoriesWidget> {
  late DashboardBloc _dashboardBloc;

  /// True between picking an image and the upload result landing, so the
  /// shared upload states are only consumed when they belong to a story.
  bool _isUploadingStory = false;

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
    // The bloc is a singleton, so clear the shared upload/create statuses to
    // avoid a stale success being observed the next time the tab is opened.
    _dashboardBloc.add(ResetCreateStoryStateEvent());
    super.dispose();
  }

  Future<void> _pickAndUploadStoryImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    final filePath = result?.files.single.path;
    if (filePath == null) {
      return;
    }

    final fileName = result!.files.single.name;
    final mimeType = mime(fileName) ?? 'image/jpeg';

    setState(() {
      _isUploadingStory = true;
    });

    _dashboardBloc.add(
      UploadDocumentEvent(filePath: filePath, mimeType: mimeType),
    );
  }

  void _onUploadStateChanged(BuildContext context, DashBoardState state) {
    if (!_isUploadingStory) {
      return;
    }

    if (state.uploadDocumentStatus == UploadDocumentStatus.success) {
      final key = state.uploadedDocumentKey;
      setState(() {
        _isUploadingStory = false;
      });

      if (key == null || key.isEmpty) {
        return;
      }

      // Step 2: create the story with the key returned by the upload flow.
      _dashboardBloc.add(CreateSellerStoryEvent(mediaKey: key));
    } else if (state.uploadDocumentStatus == UploadDocumentStatus.failure) {
      setState(() {
        _isUploadingStory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashBoardState>(
      listenWhen: (previous, current) =>
          previous.uploadDocumentStatus != current.uploadDocumentStatus,
      listener: _onUploadStateChanged,
      child: BlocBuilder<DashboardBloc, DashBoardState>(
        buildWhen: (previous, current) =>
            previous.storiesStatus != current.storiesStatus ||
            previous.createStoryStatus != current.createStoryStatus ||
            previous.uploadDocumentStatus != current.uploadDocumentStatus ||
            previous.stories != current.stories,
        builder: (context, state) {
          final isBusy =
              (_isUploadingStory &&
                  state.uploadDocumentStatus == UploadDocumentStatus.loading) ||
              state.createStoryStatus == CreateSellerStoryStatus.loading;

          return Stack(
            children: [
              _buildContent(state),
              if (isBusy) _buildUploadOverlay(state),
            ],
          );
        },
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
        onActionPressed: _pickAndUploadStoryImage,
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _dashboardBloc.add(GetSellerStoriesEvent()),
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.62,
              ),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                return SellerStoryCard(story: stories[index]);
              },
            ),
          ),
        ),
        _buildAddStoryButton(),
      ],
    );
  }

  Widget _buildAddStoryButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _pickAndUploadStoryImage,
          icon: Icon(Icons.add_a_photo_outlined, size: 18.sp),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3366FF),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          label: Text(
            LocaleKeys.add_story.tr(),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOverlay(DashBoardState state) {
    final isCreating =
        state.createStoryStatus == CreateSellerStoryStatus.loading;

    return Positioned.fill(
      child: ColoredBox(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.35),
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
                  isCreating
                      ? LocaleKeys.add_story.tr()
                      : LocaleKeys.upload_document.tr(),
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

class SellerStoryCard extends StatelessWidget {
  final SellerStoryModel story;

  const SellerStoryCard({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = story.mediaUrl ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
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
              width: 1.sw / 3,
              height: 180.h,
              imageFit: BoxFit.cover,
              fromStory: true,
            ),
          Positioned(
            left: 6.w,
            right: 6.w,
            bottom: 6.h,
            child: Row(
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 14.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 4.w),
                Text(
                  (story.viewsCount ?? 0).toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
