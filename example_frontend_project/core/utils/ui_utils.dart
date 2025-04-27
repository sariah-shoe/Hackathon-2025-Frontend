import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

/// UI utility functions for common UI operations
class UiUtils {
  /// Shows a snackbar with the given message
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration? duration,
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor:
            isError ? theme.colorScheme.error : theme.colorScheme.primary,
        duration: duration ?? UiConstants.snackbarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.defaultRadius),
        ),
      ),
    );
  }

  /// Shows a loading dialog
  static Future<void> showLoadingDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.defaultRadius),
            ),
            child: Container(
              padding: const EdgeInsets.all(UiConstants.defaultPadding),
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  /// Gets responsive width based on screen size percentage
  static double getResponsiveWidth(BuildContext context, double percentage) {
    final width = MediaQuery.of(context).size.width;
    return (width * percentage).clamp(0.0, UiConstants.maxContentWidth);
  }

  /// Gets responsive height based on screen size percentage
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Formats a date using the specified format (defaults to 'MMM dd, yyyy')
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Formats time in a human-readable format (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return formatDate(dateTime);
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Formats a number as currency
  static String formatCurrency(
    double amount, {
    String symbol = '\$',
    int decimalPlaces = 2,
  }) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalPlaces,
    ).format(amount);
  }

  /// Formats a large number in a human-readable way (e.g., 1.2K, 1.5M)
  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  /// Shows a confirmation dialog with custom actions
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
