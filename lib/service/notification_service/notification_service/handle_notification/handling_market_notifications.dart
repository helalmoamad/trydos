import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/home/data/models/get_count_likes_of_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/pages/cart_page.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';

enum TypeOfNotificationForMarketEnum {
  product_cart_expiration,
  product_availability,
  product_discount,
  product_comment,
  category_created,
  boutique_created
}

Map<TypeOfNotificationForMarketEnum, String> TypeOfNotificationForMarket = {
  TypeOfNotificationForMarketEnum.boutique_created: "boutique created",
  TypeOfNotificationForMarketEnum.category_created: "category created",
  TypeOfNotificationForMarketEnum.product_availability: "product availability",
  TypeOfNotificationForMarketEnum.product_cart_expiration:
      "product cart expiration",
  TypeOfNotificationForMarketEnum.product_comment: "product comment",
  TypeOfNotificationForMarketEnum.product_discount: "product discount",
};

class HandlingMarketNotifications {
  // في هذا التابع نفحص أنواع الإشعارات المتعلقة بالمتجر فإذا كانت للمتجر نعيد true والا نعيد false
  static bool checkIfTheNotificationIsNotRelatedToChat(RemoteMessage message) {
    Map<String, dynamic> data = jsonDecode(message.data["body"] ?? "");

    if (message.data["title"] == "market") {
      if (data["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.product_cart_expiration]) {
        GetIt.I<HomeBloc>().add(GetOldCartItemEvent());
        GetIt.I<HomeBloc>().add(GetCartItemEvent());
      }

      return true;
    }

    return false;
  }

  // هنا حسب نوع الاشعار نحدد إلى أي صفحة سننتقل او ماذا سنفعل
  static dealWithNotificationFromMarket(Map data, bool fromBackground) async {
    GetIt.I<PrefsRepository>().setNotificationTypesOfMarketFromTerminated("");
    print(
        "ddddddddddddddddddddddddddddddddddddddddddddddd${GetIt.I<PrefsRepository>().getNotificationTypeOfMarketFromTerminated ?? ""}ddddddddddddddddddddddddddddddddddd");
    //    BlocProvider.of<AppBloc>(context).add(ChangeBasePage(1));
    if (data["type"] ==
        TypeOfNotificationForMarket[
            TypeOfNotificationForMarketEnum.product_cart_expiration]) {
      try {
        Future.delayed(
          Duration(seconds: 1),
          () => Navigator.of(navigatorKey.currentState!.context)
              .push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => BasePage(),
          )),
        );

        BlocProvider.of<AppBloc>(navigatorKey.currentState!.context)
            .add(ChangeBasePage(1));
      } catch (e) {}
    } else {
      if (data["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.product_availability]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              GetFullProductDetailsEvent(
                  productId: data["product_id"].toString()));
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              AddCurrentSelectedColorEvent(
                  currentSelectedColor: data["image_color_sort"],
                  productId: data["product_id"].toString()));

          Future.delayed(
              Duration(seconds: 1),
              () => Navigator.of(navigatorKey.currentState!.context)
                      .push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProductDetailsPage(
                            fromNotification: fromBackground,
                            productIdForOpeningChatDirectly:
                                data["product_id"].toString()),
                  )));
        } catch (e) {}
      }
      if (data["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.product_discount]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              GetFullProductDetailsEvent(
                  productId: data["product_id"].toString()));
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              AddCurrentSelectedColorEvent(
                  currentSelectedColor: 0,
                  productId: data["product_id"].toString()));

          Future.delayed(
              Duration(seconds: 1),
              () => Navigator.of(navigatorKey.currentState!.context)
                      .push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProductDetailsPage(
                            fromNotification: fromBackground,
                            productIdForOpeningChatDirectly:
                                data["product_id"].toString()),
                  )));
        } catch (e) {}
      }
      if (data["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.product_comment]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              GetFullProductDetailsEvent(
                  productId: data["product_id"].toString()));
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              AddCurrentSelectedColorEvent(
                  currentSelectedColor: 0,
                  productId: data["product_id"].toString()));

          Future.delayed(
              Duration(seconds: 1),
              () => Navigator.of(navigatorKey.currentState!.context)
                      .push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProductDetailsPage(
                            fromNotification: fromBackground,
                            productIdForOpeningChatDirectly:
                                data["product_id"].toString()),
                  )));
        } catch (e) {}
      }
      if (data["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.category_created]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              ChangeSelectedFiltersEvent(
                  boutiqueSlug: "search",
                  fromHomePageSearch: true,
                  resetChoosedFilters: true,
                  requestToUpdateFilters: false));
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              ChangeAppliedFiltersEvent(
                  boutiqueSlug: "search", resetAppliedFilters: true));
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context)
              .add(ChangeAppliedFiltersEvent(
                  boutiqueSlug: "search",
                  filtersAppliedByUser: GetProductFiltersModel(
                      filters: Filter(categories: [
                    Category(
                      slug: data["category_slug"],
                      isSelected: true,
                      mostViewedProductThumbnail:
                          CategoryBanner(filePath: data["image"]),
                      flatPhotoPath:
                          CategoryBanner(filePath: data["image_svg"]),
                      name: data["category_name"],
                      id: int.tryParse(data["category_id"].toString()),
                    )
                  ]))));
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              GetProductsWithFiltersEvent(
                  category: data["category_slug"],
                  boutiqueSlug: "search",
                  offset: 1,
                  fromSearch: true));

          await Future.delayed(
              Duration(seconds: 1),
              () => Navigator.of(navigatorKey.currentState!.context).push(
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProductListingPage(
                              fromNotification: fromBackground,
                              fromSearch: true,
                              category: data["category_slug"],
                              boutiqueSlug: "search"))));
        } catch (e) {}
      }
      if (data["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.boutique_created]) {
        try {
          Map? boutiqueIcon = data["boutique_icon"] ?? {};
          List<BunnerBoutique>? boutiqueBannerList = List<BunnerBoutique>.from(
              data["banner"]!.map((x) => BunnerBoutique.fromJson(x)));

          print("${data["boutique_slug"]}" +
              "${data['description']}" +
              "${boutiqueIcon?["file_path"]}" +
              "${boutiqueBannerList}");

          await Future.delayed(
            Duration(seconds: 1),
            () => Navigator.of(navigatorKey.currentState!.context)
                .push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductListingPage(
                fromNotification: fromBackground,
                boutiqueSlug: data["boutique_slug"] ?? "",
                banner: boutiqueBannerList,
                boutiqueDescription: data["description"] ?? "",
                boutiqueFirstBanner: boutiqueBannerList[0].filePath ?? "",
                boutiqueIcon: boutiqueIcon?["file_path"] ?? "",
              ),
            )),
          );
        } catch (e) {}
      }
    }
  }

  // static dealWithNotificationFromTerminited( fromBackground) async {}
}
