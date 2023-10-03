import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import '../../../../../common/helper/file_saving.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../data/models/my_chats_response_model.dart';

groupReceivedMessageOnDays({required List<Chat> chats}) {
  //todo map for store all chats after we group every messages chat depending on it's day sent
  Map<String, Map<String, List<Message>>> newSortedChatsByDate = {};
  chats.forEach((chat) async{
    //todo here bring all the days that have messages send on it and put the date as key in the messages in this day as value
    Map<String, List<Message>> newMessagesByDate = {};
    for (int i = 0; i < chat.messages!.length; i++) {
      if (chat.messages![i].mediaMessageContent?[0].filePath!=null && !chat.messages![i].checkedExistence) {
//        File? file = await checkFileExistence(
//            chat.messages![i].mediaMessageContent![0].filePath,
//            chat.messages![i].mediaMessageContent![0].fileName ?? chat.messages![i].mediaMessageContent![0].filePath!.split('/').last);
        File? file=await checkFileExistence(      chat.messages![i].mediaMessageContent![0].fileName ?? chat.messages![i].mediaMessageContent![0].filePath!.split('/').last);

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
//
//checkFileExistence(String? filePath, String? fileName) async {
//  File? file =
//      await FileSaving().checkExistence(filePath, fileName!, download: false);
//  return file;
//}
checkFileExistence(String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';

  var file = File(filePath);
  return file;
}