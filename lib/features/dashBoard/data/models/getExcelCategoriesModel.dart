import 'dart:convert';

GetExcelCategoriesModel getExcelCategoriesModelFromJson(String str) =>
    GetExcelCategoriesModel.fromJson(json.decode(str));

String getExcelCategoriesModelToJson(GetExcelCategoriesModel data) =>
    json.encode(data.toJson());

class GetExcelCategoriesModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final List<ExcelCategories> data;

  GetExcelCategoriesModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data = const [],
  });

  GetExcelCategoriesModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    List<ExcelCategories>? data,
  }) {
    return GetExcelCategoriesModel(
      isSuccessful: isSuccessful ?? this.isSuccessful,
      hasContent: hasContent ?? this.hasContent,
      code: code ?? this.code,
      message: message ?? this.message,
      detailedError: detailedError ?? this.detailedError,
      data: data ?? this.data,
    );
  }

  factory GetExcelCategoriesModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return GetExcelCategoriesModel(
      isSuccessful: json['isSuccessful'] ?? json['success'],
      hasContent: json['hasContent'],
      code: json['code'],
      message: json['message'],
      detailedError: json['detailed_error'],

      data: rawData is List
          ? rawData
              .map(
                (e) => ExcelCategories.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccessful': isSuccessful,
      'hasContent': hasContent,
      'code': code,
      'message': message,
      'detailed_error': detailedError,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ExcelCategories {
  final int? id;
  final String? name;
  final String? displayName;
  final int? level;

  ExcelCategories({
    this.id,
    this.name,
    this.displayName,
    this.level,
  });

  ExcelCategories copyWith({
    int? id,
    String? name,
    String? displayName,
    int? level,
  }) {
    return ExcelCategories(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
    );
  }

  factory ExcelCategories.fromJson(Map<String, dynamic> json) {
    return ExcelCategories(
      id: json['id'] is int
          ? json['id']
          : int.tryParse('${json['id']}'),

      name: json['name']?.toString(),

      displayName:
          json['display_name']?.toString() ??
          json['title']?.toString(),

      level: json['level'] is int
          ? json['level']
          : int.tryParse('${json['level']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'level': level,
    };
  }
}