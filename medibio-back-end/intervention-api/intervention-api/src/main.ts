//commit - 29/05/2025 17:00
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationError, ValidationPipe } from '@nestjs/common';
import { ValidationException, ValidationFilter } from './util/filter.validation';

// Définition de la fonction asynchrone bootstrap pour démarrer l'application
async function bootstrap() {
  // Création d'une instance de l'application NestJS à partir du AppModule
  const app = await NestFactory.create(AppModule);
  
  // Activation de CORS (Cross-Origin Resource Sharing) pour permettre les requêtes cross-origin
  app.enableCors();
  
  // Définition d'un préfixe global pour toutes les routes de l'API
  //app.setGlobalPrefix('/api');

  // Utilisation d'un filtre global pour gérer les exceptions de validation
  app.useGlobalFilters(new ValidationFilter());
  
  // Configuration des pipes de validation globaux pour valider les requêtes entrantes
  app.useGlobalPipes(
    new ValidationPipe({
      skipMissingProperties: false, // Ne pas ignorer les propriétés manquantes dans la validation
      // Personnalisation de la génération d'exceptions de validation
      exceptionFactory: (errors: ValidationError[]) => {
        const errMsg = {};
        errors.forEach((err) => {
          // Construction d'un objet d'erreurs avec les messages de validation
          errMsg[err.property] = [...Object.values(err.constraints)];
        });
        // Retour d'une exception personnalisée avec les messages d'erreur
        return new ValidationException(errMsg);
      },
    }),
  );

  // Récupération du port depuis les variables d'environnement et démarrage du serveur
  const port = process.env.PORT;
  await app.listen(port);
}

// Appel de la fonction bootstrap pour démarrer l'application
bootstrap();
