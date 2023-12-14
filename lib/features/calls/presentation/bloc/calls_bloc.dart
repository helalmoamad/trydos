import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/domain/useCase/get_agora_token_use_case.dart';

import '../../../../common/constant/configuration/global.dart';
import '../../domain/useCase/answer_call_usecase.dart';
import '../../domain/useCase/reject_call_usecase.dart';
import '../../domain/useCase/video_call_usecase.dart';

part 'calls_event.dart';

part 'calls_state.dart';

@LazySingleton()
class CallsBloc extends Bloc<CallsEvent, CallsState> {
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

    on<VideoCallEvent>((event, emit) async {
      final response = await videoCallUseCase(event.chatId);
      await response.fold((l) => null, (r) async {
        String agoraToken = r.data!;
        emit(state.copyWith(
          agoraToken: agoraToken,
          channelName: event.chatId,
        ));
      });
    });

    on<ResponseRejectVideoCallEvent>((event, emit) {
      debugPrint("createVideoCallStatusdasd");
      emit(state.copyWith(createVideoCallStatus: CreateVideoCallStatus.cancel));
    });
  }
}
