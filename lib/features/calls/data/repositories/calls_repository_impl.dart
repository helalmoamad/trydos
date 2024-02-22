import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/api.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/calls/data/data_source/calls_remote_data_source.dart';
import 'package:trydos/features/calls/data/models/make_call_response_model.dart';
import 'package:trydos/features/calls/data/models/my_calls.dart';

import '../../domain/repositories/calls_repository.dart';
import '../models/agora_token_remote_response_model.dart';

@LazySingleton(as: CallsRepository)
class CallsRepositoryImpl extends CallsRepository
    with HandlingExceptionRequest {
  CallsRemoteDataSource dataSource;

  CallsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, MakeCallRemoteResponseModel>> makeCall(
      {required Map<String, dynamic> params}) {
    return handlingExceptionRequest(tryCall: () => dataSource.makeCall(params));
  }

  @override
  Future<Either<Failure, GetAgoraTokenResponseModel>> getAgoraToken(
      {required String ChatId}) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getAgoraToken(ChatId));
  }

  @override
  Future<Either<Failure, bool>> answerCall(String messageId) {
    // TODO: implement answerCall
    return handlingExceptionRequest(
        tryCall: () => dataSource.makeAnswerCall(messageId));
  }

  @override
  Future<Either<Failure, bool>> rejectCall(Map<String , dynamic> params) {
    // TODO: implement answerCall
    return handlingExceptionRequest(
        tryCall: () => dataSource.makeRejectCall(params));
  }

  @override
  Future<Either<Failure, MyCallsResponseModel>> getmycalls() {
    return handlingExceptionRequest(tryCall: () => dataSource.getMyCalls());
  }
   @override
  Future<Either<Failure, bool>> deleteCallRegister(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.deleteCallRegister(params));
  }
}
