import '../../../data/models/my_chats_response_model.dart';

MergeOldMessageWithNew(
    {required List<Chat> newChats, required List<Chat> previousChats}) {
  List<Message> currMessages;
  List<Message> prevMessages;
  List<Message> resultMessages=[];
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
            if(currMessages[i].id == prevMessages[i].id){
              resultMessages[i] = prevMessages[i];
            }else {
              resultMessages[i]=currMessages[i];
            }
          }
          for(int i= currMessages.length ; i< prevMessages.length ;i++){
            resultMessages[i] = prevMessages[i];
          }
          return chat.copyWith(messages: [...chat.messages!, ...resultMessages]);
        }).toList()
      : newChats;
}
