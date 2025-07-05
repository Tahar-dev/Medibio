import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { InterventionsModule } from './interventions/interventions.module';
import { ParcsModule } from './parcs/parcs.module';
import { ArticlesModule } from './articles/articles.module';
import { AccueilModule } from './accueil/accueil.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    // Connexion principale (interventions)
    MongooseModule.forRootAsync({
      connectionName: 'interventionsDB',
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGO_URI_ITVS'),
        connectionFactory: (connection) => {
          connection.set('strictQuery', false);
          return connection;
        }
      }),
      inject: [ConfigService]
    }),

    // Connexion pour les parcs
    MongooseModule.forRootAsync({
      connectionName: 'parcsDB',
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGO_URI_PARCS')
      }),
      inject: [ConfigService]
    }),

    // Connexion pour les articles
    MongooseModule.forRootAsync({
      connectionName: 'articlesDB',
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGO_URI_ARTICLES')
      }),
      inject: [ConfigService]
    }),

    InterventionsModule,
    ParcsModule,
    ArticlesModule,
    AccueilModule,
    
  ],
})
export class AppModule {}