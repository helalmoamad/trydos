import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/authentication/presentation/widgets/welcome_section.dart';
import '../utils/global_test_functions.dart';

class SharedScenarios {
  static Future<void> goToVerifyOtp({required WidgetTester tester}) async {
    await GlobalTestFunctions.waitFor(tester, find.byType(RegistrationPage));

    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: RegistrationPage,
      successMessage: 'Find Registration Page Success',
      failedMessage: 'Find Registration Page failed',
    );
    ////////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: WelcomeSection,
      successMessage: 'Find WelcomeSection Success',
      failedMessage: 'Find WelcomeSection failed',
    );
    ////////////////////////////
    final Finder haveAccountButton =
        find.byKey(Key(WidgetsKey.haveAccountButtonKey));
    await Future.delayed(const Duration(seconds: 1));
    await tester.tap(haveAccountButton);
    await tester.pumpAndSettle();
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: InsertPhoneTab,
      successMessage: 'Find InsertPhoneTab Success',
      failedMessage: 'Find InsertPhoneTab failed',
    );
    //////////////////////////
    final Finder phoneField =
        find.byKey(Key(WidgetsKey.loginPhoneFormFieldKey));
    final Finder confirmPhoneButton =
        find.byKey(Key(WidgetsKey.loginConfirmPhoneButtonKey));

    await tester.enterText(phoneField, '963997412860');
    await Future.delayed(const Duration(seconds: 2));
    await tester.tap(confirmPhoneButton);
    await tester.pumpAndSettle();
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: VerificationMethods,
      successMessage: 'Find VerificationMethods Success',
      failedMessage: 'Find VerificationMethods failed',
    );
    //////////////////////////
    final Finder chooseWhatsAppButton =
        find.byKey(Key(WidgetsKey.chooseWhatsappButtonKey));
    await tester.tap(chooseWhatsAppButton);
    await tester.pumpAndSettle();
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: VerifyOtp,
      successMessage: 'Find VerifyOtp Success',
      failedMessage: 'Find VerifyOtp failed',
    );
  }
}
