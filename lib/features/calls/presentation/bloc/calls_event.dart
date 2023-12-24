part of 'calls_bloc.dart';

abstract class CallsEvent {}
// class CreateVideoCallEvent extends CallsEvent {}
class VideoCallEvent extends CallsEvent {
  String? receiverUserId;
  Map<String,dynamic> payload;
String? chatId;
  VideoCallEvent({
 this.chatId,
    required this.payload,
 this.receiverUserId});
}
class EndVideoCallEvent extends CallsEvent {


}

class AnswerVideoCallEvent extends CallsEvent{
  String chatId;

  AnswerVideoCallEvent({required this.chatId});
}
class RejectVideoCallEvent extends CallsEvent{

  String chatId;

  RejectVideoCallEvent({required this.chatId});
}
class ResponseRejectVideoCallEvent extends CallsEvent {


}

class InitResponseRejectVideoCallEvent extends CallsEvent {


}