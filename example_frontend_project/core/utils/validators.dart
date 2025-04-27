import 'constants.dart';

/// Collection of validation functions for forms and input fields
class Validators {
  /// Validates an email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(ValidationConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates a password with strength requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < ValidationConstants.passwordMinLength) {
      return 'Password must be at least ${ValidationConstants.passwordMinLength} characters';
    }

    if (value.length > ValidationConstants.passwordMaxLength) {
      return 'Password must not exceed ${ValidationConstants.passwordMaxLength} characters';
    }

    final passwordRegex = RegExp(ValidationConstants.passwordPattern);
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }

    return null;
  }

  /// Validates a phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone might be optional
    }

    if (value.length < ValidationConstants.phoneMinLength) {
      return 'Phone number is too short';
    }

    final phoneRegex = RegExp(ValidationConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates a required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} is required';
    }
    return null;
  }

  /// Validates text length
  static String? validateLength(
    String? value, {
    required int minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Length validation only applies to non-empty values
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'Field'} must be at least $minLength characters';
    }

    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'Field'} must not exceed $maxLength characters';
    }

    return null;
  }

  /// Validates numeric input
  static String? validateNumeric(
    String? value, {
    double? min,
    double? max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Numeric validation only applies to non-empty values
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Field'} must be a valid number';
    }

    if (min != null && number < min) {
      return '${fieldName ?? 'Field'} must be at least $min';
    }

    if (max != null && number > max) {
      return '${fieldName ?? 'Field'} must not exceed $max';
    }

    return null;
  }

  /// Creates a custom validator function
  static String? Function(String?) custom(
    bool Function(String?) validator,
    String errorMessage,
  ) {
    return (String? value) {
      if (!validator(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Combines multiple validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
