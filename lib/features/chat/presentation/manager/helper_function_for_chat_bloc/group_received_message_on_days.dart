import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'dart:math' as math;
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../data/models/my_chats_response_model.dart';

final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

Map<String, List<Message>> groupReceivedMessageOnDays(
    {required List<Chat> chats}) {
  //todo map for store all chats after we group every messages chat depending on it's day sent
  Map<String, Map<String, List<Message>>> newSortedChatsByDate = {};
  chats.forEach((chat) {
    chat.messages?.removeWhere((element) =>
        element.localId == null && int.tryParse(element.id.toString()) == null);
    //todo here bring all the days that have messages send on it and put the date as key in the messages in this day as value
    Map<String, List<Message>> newMessagesByDate = {};
    for (int i = chat.messages!.length - 1; i >= 0; i--) {
      final zonedDate = HelperFunctions.replaceArabicNumber(
          DateFormat("yyyy-MM-dd").format(
              HelperFunctions.getZonedDate(chat.messages![i].createdAt!)));

      //todo if this date dose not appear in the chat messages yet add it and the message that appear in this date
      if (!newMessagesByDate.containsKey(zonedDate)) {
        newMessagesByDate[zonedDate] = [];
        newMessagesByDate[zonedDate]!
            .add(chat.messages![i].copyWith(isFirstMessageForThisDay: true));
      } else
        newMessagesByDate[zonedDate]!.add(chat.messages![i]);
      if(chat.messages![i].authMessageStatus?.isDeleted == 1 &&
          chat.messages![i].authMessageStatus?.deleteForAll != true){
        if(newMessagesByDate[zonedDate]!.isNotEmpty) {
          newMessagesByDate[zonedDate]!.removeLast();
        }
      }
    }

    //todo for in the dates that appear in the chat to just determine the first message appear in the dat
    for (String sendDate in newMessagesByDate.keys) {
      if(newMessagesByDate[sendDate]!.isEmpty) continue;
      newMessagesByDate[sendDate]![0] =
          newMessagesByDate[sendDate]![0].copyWith(isFirstMessage: true);
      for (int i = 1; i < newMessagesByDate[sendDate]!.length; i++) {
        if (newMessagesByDate[sendDate]![i - 1].senderUserId !=
            newMessagesByDate[sendDate]![i].senderUserId) {
          newMessagesByDate[sendDate]![i] =
              newMessagesByDate[sendDate]![i].copyWith(isFirstMessage: true);
        }
      }
    }
    newSortedChatsByDate['${chat.id}'] = newMessagesByDate;
  });

  Map<String, List<Message>> result = {};
  newSortedChatsByDate.forEach((channelId, value) {
    result[channelId] = [];
    value.keys.forEach((date) {
      if(!value[date].isNullOrEmpty) {
        result[channelId]!.add(Message(isDateMessage: true, dateValue: date));
        result[channelId]!.addAll(value[date]!);
      }
    });
  });
  result.removeWhere((key, value) => value.isNullOrEmpty);
  return result;
}
