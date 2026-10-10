import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'pagination_widget.dart';

/// The Boutiques list. [onAddBoutique] is passed only when the member may
/// create (AC-6), and [onBoutiqueTap] only when they may open a boutique
/// (AC-7) — a `null` callback hides the button / makes the card inert.
class BoutiquesGridWidget extends StatelessWidget {
  final List<Boutique> boutiques;
  final Meta? meta;
  final VoidCallback? onAddBoutique;
  final ValueChanged<Boutique>? onBoutiqueTap;
  final Function(int page)? onPageChanged;

  const BoutiquesGridWidget({
    Key? key,
    required this.boutiques,
    this.meta,
    this.onAddBoutique,
    this.onBoutiqueTap,
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int count = meta?.total ?? boutiques.length;
    return Column(
      children: [
        // Header: "Boutiques (count)" and the add button
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.boutique_list_header.tr(args: ['$count']),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3C3C3C),
                  ),
                ),
              ),
              if (onAddBoutique != null)
                TextButton.icon(
                  onPressed: onAddBoutique,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(LocaleKeys.add_boutique.tr()),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF5D5D5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Boutiques Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.58,
            ),
            itemCount: boutiques.length,
            itemBuilder: (context, index) {
              final Boutique boutique = boutiques[index];
              return BoutiqueCard(
                boutique: boutique,
                onTap: onBoutiqueTap == null
                    ? null
                    : () => onBoutiqueTap!(boutique),
              );
            },
          ),
        ),

        // Pagination
        if (meta != null && (meta!.lastPage ?? 1) > 1)
          PaginationWidget(
            currentPage: meta!.currentPage ?? 1,
            totalPages: meta!.lastPage ?? 1,
            onPrevious: () {
              if (onPageChanged != null && (meta!.currentPage ?? 1) > 1) {
                onPageChanged!((meta!.currentPage ?? 1) - 1);
              }
            },
            onNext: () {
              if (onPageChanged != null &&
                  (meta!.currentPage ?? 1) < (meta!.lastPage ?? 1)) {
                onPageChanged!((meta!.currentPage ?? 1) + 1);
              }
            },
          ),
      ],
    );
  }
}

class BoutiqueCard extends StatelessWidget {
  final Boutique boutique;

  /// `null` when the member may not open a boutique: the card does nothing.
  final VoidCallback? onTap;

  const BoutiqueCard({Key? key, required this.boutique, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isActive = boutique.status == 1;
    final String imageUrl = boutique.icon ?? '';
    final String description = boutique.description ?? boutique.bio ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Boutique Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: imageUrl.isNotEmpty
                        ? MyCachedNetworkImage(
                            imageUrl: "$imageUrl",
                            width: 200.w,
                            imageFit: BoxFit.contain,
                            height: 200.h,
                          )
                        : Icon(
                            Icons.store_outlined,
                            size: 48.sp,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
              ),

              // Boutique Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Boutique Name
                      Text(
                        boutique.name ?? 'Boutique',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Description (2 lines with ellipsis)
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const Spacer(),

                      // Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Slug
                          if (boutique.slug != null)
                            Expanded(
                              child: Text(
                                '/${boutique.slug}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          // Status
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
