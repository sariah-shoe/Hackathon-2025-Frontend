import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Orientation type enumeration
enum OrientationType { portrait, landscape }

/// Responsive layout utility with improved flexibility and performance
class ResponsiveUtils {
  /// Breakpoint ranges for different device sizes
  static const _BreakpointRange mobile = _BreakpointRange(0, 799);
  static const _BreakpointRange tablet = _BreakpointRange(800, 1623);
  static const _BreakpointRange desktop =
      _BreakpointRange(1624, double.infinity);

  /// Get the current device type based on width
  static DeviceType getDeviceType(BuildContext context) {
    return getDeviceTypeFromMedia(MediaQuery.maybeOf(context) ??
        MediaQueryData.fromView(View.of(context)));
  }

  /// Check if the current device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Get the current orientation type based on aspect ratio
  static OrientationType getOrientation(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // If width is greater than height, it's landscape
    return size.width > size.height
        ? OrientationType.landscape
        : OrientationType.portrait;
  }

  /// Check if the current orientation is landscape based on aspect ratio
  static bool isLandscape(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media == null) return false;
    return getOrientationFromMedia(media) == OrientationType.landscape ||
        getDeviceTypeFromMedia(media) == DeviceType.desktop;
  }

  /// Get a responsive value based on device type and orientation
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? mobileLandscape,
    T? tabletLandscape,
    T? desktopLandscape,
    MediaQueryData? media,
  }) {
    final mediaData = media ?? MediaQuery.maybeOf(context);
    if (mediaData == null) return mobile;

    final deviceType = getDeviceTypeFromMedia(mediaData);
    final isLandscape =
        getOrientationFromMedia(mediaData) == OrientationType.landscape;

    // First check landscape-specific values if in landscape mode
    if (isLandscape) {
      switch (deviceType) {
        case DeviceType.mobile:
          if (mobileLandscape != null) return mobileLandscape;
          break;
        case DeviceType.tablet:
          if (tabletLandscape != null) return tabletLandscape;
          break;
        case DeviceType.desktop:
          if (desktopLandscape != null) return desktopLandscape;
          break;
      }
    }

    // Fall back to device type values
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding that adapts to both device type and orientation
  static EdgeInsets responsivePadding(BuildContext context) {
    final devicePadding = MediaQuery.paddingOf(context);
    return responsive<EdgeInsets>(
      context: context,
      mobile: EdgeInsets.all(8.w),
      tablet: EdgeInsets.all(16.w),
      desktop: EdgeInsets.all(24.w),
      mobileLandscape: EdgeInsets.all(6.w),
      tabletLandscape: EdgeInsets.all(12.w),
      desktopLandscape: EdgeInsets.all(20.w),
    ).copyWith(
      top: devicePadding.top,
      bottom: devicePadding.bottom,
    );
  }

  /// Get responsive spacing based on device type
  static double spacing(BuildContext context) {
    return responsive<double>(
      context: context,
      mobile: 12.w,
      tablet: 12.w,
      desktop: 12.w,
      mobileLandscape: 12.w,
      tabletLandscape: 12.w,
      desktopLandscape: 12.w,
    );
  }

  /// Get responsive spacing based on device type
  static double responsiveSpacing(BuildContext context) {
    return responsive<double>(
      context: context,
      mobile: 8.w,
      tablet: 12.w,
      desktop: 16.w,
      mobileLandscape: 6.w,
      tabletLandscape: 10.w,
      desktopLandscape: 14.w,
    );
  }

//  /// Get responsive font size based on device type
//  static double fontSize(BuildContext context, double baseSize) {
//    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
//    return responsive<double>(
//          context: context,
//          mobile: baseSize,
//          tablet: baseSize * 0.8,
//          desktop: baseSize * 0.6,
//          mobileLandscape: baseSize,
//          tabletLandscape: baseSize * 0.8,
//          desktopLandscape: baseSize * 0.6,
//        ) *
//        textScaleFactor;
//  }
  /// Get responsive font size based on device type
  static double fontSize(BuildContext context, double baseSize) {
    return responsive<double>(
      context: context,
      mobile: baseSize.w,
      tablet: baseSize.h,
      desktop: baseSize.h,
      mobileLandscape: baseSize.h,
      tabletLandscape: baseSize.h,
      desktopLandscape: baseSize.h,
    );
  }

  /// Get responsive height based on device type and screen height
  static double height(BuildContext context, double factor) {
    final height = MediaQuery.sizeOf(context).height;
    return height * factor;
  }

  /// Get responsive width based on device type and screen width
  static double width(BuildContext context, double factor) {
    final width = MediaQuery.sizeOf(context).width;
    return width * factor;
  }

  /// Get responsive border radius based on device type
  static BorderRadius radius(BuildContext context) {
    return BorderRadius.circular(
      responsive<double>(
        context: context,
        mobile: 12.r,
        tablet: 16.r,
        desktop: 20.r,
      ),
    );
  }

  /// Get responsive icon size based on device type
  static double responsiveIconSize(BuildContext context) {
    return responsive<double>(
      context: context,
      mobile: 26.w,
      tablet: 30.w,
      desktop: 34.w,
      mobileLandscape: 26.w,
      tabletLandscape: 30.w,
      desktopLandscape: 34.w,
    );
  }

  /// Get responsive button height based on device type
  static double responsiveButtonHeight(BuildContext context) {
    return responsive<double>(
      context: context,
      mobile: 48.h,
      tablet: 56.h,
      desktop: 64.h,
      mobileLandscape: 40.h,
      tabletLandscape: 48.h,
      desktopLandscape: 56.h,
    );
  }

  /// Get responsive padding (maintained for compatibility)
  static EdgeInsets padding(BuildContext context) {
    return responsivePadding(context);
  }

  // Add media-based versions of critical methods
  static DeviceType getDeviceTypeFromMedia(MediaQueryData media) {
    final width = media.size.width;
    if (mobile.contains(width)) return DeviceType.mobile;
    if (tablet.contains(width)) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static OrientationType getOrientationFromMedia(MediaQueryData media) {
    return media.size.width > media.size.height
        ? OrientationType.landscape
        : OrientationType.portrait;
  }
}

/// Helper class for defining breakpoint ranges
class _BreakpointRange {
  final double min;
  final double max;

  const _BreakpointRange(this.min, this.max);

  bool contains(double value) => value >= min && value < max;
}
