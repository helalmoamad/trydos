part of 'calls_bloc.dart';

enum MakeCallStatus {
  init,
  loading,
  success,
  failure,
  cancel,
  endCall,
  startCall
}

enum OpenLocalVideoAndAudioStatus { init, loading, success, failure }

enum OpenRemoteVideoAndAudioStatus { init, loading, success, failure }

enum RejectVideoCallStatus { init, loading, success, failure }

enum StopRingToneReason { init, refuse, accept }
enum DeleteCallRegStatus { init, loading, success, failure }
enum GetMyCallsStatus { init, loading, success, failure }

@immutable
class CallsState {
  final String? messageId;
  final List<calls.Data>? callRegister;
  final int? sessionId;
  final DeleteCallRegStatus deleteCallRegStatus;
  final GetMyCallsStatus getMyCallsStatus;
  final RejectVideoCallStatus rejectVideoCallStatus;
  final String? agoraToken;
  final String? channelName;
  final List<int> channelMembers;
  final OpenRemoteVideoAndAudioStatus openRemoteVideoAndAudioStatus;
  final MakeCallStatus makeCallStatus;
  final OpenLocalVideoAndAudioStatus openLocalVideoAndAudioStatus;
  final StopRingToneReason stopRingToneReason;
  final bool isVideoCall;
  CallsState(
      {this.messageId,
      this.sessionId = 23,
      this.callRegister,
      this.rejectVideoCallStatus = RejectVideoCallStatus.init,
      this.agoraToken = null,
      this.getMyCallsStatus = GetMyCallsStatus.init,
      this.deleteCallRegStatus = DeleteCallRegStatus.init,
      this.channelName = null,
      this.isVideoCall = false,
      this.stopRingToneReason = StopRingToneReason.init,
      this.channelMembers = const [],
      this.openRemoteVideoAndAudioStatus = OpenRemoteVideoAndAudioStatus.init,
      this.openLocalVideoAndAudioStatus = OpenLocalVideoAndAudioStatus.init,
      this.makeCallStatus = MakeCallStatus.init});

  CallsState copyWith(
      {String? messageId,
      List<calls.Data>? callRegister,
      int? sessionId,
      GetMyCallsStatus? getMyCallsStatus,
      RejectVideoCallStatus? rejectVideoCallStatus,
      StopRingToneReason? stopRingToneReason,
      String? agoraToken,
      String? channelName,
      List<int>? channelMembers,
      DeleteCallRegStatus? deleteCallRegStatus,
      
      bool? isVideoCall,
      OpenLocalVideoAndAudioStatus? openVideoAndAudioStatus,
      OpenRemoteVideoAndAudioStatus? openRemoteVideoAndAudioStatus,
      MakeCallStatus? makeCallStatus}) {
    return CallsState(
        messageId: messageId,
        deleteCallRegStatus: deleteCallRegStatus ?? this.deleteCallRegStatus,
        callRegister: callRegister ?? this.callRegister,
        getMyCallsStatus: getMyCallsStatus ?? this.getMyCallsStatus,
        sessionId: sessionId ?? this.sessionId,
        isVideoCall: isVideoCall ?? this.isVideoCall,
        rejectVideoCallStatus:
            rejectVideoCallStatus ?? this.rejectVideoCallStatus,
        agoraToken: agoraToken ?? this.agoraToken,
        channelName: channelName ?? this.channelName,
        stopRingToneReason: stopRingToneReason ?? this.stopRingToneReason,
        channelMembers: channelMembers ?? this.channelMembers,
        openRemoteVideoAndAudioStatus:
            openRemoteVideoAndAudioStatus ?? this.openRemoteVideoAndAudioStatus,
        openLocalVideoAndAudioStatus:
            openVideoAndAudioStatus ?? this.openLocalVideoAndAudioStatus,
        makeCallStatus: makeCallStatus ?? this.makeCallStatus);
  }
}

// class CallsInitial extends CallsState {}
