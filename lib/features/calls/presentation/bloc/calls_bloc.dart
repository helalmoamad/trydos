import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/domain/useCase/get_agora_token_use_case.dart';

import '../../../../common/constant/configuration/global.dart';
import '../../../chat/data/models/my_chats_response_model.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../domain/useCase/answer_call_usecase.dart';
import '../../domain/useCase/reject_call_usecase.dart';
import '../../domain/useCase/video_call_usecase.dart';

part 'calls_event.dart';

part 'calls_state.dart';

@LazySingleton()
class CallsBloc extends Bloc<CallsEvent, CallsState> {
  PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final VideoCallUseCase videoCallUseCase;
  final AnswerCallUseCase answerCallUseCase;
  final RejectCallUseCase rejectCallUseCase;
  final GetAgoraTokenUseCase getAgoraTokenUseCase;

  CallsBloc(this.rejectCallUseCase, this.videoCallUseCase,
      this.answerCallUseCase, this.getAgoraTokenUseCase)
      : super(CallsState()) {
    on<InitResponseRejectVideoCallEvent>((event, emit) async {
      debugPrint("asdasbcvf");
      emit(state.copyWith(createVideoCallStatus: CreateVideoCallStatus.init));
    });
    on<RejectVideoCallEvent>((event, emit) async {
      debugPrint("RejectVideoCallEvent");
      final response = await rejectCallUseCase.call(event.chatId);
      response.fold((l) => null, (r) {
        emit(state.copyWith(
            rejectVideoCallStatus: RejectVideoCallStatus.success));
      });
    });
    on<CallsEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<AnswerVideoCallEvent>((event, emit) async {
      emit(state.copyWith(
        createVideoCallStatus: CreateVideoCallStatus.loading,
      ));

      final tempResponse = await answerCallUseCase(event.chatId);
      tempResponse.fold((l) => null, (r) {
        debugPrint("cbvfbfta");
        debugPrint(r.toString());
      });

      final response = await getAgoraTokenUseCase(event.chatId);

      await response.fold((l) => null, (r) async {
        String agoraToken = r.data!;
        emit(state.copyWith(
            createVideoCallStatus: CreateVideoCallStatus.success,
            agoraToken: agoraToken,
            channelName: event.chatId));
      });
    });
    on<EndVideoCallEvent>((event, emit) async {
      emit(
          state.copyWith(createVideoCallStatus: CreateVideoCallStatus.endCall));
    });
    on<VideoCallEvent>((event, emit) async {
      List<Message> messages;
      bool fromPinned = false;

      emit(state.copyWith(createVideoCallStatus: CreateVideoCallStatus.init));

      // ChatState chatState = GetIt.I<ChatBloc>().state;
      //todo check if the channel exist and get the messages of this channel
      // if (chatState.chats.any( (e) => e.id == event.chatId,)) {
      //   messages = List.of(chatState.chats
      //       .firstWhere((element) => element.id == event.chatId)
      //       .messages ??
      //       []);
      // }
      //todo the same but from the pinned channels

      // else {
      //   fromPinned = true;
      //   messages = List.of(chatState.pinnedChats
      //       .firstWhere((element) => element.id == event.chatId)
      //       .messages ??
      //       []);
      // }
//TODO FOR LATER ADD THE VIDEO MESSAGE TO THE NEW CHAT
      // messages.insert(
      //     0,
      //     Message(
      //         channelId: event.chatId,
      //         // id: event.messageId,
      //         // localId: event.messageId,
      //         createdAt: DateTime.now(),
      //         receiverUserId: int.tryParse(event.receiverUserId),
      //         messageContent: null,
      //         senderUserId: _prefsRepository.myChatId,
      //         messageType: MessageType(name:''),
      //         isForward: 0,
      //         parentMessage: null));

      if (event.receiverUserId != null) {
        final response = await videoCallUseCase(VideoCallParams(
            payload: event.payload, receiverUserId: event.receiverUserId!));
        response.fold((l) => null, (r) {
          emit(state.copyWith(
              createVideoCallStatus: CreateVideoCallStatus.startCall,
              channelName: r.data!.message!.channelId.toString(),
              agoraToken: r.data!.token));
        });
      } else {
        final response = await videoCallUseCase(VideoCallParams(
            payload: event.payload, receiverUserId: event.receiverUserId!));
        response.fold((l) => null, (r) {
          emit(state.copyWith(
            agoraToken: r.data!.token,
            channelName: event.chatId,
          ));
        });
      }
    });

    on<ResponseRejectVideoCallEvent>((event, emit) {
      debugPrint("createVideoCallStatusdasd");
      emit(state.copyWith(createVideoCallStatus: CreateVideoCallStatus.cancel));
    });
  }
}
