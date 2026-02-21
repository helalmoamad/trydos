import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_boutique_card.dart';
import 'package:trydos/main.dart' as app;
import 'package:flutter/material.dart';

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Test add to cart', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    TestVariables.kTestMode = true;
    /////////////  login  /////////////
    await SharedScenarios.goToVerifyOtp(tester: tester, isForLogin: true);
    ////////////////////////////
    await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
    //////////////////////////
    await GlobalTestFunctions.waitFor(tester, find.byType(LoginSuccessfully));
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: LoginSuccessfully,
      successMessage: 'Find LoginSuccessfully Success',
      failedMessage: 'Find LoginSuccessfully failed',
    );
    /////////////////////////
    await SharedScenarios.countryDropDown(tester: tester);
    //////////////////////////
    await GlobalTestFunctions.waitFor(tester, find.byType(HomePage));
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: HomePage,
      successMessage: 'Find HomePage Success',
      failedMessage: 'Find HomePage failed',
    );
    print(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF!!!!!!!!!!!!!!!!!!!!!!!!!!1",
    );
    // التأكد من كونك على صفحة الـ HomePage
    await tester.pumpAndSettle();
    // انتظر اختفاء مؤشر التحميل إن وجد
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    print(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF!!!!!!!!!!!!!!!!!!!!!!!!!!000001",
    );
    expect(
      find.byKey(const Key(WidgetsKeys.boutiquesSuccessStatusKey)),
      findsOneWidget,
    );
    print(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF!!!!!!!!!!!!!!!!!!!!!!!!!!00011",
    );

    final Finder boutiqueFinder = find.byKey(
      const Key('${WidgetsKeys.boutiqueCardKey}0'),
    );

    await GlobalTestFunctions.scrollUntilVisibleWidget(tester, boutiqueFinder);

    await tester.pumpAndSettle();
    final Finder boutiqueTapFinder = find.byKey(
      const Key('${WidgetsKeys.boutiqueCardKey}*tap*0'),
    );

    print(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF!!!!!!!!!!!!!!!!!!!!!!!!!!3",
    );

    await tester.pumpAndSettle();
    final boutiqueSlug =
        tester.widget<HomePageBoutiqueCard>(boutiqueFinder).boutique.slug ?? "";
    print('//////// boutiqueCard1  : $boutiqueSlug //////////');
    await tester.tap(boutiqueTapFinder);
    print(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF!!!!!!!!!!!!!!!!!!!!!!!!!!4",
    );
    await tester.pumpAndSettle();
    // الآن انتظار أول منتج (استخدم key المنتج الصحيح لاحقاً)
    final Finder productFinder = find.byKey(
      const Key('${WidgetsKeys.productsListKey}0'),
    );
    final scrollableProductsFinder = find.descendant(
      of: find.byKey(const Key(WidgetsKeys.productListingScrollKey)),
      matching: find.byType(Scrollable),
    );

    await tester.scrollUntilVisible(
      productFinder,
      300,
      scrollable: scrollableProductsFinder,
    );
    expect(productFinder, findsOneWidget);
    await tester.tap(productFinder);
    await tester.pumpAndSettle();
    ////////////////////////////
  });
}
