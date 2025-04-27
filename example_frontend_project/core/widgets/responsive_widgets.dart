import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import 'dart:async';

/// A builder function that provides device type and orientation information
typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  DeviceType deviceType,
  OrientationType orientation,
);

/// A widget that rebuilds based on device type and orientation
class ResponsiveBuilder extends StatelessWidget {
  final ResponsiveWidgetBuilder builder;
  final Duration debounceDuration;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.debounceDuration = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.maybeOf(context);
        if (media == null) {
          return builder(context, DeviceType.mobile, OrientationType.portrait);
        }

        return _DebouncedBuilder(
          duration: debounceDuration,
          builder: (context) {
            final deviceType = ResponsiveUtils.getDeviceTypeFromMedia(media);
            final orientation = ResponsiveUtils.getOrientationFromMedia(media);

            return Builder(
              builder: (context) => builder(context, deviceType, orientation),
            );
          },
        );
      },
    );
  }
}

class _DebouncedBuilder extends StatefulWidget {
  final Duration duration;
  final WidgetBuilder builder;

  const _DebouncedBuilder({
    required this.duration,
    required this.builder,
  });

  @override
  State<_DebouncedBuilder> createState() => _DebouncedBuilderState();
}

class _DebouncedBuilderState extends State<_DebouncedBuilder> {
  Timer? _debounceTimer;
  Widget? _lastChild;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.duration, () {
      setState(() {
        _lastChild = widget.builder(context);
      });
    });

    return _lastChild ?? const SizedBox.shrink();
  }
}

/// A widget that provides different layouts for different device types
class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, _) {
        switch (deviceType) {
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.mobile:
            return mobile;
        }
      },
    );
  }
}

/// A widget that provides different layouts for different orientations
class OrientationLayout extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;

  const OrientationLayout({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, _, orientation) {
        return orientation == OrientationType.landscape
            ? landscape ?? portrait
            : portrait;
      },
    );
  }
}

/// A responsive grid that adapts its cross-axis count and spacing based on device type
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, orientation) {
        final crossAxisCount = ResponsiveUtils.responsive<int>(
          context: context,
          mobile: 2,
          tablet: 3,
          desktop: 4,
          mobileLandscape: 3,
          tabletLandscape: 4,
          desktopLandscape: 6,
        );

        final defaultSpacing = ResponsiveUtils.spacing(context);

        return GridView.builder(
          padding: padding ?? ResponsiveUtils.padding(context),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing ?? defaultSpacing,
            mainAxisSpacing: runSpacing ?? defaultSpacing,
            childAspectRatio: ResponsiveUtils.responsive<double>(
              context: context,
              mobile: 1.0,
              tablet: 1.2,
              desktop: 1.4,
              mobileLandscape: 1.2,
              tabletLandscape: 1.4,
              desktopLandscape: 1.6,
            ),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// A responsive container that adapts its constraints based on device type
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, orientation) {
        final defaultPadding = ResponsiveUtils.padding(context);

        return Container(
          width: width != null ? ResponsiveUtils.width(context, width!) : null,
          height:
              height != null ? ResponsiveUtils.height(context, height!) : null,
          padding: padding ?? defaultPadding,
          margin: margin,
          decoration: decoration ??
              BoxDecoration(
                borderRadius: ResponsiveUtils.radius(context),
              ),
          child: child,
        );
      },
    );
  }
}

/// A responsive list view that adapts its layout based on device type
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.spacing,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, orientation) {
        final defaultSpacing = ResponsiveUtils.spacing(context);

        return ListView.separated(
          padding: padding ?? ResponsiveUtils.padding(context),
          shrinkWrap: shrinkWrap,
          physics: physics,
          scrollDirection: scrollDirection,
          itemCount: children.length,
          separatorBuilder: (_, __) => SizedBox(
            width: scrollDirection == Axis.horizontal
                ? spacing ?? defaultSpacing
                : 0,
            height: scrollDirection == Axis.vertical
                ? spacing ?? defaultSpacing
                : 0,
          ),
          itemBuilder: (_, index) => children[index],
        );
      },
    );
  }
}
