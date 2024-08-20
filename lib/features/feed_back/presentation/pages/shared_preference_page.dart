import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        backgroundColor: context.colorScheme.background,
        body: ListView(
          children: [
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
          ],
        ));
  }
}

class SharedPreferenceCard extends StatelessWidget {
  const SharedPreferenceCard(
      {super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 5
        )
      ]
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextWidget(
              title,
              style: context.textTheme.bodyLarge?.rr
                  .copyWith(color: Colors.deepOrangeAccent),
            ),
            10.verticalSpace,
            MyTextWidget(
              value,
              style:
                  context.textTheme.bodyMedium?.rr.copyWith(color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
