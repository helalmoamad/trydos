import 'dart:convert';

ChecklistExistModel checklistExistModelFromJson(String str) =>
    ChecklistExistModel.fromJson(json.decode(str));

String checklistExistModelToJson(ChecklistExistModel data) =>
    json.encode(data.toJson());

class ChecklistExistModel {
  final bool? isSuccessful;
  final int? code;
  final bool? hasContent;
  final String? message;
  final String? detailedError;
  final ChecklistExistData? data;

  ChecklistExistModel({
    this.isSuccessful,
    this.code,
    this.hasContent,
    this.message,
    this.detailedError,
    this.data,
  });

  ChecklistExistModel copyWith({
    bool? isSuccessful,
    int? code,
    bool? hasContent,
    String? message,
    String? detailedError,
    ChecklistExistData? data,
  }) => ChecklistExistModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    code: code ?? this.code,
    hasContent: hasContent ?? this.hasContent,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory ChecklistExistModel.fromJson(Map<String, dynamic> json) =>
      ChecklistExistModel(
        isSuccessful: json["isSuccessful"],
        code: json["code"],
        hasContent: json["hasContent"],
        message: json["message"],
        detailedError: json["detailed_error"]?.toString(),
        data: json["data"] == null
            ? null
            : ChecklistExistData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "code": code,
    "hasContent": hasContent,
    "message": message,
    "detailed_error": detailedError,
    "data": data?.toJson(),
  };

  bool get isExist => data?.isExist ?? false;
}

class ChecklistExistData {
  final bool? isExist;

  ChecklistExistData({this.isExist});

  ChecklistExistData copyWith({bool? isExist}) =>
      ChecklistExistData(isExist: isExist ?? this.isExist);

  factory ChecklistExistData.fromJson(Map<String, dynamic> json) =>
      ChecklistExistData(isExist: json["is_exist"]);

  Map<String, dynamic> toJson() => {"is_exist": isExist};
}
