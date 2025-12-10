// To parse this JSON data, do
//
//     final translateCommentModel = translateCommentModelFromJson(jsonString);

import 'dart:convert';

TranslateCommentModel translateCommentModelFromJson(String str) =>
    TranslateCommentModel.fromJson(json.decode(str));

String translateCommentModelToJson(TranslateCommentModel data) =>
    json.encode(data.toJson());

class TranslateCommentModel {
  final String? commentId;
  final String? originalText;
  final String? translatedText;
  final String? targetLanguage;
  final String? detectedLanguage;
  final bool? fromCache;
  final bool? isOriginalLanguage;
  final String? translateType;

  TranslateCommentModel({
    this.commentId,
    this.originalText,
    this.translatedText,
    this.targetLanguage,
    this.detectedLanguage,
    this.fromCache,
    this.isOriginalLanguage,
    this.translateType,
  });

  TranslateCommentModel copyWith({
    String? commentId,
    String? originalText,
    String? translatedText,
    String? targetLanguage,
    String? detectedLanguage,
    bool? fromCache,
    bool? isOriginalLanguage,
    String? translateType,
  }) => TranslateCommentModel(
    commentId: commentId ?? this.commentId,
    originalText: originalText ?? this.originalText,
    translatedText: translatedText ?? this.translatedText,
    targetLanguage: targetLanguage ?? this.targetLanguage,
    detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    fromCache: fromCache ?? this.fromCache,
    isOriginalLanguage: isOriginalLanguage ?? this.isOriginalLanguage,
    translateType: translateType ?? this.translateType,
  );

  factory TranslateCommentModel.fromJson(Map<String, dynamic> json) =>
      TranslateCommentModel(
        commentId: json["comment_id"],
        originalText: json["original_text"],
        translatedText: json["translated_text"],
        targetLanguage: json["target_language"],
        detectedLanguage: json["detected_language"],
        fromCache: json["from_cache"],
        isOriginalLanguage: json["is_original_language"],
        translateType: json["translate_type"],
      );

  Map<String, dynamic> toJson() => {
    "comment_id": commentId,
    "original_text": originalText,
    "translated_text": translatedText,
    "target_language": targetLanguage,
    "detected_language": detectedLanguage,
    "from_cache": fromCache,
    "is_original_language": isOriginalLanguage,
    "translate_type": translateType,
  };
}
