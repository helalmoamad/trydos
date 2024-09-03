import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/widgets/contact_card.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../service/language_service.dart';
import '../../../app/app_widgets/app_text_field.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/presentation/widgets/sliver_list_seprated.dart';
import '../../data/models/my_contacts_response_model.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_state.dart';

class MyContactsPage extends StatefulWidget {
  const MyContactsPage({Key? key}) : super(key: key);

  @override
  State<MyContactsPage> createState() => _MyContactsPageState();
}

class _MyContactsPageState extends State<MyContactsPage> with FormStateMinxin {
  final ScrollController scrollController = ScrollController();
  late ChatBloc chatBloc;
  ValueNotifier<List<Contact>> searchContacts =
      ValueNotifier(GetIt.I<ChatBloc>().state.contacts);

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(GetContactsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      chatBloc.add(SendErrorChatToServerEvent(
          error: error.toString(), lastPage: "My_Contacts_Page"));
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      print(error);
    };
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: TrydosAppBar(
        appBarParams: AppBarParams(
            dividerBottom: false,
            hasLeading: false,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: (Matrix4.identity()
                      ..scale(LanguageService.languageCode == 'ar' ? -1.0 : 1.0,
                          1.0, 1.0)),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding:
                            HWEdgeInsetsDirectional.fromSTEB(20.w, 15, 15, 15),
                        child: SvgPicture.asset(
                          AppAssets.backFromCallSvg,
                          width: 8.w,
                          color: const Color(0xff388CFF),
                        ),
                      ),
                    ),
                  ),
                  10.horizontalSpace,
                  MyTextWidget(
                    LocaleKeys.contacts_list.tr(),
                    style: textTheme.bodyMedium?.rr
                        .copyWith(color: const Color(0xff388CFF)),
                  ),
                ],
              ),
            )),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          controller: scrollController,
          scrollBehavior: const CupertinoScrollBehavior(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: 1.sw,
                height: 50,
                margin: HWEdgeInsets.symmetric(vertical: 5),
                color: colorScheme.white,
                padding: HWEdgeInsets.symmetric(horizontal: 10.w, vertical: 5),
                child: AppTextField(
                  controller: form.controllers[0],
                  filledColor: colorScheme.grey50,
                  bordersColor: colorScheme.grey50,
                  hintText: LocaleKeys.search_chat_contact_startNewChat.tr(),
                  hintTextStyle: textTheme.bodySmall?.lr
                      .copyWith(color: const Color(0xffD3D3D3)),
                  onChange: (String? text) {
                    if (text?.isEmpty ?? true) {
                      searchContacts.value = chatBloc.state.contacts;
                    } else {
                      List<Contact> search = [];
                      for (Contact contact
                          in GetIt.I<ChatBloc>().state.contacts) {
                        if (contact.name!
                                .toLowerCase()
                                .contains(text?.toLowerCase() ?? '') ||
                            contact.mobilePhone!
                                .toLowerCase()
                                .contains(text?.toLowerCase() ?? '')) {
                          search.add(contact);
                        }
                      }
                      searchContacts.value = search;
                    }
                  },
                  contentPadding:
                      HWEdgeInsetsDirectional.fromSTEB(20.w, 10, 20.w, 10),
                  prefixIcon: Padding(
                    padding: HWEdgeInsetsDirectional.only(top: 10, bottom: 10),
                    child: SvgPicture.asset(
                      AppAssets.searchSvg,
                      height: 20,
                      width: 20.h,
                    ),
                  ),
                ),
              ),
            ),
            BlocConsumer<ChatBloc, ChatState>(
              buildWhen: (p, c) => p.getContactsStatus != c.getContactsStatus,
              listenWhen: (p, c) => p.getContactsStatus != c.getContactsStatus,
              listener: (context, state) {
                searchContacts.value = state.contacts;
              },
              builder: (context, state) {
                if ((state.getContactsStatus == GetContactsStatus.loading ||
                        state.getContactsStatus == GetContactsStatus.init) &&
                    state.contacts.isNullOrEmpty) {
                  return SliverToBoxAdapter(
                      child: SizedBox(
                    height: 1.sh - 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TrydosLoader(),
                      ],
                    ),
                  ));
                }
                if (state.getContactsStatus == GetContactsStatus.failure) {
                  return Center(
                    child: ElevatedButton(
                        onPressed: () {
                          chatBloc.add(GetContactsEvent());
                        },
                        child: MyTextWidget(LocaleKeys.try_again.tr())),
                  );
                }
                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                        child: Container(
                            width: 1.sw,
                            color: colorScheme.white,
                            child: state.getContactsStatus !=
                                    GetContactsStatus.success
                                ? TrydosLoader()
                                : const SizedBox.shrink())),
                    ValueListenableBuilder<List<Contact>>(
                        valueListenable: searchContacts,
                        builder: (context, searchedContacts, _) {
                          return sliverListSeparated(
                            itemBuilder: (_, index) {
                              return ContactCard(
                                key: TestVariables.kTestMode
                                    ? Key(
                                        '${WidgetsKey.contactCardKey}$index',
                                      )
                                    : null,
                                index: index,
                                contact: searchedContacts[index],
                              );
                            },
                            separator: const SizedBox.shrink(),
                            childCount: searchedContacts.length,
                          );
                        }),
                  ],
                );
              },
            ),
            SliverToBoxAdapter(
              child: 20.verticalSpace,
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
