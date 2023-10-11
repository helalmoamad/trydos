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
    for( lastPrevIndex ; lastPrevIndex< prevMessages.length ;lastPrevIndex++){
      if(prevMessages[lastPrevIndex].id == currMessages[0].id)break;
      resultMessages.add( prevMessages[lastPrevIndex++]);
    }
    resultMessages.addAll(currMessages);
    while(prevMessages[lastPrevIndex].id != currMessages[currMessages.length-1].id && lastPrevIndex<prevMessages.length){
      lastPrevIndex++;
    }
          for(int i= lastPrevIndex ; i< prevMessages.length ;i++){
            resultMessages.add( prevMessages[i]);
          }
          return chat.copyWith(messages: resultMessages);
        }).toList(), ...emptyChats]
      : newChats;
}
