import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
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
import 'package:trydos/service/language_service.dart';

enum TypeOfNotificationForMarketEnum {
  product_cart_expiration,
  product_availability,
  product_discount,
  product_comment,
  category_created,
  boutique_created,
  product_hurry_up_quantity,
  product_hurry_up_time_left,
  product_when_change_in_price,
  product_before_stock_out,
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
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(message.data["body"] ?? "");
    } catch (e) {
      return false;
    }

    if (message.data["title"] == "market") {
      if (data?["type"] ==
              TypeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_cart_expiration] ||
          data?["type"] ==
              TypeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_hurry_up_time_left] ||
          data?["type"] ==
              TypeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_hurry_up_quantity]) {
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
    //    BlocProvider.of<AppBloc>(context).add(ChangeBasePage(1));
    if (data["type"] ==
            TypeOfNotificationForMarket[
                TypeOfNotificationForMarketEnum.product_cart_expiration] ||
        data["type"] ==
            TypeOfNotificationForMarket[
                TypeOfNotificationForMarketEnum.product_hurry_up_time_left] ||
        data["type"] ==
            TypeOfNotificationForMarket[
                TypeOfNotificationForMarketEnum.product_hurry_up_quantity]) {
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
                  productSlug: data["product_slug"].toString(),
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
                            productSlugForOpeningChatDirectly:
                                data["product_slug"].toString(),
                            fromNotification: fromBackground,
                            productIdForOpeningChatDirectly:
                                data["product_id"].toString()),
                  )));
        } catch (e) {}
      }

      if (data["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.product_before_stock_out]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              GetFullProductDetailsEvent(
                  productSlug: data["product_slug"].toString(),
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
                            productSlugForOpeningChatDirectly:
                                data["product_slug"].toString(),
                            fromNotification: fromBackground,
                            productIdForOpeningChatDirectly:
                                data["product_id"].toString()),
                  )));
        } catch (e) {}
      }

      if (data["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.product_when_change_in_price]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              GetFullProductDetailsEvent(
                  productSlug: data["product_slug"].toString(),
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
                            productSlugForOpeningChatDirectly:
                                data["product_slug"].toString(),
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
                  productSlug: data["product_slug"].toString(),
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
                            productSlugForOpeningChatDirectly:
                                data["product_slug"].toString(),
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
                  productSlug: data["product_slug"].toString(),
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
                            productSlugForOpeningChatDirectly:
                                data["product_slug"].toString(),
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
              ChangeAppliedFiltersEvent(
                  boutiqueSlug: "search", resetAppliedFilters: true));
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
              ChangeSelectedFiltersEvent(
                  boutiqueSlug: "search",
                  fromHomePageSearch: true,
                  resetChoosedFilters: true,
                  requestToUpdateFilters: false));

          await Future.delayed(
              Duration(seconds: 1),
              () => Navigator.of(navigatorKey.currentState!.context).push(
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProductListingPage(
                              getProductFiltersModel: GetProductFiltersModel(
                                  filters: Filter(categories: [
                                Category(
                                  slug: data["category_slug"],
                                  isSelected: true,
                                  mostViewedProductThumbnail:
                                      CategoryBanner(filePath: data["image"]),
                                  flatPhotoPath: CategoryBanner(
                                      filePath: data["image_svg"]),
                                  name: data["category_name"],
                                  id: int.tryParse(
                                      data["category_id"].toString()),
                                )
                              ])),
                              fromNotificationCategory: true,
                              fromBackground: fromBackground,
                              fromSearch: true,
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
                fromBackground: fromBackground,
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

class SubsecribeOrUnSubsecribeToTopic {
  String countryISo = ((GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
              ? GetIt.I<PrefsRepository>().userChoosedCountryIso
              : GetIt.I<PrefsRepository>().countryIso) ??
          "")
      .toLowerCase();

  void SubsecribeToOtherTopic(String topic) async {
    /*await FirebaseMessaging.instance.subscribeToTopic(topic);
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(topic);*/
    GetIt.I<HomeBloc>().add(SubscribeTopicForNotificationEvent(topic: topic));
  }

  void UnSubsecribeToOtherTopic(String topic) async {
    /* await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(topic);*/
    GetIt.I<HomeBloc>().add(UnSubscribeTopicForNotificationEvent(topic: topic));
  }

  void SubsecribeToBoutiqueCreated() async {
    /* await FirebaseMessaging.instance.subscribeToTopic(
        "boutique_created_${countryISo}_${LanguageService.languageCode}");

    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "boutique_created_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>()
        .add(SubscribeTopicForNotificationEvent(topic: "boutique_created"));
  }

  void UnSubsecribeToBoutiqueCreated() async {
    /*await FirebaseMessaging.instance.unsubscribeFromTopic(
        "boutique_created_${countryISo}_${LanguageService.languageCode}");

    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "boutique_created_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>()
        .add(UnSubscribeTopicForNotificationEvent(topic: "boutique_created"));
  }

  void SubsecribeToCategoryCreated() async {
    /*  await FirebaseMessaging.instance.subscribeToTopic(
        "category_created_${countryISo}_${LanguageService.languageCode}");

    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "category_created_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>()
        .add(SubscribeTopicForNotificationEvent(topic: "category_created"));
  }

  void UnSubsecribeToCategoryCreated() async {
    /* await FirebaseMessaging.instance.unsubscribeFromTopic(
        "category_created_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "category_created_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>()
        .add(UnSubscribeTopicForNotificationEvent(topic: "category_created"));
  }

  void SubsecribeToProductDiscount(String productId) async {
    /*  await FirebaseMessaging.instance.subscribeToTopic(
        "product_discount_${productId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "product_discount_${productId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(SubscribeTopicForNotificationEvent(
        topic: "product_discount_${productId}"));
  }

  void unSubsecribeToProductDiscount(String productId) async {
    /*  await FirebaseMessaging.instance.unsubscribeFromTopic(
        "product_discount_${productId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "product_discount_${productId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(UnSubscribeTopicForNotificationEvent(
        topic: "product_discount_${productId}"));
  }

  void SubsecribeToProductComment(String productId) async {
    /* await FirebaseMessaging.instance.subscribeToTopic(
        "product_comment_${productId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "product_comment_${productId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(SubscribeTopicForNotificationEvent(
        topic: "product_comment_${productId}"));
  }

  void UnSubsecribeToProductComment(String productId) async {
    /*   await FirebaseMessaging.instance.unsubscribeFromTopic(
        "product_comment_${productId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "product_comment_${productId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(UnSubscribeTopicForNotificationEvent(
        topic: "product_comment_${productId}"));
  }

  void SubsecribeToProductHurryUpTimeLeft(String cartId) async {
    /*   await FirebaseMessaging.instance.subscribeToTopic(
        "product_hurry_up_time_left_${cartId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "product_hurry_up_time_left_${cartId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(SubscribeTopicForNotificationEvent(
        topic: "product_hurry_up_time_left_${cartId}"));
  }

  void UnSubsecribeToProductHurryUpTimeLeft(String cartId) async {
    /* await FirebaseMessaging.instance.unsubscribeFromTopic(
        "product_hurry_up_time_left_${cartId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "product_hurry_up_time_left_${cartId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(UnSubscribeTopicForNotificationEvent(
        topic: "product_hurry_up_time_left_${cartId}"));
  }

  void SubsecribeToProductHurryUpQuantity(String cartId) async {
    /* await FirebaseMessaging.instance.subscribeToTopic(
        "product_hurry_up_quantity_${cartId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "product_hurry_up_quantity_${cartId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(SubscribeTopicForNotificationEvent(
        topic: "product_hurry_up_quantity_${cartId}"));
  }

  void UnSubsecribeToProductHurryUpQuantity(String cartId) async {
    /*  await FirebaseMessaging.instance.unsubscribeFromTopic(
        "product_hurry_up_quantity_${cartId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "product_hurry_up_quantity_${cartId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(UnSubscribeTopicForNotificationEvent(
        topic: "product_hurry_up_quantity_${cartId}"));
  }
}
