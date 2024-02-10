// Future<void> showIncomingCall(
//     BuildContext context,
//     RemoteMessage remoteMessage,
//     FlutterCallkeep callKeep,
//     ) async {
//   var callerIdFrom = remoteMessage.payload()["caller_id"] as String;
//   var callerName = remoteMessage.payload()["caller_name"] as String;
//   var uuid = remoteMessage.payload()["uuid"] as String;
//   var hasVideo = remoteMessage.payload()["has_video"] == "true";
//
//   callKeep.on(CallKeepDidToggleHoldAction(), onHold);
//   callKeep.on(CallKeepPerformAnswerCallAction(), answerAction);
//   callKeep.on(CallKeepPerformEndCallAction(), endAction);
//   callKeep.on(CallKeepDidPerformSetMutedCallAction(), setMuted);
//
//   debugPrint('backgroundMessage: displayIncomingCall ($uuid)');
//
//   bool hasPhoneAccount = await callKeep.hasPhoneAccount();
//   if (!hasPhoneAccount) {
//     hasPhoneAccount = await callKeep.hasDefaultPhoneAccount(context, callSetup["android"]);
//   }
//
//   if (!hasPhoneAccount) {
//     return;
//   }
//
//   await callKeep.displayIncomingCall(uuid, callerIdFrom, localizedCallerName: callerName, hasVideo: hasVideo);
//   callKeep.backToForeground();
// }
//
// Future<void> closeIncomingCall(
//     RemoteMessage remoteMessage,
//     FlutterCallkeep callKeep,
//     ) async {
//   var uuid = remoteMessage.payload()[MessageManager.CALLER_UUID] as String;
//   debugPrint('backgroundMessage: closeIncomingCall ($uuid)');
//   bool hasPhoneAccount = await callKeep.hasPhoneAccount();
//   if (!hasPhoneAccount) {
//     return;
//   }
//   await callKeep.endAllCalls();
// }