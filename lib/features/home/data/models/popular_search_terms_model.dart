// To parse this JSON data, do
//
//     final popularSearchTermsModel = popularSearchTermsModelFromJson(jsonString);

import 'dart:convert';

PopularSearchTermsModel popularSearchTermsModelFromJson(String str) =>
    PopularSearchTermsModel.fromJson(json.decode(str));

String popularSearchTermsModelToJson(PopularSearchTermsModel data) =>
    json.encode(data.toJson());

class PopularSearchTermsModel {
  final List<PopularSearchTerm>? popularSearchTerms;

  PopularSearchTermsModel({
    this.popularSearchTerms,
  });

  PopularSearchTermsModel copyWith({
    List<PopularSearchTerm>? popularSearchTerms,
  }) =>
      PopularSearchTermsModel(
        popularSearchTerms: popularSearchTerms ?? this.popularSearchTerms,
      );

  factory PopularSearchTermsModel.fromJson(Map<String, dynamic> json) =>
      PopularSearchTermsModel(
        popularSearchTerms: json["popular_search_terms"] == null
            ? []
            : List<PopularSearchTerm>.from(json["popular_search_terms"]!
                .map((x) => PopularSearchTerm.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "popular_search_terms": popularSearchTerms == null
            ? []
            : List<dynamic>.from(popularSearchTerms!.map((x) => x.toJson())),
      };
}

class PopularSearchTerm {
  final String? term;
  final int? count;

  PopularSearchTerm({
    this.term,
    this.count,
  });

  PopularSearchTerm copyWith({
    String? term,
    int? count,
  }) =>
      PopularSearchTerm(
        term: term ?? this.term,
        count: count ?? this.count,
      );

  factory PopularSearchTerm.fromJson(Map<String, dynamic> json) =>
      PopularSearchTerm(
        term: json["term"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "term": term,
        "count": count,
      };
}
