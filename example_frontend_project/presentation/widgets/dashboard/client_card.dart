import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/base_widgets.dart';
import '../../../core/utils/responsive_utils.dart';

class ClientCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String status;
  final VoidCallback? onTap;

  const ClientCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      child: Row(
        children: [
          _buildAvatar(context),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 12),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: ResponsiveUtils.fontSize(context, 24),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 2.w,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: ResponsiveUtils.responsiveIconSize(context) / 2,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircleAvatar(
              radius: ResponsiveUtils.responsiveIconSize(context) / 2,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: SizedBox(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2.w,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
