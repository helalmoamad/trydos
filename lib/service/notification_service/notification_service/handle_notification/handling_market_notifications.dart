import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/pages/cart_page.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';

class HandlingMarketNotifications {
  // في هذا التابع نفحص أنواع الإشعارات المتعلقة بالمتجر فإذا كانت للمتجر نعيد true والا نعيد false
  static bool checkIfTheNotificationIsNotRelatedToChat(RemoteMessage message) {
    if (message.data["title"] == "market") {
      return true;
    }
    print(message.data.toString());

    return false;
  }

  // هنا حسب نوع الاشعار نحدد إلى أي صفحة سننتقل او ماذا سنفعل
  static dealWithNotificationFromMarket(Map data, bool fromBackGround) {
    //    BlocProvider.of<AppBloc>(context).add(ChangeBasePage(1));
    if (data["type"] == "product cart expiration cart") {
      try {
        Navigator.of(navigatorKey.currentState!.context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CartPage(
            fromeNotification: true,
          ),
        ));
      } catch (e) {}
    } else {
      if (data["type"] == "product cart expiration") {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context)
              .add(GetFullProductDetailsEvent(productId: "5544"));
          Navigator.of(navigatorKey.currentState!.context)
              .push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailsPage(
                    fromNotification: fromBackGround,
                    productIdForOpeningChatDirectly: "5544"),
          ));
        } catch (e) {}
      }
      if (data["type"] == "product cart expiration offer") {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context)
              .add(GetFullProductDetailsEvent(productId: "5544"));
          Navigator.of(navigatorKey.currentState!.context)
              .push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailsPage(
                    fromNotification: fromBackGround,
                    productIdForOpeningChatDirectly: "5544"),
          ));
        } catch (e) {}
      }
      if (data["type"] == "product cart expiration comment") {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context)
              .add(GetFullProductDetailsEvent(productId: "5544"));
          Navigator.of(navigatorKey.currentState!.context)
              .push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailsPage(
                    fromNotification: fromBackGround,
                    productIdForOpeningChatDirectly: "5544"),
          ));
        } catch (e) {}
      }
      if (data["type"] == "product cart expiration buyyer") {
        try {
          BlocProvider.of<HomeBloc>(navigatorKey.currentState!.context)
              .add(GetFullProductDetailsEvent(productId: "5544"));
          Navigator.of(navigatorKey.currentState!.context)
              .push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailsPage(
                    fromNotification: fromBackGround,
                    productIdForOpeningChatDirectly: "5544"),
          ));
        } catch (e) {}
      }
      if (data["type"] == "product cart expiration boutique") {
        try {
          navigatorKey.currentState!.context.go(GRouter
                  .config.applicationRoutes.kProductListingPagePath +
              '?boutiqueSlug=men-section-66&boutiqueIcon=""  &boutiqueDescription="0000"&boutiqueFirstBanner="000"00&fromNotification=${fromBackGround == true ? "1" : "0"}&withSlidingImages=${"false"}');
        } catch (e) {}
      }
    }
  }
}
