import 'dart:convert';

ExcelUploadResponseModel excelUploadResponseModelFromJson(String str) =>
    ExcelUploadResponseModel.fromJson(json.decode(str));

String excelUploadResponseModelToJson(ExcelUploadResponseModel data) =>
    json.encode(data.toJson());

/// استجابة `POST /gated/upload/excel` — ملفات `.xlsx` و`.xls` و`.xlsm`
/// و`.xlsb` فقط، بحدّ أعلى 512 ميغابايت.
class ExcelUploadResponseModel {
  const ExcelUploadResponseModel({
    this.key,
    this.filename,
    this.originalName,
    this.contentType,
  });

  final String? key;
  final String? filename;
  final String? originalName;
  final String? contentType;

  factory ExcelUploadResponseModel.fromJson(Map<String, dynamic> json) =>
      ExcelUploadResponseModel(
        key: json["key"],
        filename: json["filename"],
        originalName: json["originalName"],
        contentType: json["contentType"],
      );

  Map<String, dynamic> toJson() => {
    "key": key,
    "filename": filename,
    "originalName": originalName,
    "contentType": contentType,
  };
}
