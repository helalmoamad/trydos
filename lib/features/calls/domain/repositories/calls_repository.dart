import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/agora_token_remote_response_model.dart';
import '../../data/models/video_call_ersponse_model.dart';

abstract
class CallsRepository {


  Future<Either<Failure, bool>> rejectCall(String ChatId);
  Future<Either<Failure,VideoCallRemoteResponseModel>> videoCall({required String ChatId});
  Future<Either<Failure,bool>> answerCall(String ChatId);
  Future<Either<Failure, GetAgoraTokenResponseModel>> getAgoraToken({required String ChatId}) ;
}