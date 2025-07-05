// src/notifications/notifications.service.ts
import { Injectable } from '@nestjs/common';
import { messaging } from '../firebase/firebase.config'; // Importez la configuration Firebase

@Injectable()
export class NotificationsService {
  async sendNotification(token: string, title: string, body: string, codeName: string) {
    const message = {
      notification: {
        title,
        body,
      },
      data: {
        codeName,
      
      },
      token,
    };
    
    console.log('FCM Token:', token);
    
    try {
      const response = await messaging.send(message);
      console.log('Notification envoyée avec succès :', response);
      return response;
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification :', error);
      throw error;
    }
  }
}
