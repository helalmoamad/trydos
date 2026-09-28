import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// خيارات دعوة شخص لا يملك التطبيق.
///
/// ورقة المشاركة التي تفتحها `share_plus` هي ورقة **النظام**، ولا يمكن لأي
/// تطبيق إضافة زر داخلها. فلعرض «نسخ رابط الدعوة» نحتاج ورقة من التطبيق تسبقها:
/// «نسخ الرابط» يكتب الرابط في الحافظة ويعرض رسالة تأكيد، و«مشاركة التطبيق»
/// تفتح ورقة النظام كما كانت تُفتح من قبل بلا أي تغيير.
///
/// [inviteLink] هو الرابط نفسه بلا نص مصاحب — لأن ما يُنسخ يجب أن يكون رابطاً
/// صالحاً للّصق وحده. و[onShare] هو مسار المشاركة القديم كما هو.
Future<void> showInviteOptions(
  BuildContext context, {
  required String inviteLink,
  required VoidCallback onShare,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xffE0E0E0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  LocaleKeys.invite.tr(),
                  style: context.textTheme.bodyLarge?.sbt.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 16.sp,
                  ),
                ),
              ),
              _InviteOption(
                icon: Icons.copy_rounded,
                label: LocaleKeys.copy_invite_link.tr(),
                onTap: () {
                  // الإغلاق أوّلاً: رسالة التأكيد تُدرَج في overlay الصفحة، فلو
                  // بقيت الورقة مفتوحة لغطّتها.
                  Navigator.of(sheetContext).pop();
                  Clipboard.setData(ClipboardData(text: inviteLink));
                  showMessage(
                    LocaleKeys.invite_link_copied.tr(),
                    // بدون هذا لا تظهر الرسالة إلا في نسخة debug.
                    showInRelease: true,
                    context: context,
                  );
                },
              ),
              _InviteOption(
                icon: Icons.ios_share_rounded,
                label: LocaleKeys.share_app.tr(),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onShare();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _InviteOption extends StatelessWidget {
  const _InviteOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: const Color(0xff388cff)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff505050),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
