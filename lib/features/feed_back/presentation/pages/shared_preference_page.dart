import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/common/helper/phone_input_diagnostics.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../app/my_text_widget.dart';

class SharedPreferencePage extends StatelessWidget {
  SharedPreferencePage({super.key});

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            10.verticalSpace,
            const _PrintProblemButton(),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'market user id',
              value: prefsRepository.myMarketId ?? "",
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'is verified phone',
              value: prefsRepository.isVerifiedPhone.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'Fcm Tokens count',
              value: prefsRepository.getFcmTokens.length.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'chat token',
              value: prefsRepository.chatToken.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'market token',
              value: prefsRepository.marketToken.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'stories token',
              value: prefsRepository.storiesToken.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'verification id',
              value: prefsRepository.verificationId.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'country iso',
              value: prefsRepository.countryIso.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'chat user id',
              value: prefsRepository.myChatId.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'chat user name',
              value: prefsRepository.myChatName.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'phone number',
              value: prefsRepository.myPhoneNumber.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'stories user id',
              value: prefsRepository.myStoriesId.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'fcm token id',
              value: prefsRepository.fcmTokenId.toString(),
            ),
            10.verticalSpace,
            SharedPreferenceCard(
              title: 'Contact',
              value: prefsRepository.myContactDetails.toString(),
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }
}

/// زرّ يعرض سجلّ تشخيص حقل رقم الهاتف، مع نسخه ومسحه.
///
/// العطل يظهر على جهاز بعينه ولا يُرى في المحرّر، فنقرأ ما يصل من لوحة مفاتيح
/// ذلك الجهاز: النصّ، ورموز محارفه، والدولة التي طابقها البحث، وسبب رفض أي
/// ضغطة.
class _PrintProblemButton extends StatelessWidget {
  const _PrintProblemButton();

  void _show(BuildContext context) {
    final String report = PhoneInputDiagnostics.read();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Print problem'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              report,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              PhoneInputDiagnostics.clear();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('مسح السجل'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: report));
              showMessage(
                'تم نسخ السجل',
                showInRelease: true,
                context: dialogContext,
              );
            },
            child: const Text('نسخ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _show(context),
      icon: const Icon(Icons.bug_report_outlined),
      label: const Text('print problem'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1877F2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class SharedPreferenceCard extends StatelessWidget {
  const SharedPreferenceCard({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(blurRadius: 5)],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextWidget(
              title,
              style: context.textTheme.bodyLarge?.rq.copyWith(
                color: Colors.deepOrangeAccent,
              ),
            ),
            10.verticalSpace,
            MyTextWidget(
              value,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
