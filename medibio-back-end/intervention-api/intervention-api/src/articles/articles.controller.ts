// Importation des décorateurs nécessaires depuis le module '@nestjs/common' 
// pour définir les routes et injecter des données de requête
import { Body, Controller, Delete, Get, HttpCode, HttpException, HttpStatus, NotFoundException, Param, Patch, Post, Query } from '@nestjs/common';
// Importation du service ParcService pour effectuer des opérations sur les données
import { ArticleService } from './articles.service';
// Importation de la classe DTO pour valider la structure des données reçues
import { CreateDto } from 'src/dto/create.dto';
import { UpdateDto } from 'src/dto/update.dto';

// intervention.controller.ts


import { Article } from 'src/models/article.models';
import { ArticlesModule } from './articles.module';

import {BASE_URL} from 'src/constants';

@Controller(BASE_URL+'/articles')
export class ArticleController {
  constructor(private readonly articleService: ArticleService) { }


  @Get('/id')
  async getParcsByInterventionId(@Query('interventions') intervention: string): Promise<ArticlesModule[]> {
    if (!intervention) {
      throw new NotFoundException('Parc Not Found');
    }
    return await this.articleService.findParcsByInterventionId(intervention);
  }


  @Post('create')
  async create(@Body() createDto: CreateDto) {
    return this.articleService.create(createDto);
  }

@Post('replaceOrCreate')
@HttpCode(200)
async replaceOrCreate(@Body() articleDto: CreateDto) {
  try {
    return await this.articleService.replaceOrCreate(articleDto.id || null, articleDto);
  } catch (error) {
    throw new HttpException({
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      error: error.message || 'Erreur lors de la création/mise à jour de l\'article',
    }, HttpStatus.INTERNAL_SERVER_ERROR);
  }
}


  @Get('')
  async findAll() {
    return this.articleService.findAll();
  }

  @Delete('deleteall')
  async deleteAll() {
    return this.articleService.deleteAll();
  }

  @Get('get/:id')
  async findOne(@Param('id') id: string) {
    return this.articleService.findOne(id);
  }

  @Patch('update/:id')
  async update(
    @Param('id') id: string,
    @Body() updateDto: UpdateDto,
  ): Promise<Article | null> {
    return this.articleService.update(id, updateDto);
  }

  @Get('search')
  Search(@Query('intervention_ID') intervention_ID: string) {
    return this.articleService.Search(intervention_ID);
  }

  @Delete('delete')
  deleteById(@Query('id') id: string) {
    return this.articleService.deleteById(id);
    //ex: http://192.168.101.60:4444/api/medibio-sav/v2/interventions/delete?id=MED2555INT000000055
  }


}