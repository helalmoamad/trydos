import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

const int kPageSize = 10;

enum PaginationStatus { initial, success, failure, loading }
@JsonSerializable(genericArgumentFactories: true , explicitToJson: true)
class PaginationModel<T> {
  const PaginationModel.init({
    this.items = const [],
    this.page = 0,
    this.paginationStatus = PaginationStatus.initial,
    this.hasReachedMax = false,
  });

  const PaginationModel({
    required this.items,
    required this.page,
    required this.paginationStatus,
    required this.hasReachedMax,
  });

  final List<T> items;
  final PaginationStatus paginationStatus;
  final int page;
  final bool hasReachedMax;

  PaginationModel<T> copyWith({
    List<T>? items,
    PaginationStatus? paginationStatus,
    int? page,
    bool? hasReachedMax,
  }) {
    return PaginationModel(
      items: items ?? this.items,
      paginationStatus: paginationStatus ?? this.paginationStatus,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  factory PaginationModel.fromJson(Map<String,dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PaginationModelFromJson<T>(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T) toJsonT) =>
      _$PaginationModelToJson<T>(this, toJsonT);

  bool get isLoading => paginationStatus == PaginationStatus.initial;

  bool get isFailure => paginationStatus == PaginationStatus.failure;

  bool get isSuccess => paginationStatus == PaginationStatus.success;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaginationModel<T>) return false;

    return other.items == items &&
        other.paginationStatus == paginationStatus &&
        other.page == page &&
        other.hasReachedMax == hasReachedMax;
  }

  @override
  int get hashCode =>
      items.hashCode ^
      paginationStatus.hashCode ^
      page.hashCode ^
      hasReachedMax.hashCode;
}
