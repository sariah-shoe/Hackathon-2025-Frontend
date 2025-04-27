import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token_pair.g.dart';

@JsonSerializable()
class TokenPair extends Equatable {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPairToJson(this);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
} 