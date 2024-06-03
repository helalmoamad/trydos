import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import '../../shared/shared_scenarios.dart';
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
      await SharedScenarios.registerGuest(tester: tester);
      ////////////////////////////
      final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
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
