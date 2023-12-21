import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../chat/data/models/my_chats_response_model.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';

Map<String, dynamic> callerInfo({required String channelId}) {
  Chat currentChat = GetIt.I<ChatBloc>()
      .state
      .chats
      .firstWhere((element) => element.id == channelId);

  debugPrint("myChatId${GetIt.I<PrefsRepository>().myChatId}");
  debugPrint("chatVideoEvent${currentChat.id}");

  ChannelMember currentCaller = GetIt.I<ChatBloc>()
      .state
      .chats
      .firstWhere((element) => element.id == channelId)
      .channelMembers!
      .firstWhere(
          (element) => element.user!.id == GetIt.I<PrefsRepository>().myChatId);
  String callerName = currentCaller.user!.contactUser == null
      ? (currentCaller.user!.name == null
          ? 'unKnown'
          : currentCaller.user!.name!)
      : (currentCaller.user!.name == null
          ? currentCaller.user!.contactUser!.mobilePhone!
          : currentCaller.user!.contactUser!.name!);


String? callerPhoto=  currentCaller.user==null?null:(currentCaller.user!.photoPath ==null?null:currentCaller.user!.photoPath);

return {"callerName":callerName,"callerPhoto":callerPhoto,"mobilePhone":currentCaller.user!.mobilePhone!};
}
