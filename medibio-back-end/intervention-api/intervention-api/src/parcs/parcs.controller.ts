// Importation des décorateurs nécessaires depuis le module '@nestjs/common' 
// pour définir les routes et injecter des données de requête
import { Body, Controller, Delete, Get, HttpCode, HttpException, HttpStatus, NotFoundException, Param, Patch, Post, Query } from '@nestjs/common';
// Importation du service ParcService pour effectuer des opérations sur les données
import { ParcService } from './parcs.service';
// Importation de la classe DTO pour valider la structure des données reçues
import { CreateDto } from 'src/dto/create.dto';
import { ParcDto, UpdateDto } from 'src/dto/update.dto';

// intervention.controller.ts


import { Parc } from 'src/models/parc.models';
import { ParcsModule } from './parcs.module';

import { BASE_URL } from 'src/constants';

@Controller(BASE_URL + '/parcs')
export class ParcController {
  constructor(private readonly parcService: ParcService) { }


  @Get('/id')
  async getParcsByInterventionId(@Query('interventions') intervention: string): Promise<ParcsModule[]> {
    if (!intervention) {
      throw new NotFoundException('Parc Not Found');
    }
    return await this.parcService.findParcsByInterventionId(intervention);
  }


  @Post('replaceOrCreate')
  @HttpCode(200)
  async replaceOrCreate(@Body() parcDto: ParcDto) {
    try {
      return await this.parcService.replaceOrCreate(parcDto);
    } catch (error) {
      throw new HttpException({
        status: HttpStatus.INTERNAL_SERVER_ERROR,
        error: error.message || 'Erreur lors de la création/mise à jour du parc',
      }, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Post('create')
  async create(@Body() createDto: CreateDto) {
    return this.parcService.create(createDto);
  }

  @Get('')
  async findAll() {
    return this.parcService.findAll();
  }

  @Get('get/:id')
  async findOne(@Param('id') id: string) {
    return this.parcService.findOne(id);
  }

  @Patch('update') // plus de paramètre d'URL
  async update(
    @Body() updateDto: UpdateDto,
  ): Promise<Parc | null> {
    return this.parcService.update(updateDto);
  }
  


  @Get('search')
  Search(@Query('intervention_ID') intervention_ID: string) {
    return this.parcService.Search(intervention_ID);
  }



// parc.controller.ts
@Delete('delete/:id')
async delete(@Param('id') id: string): Promise<{ message: string }> {
  const isDeleted = await this.parcService.delete(id);

  if (isDeleted) {
    return { message: `Parc with id ${id} is deleted` };
  } else {
    return { message: `Parc with id ${id} not found` };
  }
}



}