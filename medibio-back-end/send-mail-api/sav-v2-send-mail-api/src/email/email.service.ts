import * as nodemailer from 'nodemailer';
import * as dotenv from 'dotenv';
import { Injectable } from '@nestjs/common';

// Charger les variables d'environnement
dotenv.config();

@Injectable()
export class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      host: 'smtp.sendgrid.net',
      port: 587,
      secure: false,
      debug: true,
      tls: {
        rejectUnauthorized: false,
      },
      auth: {
        user: '', // Utilisation de "apikey" comme nom d'utilisateur pour SendGrid
        pass: '', // Clé API depuis le fichier .env
      },
    });
  }

  async sendEmailWithAttachment(
    to: string,
    subject: string,
    text: string,
    file: Express.Multer.File,
  ): Promise<void> {
    await this.transporter.sendMail({
      from: 'medibio@medibio.tn', // Utilisation de l'email depuis le fichier .env
      to,
      subject,
      text,
      attachments: [
        {
          filename: file.originalname,
          content: file.buffer,
        },
      ],
    });
  }
}
