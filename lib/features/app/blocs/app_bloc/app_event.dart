
import 'package:equatable/equatable.dart';

 abstract class AppEvent extends Equatable{
}

class ChangeBasePage extends AppEvent{
  ChangeBasePage(this.index);

  final int index;

  @override
  // TODO: implement props
  List<Object?> get props =>[index];
}
class ChangeTab extends AppEvent{
  ChangeTab(this.index);

  final int index;

  @override
  // TODO: implement props
  List<Object?> get props =>[index];
}
class ChangeTabInChat extends AppEvent{
  ChangeTabInChat(this.index);

  final int index;

  @override
  // TODO: implement props
  List<Object?> get props =>[index];
}
class ShowOrHideBars extends AppEvent{
  ShowOrHideBars(this.show);

  final bool show;

  @override
  // TODO: implement props
  List<Object?> get props =>[show];
}

class RefreshChatInputField extends AppEvent{
   final bool thereIsReply;
   final bool replyOnMe;
   final String replyType;
   final String? message;
   final String? messageId;
   final String? imageUrl;
   final DateTime? time;
   final int? senderParentMessageId;
   RefreshChatInputField(this.thereIsReply , this.replyType, this.replyOnMe,{this.senderParentMessageId , this.messageId, this.message, this.imageUrl ,this.time});
  @override
  // TODO: implement props
  List<Object?> get props => [thereIsReply , replyType , replyOnMe , senderParentMessageId ,messageId , message , imageUrl,time];
}

class AddUserToTypingList extends AppEvent{
  AddUserToTypingList(this.userId , this.chatId);

  final int userId;
  final int chatId;

  @override
  // TODO: implement props
  List<Object?> get props =>[userId ,chatId];
}

class RemoveUserFromTypingList extends AppEvent{
  RemoveUserFromTypingList(this.chatId);
  final int chatId;

  @override
  // TODO: implement props
  List<Object?> get props =>[chatId];
}