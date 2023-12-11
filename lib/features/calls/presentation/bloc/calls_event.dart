part of 'calls_bloc.dart';

abstract class CallsEvent {}
// class CreateVideoCallEvent extends CallsEvent {}
class VideoCallEvent extends CallsEvent {
  String chatId;

  VideoCallEvent({required this.chatId});
}
class AddChannelMemberToCallEvent extends CallsEvent
{
  int uid;

  AddChannelMemberToCallEvent({required this.uid});
}



class AnswerVideoCallEvent extends CallsEvent{
  String chatId;

  AnswerVideoCallEvent({required this.chatId});
}
class RejectVideoCallEvent extends CallsEvent{}
class ResponseAnswerVideoCallEvent extends CallsEvent{


  Map<String,dynamic> offer;
  Map<String,dynamic> iceCandidate;
  int chatId;
  ResponseAnswerVideoCallEvent({
    required this.chatId,
    required this.offer,
    required this.iceCandidate});



}