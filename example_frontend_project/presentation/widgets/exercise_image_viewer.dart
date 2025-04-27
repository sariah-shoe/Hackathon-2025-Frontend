import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseImageViewer extends StatelessWidget {
  final List<String> imagePaths;
  final double aspectRatio;
  final PageController? pageController;

  const ExerciseImageViewer({
    super.key,
    required this.imagePaths,
    this.aspectRatio = 16 / 9,
    this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageCarousel(maxWidth),
            _buildPageIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildImageCarousel(double maxWidth) {
    return SizedBox(
      height: maxWidth / aspectRatio,
      child: PageView.builder(
        controller: pageController,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          final imageUrl =
              'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/${imagePaths[index]}';

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (_, __, progress) => Center(
                    child: CircularProgressIndicator(
                  value: progress.progress,
                )),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error_outline),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return StreamBuilder<int>(
      stream: _pageChanges,
      builder: (context, snapshot) {
        final currentPage = snapshot.data ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imagePaths.length, (index) {
            return Container(
              width: 8.w,
              height: 8.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index
                    ? Colors.blue.shade500
                    : Colors.grey.shade300,
              ),
            );
          }),
        );
      },
    );
  }

  Stream<int> get _pageChanges {
    final controller = pageController;
    if (controller == null) return Stream.empty();

    return controller.position.changes
        .map((_) => controller.page?.round() ?? 0)
        .distinct();
  }
}

extension _ScrollPositionChanges on ScrollPosition {
  Stream<void> get changes {
    final controller = StreamController<void>();
    listener() => controller.add(null);
    addListener(listener);
    controller.onCancel = () => removeListener(listener);
    return controller.stream;
  }
}
