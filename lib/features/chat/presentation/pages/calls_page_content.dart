import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/features/calls/data/models/my_calls.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../calls/presentation/widgets/calls_card.dart';
import '../../../home/presentation/widgets/sliver_list_seprated.dart';
import '../../../calls/data/models/my_calls.dart' as calls;

class CallsPageContent extends StatefulWidget {
  const CallsPageContent({Key? key}) : super(key: key);

  @override
  State<CallsPageContent> createState() => _CallsPageContentState();
}

class _CallsPageContentState extends State<CallsPageContent> {
  late CallsBloc callsBloc;
  void initState() {
    callsBloc = BlocProvider.of<CallsBloc>(context);

    callsBloc.add(GetMyCallsEvent());
    /* calls.Data data = calls.Data();
    data.copyWith(
      messageStatus: List.empty(),
      createdAt: DateTime.now(),
      receiverUserId: 12222,
      channelId: "1111",
    );*/

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return BlocBuilder<CallsBloc, CallsState>(
      buildWhen: (previous, current) {
        return previous.callRegister != current.callRegister &&
            current.getMyCallsStatus == GetMyCallsStatus.success;
      },
      builder: (context, state) {
        if (state.callRegister == null) {
          return sliverListSeparated(
            itemBuilder: (_, index) =>
                Center(child: CircularProgressIndicator()),
            separator: const SizedBox.shrink(),
            childCount: 1,
          );
        }
        return sliverListSeparated(
          itemBuilder: (_, index) => CallsCard(
            isMissing: state.callRegister![index].durationInSeconds == null,
            createAt: state.callRegister![index].createdAt,
            isIncome: state.callRegister![index].senderUserId !=
                GetIt.I<PrefsRepository>().myChatId,
            index: index,
            fullname:
                state.callRegister![index].channel!.channelName.toString(),
            photopath: state.callRegister![index].channel!.photoPath ?? "",
            chatId: state.callRegister![index].channelId.toString(),
            duration: state.callRegister![index].durationInSeconds == null
                ? 0
                : state.callRegister![index].durationInSeconds!,
            messageType: "",
            callRegId: state.callRegister![index].id!,
            isvoice:
                state.callRegister![index].messageType!.name == "VoiceCall",
          ),
          separator: const SizedBox.shrink(),
          childCount: state.callRegister!.length,
        );
      },
    );
  }
}
