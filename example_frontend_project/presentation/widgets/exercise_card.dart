import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/widgets/base_widgets.dart';
import '../../core/utils/responsive_utils.dart';
import '../../domain/models/exercise.dart';
import '../screens/exercise_detail_screen.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final bool isDraggable;
  final bool isSelected;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.isDraggable = true,
    this.isSelected = false,
  });

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExerciseDetailScreen(exercise: exercise),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = BaseCard(
      onTap: () => _handleTap(context),
      selected: isSelected,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(12.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Exercise Image with Caching
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 300.h,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.shadow,
                      width: 1.r,
                    ),
                    left: BorderSide(
                      color: theme.colorScheme.shadow,
                      width: 1.r,
                    ),
                    right: BorderSide(
                      color: theme.colorScheme.shadow,
                      width: 1.r,
                    ),
                  ),
                ),
                child: exercise.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(11.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/${exercise.images.first}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.fitness_center,
                            size: ResponsiveUtils.responsiveIconSize(context),
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.fitness_center,
                        size: ResponsiveUtils.responsiveIconSize(context),
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),

            // Exercise Details
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.shadow,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.shadow,
                            width: 1.r,
                          ),
                          left: BorderSide(
                            color: theme.colorScheme.shadow,
                            width: 1.r,
                          ),
                          right: BorderSide(
                            color: theme.colorScheme.shadow,
                            width: 1.r,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            exercise.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            exercise.primaryMuscles.join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: theme.colorScheme.shadow,
                        width: 1.r,
                      ),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (exercise.equipment != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: theme.colorScheme.shadow,
                                  width: 1.r,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: ResponsiveUtils.fontSize(context, 20),
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                  Text(
                                    exercise.equipment!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontSize:
                                          ResponsiveUtils.fontSize(context, 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: theme.colorScheme.shadow,
                                width: 1.r,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.signal_cellular_alt,
                                  size: ResponsiveUtils.fontSize(context, 20),
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                Text(
                                  exercise.level,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontSize:
                                        ResponsiveUtils.fontSize(context, 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Wrap with Draggable if enabled
    if (isDraggable) {
      return LongPressDraggable<Exercise>(
        data: exercise,
        feedback: SizedBox(
          width: 200.w,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12.r),
            child: card,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: card,
        ),
        child: card,
      );
    }

    return card;
  }
}
