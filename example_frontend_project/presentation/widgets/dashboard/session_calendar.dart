import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/base_widgets.dart';
import '../../../core/utils/responsive_utils.dart' as responsive_utils;

class SessionCalendar extends StatefulWidget {
  final List<DateTime> sessions;
  final Function(DateTime)? onDateSelected;

  const SessionCalendar({
    super.key,
    required this.sessions,
    this.onDateSelected,
  });

  @override
  State<SessionCalendar> createState() => _SessionCalendarState();
}

class _SessionCalendarState extends State<SessionCalendar> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  static const double _maxCalendarWidth = 500;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = responsive_utils.ResponsiveUtils.isLandscape(context);
    final isPortraitTablet =
        responsive_utils.ResponsiveUtils.getDeviceType(context) ==
                responsive_utils.DeviceType.tablet &&
            !isLandscape;

    return BaseCard(
      child: isLandscape && widget.sessions.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: _maxCalendarWidth,
                  child: Padding(
                    padding:
                        responsive_utils.ResponsiveUtils.padding(context) / 4,
                    child: _buildCalendarContent(
                        context, isLandscape, isPortraitTablet),
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: _buildSessionsList(context),
                ),
              ],
            )
          : _buildCalendarContent(context, isLandscape, isPortraitTablet),
    );
  }

  Widget _buildCalendarContent(
      BuildContext context, bool isLandscape, bool isPortraitTablet) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Sessions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: responsive_utils.ResponsiveUtils.fontSize(
                          context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: isPortraitTablet
                    ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
                    : EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 0.0.h,
                  children: [
                    Flexible(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left,
                                      size: responsive_utils.ResponsiveUtils
                                          .fontSize(context, 20)),
                                  onPressed: _previousMonth,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Text(
                                  _getMonthYearText(),
                                  style: TextStyle(
                                    fontSize: responsive_utils.ResponsiveUtils
                                        .fontSize(context, 16),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.chevron_right,
                                      size: responsive_utils.ResponsiveUtils
                                          .fontSize(context, 20)),
                                  onPressed: _nextMonth,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        )),
                    _buildCalendarGrid(context, isLandscape),
                  ],
                ),
              ),
            ],
          ),
          if (widget.sessions.isNotEmpty && !isLandscape) ...[
            _buildSessionsList(context),
          ],
        ]);
  }

  Widget _buildCalendarGrid(BuildContext context, bool isLandscape) {
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final isPortraitTablet =
        responsive_utils.ResponsiveUtils.getDeviceType(context) ==
                responsive_utils.DeviceType.tablet &&
            !isLandscape;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30.h,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                  style: TextStyle(
                    fontSize:
                        responsive_utils.ResponsiveUtils.fontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        AspectRatio(
          aspectRatio: 1.35,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, dayOffset + 1);
              final isSelected = _selectedDate.year == date.year &&
                  _selectedDate.month == date.month &&
                  _selectedDate.day == date.day;
              final hasSession = widget.sessions.any((session) =>
                  session.year == date.year &&
                  session.month == date.month &&
                  session.day == date.day);

              return _CalendarDay(
                date: date,
                isSelected: isSelected,
                hasSession: hasSession,
                onTap: () {
                  setState(() => _selectedDate = date);
                  widget.onDateSelected?.call(date);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsList(BuildContext context) {
    final todaySessions = widget.sessions
        .where((session) =>
            session.year == _selectedDate.year &&
            session.month == _selectedDate.month &&
            session.day == _selectedDate.day)
        .toList();

    if (todaySessions.isEmpty) return const SizedBox.shrink();

    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sessions for ${_formatDate(_selectedDate)}',
            style: TextStyle(
              fontSize: responsive_utils.ResponsiveUtils.fontSize(context, 16),
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: todaySessions.length,
                itemBuilder: (context, index) {
                  final session = todaySessions[index];
                  return BaseListTile(
                    title: _formatTime(session),
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                    leading: CircleAvatar(
                      radius:
                          responsive_utils.ResponsiveUtils.fontSize(context, 8),
                      backgroundColor: Theme.of(context).colorScheme.onTertiary,
                      child: Icon(
                        Icons.access_time,
                        size: responsive_utils.ResponsiveUtils.fontSize(
                            context, 16),
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  String _getMonthYearText() {
    return '${_focusedMonth.month}/${_focusedMonth.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool hasSession;
  final VoidCallback onTap;

  const _CalendarDay({
    super.key,
    required this.date,
    required this.isSelected,
    required this.hasSession,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = responsive_utils.ResponsiveUtils.getDeviceType(context);
    final isTabletOrDesktop = deviceType != DeviceType.mobile;
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isToday
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : isToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            if (hasSession)
              Positioned(
                bottom: 2.r,
                child: Container(
                  width: 4.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
