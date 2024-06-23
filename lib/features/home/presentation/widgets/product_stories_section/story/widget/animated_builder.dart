/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import '../../../../manager/home_bloc.dart';

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int collectionIndex;

  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.collectionIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context1, state) {
        return Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: <Widget>[
                    _buildContainer(
                      double.infinity,
                      position <
                              state.currentStoryInEachCollection[
                                  collectionIndex]!
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                    position ==
                            state.currentStoryInEachCollection[collectionIndex]
                        ? AnimatedBuilder(
                            animation: animController,
                            builder: (context, child) {
                              return _buildContainer(
                                constraints.maxWidth * animController.value,
                                Colors.white,
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Container _buildContainer(double width, Color color) {
  return Container(
    height: 5.0,
    width: width,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(
        color: Colors.black26,
        width: 0.8,
      ),
      borderRadius: BorderRadius.circular(3.0),
    ),
  );
}
*/