import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../app/my_cached_network_image.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';

import '../../data/models/get_user_notifications_model.dart';
import '../manager/homeBloc/home_bloc.dart';
import '../manager/homeBloc/home_event.dart';
import '../manager/homeBloc/home_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late HomeBloc homeBloc;

  final ScrollController notifiScrollController = ScrollController();

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetUserNotificationEvent(getWithPagination: false));

    notifiScrollController.addListener(() async {
      if (notifiScrollController.position.maxScrollExtent ==
          notifiScrollController.offset) {
        debugPrint('scrollController');
        homeBloc.add(GetUserNotificationEvent(getWithPagination: true));
      }
    });

    super.initState();
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: GlobalScreenConst.NOTIFICATIONS_SCREEN,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': GlobalScreenConst.NOTIFICATIONS_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );
      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.getUserNotificationModel?.paginationStatus !=
            c.getUserNotificationModel?.paginationStatus,
        builder: (context, state) {
          int itemsCount = state.getUserNotificationModel == null
              ? 0
              : state.getUserNotificationModel!.items.length;
          List<NotificationItemModel> items =
              state.getUserNotificationModel?.items ?? [];
          return (state.getUserNotificationModel == null ||
                  state.getUserNotificationModel?.paginationStatus ==
                      PaginationStatus.failure ||
                  ((state.getUserNotificationModel?.paginationStatus ==
                              PaginationStatus.loading ||
                          state.getUserNotificationModel?.paginationStatus ==
                              PaginationStatus.initial) &&
                      state.getUserNotificationModel?.items.length == 0))
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.separated(
                    controller: notifiScrollController,
                    itemCount: itemsCount + 1,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index < itemsCount) {
                        return ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                          onTap: () {
                            HandlingMarketNotifications
                                .dealWithNotificationFromMarket(
                                    jsonDecode(items[index]
                                            .descriptionToHandleNotification ??
                                        ""),
                                    false);
                          },
                          leading: MyCachedNetworkImage(
                            ordinalHeight: null,
                            ordinalwidth: null,
                            imageUrl: items[index].description?.type ==
                                    "boutique created"
                                ? (items[index].description?.banner?.length ??
                                            0) ==
                                        0
                                    ? ""
                                    : items[index]
                                            .description
                                            ?.banner![0]
                                            .filePath ??
                                        ''
                                : items[index].description?.image ?? '',
                            imageWidth: null,
                            imageHeight: null,
                            height: 60,
                            width: 60,
                            imageFit: BoxFit.cover,
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              items[index].description?.type ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                color: Colors.black,
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 1,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            items[index].description?.description ?? '',
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: Colors.grey,
                              letterSpacing: 0.18,
                              fontSize: 13,
                              height: 1,
                            ),
                          ),
                        );
                      } else {
                        if (itemsCount > 4) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child:
                                  state.getUserNotificationModel!.hasReachedMax
                                      ? Text('No More Items')
                                      : const CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        color: const Color.fromARGB(255, 241, 241, 241),
                        height: 5,
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
