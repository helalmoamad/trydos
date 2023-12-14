import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/client_config.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/api/methods/post.dart';

import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../models/agora_token_remote_response_model.dart';
import '../models/video_call_ersponse_model.dart';

@injectable
class CallsRemoteDataSource {
  Future<VideoCallRemoteResponseModel> makeCallVideo(String ChatId) {
    PostClient<VideoCallRemoteResponseModel> videoCall =
        PostClient<VideoCallRemoteResponseModel>(
            requestPrams: RequestConfig<VideoCallRemoteResponseModel>(
                // data: params,
                endpoint: ChatEndPoints.videoCall(ChatId),
                response: ResponseValue<VideoCallRemoteResponseModel>(
                  fromJson: (response) {
                    debugPrint("asdascc${response}");
                    return VideoCallRemoteResponseModel.fromJson(response);
                  },
                )),
            serverName: ServerName.chat);
    return videoCall();
  }

  Future<GetAgoraTokenResponseModel> getAgoraToken(String ChatId) {
    PostClient<GetAgoraTokenResponseModel> videoCall =
        PostClient<GetAgoraTokenResponseModel>(
            requestPrams: RequestConfig<GetAgoraTokenResponseModel>(
                // data: params,
                endpoint: ChatEndPoints.getAgoraToken(ChatId),
                response: ResponseValue<GetAgoraTokenResponseModel>(
                  fromJson: (response) {
                    return GetAgoraTokenResponseModel.fromJson(response);
                  },
                )),
            serverName: ServerName.chat);
    return videoCall();
  }

  Future<bool> makeAnswerCall(String ChatId) {
    PostClient<bool> AnswerCall = PostClient<bool>(
        requestPrams: RequestConfig<bool>(
            // data: params,
            endpoint: ChatEndPoints.answer_call(ChatId),
            response: ResponseValue<bool>(returnValueOnSuccess: true)),
        serverName: ServerName.chat);
    return AnswerCall();
  }

  Future<bool> makeRejectCall(String ChatId) {
    PostClient<bool> RejectCall = PostClient<bool>(
        requestPrams: RequestConfig<bool>(
            endpoint: ChatEndPoints.refuseCall(ChatId),
            response: ResponseValue<bool>(returnValueOnSuccess: true)),
        serverName: ServerName.chat);
    return RejectCall();
  }
}
