import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc2_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_state.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/Parc_history_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/Parc_history_page2.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/details_parcs_intervention.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';

class ParcCard2 extends StatefulWidget {
  final ParcModel parccardd22;
  final bool isTerminatedcardd22;
  final List<ParcModel> parcCardPicked;
  final VoidCallback onDelete;
  final VoidCallback onHistoryPress;
  final VoidCallback onReportPress;
  

  ParcCard2({
    Key? key,
    required this.parccardd22,
    required this.isTerminatedcardd22,
    required this.parcCardPicked,
    required this.onDelete,
    required this.onHistoryPress,
    required this.onReportPress,
    
  }) : super(key: key);

  @override
  _ParcCard2State createState() => _ParcCard2State();
}

class _ParcCard2State extends State<ParcCard2> {
  late TextEditingController versionController;
  late TextEditingController referenceController;

  @override
  void initState() {
    super.initState();
    versionController = TextEditingController(text: widget.parccardd22.software);
    referenceController = TextEditingController(text: widget.parccardd22.firmware);
  }

  @override
  void dispose() {
    versionController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec l'ID du PARC et bouton de suppression
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PARC : ${widget.parccardd22.id ?? 'Parc Not Found'}',
                    style: const TextStyle(
                      color: ThemeColors.buildCardBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: widget.isTerminatedcardd22
                        ? const Icon(Icons.delete_forever, color: Colors.grey, size: 30)
                        : const Icon(Icons.delete, color: Colors.grey, size: 30),
                    onPressed: () {
                      if (!widget.isTerminatedcardd22) {
                        widget.parcCardPicked.removeWhere((p) => p.id == widget.parccardd22.id);
                        widget.onDelete();
                      }
                    },
                  ),
                ],
              ),
            ),
            // Corps de la carte avec les informations du PARC
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Colonne de gauche : Informations du PARC
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("N° Série", widget.parccardd22.numserie ?? ''),
                          _buildInfoRow("Marque", widget.parccardd22.marque ?? ''),
                          _buildInfoRow("Localisation", widget.parccardd22.localisation ?? ''),
                          //_buildInfoRow("Attitude", widget.parccardd22.attitudeApparence ?? ''),

                          _buildFieldInfoRow1(
                            "Software",
                            versionController,
                  
                          ),

                          _buildFieldInfoRow2(
                            "firmware",
                            referenceController,
                     
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Colonne de droite : Boutons d'actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                                            Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.article, color: ThemeColors.buildCardBlue, size: 30.0),
                            onPressed: widget.onReportPress,
                            iconSize: 30.0,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history, color: ThemeColors.buildCardBlue, size: 30.0),
                            onPressed: widget.onHistoryPress,
                            iconSize: 30.0,
                          ),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.isNotEmpty == true ? value! : "",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildFieldInfoRow1(String label, TextEditingController controller) {
  String tempValue = controller.text; // Stocker temporairement la valeur

  return Row(
    children: [
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !widget.isTerminatedcardd22,
                onChanged: (newValue) {
                  tempValue = newValue; // Mettre à jour la valeur temporaire
                },
                decoration: const InputDecoration(
                  hintText: "________",
                  isDense: true, 
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
IconButton(
  icon: Icon(
    Icons.check,
    color: widget.isTerminatedcardd22 ? Colors.grey : ThemeColors.buildCardBlue,
  ),
  onPressed: widget.isTerminatedcardd22
      ? null // Désactive le bouton si `isTerminatedcardd22` est `true`
      : () {
          widget.parccardd22.software = tempValue; // Mise à jour de la valeur
          print("Valeur mise à jour: ${widget.parccardd22.software}");
        },
),

          ],
        ),
      ),
    ],
  );
}

Widget _buildFieldInfoRow2(String label, TextEditingController controller) {
  String tempValue = controller.text; // Stocker temporairement la valeur

  return Row(
    children: [
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !widget.isTerminatedcardd22,
                onChanged: (newValue) {
                  tempValue = newValue; // Mettre à jour la valeur temporaire
                },
                decoration: const InputDecoration(
                  hintText: "________",
                  isDense: true, 
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
IconButton(
  icon: Icon(
    Icons.check,
    color: widget.isTerminatedcardd22 ? Colors.grey : ThemeColors.buildCardBlue,
  ),
  onPressed: widget.isTerminatedcardd22
      ? null 
      : () {
          widget.parccardd22.firmware = tempValue; 
          print("Valeur mise à jour: ${widget.parccardd22.firmware}");
        },
),

          ],
        ),
      ),
    ],
  );
}

}


          // border: InputBorder.none,
          //  enabledBorder: InputBorder.none,
           // focusedBorder: InputBorder.none,