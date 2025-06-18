import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart' as local;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart'
    show PanelController, SlidingUpPanel;
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart'
    show ChangeOrderByGroupStatus, GetOrdersEvent;
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../data/models/get_orders_model.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_state.dart';
import 'order_details2_page.dart';
import 'package:trydos/config/theme/typography.dart';

class OrderDetails1 extends StatefulWidget {
  OrderDetails1(
      {super.key,
      this.fromNotification = false,
      this.orderIdFormNotification,
      required this.order});

  final OrderListModel order;
  bool fromNotification;
  String? orderIdFormNotification;
  @override
  State<OrderDetails1> createState() => _OrderDetails1State();
}

class _OrderDetails1State extends State<OrderDetails1> {
  List<String?> addressParts = [];
  List<String> orderIdToChat = [];
  late ChatBloc chatBloc;
  late OrderBloc orderBloc;
  int tapIndex = 0;

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    orderBloc = BlocProvider.of<OrderBloc>(context);

    if ((widget.order.details?.length ?? 0) > 0) {
      if (widget.order.orderStatus?.value == "out_for_delivery") {
        orderIdToChat.add(widget.order.id.toString());
      }
      widget.order.details?.forEach(
        (element) {
          if (element.orderProductStatus?.value == "out_for_delivery" &&
              (!(orderIdToChat.contains(element.orderId.toString())))) {
            orderIdToChat.add(element.orderId.toString());
          }
        },
      );
    }
    if (widget.fromNotification &&
        widget.orderIdFormNotification != null &&
        widget.orderIdFormNotification != "") {
      GetIt.I<ChatBloc>().add(GetOrderRecipientIdEvent(
          originalUserId: GetIt.I<PrefsRepository>().myMarketId.toString(),
          orderId: widget.orderIdFormNotification!));

      tapIndex = orderIdToChat.indexOf(widget.orderIdFormNotification!);
      widget.orderIdFormNotification = null;
      if (tapIndex == -1) {
        tapIndex = 0;
      }
    }
    addressParts = [
      widget.order.shippingAddressData?.country,
      widget.order.shippingAddressData?.province,
      widget.order.shippingAddressData?.city,
      widget.order.shippingAddressData?.town,
      widget.order.shippingAddressData?.street,
      widget.order.shippingAddressData?.building,
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final addressString = addressParts
        .where((part) => part != null && part != 'null' && part.isNotEmpty)
        .join(' | ');

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF8F8F8),
      appBar: TrydosAppBar(
        appBarParams: AppBarParams(
          backgroundColor: const Color(0xffFFFFFF),
          scrolledUnderElevation: 0,
          backIconColor: Colors.black,
          withShadow: false,
          action: [
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                ),
                SvgPicture.asset(
                  AppAssets.bagsSvg,
                  width: 23,
                ),
                ///////////////////////////
                SizedBox(
                  width: 4,
                ),
                ///////////////////////////
                Text(
                  LocaleKeys.order_details.tr(),
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                ///////////////////////////
                SizedBox(
                  width: 15,
                ),
                ///////////////////////////
              ],
            ),
            Spacer(),
            ////////////
            Container(
              width: 40,
              height: 20,
              child: SvgPicture.asset(
                AppAssets.orderMenuSvg,
                width: 20,
                height: 20,
              ),
            ),
            ///////////////////////////
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 11.h,
            ),
            ///////////////////
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  (previous.getCurrencyForCountryModel !=
                      current.getCurrencyForCountryModel),
              builder: (context, state) {
                String currencySymbol =
                    state.getCurrencyForCountryModel!.data!.currency!.symbol ??
                        "";
                String orderAmount = (widget.order.orderAmount! *
                        state.getCurrencyForCountryModel!.data!.currency!
                            .exchangeRate!)
                    .toStringAsFixed(
                        state.startingSetting?.decimalPointSettings ?? 0);
                ;

                return SizedBox(
                  height: 95,
                  child: buildFirstSection(
                    context: context,
                    orderNumber: widget.order.orderGroupId ?? '',
                    orderDate: HelperFunctions.orderFormatDate(
                      DateTime.tryParse(widget.order.createdAt ?? '') ??
                          DateTime.now(),
                    ),
                    orderAmount: orderAmount.toString(),
                    orderCurrency: currencySymbol,
                  ),
                );
              },
            ),
            ///////////////////////

            SizedBox(
              height: 8.h,
            ),
            ///////////////////
            SizedBox(
              height: 85,
              child: buildSecondSection(
                context: context,
                expectedDeliveryDate: 'Monday 2.Jun | 3 Work Days',
                orderStatus: widget.order.orderGroupStatus?.label ?? '',
                deliverdTo:
                    widget.order.shippingAddressData?.contactPersonName ?? '',
              ),
            ),
            ///////////////////
            SizedBox(
              height: 8.h,
            ),
            ///////////////////
            buildThirdSection(
              context: context,
              contactInfo: widget.order.shippingAddressData?.phone ?? '',
              recipientName:
                  widget.order.shippingAddressData?.contactPersonName ?? '',
              shippingDeliveryAddress: addressString,
            ),
            ///////////////////
            SizedBox(
              height: 8.h,
            ),
            ///////////////////
            GestureDetector(
              onTapUp: (details) {
                final double dx = details.localPosition.dx;
                if (dx < ((40 * (orderIdToChat.length)) + 20) &&
                    dx < (1.sw - 100)) {
                  return;
                }

                HelperFunctions.slidingNavigation(
                  context,
                  OrderDetails2(
                    fromNotification: widget.fromNotification,
                    orderIdFormNotification: widget.orderIdFormNotification,
                    orderIdToChat: orderIdToChat,
                    order: widget.order,
                  ),
                );
              },
              child: buildFourthSection(
                  context: context,
                  itemsCount: widget.order.details!.length.toString()),
            ),
            ///////////////////
            SizedBox(
              height: 8.h,
            ),
            ///////////////////
            buildFifthSection(
              details: widget.order.details,
            ),
            ///////////////////
            SizedBox(
              height: 8.h,
            ),
            ///////////////////
          ],
        ),
      ),
    );
  }

  Widget buildFifthSection({
    required List<OrderListDetailModel>? details,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          itemCount: details?.length ?? 0,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            print("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDdd");
            print(details?[index].orderProductStatus?.label);

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: Colors.white,
                    child: MyCachedNetworkImage(
                      imageUrl: details?[index].image ?? '',
                      imageFit: BoxFit.contain,
                      width: 91,
                      height: 125,
                    ),
                  ),
                ),
                ///////////////////
                const SizedBox(
                  height: 3,
                ),
                ///////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      details?[index].orderProductStatus?.label == 'Shipped'
                          ? AppAssets.shippedAndOutOfDeliveryBagSvg
                          : AppAssets.preparingBagSvg,
                      width: 13,
                    ),
                    //////////////////////////
                    SizedBox(
                      width: 2,
                    ),
                    //////////////////////////
                    SvgPicture.asset(
                      details?[index].orderProductStatus?.label == 'Shipped'
                          ? AppAssets.shippedBlackSvg
                          : details?[index].orderProductStatus?.label ==
                                  'Delivered'
                              ? AppAssets.deliveredBlackSvg
                              : details?[index].orderProductStatus?.label ==
                                      'Pending'
                                  ? AppAssets.pendeingBlackCheck
                                  : AppAssets.orderPreparingSvg,
                      width: 13,
                    ),
                  ],
                ),
                ///////////////////
                const SizedBox(
                  height: 2,
                ),
                ///////////////////
                Text(
                  details?[index].variation == null
                      ? ''
                      : details?[index].variation?.size ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
                ///////////////////
                const SizedBox(
                  height: 2,
                ),
                ///////////////////
                Text(
                  details?[index].variation == null
                      ? ''
                      : details?[index].variation?.color ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 5,
            );
          },
        ),
      ),
    );
  }

  Widget buildFourthSection({
    required BuildContext context,
    required String itemsCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 74,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 237, 237, 237),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  AppAssets.bagsSvg,
                  width: 20,
                ),
                ///////////////////
                SizedBox(
                  height: 2,
                ),
                ///////////////////
                Text(
                  LocaleKeys.order_details.tr(),
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
                ///////////////////
                SizedBox(
                  height: 2,
                ),
                ///////////////////
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: itemsCount,
                        style: context.textTheme.bodyMedium?.bq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      TextSpan(text: ' ${LocaleKeys.item.tr()}'),
                    ],
                  ),
                ),
                ///////////////////
              ],
            ),
            Spacer(),
            Container(
              width: 30 *
                  (double.tryParse((orderIdToChat.length).toString()) ?? 0),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) =>
                    BlocListener<ChatBloc, ChatState>(
                        listenWhen: (previous, current) =>
                            previous.getOrderRecipientIdStatus !=
                            current.getOrderRecipientIdStatus,
                        listener: (context, state) {
                          if (state.getOrderRecipientIdStatus ==
                              GetOrderRecipientIdStatus.success) {
                            String receiverName = "DW";
                            String fullReceiverName = "Delivery Worker";
                            String? recipientUserId = state.recipientUserId;
                            if (recipientUserId == null) {
                              return;
                            }
                            Chat? chat;
                            User? receiver;
                            List<Chat> chats =
                                List.of(GetIt.I<ChatBloc>().state.chats);
                            debugPrint(chats.toString());
                            chats.addAll(GetIt.I<ChatBloc>().state.pinnedChats);
                            chat = chats.firstWhere((element) =>
                                element.channelMembers!.any((element) {
                                  return element.userId.toString() ==
                                      recipientUserId;
                                }));
                            final preferences = GetIt.I<PrefsRepository>();
                            receiver = chat.channelMembers
                                ?.firstWhere(
                                  (element) =>
                                      element.userId != preferences.myChatId,
                                  orElse: () => ChannelMember(
                                      userId: int.tryParse(recipientUserId),
                                      user: User(
                                          id: int.tryParse(recipientUserId),
                                          name: receiverName)),
                                )
                                .user;
                            String fromOrder = "true";
                            context.go(GRouter.config.applicationRoutes
                                    .kSinglePageChatPagePath +
                                '?chatId=${chat.id!.toString()}&fromOrder=$fromOrder&receiverName=$receiverName&fullReceiverName=${fullReceiverName}&receiverPhone=${receiver?.mobilePhone ?? 'Uo Number'}&senderName=${HelperFunctions.getTheFirstTwoLettersOfName(GetIt.I<PrefsRepository>().myChatName!)}');
                          }
                          // TODO: implement listener
                        },
                        child: BlocBuilder<ChatBloc, ChatState>(
                          buildWhen: (previous, current) =>
                              previous.getOrderRecipientIdStatus !=
                              current.getOrderRecipientIdStatus,
                          builder: (context, state) {
                            if (state.getOrderRecipientIdStatus ==
                                    GetOrderRecipientIdStatus.loading &&
                                index == tapIndex) {
                              return Container(
                                width: 30,
                                height: 30,
                                child: TrydosLoader(
                                  size: 16,
                                ),
                              );
                            }
                            return Container(
                              alignment: Alignment.center,
                              width: 30,
                              height: 30,
                              child: InkWell(
                                onTap: () {
                                  tapIndex = index;
                                  chatBloc.add(GetOrderRecipientIdEvent(
                                      originalUserId: GetIt.I<PrefsRepository>()
                                          .myMarketId
                                          .toString(),
                                      orderId: orderIdToChat[index]));
                                },
                                child: SvgPicture.asset(
                                  AppAssets.chatMarkActiveSvg,
                                  width: 20,
                                ),
                              ),
                            );
                          },
                        )),
                itemCount: orderIdToChat.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildThirdSection({
    required BuildContext context,
    required String shippingDeliveryAddress,
    required String recipientName,
    required String contactInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffF4F4F4),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.shipping_delivery_address.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              LocaleKeys.my_home.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              shippingDeliveryAddress,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              LocaleKeys.recipient.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              recipientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              LocaleKeys.recipient_contact.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                contactInfo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
            ///////////////////
          ],
        ),
      ),
    );
  }

  Widget buildSecondSection({
    required BuildContext context,
    required String expectedDeliveryDate,
    required String orderStatus,
    String deliverdTo = '',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    AppAssets.orderAddressSvg,
                    width: 20,
                  ),
                  ///////////////////
                  SvgPicture.asset(
                    AppAssets.orderDeliveryDateSvg,
                    width: 20,
                  ),
                ],
              ),
              title: LocaleKeys.expected_delivery_date.tr(),
              value: expectedDeliveryDate,
              titleIcons: SizedBox.shrink(),
              valueIcons: SizedBox.shrink(),
              amount: '',
              isTextSpan: false,
              currency: '',
            ),
          ),
          //////////////////////////
          const SizedBox(
            width: 8,
          ),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  orderStatus == 'Pending'
                      ? SvgPicture.asset(
                          AppAssets.pendingBagSvg,
                          width: 20,
                        )
                      : SvgPicture.asset(
                          AppAssets.pendingBagSvg,
                          width: 15,
                        ),
                  ////////////////////
                  const SizedBox(
                    width: 3,
                  ),
                  ///////////////////
                  orderStatus == 'Pending'
                      ? SvgPicture.asset(
                          AppAssets.whiteBagSvg,
                          width: 15,
                        )
                      : orderStatus == 'Preparing'
                          ? SvgPicture.asset(
                              AppAssets.preparingBagSvg,
                              width: 20,
                            )
                          : SvgPicture.asset(
                              AppAssets.preparingBagSvg,
                              width: 15,
                            ),
                  ////////////////////
                  const SizedBox(
                    width: 3,
                  ),
                  ///////////////////
                  orderStatus == 'Pending'
                      ? SvgPicture.asset(
                          AppAssets.whiteBagSvg,
                          width: 15,
                        )
                      : orderStatus == 'Preparing'
                          ? SvgPicture.asset(
                              AppAssets.whiteBagSvg,
                              width: 15,
                            )
                          : orderStatus == 'Shipped'
                              ? SvgPicture.asset(
                                  AppAssets.shippedAndOutOfDeliveryBagSvg,
                                  width: 20,
                                )
                              : SvgPicture.asset(
                                  AppAssets.shippedAndOutOfDeliveryBagSvg,
                                  width: 15,
                                ),
                  ////////////////////
                  const SizedBox(
                    width: 3,
                  ),
                  ///////////////////
                  orderStatus == 'Pending'
                      ? SvgPicture.asset(
                          AppAssets.whiteBagSvg,
                          width: 15,
                        )
                      : orderStatus == 'Preparing'
                          ? SvgPicture.asset(
                              AppAssets.whiteBagSvg,
                              width: 15,
                            )
                          : orderStatus == 'Shipped'
                              ? SvgPicture.asset(
                                  AppAssets.whiteBagSvg,
                                  width: 15,
                                )
                              : orderStatus == 'Delivered'
                                  ? SvgPicture.asset(
                                      AppAssets.delivered_bagSvg,
                                      width: 20,
                                    )
                                  : SvgPicture.asset(
                                      AppAssets.delivered_bagSvg,
                                      width: 15,
                                    ),
                ],
              ),
              title: LocaleKeys.order_status.tr(),
              value: orderStatus == 'Delivered'
                  ? '$orderStatus ${LocaleKeys.to.tr()} $deliverdTo'
                  : orderStatus,
              amount: '',
              isTextSpan: false,
              titleIcons: buildTitleIcons(status: orderStatus),
              valueIcons: buildValueIcons(status: orderStatus),
              currency: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitleIcons({
    required String status,
  }) {
    if (status == 'Pending')
      return Row(
        children: [
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.pendingBlueCheckSvg,
            width: 15,
          ),
        ],
      );
    else if (status == 'Preparing')
      return Row(
        children: [
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.preparingBlueSvg,
            width: 15,
          ),
        ],
      );
    else
      return SizedBox.shrink();
  }

  Widget buildValueIcons({
    required String status,
  }) {
    if (status == 'Pending')
      return Row(
        children: [
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.pendeingBlackCheck,
            width: 15,
          ),
        ],
      );
    else if (status == 'Preparing')
      return Row(
        children: [
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.preparingBlackSvg,
            width: 15,
          ),
          /////////////////////////////
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.preparingGreySvg,
            width: 15,
          ),
          /////////////////////////////
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.preparingGrey2Svg,
            width: 15,
          ),
        ],
      );
    else if (status == 'Shipped')
      return Row(
        children: [
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.shippedBlackSvg,
            width: 15,
          ),
          /////////////////////////////
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.shippedGreySvg,
            width: 15,
          ),
          /////////////////////////////
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.shippedGrey_2Svg,
            width: 15,
          ),
        ],
      );
    if (status == 'Delivered')
      return Row(
        children: [
          SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.deliveredBlackSvg,
            width: 15,
          ),
        ],
      );
    else
      return SizedBox.shrink();
  }

  Widget buildFirstSection({
    required BuildContext context,
    required String orderNumber,
    required String orderDate,
    required String orderAmount,
    required String orderCurrency,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(
                AppAssets.orderBag1Svg,
                width: 20,
              ),
              title: LocaleKeys.order_number.tr(),
              value: orderNumber,
              amount: '',
              isTextSpan: false,
              titleIcons: SizedBox.shrink(),
              valueIcons: SizedBox.shrink(),
              currency: '',
            ),
          ),
          //////////////////////////
          const SizedBox(
            width: 8,
          ),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(
                AppAssets.orderClockSvg,
                width: 20,
              ),
              title: LocaleKeys.order_date.tr(),
              value: orderDate,
              amount: '',
              isTextSpan: false,
              titleIcons: SizedBox.shrink(),
              valueIcons: SizedBox.shrink(),
              currency: '',
            ),
          ),
          //////////////////////////
          const SizedBox(
            width: 8,
          ),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    AppAssets.orderInvoice2Svg,
                    width: 20,
                  ),
                  SvgPicture.asset(
                    AppAssets.orderWalletSvg,
                    width: 15,
                  ),
                ],
              ),
              title: LocaleKeys.order_invoice.tr(),
              amount: orderAmount,
              isTextSpan: true,
              titleIcons: SizedBox.shrink(),
              valueIcons: SizedBox.shrink(),
              currency: orderCurrency,
              value: '',
            ),
          ),
          //////////////////////////
        ],
      ),
    );
  }

  Widget buildDetailsMainInfoWidget({
    required BuildContext context,
    required Widget firstItem,
    required Widget titleIcons,
    required Widget valueIcons,
    required String title,
    required String value,
    required bool isTextSpan,
    required String amount,
    required String currency,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F4),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          firstItem,
          ///////////////////
          Row(
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ),
              ///////////////
              titleIcons,
            ],
          ),
          ///////////////////
          isTextSpan
              ? Flexible(
                  fit: FlexFit.loose,
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff505050),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: amount,
                          style: context.textTheme.bodyMedium?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        TextSpan(text: ' $currency'),
                      ],
                    ),
                  ),
                )
              : Row(
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.bq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                    valueIcons,
                  ],
                ),
        ],
      ),
    );
  }
}
