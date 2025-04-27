import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/base_widgets.dart';
import '../../../core/widgets/responsive_widgets.dart';
import '../../../core/utils/responsive_utils.dart';

class ActivityItem {
  final String clientName;
  final String action;
  final DateTime timestamp;

  const ActivityItem({
    required this.clientName,
    required this.action,
    required this.timestamp,
  });
}

class ActivityFeed extends StatelessWidget {
  final List<ActivityItem> activities;
  final int maxItems;

  const ActivityFeed({
    super.key,
    required this.activities,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayedActivities = activities.take(maxItems).toList();
    final spacing = ResponsiveUtils.spacing(context);

    return BaseCard(
      child: Padding(
        padding: ResponsiveUtils.padding(context) / 4,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                          fontWeight: FontWeight.bold,
                        ),
                    softWrap: true,
                  ),
                ),
                if (activities.length > maxItems)
                  TextButton(
                    onPressed: () {
                      // TODO: Implement view all action
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 8),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: spacing / 4),
            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: displayedActivities.length,
              itemBuilder: (context, index) {
                final activity = displayedActivities[index];
                return BaseListTile(
                  title: activity.clientName,
                  subtitle: activity.action,
                  leading: CircleAvatar(
                    radius: ResponsiveUtils.fontSize(context, 8),
                    backgroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    child: Text(
                      activity.clientName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 8),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
