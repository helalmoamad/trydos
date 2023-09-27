import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;
import '../../../../../common/helper/helper_functions.dart';
import '../../../data/models/my_chats_response_model.dart';

groupReceivedMessageOnDays({required List<Chat> chats}) {
  //todo map for store all chats after we group every messages chat depending on it's day sent
  Map<String, Map<String,List<Message>>> newSortedChatsByDate = {};
  chats.map((chat) {
    //todo here bring all the days that have messages send on it and put the date as key in the messages in this day as value
    Map<String, List<Message>> newMessagesByDate = {};
    for (int i = 0; i < chat.messages!.length; i++) {
      final zonedDate = HelperFunctions.replaceArabicNumber(
          DateFormat("yyyy-MM-dd").format(HelperFunctions.getZonedDate(chat.messages![i].createdAt!)));
      if (!newMessagesByDate.containsKey(zonedDate)) {
        newMessagesByDate[zonedDate] = [];
        newMessagesByDate[zonedDate]!.add(chat.messages![i].copyWith(is_first_message_for_today: true));
      }
      else  newMessagesByDate[zonedDate]!.add(chat.messages![i]);
    }
    for (String sendDate in newMessagesByDate.keys) {
      for (int i = 0; i < newMessagesByDate[sendDate]!.length; i++) {
        if( newMessagesByDate[sendDate]![math.min(i + 1, newMessagesByDate[sendDate]!.length - 1)].senderUserId != newMessagesByDate[sendDate]![i].senderUserId)
        {
          newMessagesByDate[sendDate]![i].copyWith(is_first_message: true);
        }
      }


    }
    newSortedChatsByDate['${chat.id}'] = newMessagesByDate;
  }) ;



return newSortedChatsByDate;
}
