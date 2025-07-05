import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { lastValueFrom } from 'rxjs';

@Injectable()
export class TechnicienApiService {
  private technicienServiceUrl = 'http://192.168.1.28:8888/technicians';

  constructor(private readonly httpService: HttpService) {}

  async getTechnicienByNom(name: string) {
    try {
      // Utilisation de lastValueFrom au lieu de toPromise() qui est déprécié
      const response = await lastValueFrom(
        this.httpService.get(`${this.technicienServiceUrl}/find-tech/${name}`)
      );
      
      return response;
    } catch (error) {
      // Gestion de l'erreur 404
      if (error.response && error.response.status === 404) {
        console.error(`Technicien "${name}" non trouvé`);
        throw new Error(`Technicien "${name}" non trouvé`);
      }
      
      // Gestion des autres erreurs
      console.error(`Erreur lors de la récupération du technicien "${name}":`, error.message);
      throw new Error(`Erreur lors de la communication avec l'API des techniciens: ${error.message}`);
    }
  }
}