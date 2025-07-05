import * as admin from 'firebase-admin';
import * as serviceAccount from '../../config/serviceAccountKey.json'; 

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: serviceAccount.project_id,
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key.replace(/\\n/g, '\n'), // Gérer les sauts de ligne
  }),
});

export const messaging = admin.messaging();