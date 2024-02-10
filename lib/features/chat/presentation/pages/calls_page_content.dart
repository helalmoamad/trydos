import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/calls/data/models/my_calls.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../calls/presentation/widgets/calls_card.dart';
import '../../../home/presentation/widgets/sliver_list_seprated.dart';

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
          return SliverToBoxAdapter(child: SizedBox(
            height: 1.sh - 200 ,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TrydosLoader(),
              ],
            ),
          ));
        }
        return sliverListSeparated(
          itemBuilder: (_, index) => CallsCard(
            isMissing: state.callRegister![index].durationInSeconds == null,
            createAt: state.callRegister![index].createdAt,
            isIncome: state.callRegister![index].senderUserId !=
                GetIt.I<PrefsRepository>().myChatId,
            index: index,
            fullReceiverName:
                state.callRegister![index].channel!.channelName.toString(),
            photoPath: state.callRegister![index].channel!.photoPath ?? "",
            chatId: state.callRegister![index].channelId.toString(),
            duration: state.callRegister![index].durationInSeconds == null
                ? 0
                : state.callRegister![index].durationInSeconds!,
            messageType: "",
            callRegId: state.callRegister![index].id!,
            isVoice:
                state.callRegister![index].messageType!.name == "VoiceCall",
          ),
          separator: const SizedBox.shrink(),
          childCount: state.callRegister!.length,
        );
      },
    );
  }
}
