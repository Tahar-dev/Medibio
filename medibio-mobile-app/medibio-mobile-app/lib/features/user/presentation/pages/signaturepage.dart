import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_state.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/feedbackpopup.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'view_rapport_pdf.dart';
import 'pdf_invoice_api.dart';


class SignaturePage extends StatefulWidget {
  final File file;
  final String parcid;





  final Function(File) onUpdated;
  final bool checkTechSignature=false; 
  final bool checkClientSignature=false; 
  

  const SignaturePage({
    Key? key,
    required this.file,
    required this.onUpdated,
    required this.parcid,

 //   required this.id,



  }) : super(key: key);

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final SignatureController _techController = SignatureController(penColor: Colors.black);
  final SignatureController _clientController = SignatureController(penColor: Colors.black);

  late InterventionBloc interventionBloc;
  late InterventionState currentState;
  
  bool isLoading = false;

  bool isSignatureDisabled = false;


    // Pour gérer l'état des cases à cocher
  Map<String, bool> options = {
    "Le client a refusé de signer": false,
    "Pas de signatiare présent": false,
    "Intervention à distance": false,
  };

  String selectedOption = "";

Future<void> deleteClientSignatureImages() async {
  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDocDir.path}/images');
   // final String techSignaturePath = '${imagesDir.path}/signatureTechnicien.png';
    final String clientSignaturePath = '${imagesDir.path}/signatureClient.png';

   // final File techFile = File(techSignaturePath);
    final File clientFile = File(clientSignaturePath);

    /*if (await techFile.exists()) {
      await techFile.delete();
    }*/

    if (await clientFile.exists()) {
      await clientFile.delete();
    }

  } catch (e) {
    debugPrint('Erreur lors de la suppression des signatures : $e');
  }
}

Future<void> deleteTechnicianSignatureImages() async {
  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDocDir.path}/images');
    final String techSignaturePath = '${imagesDir.path}/signatureTechnicien.png';
   // final String clientSignaturePath = '${imagesDir.path}/signatureClient.png';

    final File techFile = File(techSignaturePath);
    //final File clientFile = File(clientSignaturePath);

    if (await techFile.exists()) {
      await techFile.delete();
    }

    /*if (await clientFile.exists()) {
      await clientFile.delete();
    }*/

  } catch (e) {
    debugPrint('Erreur lors de la suppression des signatures : $e');
  }
}

 @override
  void initState() {
    super.initState();
    // Accessing the bloc and its current state
    interventionBloc = BlocProvider.of<InterventionBloc>(context);

    currentState = interventionBloc.state;

   
  }


  Future<void> deleteClientSignature() async {
  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String clientPath = '${appDocDir.path}/images/signatureClient.png';

    final File clientFile = File(clientPath);
    if (await clientFile.exists()) {
      await clientFile.delete();
      debugPrint('Signature du client supprimée avec succès.');
    } else {
      debugPrint('Aucune signature du client à supprimer.');
    }
  } catch (e) {
    debugPrint('Erreur lors de la suppression de la signature du client : $e');
  }
}


Future<void> saveTechSignatures() async {
  setState(() => isLoading = true);

  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDocDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final String techPath = '${imagesDir.path}/signatureTechnicien.png';

    // Supprimer l'image existante si elle existe
    final File existingFile = File(techPath);
    if (await existingFile.exists()) {
      await existingFile.delete();
    }

    if (_techController.isNotEmpty) {
      final Uint8List? techData = await _techController.toPngBytes();
      if (techData != null) {
        // Enregistrer la nouvelle signature du technicien
        await existingFile.writeAsBytes(techData);
      }
    }

    // Regénérer le PDF avec uniquement la signature du technicien
    await regeneratePdfWithSignatures(techPath, '');

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la sauvegarde de la signature du technicien : $e')),
    );
  }
}


Future<void> saveClientSignatures() async {
  setState(() => isLoading = true);

  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDocDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final String clientPath = '${imagesDir.path}/signatureClient.png';

    // Supprimer l'image existante si elle existe
    final File existingFile = File(clientPath);
    if (await existingFile.exists()) {
      await existingFile.delete();
    }

    if (_clientController.isNotEmpty) {
      final Uint8List? clientData = await _clientController.toPngBytes();
      if (clientData != null) {
        // Enregistrer la nouvelle signature du client
        await existingFile.writeAsBytes(clientData);
      }
    }

    // Regénérer le PDF avec uniquement la signature du client
    await regeneratePdfWithSignatures('', clientPath);

    setState(() {
      isLoading = false;
    });

    // Ouvrir le popup d'évaluation après la sauvegarde de la signature
    _showRatingPopup();

  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la sauvegarde de la signature du client : $e')),
    );
  }
}



Future<void> goToPDF() async {
  setState(() => isLoading = true);


    final File updatedFile = await regeneratePdfWithSignatures('', '');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          file: updatedFile,
           parcid: widget.parcid,
   

             ),
      ),
    );
  
}


  Future<File> regeneratePdfWithSignatures(String techPath, String clientPath) async {
    final String uniqueName = "PDF_ID_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String pdfPath = '${appDocDir.path}/$uniqueName';

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
          listParcDateRepeter.add(
              formatDate((currentState as InterventionSelected).selecteditv.date!));
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
      (currentState as InterventionSelected).selecteditv.BL.toString(),
      (currentState as InterventionSelected).selecteditv.id.toString(),
      (currentState as InterventionSelected).selecteditv.description.toString(),
      (currentState as InterventionSelected).selecteditv.client.toString(),
      parc?.designation.toString() ?? 'Parc inconnu',
      parc?.marque.toString() ?? 'Marque inconnue',
      (currentState as InterventionSelected).selecteditv.couvertureglobale.toString(),
      (currentState as InterventionSelected).selecteditv.lieu.toString(),
      (currentState as InterventionSelected).selecteditv.type.toString(),
startdaytime,
   DateTime.now().toString().substring(0, 19),
  shpcounterTextVar??"00:00:00",
                            parc?.observation.toString() ?? 'OBSERVATION VIDE',
                            parc?.resume.toString() ?? 'RESUME VIDE',
      (currentState as InterventionSelected).selecteditv.technicienRealName.toString(),
      designationsToutArticles2,
      parc?.id.toString() ?? 'Parc inconnu',
      typesToutArticles2,
      quantityToutArticles2,
      listParcIdRepeter2,
      typesToutUnit,
      listParcDateRepeter2,
      listFacturableRepeter2,
      selectedOption,
      (currentState as InterventionSelected).selecteditv.satisfaction??'',
      (currentState as InterventionSelected).selecteditv.satisfaction??'',
      (currentState as InterventionSelected).selecteditv.satisfaction??'',
      (currentState as InterventionSelected).selecteditv.satisfaction??'',
    );


    final File file = File(pdfPath);
    await file.writeAsBytes(await pdfFile.readAsBytes());
    return file;
  }

  void _showRatingPopup() {
showDialog(
  context: context,
  builder: (BuildContext context) {
    return FeedbackPopup(parcid:widget.parcid,
    selectedOption: selectedOption,

         //   id: widget.id,        
          
  
    );
  },
);

  }


  DateTime parseDate(String dateString) {
    if (dateString.length != 8) {
      throw const FormatException("La chaîne de date doit comporter 8 caractères au format yyyyMMdd");
    }
    int year = int.parse(dateString.substring(0, 4));
    int month = int.parse(dateString.substring(4, 6));
    int day = int.parse(dateString.substring(6, 8));
    return DateTime(year, month, day);
  }

  TimeOfDay parseDuration(String durationString) {
    if (durationString.length != 5) {
      throw const FormatException("La chaîne de durée doit comporter 5 caractères au format xHHMM");
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
    throw const FormatException("La chaîne de temps doit comporter 4 caractères au format HHmm");
  }

  int hour = int.parse(timeString.substring(0, 2));
  int minute = int.parse(timeString.substring(2, 4));

  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    throw const FormatException("Les heures doivent être entre 00 et 23, et les minutes entre 00 et 59");
  }

  return TimeOfDay(hour: hour, minute: minute);
}


/// Combine une date et un temps pour retourner un DateTime formaté
String combineDateAndTime(String dateString, String timeString) {
  DateTime date = parseDate(dateString);
  TimeOfDay time = parseTime(timeString);

  DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

  // Retourne la date et l'heure au format 'yyyy-MM-dd HH:mm'
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}



// Fonction pour parser et formater la date
String formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString); // On suppose que la date est déjà dans un format ISO 8601
  return DateFormat('yyyy-MM-dd').format(date); // Formate la date en 'yyyy-MM-dd'
}


@override
Widget build(BuildContext context) {
         return WillPopScope(
      onWillPop: () async {
        // Empêche le retour à la page précédente (page login)
        return false;
      },
    child  :Scaffold(
    appBar: AppBar(
  title: const Text(
    'Signatures',
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
      goToPDF();
    },
  ),
 /* actions: [
    IconButton(
      icon: const Icon(FontAwesomeIcons.filePdf, size: 30, color: Colors.white), // Icône de validation
      onPressed: goToPDF, // Appel de la fonction lorsque l'icône est pressée
    ),
  ],*/
),

    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Espacement latéral
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligner tout à gauche
                children: [
                  const SizedBox(height: 40),
                  
Row(
  children: [
    // Colonne pour la signature
    Expanded(
      flex: 3, // 3/4 de l'espace
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Signature du Technicien',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Signature(
            controller: _techController,
            backgroundColor: Colors.grey.shade200,
            height: 150,
            width: double.infinity,
          ),
        ],
      ),
    ),
    const SizedBox(width: 10), // Espacement entre les colonnes
    // Colonne pour l'icône
Expanded(
  flex: 1, // 1/4 de l'espace
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center, // Centrer verticalement
    children: [
Column(
  mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement
  children: [
     const SizedBox(height: 40),
    IconButton(
      icon: const Icon(
        FontAwesomeIcons.check,
        size: 50,
        color: ThemeColors.buildCardBlue,
      ),
      onPressed: saveTechSignatures, // Appelle la fonction de sauvegarde
    ),
    const SizedBox(height: 10), // Espacement entre les icônes
    IconButton(
      icon: const Icon(
        FontAwesomeIcons.eraser,
        size: 50,
        color: ThemeColors.burgundy,
      ),
      onPressed: () {
        _techController.clear(); // Efface la signature du technicien
        deleteTechnicianSignatureImages(); // Supprime la signature sauvegardée
      },
    ),
  ],
)

    ],
  ),
),

  ],
),
const SizedBox(height: 50),

Row(
  children: [
Expanded(
  flex: 3, // 3/4 de l'espace
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Signature du Client',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 30),
      GestureDetector(
        onPanDown: isSignatureDisabled
            ? (_) {

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      "Cher technicien, vous ne pouvez pas signer pour le client, merci. 😊",
      style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16),
    ),
    backgroundColor: Color.fromRGBO(128, 0, 32, 1.0),  
    duration: Duration(seconds: 4), 
  ),
);  
      }: null,
        child: AbsorbPointer(
          absorbing: isSignatureDisabled,
          child: Signature(
            controller: _clientController,
            backgroundColor: Colors.grey.shade200,
            height: 150,
            width: double.infinity,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(width: 10),

Expanded(
  flex: 1, // 1/4 de l'espace
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center, // Centrer verticalement
    children: [
Column(
  mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement
  children: [
     const SizedBox(height: 40), 
    IconButton(
      icon: const Icon(
        FontAwesomeIcons.check,
        size: 50,
        color: ThemeColors.buildCardBlue,
      ),
      onPressed: selectedOption == ""
          ? saveClientSignatures
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Cher technicien, vous ne pouvez pas charger le formulaire de satisfaction pour le client, merci. 😊",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  backgroundColor: Color.fromRGBO(128, 0, 32, 1.0),
                  duration: Duration(seconds: 4),
                ),
              );
            },
    ),
    const SizedBox(height: 10), // Espacement entre les icônes
    IconButton(
      icon: const Icon(
        FontAwesomeIcons.eraser,
        size: 50,
        color: ThemeColors.burgundy,
      ),
      onPressed: () {
        _clientController.clear();
        deleteClientSignatureImages();
        setState(() {
          selectedOption = "";
          options = {
            "Le client a refusé de signer": false,
            "Pas de signataire présent": false,
            "Intervention à distance": false,
          }; // Réinitialise les options
          isSignatureDisabled = false; // Réactive la possibilité de signer
        });
      },
    ),
  ],
)

    ],
  ),
),


  ],
),


                  const SizedBox(height: 20),
        
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: options.keys.map((String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Radio<String>(
              value: key,
              groupValue: selectedOption,
              onChanged: (String? value) async {
                // Forcer le toggle de l'option sélectionnée
                setState(() {
                  selectedOption = value ?? "";
                });

                // Si une option est sélectionnée, supprimer la signature et empêcher l'écriture
                if (value != null && value.isNotEmpty && value != "false") {
                  _clientController.clear(); // Efface la signature
                 // await deleteClientSignature(); // Supprime la signature sauvegardée
                  setState(() {
                    isSignatureDisabled = true; // Désactive la possibilité de signer
                  });
                } else {
                  setState(() {
                    isSignatureDisabled = false; // Réactive la possibilité de signer
                  });
                }
              },
              activeColor: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              key,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }).toList(),
),



                 // const SizedBox(height: 20),
                 /* Align(
                    alignment: Alignment.centerLeft, // Aligne le bouton à gauche
                    child: ElevatedButton(
                      onPressed: goToPDF,
                      child: const Text(
                        'Sauvegarder et revenir',
                        style: TextStyle(
                          color: BleuFonce,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
  ),);
}
}