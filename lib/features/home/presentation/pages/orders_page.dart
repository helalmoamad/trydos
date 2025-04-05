import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../data/models/get_orders_model.dart';
import '../manager/home_bloc.dart';
import '../manager/home_event.dart';
import '../manager/home_state.dart';
import '../widgets/order_widget.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late HomeBloc homeBloc;

  final ScrollController ordersScrollController = ScrollController();

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetOrdersEvent());

    ordersScrollController.addListener(() async {
      if (ordersScrollController.position.maxScrollExtent ==
          ordersScrollController.offset) {
        debugPrint('scrollController');
        homeBloc.add(GetOrdersEvent());
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.getOrdersModel?.paginationStatus !=
            c.getOrdersModel?.paginationStatus,
        builder: (context, state) {
          int itemsCount = state.getOrdersModel == null
              ? 0
              : state.getOrdersModel!.items.length;
          List<OrderListModel> items = state.getOrdersModel?.items ?? [];
          return (state.getOrdersModel == null ||
                  state.getOrdersModel?.paginationStatus ==
                      PaginationStatus.failure ||
                  ((state.getOrdersModel?.paginationStatus ==
                              PaginationStatus.loading ||
                          state.getOrdersModel?.paginationStatus ==
                              PaginationStatus.initial) &&
                      state.getOrdersModel?.items.length == 0))
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.separated(
                    controller: ordersScrollController,
                    itemCount: itemsCount + 1,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index < itemsCount) {
                        return OrderWidget(
                          orders: items,
                          index: index,
                          onTapViewDetails: () {},
                        );
                      } else {
                        if (itemsCount > 4) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: state.getOrdersModel!.hasReachedMax
                                  ? Text('No More Items')
                                  : const CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        color: const Color.fromARGB(255, 241, 241, 241),
                        height: 5,
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
