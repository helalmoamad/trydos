import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group(
    'Products Filter tests',
    () {
      testWidgets(
        'Filter and return one product test in product listing page ,',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          TestVariables.kTestMode = true;
          /////////////  Register As Guest  /////////////
          await SharedScenarios.registerGuest(tester: tester);
          ////////////// Find Boutiques HomePageCard //////////////
          final Finder boutiquesSuccessStatus =
              find.byKey(Key(WidgetsKey.boutiquesSuccessStatusKey));
          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: boutiquesSuccessStatus,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find Boutiques HomePageCard2 Success',
            failedMessage: 'Find Boutiques HomePageCard2 failed',
          );
          ////////////////////////////
          final boutiqueBestSaller =
              find.widgetWithText(HomePageCard2, 'best saller');
          // Check if the Boutique with the text 'best saller' is found.
          expect(boutiqueBestSaller, findsOneWidget);

          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(boutiqueBestSaller);
          await tester.pumpAndSettle();
          ////////////// Find list of filters  //////////////
          final Finder productListFilterWidget =
              find.byKey(Key(WidgetsKey.productListFilterKey));

          ///////////////////////////////

          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: productListFilterWidget,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find product List Filter Widget  Success',
            failedMessage: 'Find product List Filte Widget failed',
          );

          ///////// Find categorys , brands , filters ///////////////////

          final Finder categoriesProductListingFilterListWidget =
              find.byKey(Key(WidgetsKey.categoriesProductListingFilterListKey));
          expect(categoriesProductListingFilterListWidget, findsOneWidget);
          ///////////////////////////
          final Finder brandsProductListingFilterListWidget =
              find.byKey(Key(WidgetsKey.brandsProductListingFilterListKey));
          expect(brandsProductListingFilterListWidget, findsOneWidget);
          ///////// Find products for  boutique ///////////////////
          final Finder productsList = find.byKey(
            Key(WidgetsKey.productsListKey),
          );
          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: productsList,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find productsList  Success',
            failedMessage: 'Find productsList  failed',
          );

          //////////// filter by category and check the results//////

          final Finder categoryCircleFilterWidget = find.byKey(
            Key('${WidgetsKey.categoryCircleProductListingFilterKey}0'),
          );

          String categoryName = tester
              .widget<FilterCircleWidget>(categoryCircleFilterWidget)
              .categoryName
              .toString();

          print('Filter Category name $categoryName');

          await tester.tap(categoryCircleFilterWidget);
          await tester.pump();
          await Future.delayed(const Duration(seconds: 1));
          /////////////  Loading for products  /////////////
          final Finder boutiqueProductListingLoading = find.byKey(
            Key(WidgetsKey.boutiqueProductListingLoadingKey),
          );
          ///////////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: boutiqueProductListingLoading,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find boutiqueProductListingLoading  Success',
            failedMessage: 'Find boutiqueProductListingLoading  failed',
          );

          await tester.pumpAndSettle();

          HomeBloc homeBloc = GetIt.I<HomeBloc>();
          final homeState = homeBloc.state;
          expect(homeState.getProductListingWithFiltersPaginationModels,
              isNotNull);
          ////////////// get the category of the filtered products /////////////////////////////
          int productIndex1 = 0;
          List<String> productsCategoryAfterFilter = [];
          while (true) {
            Key productKey =
                Key('${WidgetsKey.productInBoutiqueListKey}$productIndex1');

            print('productKey  found 1 : $productKey');

            if (find.byKey(productKey).evaluate().isEmpty) {
              print('productKey not found 1 : $productKey');
              break;
            }

            String productBoutCategoryName = tester
                .widget<ProductItem>(find.byKey(productKey))
                .productItem
                .categories![0]
                .name
                .toString();

            productsCategoryAfterFilter.add(productBoutCategoryName);

            print('productBoutCategory first : $productBoutCategoryName');

            expect(productBoutCategoryName, equals(categoryName));

            productIndex1++;
          }

          print('first Products Category : $productsCategoryAfterFilter');

          //////////////// Find Applied filters widget /////////////////////////
          final Finder appliedFiltersProductListingWidget = find.byKey(
            Key(WidgetsKey.appliedFiltersProductListingKey),
          );
          ///////////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: appliedFiltersProductListingWidget,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find Applied Filters Widget Success',
            failedMessage: 'Find Applied Filters Widget failed',
          );
          ///////////// cancel the filter /////////////
          final Finder appliedFiltersProductListingCloseButton = find.byKey(
            Key(WidgetsKey.appliedFiltersProductListingCloseKey),
          );
          expect(appliedFiltersProductListingCloseButton, findsOneWidget);
          await tester.tap(appliedFiltersProductListingCloseButton);
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 1));
          ///////////////////////////////
          // expect(appliedFiltersProductListingWidget, findsNothing);

          ////////// filter by brand until one product result //////

          final Finder brandCircleFilterWidget = find.byKey(
            Key('${WidgetsKey.brandCircleProductListingFilterKey}0'),
          );

          final Finder brandFilterNameWidget = find.byKey(
            Key('${WidgetsKey.brandProductListingFilterNameKey}0'),
          );

          String brandName = tester
              .widget<MyTextWidget>(brandFilterNameWidget)
              .text
              .toString();

          print('Filter Brand name $brandName');

          await tester.tap(brandCircleFilterWidget);

          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 1));

          expect(homeState.getProductListingWithFiltersPaginationModels,
              isNotNull);
          ////////////// get the Brand of the filtered products /////////////////////////////
          int productIndex2 = 0;
          List<String> productsBrandAfterFilter = [];
          while (true) {
            Key productKey =
                Key('${WidgetsKey.productInBoutiqueListKey}$productIndex2');

            print('productKey  found 1 : $productKey');

            if (find.byKey(productKey).evaluate().isEmpty) {
              print('productKey not found 1 : $productKey');
              break;
            }

            String productBoutBrandName = tester
                .widget<ProductItem>(find.byKey(productKey))
                .productItem
                .brand!
                .name
                .toString();

            productsBrandAfterFilter.add(productBoutBrandName);

            print('productBoutBrandName  : $productBoutBrandName');

            expect(productBoutBrandName, equals(brandName));

            productIndex2++;
          }

          print('first Products Category : $productsBrandAfterFilter');
          expect(productsBrandAfterFilter.length, equals(1));
          await Future.delayed(const Duration(seconds: 2));

          ////////// check there are no filters  //////////////////
          final Finder productListingFilterListWidget =
              find.byKey(Key(WidgetsKey.productListingFilterListKey));

          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: appliedFiltersProductListingWidget,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find Applied Filters Widget Success',
            failedMessage: 'Find Applied Filters Widget failed',
          );
          ///////////////////////////
          await GlobalTestFunctions.findNoWidget(
            tester: tester,
            actual: productListingFilterListWidget,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find No product List Filter Widget  Success',
            failedMessage: 'Find No product List Filte Widget failed',
          );

          final Finder filterIconButton = find.byKey(
            Key(WidgetsKey.filterIconKey),
          );

          expect(filterIconButton, findsNothing);
          /////// cancel filter /////////////
          await tester.tap(appliedFiltersProductListingCloseButton);
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2));
          //////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: productListingFilterListWidget,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find  product List Filter Widget  Success',
            failedMessage: 'Find  product List Filte Widget failed',
          );

          expect(filterIconButton, findsOneWidget);
        },
      );
    },
  );
}
