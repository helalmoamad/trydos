import '../../../data/models/my_chats_response_model.dart';

List<Chat> mergeChatsFromPagination(
    {required List<Chat> previousChats, required List<Chat> newChats}) {
  List<String> ids = [];
  newChats.forEach((element) {
    ids.add(element.id.toString());
  });
  previousChats.removeWhere((element) => ids.contains(element.id.toString()));

  return [...previousChats, ...newChats];
}
