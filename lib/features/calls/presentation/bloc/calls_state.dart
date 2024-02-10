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

@immutable
class CallsState {
  final String? messageId;
  final int? sessionId;
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

  CallsState(
      {this.messageId,
      this.sessionId = 23,
      this.rejectVideoCallStatus = RejectVideoCallStatus.init,
      this.agoraToken = null,
      this.channelIdForCurrentCall = null,
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
      RejectVideoCallStatus? rejectVideoCallStatus,
        final String? currentActiveCallId,
      StopRingToneReason? stopRingToneReason,
      String? agoraToken,
      String? channelIdForCurrentCall,
      List<int>? channelMembers,
      bool? isVideoCall,
      OpenLocalVideoAndAudioStatus? openVideoAndAudioStatus,
      OpenRemoteVideoAndAudioStatus? openRemoteVideoAndAudioStatus,
      MakeCallStatus? makeCallStatus}) {
    return CallsState(
        messageId: messageId,
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
