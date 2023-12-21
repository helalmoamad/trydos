part of 'calls_bloc.dart';

abstract class CallsEvent {}
// class CreateVideoCallEvent extends CallsEvent {}
class VideoCallEvent extends CallsEvent {
  String chatId;
  Map<String,dynamic> payload;

  VideoCallEvent({

    required this.payload,
    required this.chatId});
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