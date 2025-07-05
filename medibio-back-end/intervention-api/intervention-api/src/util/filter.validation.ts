// Importation des éléments nécessaires depuis le package @nestjs/common pour la gestion des exceptions
import {
  ArgumentsHost,
  BadRequestException,
  Catch,
  ExceptionFilter,
} from '@nestjs/common';

// Définition d'une classe d'exception personnalisée pour gérer les erreurs de validation
export class ValidationException extends BadRequestException {
  // Le constructeur prend un objet contenant les erreurs de validation
  // et le rend accessible publiquement pour une utilisation ultérieure
  constructor(public validationErrors: any) {
    super(); // Appel au constructeur de la classe parent BadRequestException
  }
}

// Utilisation du décorateur @Catch pour indiquer que ce filtre doit intercepter les ValidationException
@Catch(ValidationException)
export class ValidationFilter implements ExceptionFilter {
  // Méthode catch qui sera appelée quand une exception de type ValidationException est lancée
  catch(exception: ValidationException, host: ArgumentsHost): any {
    // Obtention du contexte HTTP à partir de l'host pour accéder à la requête et à la réponse
    const ctx = host.switchToHttp();
    // Récupération de l'objet de réponse HTTP natif
    const response = ctx.getResponse();
    
    // Envoi d'une réponse HTTP avec le statut 400 (Bad Request)
    // et un objet JSON contenant les détails de l'erreur de validation
    return response.status(400).json({
      statusCode: 400, // Code de statut HTTP indiquant une mauvaise requête
      success: false, // Indicateur de succès de l'opération
      message: '', // Message d'erreur (laissez vide si vous souhaitez utiliser un message générique du framework)
      error: exception.validationErrors, // Détail des erreurs de validation issues de l'exception
    });
  }
}
