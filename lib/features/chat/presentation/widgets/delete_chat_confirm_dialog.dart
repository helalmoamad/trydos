import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// يسأل المستخدم قبل حذف دردشة.
///
/// الحذف يمسح الدردشة من السيرفر ولا رجعة فيه، وكان يقع بضغطة واحدة بعد
/// السحب. يعيد `true` إن أكّد المستخدم، و`false` إن ألغى أو أغلق النافذة.
Future<bool> confirmDeleteChat(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        LocaleKeys.delete_chat.tr(),
        textAlign: TextAlign.center,
        style: context.textTheme.bodyLarge?.sbt.copyWith(
          color: const Color(0xff1D1D1D),
          fontSize: 16.sp,
        ),
      ),
      content: Text(
        LocaleKeys.delete_chat_confirm_message.tr(),
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.rq.copyWith(
          color: const Color(0xff8D8D8D),
          fontSize: 13.sp,
          height: 1.5,
        ),
      ),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  LocaleKeys.cancel.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff8D8D8D),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFA6868),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  LocaleKeys.delete.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
