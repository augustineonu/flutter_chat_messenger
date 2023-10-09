import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget imageAvatar({
  required String imgUrl,
  double? height,
  double? width,
 }) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: width ?? 198.0,
        height: height ?? 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Container(
        height: 100,
        width: 104,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

