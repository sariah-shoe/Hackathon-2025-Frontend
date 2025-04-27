import 'package:json_annotation/json_annotation.dart';
import 'package:ironiq/domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  @JsonKey(name: 'user_id')
  @override
  final String id;

  @override
  final String email;

  @JsonKey(name: 'first_name')
  @override
  final String firstName;

  @JsonKey(name: 'last_name')
  @override
  final String lastName;

  @override
  final String? role;

  @JsonKey(name: 'created_at')
  @override
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  @override
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    String? firstName,
    String? lastName,
    this.role = 'client',
    this.createdAt,
    this.updatedAt,
  })  : firstName = firstName ?? '',
        lastName = lastName ?? '',
        super(
          id: id,
          email: email,
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          role: role,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromRegistrationResponse(
    Map<String, dynamic> json, {
    required String email,
    String? firstName,
    String? lastName,
  }) {
    return UserModel(
      id: json['user_id'] as String,
      email: email,
      firstName: firstName ?? json['first_name'] as String? ?? '',
      lastName: lastName ?? json['last_name'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
