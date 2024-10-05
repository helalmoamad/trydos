import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/main.dart' as app;
import '../../shared/shared_scenarios.dart';
import '../../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group(
    'Login failed tests',
    () {
      testWidgets(
        'Login failed after waiting 2 minutes without entering otp (Expired OTP )',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          TestVariables.kTestMode = true;
          //////////////////////////
          await SharedScenarios.goToVerifyOtp(tester: tester, isForLogin: true);
          ////////////////////////////
          final Finder otpRemainingTime =
              find.byKey(Key(WidgetsKey.otpRemainingTimeKey));
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
            fail(
                '//////// otpRemainingTime start from 2 minutes failed Failure: //////////\n $e');
          }

          await Future.delayed(const Duration(minutes: 2));
          await tester.pumpAndSettle();

          final Finder resendCodeButton =
              find.byKey(Key(WidgetsKey.resendCodeButtonKey));
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
      //////////////////////////////
      testWidgets(
        'Login failed after enter wrong otp',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          //////////////////////////
          await SharedScenarios.goToVerifyOtp(tester: tester, isForLogin: true);
          ////////////////////////////
          await GlobalTestFunctions.enterTestOtp(tester: tester, number: '8');
          await Future.delayed(const Duration(seconds: 30));
          await tester.pumpAndSettle();
          //////////////////////////////
          await GlobalTestFunctions.findNoWidget(
            tester: tester,
            widgetType: LoginSuccessfully,
            successMessage: 'Find nothing LoginSuccessfully Success',
            failedMessage: 'Find nothing LoginSuccessfully failed',
          );
        },
      );
    },
  );
}
