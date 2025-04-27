import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/widgets/base_widgets.dart';
import '../../domain/models/exercise.dart';
import '../widgets/exercise_image_viewer.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Muscle Visualization Section
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 300.h,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 16.r, right: 16.r, bottom: 8.r, top: 16.r),
                child: BaseCard(
                  child: ExerciseImageViewer(
                    imagePaths: exercise.images,
                  ),
                ),
              ),
            ),

            // Exercise Details
            Container(
              padding: EdgeInsets.only(
                  left: 16.r, right: 16.r, bottom: 16.r, top: 8.r),
              child: BaseCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: theme.textTheme.titleLarge,
                    ),
                    SizedBox(height: 8.h),
                    ...exercise.instructions.map((step) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.circle, size: 8.r),
                              SizedBox(width: 8.w),
                              Text(step),
                            ],
                          ),
                        )),
                    SizedBox(height: 16.h),
                    Text(
                      'Details',
                      style: theme.textTheme.titleLarge,
                    ),
                    SizedBox(height: 8.h),
                    if (exercise.equipment != null)
                      BaseListTile(
                        leading: Icon(Icons.fitness_center),
                        title: 'Equipment',
                        subtitle: exercise.equipment,
                      ),
                    BaseListTile(
                      leading: Icon(Icons.speed),
                      title: 'Level',
                      subtitle: exercise.level,
                    ),
                    if (exercise.mechanic != null)
                      BaseListTile(
                        leading: Icon(Icons.architecture),
                        title: 'Mechanic',
                        subtitle: exercise.mechanic,
                      ),
                    BaseListTile(
                      leading: Icon(Icons.category),
                      title: 'Category',
                      subtitle: exercise.category,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
