part of 'calls_bloc.dart';

enum CreateVideoCallStatus { init, loading, success, failure, cancel ,endCall,startCall}

enum OpenLocalVideoAndAudioStatus { init, loading, success, failure }

enum OpenRemoteVideoAndAudioStatus { init, loading, success, failure }

enum RejectVideoCallStatus { init, loading, success, failure }

@immutable
class CallsState {
  final int? sessionId;
  final RejectVideoCallStatus rejectVideoCallStatus;
  final String? agoraToken;
  final String? channelName;
  final List<int> channelMembers;
  final OpenRemoteVideoAndAudioStatus openRemoteVideoAndAudioStatus;
  final CreateVideoCallStatus createVideoCallStatus;
  final OpenLocalVideoAndAudioStatus openLocalVideoAndAudioStatus;

  CallsState(
      {this.sessionId=23,
      this.rejectVideoCallStatus = RejectVideoCallStatus.init,
      this.agoraToken = null,
      this.channelName = null,
      this.channelMembers = const [],
      this.openRemoteVideoAndAudioStatus = OpenRemoteVideoAndAudioStatus.init,
      this.openLocalVideoAndAudioStatus = OpenLocalVideoAndAudioStatus.init,
      this.createVideoCallStatus = CreateVideoCallStatus.init});

  CallsState copyWith(
      {int? sessionId,
      RejectVideoCallStatus? rejectVideoCallStatus,
      String? agoraToken,
      String? channelName,
      List<int>? channelMembers,
      OpenLocalVideoAndAudioStatus? openVideoAndAudioStatus,
      OpenRemoteVideoAndAudioStatus? openRemoteVideoAndAudioStatus,
      CreateVideoCallStatus? createVideoCallStatus}) {
    return CallsState(
        sessionId: sessionId ?? this.sessionId,
        rejectVideoCallStatus:
            rejectVideoCallStatus ?? this.rejectVideoCallStatus,
        agoraToken: agoraToken ?? this.agoraToken,
        channelName: channelName ?? this.channelName,
        channelMembers: channelMembers ?? this.channelMembers,
        openRemoteVideoAndAudioStatus:
            openRemoteVideoAndAudioStatus ?? this.openRemoteVideoAndAudioStatus,
        openLocalVideoAndAudioStatus:
            openVideoAndAudioStatus ?? this.openLocalVideoAndAudioStatus,
        createVideoCallStatus:
            createVideoCallStatus ?? this.createVideoCallStatus);
  }
}

// class CallsInitial extends CallsState {}
