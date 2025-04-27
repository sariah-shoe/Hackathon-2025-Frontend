// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'tokens': instance.tokens,
    };
