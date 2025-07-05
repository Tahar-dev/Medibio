import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Article, ArticleSchema } from '../models/article.models';
import { ArticleController } from './articles.controller';
import { ArticleService } from './articles.service';

@Module({
  imports: [
    // Configuration spécifique à la connexion "articlesDB"
    MongooseModule.forFeature(
      [{ name: Article.name, schema: ArticleSchema }],
      'articlesDB' // Nom de connexion qui correspond à app.module.ts
    ),
  ],
  controllers: [ArticleController],
  providers: [ArticleService],
  exports: [ArticleService] // Export si le service est utilisé dans d'autres modules
})
export class ArticlesModule {}