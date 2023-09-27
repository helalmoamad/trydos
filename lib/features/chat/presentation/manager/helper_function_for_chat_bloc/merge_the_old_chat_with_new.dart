import '../../../data/models/my_chats_response_model.dart';

MergeOldMessageWithNew(
    {required List<Chat> newChats, required List<Chat> previousChats}) {
  List<Message> currMessages;
  List<Message> prevMessages;
  String? lastNewId;
  return (previousChats.isNotEmpty &&
          previousChats
              .any((element) => int.tryParse(element.id.toString()) != null))
      ? newChats.map((chat) {
          currMessages = List.of(chat.messages ?? []);
          lastNewId = currMessages[currMessages.length - 1].id;
          currMessages = [];
          prevMessages = List.of(previousChats
                  .firstWhere((element) => element.id == chat.id)
                  .messages ??
              []);
          for (int i = prevMessages.length - 1; i >= 0; i--) {
            if (prevMessages[i].id == lastNewId) break;
            currMessages.insert(0, prevMessages[i]);
          }
          return chat.copyWith(messages: [...chat.messages!, ...currMessages]);
        }).toList()
      : newChats;
}
