import 'package:dartz/dartz.dart';
import 'package:trydos/features/calls/data/models/my_calls.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/agora_token_remote_response_model.dart';
import '../../data/models/make_call_response_model.dart';
import '../../data/models/missed_call_count.dart';

abstract class CallsRepository {
  Future<Either<Failure, bool>> rejectCall(Map<String, dynamic> params);

  Future<Either<Failure, MakeCallRemoteResponseModel>> makeCall(
      {required Map<String, dynamic> params});

  Future<Either<Failure, bool>> answerCall(String messageId);

  Future<Either<Failure, bool>> watchMissedCall();

  Future<Either<Failure, MyCallsResponseModel>> getmycalls();

  Future<Either<Failure, GetAgoraTokenResponseModel>> getAgoraToken(
      {required String ChatId});

  Future<Either<Failure, bool>> deleteMessage(Map<String, dynamic> params);
  Future<Either<Failure, MissedCallCountModel>> getMissedCallCount();
}
