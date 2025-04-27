import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/widgets/base_widgets.dart';
import '../../core/utils/responsive_utils.dart';
import '../../domain/models/exercise.dart';
import '../../data/services/exercise_service.dart';
import '../widgets/exercise_card.dart';

class ExerciseBrowserScreen extends StatefulWidget {
  final bool enableDragAndDrop;
  final Function(Exercise)? onExerciseSelected;

  const ExerciseBrowserScreen({
    super.key,
    this.enableDragAndDrop = true,
    this.onExerciseSelected,
  });

  @override
  State<ExerciseBrowserScreen> createState() => _ExerciseBrowserScreenState();
}

class _ExerciseBrowserScreenState extends State<ExerciseBrowserScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedMuscleGroup;
  String? _selectedEquipment;
  String? _selectedLevel;
  final Set<Exercise> _selectedExercises = {};
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final exercises = await ExerciseService.instance.loadExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exercises: $e')),
        );
      }
    }
  }

  List<Exercise> get _filteredExercises {
    return _exercises.where((exercise) {
      if (_searchQuery.isNotEmpty && !exercise.matchesSearch(_searchQuery)) {
        return false;
      }

      if (_selectedMuscleGroup != null &&
          !exercise.getAllMuscles().any((muscle) =>
              muscle.toLowerCase() == _selectedMuscleGroup!.toLowerCase())) {
        return false;
      }

      if (_selectedEquipment != null &&
          exercise.equipment?.toLowerCase() !=
              _selectedEquipment!.toLowerCase()) {
        return false;
      }

      if (_selectedLevel != null &&
          exercise.level.toLowerCase() != _selectedLevel!.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  Set<String> get _uniqueMuscleGroups {
    return _exercises
        .expand((e) => e.getAllMuscles())
        .map((e) => e.toLowerCase())
        .toSet();
  }

  Set<String> get _uniqueEquipment {
    return _exercises
        .where((e) => e.equipment != null)
        .map((e) => e.equipment!.toLowerCase())
        .toSet();
  }

  Set<String> get _uniqueLevels {
    return _exercises.map((e) => e.level.toLowerCase()).toSet();
  }

  void _toggleExerciseSelection(Exercise exercise) {
    setState(() {
      if (_selectedExercises.contains(exercise)) {
        _selectedExercises.remove(exercise);
      } else {
        _selectedExercises.add(exercise);
      }
    });

    if (widget.onExerciseSelected != null) {
      widget.onExerciseSelected!(exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    bool isGridView = !isLandscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                BaseTextField(
                  controller: _searchController,
                  hint: 'Search exercises...',
                  prefixIcon: Icons.search,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                SizedBox(height: 16.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      BaseFilterChip(
                        label: _selectedMuscleGroup ?? 'Muscle Group',
                        selected: _selectedMuscleGroup != null,
                        onSelected: (_) => _showFilterPicker(
                          'Select Muscle Group',
                          _uniqueMuscleGroups.toList(),
                          (value) =>
                              setState(() => _selectedMuscleGroup = value),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      BaseFilterChip(
                        label: _selectedEquipment ?? 'Equipment',
                        selected: _selectedEquipment != null,
                        onSelected: (_) => _showFilterPicker(
                          'Select Equipment',
                          _uniqueEquipment.toList(),
                          (value) => setState(() => _selectedEquipment = value),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      BaseFilterChip(
                        label: _selectedLevel ?? 'Level',
                        selected: _selectedLevel != null,
                        onSelected: (_) => _showFilterPicker(
                          'Select Level',
                          _uniqueLevels.toList(),
                          (value) => setState(() => _selectedLevel = value),
                        ),
                      ),
                      if (_selectedMuscleGroup != null ||
                          _selectedEquipment != null ||
                          _selectedLevel != null) ...[
                        SizedBox(width: 8.w),
                        BaseChip(
                          label: 'Clear Filters',
                          onTap: () => setState(() {
                            _selectedMuscleGroup = null;
                            _selectedEquipment = null;
                            _selectedLevel = null;
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Exercise Grid/List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExercises.isEmpty
                    ? const Center(
                        child: Text('No exercises found'),
                      )
                    : isGridView
                        ? GridView.builder(
                            padding: EdgeInsets.all(16.r),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isLandscape ? 3 : 2,
                              childAspectRatio: 0.80,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                            ),
                            itemCount: _filteredExercises.length,
                            itemBuilder: (context, index) {
                              final exercise = _filteredExercises[index];
                              return ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 300.w,
                                ),
                                child: ExerciseCard(
                                  exercise: exercise,
                                  isDraggable: widget.enableDragAndDrop,
                                  isSelected:
                                      _selectedExercises.contains(exercise),
                                  onTap: () =>
                                      _toggleExerciseSelection(exercise),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16.r),
                            itemCount: _filteredExercises.length,
                            itemBuilder: (context, index) {
                              final exercise = _filteredExercises[index];
                              return ExerciseCard(
                                exercise: exercise,
                                isDraggable: widget.enableDragAndDrop,
                                isSelected:
                                    _selectedExercises.contains(exercise),
                                onTap: () => _toggleExerciseSelection(exercise),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showFilterPicker(
    String title,
    List<String> items,
    Function(String?) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    onSelected(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
