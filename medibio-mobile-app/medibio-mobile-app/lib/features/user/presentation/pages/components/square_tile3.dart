import 'package:flutter/material.dart';

class SquareTile3 extends StatelessWidget {
  final String imagePath;
  const SquareTile3({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),

      /*decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.blue[700],
      ),*/

      child: Image.asset(
        imagePath,
        height: 120,
        width: 250,
      ),
    );
  }
}
