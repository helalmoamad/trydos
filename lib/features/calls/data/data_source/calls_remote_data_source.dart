import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/client_config.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/api/methods/post.dart';
import 'package:trydos/features/calls/data/models/my_calls.dart';

import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../models/agora_token_remote_response_model.dart';
import '../models/make_call_response_model.dart';

@injectable
class CallsRemoteDataSource {
  Future<MakeCallRemoteResponseModel> makeCall(Map<String, dynamic> params) {
    if (params['data']['receiver_user_id'] != null) {
      params['data'].remove('channel_id');
    } else {
      params['data'].remove('receiver_user_id');
    }
    bool isVideo = params['isVideo'];
    PostClient<MakeCallRemoteResponseModel> makeCall =
        PostClient<MakeCallRemoteResponseModel>(
            requestPrams: RequestConfig<MakeCallRemoteResponseModel>(
                data: params['data'],
                endpoint: isVideo
                    ? ChatEndPoints.videoCallEP
                    : ChatEndPoints.voiceCallEP,
                response: ResponseValue<MakeCallRemoteResponseModel>(
                  fromJson: (response) {
                    log(response.toString());
                    return MakeCallRemoteResponseModel.fromJson(response);
                  },
                )),
            serverName: ServerName.chat);
    return makeCall();
  }

  Future<bool> makeAnswerCall(String messageId) {
    PostClient<bool> AnswerCall = PostClient<bool>(
        requestPrams: RequestConfig<bool>(
            // data: params,
            endpoint: ChatEndPoints.answer_call(messageId),
            response: ResponseValue<bool>(returnValueOnSuccess: true)),
        serverName: ServerName.chat);
    return AnswerCall();
  }

  Future<bool> makeRingingCall(String ChatId) {
    PostClient<bool> AnswerCall = PostClient<bool>(
        requestPrams: RequestConfig<bool>(
            // data: params,
            endpoint: ChatEndPoints.answer_call(ChatId),
            response: ResponseValue<bool>(returnValueOnSuccess: true)),
        serverName: ServerName.chat);
    return AnswerCall();
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

  Future<bool> rejectCall(Map<String, dynamic> params) {
    PostClient<bool> rejectCall = PostClient<bool>(
        requestPrams: RequestConfig<bool>(
            endpoint: ChatEndPoints.refuseCall(params['messageId']),
            data: params['payload'],
            response: ResponseValue<bool>(returnValueOnSuccess: true)),
        serverName: ServerName.chat);
    return rejectCall();
  }

  Future<MyCallsResponseModel> getMyCalls() {
    PostClient<MyCallsResponseModel> mycalls = PostClient<MyCallsResponseModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<MyCallsResponseModel>(
        endpoint: ChatEndPoints.myCallReg,
        response: ResponseValue<MyCallsResponseModel>(
            fromJson: (response) => MyCallsResponseModel.fromJson(response)),
      ),
    );
    return mycalls();
  }

  Future<bool> deleteCallRegister(Map<String, dynamic> params) {
    PostClient<bool> deleteChat = PostClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.deleteCallREg,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return deleteChat();
  }
}
