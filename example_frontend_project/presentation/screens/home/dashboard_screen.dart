import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ironiq/core/widgets/base_widgets.dart';
import 'package:ironiq/core/utils/responsive_utils.dart';
import 'package:ironiq/presentation/blocs/auth/auth_bloc.dart';
import 'package:ironiq/presentation/blocs/auth/auth_state.dart';
import 'package:ironiq/presentation/widgets/dashboard/metrics_summary.dart';
import 'package:ironiq/presentation/widgets/dashboard/activity_feed.dart';
import 'package:ironiq/presentation/widgets/dashboard/session_calendar.dart';
import 'package:ironiq/core/widgets/responsive_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return ResponsiveBuilder(
            builder: (context, deviceType, orientation) {
              final media = MediaQuery.of(context);
              final isLandscape =
                  ResponsiveUtils.getOrientationFromMedia(media);

              return _buildTabletDashboard(context, state);

              // Use deviceType from builder parameters
              if (isLandscape == OrientationType.landscape) {
                switch (deviceType) {
                  case DeviceType.mobile:
                    return _buildMobileLandscapeDashboard(context, state);
                  case DeviceType.tablet:
                    return _buildDesktopDashboard(context, state);
                  case DeviceType.desktop:
                    return _buildDesktopDashboard(context, state);
                }
              }

              // Handle portrait mode
              switch (deviceType) {
                case DeviceType.mobile:
                  return _buildMobileDashboard(context, state);
                case DeviceType.tablet:
                  return _buildTabletDashboard(context, state);
                case DeviceType.desktop:
                  return _buildDesktopDashboard(context, state);
              }
            },
          );
        }
        return const Center(child: BaseLoadingIndicator());
      },
    );
  }

  // Mobile layout with vertical scrolling (Portrait)
  Widget _buildMobileDashboard(BuildContext context, AuthAuthenticated state) {
    final spacing = ResponsiveUtils.spacing(context);

    return SingleChildScrollView(
      child: Padding(
        padding: ResponsiveUtils.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ResponsiveUtils.height(context, 0.15),
              ),
              child: _buildWelcomeSection(context, state),
            ),
            SizedBox(height: spacing),
            IntrinsicHeight(
              child: _buildTodayStats(context),
            ),
            SizedBox(height: spacing),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ResponsiveUtils.height(context, 0.15),
              ),
              child: _buildQuickActions(context),
            ),
            SizedBox(height: spacing),
            SizedBox(
              height: ResponsiveUtils.height(context, 0.55),
              child: _buildUpcomingSessions(context),
            ),
            SizedBox(height: spacing),
            SizedBox(
              height: ResponsiveUtils.height(context, 0.35),
              child: _buildRecentActivity(context),
            ),
            SizedBox(height: spacing),
            SizedBox(
              height: ResponsiveUtils.height(context, 0.4),
              child: _buildPerformanceMetrics(context),
            )
          ],
        ),
      ),
    );
  }

  // Mobile layout for landscape orientation
  Widget _buildMobileLandscapeDashboard(
      BuildContext context, AuthAuthenticated state) {
    final spacing = ResponsiveUtils.spacing(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final contentHeight = screenHeight * 0.85; // 85% of screen height

    return SingleChildScrollView(
      child: Padding(
        padding: ResponsiveUtils.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: contentHeight * 0.15, // 15% for welcome section
              child: _buildWelcomeSection(context, state),
            ),
            SizedBox(height: spacing),
            SizedBox(
              height: contentHeight * 0.35, // 35% for stats and actions
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildTodayStats(context),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: _buildQuickActions(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing),
            SizedBox(
              height: contentHeight * 0.35, // 35% for sessions
              child: _buildUpcomingSessions(context),
            ),
            SizedBox(height: spacing),
            SizedBox(
              height: contentHeight * 0.15, // 15% for activity and metrics
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildRecentActivity(context),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: _buildPerformanceMetrics(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tablet layout (Portrait)
Widget _buildTabletDashboard(BuildContext context, AuthAuthenticated state) {
  final spacing = ResponsiveUtils.spacing(context);

  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: Padding(
      padding: ResponsiveUtils.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // force children to fill width
        children: [
          SizedBox(height: spacing),
          SizedBox(
            height: ResponsiveUtils.height(context, 0.1),
            child: _buildWelcomeSection(context, state),
          ),
          SizedBox(height: spacing),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // force children to fill vertical space
              children: [
                // Left Column: Today Stats and Quick Actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildTodayStats(context)),
                      SizedBox(height: spacing),
                      Expanded(child: _buildQuickActions(context)),
                    ],
                  ),
                ),
                SizedBox(width: spacing),
                // Right Column: Upcoming Sessions on top & a row sharing space for Recent Activity & Performance Metrics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildUpcomingSessions(context)),
                      SizedBox(height: spacing),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildRecentActivity(context)),
                            SizedBox(width: spacing),
                            Expanded(child: _buildPerformanceMetrics(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing),
        ],
      ),
    ),
  );
}
  // Tablet layout for landscape orientation
  Widget _buildTabletLandscapeDashboard(
      BuildContext context, AuthAuthenticated state) {
    final spacing = ResponsiveUtils.spacing(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final contentHeight = screenHeight * 0.85;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: ResponsiveUtils.padding(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: spacing),
                  SizedBox(
                    height: contentHeight * 0.15,
                    child: _buildWelcomeSection(context, state),
                  ),
                  SizedBox(height: spacing),
                  SizedBox(
                    height: contentHeight * 0.4,
                    child: _buildTodayStats(context),
                  ),
                  SizedBox(height: spacing),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: _buildQuickActions(context),
                  ),
                  SizedBox(height: spacing),
                ],
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: spacing),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: _buildUpcomingSessions(context),
                  ),
                  SizedBox(height: spacing),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: _buildRecentActivity(context),
                        ),
                        SizedBox(width: spacing),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: _buildPerformanceMetrics(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop layout
  Widget _buildDesktopDashboard(BuildContext context, AuthAuthenticated state) {
    final spacing = ResponsiveUtils.spacing(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final contentHeight = screenHeight * 0.85;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: spacing),
                  SizedBox(
                    height: contentHeight * 0.15,
                    child: _buildWelcomeSection(context, state),
                  ),
                  SizedBox(height: spacing),
                  SizedBox(
                    height: contentHeight * 0.4,
                    child: _buildTodayStats(context),
                  ),
                  SizedBox(height: spacing),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: _buildQuickActions(context),
                  ),
                  SizedBox(height: spacing),
                ],
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: spacing),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: _buildUpcomingSessions(context),
                  ),
                  SizedBox(height: spacing),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: _buildRecentActivity(context),
                        ),
                        SizedBox(width: spacing),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: _buildPerformanceMetrics(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AuthAuthenticated state) {
    final displayName = [state.user.firstName, state.user.lastName]
        .where((name) => name.isNotEmpty)
        .join(' ');

    return BaseCard(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textSpan = TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome back',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                      ),
                    ),
                    TextSpan(
                      text: displayName.isNotEmpty ? ', $displayName' : '!',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                );

                final textPainter = TextPainter(
                  text: textSpan,
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                );
                textPainter.layout(maxWidth: double.infinity);

                // If single line width exceeds available width, use two lines
                final usesTwoLines = textPainter.width > constraints.maxWidth;

                return RichText(
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: usesTwoLines ? 2 : 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome back',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 18),
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                      ),
                      TextSpan(
                        text: displayName.isNotEmpty
                            ? (usesTwoLines
                                ? '\n$displayName'
                                : ', $displayName')
                            : '!',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BaseCard(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Stats',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildStatItem(context, '5', 'Active Clients'),
            _buildStatItem(context, '3', 'Sessions Today'),
            _buildStatItem(context, '2', 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 12),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final spacing = ResponsiveUtils.spacing(context) / 2;

    return BaseCard(
        child: Column(
      spacing: spacing,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 14),
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: spacing,
              children: [
                BaseButton(
                  text: 'New Session',
                  onPressed: () {},
                  icon: Icons.add,
                ),
                BaseButton(
                  text: 'View Schedule',
                  onPressed: () {},
                  icon: Icons.calendar_today,
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildUpcomingSessions(BuildContext context) {
    // Convert mock sessions to DateTime objects for the calendar
    final now = DateTime.now();
    final sessions = [
      DateTime(now.year, now.month, now.day, 10, 0), // 10:00 AM
      DateTime(now.year, now.month, now.day, 14, 0), // 2:00 PM
      DateTime(now.year, now.month, now.day, 16, 30), // 4:30 PM
    ];

    return SessionCalendar(
      sessions: sessions,
      onDateSelected: (date) {
        // TODO: Implement date selection handling
        debugPrint('Selected date: $date');
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      ActivityItem(
        clientName: 'John D.',
        action: 'Completed Upper Body workout',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ActivityItem(
        clientName: 'Sarah M.',
        action: 'Started Lower Body session',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ActivityItem(
        clientName: 'John D.',
        action: 'Completed Upper Body workout',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ActivityItem(
        clientName: 'Sarah M.',
        action: 'Started Lower Body session',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    return ActivityFeed(activities: activities);
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return MetricsSummary(
      activeClients: 5,
      totalSessions: 15,
      revenue: 1250.00,
    );
  }
}

class _Session {
  final String time;
  final String clientName;
  final String workoutType;

  const _Session(this.time, this.clientName, this.workoutType);
}
