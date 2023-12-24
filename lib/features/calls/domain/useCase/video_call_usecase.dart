import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';

import '../../data/models/video_call_ersponse_model.dart';

@injectable
class VideoCallUseCase extends UseCase<VideoCallRemoteResponseModel, VideoCallParams> {
  final CallsRepository repository;

  VideoCallUseCase(this.repository);

  @override
  Future<Either<Failure, VideoCallRemoteResponseModel>> call(VideoCallParams  params) {
    return repository.videoCall(params:params.map );
  }




  // VideoCallEvent








}

class VideoCallParams{
  final String? chatId;
  final String? receiverUserId;
  final Map<String,dynamic> payload;
  const VideoCallParams( {
    this.chatId,
    this.receiverUserId,
    required this.payload,});

  Map<String, dynamic> get map =>{
    "payload":payload,
    "channel_id":chatId,
    "receiver_user_id":receiverUserId,
  };
}