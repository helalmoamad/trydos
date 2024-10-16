import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/authentication/presentation/pages/register_completed.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/splash_page.dart';
import '../base_page.dart';
import '../features/authentication/presentation/pages/already_exist_account.dart';
import '../features/authentication/presentation/pages/number_not_registered.dart';
import '../features/calls/presentation/pages/agora_webview.dart';
import '../features/calls/presentation/pages/answer_call.dart';
import '../features/chat/presentation/pages/chat_pages.dart';
import '../features/chat/presentation/pages/contacts_page.dart';
import '../main.dart';
import 'error_screen.dart';
import 'router_config.dart';

class GRouter {
  static GoRouter get router => _router;

  static RouterConfiguration get config => _config;

  static final RouterConfiguration _config = RouterConfiguration.init();

  static final GoRouter _router = GoRouter(
    observers: [
      BotToastNavigatorObserver(),
      SentryNavigatorObserver(),
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
    ],
    // initialLocation: _config.applicationRoutes.kWebView,
    navigatorKey: navigatorKey,
    routes: <RouteBase>[
      GoRoute(
          path: _config.kRootRoute,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _builderPage(
              child: const SplashPage(),
              state: state,
            );
          }),
      GoRoute(
          path: _config.applicationRoutes.kWebView,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _builderPage(
              child: AgoraWebView(
                type: 'video',
                channelId: '155',
                uId: '6',
                message_id: '',
                action: '',
                auth_token: '',
              ),
              state: state,
            );
          }),

      // GoRoute(
      //     path: _config.applicationRoutes.kRoomCallPage,
      //     pageBuilder: (BuildContext context, GoRouterState state) {
      //       return _builderPage(
      //         child:  RoomCallPage(),
      //         state: state,
      //       );
      //     }),
      GoRoute(
          path: _config.applicationRoutes.kAnswerCall,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _builderPage(
              child: AnswerCall(
                channelName: state.uri.queryParameters['channelName']!,
                messageId: state.uri.queryParameters['messageId']!,
                callerName: state.uri.queryParameters['callerName']!,
                callerPhoto: state.uri.queryParameters['callerPhoto']!,
              ),
              state: state,
            );
          }),
      GoRoute(
        path: _config.applicationRoutes.kRegistrationCompletedPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(
            child: RegisterCompleted(
                userName: state.uri.queryParameters['userName']!),
            state: state,
          );
        },
      ),
      GoRoute(
        path: _config.applicationRoutes.kLoginSuccessfullyPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(
            child: LoginSuccessfully(
                phoneNumber: state.uri.queryParameters['phoneNumber']!),
            state: state,
          );
        },
      ),
      GoRoute(
        path: _config.applicationRoutes.kRegistrationPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _builderPage(
            child: RegistrationPage(),
            state: state,
          );
        },
      ),
      GoRoute(
          path: _config.applicationRoutes.kChatPage,
          pageBuilder: (BuildContext context, GoRouterState state) {
            void Function(int, String) onSendForwardMessage =
                state.extra as void Function(int, String);
            return _builderPage(
              child: ChatPages(
                description: state.uri.queryParameters['description']!,
                // ignore: sdk_version_since
                hideCallsAndStories: bool.parse(
                    state.uri.queryParameters['hideCallsAndStories']!),
                onSendForwardMessage: onSendForwardMessage,
              ),
              state: state,
            );
          }),
      GoRoute(
          path: _config.applicationRoutes.kBasePage,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _builderPage(
              child: const BasePage(),
              state: state,
            );
          },
          routes: [
            GoRoute(
              path: _config.applicationRoutes.kSinglePageChatPageName,
              pageBuilder: (BuildContext context, GoRouterState state) {
                debugPrint(state.uri.queryParameters.toString());
                return _builderPage(
                  child: SinglePageChat(
                    chatId: state.uri.queryParameters['chatId']!,
                    fullReceiverName:
                        state.uri.queryParameters['fullReceiverName']!,
                    receiverName: state.uri.queryParameters['receiverName']!,
                    receiverPhone: state.uri.queryParameters['receiverPhone']!,
                    senderName: state.uri.queryParameters['senderName']!,
                    receiverPhoto:
                        state.uri.queryParameters['receiverPhoto'] == 'null'
                            ? null
                            : state.uri.queryParameters['receiverPhoto'],
                    senderPhoto:
                        state.uri.queryParameters['senderPhoto'] == 'null'
                            ? null
                            : state.uri.queryParameters['senderPhoto'],
                  ),
                  state: state,
                );
              },
            ),
            GoRoute(
                path: _config.applicationRoutes.kRegistrationPageName,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return _builderPage(
                    child: RegistrationPage(),
                    state: state,
                  );
                },
                routes: [
                  GoRoute(
                      path: _config.applicationRoutes.kNumberNotRegisteredName,
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        return _builderPage(
                          child: NumberNotRegistered(
                            phoneNumber:
                                state.uri.queryParameters['phoneNumber']!,
                          ),
                          state: state,
                        );
                      }),
                  GoRoute(
                      path: _config.applicationRoutes.kUserExistName,
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        return _builderPage(
                          child: AlreadyExistAccount(
                            phoneNumber:
                                state.uri.queryParameters['phoneNumber']!,
                          ),
                          state: state,
                        );
                      }),
                ]),
            GoRoute(
              path: _config.applicationRoutes.kMyContactsPageName,
              pageBuilder: (BuildContext context, GoRouterState state) {
                return _builderPage(
                  child: const MyContactsPage(),
                  state: state,
                );
              },
            ),
            // GoRoute(
            //   path: _config.applicationRoutes.kPageViewStoryCollectionsPageName,
            //   pageBuilder: (BuildContext context, GoRouterState state) {
            //     return _builderPage(
            //       child:  StoryCollectionPageView(initialPage: int.parse(state.uri.queryParameters['initialPage']!),),
            //       state: state,
            //     );
            //   },
            // ),
          ]),
      // StatefulShellRoute.indexedStack(
      //   branches: [
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: _config.applicationRoutes.kHomePage,
      //           pageBuilder: (BuildContext context, GoRouterState state) {
      //             return _builderPage(
      //               child: const HomePage(),
      //               state: state,
      //             );
      //           },
      //         ),
      //         GoRoute(
      //           path: _config.applicationRoutes.kHomePage,
      //           pageBuilder: (BuildContext context, GoRouterState state) {
      //             return _builderPage(
      //               child: const HomePage(),
      //               state: state,
      //             );
      //           },
      //         ),
      //         GoRoute(
      //           path: _config.applicationRoutes.kChatPage,
      //           pageBuilder: (BuildContext context, GoRouterState state) {
      //             return _builderPage(
      //               child: ChatPages(description: ''),
      //               state: state,
      //             );
      //           },
      //         ),
      //         GoRoute(
      //           path: _config.applicationRoutes.kHomePage,
      //           pageBuilder: (BuildContext context, GoRouterState state) {
      //             return _builderPage(
      //               child: const HomePage(),
      //               state: state,
      //             );
      //           },
      //         ),
      //       ],
      //     ),
      //   ],
      //   builder: (context, state, navigationShell) {
      //     return BasePage(
      //       navigationShell: navigationShell,
      //     );
      //   },
      // ),
    ],
    errorBuilder: (context, state) => ErrorScreen(exception: state.error),
  );

  static Page<dynamic> _builderPage<T>(
      {required Widget child, required GoRouterState state}) {
    //if (Platform.isIOS) {
    return MaterialPage<T>(child: child, key: state.pageKey);
    // } else {
    //   return MaterialPage<T>(child: child, key: state.pageKey);
    // }
  }
}
