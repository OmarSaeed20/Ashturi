import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CacheNetworkImage extends StatelessWidget {
  const CacheNetworkImage({
    Key key,
    @required this.imageUrl,
    this.boxFit,
    this.borderRadius,
    this.height,
    this.width,
  }) : super(key: key);

  final String imageUrl;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final BoxFit boxFit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        height: height ?? MediaQuery.of(context).size.width,
        width: width ?? MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          image: DecorationImage(
            image: imageProvider,
            fit: boxFit ?? BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Center(
          child: const CircularProgressIndicator(
        strokeWidth: 2,
      )),
      errorWidget: (context, url, error) => const Icon(
        Icons.error,
        color: Colors.red,
      ),
    );
  }
}
