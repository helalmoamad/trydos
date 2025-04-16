import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import '../../manager/orderBloc/order_bloc.dart';
import '../../manager/orderBloc/order_event.dart';
import '../../manager/orderBloc/order_state.dart';

class ProfileAddressInfoPage extends StatefulWidget {
  const ProfileAddressInfoPage({super.key});

  @override
  State<ProfileAddressInfoPage> createState() => _ProfileAddressInfoPageState();
}

class _ProfileAddressInfoPageState extends State<ProfileAddressInfoPage>
    with SingleTickerProviderStateMixin {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late AnimationController animationController;
  final ValueNotifier<int> indexTap = ValueNotifier(0);
  late HomeBloc homeBloc;
  late OrderBloc orderBloc;
  final ValueNotifier<bool> visibleSave = ValueNotifier(false);
  final ValueNotifier<bool> showDeleteAddress = ValueNotifier(false);
  int indexToDelete = 0;
  bool setIndexDefailtForFirst = false;

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    orderBloc = BlocProvider.of<OrderBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return ValueListenableBuilder<bool>(
        valueListenable: visibleSave,
        builder: (context, _visibleSave, _) {
          return Scaffold(
              appBar: TrydosAppBar(
                appBarParams: AppBarParams(
                    backgroundColor: Color(0x000000),
                    action: [
                      Spacer(),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : SizedBox(
                              width: 55.w,
                            ),
                      Text(
                        LocaleKeys.profile_ddress.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 14,
                            height: 1.3),
                      ),
                      Spacer(),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                try {
                                  orderBloc.add(SetCustomerAddressDefaultEvent(
                                      adressId: orderBloc
                                          .state
                                          .listOfAddressInfoClassToSave![
                                              indexTap.value]
                                          .id));
                                } catch (e) {}
                                Navigator.pop(context);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 40,
                                height: 20,
                                child: Text(
                                  LocaleKeys.save.tr(),
                                  style: context.textTheme.bodyMedium?.mr
                                      .copyWith(
                                          color: const Color(0xff402CDD),
                                          letterSpacing: 0.18,
                                          fontSize: 14,
                                          height: 1.3),
                                ),
                              ),
                            ),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : SizedBox(
                              width: 15.w,
                            )
                    ],
                    scrolledUnderElevation: 0,
                    backIconColor: Colors.black,
                    withShadow: false),
              ),
              body: SafeArea(
                  child: SingleChildScrollView(
                child: BlocBuilder<OrderBloc, OrderState>(
                    buildWhen: (previous, current) =>
                        previous.getCustomerAddressStatus !=
                            current.getCustomerAddressStatus ||
                        previous.editAddressToOrderStatus !=
                            current.editAddressToOrderStatus ||
                        previous.setCustomerAddressDefaultStatus !=
                            current.setCustomerAddressDefaultStatus ||
                        previous.addAddressToOrderStatus !=
                            current.addAddressToOrderStatus ||
                        previous.removeAddressToOrderStatus !=
                            current.removeAddressToOrderStatus,
                    builder: (context, state) {
                      Future.delayed(
                        Duration(milliseconds: 200),
                        () {
                          if (state.setCustomerAddressDefaultStatus !=
                                  SetCustomerAddressDefaultStatus.loading &&
                              state.getCustomerAddressStatus !=
                                  GetCustomerAddressesStatus.loading &&
                              !setIndexDefailtForFirst) {
                            indexTap.value = state.currentAddressChoosed ?? 0;
                            setIndexDefailtForFirst = true;
                          }
                        },
                      );
                      return ValueListenableBuilder<bool>(
                          valueListenable: showDeleteAddress,
                          builder: (context, _showDeleteAddress, _) {
                            return ValueListenableBuilder<int>(
                                valueListenable: indexTap,
                                builder: (context, _indexTap, _) {
                                  return Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              height: 50,
                                              width: 1.sw,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffF8F8F8),
                                                  border: Border.all(
                                                      color:
                                                          Color(0xffD3D3D3))),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  SvgPicture.asset(
                                                    AppAssets.infoSvg,
                                                    color: Color(0xff402CDD),
                                                    width: 25.w,
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Text(
                                                    LocaleKeys
                                                        .entering_your_information_correctly
                                                        .tr(),
                                                    style: context.textTheme
                                                        .bodyMedium?.rr
                                                        .copyWith(
                                                            color: const Color(
                                                                0xff8D8D8D),
                                                            letterSpacing: 0.18,
                                                            fontSize: 10.sp,
                                                            height: 1.3),
                                                  ),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            height: 15,
                                            width: 150,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.addressSvg,
                                                  height: 15,
                                                  color: Color(0xff404040),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  LocaleKeys.your_address_info
                                                      .tr(),
                                                  style: context
                                                      .textTheme.bodyMedium?.mr
                                                      .copyWith(
                                                          color: const Color(
                                                              0xff404040),
                                                          letterSpacing: 0.18,
                                                          fontSize: 12,
                                                          height: 1.2),
                                                ),
                                                SizedBox(width: 15),
                                                SvgPicture.asset(
                                                  AppAssets.chatWithQuestionSvg,
                                                  color: Color(0xffD3D3D3),
                                                  height: 15,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          !state.listOfAddressInfoClassToSave
                                                  .isNullOrEmpty
                                              ? Container(
                                                  width: 1.sw,
                                                  height: 1.sh,
                                                  child:
                                                      buildListOfAddressInfoWidgets(
                                                          context,
                                                          state,
                                                          _indexTap),
                                                )
                                              : buildAddressWidget()
                                        ],
                                      ),
                                      _showDeleteAddress
                                          ? buildDeleteAddressWidget(
                                              context, state)
                                          : SizedBox.shrink()
                                    ],
                                  );
                                });
                          });
                    }),
              )));
        });
  }

  Widget buildDeleteAddressWidget(BuildContext context, OrderState state) {
    return Container(
      width: 1.sw,
      height: 1.sh - 100.h,
      color: Color.fromRGBO(0, 0, 0, 0.90),
      child: Column(
        children: [
          SizedBox(
            height: 1.sh / 5,
          ),
          SvgPicture.asset(
            AppAssets.deletecartSvg,
            color: Color(0xffFFFFFF),
            width: 50,
            height: 50,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "${LocaleKeys.delete_below_address.tr()} ",
            style: context.textTheme.bodyMedium?.mr.copyWith(
                color: const Color(0xffFFFFFF),
                letterSpacing: 0.18,
                fontSize: 16,
                height: 1.33),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: addressInfoWithContactInfoCart(
              cartChoosed: false,
              context: context,
              isDelete: true,
              indexTap: 0,
              index: 1,
              customerAddressesInfo:
                  state.listOfAddressInfoClassToSave![indexToDelete],
              onTapDelete: () {},
              onTapEdit: () {},
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () {
              showDeleteAddress.value = false;
              orderBloc.add(DeleteAdressInfoClassEvent(
                  adressInfoClassId:
                      state.listOfAddressInfoClassToSave?[indexToDelete].id));
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              height: 50.h,
              width: 1.sw,
              decoration: BoxDecoration(
                  color: Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(0xffFF5F61),
                  )),
              child: Center(
                child: Text(
                  LocaleKeys.yes_delete.tr(),
                  style: context.textTheme.bodyMedium?.br.copyWith(
                      color: Color(0xffFF5F61),
                      letterSpacing: 0.18,
                      fontSize: 16,
                      height: 1.3),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              showDeleteAddress.value = false;
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              height: 50.h,
              width: 1.sw,
              child: Center(
                child: Text(
                  LocaleKeys.cansel.tr(),
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                      color: Color(0xffFFFFFF),
                      letterSpacing: 0.18,
                      fontSize: 16,
                      height: 1.3),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Widget buildAddressWidget() {
    return Container(
        // height: !(state.listOfAddressInfoClassToSave.isNullOrEmpty) ? 225 : 203,
        width: 1.sw,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 85.h,
              width: 1.sw,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xffF8F8F8))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 8.h,
                  ),
                  SvgPicture.asset(
                    AppAssets.chatWithQuestionSvg,
                  ),
                  SizedBox(
                    height: 18.h,
                  ),
                  Text(
                    "${LocaleKeys.your_address_list_is_empty.tr()} ",
                    style: context.textTheme.bodyMedium?.ra.copyWith(
                        color: const Color(0xffC4C2C2),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 0.8),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    "${LocaleKeys.you_can_also_create_multiple_addresses_to_use.tr()} ",
                    style: context.textTheme.bodyMedium?.ra.copyWith(
                        color: const Color(0xffC4C2C2),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 0.8),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            InkWell(
              onTap: () => HelperFunctions.slidingNavigation(
                  context, AddShippingAdress()),
              child: Container(
                height: 40,
                width: 1.sw,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Color(0xffE8FFED),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xffC4C2C2))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            AppAssets.addShippingAddressSvg,
                          ),
                          Positioned(
                            top: 2,
                            child: SvgPicture.asset(
                              AppAssets.addShippingAddressWhiteSvg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "${LocaleKeys.add_shipping_address.tr()} ",
                      style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 12,
                          height: 1.33),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget buildListOfAddressInfoWidgets(
      BuildContext context, OrderState state, int _indexTap) {
    return Container(
        width: 1.sw,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100 *
                  (state.listOfAddressInfoClassToSave?.length ?? 0).toDouble(),
              width: 1.sw,
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              child: ListView.separated(
                padding: EdgeInsets.all(0),
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    indexTap.value = index;
                    visibleSave.value = true;
                  },
                  child: addressInfoWithContactInfoCart(
                    cartChoosed: false,
                    isDelete: false,
                    customerAddressesInfo:
                        state.listOfAddressInfoClassToSave![index],
                    context: context,
                    index: index,
                    indexTap: _indexTap,
                    onTapDelete: () {
                      if (index == _indexTap) {
                        indexTap.value = 0;
                      }
                      indexToDelete = index;
                      showDeleteAddress.value = true;
                    },
                    onTapEdit: () {
                      HelperFunctions.slidingNavigation(
                        context,
                        AddShippingAdress(
                          addressInfoClassToEdid:
                              state.listOfAddressInfoClassToSave![index],
                          fromEdid: true,
                        ),
                      );
                    },
                  ),
                ),
                separatorBuilder: (context, index) => SizedBox(
                  height: 10,
                ),
                itemCount: state.listOfAddressInfoClassToSave!.length,
              ),
            ),
            InkWell(
              onTap: () {
                HelperFunctions.slidingNavigation(context, AddShippingAdress());
              },
              child: Container(
                height: 40,
                width: 1.sw,
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                decoration: BoxDecoration(
                    color: Color(0xffE8FFED),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xffC4C2C2))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            AppAssets.addShippingAddressSvg,
                          ),
                          Positioned(
                            top: 2,
                            child: SvgPicture.asset(
                              AppAssets.addShippingAddressWhiteSvg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "${LocaleKeys.add_new_shipping_address.tr()} ",
                      style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 12,
                          height: 1.33),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ));
  }

  Widget addressInfoWithContactInfoCart({
    required CustomerAddressesInfo customerAddressesInfo,
    required int index,
    required int indexTap,
    required bool isDelete,
    bool? placeOrder,
    bool? successfulOrder,
    required bool cartChoosed,
    required BuildContext context,
    required void Function()? onTapEdit,
    required void Function()? onTapDelete,
  }) {
    return Container(
        // height: (placeOrder ?? false)
        //     ? 120
        //     : (!isDelete && cartChoosed)
        //         ? 125
        //         : 90,
        width: 1.sw,
        height: 90,
        padding: EdgeInsets.only(
          right: LanguageService.languageCode == "ar" ? 20 : 10,
          left: LanguageService.languageCode != "ar" ? 20 : 10,
          bottom: 5,
        ),
        decoration: BoxDecoration(
            color: (placeOrder ?? false) || (successfulOrder ?? false)
                ? Color(0xffFFFFFF)
                : isDelete
                    ? Color.fromRGBO(0, 0, 0, 0)
                    : Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15),
            border: (placeOrder ?? false)
                ? Border.all(color: Color(0xffC4C2C2))
                : isDelete || (successfulOrder ?? false)
                    ? Border.all(color: Color(0xffFFFFFF))
                    : cartChoosed
                        ? Border.all(color: Color(0xff388CFF))
                        : index != indexTap
                            ? null
                            : Border.all(color: Color(0xff388CFF))),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Container(
              width: 360.w,
              height: 16,
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.homeInactiveSvg,
                    color: isDelete
                        ? Color(0xffFFFFFF)
                        : index != indexTap
                            ? Color(0xff8D8D8D)
                            : Color(0xff1D1D1D),
                    height: 12,
                    width: 12,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    customerAddressesInfo.address ?? "",
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: isDelete
                            ? Color(0xffFFFFFF)
                            : index != indexTap
                                ? Color(0xff8D8D8D)
                                : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  ),
                  isDelete || cartChoosed ? SizedBox.shrink() : Spacer(),
                  isDelete || cartChoosed
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: onTapEdit,
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            width: 15,
                            height: 12,
                            child: SvgPicture.asset(
                              AppAssets.editSvg,
                              height: 30,
                              width: 20,
                            ),
                          ),
                        ),
                  isDelete || cartChoosed
                      ? SizedBox.shrink()
                      : SizedBox(
                          width: 10,
                        ),
                  isDelete || cartChoosed
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: onTapDelete,
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            width: 20,
                            height: 30,
                            child: SvgPicture.asset(
                              AppAssets.deletecartSvg,
                              height: 14,
                              width: 14,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Container(
              width: 350.w,
              height: 16,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Text(
                    "${(customerAddressesInfo.regionDetails?.building.toString() == "null" || customerAddressesInfo.regionDetails?.building == "") ? "" : customerAddressesInfo.regionDetails?.building}${(customerAddressesInfo.regionDetails?.building.toString() != "null" && customerAddressesInfo.regionDetails?.building != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.street.toString() == "null" || customerAddressesInfo.regionDetails?.street == "" ? "" : customerAddressesInfo.regionDetails?.street}${(customerAddressesInfo.regionDetails?.street.toString() != "null" && customerAddressesInfo.regionDetails?.street != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.town.toString() == "null" || customerAddressesInfo.regionDetails?.town == "" ? "" : customerAddressesInfo.regionDetails?.town}${(customerAddressesInfo.regionDetails?.town.toString() != "null" && customerAddressesInfo.regionDetails?.town != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.city.toString() == "null" || customerAddressesInfo.regionDetails?.city == "" ? "" : customerAddressesInfo.regionDetails?.city}${(customerAddressesInfo.regionDetails?.city.toString() != "null" && customerAddressesInfo.regionDetails?.city != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.province.toString() == "null" || customerAddressesInfo.regionDetails?.province == "" ? "" : customerAddressesInfo.regionDetails?.province} | ${customerAddressesInfo.regionDetails?.country ?? ''}",
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: isDelete
                            ? Color(0xffFFFFFF)
                            : index != indexTap
                                ? Color(0xff8D8D8D)
                                : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  )
                ],
              ),
            ),
            Container(
              width: 350.w,
              height: 16,
              child: Row(
                children: [
                  Text(
                    "${customerAddressesInfo.addressDetail}",
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: isDelete
                            ? Color(0xffFFFFFF)
                            : index != indexTap
                                ? Color(0xff8D8D8D)
                                : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  )
                ],
              ),
            ),
            Container(
              width: 350.w,
              height: 16,
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.phoneCallSvg,
                    color: isDelete
                        ? Color(0xffFFFFFF)
                        : index != indexTap
                            ? Color(0xff8D8D8D)
                            : Color(0xff1D1D1D),
                    height: 12,
                    width: 12,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '+${customerAddressesInfo.contactInfo?.phone ?? ""}',
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: isDelete
                            ? Color(0xffFFFFFF)
                            : index != indexTap
                                ? Color(0xff8D8D8D)
                                : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Container(
                    height: 16,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.personSvg,
                          color: isDelete
                              ? Color(0xffFFFFFF)
                              : index != indexTap
                                  ? Color(0xff8D8D8D)
                                  : Color(0xff1D1D1D),
                          height: 12,
                          width: 12,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${customerAddressesInfo.contactInfo?.name ?? ""}',
                          style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: isDelete
                                  ? Color(0xffFFFFFF)
                                  : index != indexTap
                                      ? Color(0xff8D8D8D)
                                      : const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: (!isDelete && cartChoosed)
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
        ));
  }
}
