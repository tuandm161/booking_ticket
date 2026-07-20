import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    placeholder: (context, url) => const ColoredBox(
      color: Colors.black12,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    ),
    errorWidget: (context, url, error) => const ColoredBox(
      color: Colors.black12,
      child: Icon(Icons.image_not_supported_outlined),
    ),
  );
}
