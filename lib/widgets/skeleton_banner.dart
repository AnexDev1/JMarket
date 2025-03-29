// dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBanner extends StatelessWidget {
  final double height;

  const SkeletonBanner({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
