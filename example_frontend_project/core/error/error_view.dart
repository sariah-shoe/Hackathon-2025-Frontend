import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'failures.dart';
import 'authentication_failure.dart';

/// A reusable widget for displaying errors
class ErrorView extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? icon;

  const ErrorView({
    super.key,
    required this.failure,
    this.onRetry,
    this.retryText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ??
                Icon(
                  _getIconData(),
                  size: 48,
                  color: theme.colorScheme.error,
                ),
            const SizedBox(height: UiConstants.defaultSpacing),
            Text(
              failure.message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (failure is ValidationFailure) ...[
              const SizedBox(height: UiConstants.defaultSpacing),
              _buildValidationErrors(theme, failure as ValidationFailure),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: UiConstants.defaultSpacing * 2),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    if (failure is NetworkFailure) {
      return Icons.wifi_off_rounded;
    }
    if (failure is AuthenticationFailure) {
      return Icons.lock_rounded;
    }
    if (failure is ValidationFailure) {
      return Icons.error_outline_rounded;
    }
    if (failure is CacheFailure) {
      return Icons.storage_rounded;
    }
    return Icons.error_rounded;
  }

  Widget _buildValidationErrors(ThemeData theme, ValidationFailure failure) {
    if (failure.errors == null || failure.errors!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: failure.errors!.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              ...entry.value.map((error) => Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      '• $error',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// A widget that displays a full-screen error view
class FullScreenErrorView extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? icon;
  final Color? backgroundColor;

  const FullScreenErrorView({
    super.key,
    required this.failure,
    this.onRetry,
    this.retryText,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ErrorView(
          failure: failure,
          onRetry: onRetry,
          retryText: retryText,
          icon: icon,
        ),
      ),
    );
  }
}
