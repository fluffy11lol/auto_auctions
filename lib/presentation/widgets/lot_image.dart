import 'dart:convert';
import 'package:flutter/material.dart';

class LotImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const LotImage({super.key, required this.imagePath, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('data:image')) {
      try {
        final base64String = imagePath.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _errorIcon(),
        );
      } catch (e) {
        return _errorIcon();
      }
    }

    return Image.network(
      imagePath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _errorIcon(),
    );
  }

  Widget _errorIcon() => const Center(child: Icon(Icons.broken_image, color: Colors.grey));
}