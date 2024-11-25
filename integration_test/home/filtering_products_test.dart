import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/categories_filter_list.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  ////////////////////////////////

  testWidgets(
    'Filter by cateory in product listing page , filter by brand in product listing page and return one product , filter with category and brand in filter page and return the same results , Test X button in filter page , Test filter page applied Filters X button',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
      /////////////  Register As Guest  /////////////
      await SharedScenarios.registerGuest(tester: tester);
      ////////////// Find Boutiques HomePageCard //////////////
      final Finder boutiquesSuccessStatus =
          find.byKey(Key(WidgetsKeys.boutiquesSuccessStatusKey));
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: boutiquesSuccessStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find Boutiques HomePageCard2 Success',
        failedMessage: 'Find Boutiques HomePageCard2 failed',
      );
      // Check if the Boutique with the text 'best saller' is found.
      final boutiqueBestSaller =
          find.widgetWithText(HomePageCard2, 'best saller test');

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
      ////////////// Find list of filters  //////////////
      final Finder productListFilterWidget =
          find.byKey(Key(WidgetsKeys.productListFilterKey));

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
          find.byKey(Key(WidgetsKeys.categoriesProductListingFilterListKey));
      expect(categoriesProductListingFilterListWidget,
          findsOneWidget); // Ensure categories filter widget is found.
      ///////////////////////////
      final Finder brandsProductListingFilterListWidget =
          find.byKey(Key(WidgetsKeys.brandsProductListingFilterListKey));
      expect(brandsProductListingFilterListWidget, findsOneWidget);
      ///////// Find products for  boutique ///////////////////
      final Finder productsList = find.byKey(
        Key(WidgetsKeys.productsListKey),
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
        Key('${WidgetsKeys.categoryCircleWithOutSubProductListingFilterKey}0'),
      );

      expect(categoryCircleFilterWidget, findsOneWidget);

      String categoryName = tester
          .widget<FilterCircleWidget>(categoryCircleFilterWidget)
          .categoryName
          .toString();

      print('Filter Category name $categoryName');

      await tester.tap(categoryCircleFilterWidget);
      await tester.pump();
      /////////////  Loading for products  /////////////
      final Finder boutiqueProductListingLoading = find.byKey(
        Key(WidgetsKeys.boutiqueProductListingLoadingKey),
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
      HomeState homeState = homeBloc.state;
      expect(homeState.getProductListingWithFiltersPaginationModels, isNotNull);
      expect(homeState.getProductListingWithFiltersPaginationModels,
          isNot(equals({})));
      //////////// get the category of the filtered products /////////////////////////////
      int productIndex1 = 0;
      List<String> productsCategoryAfterFilter = [];
      List<String> productsNameAfterFilter = [];

      Finder productListingScroll =
          find.byKey(Key(WidgetsKeys.productListingScrollKey));

      bool reachedEnd = false;
      //////////////////// Scroll and test ////////////////////////////////////
      /////////////////////////////////
      while (!reachedEnd) {
        try {
          Finder productWidget = find
              .byKey(Key('${WidgetsKeys.productItemInListKey}$productIndex1'));
          //////////////////////////////////
          String productBoutCategoryName = tester
              .widget<ProductItem>(productWidget)
              .productItem
              .categories![0]
              .name
              .toString();

          String productName = tester
              .widget<ProductItem>(productWidget)
              .productItem
              .name
              .toString();

          productsCategoryAfterFilter.add(productBoutCategoryName);
          productsNameAfterFilter.add(productName);

          print('productBoutCategory first : $productBoutCategoryName');

          expect(productBoutCategoryName, equals(categoryName));
        } catch (e) {
          reachedEnd = true;
          fail(e.toString());
        }
        productIndex1++;
        // Try to scroll until the next product card becomes visible
        Finder finderWidget = find
            .byKey(Key('${WidgetsKeys.productItemInListKey}$productIndex1'));
        if (finderWidget.evaluate().isEmpty) {
          try {
            await tester.drag(productListingScroll, const Offset(0, -400));
            await tester.pumpAndSettle();
            print('scroll for $productIndex1');
            expect(finderWidget, findsOneWidget);
            print('find index after scroll : $productIndex1');
          } catch (e) {
            // If the scroll fails, we have reached the end of the list
            print('scroll fails, we have reached the end of the list');
            reachedEnd = true;
          }
        } else {
          print('find index without scroll : $productIndex1');
        }
      }

      print('first Products Category : $productsCategoryAfterFilter');

      await Future.delayed(const Duration(seconds: 3));

      //////////////// Find Applied filters widget /////////////////////////
      final Finder appliedFiltersProductListingWidget = find.byKey(
        Key(WidgetsKeys.appliedFiltersProductListingKey),
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
        Key(WidgetsKeys.appliedFiltersProductListingCloseKey),
      );
      expect(appliedFiltersProductListingCloseButton, findsOneWidget);
      await tester.tap(appliedFiltersProductListingCloseButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      ///////////////////////////////

      ////////// filter by brand until one product result //////

      final Finder brandCircleFilterWidget = find.byKey(
        Key('${WidgetsKeys.brandCircleProductListingFilterKey}0'),
      );

      final Finder brandFilterNameWidget = find.byKey(
        Key('${WidgetsKeys.brandProductListingFilterNameKey}0'),
      );

      String brandName =
          tester.widget<MyTextWidget>(brandFilterNameWidget).text.toString();

      print('Filter Brand name $brandName');

      await tester.tap(brandCircleFilterWidget);

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      expect(homeState.getProductListingWithFiltersPaginationModels, isNotNull);
      expect(homeState.getProductListingWithFiltersPaginationModels,
          isNot(equals({})));
      ////////////// get the Brand of the filtered products /////////////////////////////
      int productIndex2 = 0;
      List<String> productsBrandAfterFilter = [];
      String productBrandFilterName = '';

      productListingScroll =
          find.byKey(Key(WidgetsKeys.productListingScrollKey));

      reachedEnd = false;
      //////////////////// Scroll and test ////////////////////////////////////
      /////////////////////////////////
      while (!reachedEnd) {
        try {
          Key productKey =
              Key('${WidgetsKeys.productItemInListKey}$productIndex2');
          ///////////////////////
          String productBoutBrandName = tester
              .widget<ProductItem>(find.byKey(productKey))
              .productItem
              .brand!
              .name
              .toString();

          productBrandFilterName = tester
              .widget<ProductItem>(find.byKey(productKey))
              .productItem
              .name
              .toString();

          productsBrandAfterFilter.add(productBoutBrandName);

          print('productBoutBrandName  : $productBoutBrandName');

          expect(productBoutBrandName, equals(brandName));
        } catch (e) {
          reachedEnd = true;
          fail(e.toString());
        }
        productIndex2++;
        // Try to scroll until the next product card becomes visible
        Finder finderWidget = find
            .byKey(Key('${WidgetsKeys.productItemInListKey}$productIndex2'));
        if (finderWidget.evaluate().isEmpty) {
          try {
            await tester.drag(productListingScroll, const Offset(0, -400));
            await tester.pumpAndSettle();
            print('scroll for $productIndex2');
            expect(finderWidget, findsOneWidget);
            print('find index after scroll : $productIndex2');
          } catch (e) {
            // If the scroll fails, we have reached the end of the list
            print('scroll fails, we have reached the end of the list');
            reachedEnd = true;
          }
        } else {
          print('find index without scroll : $productIndex2');
        }
      }

      print('first Products Category : $productsBrandAfterFilter');
      expect(productsBrandAfterFilter.length, equals(1));
      await Future.delayed(const Duration(seconds: 2));

      ////////// check there are no filters  //////////////////
      final Finder productListingFilterListWidget =
          find.byKey(Key(WidgetsKeys.productListingFilterListKey));

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
        Key(WidgetsKeys.filterIconKey),
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
      await Future.delayed(const Duration(seconds: 2));
      //////////////////////////////////////////////////////////////////////////////
      //////////////////////////////////////////////////////////////////////////////
      //////////////////////////////////////////////////////////////////////////////
      //////////////// Filter page /////////////////////////////////
      await tester.tap(filterIconButton);
      await tester.pump();
      /////////////  Loading for categoris and brands  /////////////
      final Finder getCategoriesLoading = find.byKey(
        Key(WidgetsKeys.getCategoriesLoadingKey),
      );
      final Finder getBrandsLoadingKey = find.byKey(
        Key(WidgetsKeys.getCategoriesLoadingKey),
      );

      final Finder filterByCategoryHead = find.byKey(
        Key(WidgetsKeys.filterByCategoryHeadKey),
      );
      final Finder filterByBrandHead = find.byKey(
        Key(WidgetsKeys.filterByBrandHeadKey),
      );
      ///////////////////////////////
      expect(getCategoriesLoading, findsOneWidget);
      expect(getBrandsLoadingKey, findsOneWidget);

      expect(filterByCategoryHead, findsOneWidget);
      expect(filterByBrandHead, findsOneWidget);

      await tester.pumpAndSettle();

      expect(getCategoriesLoading, findsNothing);
      expect(getBrandsLoadingKey, findsNothing);

      await Future.delayed(const Duration(seconds: 2));
      //////////// filter by category in filter page //////

      final Finder categoryCircleFilterWidget2 = find.byKey(
        Key('${WidgetsKeys.categoryCircleWithOutSubProductListingFilterKey}0'),
      );

      String categoryName2 = tester
          .widget<FilterCircleWidget>(categoryCircleFilterWidget2)
          .categoryName
          .toString();

      print('Filter Category name $categoryName2');

      await tester.tap(categoryCircleFilterWidget2);
      await tester.pump();

      expect(getCategoriesLoading, findsOneWidget);
      expect(getBrandsLoadingKey, findsOneWidget);

      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));

      //////////////  Applay Filter Button /////////////////

      final Finder applayFilterButtonWidget = find.byKey(
        Key(WidgetsKeys.applayFilterButtonKey),
      );

      final Finder scrollableFinder = find.byKey(
        Key(WidgetsKeys.filterPageScrollKey),
      );

      ////////////// Scroll to find filter button ///////////////////

      await tester.drag(scrollableFinder, const Offset(0, -2000));

      await tester.pumpAndSettle();

      expect(applayFilterButtonWidget, findsOneWidget);

      await tester.tap(applayFilterButtonWidget);

      await tester.pumpAndSettle();

      //////////// Filtered products  ///////////////////
      int productIndex3 = 0;
      List<String> productsCategoryAfterFilter2 = [];

      productListingScroll =
          find.byKey(Key(WidgetsKeys.productListingScrollKey));

      reachedEnd = false;
      //////////////////// Scroll and test ////////////////////////////////////
      /////////////////////////////////
      while (!reachedEnd) {
        try {
          Key productKey =
              Key('${WidgetsKeys.productItemInListKey}$productIndex3');
          ///////////////////////
          String productBoutCategoryName = tester
              .widget<ProductItem>(find.byKey(productKey))
              .productItem
              .categories![0]
              .name
              .toString();

          String productName = tester
              .widget<ProductItem>(find.byKey(productKey))
              .productItem
              .name
              .toString();

          productsCategoryAfterFilter2.add(productBoutCategoryName);

          print('productBoutCategory first : $productBoutCategoryName');

          expect(productBoutCategoryName, equals(categoryName));

          expect(productName, equals(productsNameAfterFilter[productIndex3]));
        } catch (e) {
          reachedEnd = true;
          fail(e.toString());
        }
        productIndex3++;
        // Try to scroll until the next product card becomes visible
        Finder finderWidget = find
            .byKey(Key('${WidgetsKeys.productItemInListKey}$productIndex3'));
        if (finderWidget.evaluate().isEmpty) {
          try {
            await tester.drag(productListingScroll, const Offset(0, -400));
            await tester.pumpAndSettle();
            print('scroll for $productIndex3');
            expect(finderWidget, findsOneWidget);
            print('find index after scroll : $productIndex3');
          } catch (e) {
            // If the scroll fails, we have reached the end of the list
            print('scroll fails, we have reached the end of the list');
            reachedEnd = true;
          }
        } else {
          print('find index without scroll : $productIndex3');
        }
      }

      print('first Products Category 2 : $productsCategoryAfterFilter2');

      await Future.delayed(const Duration(seconds: 3));
      //////////// return to filter page ///////////////////
      await tester.tap(filterIconButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      await tester.drag(scrollableFinder, const Offset(0, -2000));
      await tester.pumpAndSettle();

      final Finder resetFiltersButtonWidget = find.byKey(
        Key(WidgetsKeys.resetFiltersKey),
      );

      expect(resetFiltersButtonWidget, findsOneWidget);

      await tester.tap(resetFiltersButtonWidget);

      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));

      /////////////  Filter By Brand in filter page  /////////////////

      await tester.drag(scrollableFinder, const Offset(0, 2000));
      await tester.pumpAndSettle();

      String brandName2 =
          tester.widget<MyTextWidget>(brandFilterNameWidget).text.toString();

      print('Filter Brand name $brandName2');

      await tester.tap(brandCircleFilterWidget);

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      ////////////////////////////
      await tester.drag(scrollableFinder, const Offset(0, 2000));
      await tester.pumpAndSettle();

      expect(applayFilterButtonWidget, findsOneWidget);

      await tester.tap(applayFilterButtonWidget);

      await tester.pumpAndSettle();

      ////////////// filtered products by brand /////////////////////////////
      int productIndex4 = 0;
      List<String> productsBrandAfterFilter2 = [];

      productListingScroll =
          find.byKey(Key(WidgetsKeys.productListingScrollKey));

      reachedEnd = false;
      //////////////////// Scroll and test ////////////////////////////////////
      /////////////////////////////////
      while (!reachedEnd) {
        try {
          Key productKey =
              Key('${WidgetsKeys.productItemInListKey}$productIndex4');
          ///////////////////////
          String productBoutBrandName = tester
              .widget<ProductItem>(find.byKey(productKey))
              .productItem
              .brand!
              .name
              .toString();

          String productName = tester
              .widget<ProductItem>(find.byKey(productKey))
              .productItem
              .name
              .toString();

          productsBrandAfterFilter2.add(productBoutBrandName);

          print('productBoutBrandName  : $productBoutBrandName');

          expect(productBoutBrandName, equals(brandName));

          expect(productName, equals(productBrandFilterName));
        } catch (e) {
          reachedEnd = true;
          fail(e.toString());
        }
        productIndex4++;
        // Try to scroll until the next product card becomes visible
        Finder finderWidget = find
            .byKey(Key('${WidgetsKeys.productItemInListKey}$productIndex4'));
        if (finderWidget.evaluate().isEmpty) {
          try {
            await tester.drag(productListingScroll, const Offset(0, -400));
            await tester.pumpAndSettle();
            print('scroll for $productIndex4');
            expect(finderWidget, findsOneWidget);
            print('find index after scroll : $productIndex4');
          } catch (e) {
            // If the scroll fails, we have reached the end of the list
            print('scroll fails, we have reached the end of the list');
            reachedEnd = true;
          }
        } else {
          print('find index without scroll : $productIndex4');
        }
      }

      print('first Products Category : $productsBrandAfterFilter2');
      expect(productsBrandAfterFilter2.length, equals(1));

      await Future.delayed(const Duration(seconds: 2));

      ////////// check there are no filters  //////////////////

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

      expect(filterIconButton, findsNothing);

      ///////////////////  Test X button in filter page /////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////
      ///////////////////// close filter  /////////////////////////////
      expect(appliedFiltersProductListingCloseButton, findsOneWidget);
      await tester.tap(appliedFiltersProductListingCloseButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      /////////////////////////////////////////////////
      expect(filterIconButton, findsOneWidget);
      await tester.tap(filterIconButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      /////////////// choose filter /////////////////////////////////////
      await tester.tap(brandCircleFilterWidget);

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      //////////////////////  Tap on close icon after filter ///////////////////////////////////////

      final Finder closeFilterPageIcon = find.byKey(
        Key(WidgetsKeys.closeFilterPageKey),
      );

      expect(closeFilterPageIcon, findsOneWidget);

      await tester.tap(closeFilterPageIcon);

      await tester.pumpAndSettle();

      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productsList,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find productsList  Success',
        failedMessage: 'Find productsList  failed',
      );

      await GlobalTestFunctions.findNoWidget(
        tester: tester,
        actual: appliedFiltersProductListingWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find No Applied Filters Widget Success',
        failedMessage: 'Find No Applied Filters Widget failed',
      );

      await Future.delayed(const Duration(seconds: 2));

      ///////////////////  Test filter page applied Filters X button /////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////
      //////////////////////////////////////////////////
      expect(filterIconButton, findsOneWidget);
      await tester.tap(filterIconButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      ///////////  choose filter /////////////////
      await tester.tap(brandCircleFilterWidget);

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      /////////////////// close applied Filters  //////////////////////////////
      await tester.drag(scrollableFinder, const Offset(0, 2000));
      await tester.pumpAndSettle();
      final Finder appliedFiltersPageCloseButton = find.byKey(
        Key(WidgetsKeys.appliedFiltersPageCloseKey),
      );
      expect(appliedFiltersPageCloseButton, findsOneWidget);
      await tester.tap(appliedFiltersPageCloseButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      ////////////////////////////
      final Finder categoriesFilterListFinder =
          find.byType(CategoriesFilterList);
      expect(categoriesFilterListFinder, findsOneWidget);
      String boutiqueSlug = tester
          .widget<CategoriesFilterList>(categoriesFilterListFinder)
          .boutiqueSlug;

      String category = tester
              .widget<CategoriesFilterList>(categoriesFilterListFinder)
              .category ??
          '';

      String key2 = boutiqueSlug + (category);

      homeState = homeBloc.state;

      Filter? filters2 = homeState.getProductFiltersModel[key2]?.filters != null
          ? homeState.getProductFiltersModel[key2]?.filters ?? Filter()
          : Filter();

      print(
          'categories length : ${filters2.categories == null ? null : filters2.categories!.length}');

      String boutiqueSlugInFilterData = filters2.boutiques?[0].slug ?? '';

      print(
          '////// boutiques length : ${filters2.boutiques?.length} /////////////////');

      print(
          '////// boutique Slug In Filter Data : $boutiqueSlugInFilterData /////////////////');

      expect(boutiqueSlugInFilterData, equals(boutiqueBestSellerSlug));

      await Future.delayed(const Duration(seconds: 2));
    },
  );
}
