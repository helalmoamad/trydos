import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ShareProductWithContactsOrChannelsUsecase
    extends UseCase<Message, ShareProductWithContactsOrChannelsParams> {
  final ChatRepository repository;

  ShareProductWithContactsOrChannelsUsecase(this.repository);

  @override
  Future<Either<Failure, Message>> call(
      ShareProductWithContactsOrChannelsParams params) {
    return repository.shareProductWithContactsOrChannels(params.map);
  }
}

class ShareProductWithContactsOrChannelsParams {
  final String productId;
  final String productName;
  final String productSlug;
  final String productDescription;
  final String productImageUrl;
  final List<String> channelIds;
  final List<int?> receiverIds;
  final String? productImageWidth;
  final String? productImageHeight;

  ShareProductWithContactsOrChannelsParams({
    required this.productId,
    required this.productName,
    required this.productSlug,
    required this.productDescription,
    required this.productImageUrl,
    required this.channelIds,
    required this.receiverIds,
    this.productImageWidth,
    this.productImageHeight,
  });

  Map<String, dynamic> get map => {
        'content': [{
          'product_id': productId,
          'product_slug': productSlug,
          'product_description': productDescription,
          'product_image_url': productImageUrl,
          'product_image_width': productImageWidth,
          'product_image_height': productImageHeight,
          'product_name': productName
        }],
        'channel_ids': channelIds,
        'receiver_ids': receiverIds,
      };
}
