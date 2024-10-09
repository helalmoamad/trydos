// To parse this JSON data, do
//
//     final startingSettingsResponseModel = startingSettingsResponseModelFromJson(jsonString);

import 'dart:convert';

StartingSettingsResponseModel startingSettingsResponseModelFromJson(String str) => StartingSettingsResponseModel.fromJson(json.decode(str));

String startingSettingsResponseModelToJson(StartingSettingsResponseModel data) => json.encode(data.toJson());

class StartingSettingsResponseModel {
  final String? message;
  final Data? data;

  StartingSettingsResponseModel({
    this.message,
    this.data,
  });

  StartingSettingsResponseModel copyWith({
    String? message,
    Data? data,
  }) =>
      StartingSettingsResponseModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory StartingSettingsResponseModel.fromJson(Map<String, dynamic> json) => StartingSettingsResponseModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final StartingSetting? startingSetting;
  final String? advertiseTop;
  final String? returnAndExchange;
  final String? shipping;

  Data({
    this.startingSetting,
    this.advertiseTop,
    this.returnAndExchange,
    this.shipping,
  });

  Data copyWith({
    StartingSetting? startingSetting,
    String? advertiseTop,
    String? returnAndExchange,
    String? shipping,
  }) =>
      Data(
        startingSetting: startingSetting ?? this.startingSetting,
        advertiseTop: advertiseTop ?? this.advertiseTop,
        returnAndExchange: returnAndExchange ?? this.returnAndExchange,
        shipping: shipping ?? this.shipping,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    startingSetting: json["starting-setting"] == null ? null : StartingSetting.fromJson(json["starting-setting"]),
    advertiseTop: json["advertise_top"],
    returnAndExchange: json["return_and_exchange"],
    shipping: json["shipping"],
  );

  Map<String, dynamic> toJson() => {
    "starting-setting": startingSetting?.toJson(),
    "advertise_top": advertiseTop,
    "return_and_exchange": returnAndExchange,
    "shipping": shipping,
  };
}

class StartingSetting {
  final String? primaryColor;
  final String? mainBackgroundColor;
  final String? titleColor;
  final String? subCategoriesColor;
  final String? buyNowButtonColor;
  final String? priceColor;
  final String? shareButtonColor;
  final String? includingTaxColor;
  final String? giftBackColor;
  final String? categoryHeaderColor;
  final String? newSoftGreyColor;
  final String? mainGreyColor;
  final String? mainCatGreyColor;
  final String? newSoftGreyColorAux;
  final String? applyCouponButtonColor;
  final String? flashDealForeColor;
  final String? flashDealBackColor;
  final OffersTheme? offersTheme;
  final String? squareCurvedLogoUrl;
  final String? squareLogoUrl;
  final String? rectangularCurvedLogoUrl;
  final bool? showPaymentUsingCards;
  final bool? showPaymentUsingPostPay;
  final bool? showCashPayment;
  final bool? showFlashDeal;
  final int? androidMinVersion;
  final int? iosMinVersion;
  final int? closedHour;
  final String? messageTimeEndWork;
  final String? descriptionOnPageProductDetails;
  final bool? collectionGrid;
  final bool? showNotifications;
  final bool? showFeedBack;
  final bool? showContactWithWhatsapp;
  final String? defaultCountryDialCode;
  final bool? enableCrashylitcs;
  final bool? enableFirebaseMessaging;
  final bool? returnMoneyWithCard;
  final bool? returnMoneyWithWallet;
  final List<String>? orderStatusCanCanceled;
  final List<String>? orderStatusCanCanceledItem;
  final bool? verificationWithWhatsappEnable;
  final bool? verificationWithSmsEnable;
  final bool? isSystemSupportEmail;
  final bool? showSubCategoryTitle;
  final bool? enableInviteBanner;
  final List<Country>? countries;
  final Country? defaultCountry;
  final List<String>? addressType;
  final int? systemDefaultCurrency;
  final bool? canInviteFriends;
  final bool? showButtonWhatsappCashOnDelivery;
  final bool? smartLook;
  final List<Language>? language;
  final List<NotificationType>? notificationTypes;
  final List<CurrencyList>? currencyList;
  final String? telrSuccessUrl;
  final String? postPaySuccessUrl;
  final int? decimalPointSetting;
  StartingSetting({
    this.primaryColor,
    this.mainBackgroundColor,
    this.titleColor,
    this.subCategoriesColor,
    this.buyNowButtonColor,
    this.decimalPointSetting,
    this.priceColor,
    this.shareButtonColor,
    this.includingTaxColor,
    this.giftBackColor,
    this.categoryHeaderColor,
    this.newSoftGreyColor,
    this.mainGreyColor,
    this.mainCatGreyColor,
    this.newSoftGreyColorAux,
    this.applyCouponButtonColor,
    this.flashDealForeColor,
    this.flashDealBackColor,
    this.offersTheme,
    this.squareCurvedLogoUrl,
    this.squareLogoUrl,
    this.rectangularCurvedLogoUrl,
    this.showPaymentUsingCards,
    this.showPaymentUsingPostPay,
    this.showCashPayment,
    this.showFlashDeal,
    this.androidMinVersion,
    this.iosMinVersion,
    this.closedHour,
    this.messageTimeEndWork,
    this.descriptionOnPageProductDetails,
    this.collectionGrid,
    this.showNotifications,
    this.showFeedBack,
    this.showContactWithWhatsapp,
    this.defaultCountryDialCode,
    this.enableCrashylitcs,
    this.enableFirebaseMessaging,
    this.returnMoneyWithCard,
    this.returnMoneyWithWallet,
    this.orderStatusCanCanceled,
    this.orderStatusCanCanceledItem,
    this.verificationWithWhatsappEnable,
    this.verificationWithSmsEnable,
    this.isSystemSupportEmail,
    this.showSubCategoryTitle,
    this.enableInviteBanner,
    this.countries,
    this.notificationTypes,
    this.defaultCountry,
    this.addressType,
    this.systemDefaultCurrency,
    this.canInviteFriends,
    this.showButtonWhatsappCashOnDelivery,
    this.smartLook,
    this.language,
    this.currencyList,
    this.telrSuccessUrl,
    this.postPaySuccessUrl,
  });

  StartingSetting copyWith({
    String? primaryColor,
    String? mainBackgroundColor,
    String? titleColor,
    String? subCategoriesColor,
    String? buyNowButtonColor,
    String? priceColor,
    String? shareButtonColor,
    String? includingTaxColor,
    String? giftBackColor,
    String? categoryHeaderColor,
    String? newSoftGreyColor,
    String? mainGreyColor,
    String? mainCatGreyColor,
    String? newSoftGreyColorAux,
    String? applyCouponButtonColor,
    String? flashDealForeColor,
    String? flashDealBackColor,
    OffersTheme? offersTheme,
    String? squareCurvedLogoUrl,
    String? squareLogoUrl,
    String? rectangularCurvedLogoUrl,
    bool? showPaymentUsingCards,
    bool? showPaymentUsingPostPay,
    bool? showCashPayment,
    bool? showFlashDeal,
    int? androidMinVersion,
    int? decimalPointSetting,
    int? iosMinVersion,
    int? closedHour,
    String? messageTimeEndWork,
    String? descriptionOnPageProductDetails,
    bool? collectionGrid,
    bool? showNotifications,
    bool? showFeedBack,
    bool? showContactWithWhatsapp,
    String? defaultCountryDialCode,
    bool? enableCrashylitcs,
    bool? enableFirebaseMessaging,
    bool? returnMoneyWithCard,
    bool? returnMoneyWithWallet,
    List<String>? orderStatusCanCanceled,
    List<String>? orderStatusCanCanceledItem,
    bool? verificationWithWhatsappEnable,
    bool? verificationWithSmsEnable,
    bool? isSystemSupportEmail,
    bool? showSubCategoryTitle,
    bool? enableInviteBanner,
    List<Country>? countries,
    Country? defaultCountry,
    List<String>? addressType,
    int? systemDefaultCurrency,
    bool? canInviteFriends,
    bool? showButtonWhatsappCashOnDelivery,
    bool? smartLook,
    List<Language>? language,
    List<NotificationType>? notificationTypes,
    List<CurrencyList>? currencyList,
    String? telrSuccessUrl,
    String? postPaySuccessUrl,
  }) =>
      StartingSetting(
        primaryColor: primaryColor ?? this.primaryColor,
        mainBackgroundColor: mainBackgroundColor ?? this.mainBackgroundColor,
        titleColor: titleColor ?? this.titleColor,
        subCategoriesColor: subCategoriesColor ?? this.subCategoriesColor,
        buyNowButtonColor: buyNowButtonColor ?? this.buyNowButtonColor,
        priceColor: priceColor ?? this.priceColor,
        shareButtonColor: shareButtonColor ?? this.shareButtonColor,
        includingTaxColor: includingTaxColor ?? this.includingTaxColor,
        giftBackColor: giftBackColor ?? this.giftBackColor,
        decimalPointSetting: decimalPointSetting ?? this.decimalPointSetting,
        categoryHeaderColor: categoryHeaderColor ?? this.categoryHeaderColor,
        newSoftGreyColor: newSoftGreyColor ?? this.newSoftGreyColor,
        mainGreyColor: mainGreyColor ?? this.mainGreyColor,
        mainCatGreyColor: mainCatGreyColor ?? this.mainCatGreyColor,
        newSoftGreyColorAux: newSoftGreyColorAux ?? this.newSoftGreyColorAux,
        applyCouponButtonColor: applyCouponButtonColor ?? this.applyCouponButtonColor,
        flashDealForeColor: flashDealForeColor ?? this.flashDealForeColor,
        flashDealBackColor: flashDealBackColor ?? this.flashDealBackColor,
        offersTheme: offersTheme ?? this.offersTheme,
        squareCurvedLogoUrl: squareCurvedLogoUrl ?? this.squareCurvedLogoUrl,
        squareLogoUrl: squareLogoUrl ?? this.squareLogoUrl,
        rectangularCurvedLogoUrl: rectangularCurvedLogoUrl ?? this.rectangularCurvedLogoUrl,
        showPaymentUsingCards: showPaymentUsingCards ?? this.showPaymentUsingCards,
        showPaymentUsingPostPay: showPaymentUsingPostPay ?? this.showPaymentUsingPostPay,
        showCashPayment: showCashPayment ?? this.showCashPayment,
        showFlashDeal: showFlashDeal ?? this.showFlashDeal,
        androidMinVersion: androidMinVersion ?? this.androidMinVersion,
        iosMinVersion: iosMinVersion ?? this.iosMinVersion,
        closedHour: closedHour ?? this.closedHour,
        messageTimeEndWork: messageTimeEndWork ?? this.messageTimeEndWork,
        descriptionOnPageProductDetails: descriptionOnPageProductDetails ?? this.descriptionOnPageProductDetails,
        collectionGrid: collectionGrid ?? this.collectionGrid,
        showNotifications: showNotifications ?? this.showNotifications,
        showFeedBack: showFeedBack ?? this.showFeedBack,
        showContactWithWhatsapp: showContactWithWhatsapp ?? this.showContactWithWhatsapp,
        defaultCountryDialCode: defaultCountryDialCode ?? this.defaultCountryDialCode,
        enableCrashylitcs: enableCrashylitcs ?? this.enableCrashylitcs,
        enableFirebaseMessaging: enableFirebaseMessaging ?? this.enableFirebaseMessaging,
        returnMoneyWithCard: returnMoneyWithCard ?? this.returnMoneyWithCard,
        returnMoneyWithWallet: returnMoneyWithWallet ?? this.returnMoneyWithWallet,
        orderStatusCanCanceled: orderStatusCanCanceled ?? this.orderStatusCanCanceled,
        orderStatusCanCanceledItem: orderStatusCanCanceledItem ?? this.orderStatusCanCanceledItem,
        verificationWithWhatsappEnable: verificationWithWhatsappEnable ?? this.verificationWithWhatsappEnable,
        verificationWithSmsEnable: verificationWithSmsEnable ?? this.verificationWithSmsEnable,
        isSystemSupportEmail: isSystemSupportEmail ?? this.isSystemSupportEmail,
        showSubCategoryTitle: showSubCategoryTitle ?? this.showSubCategoryTitle,
        enableInviteBanner: enableInviteBanner ?? this.enableInviteBanner,
        countries: countries ?? this.countries,
        defaultCountry: defaultCountry ?? this.defaultCountry,
        addressType: addressType ?? this.addressType,
        systemDefaultCurrency: systemDefaultCurrency ?? this.systemDefaultCurrency,
        canInviteFriends: canInviteFriends ?? this.canInviteFriends,
        showButtonWhatsappCashOnDelivery: showButtonWhatsappCashOnDelivery ?? this.showButtonWhatsappCashOnDelivery,
        smartLook: smartLook ?? this.smartLook,
        language: language ?? this.language,
        notificationTypes: notificationTypes ?? this.notificationTypes,
        currencyList: currencyList ?? this.currencyList,
        telrSuccessUrl: telrSuccessUrl ?? this.telrSuccessUrl,
        postPaySuccessUrl: postPaySuccessUrl ?? this.postPaySuccessUrl,
      );

  factory StartingSetting.fromJson(Map<String, dynamic> json) => StartingSetting(
    primaryColor: json["primaryColor"],
    mainBackgroundColor: json["mainBackgroundColor"],
    titleColor: json["titleColor"],
    subCategoriesColor: json["subCategoriesColor"],
    buyNowButtonColor: json["buyNowButtonColor"],
    priceColor: json["priceColor"],
    shareButtonColor: json["shareButtonColor"],
    includingTaxColor: json["includingTaxColor"],
    giftBackColor: json["giftBackColor"],
    categoryHeaderColor: json["categoryHeaderColor"],
    newSoftGreyColor: json["newSoftGreyColor"],
    mainGreyColor: json["mainGreyColor"],
    mainCatGreyColor: json["mainCatGreyColor"],
    newSoftGreyColorAux: json["newSoftGreyColorAux"],
    applyCouponButtonColor: json["applyCouponButtonColor"],
    flashDealForeColor: json["flash_deal_foreColor"],
    flashDealBackColor: json["flash_deal_backColor"],
    offersTheme: json["offersTheme"] == null ? null : OffersTheme.fromJson(json["offersTheme"]),
    squareCurvedLogoUrl: json["square_curved_logo_url"],
    squareLogoUrl: json["square_logo_url"],
    rectangularCurvedLogoUrl: json["rectangular_curved_logo_url"],
    showPaymentUsingCards: json["show_payment_using_cards"],
    showPaymentUsingPostPay: json["show_payment_using_post_pay"],
    showCashPayment: json["show_Cash_payment"],
    showFlashDeal: json["show_flash_deal"],
    androidMinVersion: json["android_min_version"],
    iosMinVersion: json["ios_min_version"],
    closedHour: json["closed_hour"],
    messageTimeEndWork: json["message_time_end_work"],
    descriptionOnPageProductDetails: json["description_on_page_product_details"],
    collectionGrid: json["collection_grid"],
    showNotifications: json["show_notifications"],
    decimalPointSetting: json["decimal_point_settings"],
    showFeedBack: json["show_feedBack"],
    showContactWithWhatsapp: json["show_contact_with_whatsapp"],
    defaultCountryDialCode: json["default_country_dial_code"],
    enableCrashylitcs: json["enable_crashylitcs"],
    enableFirebaseMessaging: json["enable_Firebase_Messaging"],
    returnMoneyWithCard: json["return_money_with_card"],
    returnMoneyWithWallet: json["return_money_with_wallet"],
    orderStatusCanCanceled: json["order_status_can_canceled"] == null ? [] : List<String>.from(json["order_status_can_canceled"]!.map((x) => x)),
    orderStatusCanCanceledItem: json["order_status_can_canceled_item"] == null ? [] : List<String>.from(json["order_status_can_canceled_item"]!.map((x) => x)),
    verificationWithWhatsappEnable: json["verification_with_whatsapp_enable"],
    verificationWithSmsEnable: json["verification_with_sms_enable"],
    isSystemSupportEmail: json["is_system_support_email"],
    showSubCategoryTitle: json["show_subCategory_title"],
    enableInviteBanner: json["enable_invite_banner"],
    countries: json["countries"] == null ? [] : List<Country>.from(json["countries"]!.map((x) => Country.fromJson(x))),
    defaultCountry: json["default_country"] == null ? null : Country.fromJson(json["default_country"]),
    addressType: json["address_type"] == null ? [] : List<String>.from(json["address_type"]!.map((x) => x)),
    systemDefaultCurrency: json["system_default_currency"],
    canInviteFriends: json["can_invite_friends"],
    showButtonWhatsappCashOnDelivery: json["show_button_whatsapp_cash_on_delivery"],
    smartLook: json["smart_look"],
    language: json["language"] == null ? [] : List<Language>.from(json["language"]!.map((x) => Language.fromJson(x))),
    notificationTypes: json["notificationTypes"] == null ? [] : List<NotificationType>.from(json["notificationTypes"]!.map((x) => NotificationType.fromJson(x))),
    currencyList: json["currency_list"] == null ? [] : List<CurrencyList>.from(json["currency_list"]!.map((x) => CurrencyList.fromJson(x))),
    telrSuccessUrl: json["telr_success_url"],
    postPaySuccessUrl: json["post_pay_success_url"],
  );

  Map<String, dynamic> toJson() => {
    "primaryColor": primaryColor,
    "mainBackgroundColor": mainBackgroundColor,
    "titleColor": titleColor,
    "subCategoriesColor": subCategoriesColor,
    "buyNowButtonColor": buyNowButtonColor,
    "priceColor": priceColor,
    "shareButtonColor": shareButtonColor,
    "includingTaxColor": includingTaxColor,
    "giftBackColor": giftBackColor,
    "categoryHeaderColor": categoryHeaderColor,
    "newSoftGreyColor": newSoftGreyColor,
    "mainGreyColor": mainGreyColor,
    "mainCatGreyColor": mainCatGreyColor,
    "newSoftGreyColorAux": newSoftGreyColorAux,
    "applyCouponButtonColor": applyCouponButtonColor,
    "flash_deal_foreColor": flashDealForeColor,
    "decimal_point_settings": decimalPointSetting,
    "flash_deal_backColor": flashDealBackColor,
    "offersTheme": offersTheme?.toJson(),
    "square_curved_logo_url": squareCurvedLogoUrl,
    "square_logo_url": squareLogoUrl,
    "rectangular_curved_logo_url": rectangularCurvedLogoUrl,
    "show_payment_using_cards": showPaymentUsingCards,
    "show_payment_using_post_pay": showPaymentUsingPostPay,
    "show_Cash_payment": showCashPayment,
    "show_flash_deal": showFlashDeal,
    "android_min_version": androidMinVersion,
    "ios_min_version": iosMinVersion,
    "closed_hour": closedHour,
    "message_time_end_work": messageTimeEndWork,
    "description_on_page_product_details": descriptionOnPageProductDetails,
    "collection_grid": collectionGrid,
    "show_notifications": showNotifications,
    "show_feedBack": showFeedBack,
    "show_contact_with_whatsapp": showContactWithWhatsapp,
    "default_country_dial_code": defaultCountryDialCode,
    "enable_crashylitcs": enableCrashylitcs,
    "enable_Firebase_Messaging": enableFirebaseMessaging,
    "return_money_with_card": returnMoneyWithCard,
    "return_money_with_wallet": returnMoneyWithWallet,
    "order_status_can_canceled": orderStatusCanCanceled == null ? [] : List<dynamic>.from(orderStatusCanCanceled!.map((x) => x)),
    "order_status_can_canceled_item": orderStatusCanCanceledItem == null ? [] : List<dynamic>.from(orderStatusCanCanceledItem!.map((x) => x)),
    "verification_with_whatsapp_enable": verificationWithWhatsappEnable,
    "verification_with_sms_enable": verificationWithSmsEnable,
    "is_system_support_email": isSystemSupportEmail,
    "show_subCategory_title": showSubCategoryTitle,
    "enable_invite_banner": enableInviteBanner,
    "countries": countries == null ? [] : List<dynamic>.from(countries!.map((x) => x.toJson())),
    "default_country": defaultCountry?.toJson(),
    "address_type": addressType == null ? [] : List<dynamic>.from(addressType!.map((x) => x)),
    "system_default_currency": systemDefaultCurrency,
    "can_invite_friends": canInviteFriends,
    "show_button_whatsapp_cash_on_delivery": showButtonWhatsappCashOnDelivery,
    "smart_look": smartLook,
    "language": language == null ? [] : List<dynamic>.from(language!.map((x) => x.toJson())),
    "notificationTypes": notificationTypes == null ? [] : List<dynamic>.from(notificationTypes!.map((x) => x.toJson())),
    "currency_list": currencyList == null ? [] : List<dynamic>.from(currencyList!.map((x) => x.toJson())),
    "telr_success_url": telrSuccessUrl,
    "post_pay_success_url": postPaySuccessUrl,
  };
}

class Country {
  final int? id;
  final String? iso;
  final String? name;
  final String? nicename;
  final String? iso3;
  final int? numcode;
  final int? phonecode;
  final int? status;
  final int? isAccess;
  final int? otpByWhatsapp;
  final int? otpBySms;
  final dynamic createdAt;
  final DateTime? updatedAt;

  Country({
    this.id,
    this.iso,
    this.name,
    this.nicename,
    this.iso3,
    this.numcode,
    this.phonecode,
    this.status,
    this.isAccess,
    this.otpByWhatsapp,
    this.otpBySms,
    this.createdAt,
    this.updatedAt,
  });

  Country copyWith({
    int? id,
    String? iso,
    String? name,
    String? nicename,
    String? iso3,
    int? numcode,
    int? phonecode,
    int? status,
    int? isAccess,
    int? otpByWhatsapp,
    int? otpBySms,
    dynamic createdAt,
    DateTime? updatedAt,
  }) =>
      Country(
        id: id ?? this.id,
        iso: iso ?? this.iso,
        name: name ?? this.name,
        nicename: nicename ?? this.nicename,
        iso3: iso3 ?? this.iso3,
        numcode: numcode ?? this.numcode,
        phonecode: phonecode ?? this.phonecode,
        status: status ?? this.status,
        isAccess: isAccess ?? this.isAccess,
        otpByWhatsapp: otpByWhatsapp ?? this.otpByWhatsapp,
        otpBySms: otpBySms ?? this.otpBySms,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    id: json["id"],
    iso: json["iso"],
    name: json["name"],
    nicename: json["nicename"],
    iso3: json["iso3"],
    numcode: json["numcode"],
    phonecode: json["phonecode"],
    status: json["status"],
    isAccess: json["isAccess"],
    otpByWhatsapp: json["otp_by_whatsapp"],
    otpBySms: json["otp_by_sms"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "iso": iso,
    "name": name,
    "nicename": nicename,
    "iso3": iso3,
    "numcode": numcode,
    "phonecode": phonecode,
    "status": status,
    "isAccess": isAccess,
    "otp_by_whatsapp": otpByWhatsapp,
    "otp_by_sms": otpBySms,
    "created_at": createdAt,
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class CurrencyList {
  final int? id;
  final String? name;
  final String? symbol;
  final String? code;
  final double? exchangeRate;
  final int? status;
  final int? showInWebsite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CurrencyList({
    this.id,
    this.name,
    this.symbol,
    this.code,
    this.exchangeRate,
    this.status,
    this.showInWebsite,
    this.createdAt,
    this.updatedAt,
  });

  CurrencyList copyWith({
    int? id,
    String? name,
    String? symbol,
    String? code,
    double? exchangeRate,
    int? status,
    int? showInWebsite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CurrencyList(
        id: id ?? this.id,
        name: name ?? this.name,
        symbol: symbol ?? this.symbol,
        code: code ?? this.code,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        status: status ?? this.status,
        showInWebsite: showInWebsite ?? this.showInWebsite,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory CurrencyList.fromJson(Map<String, dynamic> json) => CurrencyList(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    code: json["code"],
    exchangeRate: json["exchange_rate"]?.toDouble(),
    status: json["status"],
    showInWebsite: json["show_in_website"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "symbol": symbol,
    "code": code,
    "exchange_rate": exchangeRate,
    "status": status,
    "show_in_website": showInWebsite,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Language {
  final String? code;
  final String? name;

  Language({
    this.code,
    this.name,
  });

  Language copyWith({
    String? code,
    String? name,
  }) =>
      Language(
        code: code ?? this.code,
        name: name ?? this.name,
      );

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    code: json["code"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
  };
}

class NotificationType {
  final int? id;
  final String? name;

  NotificationType({
    this.id,
    this.name,
  });

  NotificationType copyWith({
    int ? id,
    String? name,
  }) =>
      NotificationType(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory NotificationType.fromJson(Map<String, dynamic> json) => NotificationType(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class OffersTheme {
  final ClearanceSale? everyThingMustGo;
  final ClearanceSale? hardClearance;
  final ClearanceSale? clearanceSale;
  final ClearanceSale? freshSale;

  OffersTheme({
    this.everyThingMustGo,
    this.hardClearance,
    this.clearanceSale,
    this.freshSale,
  });

  OffersTheme copyWith({
    ClearanceSale? everyThingMustGo,
    ClearanceSale? hardClearance,
    ClearanceSale? clearanceSale,
    ClearanceSale? freshSale,
  }) =>
      OffersTheme(
        everyThingMustGo: everyThingMustGo ?? this.everyThingMustGo,
        hardClearance: hardClearance ?? this.hardClearance,
        clearanceSale: clearanceSale ?? this.clearanceSale,
        freshSale: freshSale ?? this.freshSale,
      );

  factory OffersTheme.fromJson(Map<String, dynamic> json) => OffersTheme(
    everyThingMustGo: json["everyThingMustGo"] == null ? null : ClearanceSale.fromJson(json["everyThingMustGo"]),
    hardClearance: json["hardClearance"] == null ? null : ClearanceSale.fromJson(json["hardClearance"]),
    clearanceSale: json["clearanceSale"] == null ? null : ClearanceSale.fromJson(json["clearanceSale"]),
    freshSale: json["freshSale"] == null ? null : ClearanceSale.fromJson(json["freshSale"]),
  );

  Map<String, dynamic> toJson() => {
    "everyThingMustGo": everyThingMustGo?.toJson(),
    "hardClearance": hardClearance?.toJson(),
    "clearanceSale": clearanceSale?.toJson(),
    "freshSale": freshSale?.toJson(),
  };
}

class ClearanceSale {
  final String? backgroundColor;
  final String? foregroundColor;

  ClearanceSale({
    this.backgroundColor,
    this.foregroundColor,
  });

  ClearanceSale copyWith({
    String? backgroundColor,
    String? foregroundColor,
  }) =>
      ClearanceSale(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
      );

  factory ClearanceSale.fromJson(Map<String, dynamic> json) => ClearanceSale(
    backgroundColor: json["backgroundColor"],
    foregroundColor: json["foregroundColor"],
  );

  Map<String, dynamic> toJson() => {
    "backgroundColor": backgroundColor,
    "foregroundColor": foregroundColor,
  };
}
