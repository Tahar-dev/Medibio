import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';

class SitePage extends StatelessWidget {
  final String siteName;

  const SitePage({Key? key, required this.siteName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site'),
        backgroundColor: ThemeColors.buildCardBlue, // Utilisez votre couleur
      ),
      body: Center(
        child: Text(
          siteName,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}