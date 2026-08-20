import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// Brand red used across the listing page for the active/selected state.
const Color _kRed = Color(0xffFF5F61);
const Color _kSelectedBg = Color(0xffFFF3F3);
const Color _kCardBg = Color(0xffF6F6F6);
const Color _kPillBg = Color(0xffEDEDED);
const Color _kIconBg = Color(0xffEDEDED);
const Color _kSubtitleGrey = Color(0xff8A8A8A);

/// A single sub-choice inside a sort group (e.g. Newest / Oldest).
class _SortSub {
  final String labelKey;
  final String value;

  const _SortSub(this.labelKey, this.value);
}

/// One row in the sort sheet. Either a direct [value] (no sub-choices) or a
/// group of [subs] (ascending / descending style choices).
class _SortOption {
  final String titleKey;
  final String subtitleKey;
  final Widget icon;
  final String? value;
  final List<_SortSub>? subs;

  const _SortOption({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    this.value,
    this.subs,
  });

  /// The set of sort keys this option owns.
  List<String> get ownedValues =>
      subs != null ? subs!.map((e) => e.value).toList() : [value ?? ""];
}

/// Opens the "Sort products" bottom sheet. Keeps under 90% of the screen
/// height, preselects the currently applied sort (from [boutiqueBloc]) and,
/// on confirm, dispatches [ChangeSortEvent] which reloads the listing.
Future<void> showSortProductsSheet({
  required BuildContext context,
  required BoutiqueBloc boutiqueBloc,
  required String boutiqueSlug,
  required String? searchText,
  String? category,
  bool fromSearch = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
    ),
    builder: (_) => _SortSheetContent(
      initialSort: boutiqueBloc.state.sortKey,
      onConfirm: (sortKey) {
        boutiqueBloc.add(
          ChangeSortEvent(
            sortKey: sortKey,
            boutiqueSlug: boutiqueSlug,
            category: category,
            searchText: searchText,
            fromSearch: fromSearch,
          ),
        );
      },
    ),
  );
}

class _SortSheetContent extends StatefulWidget {
  final String initialSort;
  final ValueChanged<String> onConfirm;

  const _SortSheetContent({required this.initialSort, required this.onConfirm});

  @override
  State<_SortSheetContent> createState() => _SortSheetContentState();
}

class _SortSheetContentState extends State<_SortSheetContent> {
  late String _selected = widget.initialSort;

  late final List<_SortOption> _options = [
    const _SortOption(
      titleKey: LocaleKeys.sort_default,
      subtitleKey: LocaleKeys.sort_best_match,
      icon: Icon(Icons.format_list_bulleted),
      value: "",
    ),
    const _SortOption(
      titleKey: LocaleKeys.sort_best_sellers,
      subtitleKey: LocaleKeys.sort_most_bought,
      icon: Icon(Icons.local_fire_department_outlined),
      value: "best_selling",
    ),
    const _SortOption(
      titleKey: LocaleKeys.sort_new_arrivals,
      subtitleKey: LocaleKeys.sort_by_date_added,
      icon: Icon(Icons.schedule),
      subs: [
        _SortSub(LocaleKeys.sort_newest, "newest"),
        _SortSub(LocaleKeys.sort_oldest, "oldest"),
      ],
    ),
    const _SortOption(
      titleKey: LocaleKeys.sort_price,
      subtitleKey: LocaleKeys.sort_by_product_price,
      icon: Icon(Icons.sell_outlined),
      subs: [
        _SortSub(LocaleKeys.sort_low_to_high, "price_asc"),
        _SortSub(LocaleKeys.sort_high_to_low, "price_desc"),
      ],
    ),
    _SortOption(
      titleKey: LocaleKeys.sort_name,
      subtitleKey: LocaleKeys.sort_alphabetical,
      icon: Text(
        "A Z",
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
      ),
      subs: const [
        _SortSub(LocaleKeys.sort_a_to_z, "name_asc"),
        _SortSub(LocaleKeys.sort_z_to_a, "name_desc"),
      ],
    ),
  ];

  bool get _canReset => _selected.isNotEmpty;

  bool get _canConfirm => _selected != widget.initialSort;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xffE0E0E0),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.sort_products.tr(),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6.h),
          Text(
            LocaleKeys.sort_choose_ordering.tr(),
            style: TextStyle(fontSize: 13.sp, color: _kSubtitleGrey),
          ),
          SizedBox(height: 16.h),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: _options.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) => _buildOption(_options[index]),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  bool _isOptionSelected(_SortOption option) =>
      option.ownedValues.contains(_selected);

  Widget _buildOption(_SortOption option) {
    final bool selected = _isOptionSelected(option);
    final bool hasSubs = option.subs != null;

    return GestureDetector(
      onTap: hasSubs
          ? null
          : () => setState(() => _selected = option.value ?? ""),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? _kSelectedBg : _kCardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? _kRed : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xffFFE1E1) : _kIconBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: selected ? _kRed : const Color(0xff5A5A5A),
                      size: 22.sp,
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: selected ? _kRed : const Color(0xff5A5A5A),
                      ),
                      child: option.icon,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        option.titleKey.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: selected ? _kRed : Colors.black,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        option.subtitleKey.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _kSubtitleGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 24.w,
                  child: (!hasSubs && selected)
                      ? Icon(Icons.check, color: _kRed, size: 22.sp)
                      : null,
                ),
              ],
            ),
            if (hasSubs) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  for (int i = 0; i < option.subs!.length; i++) ...[
                    if (i > 0) SizedBox(width: 10.w),
                    Expanded(child: _buildSubPill(option.subs![i])),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubPill(_SortSub sub) {
    final bool selected = _selected == sub.value;
    return GestureDetector(
      onTap: () => setState(() => _selected = sub.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _kSelectedBg : _kPillBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? _kRed : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          sub.labelKey.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? _kRed : const Color(0xff3C3C3C),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _canReset ? () => setState(() => _selected = "") : null,
              child: Container(
                height: 52.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: _canReset
                        ? const Color(0xffCFCFCF)
                        : const Color(0xffE8E8E8),
                  ),
                ),
                child: Text(
                  LocaleKeys.reset.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: _canReset ? Colors.black : const Color(0xffBDBDBD),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _canConfirm
                  ? () {
                      widget.onConfirm(_selected);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Container(
                height: 52.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: _canConfirm ? _kRed : _kRed.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  LocaleKeys.confirm.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
