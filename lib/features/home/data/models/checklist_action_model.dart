import 'dart:convert';

ChecklistActionModel checklistActionModelFromJson(String str) =>
    ChecklistActionModel.fromJson(json.decode(str));

String checklistActionModelToJson(ChecklistActionModel data) =>
    json.encode(data.toJson());

/// Response shape shared by `POST /checklist` and `DELETE /checklist/{id}`.
/// Both return `data: null`, so only the envelope matters.
class ChecklistActionModel {
  final bool? isSuccessful;
  final int? code;
  final bool? hasContent;
  final String? message;
  final String? detailedError;

  ChecklistActionModel({
    this.isSuccessful,
    this.code,
    this.hasContent,
    this.message,
    this.detailedError,
  });

  ChecklistActionModel copyWith({
    bool? isSuccessful,
    int? code,
    bool? hasContent,
    String? message,
    String? detailedError,
  }) => ChecklistActionModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    code: code ?? this.code,
    hasContent: hasContent ?? this.hasContent,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
  );

  factory ChecklistActionModel.fromJson(Map<String, dynamic> json) =>
      ChecklistActionModel(
        isSuccessful: json["isSuccessful"],
        code: json["code"],
        hasContent: json["hasContent"],
        message: json["message"],
        detailedError: json["detailed_error"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "code": code,
    "hasContent": hasContent,
    "message": message,
    "detailed_error": detailedError,
  };
}
