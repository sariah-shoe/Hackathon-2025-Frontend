import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/exercise.dart';

class ExerciseService {
  static const _exercisesPath = 'assets/data/exercises.json';
  static ExerciseService? _instance;
  List<Exercise>? _exercises;

  // Private constructor
  ExerciseService._();

  // Singleton instance
  static ExerciseService get instance {
    _instance ??= ExerciseService._();
    return _instance!;
  }

  // Load exercises from JSON file
  Future<List<Exercise>> loadExercises() async {
    if (_exercises != null) return _exercises!;

    try {
      final jsonString = await rootBundle.loadString(_exercisesPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      _exercises = jsonList.map((json) => Exercise.fromJson(json)).toList();

      return _exercises!;
    } catch (e) {
      print('Error loading exercises: $e');
      return [];
    }
  }

  // Get all exercises
  Future<List<Exercise>> getAllExercises() async {
    return await loadExercises();
  }

  // Search exercises by query
  Future<List<Exercise>> searchExercises(String query) async {
    final exercises = await loadExercises();
    if (query.isEmpty) return exercises;

    return exercises
        .where((exercise) => exercise.matchesSearch(query))
        .toList();
  }

  // Filter exercises by muscle group
  Future<List<Exercise>> getExercisesByMuscle(String muscle) async {
    final exercises = await loadExercises();
    return exercises
        .where((exercise) =>
            exercise.primaryMuscles.contains(muscle) ||
            exercise.secondaryMuscles.contains(muscle))
        .toList();
  }

  // Filter exercises by equipment
  Future<List<Exercise>> getExercisesByEquipment(String equipment) async {
    final exercises = await loadExercises();
    return exercises
        .where((exercise) =>
            exercise.equipment?.toLowerCase() == equipment.toLowerCase())
        .toList();
  }

  // Filter exercises by level
  Future<List<Exercise>> getExercisesByLevel(String level) async {
    final exercises = await loadExercises();
    return exercises
        .where(
            (exercise) => exercise.level.toLowerCase() == level.toLowerCase())
        .toList();
  }

  // Get unique values for different attributes
  Future<Set<String>> getUniqueMuscles() async {
    final exercises = await loadExercises();
    final muscles = <String>{};
    for (final exercise in exercises) {
      muscles.addAll(exercise.primaryMuscles);
      muscles.addAll(exercise.secondaryMuscles);
    }
    return muscles;
  }

  Future<Set<String>> getUniqueEquipment() async {
    final exercises = await loadExercises();
    return exercises
        .where((e) => e.equipment != null)
        .map((e) => e.equipment!)
        .toSet();
  }

  Future<Set<String>> getUniqueCategories() async {
    final exercises = await loadExercises();
    return exercises.map((e) => e.category).toSet();
  }

  Future<Set<String>> getUniqueLevels() async {
    final exercises = await loadExercises();
    return exercises.map((e) => e.level).toSet();
  }

  // Get exercise by ID
  Future<Exercise?> getExerciseById(String id) async {
    final exercises = await loadExercises();
    try {
      return exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get similar exercises based on muscle groups and equipment
  Future<List<(Exercise, double)>> getSimilarExercises(Exercise exercise,
      {int limit = 5}) async {
    final exercises = await loadExercises();
    final targetMuscles = exercise.getAllMuscles().toSet();

    final results = exercises
        .where((e) => e.id != exercise.id)
        .map((e) {
          final muscles = e.getAllMuscles().toSet();
          final commonMuscles = muscles.intersection(targetMuscles);
          final score = commonMuscles.length / targetMuscles.length;
          return (e, score);
        })
        .where((tuple) => tuple.$2 > 0)
        .toList();

    results.sort((a, b) => b.$2.compareTo(a.$2));

    return results.take(limit).toList();
  }
}
