import 'dart:io'; // Importation de la bibliothèque Dart pour les opérations sur les fichiers et les entrées/sorties.
import 'package:pdf/widgets.dart' as pw; // Importation du package pdf pour la création de documents PDF.
import 'package:path_provider/path_provider.dart'; // Importation du package path_provider pour obtenir les chemins de répertoires sur l'appareil.
import 'package:open_file/open_file.dart'; // Importation du package open_file pour ouvrir des fichiers avec les applications associées.

class FileHandleApi { // Définition d'une classe appelée FileHandleApi.

  // Fonction pour enregistrer un fichier PDF
  static Future<File> saveDocument({
    required String name, // Nom du fichier PDF à enregistrer.
    required pw.Document pdf, // Document PDF à enregistrer.
  }) async {
    final bytes = await pdf.save(); // Conversion du document PDF en un tableau de bytes.

    // final dir = await getApplicationDocumentsDirectory(); // Optionnel: obtention du répertoire des documents de l'application (commenté).
    final dir = await getExternalStorageDirectory(); // Obtention du répertoire de stockage externe de l'appareil.
    final file = File('${dir?.path}/$name'); // Création d'un objet File avec le chemin complet et le nom du fichier.
    await file.writeAsBytes(bytes); // Écriture des bytes du document PDF dans le fichier.
    return file; // Retour du fichier nouvellement créé.
  }

  // Fonction pour ouvrir un fichier PDF
  static Future openFile(File file) async {
    final url = file.path; // Obtention du chemin du fichier.

    await OpenFile.open(url); // Ouverture du fichier avec l'application associée.
  }
}
