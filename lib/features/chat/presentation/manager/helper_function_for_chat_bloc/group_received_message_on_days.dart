import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import '../../../../../common/helper/file_saving.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../data/models/my_chats_response_model.dart';
final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
groupReceivedMessageOnDays({required List<Chat> chats}) {
  //todo map for store all chats after we group every messages chat depending on it's day sent
  Map<String, Map<String, List<Message>>> newSortedChatsByDate = {};
  chats.forEach((chat){
    //todo here bring all the days that have messages send on it and put the date as key in the messages in this day as value
    Map<String, List<Message>> newMessagesByDate = {};
    for (int i = 0; i < chat.messages!.length; i++) {
      String? filePath = chat.messages![i].mediaMessageContent?[0].filePath;
      if (filePath!=null &&  _prefsRepository.isAFilePathExist(filePath)) {
        File? file= File(FileSaving().getFilePath(filePath.split('/').last));
        chat.messages![i] = chat.messages![i].copyWith(file: file , checkedExistence: true);
      }
      final zonedDate = HelperFunctions.replaceArabicNumber(
          DateFormat("yyyy-MM-dd").format(
              HelperFunctions.getZonedDate(chat.messages![i].createdAt!)));
      if (!newMessagesByDate.containsKey(zonedDate)) {
        newMessagesByDate[zonedDate] = [];
        newMessagesByDate[zonedDate]!
            .add(chat.messages![i].copyWith(isFirstMessageForThisDay: true));
      } else
        newMessagesByDate[zonedDate]!.add(chat.messages![i]);
    }
    for (String sendDate in newMessagesByDate.keys) {
      for (int i = 0; i < newMessagesByDate[sendDate]!.length; i++) {
        if (newMessagesByDate[sendDate]![
                    math.min(i + 1, newMessagesByDate[sendDate]!.length - 1)]
                .senderUserId !=
            newMessagesByDate[sendDate]![i].senderUserId) {
          newMessagesByDate[sendDate]![i].copyWith(isFirstMessage: true);
        }
      }
    }
    print('thereeeeveev2 : $newMessagesByDate');
    print('thereeeeveev2 : ${chat.id}');
    newSortedChatsByDate['${chat.id}'] = newMessagesByDate;
  });

  print('thereeeeveev : $newSortedChatsByDate');
  return newSortedChatsByDate;
}
