// To parse this JSON data, do
//
//     final verifyGuestPhoneResponseModel = verifyGuestPhoneResponseModelFromJson(jsonString);

import 'dart:convert';

VerifyGuestPhoneResponseModel verifyGuestPhoneResponseModelFromJson(String str) => VerifyGuestPhoneResponseModel.fromJson(json.decode(str));

String verifyGuestPhoneResponseModelToJson(VerifyGuestPhoneResponseModel data) => json.encode(data.toJson());

class VerifyGuestPhoneResponseModel {
  final String? code;
  final String? message;
  final Data? data;
  final String? token;
  final String? expiresAt;

  VerifyGuestPhoneResponseModel({
    this.code,
    this.message,
    this.data,
    this.token,
    this.expiresAt,
  });

  VerifyGuestPhoneResponseModel copyWith({
    String? code,
    String? message,
    Data? data,
    String? token,
    String? expiresAt,
  }) =>
      VerifyGuestPhoneResponseModel(
        code: code ?? this.code,
        message: message ?? this.message,
        data: data ?? this.data,
        token: token ?? this.token,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  factory VerifyGuestPhoneResponseModel.fromJson(Map<String, dynamic> json) => VerifyGuestPhoneResponseModel(
    code: json["code"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    token: json["token"],
    expiresAt: json["expires_at"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
    "token": token,
    "expires_at": expiresAt,
  };
}

class Data {
  final int? id;
  final dynamic name;
  final String? fName;
  final String? lName;
  final String? phone;
  final String? image;
  final String? email;
  final dynamic emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic streetAddress;
  final dynamic country;
  final dynamic city;
  final dynamic zip;
  final dynamic houseNo;
  final dynamic apartmentNo;
  final dynamic cmFirebaseToken;
  final int? isActive;
  final dynamic paymentCardLastFour;
  final dynamic paymentCardBrand;
  final dynamic paymentCardFawryToken;
  final dynamic loginMedium;
  final dynamic socialId;
  final int? isPhoneVerified;
  final String? temporaryToken;
  final int? isEmailVerified;
  final dynamic walletBalance;
  final dynamic loyaltyPoint;
  final int? hasTempOrder;
  final int? isGuest;
  final dynamic countryDialCode;
  final dynamic categories;
  final DateTime? updatedAtCategories;
  final int? isTester;
  final dynamic addedByAdminId;
  final int? isValidWhatsappNumber;
  final dynamic applicationRecommendedCategory;
  final dynamic webRecommendedCategory;
  final String? isStopWhatsappMessages;
  final int? isUseWhatsappForOtp;
  final dynamic lastActivityDatetime;
  final dynamic lastActivityType;
  final dynamic invitedContacts;
  final String? deviceId;
  final String? lastOtpIdToken;

  Data({
    this.id,
    this.name,
    this.fName,
    this.lName,
    this.phone,
    this.image,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.streetAddress,
    this.country,
    this.city,
    this.zip,
    this.houseNo,
    this.apartmentNo,
    this.cmFirebaseToken,
    this.isActive,
    this.paymentCardLastFour,
    this.paymentCardBrand,
    this.paymentCardFawryToken,
    this.loginMedium,
    this.socialId,
    this.isPhoneVerified,
    this.temporaryToken,
    this.isEmailVerified,
    this.walletBalance,
    this.loyaltyPoint,
    this.hasTempOrder,
    this.isGuest,
    this.countryDialCode,
    this.categories,
    this.updatedAtCategories,
    this.isTester,
    this.addedByAdminId,
    this.isValidWhatsappNumber,
    this.applicationRecommendedCategory,
    this.webRecommendedCategory,
    this.isStopWhatsappMessages,
    this.isUseWhatsappForOtp,
    this.lastActivityDatetime,
    this.lastActivityType,
    this.invitedContacts,
    this.deviceId,
    this.lastOtpIdToken,
  });

  Data copyWith({
    int? id,
    dynamic name,
    String? fName,
    String? lName,
    String? phone,
    String? image,
    String? email,
    dynamic emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic streetAddress,
    dynamic country,
    dynamic city,
    dynamic zip,
    dynamic houseNo,
    dynamic apartmentNo,
    dynamic cmFirebaseToken,
    int? isActive,
    dynamic paymentCardLastFour,
    dynamic paymentCardBrand,
    dynamic paymentCardFawryToken,
    dynamic loginMedium,
    dynamic socialId,
    int? isPhoneVerified,
    String? temporaryToken,
    int? isEmailVerified,
    dynamic walletBalance,
    dynamic loyaltyPoint,
    int? hasTempOrder,
    int? isGuest,
    dynamic countryDialCode,
    dynamic categories,
    DateTime? updatedAtCategories,
    int? isTester,
    dynamic addedByAdminId,
    int? isValidWhatsappNumber,
    dynamic applicationRecommendedCategory,
    dynamic webRecommendedCategory,
    String? isStopWhatsappMessages,
    int? isUseWhatsappForOtp,
    dynamic lastActivityDatetime,
    dynamic lastActivityType,
    dynamic invitedContacts,
    String? deviceId,
    String? lastOtpIdToken,
  }) =>
      Data(
        id: id ?? this.id,
        name: name ?? this.name,
        fName: fName ?? this.fName,
        lName: lName ?? this.lName,
        phone: phone ?? this.phone,
        image: image ?? this.image,
        email: email ?? this.email,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        streetAddress: streetAddress ?? this.streetAddress,
        country: country ?? this.country,
        city: city ?? this.city,
        zip: zip ?? this.zip,
        houseNo: houseNo ?? this.houseNo,
        apartmentNo: apartmentNo ?? this.apartmentNo,
        cmFirebaseToken: cmFirebaseToken ?? this.cmFirebaseToken,
        isActive: isActive ?? this.isActive,
        paymentCardLastFour: paymentCardLastFour ?? this.paymentCardLastFour,
        paymentCardBrand: paymentCardBrand ?? this.paymentCardBrand,
        paymentCardFawryToken: paymentCardFawryToken ?? this.paymentCardFawryToken,
        loginMedium: loginMedium ?? this.loginMedium,
        socialId: socialId ?? this.socialId,
        isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
        temporaryToken: temporaryToken ?? this.temporaryToken,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        walletBalance: walletBalance ?? this.walletBalance,
        loyaltyPoint: loyaltyPoint ?? this.loyaltyPoint,
        hasTempOrder: hasTempOrder ?? this.hasTempOrder,
        isGuest: isGuest ?? this.isGuest,
        countryDialCode: countryDialCode ?? this.countryDialCode,
        categories: categories ?? this.categories,
        updatedAtCategories: updatedAtCategories ?? this.updatedAtCategories,
        isTester: isTester ?? this.isTester,
        addedByAdminId: addedByAdminId ?? this.addedByAdminId,
        isValidWhatsappNumber: isValidWhatsappNumber ?? this.isValidWhatsappNumber,
        applicationRecommendedCategory: applicationRecommendedCategory ?? this.applicationRecommendedCategory,
        webRecommendedCategory: webRecommendedCategory ?? this.webRecommendedCategory,
        isStopWhatsappMessages: isStopWhatsappMessages ?? this.isStopWhatsappMessages,
        isUseWhatsappForOtp: isUseWhatsappForOtp ?? this.isUseWhatsappForOtp,
        lastActivityDatetime: lastActivityDatetime ?? this.lastActivityDatetime,
        lastActivityType: lastActivityType ?? this.lastActivityType,
        invitedContacts: invitedContacts ?? this.invitedContacts,
        deviceId: deviceId ?? this.deviceId,
        lastOtpIdToken: lastOtpIdToken ?? this.lastOtpIdToken,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    fName: json["f_name"],
    lName: json["l_name"],
    phone: json["phone"],
    image: json["image"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    streetAddress: json["street_address"],
    country: json["country"],
    city: json["city"],
    zip: json["zip"],
    houseNo: json["house_no"],
    apartmentNo: json["apartment_no"],
    cmFirebaseToken: json["cm_firebase_token"],
    isActive: json["is_active"],
    paymentCardLastFour: json["payment_card_last_four"],
    paymentCardBrand: json["payment_card_brand"],
    paymentCardFawryToken: json["payment_card_fawry_token"],
    loginMedium: json["login_medium"],
    socialId: json["social_id"],
    isPhoneVerified: json["is_phone_verified"],
    temporaryToken: json["temporary_token"],
    isEmailVerified: json["is_email_verified"],
    walletBalance: json["wallet_balance"],
    loyaltyPoint: json["loyalty_point"],
    hasTempOrder: json["has_temp_order"],
    isGuest: json["is_guest"],
    countryDialCode: json["country_dial_code"],
    categories: json["categories"],
    updatedAtCategories: json["updated_at_categories"] == null ? null : DateTime.parse(json["updated_at_categories"]),
    isTester: json["is_tester"],
    addedByAdminId: json["added_by_admin_id"],
    isValidWhatsappNumber: json["is_valid_whatsapp_number"],
    applicationRecommendedCategory: json["application_recommended_category"],
    webRecommendedCategory: json["web_recommended_category"],
    isStopWhatsappMessages: json["is_stop_whatsapp_messages"],
    isUseWhatsappForOtp: json["is_use_whatsapp_for_otp"],
    lastActivityDatetime: json["last_activity_datetime"],
    lastActivityType: json["last_activity_type"],
    invitedContacts: json["invited_contacts"],
    deviceId: json["device_id"],
    lastOtpIdToken: json["last_otp_id_token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "f_name": fName,
    "l_name": lName,
    "phone": phone,
    "image": image,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "street_address": streetAddress,
    "country": country,
    "city": city,
    "zip": zip,
    "house_no": houseNo,
    "apartment_no": apartmentNo,
    "cm_firebase_token": cmFirebaseToken,
    "is_active": isActive,
    "payment_card_last_four": paymentCardLastFour,
    "payment_card_brand": paymentCardBrand,
    "payment_card_fawry_token": paymentCardFawryToken,
    "login_medium": loginMedium,
    "social_id": socialId,
    "is_phone_verified": isPhoneVerified,
    "temporary_token": temporaryToken,
    "is_email_verified": isEmailVerified,
    "wallet_balance": walletBalance,
    "loyalty_point": loyaltyPoint,
    "has_temp_order": hasTempOrder,
    "is_guest": isGuest,
    "country_dial_code": countryDialCode,
    "categories": categories,
    "updated_at_categories": updatedAtCategories?.toIso8601String(),
    "is_tester": isTester,
    "added_by_admin_id": addedByAdminId,
    "is_valid_whatsapp_number": isValidWhatsappNumber,
    "application_recommended_category": applicationRecommendedCategory,
    "web_recommended_category": webRecommendedCategory,
    "is_stop_whatsapp_messages": isStopWhatsappMessages,
    "is_use_whatsapp_for_otp": isUseWhatsappForOtp,
    "last_activity_datetime": lastActivityDatetime,
    "last_activity_type": lastActivityType,
    "invited_contacts": invitedContacts,
    "device_id": deviceId,
    "last_otp_id_token": lastOtpIdToken,
  };
}
