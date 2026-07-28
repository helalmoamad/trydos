import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import '../features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';
import '../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart';
import '../features/home/presentation/manager/orderBloc/order_bloc.dart';
import '../features/story/presentation/bloc/story_bloc.dart';

class ServiceProvider extends StatelessWidget {
  final Widget child;
  const ServiceProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // هذه البلوكات مُسجّلة كـ lazySingleton في GetIt (دورة حياتها يديرها الـ DI
        // طوال عمر التطبيق). نستخدم BlocProvider.value حتى لا يمتلكها المزوّد ولا
        // يستدعي close() عليها عند dispose — وإلا يُغلَق الـ singleton وتفشل أي
        // إضافة حدث لاحقة بـ: "Cannot add new events after calling close".
        BlocProvider.value(value: GetIt.I<CallsBloc>()),
        BlocProvider.value(value: GetIt.I<DashboardBloc>()),
        BlocProvider.value(value: GetIt.I<StoryBloc>()),
        BlocProvider.value(value: GetIt.I<AppBloc>()),
        // يُنشأ ويُملَك من المزوّد (ليس singleton في DI) — يبقى create: ليُغلق مع dispose.
        BlocProvider(
          create: (BuildContext context) => SensitiveConnectivityBloc(),
        ),
        BlocProvider.value(value: GetIt.I<AuthBloc>()),
        BlocProvider.value(value: GetIt.I<ChatBloc>()),
        BlocProvider.value(value: GetIt.I<CategoryBloc>()),
        BlocProvider.value(value: GetIt.I<HomeBloc>()),
        BlocProvider.value(value: GetIt.I<BoutiqueBloc>()),
        BlocProvider.value(value: GetIt.I<PreCachingImageBloc>()),
        BlocProvider.value(value: GetIt.I<OrderBloc>()),
      ],
      child: child,
    );
  }
}
