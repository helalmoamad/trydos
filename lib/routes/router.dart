import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/authentication/presentation/pages/register_completed.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/features/story/presentation/pages/story_collection.dart';
import 'package:trydos/splash_page.dart';
import '../base_page.dart';
import '../features/authentication/presentation/pages/already_exist_account.dart';
import '../features/authentication/presentation/pages/number_not_registered.dart';
import '../features/chat/presentation/pages/chat_pages.dart';
import '../features/chat/presentation/pages/contacts_page.dart';
import '../features/story/presentation/pages/story_collection_page_view.dart';
import 'error_screen.dart';
import 'router_config.dart';

class GRouter {
  static GoRouter get router => _router;

  static RouterConfiguration get config => _config;

  static final RouterConfiguration _config = RouterConfiguration.init();

  static final GoRouter _router = GoRouter(
    observers: [BotToastNavigatorObserver()],
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
                print(state.uri.queryParameters);
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
    if (Platform.isIOS) {
      return CupertinoPage<T>(child: child, key: state.pageKey);
    } else {
      return MaterialPage<T>(child: child, key: state.pageKey);
    }
  }
}
