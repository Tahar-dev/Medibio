import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Hello, this is a PDF!'),
          );
        },
      ),
    );
    return pdf.save();
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

  Future<String> generateAndUploadPdf() async {
    final pdfBytes = await generatePdf();
    final pdfUrl = await uploadPdf(pdfBytes);
    return pdfUrl;
  }
}