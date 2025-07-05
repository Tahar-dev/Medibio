import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';


class ParcListWidget extends StatelessWidget {
  final List<Parc> parcs;

  const ParcListWidget({Key? key, required this.parcs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: parcs.length,
      itemBuilder: (context, index) {
        final parc = parcs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade800,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'PARC : ${parc.designation}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("N° série", parc.numserie),
                      //_buildInfoRow("Article", parc.article),
                      _buildInfoRow("Marque", parc.marque),
                      _buildInfoRow("Localisation", parc.localisation),
                      _buildInfoRow("Software", parc.software),
                      _buildInfoRow("Firmware", parc.firmware),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.isNotEmpty == true ? value! : "________",
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
