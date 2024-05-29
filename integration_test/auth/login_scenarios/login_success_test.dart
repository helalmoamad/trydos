import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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
    'Login success test ',
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
      //////////////////////////
      await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
      await Future.delayed(const Duration(seconds: 5));
      //////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(LoginSuccessfully));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: LoginSuccessfully,
        successMessage: 'Find LoginSuccessfully Success',
        failedMessage: 'Find LoginSuccessfully failed',
      );
      //////////////////////////
    },
  );
}
