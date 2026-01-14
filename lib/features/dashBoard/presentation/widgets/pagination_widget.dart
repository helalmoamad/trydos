import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trydos/generated/locale_keys.g.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = currentPage > 1;
    final bool canGoNext = currentPage < totalPages;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _PaginationButton(
            text: LocaleKeys.previous.tr(),
            isEnabled: canGoPrevious,
            onTap: canGoPrevious ? onPrevious : null,
          ),

          SizedBox(width: 16.w),

          // Page Info
          Text(
            '${LocaleKeys.page.tr()} $currentPage ${LocaleKeys.of.tr()} $totalPages',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(width: 16.w),

          // Next Button
          _PaginationButton(
            text: LocaleKeys.next.tr(),
            isEnabled: canGoNext,
            onTap: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _PaginationButton({
    Key? key,
    required this.text,
    required this.isEnabled,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isEnabled ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
