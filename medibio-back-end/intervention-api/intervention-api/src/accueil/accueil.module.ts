import { Module } from '@nestjs/common';
import { AccueilController } from './accueil.controller';

@Module({
  controllers: [AccueilController],
})
export class AccueilModule {}