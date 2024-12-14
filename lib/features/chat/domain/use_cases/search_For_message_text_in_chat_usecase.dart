import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/data/models/result_of_search_text_in_chat_model.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class SearchForMessageTextInChatUseCase extends UseCase<
    ResultOfSearchTextInChatModel, SearchForMessageTextInChatParams> {
  final ChatRepository repository;

  SearchForMessageTextInChatUseCase(this.repository);

  @override
  Future<Either<Failure, ResultOfSearchTextInChatModel>> call(
      SearchForMessageTextInChatParams params) {
    return repository.searchForMessageTextInChat(params.map);
  }
}

class SearchForMessageTextInChatParams {
  String channeltId;
  String searchText;
  String offset;

  SearchForMessageTextInChatParams(
      {required this.searchText,
      required this.channeltId,
      required this.offset});
  Map<String, dynamic> get map => {
        "channel_id": channeltId,
        "query": searchText,
        "limit": 10,
        "offset": offset
      };
}
