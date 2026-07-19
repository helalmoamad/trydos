import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';

import '../../../../app/my_cached_network_image.dart';
import '../../../data/models/get_checklist_model.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_event.dart';
import '../../manager/homeBloc/home_state.dart';

/// Paginated view of `GET /checklist`.
///
/// The caller (profile page) issues the first `GetChecklistEvent` and only
/// navigates here once it succeeds, so this page starts with data already in
/// state and does not re-request on open.
class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  late HomeBloc homeBloc;

  @override
  void initState() {
    LastPagesTracker.push("Checklist Page");
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    return Scaffold(
      appBar: TrydosAppBar(
        appBarParams: AppBarParams(
          backgroundColor: const Color(0x000000),
          action: [
            const Spacer(),

            Text(
              LocaleKeys.my_checklist.tr(),
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14.sp,
                height: 1.3,
              ),
            ),
            SizedBox(width: 30.w),
            const Spacer(),
          ],
          scrolledUnderElevation: 0,
          backIconColor: Colors.black,
          withShadow: false,
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.getChecklistStatus != c.getChecklistStatus ||
            p.checklistPageData != c.checklistPageData ||
            p.checklistItemStatus != c.checklistItemStatus,
        builder: (context, state) {
          final ChecklistPageData? pageData = state.checklistPageData;
          final List<ChecklistItemModel> items = pageData?.items ?? [];

          if (state.getChecklistStatus == GetChecklistStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.getChecklistStatus == GetChecklistStatus.failure) {
            return Center(child: Text(LocaleKeys.something_went_wrong.tr()));
          }

          // The pagination bar stays mounted even when the page came back
          // empty, so a user who lands on an emptied page is never trapped
          // without a way back.
          return Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? Center(child: Text(LocaleKeys.checklist_is_empty.tr()))
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                        itemBuilder: (context, index) =>
                            _checklistTile(state, items[index]),
                      ),
              ),
              _paginationBar(state, pageData),
            ],
          );
        },
      ),
    );
  }

  Widget _checklistTile(HomeState state, ChecklistItemModel item) {
    final String productId = item.id?.toString() ?? '';
    final bool isDeleting =
        state.checklistItemStatus[productId] == ChecklistItemStatus.loading;

    final Widget tile = Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 10.w),
          InkWell(
            onTap: () {
              BlocProvider.of<HomeBloc>(
                context,
              ).add(GetFullProductDetailsEvent(productSlug: item.slug ?? ""));
              Future.delayed(
                const Duration(milliseconds: 300),
                () => Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProductDetailsPageNew(
                          productSlugForOpeningChatDirectly: item.slug ?? "",
                          productIdForOpeningChatDirectly:
                              item.id?.toString() ?? "",
                        ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: MyCachedNetworkImage(
                imageUrl: item.image ?? '',
                width: 70.w,
                height: 70.h,
                imageFit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              item.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 15.sp,
              ),
            ),
          ),
          IconButton(
            onPressed: productId.isEmpty
                ? null
                : () => homeBloc.add(
                    DeleteChecklistItemEvent(productId: productId),
                  ),
            icon: Icon(Icons.close, size: 22.r, color: const Color(0xff505050)),
          ),
          SizedBox(width: 5.w),
        ],
      ),
    );

    if (isDeleting) {
      // AbsorbPointer: Shimmer does not block hit-testing, so the delete
      // IconButton underneath would otherwise stay tappable mid-request.
      return AbsorbPointer(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: tile,
        ),
      );
    }

    return tile;
  }

  Widget _paginationBar(HomeState state, ChecklistPageData? pageData) {
    if (pageData == null) return const SizedBox.shrink();

    final int currentPage = pageData.currentPage ?? 1;
    final int lastPage = pageData.lastPage ?? 1;

    // A single page needs no controls at all.
    if (lastPage <= 1) return const SizedBox.shrink();

    final bool isLoading =
        state.getChecklistStatus == GetChecklistStatus.loading;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _pageButton(
            label: LocaleKeys.previous.tr(),
            isEnabled: pageData.hasPrevPage && !isLoading,
            onTap: () => homeBloc.add(GetChecklistEvent(page: currentPage - 1)),
          ),
          Text(
            '$currentPage / $lastPage',
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 15.sp,
            ),
          ),
          _pageButton(
            label: LocaleKeys.next.tr(),
            isEnabled: pageData.hasNextPage && !isLoading,
            onTap: () => homeBloc.add(GetChecklistEvent(page: currentPage + 1)),
          ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.4,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
