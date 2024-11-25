import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/main.dart' as app;

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Test Login and add item to cart with increase and decrease item',
    (WidgetTester tester) async {
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
      ////////////////////////////
      final Finder boutiquesFailureStatus =
          find.byKey(Key(WidgetsKeys.boutiquesFailureStatusKey));
      await GlobalTestFunctions.findNoWidget(
        tester: tester,
        actual: boutiquesFailureStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Boutiques not Null Success',
        failedMessage: 'Boutiques not Null failed',
      );
      ////////////////////////////
      final Finder boutiquesSuccessStatus =
          find.byKey(Key(WidgetsKeys.boutiquesSuccessStatusKey));
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: boutiquesSuccessStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find Boutiques HomePageCard2 Success',
        failedMessage: 'Find Boutiques HomePageCard2 failed',
      );

      await tester.pumpAndSettle();
      // Check if the Boutique with the text 'best saller' is found.
      final boutiqueBestSaller =
          find.widgetWithText(HomePageCard2, 'men section'); //best saller test

      final homeScroll = find.byKey(Key(WidgetsKeys.homepageScrollKey));

      await GlobalTestFunctions.scrollToFindWidget(
        tester: tester,
        widgetToFind: boutiqueBestSaller,
        widgetToScroll: homeScroll,
      );

      String boutiqueBestSellerSlug =
          tester.widget<HomePageCard2>(boutiqueBestSaller).boutique.slug ?? '';

      print(
          '///////// boutique Slug : $boutiqueBestSellerSlug  ////////////////');

      await Future.delayed(const Duration(seconds: 2));

      Offset topLeft = tester.getTopLeft(boutiqueBestSaller);

      await tester.tapAt(topLeft);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      //////////////////////////////
      final Finder productsList = find.byKey(
        Key(WidgetsKeys.productsListKey),
      );
      //////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productsList,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find productsList  Success',
        failedMessage: 'Find productsList  failed',
      );
      ////////////// choose first product ////////////////////////////////
      await tester.pumpAndSettle();
      final Finder productItemInList =
          find.byKey(Key('${WidgetsKeys.productItemInListKey}0'));
      expect(productItemInList, findsOneWidget);
      await tester.tap(productItemInList);
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.waitFor(
        tester,
        find.byType(ProductDetailsPage),
      );
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: ProductDetailsPage,
        successMessage: 'Find ProductDetailsPage Success',
        failedMessage: 'Find ProductDetailsPage failed',
      );
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: ProductDetailsSheetBottomBar,
        successMessage: 'Find Product Details Sheet BottomBar Success',
        failedMessage: 'Find Product Details Sheet BottomBar failed',
      );
      ////////////////////////////
      final Finder addToBagButton =
          find.byKey(Key(WidgetsKeys.addToBagButtonKey));
      expect(addToBagButton, findsOneWidget);
      //////////////////////////
      await tester.tap(addToBagButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      //////////////////////////
      Offset decreaseOrDeleteItem =
          tester.getTopLeft(addToBagButton) + Offset(5, -5);
      Offset increaseOrDeleteItem =
          tester.getTopRight(addToBagButton) - Offset(5, -5);
      ;
      Offset addToBagItem = tester.getCenter(addToBagButton);

      HomeBloc homeBloc = GetIt.I<HomeBloc>();
      HomeState homeState = homeBloc.state;

      int? currentCartItems = homeState.listitemForAddToCart?.length;
      print('currentCartItems :  $currentCartItems');
      ////////////// Increase Item ////////////
      await tester.tapAt(increaseOrDeleteItem);
      await tester.pumpAndSettle();
      increaseOrDeleteItem = tester.getTopRight(addToBagButton) - Offset(5, -5);
      await tester.tapAt(increaseOrDeleteItem);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      //////////////////////////
      homeState = homeBloc.state;
      currentCartItems = homeState.listitemForAddToCart?.length;
      print('currentCartItems :  $currentCartItems');
      ////////////// decrease Item ////////////
      await tester.tapAt(decreaseOrDeleteItem);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      //////////////////////////
      homeState = homeBloc.state;
      currentCartItems = homeState.listitemForAddToCart?.length;
      print('currentCartItems :  $currentCartItems');
      await Future.delayed(const Duration(seconds: 5));
    },
  );
}
