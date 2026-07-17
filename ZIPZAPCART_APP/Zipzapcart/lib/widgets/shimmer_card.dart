import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A grey shimmer placeholder shaped like a product card,
/// used wherever a product grid/list is loading.
class ShimmerProductCard extends StatelessWidget {

  final double width;
  final double height;

  const ShimmerProductCard({
    super.key,
    this.width = 175,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

/// A generic full-width shimmer block (e.g. for a landscape card row).
class ShimmerBlock extends StatelessWidget {

  final double? width;
  final double height;
  final double radius;

  const ShimmerBlock({
    super.key,
    this.width,
    this.height = 100,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 14, bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
