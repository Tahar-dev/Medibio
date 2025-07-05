import 'package:flutter/material.dart';

class SquareTile2 extends StatelessWidget {
  final String imagePath;
  const SquareTile2({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),

      child: Image.asset(
        imagePath,
        height: 60,
        width: 60,
      ),
    );
  }
}
