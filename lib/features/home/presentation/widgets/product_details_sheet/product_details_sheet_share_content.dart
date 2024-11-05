import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/presentation/widgets/share_products_with_social_media/build_social_buttons.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../app/app_widgets/app_text_field.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../../calls/presentation/widgets/no_image_widget.dart';
import '../../../../chat/data/models/my_chats_response_model.dart';
import '../../../../chat/presentation/manager/chat_bloc.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as product;

class ProductDetailsSheetShareContent extends cupertino.StatefulWidget {
  const ProductDetailsSheetShareContent(
      {super.key,
      required this.idsOfChatCardsToShare,
      required this.focusNode,
      required this.productItem,
      required this.productDescription,
      this.scrollController});

  final FocusNode focusNode;
  final product.Products productItem;
  final String productDescription;
  final ValueNotifier<List<String>> idsOfChatCardsToShare;
  final ScrollController? scrollController;

  @override
  cupertino.State<ProductDetailsSheetShareContent> createState() =>
      _ProductDetailsSheetShareContentState();
}

class _ProductDetailsSheetShareContentState
    extends cupertino.State<ProductDetailsSheetShareContent> {
  final ValueNotifier<List<Chat>> chats = ValueNotifier([]);
  List<Chat> originalCopyOfChats = [];

  @override
  Widget build(BuildContext context) {
    print(
        "*******************************///////////////////////////////111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111/");
    print(widget.productDescription);
    return ScrollConfiguration(
      behavior: cupertino.CupertinoScrollBehavior(),
      child: ListView(
        controller: widget.scrollController,
        shrinkWrap: true,
        physics: cupertino.ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          10.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.shareSvg,
                color: Color(0xff505050),
                height: 20,
              ),
              SizedBox(
                width: 10,
              ),
              MyTextWidget('Share This Product With',
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: Color(0xff505050),
                  )),
            ],
          ),
          if (GetIt.I<PrefsRepository>().chatToken == null) ...{
            SizedBox(
              height: 50,
            ),
            cupertino.Container(
              height: 280.h,
              child: cupertino.Column(
                mainAxisAlignment: cupertino.MainAxisAlignment.center,
                children: [
                  MyTextWidget('You Must Login To Share Product With Chats!',
                      style: context.textTheme.bodyMedium?.bq.copyWith(
                        color: Color(0xffff0000),
                      )),
                  cupertino.Spacer(),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
          } else ...{
            10.verticalSpace,
            Material(
              color: Colors.transparent,
              child: Padding(
                padding: HWEdgeInsets.symmetric(horizontal: 20.0)
                    .copyWith(bottom: 10),
                child: AppTextField(
                  focusNode: widget.focusNode,
                  filledColor: Color(0xffF8F8F8),
                  bordersColor: Color(0xffF8F8F8),
                  hintText: 'Search',
                  roundingCornersValue: 30,
                  onChange: (String text) {
                    if (text.isEmpty) {
                      chats.value = originalCopyOfChats;
                    } else {
                      List<Chat> search = [];
                      for (Chat chat in originalCopyOfChats) {
                        ChannelMember member = chat.channelMembers!.firstWhere(
                            (element) =>
                                element.userId !=
                                GetIt.I<PrefsRepository>().myChatId);
                        if ((chat.channelName ?? LocaleKeys.unknown_user.tr())
                                .toLowerCase()
                                .contains(text.toLowerCase() ?? '') ||
                            (member.user?.mobilePhone ?? LocaleKeys.no_num.tr())
                                .toLowerCase()
                                .contains(text.toLowerCase() ?? '')) {
                          search.add(chat);
                        }
                      }
                      chats.value = search;
                    }
                  },
                  textStyle: context.textTheme.titleMedium?.lr
                      .copyWith(color: const Color(0xff8D8D8D)),
                  hintTextStyle: context.textTheme.bodySmall?.lr
                      .copyWith(color: const Color(0xff8D8D8D)),
                  prefixIcon: Padding(
                    padding: HWEdgeInsetsDirectional.only(top: 15, bottom: 15),
                    child: SvgPicture.asset(
                      AppAssets.searchOutlinedSvg,
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<List<String>>(
                valueListenable: widget.idsOfChatCardsToShare,
                builder: (context, channelIds, _) {
                  return BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      chats.value = [...state.pinnedChats, ...state.chats];
                      chats.value.sort(
                        (a, b) {
                          if ((a.messages?.isEmpty ?? true) &&
                              (b.messages?.isEmpty ?? true)) {
                            return 0;
                          }
                          if (a.messages?.isEmpty ?? true) {
                            return 1; // a < b
                          }
                          if (b.messages?.isEmpty ?? true) {
                            return -1;
                          }
                          return b.messages!.first.createdAt!
                              .compareTo(a.messages!.first.createdAt!);
                        },
                      );
                      originalCopyOfChats = chats.value;
                      return ValueListenableBuilder<List<Chat>>(
                          valueListenable: chats,
                          builder: (context, chats, _) {
                            final List<Chat> displayedChats = chats
                                .getRange(0, min(10, chats.length))
                                .toList();
                            return Align(
                              alignment: Alignment.center,
                              child: Wrap(
                                children: List.generate(
                                    min(10, chats.length),
                                    (index) => ChatCardForShare(
                                          index: index,
                                          channelMember: displayedChats[index]
                                              .channelMembers!
                                              .firstWhere((member) =>
                                                  member.userId !=
                                                  GetIt.I<PrefsRepository>()
                                                      .myChatId),
                                          onTap: () {
                                            if (!widget
                                                .idsOfChatCardsToShare.value
                                                .contains(displayedChats[index]
                                                    .id
                                                    .toString())) {
                                              widget.idsOfChatCardsToShare.value
                                                  .add(displayedChats[index]
                                                      .id
                                                      .toString());
                                              //////////////////////////////
                                              FirebaseAnalyticsService
                                                  .logEventForSession(
                                                eventName: AnalyticsEventsConst
                                                    .buttonClicked,
                                                executedEventName:
                                                    AnalyticsExecutedEventNameConst
                                                        .shareWithChatButton,
                                              );
                                            } else {
                                              widget.idsOfChatCardsToShare.value
                                                  .remove(displayedChats[index]
                                                      .id
                                                      .toString());
                                            }
                                            widget.idsOfChatCardsToShare
                                                .notifyListeners();
                                          },
                                          selected: channelIds.contains(
                                              displayedChats[index]
                                                  .id
                                                  .toString()),
                                        )),
                              ),
                            );
                          });
                    },
                  );
                }),
          },
          buildSocialButtons(
              text: "${widget.productDescription}",
              productSlugForULr: widget.productItem.slug ?? "",
              productId: widget.productItem.id.toString()),
        ],
      ),
    );
  }
}

class ChatCardForShare extends StatelessWidget {
  const ChatCardForShare(
      {super.key,
      required this.index,
      required this.selected,
      this.onTap,
      required this.channelMember});

  final int index;
  final bool selected;
  final ChannelMember channelMember;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final String receiverName, fullReceiverName;
    if (channelMember.user?.name == null) {
      receiverName = LocaleKeys.uk.tr();
      fullReceiverName = channelMember.user?.mobilePhone ?? 'UnKnown User';
    } else {
      receiverName = HelperFunctions.getTheFirstTwoLettersOfName(
          channelMember.user!.name!);
      fullReceiverName = channelMember.user!.name!;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: onTap,
        child: Padding(
          padding: HWEdgeInsets.only(
              right: (index != 4 && index != 9) ? 10 : 0,
              top: index > 4 ? 20 : 0),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: selected
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0x29000000),
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                        border: selected
                            ? Border.all(
                                color: Color(0xff0859D9),
                              )
                            : null),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: selected ? 0.5 : 1,
                            child: Container(
                                width: 70.w - (selected ? 2 : 0),
                                height: 80 - (selected ? 2 : 0),
                                decoration: BoxDecoration(),
                                child: channelMember.user?.photoPath == null
                                    ? NoImageWidget(
                                        width: 70.w - (selected ? 2 : 0),
                                        height: 80 - (selected ? 2 : 0),
                                        textStyle: context
                                            .textTheme.bodyMedium?.br
                                            .copyWith(
                                                color: const Color(0xff6638FF),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                        name: receiverName)
                                    : MyCachedNetworkImage(
                                        imageUrl: ChatUrls.baseUrl +
                                            channelMember.user?.photoPath,
                                        imageFit: BoxFit.cover,
                                        width: 70.w - (selected ? 2 : 0),
                                        height: 80 - (selected ? 2 : 0),
                                        imageWidth: 70.w - (selected ? 2 : 0),
                                        imageHeight: 80 - (selected ? 2 : 0),
                                      )),
                          ),
                          Container(
                            width: 70.w - (selected ? 2 : 0),
                            height: 80 - (selected ? 2 : 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                  color: Colors.white.withOpacity(0.5),
                                  inset: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  cupertino.SizedBox(
                    width: 70.w - (selected ? 2 : 0),
                    child: MyTextWidget(
                      fullReceiverName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.rq
                          .copyWith(color: Color(0xff505050)),
                    ),
                  )
                ],
              ),
              selected
                  ? Positioned(
                      right: 0,
                      child: SvgPicture.asset(
                        AppAssets.shareSvg,
                        height: 20,
                        color: Color(0xff0859D9),
                      ))
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
