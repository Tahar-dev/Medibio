import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Parc, ParcSchema } from '../models/parc.models';
import { ParcController } from './parcs.controller';
import { ParcService } from './parcs.service';

@Module({
  imports: [
    // Configuration spécifique à la connexion "parcsDB"
    MongooseModule.forFeature(
      [{ name: Parc.name, schema: ParcSchema }],
      'parcsDB' // Nom de connexion qui correspond à app.module.ts
    ),
  ],
  controllers: [ParcController],
  providers: [ParcService],
  exports: [ParcService] // Export si le service est utilisé ailleurs
})
export class ParcsModule {}