import 'package:intl/intl.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';

class ItemTile extends StatelessWidget {
  final String itemName;
  final String imagePath;
  final void Function()? onPressed;

  const ItemTile({
    super.key,
    required this.itemName,
    required this.imagePath,
    required this.onPressed,
  });

   @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: () {
          onPressed?.call();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click, // Change le curseur au survol
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), // Animation fluide
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              color: Colors.blue[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 5), // Ombre portée
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  spreadRadius: -5,
                  blurRadius: 10,
                  offset: const Offset(-5, -5), // Ombre intérieure pour un effet 3D
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image sans forme ovale
                Image.asset(
                  imagePath,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                // Texte sans dégradé
                Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 24,
                   // fontWeight: FontWeight.bold,
                     color: ThemeColors.buildCardBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }