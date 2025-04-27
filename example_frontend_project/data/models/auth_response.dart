import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ironiq/data/models/user_model.dart';
import 'package:ironiq/data/models/token_pair.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse extends Equatable {
  final UserModel user;
  final TokenPair tokens;

  const AuthResponse({
    required this.user,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  List<Object?> get props => [user, tokens];
} 