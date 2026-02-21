// To parse this JSON data, do
//
//     final responseOnlyMessageModel = responseOnlyMessageModelFromJson(jsonString);

import 'dart:convert';

GetListOfCustomerAddressesInfoModel responseOnlyMessageModelFromJson(
        String str) =>
    GetListOfCustomerAddressesInfoModel.fromJson(json.decode(str));

String responseOnlyMessageModelToJson(
        GetListOfCustomerAddressesInfoModel data) =>
    json.encode(data.toJson());

class GetListOfCustomerAddressesInfoModel {
  final String? message;
  final List<CustomerAddressesInfo>? data;

  GetListOfCustomerAddressesInfoModel({
    this.message,
    this.data,
  });

  GetListOfCustomerAddressesInfoModel copyWith({
    String? message,
    List<CustomerAddressesInfo>? data,
  }) =>
      GetListOfCustomerAddressesInfoModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetListOfCustomerAddressesInfoModel.fromJson(
          Map<String, dynamic> json) =>
      GetListOfCustomerAddressesInfoModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<CustomerAddressesInfo>.from(
                json["data"]!.map((x) => CustomerAddressesInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CustomerAddressesInfo {
  final int? id;
  final Location? location;
  final RegionDetails? regionDetails;
  final String? address;
  final String? addressDetail;
  final ContactInfo? contactInfo;
  final int? isDefault;

  final String? iso;
  CustomerAddressesInfo({
    this.id,
    this.location,
    this.regionDetails,
    this.address,
    this.iso,
    this.addressDetail,
    this.contactInfo,
    this.isDefault,
  });

  CustomerAddressesInfo copyWith({
    int? id,
    Location? location,
    RegionDetails? regionDetails,
    String? address,
    String? addressDetail,
    String? iso,
    ContactInfo? contactInfo,
    int? isDefault,
  }) =>
      CustomerAddressesInfo(
        id: id ?? this.id,
        iso: iso ?? this.iso,
        location: location ?? this.location,
        regionDetails: regionDetails ?? this.regionDetails,
        address: address ?? this.address,
        addressDetail: addressDetail ?? this.addressDetail,
        contactInfo: contactInfo ?? this.contactInfo,
        isDefault: isDefault ?? this.isDefault,
      );

  factory CustomerAddressesInfo.fromJson(Map<String, dynamic> json) =>
      CustomerAddressesInfo(
        id: json["id"],
        iso: json["iso"],
        isDefault: json["is_default"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        regionDetails: json["region_details"] == null
            ? null
            : RegionDetails.fromJson(json["region_details"]),
        address: json["address"],
        addressDetail: json["address_detail"],
        contactInfo: json["contact_info"] == null
            ? null
            : ContactInfo.fromJson(json["contact_info"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "iso": iso,
        "location": location?.toJson(),
        "region_details": regionDetails?.toJson(),
        "address": address,
        "address_detail": addressDetail,
        "contact_info": contactInfo?.toJson(),
        "is_default": isDefault,
      };
}

class ContactInfo {
  final String? name;
  final String? phone;
  final String? alternativePhone;

  ContactInfo({
    this.name,
    this.phone,
    this.alternativePhone,
  });

  ContactInfo copyWith({
    String? name,
    String? phone,
    String? alternativePhone,
  }) =>
      ContactInfo(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        alternativePhone: alternativePhone ?? this.alternativePhone,
      );

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
        name: json["name"],
        phone: json["phone"],
        alternativePhone: json["alternative_phone"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "alternative_phone": alternativePhone,
      };
}

class Location {
  final String? latitude;
  final String? longitude;

  Location({
    this.latitude,
    this.longitude,
  });

  Location copyWith({
    String? latitude,
    String? longitude,
  }) =>
      Location(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

class RegionDetails {
  final String? country;
  final String? province;
  final String? city;
  final String? town;
  final String? street;
  final String? building;
  final String? zip;

  RegionDetails({
    this.country,
    this.province,
    this.city,
    this.town,
    this.zip,
    this.street,
    this.building,
  });

  RegionDetails copyWith({
    String? country,
    String? province,
    String? city,
    String? town,
    String? street,
    String? building,
    String? zip,
  }) =>
      RegionDetails(
          country: country ?? this.country,
          province: province ?? this.province,
          city: city ?? this.city,
          town: town ?? this.town,
          street: street ?? this.street,
          building: building ?? this.building,
          zip: zip ?? this.zip);

  factory RegionDetails.fromJson(Map<String, dynamic> json) => RegionDetails(
        country: json["country"],
        province: json["province"],
        city: json["city"],
        town: json["town"],
        zip: json["zip"],
        street: json["street"],
        building: json["building"],
      );

  Map<String, dynamic> toJson() => {
        "country": country,
        "province": province,
        "city": city,
        "town": town,
        "zip": zip,
        "street": street,
        "building": building,
      };
}
