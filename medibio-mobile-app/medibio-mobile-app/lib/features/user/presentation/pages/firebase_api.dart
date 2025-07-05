import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/calendar_page.dart';
import 'package:srasav_vf_v1/main.dart';

var userCode; // Code utilisateur stocké localement
var notificationCodeName; // Code reçu dans la notification

final _firebaseMessaging = FirebaseMessaging.instance;
final _localNotifications = FlutterLocalNotificationsPlugin();

// 📌 Fonction pour gérer les notifications en arrière-plan (DOIT ÊTRE DÉFINIE EN DEHORS DE LA CLASSE)
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("🔔 Notification reçue en arrière-plan ou lorsque l'application est fermée");

  // Vérifier si la notification contient un message valide et si les codes correspondent
  if (message.data.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    prefs.getString('name'); // Récupérer le code utilisateur
// Récupérer le code depuis la notification

    // Si les codes correspondent, afficher la notification
   
      final notification = message.notification;

      if (notification != null) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Ce canal est utilisé pour les notifications importantes',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_launcher',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        // Afficher la notification avec les détails
        await _localNotifications.show(
          message.hashCode, // Utiliser un identifiant unique pour la notification
          notification.title,
          notification.body,
          platformChannelSpecifics,
          payload: jsonEncode(message.toMap()), // Ajouter les données au payload
        );

        print("✅ Notification affichée en arrière-plan");
      } else {
        print("❌ Notification invalide, aucun titre ni corps");
      }
    
  } else {
    print("❌ Notification rejetée : Données vides");
  }
}

// 📌 Fonction principale pour gérer les notifications (accepte un paramètre nullable)
Future<void> handleMessage(RemoteMessage? message) async {
  if (message == null || message.data.isEmpty) return; // Vérifie la nullabilité

  final prefs = await SharedPreferences.getInstance();
  prefs.getString('name');


    print("✅ Notification acceptée");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Ce canal est utilisé pour les notifications importantes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      0,
      message.data['title'],
      message.data['body'],
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );

    navigatorKey.currentState?.pushNamed(
      InterventionCalendarPage.route,
      arguments: message,
    );
  
}

class FirebaseApi {
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Ce canal est utilisé pour les notifications importantes',
    importance: Importance.high,
  );

  // 📌 Initialisation Firebase
  void initFirebase() {
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  // 📌 Récupérer le code utilisateur
  Future<String?> getUserCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  // 📌 Initialiser les notifications locales
  Future<void> initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
          await handleMessage(message);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  // 📌 Initialiser les notifications push
  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false, // Désactiver l'affichage automatique des notifications
      badge: false,
      sound: false,
    );

    // Cas 1: L'application est en premier plan
    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification == null) return;

      userCode = await getUserCode();
      notificationCodeName = message.data['codeName']; // Récupérer depuis data

      // Afficher la notification UNIQUEMENT si les codes correspondent
      
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
     
    });

    // Cas 2: L'application est fermée ou en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print("🔔 Notification ouverte depuis l'arrière-plan");
      await handleMessage(message);
    });
  }

  // 📌 Initialiser toutes les notifications
  Future<void> initNotifications() async {
    userCode = await getUserCode();
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('✅ FCM Token: $fcmToken');
    print("✅ UserCode: $userCode");

    await initLocalNotifications();
    await initPushNotifications();
  }
}