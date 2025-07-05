import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/data/data_sources/user_remote_data_source.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/repositories/pdf_repository_impl.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/email_request.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_state.dart';
import 'package:fluentui_emoji_icon/fluentui_emoji_icon.dart';
//import 'package:fluent_ui/fluent_ui.dart' hide showDialog;
import 'package:srasav_vf_v1/features/user/presentation/pages/details_parcs_intervention.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/pdf_invoice_api.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/view_rapport_pdf.dart';

import 'package:http/http.dart' as http;

const Color BleuFonce = Color.fromARGB(255, 7, 63, 166);

class FeedbackPopup extends StatefulWidget {
  final String parcid;
  final String selectedOption;

  const FeedbackPopup({
    Key? key,
    required this.parcid,
    required this.selectedOption,
  }) : super(key: key);

  @override
  _FeedbackPopupState createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
  final PdfRepositoryImpl repository = PdfRepositoryImpl(
    dataSource: UserRemoteDataSource(),
  );

  late InterventionBloc interventionBloc;
  late InterventionState currentState;

  bool isLoading = false;

  bool isSignatureDisabled = false;

  bool isLoadingmail = false;
  String statusMessage = "";

  final Map<String, String> feedbackSelections = {
    "Attitude et Apparence": "",
    "Qualité de prestation": "",
    "Communication": "",
    "Globalement": "",
  };
  var pdfUrl;

final List<String> _apiKeys = [
  'live_91e72c47d3bb0ec13a65', 
  'live_1b17602400be07141639',
  'live_4758b5eaf8ae17c36cc2'
];
int _currentApiKeyIndex = 0;
int? _lastKnownCredits;
bool _serviceUnavailable = false;


Future<void> createOrUpdateIntervention({
  required String id,
  required String technicienName,
  required bool isSaved,
}) async {
  const String apiUrl = 'http://192.168.101.10:4002/api/interventions/replaceOrCreate';
  
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        // Ajoutez d'autres headers si nécessaire (comme un token d'authentification)
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "_id": id,
        "id": id,
        "interventionId": id,
        "technicienname": technicienName,
        "isSaved": isSaved,
      }),
    );

    if (response.statusCode == 200) {
      print('Succès: ${response.body}');
    } else {
      print('Erreur ${response.statusCode}: ${response.body}');
      throw Exception('Échec de la requête');
    }
  } catch (e) {
    print('Erreur réseau: $e');
    throw Exception('Erreur de connexion: $e');
  }
}

Future<Map<String, dynamic>?> _getAccountInfo() async {
  if (_serviceUnavailable) return null;

  try {
    final response = await http.get(
      Uri.parse('https://api.emailable.com/v1/account'),
      headers: {
        'Authorization': 'Bearer ${_apiKeys[_currentApiKeyIndex]}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _lastKnownCredits = data['available_credits'] as int?;
      print('Crédits disponibles: $_lastKnownCredits');
      return data;
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      print('Clé API invalide ($_currentApiKeyIndex) - ${response.statusCode}');
      return await _rotateApiKeyAndRetry(_getAccountInfo);
    } else {
      print('Erreur API Account (${response.statusCode}): ${response.body}');
    }
  } catch (e) {
    print('Erreur réseau (_getAccountInfo): $e');
    return await _rotateApiKeyAndRetry(_getAccountInfo);
  }

  return null;
}

Future<void> _switchApiKeyIfNeeded() async {
  final accountInfo = await _getAccountInfo();
  final credits = accountInfo?['available_credits'] as int? ?? 0;

  _lastKnownCredits = credits;

  if (credits <= 10) {
    await _rotateApiKeyAndRetry(() => _getAccountInfo());
  }
}

Future<String?> getEmailState(String email) async {
  if (_serviceUnavailable) {
    print('Service désactivé - toutes les clés sont épuisées ou invalides.');
    return 'service_unavailable';
  }

  await _switchApiKeyIfNeeded();

  if (_serviceUnavailable) return 'service_unavailable';

  try {
    final url = Uri.parse(
      'https://api.emailable.com/v1/verify?email=${Uri.encodeComponent(email)}&api_key=${_apiKeys[_currentApiKeyIndex]}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final state = data['state'];
      print('État de vérification email : $state');
      return state;
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      print('Clé API invalide pendant vérification email');
      return await _rotateApiKeyAndRetry(() => getEmailState(email));
    } else {
      print('Erreur API Email (${response.statusCode}): ${response.body}');
    }
  } catch (e) {
    print('Erreur réseau lors de la vérification email: $e');
    return null;
  }

  return null;
}

Future<bool> isEmailPotentiallyValid(String email) async {
  if (_serviceUnavailable) {
    print('Service de vérification indisponible - retour fallback true');
    return true;
  }

  final state = await getEmailState(email);

  if (state == 'service_unavailable') {
    print('API indisponible - validation manuelle possible');
    return true;
  }

  const validStates = ['deliverable', 'unknown', 'risky'];
  final isValid = state != null && validStates.contains(state);

  print('Email $email est valide: $isValid (état: $state)');
  return isValid;
}

/// 🔁 Essaie la clé suivante si disponible et relance la fonction passée en paramètre
Future<T?> _rotateApiKeyAndRetry<T>(Future<T?> Function() retryCallback) async {
  if (_currentApiKeyIndex < _apiKeys.length - 1) {
    _currentApiKeyIndex++;
    print('Rotation vers clé API $_currentApiKeyIndex');
    return await retryCallback();
  } else {
    _serviceUnavailable = true;
    print('Toutes les clés API sont invalides ou épuisées');
    return null;
  }
}

  @override
  void initState() {
    super.initState();
    interventionBloc = BlocProvider.of<InterventionBloc>(context);
    currentState = interventionBloc.state;
  }

  Future<File> regeneratePdfWithSignatures(
      String techPath, String clientPath) async {
    final String uniqueName =
        "PDF_ID_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String pdfPath = '${appDocDir.path}/$uniqueName';

    final parc =
        (currentState as InterventionSelected).selecteditv.parcs?.firstWhere(
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
              (currentState as InterventionSelected).selecteditv.date!));
          listFacturableRepeter.add('Oui');
        }

        if (article.type == "Main d'oeuvre") {
          typesMainDoeuvreArticles.add(article.type.toString());
          designationMainDoeuvreArticles.add(article.designation.toString());
          quantityMainDoeuvreArticles.add(article.quantity.toString());
          listUnitMIN.add('MIN');
        }

        if (article.type == "Pièce") {
          typesPiecesArticles.add(article.type.toString());
          designationPiecesArticles.add(article.designation.toString());
          quantityPiecesArticles.add(article.quantity.toString());
          listUnitPIECE.add('PIECE');
        }

        if (article.type == "Déplacement") {
          typesDeplacementArticles.add(article.type.toString());
          designationDeplacementArticles.add(article.designation.toString());
          quantityDeplacementArticles.add(article.quantity.toString());
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

    String listParcIdRepeter2 = listParcIdRepeter.join('\n');
    String listParcDateRepeter2 = listParcDateRepeter.join('\n');
    String listFacturableRepeter2 = listFacturableRepeter.join('\n');
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
      final prefs = await SharedPreferences.getInstance();
  final shpcounterTextVar = prefs.getString('shpcounterText');

    // Génération du PDF avec les informations collectées
    final pdfFile = await PdfInvoiceApi.generate(
      PdfColors.black,
                                    (currentState as InterventionSelected)
                                    .selecteditv
                                    .BL
                                    .toString() ??
                                '',
      (currentState as InterventionSelected).selecteditv.id.toString(),
      (currentState as InterventionSelected).selecteditv.description.toString(),
      (currentState as InterventionSelected).selecteditv.client.toString(),
      parc?.designation.toString() ?? 'Parc inconnu',
      parc?.marque.toString() ?? 'Marque inconnue',
      (currentState as InterventionSelected)
          .selecteditv
          .couvertureglobale
          .toString(),
      (currentState as InterventionSelected).selecteditv.lieu.toString(),
      (currentState as InterventionSelected).selecteditv.type.toString(),
startdaytime,
   DateTime.now().toString().substring(0, 19),
shpcounterTextVar??"00:00:00",
                            parc?.observation.toString() ?? 'OBSERVATION VIDE',
                            parc?.resume.toString() ?? 'RESUME VIDE',
      (currentState as InterventionSelected)
          .selecteditv
          .technicienRealName
          .toString(),
      designationsToutArticles2,
      parc?.id.toString() ?? 'Parc inconnu',
      typesToutArticles2,
      quantityToutArticles2,
      listParcIdRepeter2,
      typesToutUnit,
      listParcDateRepeter2,
      listFacturableRepeter2,
      widget.selectedOption,
      (currentState as InterventionSelected).selecteditv.attitudeApparenceItv!,
      (currentState as InterventionSelected).selecteditv.qualityPrestationItv!,
      (currentState as InterventionSelected).selecteditv.communicationItv!,
      (currentState as InterventionSelected).selecteditv.globlementItv!,
    );

    final File file = File(pdfPath);
    await file.writeAsBytes(await pdfFile.readAsBytes());
    return file;
  }

  Widget buildFeedbackSection(String title, String category) {
    final options = {
      "Très insatisfait":
          FluentUiEmojiIcon(fl: Fluents.flAngryFace, w: 50, h: 50),
      "Insatisfait": FluentUiEmojiIcon(fl: Fluents.flNeutralFace, w: 50, h: 50),
      "Satisfait": FluentUiEmojiIcon(fl: Fluents.flSmilingFace, w: 50, h: 50),
      "Très satisfait":
          FluentUiEmojiIcon(fl: Fluents.flGrinningFace, w: 50, h: 50),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: options.entries.map((entry) {
              final label = entry.key;
              final emoji = entry.value;
              final isSelected = feedbackSelections[category] == label;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    feedbackSelections[category] = label;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Color(0xFF000000) : Color(0x00000000),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  child: emoji,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void showConfirmationPopup(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Center(
            // Centrer le titre
            child: Text(
              "Que voulez-vous faire ?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Container(
            width: screenWidth,
            height: screenHeight * 0.242,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
onPressed: () async {
  final recipientEmail = (currentState as InterventionSelected).selecteditv.email;

  // Vérifier la connectivité
  final connectivityResult = await Connectivity().checkConnectivity();
  print("WIFI STATE:");
  if (connectivityResult != ConnectivityResult.wifi &&
      connectivityResult != ConnectivityResult.mobile) {
    // Pas de connexion internet
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: 'Pas de connexion',
      desc: 'Aucune connexion Internet détectée.\nVeuillez vérifier votre réseau.',
      btnOkOnPress: () {},
    ).show();
    return;
  }

  print("Connecté à Internet");

  if (context.mounted) {
    print("Sending PDF to $recipientEmail");
  }

  // Affichage loader
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final isValid = await isEmailPotentiallyValid(recipientEmail!);
    Navigator.of(context).pop(); // Fermer le loader

    if (_serviceUnavailable) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'Clé API invalide ou expirée',
        desc: 'Toutes les clés API sont invalides ou expirées.\nVeuillez contacter l\'administrateur.',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    if (!isValid) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Adresse E-mail Invalide',
        desc: "l'adresse e-mail $recipientEmail est invalide.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    // Régénérer le PDF signé
    final File updatedFile = await regeneratePdfWithSignatures('', '');
    print('PDF regenerated successfully!');

    // Ré-afficher le loader avant envoi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final emailRequest = EmailRequest(
      to: recipientEmail,
      subject: 'Rapport de l\'intervention ID : ${(currentState as InterventionSelected).selecteditv.id.toString()}',
      text: '',
      filePath: updatedFile.path,
    );

    await repository.sendPdf(emailRequest);
    print("PDF sent successfully!");

    final pdffbService = PdfInvoiceApi();
    final url = await pdffbService.generateAndUploadPdf(updatedFile);
    print('URL du PDF : $url');

    pdfUrl = url;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pdffirebaselink', pdfUrl);

    String? storedPdfUrl = prefs.getString('pdffirebaselink');
    print("Valeur stockée dans SharedPreferences : $storedPdfUrl");
    

    print("T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T-T");
    print("Is MAIL SENT IS (isSaved) Before send is :");
    print((currentState as InterventionSelected).selecteditv.isSaved.toString());
    print("Is MAIL SENT IS (isSaved) After send is :");
    (currentState as InterventionSelected).selecteditv.isSaved=true;
    print((currentState as InterventionSelected).selecteditv.isSaved.toString());

    await createOrUpdateIntervention(
  id: (currentState as InterventionSelected).selecteditv.id.toString(),
  technicienName: (currentState as InterventionSelected).selecteditv.technicienname.toString(),
  isSaved: true,
);

                              Hive.box<LocalIntervention>('interventions').put(
                              (currentState as InterventionSelected).selecteditv.id,
                              LocalIntervention(
                                id: (currentState as InterventionSelected).selecteditv.id,
                                isSaved: (currentState as InterventionSelected).selecteditv.isSaved??true,
                              ),
                            );

    
    Navigator.of(context).pop(); // Fermer le loader

    // Afficher la boîte de dialogue de succès
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      headerAnimationLoop: true,
      dialogType: DialogType.success,
      showCloseIcon: false,
      title: 'Succès',
      body: Text(
        'Le PDF a été envoyé à \n$recipientEmail\n avec succès.',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: material.Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
      alignment: Alignment.center,
      btnOkOnPress: () async {


        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DetailsParcsIntervention(),
          ),
        );

        print("Naviguer vers DetailsParcsIntervention");
      },
      btnOkIcon: Icons.check_circle,
      btnOkColor: Color(0xFF4CAF50),
    ).show();
  } catch (e) {
    Navigator.of(context).pop(); // Fermer le loader en cas d'erreur
    print("Erreur lors de l'envoi du PDF : $e");

    AwesomeDialog(
      context: context,
      animType: AnimType.rightSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      showCloseIcon: true,
      title: 'Erreur',
      desc: 'Une erreur est survenue lors de l\'envoi du PDF.',
      btnOkOnPress: () {
        debugPrint('OnClick Ok for Error');
      },
      btnOkIcon: Icons.error_outline,
    ).show();
  }
},

                  child: Container(
                    width: 280,
                    // height: 50,
                child: RichText(
  textAlign: TextAlign.center,
  text: const TextSpan(
    children: [
      TextSpan(
        text: "Envoyer le PDF par\nmail ",
        style: TextStyle(
          color: BleuFonce,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: FluentUiEmojiIcon(
          fl: Fluents.flEMail,
          w: 40,
          h: 40,
        ),
      ),
    ],
  ),
),

                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {

                    try {
                      // Regénérer le PDF de manière asynchrone
                      final File updatedFile =
                          await regeneratePdfWithSignatures('', '');

                      // Naviguer vers la nouvelle page
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerPage(
                            file: updatedFile,
                            parcid: widget.parcid,
                          ),
                        ),
                      );

                      // Fermer le popup
                      Navigator.of(context).pop();
                      print("Visualiser le PDF");
                    } catch (e) {
                      // Gestion des erreurs
                      print("Erreur lors de la génération ou navigation : $e");
                    }
                  },
                  child: Container(
                    width: 280, // Largeur fixe pour les deux boutons
                  //  height: 50, // Hauteur fixe pour uniformité
                    child: RichText(
  textAlign: TextAlign.center,
  text: TextSpan(
    children: [
      TextSpan(
        text: "Visualiser le \nPDF ",
        style: TextStyle(
          color: BleuFonce,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(
          Icons.picture_as_pdf, // Icône PDF
          size: 36,
          color: BleuFonce,
        ),
      ),
    ],
  ),
),

                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Empêche le retour à la page précédente (page login)
        return false;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          width: screenWidth ,
          height: screenHeight * 0.292,
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                "Donnez-nous votre avis 🌟",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: feedbackSelections.keys.map((category) {
                      return buildFeedbackSection(category, category);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        color: BleuFonce,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (currentState is InterventionSelected) {
                        final selectedItv =
                            (currentState as InterventionSelected).selecteditv;

                        selectedItv.attitudeApparenceItv =
                            feedbackSelections["Attitude et Apparence"] ?? "";
                        selectedItv.qualityPrestationItv =
                            feedbackSelections["Qualité de prestation"] ?? "";
                        selectedItv.communicationItv =
                            feedbackSelections["Communication"] ?? "";
                        selectedItv.globlementItv =
                            feedbackSelections["Globalement"] ?? "";
                      }
                      Navigator.of(context).pop();
                      showConfirmationPopup(context);
                    },
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                        color: BleuFonce,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
