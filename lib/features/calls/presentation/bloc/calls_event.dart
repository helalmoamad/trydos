part of 'calls_bloc.dart';

abstract class CallsEvent {}
// class CreateVideoCallEvent extends CallsEvent {}
class MakeCallEvent extends CallsEvent {
  String? receiverUserId;
  Map<String,dynamic> payload;
String? chatId;
final bool isVideo ;
  MakeCallEvent({
 this.chatId,
    required this.payload,
    required this.isVideo,
 this.receiverUserId});
}
class EndVideoCallEvent extends CallsEvent {


}

class AnswerVideoCallEvent extends CallsEvent{
  String messageId;
  String chatId;

  AnswerVideoCallEvent({required this.messageId,required this.chatId});
}
class RejectVideoCallEvent extends CallsEvent{

  String messageId;

  RejectVideoCallEvent({required this.messageId});
}
class ResponseRejectVideoCallEvent extends CallsEvent {


}

class InitResponseRejectVideoCallEvent extends CallsEvent {


}
class UserInteractWithCall extends CallsEvent {
  final bool rejectIt;

  UserInteractWithCall({required this.rejectIt});

}

