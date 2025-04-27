import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// Base button with consistent styling
class BaseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const BaseButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>();

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: ResponsiveUtils.responsiveIconSize(context) * 0.2,
            color: textColor ?? theme.colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: 8.0.w),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16),
              color: textColor ?? theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );

    if (isLoading) {
      buttonChild = SizedBox(
        height: 20.0.h,
        width: 20.0.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? theme.colorScheme.primary : Colors.white,
          ),
        ),
      );
    }

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.secondary),
              padding: themeExt?.defaultPadding,
              shape: RoundedRectangleBorder(
                borderRadius:
                    themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
              ),
            ),
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              padding: themeExt?.defaultPadding,
              shape: RoundedRectangleBorder(
                borderRadius:
                    themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
              ),
            ),
            child: buttonChild,
          );

    return isFullWidth
        ? SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.isDesktop(context)
                    ? 400.w
                    : double.infinity,
              ),
              child: button,
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.isDesktop(context) ? 300.w : 200.w,
            ),
            child: button,
          );
  }
}

/// Base card with consistent styling
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final double? maxHeight;
  final bool selected;

  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.maxHeight,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUtils.isDesktop(context) ? 600.w : double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: Card(
        elevation: elevation ?? 2,
        color:
            backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius:
              themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

/// Base text field with consistent styling
class BaseTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const BaseTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>();

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: ResponsiveUtils.fontSize(context, 16),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
                size: ResponsiveUtils.responsiveIconSize(context) * 0.8)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon,
                    size: ResponsiveUtils.responsiveIconSize(context) * 0.8),
                onPressed: onSuffixIconPressed,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius:
              themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Base list tile with consistent styling
class BaseListTile extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final Color? backgroundColor;

  const BaseListTile({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.backgroundColor,
  }) : assert(title == null || titleWidget == null,
            'Cannot provide both title and titleWidget');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>();

    return Card.outlined(
      elevation: 0,
      color: selected
          ? backgroundColor ?? theme.colorScheme.primaryContainer
          : backgroundColor ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
            themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline,
        ),
      ),
      margin: EdgeInsets.all(3.r),
      child: ListTile(
        title: titleWidget ??
            (title != null
                ? Text(
                    title!,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 12),
                    ),
                  )
                : null),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 10),
                ),
              )
            : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius:
              themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Base chip with consistent styling
class BaseChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool selected;
  final bool deletable;
  final VoidCallback? onDeleted;
  final IconData? icon;
  final bool fullWidth;

  const BaseChip({
    super.key,
    required this.label,
    this.color,
    this.onTap,
    this.selected = false,
    this.deletable = false,
    this.onDeleted,
    this.icon,
    this.backgroundColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>();

    Widget chipContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: ResponsiveUtils.fontSize(context, 16),
            color: color ?? theme.colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: 4.w),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 14),
            color: color,
          ),
        ),
      ],
    );

    Widget chip = FilterChip(
      label: chipContent,
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      selectedColor: theme.colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius:
            themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
      ),
      onDeleted: deletable ? onDeleted : null,
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: chip,
      );
    }

    return chip;
  }
}

/// Base filter chip with consistent styling
class BaseFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool)? onSelected;
  final Color? color;
  final IconData? icon;

  const BaseFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>();

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: ResponsiveUtils.fontSize(context, 16),
              color: selected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14),
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: color ?? theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius:
            themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}

/// Base divider with consistent styling
class BaseDivider extends StatelessWidget {
  final double? height;
  final Color? color;
  final double? thickness;
  final double? indent;
  final double? endIndent;

  const BaseDivider({
    super.key,
    this.height,
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Divider(
      height: height ?? 24,
      color: color ?? theme.colorScheme.outline,
      thickness: thickness ?? 1,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

/// Base gradient container with consistent styling
class BaseGradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;

  const BaseGradientContainer({
    super.key,
    required this.child,
    this.colors,
    this.begin,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
          colors: colors ??
              [
                themeExt?.primaryGradientStart ?? theme.colorScheme.primary,
                themeExt?.primaryGradientEnd ??
                    theme.colorScheme.primary.withOpacity(0.8),
              ],
        ),
        borderRadius:
            themeExt?.defaultBorderRadius ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// Base loading indicator with consistent styling
class BaseLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const BaseLoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: size ?? ResponsiveUtils.responsiveIconSize(context),
      width: size ?? ResponsiveUtils.responsiveIconSize(context),
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Base error widget with consistent styling
class BaseErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const BaseErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: ResponsiveUtils.responsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.responsiveIconSize(context) * 2,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: ResponsiveUtils.spacing(context)),
            Text(
              message,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16),
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: ResponsiveUtils.spacing(context)),
              BaseButton(
                text: 'Retry',
                onPressed: onRetry,
                isFullWidth: false,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Base empty state widget with consistent styling
class BaseEmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const BaseEmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: ResponsiveUtils.responsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: ResponsiveUtils.responsiveIconSize(context) * 2,
              color: theme.colorScheme.outline,
            ),
            SizedBox(height: ResponsiveUtils.spacing(context)),
            Text(
              message,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16),
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: ResponsiveUtils.spacing(context)),
              BaseButton(
                text: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
