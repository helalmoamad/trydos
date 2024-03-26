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

enum WatchedMissedCallStatus { init, loading, success, failure }

enum OpenRemoteVideoAndAudioStatus { init, loading, success, failure }

enum RejectVideoCallStatus { init, loading, success, failure }

enum GetMissedCallCountStatus { init, loading, success, failure }

enum StopRingToneReason { init, refuse, accept }

enum DeleteMessageStatus { init, loading, success, failure }

enum GetMyCallsStatus { init, loading, success, failure }

@immutable
class CallsState {
  final String? messageId;
  final List<CallReg>? callRegister;
  final int? sessionId;
  final WatchedMissedCallStatus watchedMissedCallStatus;
  final DeleteMessageStatus deleteMessageStatus;
  final GetMyCallsStatus getMyCallsStatus;
  final RejectVideoCallStatus rejectVideoCallStatus;
  final GetMissedCallCountStatus getMissedCallCountStatus;
  final String? agoraToken;
  final String? channelIdForCurrentCall;
  final List<int> channelMembers;
  final OpenRemoteVideoAndAudioStatus openRemoteVideoAndAudioStatus;
  final MakeCallStatus makeCallStatus;
  final OpenLocalVideoAndAudioStatus openLocalVideoAndAudioStatus;
  final StopRingToneReason stopRingToneReason;
  final bool isVideoCall;
  final int missedCallCount;
  final String? currentActiveCallId;
  final String? receiverCallName;
  CallsState(
      {this.messageId,
      this.sessionId = 23,
      this.watchedMissedCallStatus = WatchedMissedCallStatus.init,
      this.missedCallCount = 0,
      this.rejectVideoCallStatus = RejectVideoCallStatus.init,
      this.getMissedCallCountStatus = GetMissedCallCountStatus.init,
      this.agoraToken = null,
      this.channelIdForCurrentCall = null,
      this.callRegister,
      this.receiverCallName,
      this.getMyCallsStatus = GetMyCallsStatus.init,
      this.deleteMessageStatus = DeleteMessageStatus.init,
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
      List<CallReg>? callRegister,
      GetMyCallsStatus? getMyCallsStatus,
      RejectVideoCallStatus? rejectVideoCallStatus,
      final String? currentActiveCallId,
      StopRingToneReason? stopRingToneReason,
      String? agoraToken,
      WatchedMissedCallStatus? watchedMissedCallStatus,
      GetMissedCallCountStatus? getMissedCallCountStatus,
      String? receiverCallName,
      String? channelIdForCurrentCall,
      List<int>? channelMembers,
      DeleteMessageStatus? deleteMessageStatus,
      int? missedCallCount,
      bool? isVideoCall,
      OpenLocalVideoAndAudioStatus? openVideoAndAudioStatus,
      OpenRemoteVideoAndAudioStatus? openRemoteVideoAndAudioStatus,
      MakeCallStatus? makeCallStatus}) {
    return CallsState(
        watchedMissedCallStatus:
            watchedMissedCallStatus ?? this.watchedMissedCallStatus,
        getMissedCallCountStatus:
            getMissedCallCountStatus ?? this.getMissedCallCountStatus,
        messageId: messageId ?? this.messageId,
        missedCallCount: missedCallCount ?? this.missedCallCount,
        receiverCallName: receiverCallName ?? this.receiverCallName,
        deleteMessageStatus: deleteMessageStatus ?? this.deleteMessageStatus,
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
