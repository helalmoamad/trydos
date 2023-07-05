import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/app_bottom_navigation_bar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/presentation/pages/chat_pages.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';

class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final List<Widget> pages = [
    const HomePage(),
    const HomePage(),
    const ChatPages(),
    const HomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      bottomNavigationBar: BlocBuilder<AppBloc, AppState>(
          buildWhen: (p, c) => p.showBars != c.showBars,
          builder: (context, state) {
            if (state.showBars == true) {
              return const AppBottomNavBar();
            } else {
              return const SizedBox.shrink();
            }
          }),
      body: BlocBuilder<AppBloc, AppState>(
        buildWhen: (oldState, newState) =>
            oldState.currentIndex != newState.currentIndex,
        builder: (_, state) {
          return pages[state.currentIndex];
        },
      ),
    );
  }
}
