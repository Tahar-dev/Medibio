// ignore_for_file: dead_code

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';

import 'package:srasav_vf_v1/features/user/data/models/local_listarticle_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_listpiece_model.dart';

import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';

import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_bloc.dart';

import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_state.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_state.dart';

import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_state.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/components/build_card_widget.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/details_parcs_intervention.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/pdf_invoice_api.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/view_rapport_pdf.dart';
import 'package:uuid/uuid.dart';

class MyDialogController {
  final Map<String, TextEditingController> referenceControllers = {};
  final Map<String, TextEditingController> designationControllers = {};
  final Map<String, TextEditingController> commentaireControllers = {};
}
// ignore: unused_element
List<ArticleModel> _savedOptionsIntervenants = [];

List<String> optionsMainOeuvre = [];

List<String> articles = [];

List<String> articles2 = [];


String? loacalDuration;
bool isRunning = false;
// Map globale pour stocker les données saisies pour chaque intervenant
Map<String, Map<String, String>> intervenantData = {};

// Map pour stocker les contrôleurs de texte pour chaque intervenant
Map<String, TextEditingController> referenceControllers = {};
Map<String, TextEditingController> designationControllers = {};
Map<String, TextEditingController> commentaireControllers = {};

bool doesExist(String designation, Box<LocalListArticle> box) {
  return box.values
      .any((localArticle) => localArticle.designation == designation);
}

bool doesExist2(String designation, Box<LocalPieceArticle> box) {
  return box.values
      .any((localArticle) => localArticle.designation == designation);
}

// ignore: must_be_immutable
class RapportInterventionParc extends StatefulWidget {
  String? parcid;

  RapportInterventionParc({super.key, required this.parcid});

  @override
  // ignore: library_private_types_in_public_api
  _RapportInterventionParcState createState() =>
      _RapportInterventionParcState();
}

class _RapportInterventionParcState extends State<RapportInterventionParc> {
  late InterventionBloc interventionBloc;
  late InterventionState currentState;

  var counterText;




// Variable externe pour stocker les valeurs des contrôleurs
Map<String, Map<String, String>> savedValues = {};


// Déclarer les contrôleurs en dehors de la méthode pour qu'ils persistent
final Map<String, TextEditingController> referenceControllers = {};

final Map<String, TextEditingController> commentaireControllers = {};



Future<List<String>> showCustomMultiSelectDialog({
  required BuildContext context,
  required List<String> options,
  required List<String> selectedOptions,
  required ParcModel parc, // Passer l'objet parc en paramètre
  String title = 'Sélectionnez des options',
}) async {
  // Initialiser les contrôleurs avec les valeurs des articles existants
  if (parc.articles != null) {
    for (var article in parc.articles!) {
      if (article.type == "Main d'oeuvre") {
        // Utiliser l'ID de l'article comme clé
        referenceControllers[article.id!] = TextEditingController(text: article.ref);
        commentaireControllers[article.id!] = TextEditingController(text: article.commentaire);
      }
    }
  }

  // Liste mutable pour stocker la sélection temporaire
  List<String> tempSelected = List.from(selectedOptions);

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
                  children: options.asMap().entries.map((entry) {
// Utiliser l'index comme identifiant unique
                    String option = entry.value;

                    // Utiliser l'ID de l'option comme clé (si applicable)
                    String optionId = option; // ou une autre logique pour générer un ID unique

                    // Vérifier si les contrôleurs existent déjà avant de les initialiser
                    if (!referenceControllers.containsKey(optionId)) {
                      referenceControllers[optionId] = TextEditingController();
                    }
                    if (!commentaireControllers.containsKey(optionId)) {
                      commentaireControllers[optionId] = TextEditingController();
                    }

                    // Récupérer les contrôleurs existants
                    final referenceController = referenceControllers[optionId]!;
                    final commentaireController = commentaireControllers[optionId]!;

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
                                controller: referenceController,
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
                                controller: commentaireController,
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
                    color: ThemeColors.buildCardBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Sauvegarder les valeurs des contrôleurs dans la Map
                  for (var option in tempSelected) {
                    String optionId = option; // ou une autre logique pour générer un ID unique
                    savedValues[optionId] = {
                      'Référence': referenceControllers[optionId]!.text,
                      'Commentaire': commentaireControllers[optionId]!.text,
                    };
                  }
                  Navigator.of(context).pop(tempSelected);
                },
                child: Text(
                  'Valider',
                  style: TextStyle(
                    color: ThemeColors.buildCardBlue,
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
  ) ??
      selectedOptions;
}

  Future<List<Map<String, Object>>> showCustomMultiSelectDialog2({
    required BuildContext context,
    required List<String> options,
    required List<Map<String, Object>> selectedOptions,
    String title = 'Sélectionnez des options',
  }) async {
    // Liste mutable pour stocker la sélection temporaire avec quantité
    List<Map<String, Object>> tempSelected = List.from(selectedOptions);

    // Afficher le dialogue
    return await showDialog<List<Map<String, Object>>>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Container(
                      // Utilisation de MediaQuery pour définir la taille du dialogue de manière responsive
                      width: MediaQuery.of(context).size.width *
                          0.8, // 80% de la largeur de l'écran
                      height: MediaQuery.of(context).size.height *
                          0.6, // 60% de la hauteur de l'écran
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: options.map((option) {
                          // Vérifier si l'option est déjà sélectionnée
                          final existing = tempSelected.firstWhere(
                            (item) => item['designation'] == option,
                            orElse: () => <String, Object>{},
                          );

                          return CheckboxListTile(
                            enabled: !isTerminated,
                            title: Text(
                              option, // La variable de type String
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Texte en gras
                                fontSize: 20.0, // Augmente la taille du texte
                              ),
                            ),
                            value: existing
                                .isNotEmpty, // Vérifie si l'élément est présent
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  tempSelected.add(
                                      {'designation': option, 'quantity': 1});
                                } else {
                                  tempSelected.removeWhere(
                                      (item) => item['designation'] == option);
                                }
                              });
                            },
                            subtitle: existing.isNotEmpty
                                ? Row(
                                    children: [
                                      const Text(
                                        'Quantité: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      DropdownButton<int>(
                                        value: int.parse(
                                            existing['quantity'].toString()),
                                        items: List.generate(100, (index) {
                                          return DropdownMenuItem<int>(
                                            value: index + 1,
                                            child: Text('${index + 1}'),
                                          );
                                        }),
                                        onChanged: !isTerminated
                                            ? (newQuantity) {
                                                setState(() {
                                                  final index =
                                                      tempSelected.indexWhere(
                                                    (item) =>
                                                        item['designation'] ==
                                                        option,
                                                  );
                                                  if (index != -1 &&
                                                      newQuantity != null) {
                                                    tempSelected[index] = {
                                                      'designation': option,
                                                      'quantity': newQuantity,
                                                    };
                                                  }
                                                });
                                              }
                                            : null, // Désactive les changements si isTerminated == true
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Espacement entre les boutons
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(null); // Annuler la sélection
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
                        Navigator.of(context)
                            .pop(tempSelected); // Valider la sélection
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
        ) ??
        selectedOptions; // Retourne selectedOptions si le dialogue est annulé
  }

// ignore: non_constant_identifier_names
  void PrintSelectedParcDetails() {
    ParcModel? parc =
        (currentState as InterventionSelected).selecteditv.parcs?.firstWhere(
              (parc) => parc.id == widget.parcid,
              orElse: () => ParcModel(),
            );

    if (parc != null) {
      // Print details for the selected parc
      print('Parc ID: ${parc.id}');
      print('Résumé: ${parc.resume}');
      print('Observation: ${parc.observation}');
      print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      print('articles: ${parc.articles}');

      // _savedOptionsIntervenants=parc.articles;
      // Check if articles exist
      if (parc.articles != null) {
        for (var article in parc.articles!) {
          print('Article ID: ${article.id}');
          //print('Parc ID: ${article.parcid}');
          print('Désignation: ${article.id}');
          print('US: ${article.us}');
          print('Quantité: ${article.quantity}');
          print('Type: ${article.type}');
          print('Ref:${article.ref}');
          refController.text = article.ref ?? '';
          print('commenataire:${article.commentaire}');
          // String? _selectedIntervenants = article.id;
          // print("LIST INTERVENANTS: $_selectedIntervenants");
          _savedOptionsIntervenants = parc.articles!;
        }
      } else {
        print("Aucun article pour ce parc.");
      }
    } else {
      print("Aucun parc sélectionné.");
    }
  }

  List<String> _selectedOptionsIntervenants = [];

  List<String> _selectedOptionsIntervenantsRef = [];

  List<Map<String, Object>> _selectedOptionsPieces = [];

  TextEditingController otherProbController = TextEditingController();

  TextEditingController refController = TextEditingController();

  bool isTerminated = false;

  List<String>? ProblemOptions = [
    'Software & Firmware',
    'Mécanique',
    'Fluidique',
    'Réactif',
    'Électronique',
    'Util & Manip',
    'Autre'
  ];

  List<String> _selectedProblemOptions = [];

  List<String>? problemTypeList2 = [];
  // Liste des problèmes sélectionnés
  List<String>? _selectedCodes = [
    '1',
    '1',
    '1',
    '1',
    '1',
    '1',
    '1'
  ]; // Liste des codes correspondants aux problèmes sélectionnés

  List<String>? listCode = ['1', '1', '1', '1', '1', '1', '1'];

  int calculateTotalSeconds(String? stringDuration) {
    if (stringDuration!.length != 5) {
      throw ArgumentError("La chaîne doit contenir exactement 5 caractères.");
    }

    // Extraire les heures, minutes et secondes
    int hours = int.parse(stringDuration.substring(0, 1)); // 1er caractère
    int minutes =
        int.parse(stringDuration.substring(1, 3)); // 2e et 3e caractères
    int seconds =
        int.parse(stringDuration.substring(3, 5)); // 4e et 5e caractères

    // Calculer la durée totale en secondes
    int totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

    return totalSeconds;
  }

  String calcDuration(
      List<String>? realstarttimelist, List<String>? realendtimelist) {
    if (realstarttimelist == null ||
        realendtimelist == null ||
        realstarttimelist.isEmpty ||
        realendtimelist.isEmpty) {
      return "00000"; // Gérer le cas des listes vides ou nulles
    }

    // Vérifier que les listes ont la même longueur
    if (realstarttimelist.length != realendtimelist.length) {
      return "00000"; // Gérer le cas où les listes n'ont pas la même longueur
    }

    // Initialiser la durée totale en secondes
    int totalDurationInSeconds = 0;

    // Itérer sur les paires d'éléments des deux listes
    for (int i = 0; i < realstarttimelist.length; i++) {
      // Extraire l'heure, les minutes et les secondes du startTime
      String start = realstarttimelist[i];
      String end = realendtimelist[i];

      // Convertir le startTime en secondes depuis minuit
      int startHours =
          int.parse(start.substring(0, 2)); // 1ere 2eme caractères : heures
      int startMinutes =
          int.parse(start.substring(2, 4)); // 3eme et 4eme caractères : minutes
      int startSeconds = int.parse(
          start.substring(4, 6)); // 5eme et 6eme caractères : secondes
      int startTotalSeconds =
          (startHours * 3600) + (startMinutes * 60) + startSeconds;

      // Convertir le endTime en secondes depuis minuit
      int endHours = int.parse(end.substring(0, 2)); // 1er caractère : heures
      int endMinutes =
          int.parse(end.substring(2, 4)); // 2e et 3e caractères : minutes
      int endSeconds =
          int.parse(end.substring(4, 6)); // 4e et 5e caractères : secondes
      int endTotalSeconds = (endHours * 3600) + (endMinutes * 60) + endSeconds;

      // Ajouter la différence des secondes de cette paire à la durée totale
      totalDurationInSeconds += (endTotalSeconds - startTotalSeconds);
    }

    // Vérifier si la durée totale est négative (cela signifie que l'heure de fin est avant l'heure de début)
    if (totalDurationInSeconds < 0) {
      return "00000"; // Retourner 00000 si la durée est négative
    }

    // Convertir la durée totale en heures, minutes et secondes
    int hours = totalDurationInSeconds ~/ 3600;
    int minutes = (totalDurationInSeconds % 3600) ~/ 60;
    int seconds = totalDurationInSeconds % 60;

    // Formater la durée en "HHMMSS" avec 5 caractères
    String formattedHours = hours.toString();
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = seconds.toString().padLeft(2, '0');

    return '$formattedHours$formattedMinutes$formattedSeconds';
  }

  @override
  void initState() {
    super.initState();
    // Accessing the bloc and its current state
    interventionBloc = BlocProvider.of<InterventionBloc>(context);

    currentState = interventionBloc.state;

    context.read<ParcBloc>().add(LoadAllArticles());
    print("INFOS FROM SELECTED PARC FROM SELECTED ITV ***********************");
    PrintSelectedParcDetails();

    final existingIntitule = (currentState as InterventionSelected)
        .selecteditv
        .parcs
        ?.firstWhere(
          (parc) => parc.id == widget.parcid,
          orElse: () =>
              ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
        )
        .intitule;

    _intituleController = TextEditingController(text: existingIntitule ?? '');

    final existingCodeRapport = (currentState as InterventionSelected)
        .selecteditv
        .parcs
        ?.firstWhere(
          (parc) => parc.id == widget.parcid,
          orElse: () =>
              ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
        )
        .codeRapport;

    _codeRapportController =
        TextEditingController(text: existingCodeRapport ?? '');

    final existingResume = (currentState as InterventionSelected)
        .selecteditv
        .parcs
        ?.firstWhere(
          (parc) => parc.id == widget.parcid,
          orElse: () =>
              ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
        )
        .resume;

    _resumeTravauxController =
        TextEditingController(text: existingResume ?? '');

    final existingObservation = (currentState as InterventionSelected)
        .selecteditv
        .parcs
        ?.firstWhere(
          (parc) => parc.id == widget.parcid,
          orElse: () =>
              ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
        )
        .observation;

    _observatioController =
        TextEditingController(text: existingObservation ?? '');

    final existingDistance = (currentState as InterventionSelected)
        .selecteditv
        .parcs
        ?.firstWhere(
          (parc) => parc.id == widget.parcid,
          orElse: () =>
              ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
        )
        .articles
        ?.firstWhere(
          (article) =>
              article.type == "Déplacement" && article.quantity!.isNotEmpty,
          orElse: () =>
              ArticleModel(), // Fournir une valeur par défaut si aucun article n'est trouvé
        )
        .quantity;

    _distanceController2 = TextEditingController(text: existingDistance ?? '');

    isTerminated =
        (currentState as InterventionSelected).selecteditv.state == 'terminé';

//listCode = List<String>.filled(_problemOptions.length, '1');
//_selectedCodes = ['1','1','2','1','1','1','1']; // Codes initialisés à '1'

    // Placer la logique ici dans initState
    _selectedCodes = (currentState as InterventionSelected)
        .selecteditv
        .parcs
        ?.firstWhere(
          (parc) => parc.id == widget.parcid,
          orElse: () =>
              ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
        )
        .problemTypeList;
    //  listCode=['1','1','2','1','1','1','1','1','1','1'];

    problemTypeList2 = (currentState as InterventionSelected)
        .selecteditv
        .parcs
        ?.firstWhere(
          (parc) => parc.id == widget.parcid,
          orElse: () => ParcModel(),
        )
        .problemTypeList;

    if (problemTypeList2 != null && problemTypeList2!.length == 7) {
      for (int i = 0; i < problemTypeList2!.length; i++) {
        if (problemTypeList2![i] == "2") {
          _selectedProblemOptions.add(ProblemOptions![i]);
        }
      }
    } else {
      // Gérer le cas où la liste est null ou n'a pas la bonne longueur
      print("La liste problemTypeList est vide");
    }
    otherProbController.text = (currentState as InterventionSelected)
            .selecteditv
            .parcs
            ?.firstWhere(
              (parc) => parc.id == widget.parcid,
              orElse: () => ParcModel(),
            )
            .problemType ??
        ""; // Si problemType est null, initialise avec une chaîne vide

    loacalDuration = calcDuration(
        (currentState as InterventionSelected).selecteditv.realstarttimelist,
        (currentState as InterventionSelected).selecteditv.realendtimelist);

    print("DURATION $loacalDuration");

    print("IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
    print((currentState as InterventionSelected).selecteditv.isSaved);

    print("BLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLBLB");
    print((currentState as InterventionSelected).selecteditv.BL);

  }

  Future<void> _showMultiSelectDialogProb() async {
    final result = await showCustomMultiSelectDialogProb(
      context: context,
      options: _problemOptions,
      listCode: _selectedCodes,
    );

    if (result != null) {
      setState(() {
        _selectedCodes = result;
        _selectedProblemOptions = _problemOptions
            .asMap()
            .entries
            .where((entry) =>
                _selectedCodes![entry.key] == '2') // Filtre les options cochées
            .map((entry) => entry.value)
            .toList();

        (currentState as InterventionSelected)
            .selecteditv
            .parcs
            ?.firstWhere(
              (parc) => parc.id == widget.parcid,
              orElse: () =>
                  ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
            )
            .problemTypeList = _selectedCodes!;
      });
    }
  }

//bool isRunning = false;
  @override
  void dispose() {
    _resumeTravauxController.dispose();
    _observatioController.dispose();
    _intituleController.dispose();
    _codeRapportController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  List<String> selectedIntervenants2 = [];
  List<String> selectedAutresFrais2 = [];

  TextEditingController _distanceController2 = TextEditingController();

  final List<String> _problemOptions = [
    'Software & Firmware',
    'Mécanique',
    'Fluidique',
    'Réactif',
    'Électronique',
    'Util & Manip',
    'Autre'
  ];

  TextEditingController _intituleController = TextEditingController();
  TextEditingController _codeRapportController = TextEditingController();
  TextEditingController _resumeTravauxController = TextEditingController();
  TextEditingController _observatioController = TextEditingController();

  Timer? _timer;
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  String _formatElapsedTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$secs";
  }

  DateTime parseDate(String dateString) {
    if (dateString.length != 8) {
      throw const FormatException(
          "La chaîne de date doit comporter 8 caractères au format yyyyMMdd");
    }
    int year = int.parse(dateString.substring(0, 4));
    int month = int.parse(dateString.substring(4, 6));
    int day = int.parse(dateString.substring(6, 8));
    return DateTime(year, month, day);
  }

  TimeOfDay parseDuration(String durationString) {
    if (durationString.length != 5) {
      throw const FormatException(
          "La chaîne de durée doit comporter 5 caractères au format xHHMM");
    }
    String relevantPart = durationString.substring(1);
    int hours = int.parse(relevantPart.substring(0, 2));
    int minutes = int.parse(relevantPart.substring(2, 4));
    return TimeOfDay(hour: hours, minute: minutes);
  }

  String timeOfDayToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours H $minutes M";
  }

  TimeOfDay parseTime(String timeString) {
    if (timeString.length != 4) {
      throw const FormatException(
          "La chaîne de temps doit comporter 4 caractères au format HHmm");
    }

    int hour = int.parse(timeString.substring(0, 2));
    int minute = int.parse(timeString.substring(2, 4));

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw const FormatException(
          "Les heures doivent être entre 00 et 23, et les minutes entre 00 et 59");
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Combine une date et un temps pour retourner un DateTime formaté
  String combineDateAndTime(String dateString, String timeString) {
    DateTime date = parseDate(dateString);
    TimeOfDay time = parseTime(timeString);

    DateTime dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    // Retourne la date et l'heure au format 'yyyy-MM-dd HH:mm'
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

// Fonction pour parser et formater la date
  String formatDate(String dateString) {
    DateTime date = DateTime.parse(
        dateString); // On suppose que la date est déjà dans un format ISO 8601
    return DateFormat('yyyy-MM-dd')
        .format(date); // Formate la date en 'yyyy-MM-dd'
  }

  String formatTime(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    ParcModel? parc =
        (currentState as InterventionSelected).selecteditv.parcs?.firstWhere(
              (parc) => parc.id == widget.parcid,
              orElse: () => ParcModel(),
            ) as ParcModel?;

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text(
                    'Rapport de l\'intervention',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: () {
                        print('refresh button clickedddddTssT');

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Actualisation de données 🔁'),
                            backgroundColor: Color.fromARGB(255, 24, 113, 172),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.filePdf),
                      color: Colors.white,
                      onPressed: () async {
                        // Sauvegarder le contexte initial
                        final stableContext = context;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shpcounterText', counterText);
                        // Récupérer le parc avec les articles associés
                        final parc = (currentState as InterventionSelected)
                            .selecteditv
                            .parcs
                            ?.firstWhere(
                              (parc) => parc.id == widget.parcid,
                            );

                        // Listes pour différents types d'articles
                        List<String> typesMainDoeuvreArticles = [];
                        List<String> designationMainDoeuvreArticles = [];
                        List<String> quantityMainDoeuvreArticles = [];

                        List<String> typesPiecesArticles = [];
                        List<String> designationPiecesArticles = [];
                        List<String> quantityPiecesArticles = [];

                        List<String> typesDeplacementArticles = [];
                        List<String> designationDeplacementArticles = [];
                        List<String> quantityDeplacementArticles = [];

                        List<String> listParcIdRepeter = [];
                        List<String> listParcDateRepeter = [];
                        List<String> listFacturableRepeter = [];

                        List<String> listUnitMIN = [];
                        List<String> listUnitPIECE = [];
                        List<String> listUnitKM = [];

                        if (parc != null && parc.articles!.isNotEmpty) {
                          for (var article in parc.articles!) {
                            if (article.type == "Main d'oeuvre" ||
                                article.type == "Pièce" ||
                                article.type == "Déplacement") {
                              listParcIdRepeter.add(parc.id.toString());
                              listParcDateRepeter.add(formatDate(
                                  (currentState as InterventionSelected)
                                      .selecteditv
                                      .date!));
                              listFacturableRepeter.add('Oui');
                            }

                            if (article.type == "Main d'oeuvre") {
                              typesMainDoeuvreArticles
                                  .add(article.type.toString());
                              designationMainDoeuvreArticles
                                  .add(article.id.toString());
                              quantityMainDoeuvreArticles
                                  .add(article.quantity.toString());
                              listUnitMIN.add('MIN');
                            }

                            if (article.type == "Pièce") {
                              typesPiecesArticles.add(article.type.toString());
                              designationPiecesArticles
                                  .add(article.id.toString());
                              quantityPiecesArticles
                                  .add(article.quantity.toString());
                              listUnitPIECE.add('PIECE');
                            }

                            if (article.type == "Déplacement") {
                              typesDeplacementArticles
                                  .add(article.type.toString());
                              designationDeplacementArticles
                                  .add(article.id.toString());
                              quantityDeplacementArticles
                                  .add(article.quantity.toString());
                              listUnitKM.add('KM');
                            }
                          }
                        }

                        // Conversion des listes en chaînes de caractères
                        String typesToutArticles2 = [
                          typesMainDoeuvreArticles.join('\n'),
                          typesPiecesArticles.join('\n'),
                          typesDeplacementArticles.join('\n'),
                        ].where((element) => element.isNotEmpty).join('\n');

                        String designationsToutArticles2 = [
                          designationMainDoeuvreArticles.join('\n'),
                          designationPiecesArticles.join('\n'),
                          designationDeplacementArticles.join('\n'),
                        ].where((element) => element.isNotEmpty).join('\n');

                        String quantityToutArticles2 = [
                          quantityMainDoeuvreArticles.join('\n'),
                          quantityPiecesArticles.join('\n'),
                          quantityDeplacementArticles.join('\n'),
                        ].where((element) => element.isNotEmpty).join('\n');

                        String typesToutUnit = [
                          listUnitMIN.join('\n'),
                          listUnitPIECE.join('\n'),
                          listUnitKM.join('\n'),
                        ].where((element) => element.isNotEmpty).join('\n');

                        String listParcIdRepeter2 =
                            listParcIdRepeter.join('\n');
                        String listParcDateRepeter2 =
                            listParcDateRepeter.join('\n');
                        String listFacturableRepeter2 =
                            listFacturableRepeter.join('\n');
final selectedItv = (currentState as InterventionSelected).selecteditv;
final startdaytime = [
  selectedItv.realstartdaylist?.firstOrNull,
  selectedItv.realstarttimelist?.firstOrNull
].whereType<String>().map((s) => s.length == 8 ? 
  '${s.substring(0, 4)}-${s.substring(4, 6)}-${s.substring(6, 8)}' : 
  (s.length == 6 ? 
    '${s.substring(0, 2)}:${s.substring(2, 4)}:${s.substring(4, 6)}' : 
    ''
  )
).join(' ').trim();
                        // Génération et ouverture du PDF
                        try {
                          final pdfFile = await PdfInvoiceApi.generate(
                            PdfColors.black,
                              (currentState as InterventionSelected)
                                    .selecteditv
                                    .BL
                                    .toString() ??
                                '',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .id
                                    .toString() ??
                                '',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .description
                                    .toString() ??
                                '',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .client
                                    .toString() ??
                                '',
                            parc?.designation.toString() ?? 'Parc inconnu',
                            parc?.marque.toString() ?? 'Marque inconnue',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .couvertureglobale
                                    .toString() ??
                                '',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .lieu
                                    .toString() ??
                                '',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .type
                                    .toString() ??
                                '',
  startdaytime,
   DateTime.now().toString().substring(0, 19),
                            counterText,
                            parc?.observation.toString() ?? 'OBSERVATION VIDE',
                            parc?.resume.toString() ?? 'RESUME VIDE',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .technicienRealName
                                    .toString() ??
                                '',
                            designationsToutArticles2 ?? '',
                            parc?.id.toString() ?? 'Parc inconnu',
                            typesToutArticles2 ?? '',
                            quantityToutArticles2 ?? '',
                            listParcIdRepeter2 ?? '',
                            typesToutUnit ?? '',
                            listParcDateRepeter2 ?? '',
                            listFacturableRepeter2 ?? '',
                            "",
                            (currentState as InterventionSelected)
                                .selecteditv
                                .attitudeApparenceItv
                                .toString(),
                            (currentState as InterventionSelected)
                                .selecteditv
                                .qualityPrestationItv
                                .toString(),
                            (currentState as InterventionSelected)
                                .selecteditv
                                .communicationItv
                                .toString(),
                            (currentState as InterventionSelected)
                                .selecteditv
                                .globlementItv
                                .toString(),
                          );

                          if (pdfFile.existsSync()) {
                            Navigator.push(
                              stableContext,
                              MaterialPageRoute(
                                builder: (context) => PdfViewerPage(
                                  // id: widget.id,

                                  file: pdfFile,
                                  parcid: widget.parcid.toString(),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(stableContext).showSnackBar(
                              const SnackBar(
                                  content: Text('Erreur : PDF non généré.')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(stableContext).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Erreur lors de la génération du PDF : $e')),
                          );
                        }
                      },
                    ),
                  ],
                  backgroundColor: ThemeColors.buildCardBlue,
                  leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsParcsIntervention(

                                //  id: widget.id,

                                ),
                          ),
                        );
                        if ((currentState as InterventionSelected)
                                .selecteditv
                                .realendtimelist!
                                .length !=
                            (currentState as InterventionSelected)
                                .selecteditv
                                .realstarttimelist!
                                .length) {
                          

                          (currentState as InterventionSelected)
                              .selecteditv
                              .realendtimelist
                              ?.add(DateTime.now()
                                  .toString()
                                  .substring(11, 19)
                                  .replaceAll(':', ''));

                          print(
                              "REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                          print((currentState as InterventionSelected)
                              .selecteditv
                              .realstarttimelist
                              .toString());

                          print(
                              "REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                          print((currentState as InterventionSelected)
                              .selecteditv
                              .realendtimelist
                              .toString());

                          print(
                              "DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                          print((currentState as InterventionSelected)
                              .selecteditv
                              .realstartdaylist
                              .toString());
                        } else {
                          print(
                              "REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                          print((currentState as InterventionSelected)
                              .selecteditv
                              .realstarttimelist
                              .toString());

                          print(
                              "REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                          print((currentState as InterventionSelected)
                              .selecteditv
                              .realendtimelist
                              .toString());

                          print(
                              "DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                          print((currentState as InterventionSelected)
                              .selecteditv
                              .realstartdaylist
                              .toString());
                        }
                      }),
                ),
                Container(
                  width: double.infinity, // Largeur complète
                  height: 3, // Épaisseur de la ligne
                  color: Colors.white, // Couleur de la ligne
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardUtils.buildCard(
                        context: context,
                        interventionIdLabel: 'Intervention ID : ',
                        interventionIdValue:
                            (currentState as InterventionSelected)
                                .selecteditv
                                .id
                                .toString(),
                        datedebutplanfieeValue: combineDateAndTime(
                          (currentState as InterventionSelected)
                              .selecteditv
                              .date!,
                          (currentState as InterventionSelected)
                              .selecteditv
                              .debuteHour!,
                        ).toString(),
                        datefinplanfieeValue: combineDateAndTime(
                          (currentState as InterventionSelected)
                              .selecteditv
                              .enddate!,
                          (currentState as InterventionSelected)
                              .selecteditv
                              .finishHour!,
                        ).toString(),
                        child: BlocBuilder<TimerBloc, TimerState>(
                          builder: (context, state) {
                            // Vérifie si l'état actuel contient un compteur valide
                            counterText =
                                (state is TimerRunning || state is TimerPausing)
                                    ? formatTime(state.counter)
                                    : formatTime(state.counter);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Aligner les éléments verticalement au centre
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // Centrer horizontalement
                              children: [
                                // Informations principales avec icône et texte
                                _buildInfoColumn(
                                  icon: FontAwesomeIcons.solidClock,
                                  text1: counterText,
                                  text2: timeOfDayToString(
                                    parseDuration(
                                      (currentState as InterventionSelected)
                                              .selecteditv
                                              .duration ??
                                          "0000",
                                    ),
                                  ),
                                ),

                                // Espacement réduit entre les colonnes et la ligne
                                const SizedBox(height: 8),

                                // Ligne pour les boutons de contrôle (play/pause et reset)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Centrer les boutons horizontalement
                                  children: [
                                    // Bouton play/pause
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors.bleuCiel,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.08,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.08,
                                      child: BlocBuilder<TimerBloc, TimerState>(
                                        builder: (context, state) {
                                          isRunning = state
                                              is TimerRunning; // Détermine si le timer est en cours

                                          return IconButton(
                                            icon: Icon(
                                              isRunning
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              color: Colors.white,
                                            ),
                                            onPressed: isTerminated
                                                ? null
                                                : () {
                                                    if (isRunning) {
                                                      context
                                                          .read<TimerBloc>()
                                                          .add(TimerPaused());

                                                      (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realendtimelist
                                                          ?.add(DateTime.now()
                                                              .toString()
                                                              .substring(11, 19)
                                                              .replaceAll(
                                                                  ':', ''));

                                                      print(
                                                          "REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstarttimelist
                                                          .toString());

                                                      print(
                                                          "REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realendtimelist
                                                          .toString());

                                                      print(
                                                          "DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstartdaylist
                                                          .toString());
                                                    } else {
                                                      context
                                                          .read<TimerBloc>()
                                                          .add(TimerStarted());
                                                      (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstarttimelist
                                                          ?.add(DateTime.now()
                                                              .toString()
                                                              .substring(11, 19)
                                                              .replaceAll(
                                                                  ':', ''));

                                                      print(
                                                          "REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstarttimelist
                                                          .toString());

                                                      print(
                                                          "REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realendtimelist
                                                          .toString());

                                                      (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstartdaylist
                                                          ?.add(DateTime.now()
                                                              .toString()
                                                              .substring(0, 10)
                                                              .replaceAll(
                                                                  '-', ''));
                                                      print(
                                                          "DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstartdaylist
                                                          .toString());
                                                    }
                                                  },
                                          );
                                        },
                                      ),
                                    ),

                                    // Espacement horizontal réduit
                                    const SizedBox(width: 12),

                                    // Bouton reset
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors
                                                .bleuCiel, // Fond gris si terminé
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.08,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.08,
                                      child: IconButton(
                                          icon: Icon(
                                            Icons
                                                .refresh, // Icône pour le bouton reset
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            color: Colors
                                                .white, // Icône reste blanche
                                          ),
                                          onPressed: isTerminated
                                              ? null
                                              : () {
                                                  context
                                                      .read<TimerBloc>()
                                                      .add(TimerReset());
                                                  print(
                                                      "DURATIONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
                                                  loacalDuration = calcDuration(
                                                      (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstarttimelist,
                                                      (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realendtimelist);
                                                  print(loacalDuration);
                                                }),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        )),
                    SizedBox(height: screenHeight * 0.02),
                    Column(
                      children: [
                        _itemTextField1(Icons.code, 'Code Rapport'),
                        _itemTextField2(Icons.title, 'Intitulé'),
                        _itemProfile(
                            Icons.person,
                            'Techniciens',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .technicienRealName ??
                                'Non défini'),
                        _itemProfile(
                            Icons.people,
                            'Client',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .client ??
                                'Non défini'),
                        _itemProfile(
                            Icons.location_city,
                            'Site',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .lieu ??
                                'Non défini'),
                        _itemProfile(Icons.numbers, 'N° Série', 'N° Série'),
                        _itemProfile(
                            Icons.location_on, 'Localisation', 'Localisation'),
                        _itemProfile(
                            Icons.location_history, 'Réference', 'Client'),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        const Text(
                          'Problème-type',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.buildCardBlue),
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
/**      ElevatedButton(
  onPressed: () async {
    final selectedParc = (currentState as InterventionSelected)
        .selecteditv
        .parcs
        ?.firstWhere((parc) => parc.id == widget.parcid, orElse: () => ParcModel());

    if (selectedParc != null && selectedParc.articles != null && _selectedOptionsPieces.isEmpty) {
      _selectedOptionsPieces = selectedParc.articles!
          .where((article) => article.type == "Pièce")
          .map((article) => article.id ?? "")
          .toList();
    }

    // Ouverture de la boîte de dialogue pour sélectionner les articles et la quantité
    List<Map<String, dynamic>> result = await showCustomMultiSelectDialog2(
      context: context,
      options: optionsPiece, // Liste des options disponibles
      selectedOptions: _selectedOptionsPieces, // Options sélectionnées actuelles
      title: 'PDR',
    );

    setState(() {
      // Mettre à jour les options sélectionnées
      if (result != null) {
        _selectedOptionsPieces = result.map((e) => e['designation'] as String).toList();

        if (selectedParc != null && selectedParc.articles != null) {
          // Suppression des anciens articles "Pièce"
          selectedParc.articles!.removeWhere((article) => article.type == "Pièce");

          // Ajout des nouveaux articles sélectionnés avec leur quantité
          for (var item in result) {
            final newArticle = ArticleModel(
              id: "Article_${DateTime.now().millisecondsSinceEpoch}",
              parcid: selectedParc.id,
              designation: item['designation'],
              us: "UN",
              quantity: item['quantity'].toString(),
              type: "Pièce",
            );
            selectedParc.articles!.add(newArticle);
            print('Nouvel article ajouté : ${newarticle.id} avec quantité ${newArticle.quantity}');
          }
        }
      }
    });
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'PDR',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isTerminated ? Colors.grey :ThemeColors.buildCardBlue,
        ),
      ),
      Icon(Icons.build,color: isTerminated ? Colors.grey :ThemeColors.buildCardBlue, ),
    ],
  ),
), */
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isTerminated
                                  ? Colors.grey
                                  : ThemeColors.buildCardBlue,
                              width: 2,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: isTerminated
                                ? () {
                                    print("Session terminée");
                                  }
                                : _showMultiSelectDialogProb,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Problèmes-Types',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isTerminated
                                        ? Colors.grey
                                        : ThemeColors.buildCardBlue,
                                  ),
                                ),
                                Icon(Icons.bug_report,
                                    color: isTerminated
                                        ? Colors.grey
                                        : ThemeColors.buildCardBlue),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Builder(
                            builder: (context) {
                              if (_selectedProblemOptions!.isEmpty) {
                                return Text(
                                  "",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                );
                              }

                              return Align(
                                alignment: Alignment
                                    .centerLeft, // Forcer l'alignement à gauche
                                child: Wrap(
                                  alignment: WrapAlignment
                                      .start, // Assurer que les éléments restent collés à gauche
                                  spacing:
                                      8.0, // Espacement horizontal entre les containers
                                  runSpacing:
                                      4.0, // Espacement vertical entre les lignes
                                  children: _selectedProblemOptions!
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    // int index = entry.key;
                                    String problem = entry.value;
                                    //String code = _selectedCodes[index]; // Récupère le code correspondant

                                    return Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors.buildCardBlue,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        problem,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),

// MultiSelectDialogField avec gestion d'état

/*IgnorePointer(
  ignoring: true,
  child: MultiSelectDialogField(
    items: _problemOptions.map((e) => MultiSelectItem(e, e)).toList(),
    title: Text(
      'Problème-type',
      style: TextStyle(
        fontSize: 16,
        color: isTerminated ? Colors.grey : null,
      ),
    ),
    selectedColor: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
    dialogHeight: MediaQuery.of(context).size.height * 0.45,
    decoration: BoxDecoration(
      color: isTerminated ? Colors.grey.shade200 : Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
        width: 2,
      ),
    ),
    buttonIcon: Icon(
      Icons.bug_report,
      color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
    ),
    buttonText: Text(
      "Problèmes",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
      ),
    ),
    onConfirm: (values) {
      if (!isTerminated) {
        setState(() {
          _selectedOptionsProbleme = values.cast<String>();
          _showOtherField = _selectedOptionsProbleme.contains('Autre');
        });
      }
    },
  ),
),*/

// Champ texte pour "Autre problème"
/*if (_showOtherField)
  AnimatedContainer(
    duration: const Duration(milliseconds: 500),
    child: TextField(
      enabled: !isTerminated,
      controller: _otherController,
      decoration: InputDecoration(
        labelText: 'Autre Problème',
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    ),
  ),*/

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        const Align(
                          alignment:
                              Alignment.centerLeft, // Aligne le texte à gauche
                          child: Text(
                            'Résumé de travaux',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.buildCardBlue,
                            ),
                          ),
                        ),

                        TextField(
                          controller: _resumeTravauxController,
                          enabled: !isTerminated,
                          decoration: InputDecoration(
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.check,
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                              ),
                              onPressed: () {
                                // Mise à jour de la valeur du résumé
                                final selectedParc =
                                    (currentState as InterventionSelected)
                                        .selecteditv
                                        .parcs
                                        ?.firstWhere(
                                            (parc) => parc.id == widget.parcid);

                                if (selectedParc != null) {
                                  selectedParc.resume =
                                      _resumeTravauxController.text;
                                  // Ajoute ici la logique pour sauvegarder ou rafraîchir l'état
                                }

                                // Ferme le clavier
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 6,
                          minLines: 3,
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        const Align(
                          alignment:
                              Alignment.centerLeft, // Aligne le texte à gauche
                          child: Text(
                            'Commentaire - Observation',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.buildCardBlue,
                            ),
                          ),
                        ),

                        TextField(
                          controller: _observatioController,
                          enabled: !isTerminated,
                          decoration: InputDecoration(
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.check,
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                              ),
                              onPressed: () {
                                // Mise à jour de la valeur du résumé
                                final selectedParc =
                                    (currentState as InterventionSelected)
                                        .selecteditv
                                        .parcs
                                        ?.firstWhere(
                                            (parc) => parc.id == widget.parcid);

                                if (selectedParc != null) {
                                  selectedParc.observation =
                                      _observatioController.text;
                                  // Ajoute ici la logique pour sauvegarder ou rafraîchir l'état
                                }

                                // Ferme le clavier
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 6,
                          minLines: 3,
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        const Text(
                          'Consommation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.buildCardBlue,
                          ),
                        ),

// Appel de la boîte de dialogue personnalisée
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        BlocBuilder<ParcBloc, ParcState>(
                          builder: (context, state) {
                            // Accès à la boîte Hive pour stocker et récupérer les options
                            final box =
                                Hive.box<LocalListArticle>('BoxMainOeuvreList');

                            // Récupération et mise à jour des articles "Main d'oeuvre" dans la boîte Hive
                            if (state is ArticleListLoaded) {
                              articles = state.articlesList
                                  .where((article) =>
                                      article.type == "Main d'oeuvre" &&
                                      article.id != null)
                                  .map((article) => article.id!)
                                  .toList();

                              for (var designation in articles) {
                                if (!doesExist(designation, box)) {
                                  box.add(LocalListArticle(
                                      designation: designation));
                                }
                              }
                            }

                            // Récupération des options depuis Hive
                            final optionsMainOeuvre = box.values
                                .map((localArticle) => localArticle.designation)
                                .where((designation) => designation != null)
                                .cast<String>()
                                .toList();

                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isTerminated
                                      ? Colors.grey
                                      : ThemeColors.buildCardBlue,
                                  width: 2,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: isTerminated
                                    ? () {
                                        print("Session terminée");
                                      }
                                    : () async {
                                        // Récupération de l'état actuel pour le parc sélectionné
                                        // Récupération de l'état actuel pour le parc sélectionné
                                        final selectedParc = (currentState
                                                as InterventionSelected)
                                            .selecteditv
                                            .parcs
                                            ?.firstWhere(
                                                (parc) =>
                                                    parc.id == widget.parcid,
                                                orElse: () => ParcModel());

// Vérification que selectedParc et ses articles ne sont pas null avant d'accéder à leurs valeurs
                                        if (selectedParc?.articles != null &&
                                            _selectedOptionsIntervenants
                                                .isEmpty) {
                                          _selectedOptionsIntervenants =
                                              selectedParc!.articles!
                                                  .where((article) =>
                                                      article.type ==
                                                      "Main d'oeuvre")
                                                  .map((article) =>
                                                      article.id ?? "")
                                                  .toList();
                                        }
                                        print(
                                            "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ");
                                        print(_selectedOptionsIntervenants);

// Vérification que selectedParc et ses articles ne sont pas null avant d'accéder à leurs valeurs
                                        if (selectedParc?.articles != null &&
                                            _selectedOptionsIntervenantsRef
                                                .isEmpty) {
                                          _selectedOptionsIntervenantsRef =
                                              selectedParc!.articles!
                                                  .where((article) =>
                                                      article.type ==
                                                      "Main d'oeuvre")
                                                  .map((article) =>
                                                      article.ref ?? "")
                                                  .toList();
                                        }
                                        print(
                                            "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
                                        print(_selectedOptionsIntervenantsRef);

                                        // Ouverture de la boîte de dialogue
                                List<String> result = await showCustomMultiSelectDialog(
  context: context,
  options: optionsMainOeuvre, // Liste des options disponibles
  selectedOptions: _selectedOptionsIntervenants, // Options sélectionnées actuelles
  parc: selectedParc!, // Passer l'objet parc pour initialiser les contrôleurs
  title: 'Intervenants',
);

setState(() {
  // Mettre à jour les options sélectionnées
  _selectedOptionsIntervenants = result ?? _selectedOptionsIntervenants;

  if (selectedParc != null && selectedParc.articles != null) {
    // Suppression des anciens articles "Main d'oeuvre"
    selectedParc.articles!.removeWhere(
      (article) => article.type == "Main d'oeuvre",
    );

    // Ajout des nouveaux articles sélectionnés
    for (String intervenant in _selectedOptionsIntervenants) {
      // Récupérer l'index de l'intervenant dans la liste des options
      optionsMainOeuvre.indexOf(intervenant);

      // Récupérer les valeurs des contrôleurs pour cet intervenant
      String reference = referenceControllers[intervenant]?.text ?? '';
      String commentaire = commentaireControllers[intervenant]?.text ?? '';

      // Créer un nouvel article
      final newArticle = ArticleModel(
        id: intervenant,
        parcid: selectedParc.id,
        designation: intervenant,
        us: "UN",
        quantity: "1",
        type: "Main d'oeuvre",
        ref: reference, // Utiliser la valeur du contrôleur "Référence"
        commentaire: commentaire, // Utiliser la valeur du contrôleur "Commentaire"
      );

      // Ajouter le nouvel article à la liste des articles du parc
      selectedParc.articles!.add(newArticle);
    }
  }
});
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Intervenants',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors.buildCardBlue,
                                      ),
                                    ),
                                    Icon(
                                      Icons.people,
                                      color: isTerminated
                                          ? Colors.grey
                                          : ThemeColors.buildCardBlue,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Builder(
                            builder: (context) {
                              final selectedParc =
                                  (currentState as InterventionSelected)
                                      .selecteditv
                                      .parcs
                                      ?.firstWhere(
                                          (parc) => parc.id == widget.parcid,
                                          orElse: () => ParcModel());

                              if (selectedParc == null ||
                                  selectedParc.articles == null ||
                                  selectedParc.articles!.isEmpty) {
                                return const Text(
                                  "",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey),
                                );
                              }

                              final articlesMainOeuvre = selectedParc.articles!
                                  .where((article) =>
                                      article.type == "Main d'oeuvre")
                                  .toList();

                              if (articlesMainOeuvre.isEmpty) {
                                return const Text(
                                  "",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                );
                              }

                              return Align(
                                alignment: Alignment
                                    .centerLeft, // Aligner le contenu à gauche
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: articlesMainOeuvre.map((article) {
                                    return Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors.buildCardBlue,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        article.id ?? 'Désignation inconnue',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),

                        BlocBuilder<ParcBloc, ParcState>(
                          builder: (context, state) {
                            // Accès à la boîte Hive pour stocker et récupérer les options
                            final box2 =
                                Hive.box<LocalPieceArticle>('BoxPieceList');

                            // Récupération et mise à jour des articles "Main d'oeuvre" dans la boîte Hive
                            if (state is ArticleListLoaded) {
                              articles2 = state.articlesList
                                  .where((article) =>
                                      article.type == "Pièce" &&
                                      article.id != null)
                                  .map((article) => article.id!)
                                  .toList();

                              for (var designation in articles2) {
                                if (!doesExist2(designation, box2)) {
                                  box2.add(LocalPieceArticle(
                                      designation: designation));
                                }
                              }
                            }

                            // Récupération des options depuis Hive
                            final optionsPiece = box2.values
                                .map((localArticle) => localArticle.designation)
                                .where((designation) => designation != null)
                                .cast<String>()
                                .toList();

                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isTerminated
                                      ? Colors.grey
                                      : ThemeColors.buildCardBlue,
                                  width: 2,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: isTerminated
                                    ? () {
                                        print("Session terminée");
                                      }
                                    : () async {
                                        final selectedParc = (currentState
                                                as InterventionSelected)
                                            .selecteditv
                                            .parcs
                                            ?.firstWhere(
                                                (parc) =>
                                                    parc.id == widget.parcid,
                                                orElse: () => ParcModel());
                                        if (selectedParc != null &&
                                            selectedParc.articles != null &&
                                            _selectedOptionsPieces.isEmpty) {
                                          _selectedOptionsPieces = selectedParc
                                              .articles!
                                              .where((article) =>
                                                  article.type == "Pièce")
                                              .map((article) => {
                                                    'designation':
                                                        article.id ?? "",
                                                    'quantity': article
                                                            .quantity ??
                                                        "", // Ajoutez d'autres attributs si nécessaire
                                                  })
                                              .toList();
                                        }

                                        // Ouverture de la boîte de dialogue pour sélectionner les articles et la quantité
                                        List<Map<String, dynamic>> result =
                                            await showCustomMultiSelectDialog2(
                                          context: context,
                                          options:
                                              optionsPiece, // Liste des options disponibles
                                          selectedOptions:
                                              _selectedOptionsPieces, // Options sélectionnées actuelles
                                          title: 'PDR',
                                        );

                                        setState(() {
                                          // Mettre à jour les options sélectionnées
                                          if (result != null) {
                                            _selectedOptionsPieces =
                                                List<Map<String, Object>>.from(
                                                    result);

                                            if (selectedParc != null &&
                                                selectedParc.articles != null) {
                                              // Suppression des anciens articles "Pièce"
                                              selectedParc.articles!
                                                  .removeWhere((article) =>
                                                      article.type == "Pièce");

                                              // Ajout des nouveaux articles sélectionnés avec leur quantité
                                              for (var item in result) {
                                                final newArticle = ArticleModel(
                                                  id: item['designation'],
                                                  parcid: selectedParc.id,
                                                  designation:
                                                      item['designation'],
                                                  us: "UN",
                                                  quantity: item['quantity']
                                                      .toString(),
                                                  type: "Pièce",
                                                );
                                                selectedParc.articles!
                                                    .add(newArticle);
                                                print(
                                                    'Nouvel article ajouté : ${newArticle.id} avec quantité ${newArticle.quantity}');
                                              }
                                            }
                                          }
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PDR',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors.buildCardBlue,
                                      ),
                                    ),
                                    Icon(
                                      Icons.build,
                                      color: isTerminated
                                          ? Colors.grey
                                          : ThemeColors.buildCardBlue,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Builder(
                            builder: (context) {
                              final selectedParc =
                                  (currentState as InterventionSelected)
                                      .selecteditv
                                      .parcs
                                      ?.firstWhere(
                                          (parc) => parc.id == widget.parcid,
                                          orElse: () => ParcModel());

                              if (selectedParc?.articles == null ||
                                  selectedParc!.articles!.isEmpty) {
                                return const Text(
                                  "",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey),
                                );
                              }

                              final articlesPiece = selectedParc.articles!
                                  .where((article) => article.type == "Pièce")
                                  .toList();

                              if (articlesPiece.isEmpty) {
                                return const Text(
                                  "",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                );
                              }

                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: articlesPiece.map((article) {
                                    String quantity = article.quantity ?? '0';

                                    return Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors.buildCardBlue,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            article.id ??
                                                'Désignation inconnue',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Qté: $quantity',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),

//SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        const Align(
                          alignment:
                              Alignment.centerLeft, // Aligne le texte à gauche
                          child: Text(
                            'Distance de déplacement (en Km)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.buildCardBlue,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _distanceController2,
                          enabled: !isTerminated,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isTerminated
                                    ? Colors.grey
                                    : ThemeColors.buildCardBlue,
                                width: 2.0,
                              ),
                            ),
                            hintText: (() {
                              final selectedParc =
                                  (currentState as InterventionSelected)
                                      .selecteditv
                                      .parcs
                                      ?.firstWhere(
                                        (parc) => parc.id == widget.parcid,
                                        orElse: () =>
                                            ParcModel(), // Default value when no match is found
                                      );

                              if (selectedParc != null) {
                                final existingArticleIndex =
                                    selectedParc.articles?.indexWhere(
                                  (article) =>
                                      article.type == "Déplacement" &&
                                      article.quantity?.isNotEmpty == true,
                                );

                                if (existingArticleIndex != null &&
                                    existingArticleIndex != -1) {
                                  final existingArticle = selectedParc
                                      .articles?[existingArticleIndex];
                                  return '${existingArticle?.quantity}'; // Afficher la quantité
                                }
                              }
                              return ''; // Texte par défaut
                            })(),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isTerminated
                                  ? Colors.grey
                                  : ThemeColors.buildCardBlue,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  color: isTerminated
                                      ? Colors.grey
                                      : ThemeColors.buildCardBlue,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color: isTerminated
                                        ? Colors.grey
                                        : ThemeColors.buildCardBlue,
                                  ),
                                  onPressed: () {
                                    final distance = _distanceController2.text;

                                    final selectedParc = (currentState
                                            as InterventionSelected)
                                        .selecteditv
                                        .parcs
                                        ?.firstWhere(
                                            (parc) => parc.id == widget.parcid);

                                    String?
                                        lastValidDistance; // Stocke la dernière distance valide

                                    if (selectedParc != null) {
                                      final existingArticleIndex =
                                          selectedParc.articles?.indexWhere(
                                        (article) =>
                                            article.type == "Déplacement",
                                      );

                                      // Récupération de la dernière valeur valide
                                      /*if (existingArticleIndex != null && existingArticleIndex != -1) {
                lastValidDistance = selectedParc.articles?[existingArticleIndex].quantity;
              }*/

                                      /*   if (int.tryParse(distance) == null || int.parse(distance) < 1) {
           
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("La distance doit être supérieure à 0"),
                    backgroundColor: ThemeColors.burgundy,
                  ),
                );

            
                _distanceController2.text = lastValidDistance ?? '';
                return;
              }*/

                                      if (existingArticleIndex != null &&
                                          existingArticleIndex != -1) {
                                        // Mise à jour de l'article existant
                                        selectedParc
                                            .articles?[existingArticleIndex]
                                            .quantity = distance;
                                        print(
                                            'Article existant mis à jour : \n ${selectedParc.articles?[existingArticleIndex].designation} \n Nouvelle quantité : ${selectedParc.articles?[existingArticleIndex].quantity}');
                                      } else {
                                        // Création d'un nouvel article si aucun n'existe
                                        final newArticle = ArticleModel(
                                          id: "Déplacement",
                                          parcid: selectedParc.id,
                                          designation: "Déplacement",
                                          us: "UN",
                                          quantity: distance,
                                          type: "Déplacement",
                                        );
                                        selectedParc.articles?.add(newArticle);
                                        print(
                                            'Nouvel article ajouté : \n ${newArticle.id} \n Quantité : ${newArticle.quantity}');
                                      }
                                    } else {
                                      print("Parc introuvable ou invalide.");
                                    }
                                  },
                                ),
                              ],
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: ThemeColors.buildCardBlue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: ThemeColors.buildCardBlue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter
                                .digitsOnly, // Permet seulement les chiffres
                          ],
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      elevation: 15, // Augmentez la valeur pour une ombre plus forte
      shadowColor: Colors.black
          .withOpacity(1), // Ajustez la couleur et l'opacité de l'ombre
      color: ThemeColors.buildCardBlue,
      child: Container(
        padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.01), // Taille dynamique
        child: Column(
          children: [
            // La barre en haut de la Card
            Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Couleur de la barre
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Intervention ID : ',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .black, // Couleur noire pour "Intervention ID :"
                            fontFamily: 'Courier',
                          ),
                        ),
                        TextSpan(
                          text:
                              '${(currentState as InterventionSelected).selecteditv.id.toString()}',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[
                                900], // Couleur noire pour "Intervention ID :"
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contenu de la Card
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String text1,
    required String text2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment:
          MainAxisAlignment.center, // Centre verticalement les éléments
      children: [
        // Texte principal
        Text(
          text1,
          style: TextStyle(
            fontSize:
                MediaQuery.of(context).size.width * 0.04, // Taille dynamique
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
            color: Colors.white,
          ),
        ),

        // Espacement minimal entre le texte et l'icône
        const SizedBox(height: 8),

        // Icône
        Icon(
          icon,
          size: MediaQuery.of(context).size.width * 0.07, // Taille dynamique
          color: Colors.white,
        ),

        // Espacement minimal entre l'icône et le texte secondaire
        const SizedBox(height: 8),

        // Texte secondaire
        Text(
          text2,
          style: TextStyle(
            fontSize:
                MediaQuery.of(context).size.width * 0.04, // Taille dynamique
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _itemProfile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: ThemeColors.buildCardBlue,
        ),
        title: Text(title,
            style: const TextStyle(
                color: ThemeColors.buildCardBlue, fontSize: 18)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 17)),
      ),
    );
  }

  Widget _itemTextField1(IconData icon, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 3), // Réduction du margin vertical
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 3),
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        leading: Icon(
          icon,
          color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
        ),
        subtitle: TextField(
          controller: _codeRapportController,
          enabled: !isTerminated,
          onChanged: (text) {},
          decoration: InputDecoration(
            labelText: 'Code Rapport',
            hintText: 'Entrez le Code Rapport',
            labelStyle: TextStyle(
              fontSize: 17,
              color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
            ),
            hintStyle: const TextStyle(
              color: Colors.blueGrey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
                width: 2.0, // Épaisseur du border augmentée
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
                width: 2.0, // Épaisseur du border augmentée
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
                width: 1.0, // Épaisseur du border augmentée
              ),
            ),
            suffixIcon: isTerminated
                ? null // Supprimer l'icône si désactivé
                : IconButton(
                    icon: const Icon(Icons.check,
                        color: ThemeColors.buildCardBlue),
                    onPressed: () {
                      (currentState as InterventionSelected)
                          .selecteditv
                          .parcs
                          ?.firstWhere(
                            (parc) => parc.id == widget.parcid,
                            orElse: () =>
                                ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
                          )
                          .codeRapport = _codeRapportController.text;
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _itemTextField2(IconData icon, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 3),
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        leading: Icon(icon,
            color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue),
        subtitle: TextField(
          controller: _intituleController,
          enabled: !isTerminated,
          onChanged: (text) {},
          decoration: InputDecoration(
            labelText: 'Intitulé',
            hintText: 'Entrez le titre',
            labelStyle: TextStyle(
              fontSize: 17,
              color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
            ),
            hintStyle: const TextStyle(
              color: Colors.blueGrey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
                width: 2.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isTerminated ? Colors.grey : ThemeColors.buildCardBlue,
                width: 1.0,
              ),
            ),
            suffixIcon: isTerminated
                ? null // Supprimer l'icône si désactivé
                : IconButton(
                    icon: const Icon(Icons.check,
                        color: ThemeColors.buildCardBlue),
                    onPressed: () {
                      (currentState as InterventionSelected)
                          .selecteditv
                          .parcs
                          ?.firstWhere(
                            (parc) => parc.id == widget.parcid,
                            orElse: () =>
                                ParcModel(), // Fournir une valeur par défaut si aucun élément n'est trouvé
                          )
                          .intitule = _intituleController.text;
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<List<String>?> showCustomMultiSelectDialogProb({
    required BuildContext context,
    required List<String> options,
    required List<String>? listCode,
    String title = 'Sélectionnez des options',
  }) async {
    List<String> tempListCode = List.from(listCode ??
        [
          '1',
          '1',
          '1',
          '1',
          '1',
          '1',
          '1',
        ]); // Copie des codes sélectionnés
    bool isOtherEnabled = tempListCode[6] == "2";

    return await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...options.asMap().entries.map((entry) {
                        int index = entry.key;
                        String option = entry.value;
                        return CheckboxListTile(
                          title: Text(option,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          value: tempListCode[index] == '2',
                          onChanged: (bool? value) {
                            setState(() {
                              tempListCode[index] = value == true ? '2' : '1';
                              if (index == 6) {
                                isOtherEnabled = tempListCode[6] == "2";
                              }
                            });
                          },
                        );
                      }).toList(),
                      if (isOtherEnabled)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: otherProbController,
                                decoration: InputDecoration(
                                  labelText: 'Autre',
                                  border: OutlineInputBorder(),
                                ),
                                enabled:
                                    isOtherEnabled, // Active ou désactive le champ
                              ),
                            ),
                            SizedBox(
                                width:
                                    8), // Espace entre le TextField et l'icône
                            if (isOtherEnabled) // Affiche l'icône uniquement si le champ est activé
                              IconButton(
                                icon: Icon(Icons.check,
                                    color: ThemeColors
                                        .buildCardBlue), // Icône de check
                                onPressed: () {
                                  // Mettre à jour la valeur de problemType dans ParcModel
                                  final parc =
                                      (currentState as InterventionSelected)
                                          .selecteditv
                                          .parcs
                                          ?.firstWhere(
                                            (parc) => parc.id == widget.parcid,
                                            orElse: () => ParcModel(),
                                          );

                                  if (parc != null) {
                                    parc.problemType = otherProbController.text;
                                  }
                                  parc!.problemType = otherProbController.text;
                                },
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(null),
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
                    Navigator.of(context).pop(tempListCode);
                    (currentState as InterventionSelected)
                        .selecteditv
                        .parcs
                        ?.firstWhere(
                          (parc) => parc.id == widget.parcid,
                          orElse: () => ParcModel(),
                        )
                        .problemTypeList = tempListCode;

                    print(tempListCode);
                    print("---");

                    print((currentState as InterventionSelected)
                        .selecteditv
                        .parcs
                        ?.firstWhere(
                          (parc) => parc.id == widget.parcid,
                          orElse: () => ParcModel(),
                        )
                        .problemTypeList
                        .toString());
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
    );
  }
  
}
