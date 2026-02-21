import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../chat/data/models/my_chats_response_model.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';

List<Map<String, dynamic>> callerInfo({required String channelId}) {
  FlutterError.onError = (details) {
    debugPrint("asfsd${details.toString()}");
    GetIt.I<PrefsRepository>().saveRequestsData(
        null, null, null, null, null, null, null,
        error: details.toString());
  };
  Chat currentChat = GetIt.I<ChatBloc>().state.chats.firstWhere(
      (element) => element.id == channelId || element.localId == channelId,
      orElse: () => GetIt.I<ChatBloc>()
          .state
          .pinnedChats
          .firstWhere((element) => element.id == channelId || element.localId == channelId,));

  ChannelMember currentReceiver = currentChat.channelMembers!.firstWhere(
      (element) => element.userId! != GetIt.I<PrefsRepository>().myChatId);

  debugPrint("myChatId${GetIt.I<PrefsRepository>().myChatId}");
  debugPrint("chatVideoEvent${currentChat.id}");
  debugPrint("currentReceiverId${currentReceiver.userId}");

  // ChannelMember currentCaller = GetIt.I<ChatBloc>()
  //     .state
  //     .chats
  //     .firstWhere((element) => element.id == channelId , orElse: ()=> GetIt.I<ChatBloc>()
  //     .state
  //     .pinnedChats
  //     .firstWhere((element) => element.id == channelId))
  //     .channelMembers!
  //     .firstWhere(
  //         (element) => element.user!.id == GetIt.I<PrefsRepository>().myChatId);
  // String callerName = currentCaller.user!.contactUser == null
  //     ? (currentCaller.user!.name == null
  //         ? 'unKnown'
  //         : currentCaller.user!.name!)
  //     : (currentCaller.user!.name == null
  //         ? currentCaller.user!.contactUser!.mobilePhone!
  //         : currentCaller.user!.contactUser!.name!);

  String callerName = GetIt.I<PrefsRepository>().myChatName ??
      GetIt.I<PrefsRepository>().myPhoneNumber ??
      'Un Known';
  String? callerPhoto = GetIt.I<PrefsRepository>().myChatPhoto ?? (GetIt.I<PrefsRepository>().myChatPhoto == 'null'
      ? null
      : GetIt.I<PrefsRepository>().myChatPhoto);
  // String? callerPhoto = currentCaller.user == null
  //     ? null
  //     : (currentCaller.user!.photoPath == null
  //         ? null
  //         : currentCaller.user!.photoPath);
  if (int.tryParse(currentChat.id!) == null) {
//todo the chat dose not exist yet cause we generate the id for it
    return [
      {"currentReceiver": currentReceiver.userId},
      {
        "callerName": callerName,
        "callerPhoto": callerPhoto,
        "channelId" : currentChat.id.toString(),
        "mobilePhone": GetIt.I<PrefsRepository>().myPhoneNumber,
        "Target" : 'Application'
      }
    ];
  }

  return [
    {
      "callerName": callerName,
      "callerPhoto": callerPhoto,
      "channelId" : currentChat.id.toString(),
      "mobilePhone": GetIt.I<PrefsRepository>().myPhoneNumber,
      "Target" : 'Application'
    }
  ];
}
