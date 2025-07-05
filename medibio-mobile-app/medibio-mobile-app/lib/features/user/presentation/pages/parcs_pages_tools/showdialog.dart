import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';

class DialogHelper {
  // Déclarer les contrôleurs et les données nécessaires
  static Map<String, TextEditingController> referenceControllers = {};
  static Map<String, TextEditingController> designationControllers = {};
  static Map<String, TextEditingController> commentaireControllers = {};
  static Map<String, Map<String, String>> intervenantData = {};
  static bool isTerminated = false; // Exemple de variable statique

  // Déclarer la fonction showCustomMultiSelectDialog
  static Future<List<String>> showCustomMultiSelectDialog({
    required BuildContext context,
    required List<String> options,
    required List<String> selectedOptions,
    String title = 'Sélectionnez des options',
  }) async {
    // Liste mutable pour stocker la sélection temporaire
    List<String> tempSelected = List.from(selectedOptions);

    // Réinitialiser les contrôleurs pour les articles sélectionnés
    for (var option in tempSelected) {
      String uniqueKey = option;
      referenceControllers[uniqueKey] = TextEditingController();
      designationControllers[uniqueKey] = TextEditingController();
      commentaireControllers[uniqueKey] = TextEditingController();
    }

    // Afficher le dialogue
    return await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      // Créer un identifiant unique pour chaque article (en utilisant un paramètre comme option ou id)
                      String uniqueKey = option; // Vous pouvez aussi ajouter un suffixe unique ici si besoin

                      // Initialiser les contrôleurs UNIQUES pour chaque article
                      if (!referenceControllers.containsKey(uniqueKey)) {
                        referenceControllers[uniqueKey] = TextEditingController();
                        designationControllers[uniqueKey] = TextEditingController();
                        commentaireControllers[uniqueKey] = TextEditingController();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Désignation (Personne physique)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          CheckboxListTile(
                            enabled: !isTerminated,
                            title: Text(
                              option,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            value: tempSelected.contains(option),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  tempSelected.add(option);
                                } else {
                                  tempSelected.remove(option);
                                }
                              });
                            },
                          ),
                          if (tempSelected.contains(option))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Champ Référence
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Référence (Emplacement)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: referenceControllers[uniqueKey],
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Champ Commentaire
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Commentaire d\'intervenant',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: commentaireControllers[uniqueKey],
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 4,
                                  minLines: 1,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: isTerminated
                          ? Colors.grey
                          : ThemeColors.buildCardBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Sauvegarder les valeurs des contrôleurs dans la Map avec des clés uniques
                    tempSelected.forEach((option) {
                      String uniqueKey = option;
                      intervenantData[option] = {
                        'Référence': referenceControllers[uniqueKey]!.text,
                        'Désignation':
                            designationControllers[uniqueKey]?.text ?? '',
                        'Commentaire': commentaireControllers[uniqueKey]!.text,
                      };
                    });
                    Navigator.of(context).pop(tempSelected);
                  },
                  child: Text(
                    'Valider',
                    style: TextStyle(
                      color: isTerminated
                          ? Colors.grey
                          : ThemeColors.buildCardBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ?? selectedOptions;
  }

  // Nettoyer les contrôleurs après utilisation
  static void clearControllers() {
    referenceControllers.clear();
    designationControllers.clear();
    commentaireControllers.clear();
  }
}