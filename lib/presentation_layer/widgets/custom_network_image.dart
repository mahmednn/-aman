import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_application_11/constants/strings.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth ?? 400,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: secondaryBgColor,
        highlightColor: cardColor,
        child: Container(color: Colors.black),
      ),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: secondaryBgColor,
      width: width,
      height: height,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: textSecondary, size: 40),
      ),
    );
  }
}
