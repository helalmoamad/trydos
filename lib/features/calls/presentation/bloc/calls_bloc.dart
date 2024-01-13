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
    on<CallsEvent>((event, emit) {});
    on<InitResponseRejectVideoCallEvent>(_onInitResponseRejectVideoCallEvent);
    on<RejectVideoCallEvent>(_onRejectVideoCallEvent);
    on<AnswerVideoCallEvent>(_onAnswerVideoCallEvent);
    on<EndVideoCallEvent>(_onEndVideoCallEvent);
    on<VideoCallEvent>(_onVideoCallEvent);
    on<UserInteractWithCall>(_onUserInteractWithCall);
    on<ResponseRejectVideoCallEvent>(_onResponseRejectVideoCallEvent);
  }

  FutureOr<void> _onResponseRejectVideoCallEvent(ResponseRejectVideoCallEvent event, Emitter<CallsState> emit) {
    debugPrint("createVideoCallStatusdasd");
    emit(state.copyWith(createVideoCallStatus: CreateVideoCallStatus.cancel));
  }

  FutureOr<void> _onVideoCallEvent(VideoCallEvent event, Emitter<CallsState> emit) async {
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

      debugPrint("the channel not exist");
    } else {
      debugPrint("the channel exist");

      final response = await videoCallUseCase(
          VideoCallParams(payload: event.payload, chatId: event.chatId!));
      response.fold((l) => null, (r) {
        emit(state.copyWith(
          messageId: r.data!.message!.id!.toString(),
          createVideoCallStatus: CreateVideoCallStatus.startCall,
          agoraToken: r.data!.token,
          channelName: event.chatId,
        ));
      });
    }
  }

  FutureOr<void> _onEndVideoCallEvent(EndVideoCallEvent event, Emitter<CallsState> emit) async {
    emit(
        state.copyWith(createVideoCallStatus: CreateVideoCallStatus.endCall));
  }

  FutureOr<void> _onAnswerVideoCallEvent(AnswerVideoCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(
      createVideoCallStatus: CreateVideoCallStatus.loading,
    ));

    final tempResponse = await answerCallUseCase(event.messageId);
    tempResponse.fold((l) => null, (r) {
      debugPrint("cbvfbfta");
      debugPrint(r.toString());
    });

    final response = await getAgoraTokenUseCase(event.messageId);

    await response.fold((l) => null, (r) async {
      String agoraToken = r.data!;
      emit(state.copyWith(
          createVideoCallStatus: CreateVideoCallStatus.success,
          agoraToken: agoraToken,
          channelName: event.chatId));
    });
  }

  FutureOr<void> _onRejectVideoCallEvent(RejectVideoCallEvent event,Emitter<CallsState> emit) async {
    debugPrint("RejectVideoCallEvent");
    final response = await rejectCallUseCase.call(event.messageId);
    response.fold((l) => null, (r) {
      emit(state.copyWith(
          rejectVideoCallStatus: RejectVideoCallStatus.success));
    });
  }

  FutureOr<void> _onInitResponseRejectVideoCallEvent(InitResponseRejectVideoCallEvent event, Emitter<CallsState> emit) async {
    debugPrint("asdasbcvf");
    emit(state.copyWith(createVideoCallStatus: CreateVideoCallStatus.init));
  }

  FutureOr<void> _onUserInteractWithCall(UserInteractWithCall event, Emitter<CallsState> emit) {
    emit(state.copyWith(
      stopRingToneReason: event.rejectIt ? StopRingToneReason.refuse : StopRingToneReason.accept
    ));
  }
}
