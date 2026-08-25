import 'package:flutter/foundation.dart' hide Category;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/pages/Order/orders_page.dart';
import 'package:trydos/features/home/presentation/pages/cart_page_new.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/main.dart';

import '../../../../features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/common/helper/dev_log.dart';

enum TypeOfNotificationForMarketEnum {
  product_cart_expiration,
  product_availability,
  product_discount,
  greeting,
  product_comment,
  category_created,
  boutique_created,
  product_hurry_up_quantity,
  product_hurry_up_time_left,
  product_when_change_in_price,
  remember_abandon_cart,
  product_before_stock_out,
  order_placed,
  order_status_changed_to_pending,
  order_status_changed_to_preparing,
  order_status_changed_to_canceled,
  order_status_changed_to_shipped,
  order_status_changed_to_delivered,
  order_status_changed_to_out_for_return,
  order_status_changed_to_out_for_delivery,
  seller_order_added,
  seller_comment_added,
  seller_product_stock_out,
  order_status_changed,
  seller_order_status_changed,
}

Map<TypeOfNotificationForMarketEnum, String> typeOfNotificationForMarket = {
  TypeOfNotificationForMarketEnum.boutique_created: "boutique created",
  TypeOfNotificationForMarketEnum.seller_order_added: "seller order added",
  TypeOfNotificationForMarketEnum.order_status_changed: "order status changed",
  TypeOfNotificationForMarketEnum.greeting: "greeting",
  TypeOfNotificationForMarketEnum.seller_comment_added: "seller comment added",
  TypeOfNotificationForMarketEnum.order_status_changed_to_out_for_return:
      "order status changed to out for return",
  TypeOfNotificationForMarketEnum.order_status_changed_to_out_for_delivery:
      "order status changed to out for delivery",
  TypeOfNotificationForMarketEnum.seller_product_stock_out:
      "seller product stock out",
  TypeOfNotificationForMarketEnum.seller_order_status_changed:
      "seller_order_status_changed",
  TypeOfNotificationForMarketEnum.remember_abandon_cart:
      "remember abandon cart",
  TypeOfNotificationForMarketEnum.order_status_changed_to_pending:
      "order status changed to pending",
  TypeOfNotificationForMarketEnum.order_status_changed_to_preparing:
      "order status changed to preparing",
  TypeOfNotificationForMarketEnum.order_status_changed_to_canceled:
      "order status changed to canceled",
  TypeOfNotificationForMarketEnum.order_status_changed_to_shipped:
      "order status changed to shipped",
  TypeOfNotificationForMarketEnum.order_status_changed_to_delivered:
      "order status changed to delivered",
  TypeOfNotificationForMarketEnum.category_created: "category created",
  TypeOfNotificationForMarketEnum.product_availability: "product availability",
  TypeOfNotificationForMarketEnum.product_cart_expiration:
      "product cart expiration",
  TypeOfNotificationForMarketEnum.product_comment: "product comment",
  TypeOfNotificationForMarketEnum.product_discount: "product discount",
  TypeOfNotificationForMarketEnum.product_when_change_in_price:
      "product when change in price",
  TypeOfNotificationForMarketEnum.product_before_stock_out:
      "product before stock out",
  TypeOfNotificationForMarketEnum.product_hurry_up_quantity:
      "product hurry up notification quantity",
  TypeOfNotificationForMarketEnum.product_hurry_up_time_left:
      "product hurry up notification time left",
  TypeOfNotificationForMarketEnum.order_placed: "order placed",
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
      devLog("data?['type']${data?["type"]}");
      if (data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_cart_expiration] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .remember_abandon_cart] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_hurry_up_time_left] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_hurry_up_quantity]) {
        GetIt.I<HomeBloc>().add(const GetOldCartItemEvent());
        GetIt.I<HomeBloc>().add(const GetCartItemEvent());
      }
      if (data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .order_placed] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .seller_order_added] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .seller_order_status_changed] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .order_status_changed_to_delivered] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .order_status_changed_to_out_for_return] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .order_status_changed_to_out_for_delivery] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .order_status_changed_to_canceled] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .order_status_changed_to_pending] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .order_status_changed_to_preparing] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .order_status_changed_to_shipped]) {
        GetIt.I<OrderBloc>().add(
          GetOrdersByOrderGroupIDEvent(
            fromNotification: true,
            status: GetIt.I<OrderBloc>().state.currentOrederStatus ?? "",
            orderGroupId: data?["order_group_id"].toString() ?? "",
          ),
        );
      }
      if (data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_availability] &&
          GetIt.I<HomeBloc>().state.currentSlugToRefreshFromNotification ==
              data?["product_slug"].toString()) {
        GetIt.I<HomeBloc>().add(
          GetProductDatailsWithoutRelatedProductsEvent(
            productSlug: data?["product_slug"].toString() ?? "",
          ),
        );
      }

      return true;
    }

    return false;
  }

  // هنا حسب نوع الاشعار نحدد إلى أي صفحة سننتقل او ماذا سنفعل
  static dealWithNotificationFromMarket(Map data, bool fromBackground) async {
    //    BlocProvider.of<AppBloc>(context).add(ChangeBasePage(1));
    if (data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .order_placed] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .seller_order_added] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .seller_order_status_changed] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .order_status_changed_to_delivered] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .order_status_changed_to_out_for_return] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .order_status_changed_to_out_for_delivery] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .order_status_changed_to_canceled] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .order_status_changed_to_pending] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .order_status_changed_to_preparing] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .order_status_changed_to_shipped]) {
      if (data["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .order_placed]) {
        GetIt.I<OrderBloc>().add(ChangeOrderByGroupStatus(loading: true));
        //      homeBloc.add(RemoveItemsFromCartAfterOrderSuccessEvent());
        GetIt.I<HomeBloc>().add(const GetCartItemEvent());
      }
      // GetIt.I<OrderBloc>().add(
      //   GetOrdersByOrderGroupIDEvent(orderGroupId: data["order_group_id"]));

      Future.delayed(
        const Duration(seconds: 1),
        () => Navigator.of(navigatorKey.currentState!.context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => OrdersPage(
              fromNotification: true,
              groupId: data["order_group_id"].toString(),
            ),
          ),
        ),
      );
    }
    if (data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .product_cart_expiration] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .remember_abandon_cart] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .product_hurry_up_time_left] ||
        data["type"] ==
            typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                .product_hurry_up_quantity]) {
      try {
        Future.delayed(
          const Duration(seconds: 1),
          () => Navigator.of(navigatorKey.currentState!.context).push(
            MaterialPageRoute(
              builder: (context) => const CartPage(fromeFilters: true),
            ),
          ),
        );

        //  BlocProvider.of<AppBloc>(navigatorKey.currentState!.context)
        //   .add(ChangeBasePage(1));
      } catch (e) {
        devLog('handling_market_notifications.dart: ignored error', e);
      }
    } else {
      if (data["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .product_availability]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            GetFullProductDetailsEvent(
              productSlug: data["product_slug"].toString(),
            ),
          );
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: data["image_color_sort"],
              productSlug: data["product_slug"].toString(),
            ),
          );

          Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.of(navigatorKey.currentState!.context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailsPageNew(
                      productSlugForOpeningChatDirectly: data["product_slug"]
                          .toString(),
                      fromNotification: fromBackground,
                      productIdForOpeningChatDirectly: data["product_id"]
                          .toString(),
                    ),
              ),
            ),
          );
        } catch (e) {
          devLog('handling_market_notifications.dart: ignored error', e);
        }
      }

      if (data["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .product_before_stock_out]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            GetFullProductDetailsEvent(
              productSlug: data["product_slug"].toString(),
            ),
          );
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: 0,
              productSlug: data["product_slug"].toString(),
            ),
          );

          Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.of(navigatorKey.currentState!.context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailsPageNew(
                      productSlugForOpeningChatDirectly: data["product_slug"]
                          .toString(),
                      fromNotification: fromBackground,
                      productIdForOpeningChatDirectly: data["product_id"]
                          .toString(),
                    ),
              ),
            ),
          );
        } catch (e) {
          devLog('handling_market_notifications.dart: ignored error', e);
        }
      }

      if (data["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_when_change_in_price] ||
          data["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .seller_product_stock_out]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            GetFullProductDetailsEvent(
              productSlug: data["product_slug"].toString(),
            ),
          );
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: 0,
              productSlug: data["product_slug"].toString(),
            ),
          );

          Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.of(navigatorKey.currentState!.context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailsPageNew(
                      productSlugForOpeningChatDirectly: data["product_slug"]
                          .toString(),
                      fromNotification: fromBackground,
                      productIdForOpeningChatDirectly: data["product_id"]
                          .toString(),
                    ),
              ),
            ),
          );
        } catch (e) {
          devLog('handling_market_notifications.dart: ignored error', e);
        }
      }

      if (data["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .product_discount]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            GetFullProductDetailsEvent(
              productSlug: data["product_slug"].toString(),
            ),
          );
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: 0,
              productSlug: data["product_slug"].toString(),
            ),
          );

          Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.of(navigatorKey.currentState!.context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailsPageNew(
                      productSlugForOpeningChatDirectly: data["product_slug"]
                          .toString(),
                      fromNotification: fromBackground,
                      productIdForOpeningChatDirectly: data["product_id"]
                          .toString(),
                    ),
              ),
            ),
          );
        } catch (e) {
          devLog('handling_market_notifications.dart: ignored error', e);
        }
      }
      if (data["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_comment] ||
          data["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .seller_comment_added]) {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            GetFullProductDetailsEvent(
              productSlug: data["product_slug"].toString(),
            ),
          );
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context).add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: 0,
              productSlug: data["product_slug"].toString(),
            ),
          );

          Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.of(navigatorKey.currentState!.context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailsPageNew(
                      fromNotificationComment: true,
                      fromNotification: fromBackground,
                      productSlugForOpeningChatDirectly: data["product_slug"]
                          .toString(),
                      productIdForOpeningChatDirectly: data["product_id"]
                          .toString(),
                    ),
              ),
            ),
          );
        } catch (e) {
          devLog('handling_market_notifications.dart: ignored error', e);
        }
      }
      if (data["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .category_created]) {
        try {
          BlocProvider.of<BoutiqueBloc>(navigatorKey.currentState!.context).add(
            ChangeAppliedFiltersEvent(
              boutiqueSlug: "search",
              resetAppliedFilters: true,
            ),
          );
          BlocProvider.of<BoutiqueBloc>(navigatorKey.currentState!.context).add(
            ChangeSelectedFiltersEvent(
              boutiqueSlug: "search",
              fromHomePageSearch: true,
              resetChoosedFilters: true,
              requestToUpdateFilters: false,
            ),
          );

          await Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.of(navigatorKey.currentState!.context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductListingPage(
                      getProductFiltersModel: GetProductFiltersModel(
                        filters: Filter(
                          categories: [
                            Category(
                              slug: data["category_slug"],
                              isSelected: true,

                              flatPhotoPath: CategoryBanner(
                                filePath: data["image"],
                              ),
                              name: data["category_name"],
                              id: int.tryParse(data["category_id"].toString()),
                            ),
                          ],
                        ),
                      ),
                      fromNotificationCategory: true,
                      fromBackground: fromBackground,
                      fromSearch: true,
                      boutiqueSlug: "search",
                    ),
              ),
            ),
          );
        } catch (e) {
          devLog('handling_market_notifications.dart: ignored error', e);
        }
      }
      if (data["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .boutique_created]) {
        try {
          Map? boutiqueIcon = data["boutique_icon"] ?? {};
          List<BunnerBoutique>? boutiqueBannerList = List<BunnerBoutique>.from(
            data["banner"]!.map((x) => BunnerBoutique.fromJson(x)),
          );

          if (kDebugMode)
            devLog(
              "${data["boutique_slug"]}" +
                  "${data['description']}" +
                  "${boutiqueIcon?["file_path"]}" +
                  "${boutiqueBannerList}",
            );

          await Future.delayed(
            const Duration(seconds: 1),
            () => Navigator.of(navigatorKey.currentState!.context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductListingPage(
                      fromBackground: fromBackground,
                      boutiqueSlug: data["boutique_slug"] ?? "",
                      banner: boutiqueBannerList,
                      boutiqueName: data["name"] ?? "",
                      boutiqueFirstBanner: boutiqueBannerList[0].filePath ?? "",
                      boutiqueIcon: boutiqueIcon?["file_path"] ?? "",
                    ),
              ),
            ),
          );
        } catch (e) {
          devLog('handling_market_notifications.dart: ignored error', e);
        }
      }
    }
  }

  // static dealWithNotificationFromTerminited( fromBackground) async {}
}

class SubsecribeOrUnSubsecribeToTopic {
  String countryISo =
      ((GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
                  ? GetIt.I<PrefsRepository>().userChoosedCountryIso
                  : GetIt.I<PrefsRepository>().countryIso) ??
              "")
          .toLowerCase();

  void subsecribeToOtherTopic(String topic) async {
    /*await FirebaseMessaging.instance.subscribeToTopic(topic);
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(topic);*/
    GetIt.I<HomeBloc>().add(SubscribeTopicForNotificationEvent(topic: topic));
  }

  void unSubsecribeToOtherTopic(String topic) async {
    /* await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(topic);*/
    GetIt.I<HomeBloc>().add(UnSubscribeTopicForNotificationEvent(topic: topic));
  }

  void subsecribeToBoutiqueCreated() async {
    /* await FirebaseMessaging.instance.subscribeToTopic(
        "boutique_created_${countryISo}_${LanguageService.languageCode}");

    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "boutique_created_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      const SubscribeTopicForNotificationEvent(topic: "boutique_created"),
    );
  }

  void unSubsecribeToBoutiqueCreated() async {
    /*await FirebaseMessaging.instance.unsubscribeFromTopic(
        "boutique_created_${countryISo}_${LanguageService.languageCode}");

    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "boutique_created_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      const UnSubscribeTopicForNotificationEvent(topic: "boutique_created"),
    );
  }

  void subsecribeToCategoryCreated() async {
    /*  await FirebaseMessaging.instance.subscribeToTopic(
        "category_created_${countryISo}_${LanguageService.languageCode}");

    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "category_created_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      const SubscribeTopicForNotificationEvent(topic: "category_created"),
    );
  }

  void unSubsecribeToCategoryCreated() async {
    /* await FirebaseMessaging.instance.unsubscribeFromTopic(
        "category_created_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "category_created_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      const UnSubscribeTopicForNotificationEvent(topic: "category_created"),
    );
  }

  void subsecribeToProductDiscount(String productId) async {
    /*  await FirebaseMessaging.instance.subscribeToTopic(
        "product_discount_${productId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "product_discount_${productId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      SubscribeTopicForNotificationEvent(
        topic: "product_discount_${productId}",
      ),
    );
  }

  void unSubsecribeToProductDiscount(String productId) async {
    /*  await FirebaseMessaging.instance.unsubscribeFromTopic(
        "product_discount_${productId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "product_discount_${productId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      UnSubscribeTopicForNotificationEvent(
        topic: "product_discount_${productId}",
      ),
    );
  }

  void subsecribeToProductComment(String productId) async {
    /* await FirebaseMessaging.instance.subscribeToTopic(
        "product_comment_${productId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "product_comment_${productId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      SubscribeTopicForNotificationEvent(topic: "product_comment_${productId}"),
    );
  }

  void unSubsecribeToProductComment(String productId) async {
    /*   await FirebaseMessaging.instance.unsubscribeFromTopic(
        "product_comment_${productId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "product_comment_${productId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      UnSubscribeTopicForNotificationEvent(
        topic: "product_comment_${productId}",
      ),
    );
  }

  void subsecribeToProductHurryUpTimeLeft(String cartId) async {
    /*   await FirebaseMessaging.instance.subscribeToTopic(
        "product_hurry_up_time_left_${cartId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "product_hurry_up_time_left_${cartId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      SubscribeTopicForNotificationEvent(
        topic: "product_hurry_up_time_left_${cartId}",
      ),
    );
  }

  void unSubsecribeToProductHurryUpTimeLeft(String cartId) async {
    /* await FirebaseMessaging.instance.unsubscribeFromTopic(
        "product_hurry_up_time_left_${cartId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "product_hurry_up_time_left_${cartId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      UnSubscribeTopicForNotificationEvent(
        topic: "product_hurry_up_time_left_${cartId}",
      ),
    );
  }

  void subsecribeToProductHurryUpQuantity(String cartId) async {
    /* await FirebaseMessaging.instance.subscribeToTopic(
        "product_hurry_up_quantity_${cartId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().setTopicThatAlreadySubsecribed(
        "product_hurry_up_quantity_${cartId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      SubscribeTopicForNotificationEvent(
        topic: "product_hurry_up_quantity_${cartId}",
      ),
    );
  }

  void unSubsecribeToProductHurryUpQuantity(String cartId) async {
    /*  await FirebaseMessaging.instance.unsubscribeFromTopic(
        "product_hurry_up_quantity_${cartId}_${countryISo}_${LanguageService.languageCode}");
    GetIt.I<PrefsRepository>().removeTopicThatAlreadySubsecribed(
        "product_hurry_up_quantity_${cartId}_${countryISo}_${LanguageService.languageCode}");*/
    GetIt.I<HomeBloc>().add(
      UnSubscribeTopicForNotificationEvent(
        topic: "product_hurry_up_quantity_${cartId}",
      ),
    );
  }
}
