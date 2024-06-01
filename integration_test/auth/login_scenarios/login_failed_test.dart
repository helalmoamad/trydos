import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/authentication/presentation/widgets/welcome_section.dart';
import 'package:trydos/main.dart' as app;
import '../../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Login failed after waiting 2 minutes without entering otp',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

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
          find.byKey(Key('have_already_account_button'));
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
      final Finder phoneField = find.byKey(Key('login_phone_form_field'));
      final Finder confirmPhoneButton =
          find.byKey(Key('login_confirm_phone_button'));

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
          find.byKey(Key('choose_whatsapp_button'));
      await tester.tap(chooseWhatsAppButton);
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: VerifyOtp,
        successMessage: 'Find VerifyOtp Success',
        failedMessage: 'Find VerifyOtp failed',
      );
      ////////////////////////////
      final Finder otpRemainingTime = find.byKey(Key('otp_remaining_time'));
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: otpRemainingTime,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find otpRemainingTime Success',
        failedMessage: 'Find otpRemainingTime failed',
      );
      ////////////////////////////
      final textWidget = tester.widget<MyTextWidget>(otpRemainingTime);
      final textContent = textWidget.text;

      try {
        expect(
            textContent == '02 : 00 ' ||
                textContent == '01 : 59 ' ||
                textContent == '01 : 58 ' ||
                textContent == '01 : 57 ',
            isTrue);
        debugPrint('otpRemainingTime start from 2 minutes success');
      } catch (e) {
        print(
            '//////// otpRemainingTime start from 2 minutes failed Failure: //////////\n $e');
        rethrow;
      }

      await Future.delayed(const Duration(minutes: 2));
      await tester.pumpAndSettle();

      final Finder resendCodeButton = find.byKey(Key('resend_code_button'));
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: resendCodeButton,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find resend Code Button Success',
        failedMessage: 'Find resend Code Button failed',
      );
      //////////////////////////////
      await GlobalTestFunctions.findNoWidget(
        tester: tester,
        widgetType: LoginSuccessfully,
        successMessage: 'Find nothing LoginSuccessfully Success',
        failedMessage: 'Find nothing LoginSuccessfully failed',
      );
    },
  );
}
