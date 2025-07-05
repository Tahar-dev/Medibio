// Importation des modules nécessaires depuis NestJS, Mongoose, et autres
import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateDto } from 'src/dto/create.dto';
import { UpdateDto } from 'src/dto/update.dto';
import { Article, ArticleDocument } from 'src/models/article.models';


@Injectable()
export class ArticleService {
  constructor(
    @InjectModel(Article.name, 'articlesDB') // Spécification explicite
    private readonly ArticleModel: Model<Article>
  ) {}

  async create(createDto: CreateDto): Promise<Article> {
    const createdParc = new this.ArticleModel(createDto);
    return createdParc.save();
  }

  async replaceOrCreate(id: string | null, dto: CreateDto | UpdateDto): Promise<Article> {
    if (id) {
      const updated = await this.ArticleModel.findOneAndUpdate(
        { _id: id },
        { $set: dto },
        { new: true, upsert: true }
      ).exec();
      return updated;
    } else {
      const created = new this.ArticleModel(dto);
      return created.save();
    }
  }
  

  
  async findAll(): Promise<Article[]> {
    return this.ArticleModel.find().exec();
  }

  async deleteAll(): Promise<{ deletedCount: number }> {
    const result = await this.ArticleModel.deleteMany({}).exec();
    return { deletedCount: result.deletedCount };
  }

  async deleteById(id: string): Promise<{ deletedCount: number }> {
    if (!id) {
      console.error('article is required');
      throw new BadRequestException('article is required');
    }
    console.debug(`Deleting article with id: ${id}`);
    const result = await this.ArticleModel.deleteOne({ id }).exec();
    if (result.deletedCount === 0) {
      console.error(`article with id ${id} not found.`);
      throw new NotFoundException(`article with id ${id} not found`);
    }
    console.debug('article deleted successfully:', result);
    return { deletedCount: result.deletedCount };
  }

  async findOne(id: string): Promise<Article> {
    return this.ArticleModel.findById(id).exec();
  }

  async update(id: string, updateDto: UpdateDto): Promise<Article | null> {
    return this.ArticleModel.findByIdAndUpdate(
      id,
      { $set: updateDto },
      { new: true },
    ).exec();
  }

  Search(intervention_ID: string) {
    if (!intervention_ID) {
      throw new Error('intervention_ID is required');
    }
    return this.ArticleModel.find({ intervention_ID: intervention_ID });
  }



  //interventions == intervention_id (suit Sage X3)
  async findParcsByInterventionId(interventions: string): Promise<Article[]> {
    if (!interventions) {
      throw new BadRequestException('Parc Not Found');
    }

    const parcs = await this.ArticleModel
      .find({ interventions: interventions })
      .exec();

    if (interventions.length === 0) {
      throw new NotFoundException(`Aucun Parc trouvé pour l'intervention' ${interventions}`);
    }

    return parcs;
  }
}