import 'package:flutter/material.dart';



import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trydos/features/chat/presentation/widgets/calls_card.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';

import '../../../home/presentation/widgets/sliver_list_seprated.dart';

class CallsPageContent extends StatefulWidget {
  const CallsPageContent({Key? key}) : super(key: key);

  @override
  State<CallsPageContent> createState() => _CallsPageContentState();
}

class _CallsPageContentState extends State<CallsPageContent> {
  @override
  Widget build(BuildContext context) {
    return  sliverListSeparated(
      itemBuilder: (_, index) =>
          CallsCard(
            isMissing: index <= 1,
            isIncome: index==2,
            index: index,
          ),
      separator: const SizedBox.shrink(),
      childCount: 4,
    );
  }
}

