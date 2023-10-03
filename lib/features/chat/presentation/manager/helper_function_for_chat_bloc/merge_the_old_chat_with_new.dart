import '../../../data/models/my_chats_response_model.dart';

MergeOldMessageWithNew(
    {required List<Chat> newChats, required List<Chat> previousChats}) {
  List<Message> currMessages;
  List<Message> prevMessages;
  List<Message> resultMessages=[];
  int lastPrevIndex = 0;
  return (previousChats.isNotEmpty &&
          previousChats
              .any((element) => int.tryParse(element.id.toString()) != null))
      ? newChats.map((chat) {
    prevMessages = List.of(previousChats
        .firstWhere((element) => element.id == chat.id)
        .messages ??
        []);
    resultMessages=[];
          currMessages = List.of(chat.messages ?? []);
          for(int i=0;i<currMessages.length ; i++){
            if(lastPrevIndex < prevMessages.length && currMessages[i].id == prevMessages[lastPrevIndex].id){
              resultMessages.add( prevMessages[lastPrevIndex]);
              lastPrevIndex++;
            }else {
              resultMessages.add(currMessages[i]);
            }
          }
          for(int i= lastPrevIndex ; i< prevMessages.length ;i++){
            resultMessages.add( prevMessages[lastPrevIndex]);
          }
          return chat.copyWith(messages: [...chat.messages!, ...resultMessages]);
        }).toList()
      : newChats;
}
