import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
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
      WidgetsKey.kTestMode = true;
      //////////////////////////
      await SharedScenarios.registerGuest(tester: tester);
      //////////////////////////
      await SharedScenarios.testTokensAreNotNull(isJustForMarketToken: true);
      ////////////////////////////
    },
  );
}
