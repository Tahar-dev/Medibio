import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';


class ParcCard extends StatelessWidget {
  final Parc parc;

  const ParcCard({required this.parc});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(parc.designation!),
        subtitle: Text(parc.addressSite!),
      ),
    );
  }
}
