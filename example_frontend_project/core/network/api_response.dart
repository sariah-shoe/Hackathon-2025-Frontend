import 'package:json_annotation/json_annotation.dart';
import '../utils/type_defs.dart';

part 'api_response.g.dart';

/// Base API response model
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, List<String>>? errors;
  final Meta? meta;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Json json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Json toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// Creates a successful response
  static ApiResponse<T> successfulResponse<T>({
    required T data,
    String message = 'Success',
    Meta? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      meta: meta,
    );
  }

  /// Creates an error response
  static ApiResponse<T> error<T>({
    required String message,
    Map<String, List<String>>? errors,
    T? data,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      data: data,
    );
  }
}

/// Pagination and metadata
@JsonSerializable()
class Meta {
  final Pagination? pagination;
  final Map<String, dynamic>? extra;

  const Meta({
    this.pagination,
    this.extra,
  });

  factory Meta.fromJson(Json json) => _$MetaFromJson(json);

  Json toJson() => _$MetaToJson(this);
}

/// Pagination information
@JsonSerializable()
class Pagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int from;
  final int to;

  const Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory Pagination.fromJson(Json json) => _$PaginationFromJson(json);

  Json toJson() => _$PaginationToJson(this);
}
