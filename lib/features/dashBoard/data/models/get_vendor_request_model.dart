import 'dart:convert';

GetVendorRequestModel getVendorRequestModelFromJson(String str) =>
    GetVendorRequestModel.fromJson(json.decode(str));

String getVendorRequestModelToJson(GetVendorRequestModel data) =>
    json.encode(data.toJson());

class GetVendorRequestModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final VendorRequestData? data;

  GetVendorRequestModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  factory GetVendorRequestModel.fromJson(Map<String, dynamic> json) {
    return GetVendorRequestModel(
      isSuccessful: json["isSuccessful"],
      hasContent: json["hasContent"],
      code: json["code"],
      message: json["message"],
      detailedError: json["detailed_error"],
      data: json["data"] == null
          ? null
          : VendorRequestData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": data?.toJson(),
      };
}

class VendorRequestData {
  final int? id;
  final String? name;
  final String? lName;
  final String? email;
  final String? phone;
  final String? currencyCode;
  final String? languageCode;
  final String? countryIso;
  final String? shopName;
  final String? shopAddress;
  final String? locationCountryIso;
  final String? locationName;
  final String? locationAddress;
  final String? latitude;
  final String? longitude;
  final List<VendorDocument>? documents;
  final String? status;

  VendorRequestData({
    this.id,
    this.name,
    this.lName,
    this.email,
    this.phone,
    this.currencyCode,
    this.languageCode,
    this.countryIso,
    this.shopName,
    this.shopAddress,
    this.locationCountryIso,
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.documents,
    this.status,
  });

  factory VendorRequestData.fromJson(Map<String, dynamic> json) {
    return VendorRequestData(
      id: json["id"],
      name: json["name"],
      lName: json["l_name"],
      email: json["email"],
      phone: json["phone"],
      currencyCode: json["currency_code"],
      languageCode: json["language_code"],
      countryIso: json["country_iso"],
      shopName: json["shop_name"],
      shopAddress: json["shop_address"],
      locationCountryIso: json["location_country_iso"],
      locationName: json["location_name"],
      locationAddress: json["location_address"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      documents: json["documents"] == null
          ? null
          : List<VendorDocument>.from(
              json["documents"].map((x) => VendorDocument.fromJson(x))),
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "l_name": lName,
        "email": email,
        "phone": phone,
        "currency_code": currencyCode,
        "language_code": languageCode,
        "country_iso": countryIso,
        "shop_name": shopName,
        "shop_address": shopAddress,
        "location_country_iso": locationCountryIso,
        "location_name": locationName,
        "location_address": locationAddress,
        "latitude": latitude,
        "longitude": longitude,
        "documents": documents == null
            ? null
            : List<dynamic>.from(documents!.map((x) => x.toJson())),
        "status": status,
      };
}

class VendorDocument {
  final int? id;
  final int? vendorRequestId;
  final String? type;
  final String? path;
  final String? url;

  VendorDocument({
    this.id,
    this.vendorRequestId,
    this.type,
    this.path,
    this.url,
  });

  factory VendorDocument.fromJson(Map<String, dynamic> json) {
    return VendorDocument(
      id: json["id"],
      vendorRequestId: json["vendor_request_id"],
      type: json["type"],
      path: json["path"],
      url: json["url"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "vendor_request_id": vendorRequestId,
        "type": type,
        "path": path,
        "url": url,
      };
}
