import {
    Controller,
    Post,
    UploadedFile,
    UseInterceptors,
    Body,
  } from '@nestjs/common';
  import { FileInterceptor } from '@nestjs/platform-express';
  import { EmailService } from './email.service';
  
  @Controller('email')
  export class EmailController {
    constructor(private readonly emailService: EmailService) {}
  
    @Post('send')
    @UseInterceptors(FileInterceptor('file')) // Attend le champ 'file' dans le form-data
    async sendEmail(
      @Body() body: { to: string; subject: string; text: string }, // Récupère les données du body
      @UploadedFile() file: Express.Multer.File, // Récupère le fichier envoyé
    ) {
      const { to, subject, text } = body;
  
      // Vérification si un fichier est bien envoyé
      if (!file) {
        return { message: 'Le fichier est requis' };
      }
  
      try {
        console.log('Fichier reçu:', file); // Affiche le fichier reçu dans la console
        // Appel du service pour envoyer l'email avec pièce jointe
        await this.emailService.sendEmailWithAttachment(to, subject, text, file);
        return { message: 'Email envoyé avec succès' }; // Confirmation de l'envoi
      } catch (error) {
        console.error('Erreur lors de l\'envoi de l\'email:', error);
        return { message: 'Erreur lors de l\'envoi de l\'email', error }; // Gestion des erreurs
      }
    }
  }
  