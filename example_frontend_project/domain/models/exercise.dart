import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

@JsonSerializable()
class Exercise {
  final String id;
  final String name;
  final String? force;
  final String level;
  final String? mechanic;
  final String? equipment;
  @JsonKey(name: 'primaryMuscles')
  final List<String> primaryMuscles;
  @JsonKey(name: 'secondaryMuscles')
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String category;
  final List<String> images;

  const Exercise({
    required this.id,
    required this.name,
    this.force,
    required this.level,
    this.mechanic,
    this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.images,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowercaseQuery) ||
        equipment?.toLowerCase().contains(lowercaseQuery) == true ||
        primaryMuscles
            .any((muscle) => muscle.toLowerCase().contains(lowercaseQuery)) ||
        secondaryMuscles
            .any((muscle) => muscle.toLowerCase().contains(lowercaseQuery)) ||
        category.toLowerCase().contains(lowercaseQuery);
  }

  List<String> getAllMuscles() {
    return {...primaryMuscles, ...secondaryMuscles}.toList();
  }
}
