
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_widgets/app_bottom_navigation_bar.dart';
import '../../../app/app_widgets/tabs_bar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../widgets/product_listing/product_item.dart';

class ProductListingPage extends StatefulWidget {
  const ProductListingPage({super.key});

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {

  late AppBloc appBloc;
  double? _previousOffset;
  double? _velocity;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    scrollController.addListener(() {
      if (scrollController.position.pixels <= 80) {
        print(scrollController.position.pixels);
        appBloc.add(ShowOrHideBars(true));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BlocBuilder<AppBloc, AppState>(
            buildWhen: (p, c) => p.showBars != c.showBars,
            builder: (context, state) {
              if (state.showBars == true) {
                return const AppBottomNavBar();
              } else {
                return const SizedBox.shrink();
              }
            }),
        body:
            NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis == Axis.horizontal) return false;
                final currentOffset = notification.metrics.pixels;
                if (_previousOffset != null) {
                  final distance = (currentOffset - _previousOffset!).abs();
                  final time =
                      notification.dragDetails?.sourceTimeStamp?.inMilliseconds ??
                          0.000001;
                  _velocity = distance / time;
                  if (scrollController.position.pixels <= 80) {
                    _previousOffset = currentOffset;
                    return true;
                  }
                  if (_velocity! <= (1.5e-8) && _velocity! >= (1.42e-8)) {
                    appBloc.add(ShowOrHideBars(true));
                  } else {
                    appBloc.add(ShowOrHideBars(false));
                  }
                }
                print(_velocity);
                _previousOffset = currentOffset;
                return true;
              },
              child: Stack(
                alignment: Alignment.topCenter,
                children: [ GridView.count(
                crossAxisCount: 2,
                controller: scrollController,
                padding: const EdgeInsets.only(top: 50),
                childAspectRatio: 0.54,
                crossAxisSpacing: 10,
                mainAxisSpacing: 15,
                children: List.generate(30, (index) => const ProductItem()),
              ),
                  BlocBuilder<AppBloc, AppState>(
                      buildWhen: (p, c) => p.showBars != c.showBars,
                      builder: (context, state) {
                        if (state.showBars == true) {
                          return const TabsBar();
                        } else {
                          return const SizedBox.shrink();
                        }
                      })
                ],
            ),

        ),
      ),
    );
  }
}
