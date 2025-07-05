import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/file_handle_api.dart.dart';

class PdfInvoiceApi {
 

  

  static Future<File> generate(
   PdfColor color,
   String num_service,
   String itv_id , String itv_description , String itv_client,
   String parc_designation ,
   String parc_marque,String itv_couverture_globale, String itv_site, String itv_type , String itv_date_debut_jrs_heurs, String itv_date_fin,
   String itv_duration, String parc_observation ,
   String parc_resume,String itv_tech,

   String parc_designations_tout_articles , String parc_id, String parc_type_tout_article,

   String parc_quantity_tout_article,
   String listParcIdRepeter2,
   String listUnit,
   String itv_date_debut_en_jours,
   String list_facturable,
   String no_client_signature_msg,

   String attitudeSatisfaction,
   String reactivitySatisfaction,
   String communicationSatisfaction,
   String globalSatisfaction

     ) async {
  
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final Directory imagesDir = Directory('${appDocDir.path}/images');
  final String techImagePath = '${imagesDir.path}/signatureTechnicien.png';
  final String clientImagePath = '${imagesDir.path}/signatureClient.png';

final techImage = File(techImagePath);
final clientImage = File(clientImagePath);



    final pdf = pw.Document();
     
  final List<Future<ByteData>> futures = [
    rootBundle.load('lib/images/medibio22.png'),
    rootBundle.load('lib/images/obs.png'),
    rootBundle.load('lib/images/sft.png'),
  ];


  print("generating ---------------------------------") ;

 

// Fonction qui crée une cellule avec plusieurs lignes de texte, chaque ligne séparée par un retour à la ligne
pw.Widget _multiLineCell(String content) {
  // Divise le texte d'entrée en plusieurs lignes en utilisant le retour à la ligne (\n) comme séparateur
  final lines = content.split('\n');

  // Retourne un widget de type Padding qui contient une colonne de texte
  return pw.Padding(
    // Définition des marges (padding) pour le widget Padding
    padding: const pw.EdgeInsets.only(top: 4.0, bottom: 4.0, left: 1.5, right: 0.0),
    child: pw.Column(
      // Alignement des éléments de la colonne à gauche
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Boucle pour créer un widget Text pour chaque ligne du texte
        for (int i = 0; i < lines.length; i++) ...[
          // Affiche le texte de la ligne courante avec une taille de police de 10
          pw.Text(
            lines[i],
            style: pw.TextStyle(fontSize: 10),
          ),
          // Si ce n'est pas la dernière ligne, ajoute une ligne horizontale (divider)
          if (i != lines.length - 1) 
            pw.Divider(thickness: 1, color: PdfColors.black), // Ligne horizontale
        ],
      ],
    ),
  );
}



  // Attendre que toutes les images soient chargées
  final results = await Future.wait(futures);

  // Convertir les données en MemoryImage pour les utiliser dans le PDF
  final medibioImage = pw.MemoryImage(results[0].buffer.asUint8List());
  final obsImage = pw.MemoryImage(results[1].buffer.asUint8List());
  final stfImage = pw.MemoryImage(results[2].buffer.asUint8List());

   // final iconImage = (await rootBundle.load('lib/images/medibio3.png')).buffer.asUint8List();
   // final elapsed = _stopwatch.elapsed;
  String formattedDate = DateTime.now().toString();
formattedDate = formattedDate.substring(0, formattedDate.length - 10);

    // Récupérer la valeur de ITVlocationP depuis SharedPreferences

      pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 20, // Réduire les marges gauche
        marginRight: 20, // Réduire les marges droite
        marginTop: 20, // Réduire les marges supérieures
        marginBottom: 20, // Réduire les marges inférieures
      ),
      build: (pw.Context context) => [
        // Row to contain the image on the left and text on the right
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Image on the left
            pw.Container(
              width: 100, // Set a width for the image
              child: pw.Image(medibioImage),
            ),
            // Spacer to push the text to the right
            pw.Text(
                
              DateTime.now().toString().substring(0, 10),

              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        
      pw.Header(level: 0, text: '-Rapport Intervention N°: $num_service-'),

       
        // Tableau classique avec colorisation
        pw.Table(
          border: pw.TableBorder.all(), // Ajout de bordures au tableau
          children: [
            // Ligne d'en-tête
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4.0),
                  child: pw.Text('Client : $itv_client \nDate D\'installation : $itv_date_debut_jrs_heurs \nMachine : $parc_designation \nMarque : $parc_marque \nCouverture globale : $itv_couverture_globale'),

                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4.0),
                  child: pw.Text('Demande Service N° :\n$num_service \nIntervention N° :\n$itv_id \nStatut : Effectué / Collaborateur'),
                ),
              ],
            ),
            // Ligne de données
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4.0),
                  child: pw.Text('Lieu D\'intervention : $itv_site \nNature D\'intervention : Maintenance \nType D\'intervention : $itv_type \nRéclamation : Non'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4.0),
                  child: pw.Text('Date et Heure Début : $itv_date_debut_jrs_heurs \nDate et Heure Fin : $itv_date_fin \nDurée : $itv_duration'),
                ),
              ],
            ),
          ],
        ),
        
        pw.SizedBox(height: 5),
        
        // Texte classique
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'Motif D\'intervention: ',  
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
              pw.TextSpan(
                text: '$itv_description.\n',
                style: pw.TextStyle(fontSize: 12),
              ),
              
              pw.TextSpan(
                text: '\nRésumé des travaux: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
              pw.TextSpan(
                text: parc_resume,
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 5),
        // Tableau de consommation avec couleurs
       /* pw.Text('Équipe d\'intervention:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            // En-tête du tableau
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.blue200), // Couleur de l'en-tête
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4.0),
                   child: pw.Text(
                  'Intervenant', style: pw.TextStyle(fontSize: 10) ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4.0),
                  child: pw.Text('Aide Intervenant',style: pw.TextStyle(fontSize: 10)),
                ),
               
                
              ],
            ),
            // Ligne de données
            pw.TableRow(
              children: [
           pw.Padding(
  padding: const pw.EdgeInsets.all(4.0),
  child: pw.Text(itv_tech.replaceAll(RegExp(r'[^a-zA-Z\s]'), ''), style: pw.TextStyle(fontSize: 10)),
),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4.0),
                  child: pw.Text(itv_parc_aide_tech, style: pw.TextStyle(fontSize: 10)),
                ),  
              ],
            ),
          ],
        ),*/
         pw.SizedBox(height: 5),
        
pw.Text(
  'Consommation :',
  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
),

pw.Table(
  border: pw.TableBorder.all(), // Bordures générales de la table
  children: [
    // En-tête du tableau
    pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.blue200),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Text(
            'Parc',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Text(
            'Type Conso',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Text(
            'Désignation',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Text(
            'Qté/Durée',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Text(
            'Unité',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Text(
            'Effectué Le',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Text(
            'Facturable',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
pw.TableRow(
  children: [
    // Vérification si listParcIdRepeter2 est vide, si oui, afficher parc_id
    listParcIdRepeter2.isEmpty 
      ? pw.Text(parc_id, style: pw.TextStyle(fontSize: 10)) 
      : _multiLineCell(listParcIdRepeter2),

    _multiLineCell(parc_type_tout_article),
    _multiLineCell(parc_designations_tout_articles),
    _multiLineCell(parc_quantity_tout_article), 
    _multiLineCell(listUnit), 
    _multiLineCell(itv_date_debut_en_jours), 
    _multiLineCell(list_facturable),
  ],
)

  ],
),

        
        pw.SizedBox(height: 10),

        // Row for 'Observations:' text and image
        pw.Row(
          children: [
            pw.Text('Observations:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5), // Space between the text and the image
            pw.Container(
              width: 30, // Set a width for the image
              height: 30, // Set a height for the image
              child: pw.Image(obsImage), // Display the observation image
            ),
          ],
        ),

        // Text under 'Observations'
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: parc_observation,
                style: pw.TextStyle(fontSize: 12), // Style par défaut pour cette partie
              ),
             /* pw.TextSpan(
                text: '\nnb: ',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), // "nb:" en gras
              ),*/
              pw.TextSpan(
                text: '',
                style: pw.TextStyle(fontSize:12), // Texte normal après "nb:"
              ),
            ],
          ),
        ),

pw.SizedBox(height: 20), // Espacement initial

pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    // Côté gauche : Signature de l'intervenant
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Texte de l'intervenant
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'Signature de L\'intervenant\n', // Texte pour la signature du technicien
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(
                text: itv_tech.replaceAll(RegExp(r'[^a-zA-Z\s]'), ''), // Nom de l'intervenant sans caractères spéciaux
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
     pw.SizedBox(height: 20),
        techImage.existsSync()
            ? pw.Image(
                pw.MemoryImage(techImage.readAsBytesSync()),
                width: 80,
                height: 40,
              )
            : pw.SizedBox(), 
      ],
    ),

    // Côté droit : Cachet & Signature Client
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Texte du client
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'Cachet & Signature Client\n', // Texte pour la signature du client
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 30),
                pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: no_client_signature_msg, 
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        clientImage.existsSync()
            ? pw.Image(
                pw.MemoryImage(clientImage.readAsBytesSync()),
                width: 80,
                height: 40,
              )
            : pw.SizedBox(), // Widget vide si aucune signature disponible
      ],
    ),
  ],
),

// Espacement après les signatures
//pw.SizedBox(height: 20),


             pw.Row(
          children: [
            pw.Text('Évaluation:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5), // Space between the text and the image
            pw.Container(
              width: 30, // Set a width for the image
              height: 30, // Set a height for the image
              child: pw.Image(stfImage), // Display the observation image
            ),
          ],
        ),
       pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, // Aligne les éléments à gauche et à droite
  children: [
    // Colonne gauche pour les deux premières phrases
    /*      (currentState as InterventionSelected).selecteditv.attitudeSatisfaction!,
       (currentState as InterventionSelected).selecteditv.reactivitySatisfaction!,
       (currentState as InterventionSelected).selecteditv.communicationSatisfaction!,
      (currentState as InterventionSelected).selecteditv.globalSatisfaction!,*/
    pw.Expanded(
      child: pw.Paragraph(
        text: 'Attitude et Apparence : $attitudeSatisfaction\n'
              'Qualité de Prestation : $reactivitySatisfaction',
        style: const pw.TextStyle(fontSize: 12),
      ),
    ),

    // Ligne verticale pour séparer les deux parties
    pw.Container(
      width: 1, // Très fine pour simuler une ligne
      height: 50, // Hauteur de la ligne verticale
      color: PdfColors.black, // Couleur de la ligne (noir ici)
    ),

    // Colonne droite pour les deux dernières phrases
    pw.Expanded(
      child: pw.Paragraph(
        text: 'Communication : $communicationSatisfaction\n'
              'Globalement : $globalSatisfaction',
        style: const pw.TextStyle(fontSize: 12),
        textAlign: pw.TextAlign.right, // Alignement à droite
      ),
    ),
  ],
),




pw.Table(
  border: pw.TableBorder.all(), // Optionnel : ajoute une bordure au tableau
  children: [
    pw.TableRow(
      children: [
        // Première colonne : fond bleu
        pw.Container(
          color: PdfColors.blue,
          padding: const pw.EdgeInsets.all(8), // Espacement interne des cellules
          child: pw.Text(
            'Rue du Dollar, cité des Jardins, immeuble City lake Center, Bloc B,\nApp B12, Les Berges du Lac II,1053 Tunis.\n- SAV | Fax : +216 71 195 662 | Courriel: sav@medibio.tn',
            style: pw.TextStyle(
              color: PdfColors.white, // Texte en blanc
              fontSize: 8, // Taille du texte
              fontWeight: pw.FontWeight.bold, // Texte en gras
            ),
          ),
        ),

        // Deuxième colonne : fond rouge
        pw.Container(
          color: PdfColors.red,
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            'App B12, Les Berges du Lac II,1053 Tunis. \nR.C : B1118611996.\nUBCI : 11 0080001051 002 788 32.',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

       
        pw.Container(
          color: PdfColors.green,
          padding: const pw.EdgeInsets.all(8),
       child: pw.Text(
       '       SITE WEB\n\nWWW.MEDIBIO.TN',
       style: pw.TextStyle(
       color: PdfColors.white,
       fontSize: 8,
       fontWeight: pw.FontWeight.bold,
       //decoration: pw.TextDecoration.underline, // Ajout du soulignement
  ),
),

        ),
      ],
    ),
  ],
),


      ],
    ),
  );

    return FileHandleApi.saveDocument(name: 'PDF_ID_${DateTime.now().millisecondsSinceEpoch}.pdf', pdf: pdf);
  }
  Future<String> uploadPdf(Uint8List pdfBytes) async {
  try {
    // Authentifier l'utilisateur avec Firebase Auth
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'taharfbsassifb@gmail.com',
      password: '123456sassi',
    );

    // Vérifier si l'utilisateur est authentifié
    if (userCredential.user != null) {
      print("User authenticated: ${userCredential.user!.uid}");

      // Créez un fichier temporaire pour le PDF
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/document.pdf');
      await file.writeAsBytes(pdfBytes);

      // Téléversez le fichier vers Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
      await storageRef.putFile(file);

      // Obtenez l'URL de téléchargement
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } else {
      throw Exception("User authentication failed.");
    }
  } on FirebaseAuthException catch (e) {
    // Gérer les erreurs d'authentification
    print("Authentication error: ${e.message}");
    throw Exception("Failed to authenticate user: ${e.message}");
  } catch (e) {
    // Gérer les autres erreurs
    print("Error uploading PDF: $e");
    throw Exception("Failed to upload PDF: $e");
  }
}

Future<String> generateAndUploadPdf(File pdfFile) async {

    final pdfBytes = await pdfFile.readAsBytes();
    final pdfUrl = await uploadPdf(pdfBytes);
    return pdfUrl;
  }
}

/* Future<String> generateAndUploadPdf() async {
    final pdfFile = await generate(
      PdfColors.blue, // Example color
      'itv_id', 'itv_description', 'itv_client',
      'parc_designation', 'parc_marque', 'itv_couverture_globale', 'itv_site', 'itv_type', 'itv_date_debut_jrs_heurs', 'itv_date_fin',
      'itv_duration', 'parc_observation', 'parc_resume', 'itv_tech',
      'parc_designations_tout_articles', 'parc_id', 'parc_type_tout_article',
      'parc_quantity_tout_article', 'listParcIdRepeter2', 'listUnit',
      'itv_date_debut_en_jours', 'list_facturable', 'no_client_signature_msg',
      'attitudeSatisfaction', 'reactivitySatisfaction', 'communicationSatisfaction', 'globalSatisfaction'
    );
    final pdfBytes = await pdfFile.readAsBytes();
    final pdfUrl = await uploadPdf(pdfBytes);
    return pdfUrl;
  }*/