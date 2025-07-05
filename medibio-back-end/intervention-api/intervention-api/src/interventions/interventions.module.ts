import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { HttpModule } from '@nestjs/axios';

import { NotificationsModule } from '../notifications/notifications.module';
import { ParcsModule } from '../parcs/parcs.module'; // Import du module plutôt que du service directement
import { Intervention, InterventionSchema } from '../models/intervention.models';
import { InterventionController } from './interventions.controller';
import { InterventionService } from './interventions.service';
import { TechnicienApiService } from '../services/technicien-api.service';
import { ParcService } from 'src/parcs/parcs.service';

@Module({
  imports: [
    MongooseModule.forFeature(
      [
        { 
          name: Intervention.name, 
          schema: InterventionSchema 
        }
      ],
      'interventionsDB'
    ),
    HttpModule.register({}),
     // Module pour les événements
    NotificationsModule,
    forwardRef(() => ParcsModule), // Solution pour les dépendances circulaires
  ],
  controllers: [InterventionController],
  providers: [
    InterventionService,
    TechnicienApiService,
   
  ],
  exports: [
    MongooseModule,
    InterventionService
  ],
})
export class InterventionsModule {}