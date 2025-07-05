//commit - 29/05/2025 17:00
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';

async function bootstrap() {
  try {
    dotenv.config(); // Charger les variables d'environnement
    const app = await NestFactory.create(AppModule);
    const port = process.env.PORT;
    await app.listen(port);
    console.log('Application is running on: http://localhost:'+port);
  } catch (error) {
    console.error('Error starting the application:', error);
  }
}
bootstrap();
