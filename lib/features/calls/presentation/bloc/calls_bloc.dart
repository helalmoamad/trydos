import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/calls/domain/useCase/delete_Call_reg.dart';
import 'package:trydos/features/calls/domain/useCase/get_my_calls.dart';
import 'package:trydos/main.dart';
import '../../data/models/my_calls.dart' as calls;
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/domain/useCase/get_agora_token_use_case.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';

import '../../../../common/constant/configuration/global.dart';
import '../../../chat/data/models/my_chats_response_model.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../domain/useCase/answer_call_usecase.dart';
import '../../domain/useCase/reject_call_usecase.dart';
import '../../domain/useCase/make_call_usecase.dart';

part 'calls_event.dart';

part 'calls_state.dart';

@LazySingleton()
class CallsBloc extends Bloc<CallsEvent, CallsState> {
  PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final MakeCallUseCase makeCallUseCase;
  final AnswerCallUseCase answerCallUseCase;
  final RejectCallUseCase rejectCallUseCase;

  final GetAgoraTokenUseCase getAgoraTokenUseCase;
  final DeleteCallRegUseCase deleteCallRegUseCase;
  final GetMyCallsUseCase getMyCallsUseCase;

  CallsBloc(
      this.rejectCallUseCase,
      this.makeCallUseCase,
      this.getMyCallsUseCase,
      this.answerCallUseCase,
      this.getAgoraTokenUseCase,
      this.deleteCallRegUseCase)
      : super(CallsState()) {
    on<CallsEvent>((event, emit) {});
    on<InitResponseRejectVideoCallEvent>(_onInitResponseRejectVideoCallEvent);
    on<RejectVideoCallEvent>(_onRejectVideoCallEvent);
    on<AnswerVideoCallEvent>(_onAnswerVideoCallEvent);
    on<EndVideoCallEvent>(_onEndVideoCallEvent);
    on<MakeCallEvent>(_onMakeCallEvent);
    on<DeleteCallRegEvent>(_onDeleteCallRegEvent);
    on<GetMyCallsEvent>(_onGetMyCalls,
        transformer: throttleDroppable(throttleDuration));
    on<UserInteractWithCall>(_onUserInteractWithCall);
    on<ResponseRejectVideoCallEvent>(_onResponseRejectVideoCallEvent);
  }

  FutureOr<void> _onResponseRejectVideoCallEvent(
      ResponseRejectVideoCallEvent event, Emitter<CallsState> emit) {
    debugPrint("createVideoCallStatusdasd");
    emit(state.copyWith(makeCallStatus: MakeCallStatus.cancel));
  }

  FutureOr<void> _onGetMyCalls(
      GetMyCallsEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(getMyCallsStatus: GetMyCallsStatus.loading));
    final response = await getMyCallsUseCase(NoParams());
    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetMyCall')) {
          add(GetMyCallsEvent());
          isFailedTheFirstTime.add('GetMyCall');
        }

        emit(state.copyWith(getMyCallsStatus: GetMyCallsStatus.failure));
      },
      (r) {
        apisMustNotToRequest.add('GetMyCalls');

        isFailedTheFirstTime.remove('GetMyCalls');

        emit(state.copyWith(
            getMyCallsStatus: GetMyCallsStatus.success, callRegister: r.data));
      },
    );
  }

  FutureOr<void> _onMakeCallEvent(
      MakeCallEvent event, Emitter<CallsState> emit) async {
    List<Message> messages;
    bool fromPinned = false;

    emit(state.copyWith(
        makeCallStatus: MakeCallStatus.init, isVideoCall: event.isVideo));

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
      final response = await makeCallUseCase(MakeCallParams(
          isVideo: event.isVideo,
          payload: event.payload,
          receiverUserId: event.receiverUserId!));
      response.fold((l) => null, (r) {
        emit(state.copyWith(
            makeCallStatus: MakeCallStatus.startCall,
            isVideoCall: event.isVideo,
            messageId: r.data!.message!.id!.toString(),
            channelName: r.data!.message!.channelId.toString(),
            agoraToken: r.data!.token));
      });

      debugPrint("the channel not exist");
    } else {
      debugPrint("the channel exist");

      final response = await makeCallUseCase(MakeCallParams(
          payload: event.payload,
          chatId: event.chatId!,
          isVideo: event.isVideo));
      response.fold((l) => null, (r) {
        GetIt.I<ChatBloc>().add(ReceiveMessageEvent(
            message: r.data!.message!, increaseUnReadMessages: false));
        emit(state.copyWith(
          messageId: r.data!.message!.id!.toString(),
          isVideoCall: event.isVideo,
          makeCallStatus: MakeCallStatus.startCall,
          agoraToken: r.data!.token,
          channelName: event.chatId,
        ));

        emit(state.copyWith(callRegister: state.callRegister));
      });
    }
  }

  FutureOr<void> _onEndVideoCallEvent(
      EndVideoCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(makeCallStatus: MakeCallStatus.endCall));
    add(GetMyCallsEvent());
  }

  FutureOr<void> _onAnswerVideoCallEvent(
      AnswerVideoCallEvent event, Emitter<CallsState> emit) async {
    emit(state.copyWith(
      makeCallStatus: MakeCallStatus.loading,
    ));

    final tempResponse = await answerCallUseCase(event.messageId);
    tempResponse.fold((l) => null, (r) {
      debugPrint("cbvfbfta");
      debugPrint(r.toString());
    });

    final response = await getAgoraTokenUseCase(event.chatId);

    await response.fold((l) => null, (r) async {
      String agoraToken = r.data!;
      emit(state.copyWith(
          makeCallStatus: MakeCallStatus.success,
          agoraToken: agoraToken,
          channelName: event.chatId));
    });
  }

  FutureOr<void> _onRejectVideoCallEvent(
      RejectVideoCallEvent event, Emitter<CallsState> emit) async {
    debugPrint("RejectVideoCallEvent");
    final response = await rejectCallUseCase.call(event.messageId);
    response.fold((l) => null, (r) {
      emit(
          state.copyWith(rejectVideoCallStatus: RejectVideoCallStatus.success));
    });
  }

  FutureOr<void> _onInitResponseRejectVideoCallEvent(
      InitResponseRejectVideoCallEvent event, Emitter<CallsState> emit) async {
    debugPrint("asdasbcvf");
    emit(state.copyWith(makeCallStatus: MakeCallStatus.init));
  }

  FutureOr<void> _onUserInteractWithCall(
      UserInteractWithCall event, Emitter<CallsState> emit) {
    emit(state.copyWith(
        stopRingToneReason: event.rejectIt
            ? StopRingToneReason.refuse
            : StopRingToneReason.accept));
  }

  FutureOr<void> _onDeleteCallRegEvent(
      DeleteCallRegEvent event, Emitter<CallsState> emit) async {
    /*bool fromPinned = false;
    List<Chat> chats;
    if (state.chats.any((element) => element.id == event.channelId)) {
      chats = List.of(state.chats);
    } else {
      fromPinned = true;
      chats = List.of(state.pinnedChats);
    }
    String uuid = const Uuid().v4();
    int index = chats.indexWhere((element) => element.id == event.channelId);
    chats[index] = chats[index].copyWith(id: uuid, localId: uuid, messages: []);
    emit(state.copyWith(
        chats: fromPinned ? state.chats : chats,
        deleteChatStatus: DeleteChatStatus.loading,
        newSortedChatsByDate: groupReceivedMessageOnDays(chats: [
          ...chats,
          ...(fromPinned ? state.chats : state.pinnedChats)
        ]),
        pinnedChats: !fromPinned ? state.pinnedChats : chats));*/
    final response = await deleteCallRegUseCase(
        DeleteCallRegParams.DeleteCallRegParams(callId: event.callId));
    response.fold((l) {
      showMessage("لا يوجد اتصال بالانترنيت ");
    }, (r) {
      state.callRegister!.removeWhere(
        (element) => element.id == event.callId,
      );
      add(GetMyCallsEvent());
      emit((state.copyWith(
        callRegister: state.callRegister,
        deleteCallRegStatus: DeleteCallRegStatus.success,
      )));
    });
  }
}
