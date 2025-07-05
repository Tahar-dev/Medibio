import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dns_client/dns_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:srasav_vf_v1/features/user/data/data_sources/user_remote_data_source.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/repositories/pdf_repository_impl.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/email_request.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/details_parcs_intervention.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/pdf_invoice_api.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/signaturepage.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_state.dart';
import 'rapport_intervention_parc.dart';



class PdfViewerPage extends StatefulWidget {
  final File file;
  final String parcid;

  const PdfViewerPage({
    Key? key,
    required this.file,
    required this.parcid,
  }) : super(key: key);

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late File _currentFile;

  late InterventionBloc interventionBloc;
  late InterventionState currentState;

  var pdfUrl;

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


  final PdfRepositoryImpl repository = PdfRepositoryImpl(
    dataSource: UserRemoteDataSource(),
  );

  bool isTerminated = false;
  @override
  void initState() {
    super.initState();
    _currentFile = widget.file;

    interventionBloc = BlocProvider.of<InterventionBloc>(context);
    currentState = interventionBloc.state;
    isTerminated =
        (currentState as InterventionSelected).selecteditv.state == 'terminé';
  }

  void updateFile(File updatedFile) {
    setState(() {
      _currentFile = updatedFile;
    });
  }





final List<String> _apiKeys = [
  'live_91e72c47d3bb0ec13a65', 
  'live_1b17602400be07141639',
  'live_4758b5eaf8ae17c36cc2'
];
int _currentApiKeyIndex = 0;
int? _lastKnownCredits;
bool _serviceUnavailable = false;

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Empêche le retour à la page précédente (page login)
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Rapport en PDF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: ThemeColors.buildCardBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RapportInterventionParc(

                      //   id: widget.id,

                      parcid: widget.parcid),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.paperPlane,
                color: isTerminated ||(currentState as InterventionSelected).selecteditv.isSaved == true? Colors.grey : Colors.white,
              ),
              color: Colors.white,
              onPressed: isTerminated ||(currentState as InterventionSelected).selecteditv.isSaved == true
                  ?  () {
        print("Le rapport d'intervention était déjà signé et envoyé au client par mail.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Le rapport d'intervention était déjà signé et envoyé au client par mail."),
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
                  : () async {
                      // Afficher un dialogue pop-up pour demander la confirmation
                      AwesomeDialog(
                        context: context,
                        animType: AnimType.scale,
                        headerAnimationLoop: true,
                        dialogType: DialogType.question,
                        // dialogBackgroundColor: Color(0xFF9B4D96) ,// Violet
                        customHeader: Container(
                          decoration: BoxDecoration(
                            //     color: ThemeColors.buildCardBlue,
                            shape: BoxShape.circle,
                          ),
                          // padding: EdgeInsets.all(30),
                          child: Icon(
                            Icons.help,
                            color: ThemeColors.buildCardBlue,
                            size: 110,
                          ),
                        ),

                        showCloseIcon: false,
                        titleTextStyle: const TextStyle(
                            fontSize: 18,
                            color: ThemeColors.buildCardBlue,
                            fontWeight: FontWeight.bold),
                        
                        title: 'Confirmer l\'envoi',
                        desc:
                            'Voulez-vous envoyer le Rapport en PDF au \n${(currentState as InterventionSelected).selecteditv.email} ❓',
                        descTextStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),

                        btnCancelColor: Color(0xFF808080),

btnOkOnPress: () async {
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

  // Affichage SnackBar "Chargement en cours"
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
    Navigator.of(context).pop(); // Fermer loader

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

    // Re-afficher le loader pour l'envoi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Envoi du PDF
    final emailRequest = EmailRequest(
      to: recipientEmail,
      subject: 'Rapport de l\'intervention ID : ${(currentState as InterventionSelected).selecteditv.id}',
      text: '',
      filePath: _currentFile.path,
    );

    await repository.sendPdf(emailRequest);
    print("PDF envoyé avec succès.");

    await Future.delayed(const Duration(milliseconds: 200));
    final pdfService = PdfInvoiceApi();
    final url = await pdfService.generateAndUploadPdf(_currentFile);

    setState(() => pdfUrl = url);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pdffirebaselink', pdfUrl);
    print("PDF stocké dans SharedPreferences");

    print("X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X");
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

    Navigator.of(context).pop();

    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.success,
      title: 'Succès',
      body: Text(
        'Le PDF a été envoyé à \n$recipientEmail\n avec succès.',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
      btnOkOnPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: interventionBloc,
              child: const DetailsParcsIntervention(),
            ),
          ),
        );
      },
    ).show();
  } catch (e) {
    Navigator.of(context).pop();
    print('Exception générale : $e');
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: 'Erreur',
      desc: 'Une erreur est survenue : ${e.toString()}',
      btnOkOnPress: () {},
    ).show();
  }
},




                        btnCancelOnPress: () {
                          // Si l'utilisateur annule, ne rien faire
                          // Navigator.of(context).pop();
                          print("Envoi du PDF annulé.");
                        },
                        btnOkText: 'Oui',
                        btnCancelText: 'Non',
                      ).show();
                    },
            ),
          ],
        ),
        body: PDFView(
          filePath: _currentFile.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
        ),
    floatingActionButton: FloatingActionButton(
  onPressed: isTerminated || (currentState as InterventionSelected).selecteditv.isSaved == true
      ? () {
        print("Le rapport d'intervention était déjà signé et envoyé au client par mail.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Le rapport d'intervention était déjà signé et envoyé au client par mail."),
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignaturePage(
                file: _currentFile,
                onUpdated: updateFile,
                parcid: widget.parcid,
              ),
            ),
          );
        },
  child: Icon(
    FontAwesomeIcons.signature,
    color: isTerminated || (currentState as InterventionSelected).selecteditv.isSaved == true? Colors.grey : ThemeColors.buildCardBlue,
  ),
),
      ),
    );
  }
}
