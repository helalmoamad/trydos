import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/generated/locale_keys.g.dart';

const Color _kLightGrey = Color(0xFFF1F2F4);
const Color _kRed = Color(0xFFE9564F);

/// نافذة تأكيد حذف الستوري.
///
/// تُعيد `true` إن أكّد المستخدم الحذف، و`false` إن ألغى أو أغلق النافذة —
/// فلا يُرسل حدث الحذف إلا بتأكيدٍ صريح.
///
/// شكلها هو نفسه المستعمل في لوحة البائع (`seller_stories_widget.dart`) حتى
/// يبقى تأكيد الحذف واحداً في التطبيق كلّه.
Future<bool> showDeleteStoryConfirmDialog(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteStoryConfirmDialog(),
  );
  return confirmed ?? false;
}

class _DeleteStoryConfirmDialog extends StatelessWidget {
  const _DeleteStoryConfirmDialog();

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
