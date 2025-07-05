import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:srasav_vf_v1/features/user/constants/api_urls.dart';
import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/user_model.dart';

final _firebaseMessaging = FirebaseMessaging.instance;

class UserRemoteDataSource {
  bool _isLoading = false; 
  bool get isLoading => _isLoading; 

Future<UserModel?> login(String email, String password) async {
  if (email.isEmpty) throw "L'email ne peut pas être vide.";
  if (password.isEmpty) throw "Le mot de passe ne peut pas être vide.";

  try {
    _isLoading = true;

    // 1. Authentification
    final response = await http
        .post(
          Uri.parse(ApiUrls.LOGIN_URL),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 2));

    print("📥 Réponse brute du serveur: ${response.body}");

    if (response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      print("✅ Données JSON décodées: $jsonData");

      // 2. Préparation de la nouvelle liste FCM
      final currentFcmList = List<String>.from(jsonData['fcmlist'] ?? []);
          await _firebaseMessaging.requestPermission();
          final fcmToken = await _firebaseMessaging.getToken();
         // const newFcmToken = 'nouveau_FCM_test2';
      
      if (!currentFcmList.contains(fcmToken)) {
        currentFcmList.add(fcmToken!);

        // 3. Mise à jour côté serveur
        try {
          final fcmResponse = await http.put(
            Uri.parse('http://172.16.20.7:8888/technicians/update-by-name/${jsonData['name']}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'fcmlist': currentFcmList}),
          ).timeout(const Duration(seconds: 2));

          if (fcmResponse.statusCode == 200) {
            print("✅ Liste FCM mise à jour avec succès: $currentFcmList");
          } else {
            print("⚠️ Échec mise à jour FCM: ${fcmResponse.body}");
          }
        } catch (e) {
          print("⚠️ Erreur mise à jour FCM: $e");
        }
      } else {
        print("ℹ️ Token FCM déjà présent dans la liste");
      }

      return UserModel.fromJson(jsonData);
    } else {
      throw jsonDecode(response.body)['message'] ?? "Échec de l'authentification";
    }
  } on SocketException {
    throw "Problème de connexion";
  } on TimeoutException {
    throw "Serveur non disponible";
  } catch (e) {
    throw "Erreur: ${e.toString()}";
  } finally {
    _isLoading = false;
  }
}
  Future<UserModel> getUserById(String id) async {
    final response = await http.get(Uri.parse('${ApiUrls.GET_ALL_USER_URL}$id'));

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

   Future<List<InterventionModel>> getInterventionsById(String id) async {
    final response = await http.get(Uri.parse('${ApiUrls.GET_INTERVENTION_BY_USER_NAME_URL}$id'));

    if (response.statusCode == 200) {
      final List responseData = json.decode(response.body);
      return responseData.map((data) => InterventionModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

Future<List<ParcModel>> fetchParcs(String interventionId) async {
  final uri = Uri.parse('${ApiUrls.FETCH_PARC_OF_ITV_URL}$interventionId');
  final response = await http.get(uri);


  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List; 
    return data.map((json) => ParcModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load parcs: ${response.reasonPhrase}');
  }
}

Future<List<ParcModel>> fetchParcsList() async {
  final uri = Uri.parse(ApiUrls.FETCH_ALL_PARCS_URL);
  final response = await http.get(uri);


  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List; 
    return data.map((json) => ParcModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load parcs: ${response.reasonPhrase}');
  }
}

Future<List<InterventionModel>> getInterventions(String technicienName) async {
    final response = await http.get(Uri.parse('${ApiUrls.GET_ALL_INTERVENTIONS_URL}$technicienName'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => InterventionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load interventions');
    }
  }

Future<List<ArticleModel>> fetchArticleList() async {
  final uri = Uri.parse(ApiUrls.FETCH_ALL_ARTICLES_URL);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List; 
    return data.map((json) => ArticleModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load article: ${response.reasonPhrase}');
  }
}

Future<bool> sendPdfToBackend({
  required String filePath,
  required String to,
  required String subject,
  required String text,
}) async {
  final uri = Uri.parse(ApiUrls.SEND_EMAIL_URL);
  final request = http.MultipartRequest('POST', uri)
    ..fields['to'] = to
    ..fields['subject'] = subject
    ..fields['text'] = text
    ..files.add(await http.MultipartFile.fromPath('file', filePath));

  try {
    final response = await request.send();
    
    // Vérifier le code de statut de la réponse
    if (response.statusCode == 201) {
      print("Email envoyé avec succès");
      return true;
    } else {
      final responseBody = await response.stream.bytesToString();
      print("Échec de l'envoi de l'email. Code: ${response.statusCode}, Réponse: $responseBody");
      return false;
    }
  } catch (e) {
    print("Erreur lors de l'envoi du PDF: $e");
    return false;
  }
}

//updateInterventionInSage
Future<void> updateIntervention(String id, Map<String, dynamic> updateData) async {
  final url = Uri.parse(ApiUrls.UPDATE_ITV_URL);
  

  try {
    // Envoie de la requête POST avec le corps encodé en JSON
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updateData), // Conversion des données en JSON
    );

    // Vérification de la réponse HTTP
    if (response.statusCode == 201) {
      // La mise à jour a réussi, vous pouvez traiter la réponse ici si nécessaire
      print('Mise à jour IN SAGE X3 réussie: ${response.body}');
    } else if (response.statusCode == 404) {
      // Si l'ID de l'intervention est incorrect
      throw Exception('Intervention non trouvée (ID incorrect)');
    } else {
      // Si une autre erreur se produit côté serveur
      throw Exception('Erreur lors de la mise à jour. Code: ${response.statusCode}');
    }
  } catch (e) {
    // Capture des erreurs et affichage des détails
    throw Exception('Erreur lors de la mise à jour: $e');
  }
}



Future<void> updateIntervention2(String id, Map<String, dynamic> updateData) async {
  if (id.isEmpty) {
    throw Exception('L\'ID de l\'intervention ne peut pas être vide.');
  }

  final Uri url = Uri.parse('${ApiUrls.UPDATE_ITV_URL_NEST}');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Mise à jour réussie en nest js : $responseData');
    } else if (response.statusCode == 404) {
      throw Exception('Intervention non trouvée (ID incorrect)');
    } else {
      throw Exception('Erreur serveur: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Erreur lors de la mise à jour: $e');
    throw Exception('Erreur lors de la mise à jour: $e');
  }
}


}

