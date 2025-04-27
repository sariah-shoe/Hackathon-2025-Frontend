import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, email, firstName, lastName, role, createdAt, updatedAt];
}
