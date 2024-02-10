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
  final String? channelIdForCurrentCall;
  final List<int> channelMembers;
  final OpenRemoteVideoAndAudioStatus openRemoteVideoAndAudioStatus;
  final MakeCallStatus makeCallStatus;
  final OpenLocalVideoAndAudioStatus openLocalVideoAndAudioStatus;
  final StopRingToneReason stopRingToneReason;
  final bool isVideoCall;
  final String? currentActiveCallId;
  final String? receiverCallName;
  CallsState(
      {this.messageId,
      this.sessionId = 23,
      this.rejectVideoCallStatus = RejectVideoCallStatus.init,
      this.agoraToken = null,
      this.channelIdForCurrentCall = null,
      this.callRegister,
        this.receiverCallName,
      this.getMyCallsStatus = GetMyCallsStatus.init,
      this.deleteCallRegStatus = DeleteCallRegStatus.init,
      this.isVideoCall = false,
      this.stopRingToneReason = StopRingToneReason.init,
      this.channelMembers = const [],
      this.currentActiveCallId = '-1',
      this.openRemoteVideoAndAudioStatus = OpenRemoteVideoAndAudioStatus.init,
      this.openLocalVideoAndAudioStatus = OpenLocalVideoAndAudioStatus.init,
      this.makeCallStatus = MakeCallStatus.init});

  CallsState copyWith(
      {String? messageId,
      int? sessionId,
      List<calls.Data>? callRegister,
      GetMyCallsStatus? getMyCallsStatus,
      RejectVideoCallStatus? rejectVideoCallStatus,
        final String? currentActiveCallId,
      StopRingToneReason? stopRingToneReason,
      String? agoraToken,
      String? receiverCallName,
      String? channelIdForCurrentCall,
      List<int>? channelMembers,
      DeleteCallRegStatus? deleteCallRegStatus,
      bool? isVideoCall,
      OpenLocalVideoAndAudioStatus? openVideoAndAudioStatus,
      OpenRemoteVideoAndAudioStatus? openRemoteVideoAndAudioStatus,
      MakeCallStatus? makeCallStatus}) {
    return CallsState(
        messageId: messageId ?? this.messageId,
        receiverCallName : receiverCallName ?? this.receiverCallName,
        deleteCallRegStatus: deleteCallRegStatus ?? this.deleteCallRegStatus,
        callRegister: callRegister ?? this.callRegister,
        getMyCallsStatus: getMyCallsStatus ?? this.getMyCallsStatus,
        sessionId: sessionId ?? this.sessionId,
        currentActiveCallId: currentActiveCallId ?? this.currentActiveCallId,
        isVideoCall: isVideoCall ?? this.isVideoCall,
        rejectVideoCallStatus:
            rejectVideoCallStatus ?? this.rejectVideoCallStatus,
        agoraToken: agoraToken ?? this.agoraToken,
        channelIdForCurrentCall:
            channelIdForCurrentCall ?? this.channelIdForCurrentCall,
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
