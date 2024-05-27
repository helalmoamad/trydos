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
    'Test login success',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await GlobalTestFunctions.waitFor(tester, find.byType(RegistrationPage));

      try {
        expect(find.byType(RegistrationPage), findsOneWidget);
        debugPrint('Find RegistrationPage Success');
      } catch (e) {
        print('//////// Find RegistrationPage failed Failure: //////////\n $e');
        rethrow;
      }
      //////////////////////////
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 100));
      ////////////////////////////
      try {
        expect(find.byType(WelcomeSection), findsOneWidget);
        debugPrint('Find WelcomeSection Success');
      } catch (e) {
        print('//////// Find WelcomeSection failed Failure: //////////\n $e');
        rethrow;
      }
      //////////////////////////
      await tester.pumpAndSettle();
      ////////////////////////////
      final Finder haveAccountButton =
          find.byKey(Key('have_already_account_button'));
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(haveAccountButton);
      await tester.pumpAndSettle();
      //////////////////////////
      try {
        expect(find.byType(InsertPhoneTab), findsOneWidget);
        debugPrint('Find InsertPhoneTab Success');
      } catch (e) {
        print('//////// Find InsertPhoneTab failed Failure: //////////\n $e');
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      //////////////////////////
      final Finder phoneField = find.byKey(Key('login_phone_form_field'));
      final Finder confirmPhoneButton =
          find.byKey(Key('login_confirm_phone_button'));

      await tester.enterText(phoneField, '963997412860');
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(confirmPhoneButton);
      await tester.pumpAndSettle();
      //////////////////////////
      try {
        expect(find.byType(VerificationMethods), findsOneWidget);
        debugPrint('Find VerificationMethods Success');
      } catch (e) {
        print(
            '//////// Find VerificationMethods failed Failure: //////////\n $e');
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      //////////////////////////
      final Finder chooseWhatsAppButton =
          find.byKey(Key('choose_whatsapp_button'));
      await tester.tap(chooseWhatsAppButton);
      await tester.pumpAndSettle();
      //////////////////////////
      try {
        expect(find.byType(VerifyOtp), findsOneWidget);
        debugPrint('Find VerifyOtp Success');
      } catch (e) {
        print('//////// Find VerifyOtp failed Failure: //////////\n $e');
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      //////////////////////////
      final Finder otpItem1 = find.byKey(Key('otp_item_1'));
      final Finder otpItem2 = find.byKey(Key('otp_item_2'));
      final Finder otpItem3 = find.byKey(Key('otp_item_3'));
      final Finder otpItem4 = find.byKey(Key('otp_item_4'));
      final Finder otpItem5 = find.byKey(Key('otp_item_5'));
      final Finder otpItem6 = find.byKey(Key('otp_item_6'));

      await tester.enterText(otpItem1, '9');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.enterText(otpItem2, '9');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.enterText(otpItem3, '9');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.enterText(otpItem4, '9');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.enterText(otpItem5, '9');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.enterText(otpItem6, '9');
      await Future.delayed(const Duration(seconds: 5));
      await GlobalTestFunctions.waitFor(tester, find.byType(LoginSuccessfully));
      //////////////////////////
      try {
        expect(find.byType(LoginSuccessfully), findsOneWidget);
        debugPrint('Find LoginSuccessfully Success');
      } catch (e) {
        print(
            '//////// Find LoginSuccessfully failed Failure: //////////\n $e');
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      //////////////////////////
    },
  );
}
