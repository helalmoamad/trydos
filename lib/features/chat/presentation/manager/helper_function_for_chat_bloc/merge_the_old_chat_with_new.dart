import 'package:trydos/core/utils/extensions/list.dart';

import '../../../data/models/my_chats_response_model.dart';

MergeOldMessageWithNew(
    {required List<Chat> newChats, required List<Chat> previousChats}) {
  List<Message> currMessages;
  List<Message> prevMessages;
  List<Message> resultMessages=[];
  List<Chat> emptyChats=[];
  previousChats.forEach((chat) {
    if(chat.messages.isNullOrEmpty && int.tryParse(chat.id.toString())==null){
      emptyChats.add(chat);
    }
  });
  return (previousChats.isNotEmpty &&
          previousChats
              .any((element) => int.tryParse(element.id.toString()) != null))
      ? [...newChats.map((chat) {
    prevMessages = List.of(previousChats
        .firstWhere((element) => element.id == chat.id,orElse: ()=> Chat())
        .messages ??
        []);
    if(prevMessages.isEmpty){
      return chat;
    }
    resultMessages=[];
    int lastPrevIndex = 0;
          currMessages = List.of(chat.messages ?? []);
          for(int i=0;i<currMessages.length  && lastPrevIndex < prevMessages.length; i++){
            if( currMessages[i].id == prevMessages[lastPrevIndex].id || currMessages[i].id == prevMessages[lastPrevIndex].localId){
              resultMessages.add( prevMessages[lastPrevIndex]);
              lastPrevIndex++;
            }else {
              resultMessages.add(currMessages[i]);
            }
          }
          for(int i= lastPrevIndex ; i< prevMessages.length ;i++){
            resultMessages.add( prevMessages[i]);
          }
          return chat.copyWith(messages: resultMessages);
        }).toList(), ...emptyChats]
      : newChats;
}
