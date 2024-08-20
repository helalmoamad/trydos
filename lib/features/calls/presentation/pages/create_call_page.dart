import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/calls/presentation/pages/room_call_page.dart';
import 'package:trydos/features/calls/presentation/widgets/call_status_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router_config.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../service/language_service.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import '../widgets/no_image_widget.dart';

class CreateCallPage extends StatefulWidget {
  const CreateCallPage(
      {Key? key,
      required this.chatId,
      required this.receiverName,
      required this.fullReceiverName,
      this.receiverPhoto})
      : super(key: key);
  final String chatId;
  final String fullReceiverName;
  final String receiverName;
  final String? receiverPhoto;

  @override
  State<CreateCallPage> createState() => _CreateCallPageState();
}

class _CreateCallPageState extends ThemeState<CreateCallPage> {
  late ChatBloc chatBloc;
  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    if (GetIt.I<CallsBloc>().state.makeCallStatus == MakeCallStatus.endCall)
      Navigator.of(context).pop();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      chatBloc.add(SendErrorChatToServerEvent(
          error: error.toString(), lastPage: "Create_Call_Page"));
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    GetIt.I<CallsBloc>().add(InitResponseRejectVideoCallEvent());

    return Scaffold(
      backgroundColor: colorScheme.black,
      body: SafeArea(
        child: BlocConsumer<CallsBloc, CallsState>(
          listener: (context, state) {
            if (state.makeCallStatus == MakeCallStatus.cancel) {
              Future.delayed(
                Duration(seconds: 1),
                () {
                  Navigator.of(context).pop();
                },
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  children: [
                    Column(
                      children: [
                        140.verticalSpace,
                        Padding(
                          padding: HWEdgeInsets.symmetric(horizontal: 105.w),
                          child: Column(
                            children: [
                              widget.receiverPhoto != null
                                  ? Container(
                                      height: 200,
                                      width: 200.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                            width: 1.0,
                                            color: const Color(0xff388cff)),
                                        boxShadow: [
                                          BoxShadow(
                                              color: colorScheme.white
                                                  .withOpacity(0.35),
                                              offset: const Offset(0, 10),
                                              blurRadius: 30,
                                              spreadRadius: 10),
                                        ],
                                      ),
                                      child: MyCachedNetworkImage(
                                          imageUrl: ChatUrls.baseUrl +
                                              widget.receiverPhoto!,
                                          imageFit: BoxFit.cover,
                                          progressIndicatorBuilderWidget:
                                              TrydosLoader(),
                                          height: 80.h,
                                          width: 60.w),
                                    )
                                  : NoImageWidget(
                                      width: 60.w,
                                      height: 80.h,
                                      textStyle: context.textTheme.bodyMedium?.br
                                          .copyWith(
                                              color: const Color(0xff6638FF),
                                              letterSpacing: 0.18,
                                              height: 1.33),
                                      name: widget.receiverName),
                              15.verticalSpace,
                              MyTextWidget(
                                widget.fullReceiverName,
                                style: textTheme.headlineSmall?.rr
                                    .copyWith(color: const Color(0xffD3D3D3)),
                              ),
                              80.verticalSpace,
                              state.makeCallStatus == MakeCallStatus.cancel
                                  ? CallStatusWidget(
                                      text: LocaleKeys.did_no_answer.tr(),
                                      iconUrl: 'assets/svg/end_call.svg',
                                      textColor: Color(0xFFFF0000))
                                  : CallStatusWidget(
                                      text: LocaleKeys.calling.tr(),
                                      iconUrl: AppAssets.callingSvg,
                                      textColor: colorScheme.grey200,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: HWEdgeInsets.symmetric(horizontal: 41.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            AppAssets.callMutedSvg,
                            width: 25.sp,
                            height: 25.sp,
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.endCallSvg,
                                  width: 25.sp,
                                  height: 25.sp,
                                ),
                                10.verticalSpace,
                                MyTextWidget(
                                  LocaleKeys.end_call.tr(),
                                  style: textTheme.titleLarge?.lr
                                      .copyWith(color: const Color(0xffFF5F61)),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            AppAssets.cancelVideoCallSvg,
                            width: 34.sp,
                            height: 25.sp,
                          ),
                        ],
                      ),
                    ),
                    50.verticalSpace
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.w, 15.h, 0, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Transform(
                      alignment: Alignment.center,
                      transform: (Matrix4.identity()
                        ..scale(
                            LanguageService.languageCode == 'ar' ? -1.0 : 1.0,
                            1.0,
                            1.0)),
                      child: SvgPicture.asset(
                        AppAssets.backFromCallSvg,
                        height: 20,
                        width: 8,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
