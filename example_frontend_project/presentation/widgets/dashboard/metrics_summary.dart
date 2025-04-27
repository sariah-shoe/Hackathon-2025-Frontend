import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/base_widgets.dart';
import '../../../core/utils/responsive_utils.dart';

class MetricsSummary extends StatelessWidget {
  final int activeClients;
  final int totalSessions;
  final double revenue;

  const MetricsSummary({
    super.key,
    required this.activeClients,
    required this.totalSessions,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.spacing(context);

    return BaseCard(
      child: Padding(
        padding: ResponsiveUtils.padding(context) / 4,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context) / 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: ResponsiveUtils.isDesktop(context) ? 2 : 1,
                mainAxisSpacing: spacing / 4,
                crossAxisSpacing: spacing / 4,
                shrinkWrap: true,
                children: [
                  _buildMetricItem(
                    context,
                    'Active Clients',
                    activeClients.toString(),
                    Icons.people,
                  ),
                  _buildMetricItem(
                    context,
                    'Total Sessions',
                    totalSessions.toString(),
                    Icons.calendar_today,
                  ),
                  _buildMetricItem(
                    context,
                    'Revenue',
                    '\$${revenue.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
      BuildContext context, String label, String value, IconData icon) {
    final iconSize = ResponsiveUtils.responsiveIconSize(context) / 3;

    final valueStyle = TextStyle(
      fontSize: ResponsiveUtils.fontSize(context, 12),
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );

    final labelStyle = TextStyle(
      fontSize: ResponsiveUtils.fontSize(context, 8),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: ResponsiveUtils.radius(context),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          Text(
            value,
            style: valueStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
