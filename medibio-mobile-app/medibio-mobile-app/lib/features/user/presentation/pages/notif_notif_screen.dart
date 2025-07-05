import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  //static const route = '/notification-screen';

  @override
  Widget build(BuildContext context) {
    // Récupérer l'argument de la route et le caster en RemoteMessage
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message?.notification?.title ?? "Aucune notification"),
            Text(message?.notification?.body?? "Aucune notification"),
            Text(message?.data.toString() ?? "Aucune notification")
          ],
        ),
      ),
    );
  }
}
