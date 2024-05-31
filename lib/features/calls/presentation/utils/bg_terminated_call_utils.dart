import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../bloc/calls_bloc.dart';
import '../pages/in_app_view.dart';

Future<void> checkAndNavigationCallingPage(BuildContext context,
    {bool fromTerminated = false,
    void Function()? whereToNavigationAfterCheck}) async {
  var currentCall = await getCurrentCall();
  await FlutterCallkitIncoming.endAllCalls();
  if (currentCall != null) {
    debugPrint(currentCall['extra']['message_id']);
    debugPrint(currentCall['extra']['channel_id']);
    GetIt.I<CallsBloc>().add(AnswerVideoCallEvent(
        chatId: currentCall['extra']['channel_id'],
        messageId: currentCall['extra']['message_id']));
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => AgoraInAppWebView(
          messageId: currentCall['extra']['message_id'],
          action: currentCall['accepted'] ? 'sent' : 'receive',
          type: currentCall['extra']['type'],
          channelId: currentCall['extra']['channel_id'],
          auth_token: GetIt.I<PrefsRepository>().chatToken!,
          uId: GetIt.I<PrefsRepository>().myChatId!.toString()),
    ))
        .then((value) {
      if (fromTerminated) {
        whereToNavigationAfterCheck!.call();
      }
    });
    return;
  }
  Future.delayed(
    Duration(seconds: 2),
    whereToNavigationAfterCheck,
  );
}

Future<dynamic> getCurrentCall() async {
  //check current call from pushkit if possible
  var calls = await FlutterCallkitIncoming.activeCalls();
  if (calls is List) {
    if (calls.isNotEmpty) {
      debugPrint('DATA: $calls');
      return calls[0];
    } else {
      return null;
    }
  }
}
