// import 'dart:async';
//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:get_it/get_it.dart';
// import 'package:injectable/injectable.dart';
// import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
// import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
// import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
//
// import '../../../../service/language_service.dart';
// import '../../data/models/my_chats_response_model.dart';
//
// class FirebasePresence {
//   static StreamSubscription? typingSubscription;
//   static final AppBloc appBloc = GetIt.I<AppBloc>();
//   static final int myChatId = GetIt.I<PrefsRepository>().myChatId!;
//   static bool isSubscribed = false;
//   static final ChatBloc chatBloc = GetIt.I<ChatBloc>();
//   static final Map<String, String> descTranslation = {
//     "Typing...": "يكتب...",
//     "Recording...": "يسجل مقطع صوتي...",
//     "Sending file...": "يرسل ملف...",
//   };
//   static final FirebaseDatabase database = FirebaseDatabase.instance;
//
//   static Future<void> listeningToUserTransaction() async {
//     Map<dynamic, dynamic> data;
//     String description;
//     final typingRef = database.ref().child('Transaction');
//     typingRef.onValue.listen((event) {
//       if (event.snapshot.exists) {
//         debugPrint('data  ${event.snapshot.value}');
//         data = (event.snapshot.value as Map<dynamic, dynamic>);
//         data.forEach((key, value) {
//           if (value['myId'] != myChatId.toString()) {
//             description = value['description'];
//             if (description == 'null') {
//               appBloc
//                   .add(RemoveUserFromTypingList(int.parse(value['channelId'])));
//               return;
//             }
//             if (LanguageService.languageCode == 'ar') {
//               description =
//                   descTranslation[value['description']] ?? value['description'];
//             }
//             appBloc.add(AddUserToTypingList(int.parse(value['friendId']),
//                 int.parse(value['channelId']), description));
//           }
//         });
//       }
//     });
//   }
//
//   static Future<void> sendUserTransaction(
//       {required String channelId, String? description}) async {
//     String friendId = [...chatBloc.state.chats, ...chatBloc.state.pinnedChats]
//         .firstWhere((element) => element.id == channelId)
//         .channelMembers!
//         .firstWhere((element) => element.user!.id != myChatId)
//         .user!
//         .id
//         .toString();
//     DatabaseReference con;
//     await database.goOnline();
//     final typingRef = onUserTransactionRef(friendId: friendId);
//     Map<dynamic, dynamic> data =
//         ((await typingRef.get()).value as Map<dynamic, dynamic>?) ?? {};
//     bool containRecord = false;
//     String? pathToChange;
//     data.forEach((key, value) {
//       if (value['friendId'] == friendId &&
//           value['myId'] == myChatId.toString()) {
//         containRecord = true;
//         pathToChange = key;
//       }
//     });
//     if (!containRecord) {
//       con = typingRef.push();
//       typingRef.update({
//         con.key!: {
//           'friendId': friendId.toString(),
//           'description': description.toString(),
//           'channelId': channelId.toString(),
//           'myId': myChatId.toString(),
//         }
//       });
//     } else {
//       con = typingRef.child(pathToChange!);
//       debugPrint('pathToChange $pathToChange');
//       con.update({
//         'description': description.toString(),
//       });
//     }
//   }
//
//   static DatabaseReference onUserTransactionRef({required String friendId}) {
//     return database.ref().child('Transaction');
//   }
//
//   static typingConnectionListener({required String friendId}) async {
//     final typingRef = onUserTransactionRef(friendId: friendId);
//     await database.goOnline();
//     typingSubscription =
//         database.ref().child('.info/connected').onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         typingRef.onDisconnect().remove();
//       }
//     });
//   }
//
//   static void disconnect() {
//     if (!isSubscribed) return;
//     if (typingSubscription != null) {
//       typingSubscription?.cancel();
//     }
//     database.goOffline();
//     isSubscribed = false;
//   }
// }

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';

import '../../../../service/language_service.dart';
import '../../data/models/my_chats_response_model.dart';

class FirebasePresence {
  static StreamSubscription? typingSubscription;
  static final AppBloc appBloc = GetIt.I<AppBloc>();
  static final int myChatId = GetIt.I<PrefsRepository>().myChatId!;
  static bool isSubscribed = false;
  static final ChatBloc chatBloc = GetIt.I<ChatBloc>();
  static final Map<String, String> descTranslation = {
    "Typing...": "يكتب...",
    "Recording...": "يسجل مقطع صوتي...",
    "Sending file...": "يرسل ملف...",
  };
  static final FirebaseDatabase database = FirebaseDatabase.instance;
  static final FirebaseDatabase databases = FirebaseDatabase.instance;

  static Future<void> listeningToTyping({
    required int friendId,
    required int chatId,
  }) async {
    String description;
    final typingRef = database
        .ref()
        .child('Transaction')
        .child(friendId.toString())
        .child(myChatId.toString());
    typingRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        if (event.snapshot.value is String) {
          description = event.snapshot.value.toString();
        } else {
          description = (event.snapshot.value as Map<dynamic, dynamic>)
              .values
              .first
              .toString();
        }
        debugPrint('description  $description');
        if (LanguageService.languageCode == 'ar') {
          description = descTranslation[description] ?? description;
        }
        appBloc.add(AddUserToTypingList(friendId, chatId, description));
      } else {
        appBloc.add(RemoveUserFromTypingList(chatId));
      }
    });
  }

  static Future<void> listeningToConnectStatus({
    required String chatId,
    required int friendId,
  }) async {
    String description;
    final typingRef =
        databases.ref().child('ConnectStatus').child(friendId.toString());

    typingRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        description = event.snapshot.value.toString();
        chatBloc.add(AddUserConntctSatuseEvent(
            userConnectedStatuse: description, chatId: chatId));
      } else {
        chatBloc.add(AddUserConntctSatuseEvent(
            userConnectedStatuse: " ", chatId: chatId));
      }
    });
  }

  static Future<void> sendUserStatus(String? description) async {
    DatabaseReference con =
        database.ref().child('ConnectStatus').child(myChatId.toString());
    await database.goOnline();
    con.push();
    con.set(description);
  }

  static Future<void> sendUserTransaction(
      {required String channelId, String? description}) async {
    print([...chatBloc.state.chats, ...chatBloc.state.pinnedChats]
        .firstWhere((element) => element.id == channelId || element.localId == channelId).channelMembers.toString());
    [...chatBloc.state.chats, ...chatBloc.state.pinnedChats]
        .firstWhere((element) => element.id == channelId || element.localId == channelId).channelMembers?.forEach((element) {
          print(element.user.toString());
    });
    String friendId = [...chatBloc.state.chats, ...chatBloc.state.pinnedChats]
        .firstWhere((element) => element.id == channelId || element.localId == channelId)
        .channelMembers!
        .firstWhere((element) => element.user!.id != myChatId)
        .user!
        .id
        .toString();
    DatabaseReference con;
    await database.goOnline();
    final typingRef = onUserTransactionRef(friendId: friendId);
    con = typingRef.push();
    con.set(description);
  }

  static DatabaseReference onUserTransactionRef({required String friendId}) {
    return database
        .ref()
        .child('Transaction')
        .child(myChatId.toString())
        .child(friendId.toString());
  }

  static void deleteUserTransaction({required String channelId}) {
    String friendId = [...chatBloc.state.chats, ...chatBloc.state.pinnedChats]
        .firstWhere((element) => element.id == channelId || element.localId == channelId)
        .channelMembers!
        .firstWhere((element) => element.userId != myChatId)
        .userId
        .toString();
    final typingRef = onUserTransactionRef(friendId: friendId);
    typingRef.remove();
  }

  static typingConnectionListener({required String friendId}) async {
    final typingRef = onUserTransactionRef(friendId: friendId);
    await database.goOnline();
    typingSubscription =
        database.ref().child('.info/connected').onValue.listen((event) {
      if (event.snapshot.value != null) {
        typingRef.onDisconnect().remove();
      }
    });
  }

  static void disconnect() {
    if (!isSubscribed) return;
    if (typingSubscription != null) {
      typingSubscription?.cancel();
    }
    database.goOffline();
    isSubscribed = false;
  }

  static listenToAllChats(List<Chat> chats) {
    if (isSubscribed) return;
    for (int i = 0; i < chats.length; i++) {
      if (int.tryParse(chats[i].id.toString()) == null) continue;
      ChannelMember you = chats[i]
          .channelMembers!
          .firstWhere((element) => element.userId != myChatId);
      int friendId = you.userId!;
      listeningToTyping(chatId: int.parse(chats[i].id!), friendId: friendId);
    }
    isSubscribed = chats.length > 0;
  }
}
