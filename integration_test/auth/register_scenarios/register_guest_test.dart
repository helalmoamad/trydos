import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/authentication/presentation/widgets/welcome_section.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import '../../utils/global_test_functions.dart';
import 'package:trydos/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Register guest success and market token has been returned',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      //////////////////////////
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
      final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
      try {
        expect(prefsRepository.marketToken, isNull);
        debugPrint('marketToken is null before guest register');
      } catch (e) {
        print(
            '//////// marketToken is NOT null before guest register Failure: //////////\n $e');
        rethrow;
      }
      ////////////////////////////
      final Finder laterTakeLookButton =
          find.byKey(Key(WidgetsKey.laterTakeLookKey));
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(laterTakeLookButton);
      await tester.pumpAndSettle();
      ////////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(HomePage),
          timeout: Duration(seconds: 30));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: HomePage,
        successMessage: 'Find HomePage Success',
        failedMessage: 'Find HomePage failed',
      );
      ////////////////////////////
      try {
        expect(prefsRepository.marketToken, isNotNull);
        debugPrint('marketToken is NOT null after guest register');
      } catch (e) {
        print(
            '//////// marketToken is null after guest register Failure: //////////\n $e');
        rethrow;
      }
      ////////////////////////////
    },
  );
}
