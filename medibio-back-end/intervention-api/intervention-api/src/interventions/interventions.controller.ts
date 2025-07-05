
import { BadRequestException, Body, Controller, Delete, Get, HttpCode, HttpException, HttpStatus, NotFoundException, Param, Patch, Post, Query } from '@nestjs/common';

import { InterventionService } from './interventions.service';


import { CreateDto } from 'src/dto/create.dto';
import { UpdateDto } from 'src/dto/update.dto';
import { InterventionsModule } from './interventions.module';
import { NotificationsService } from 'src/notifications/notifications.service';


import { BASE_URL } from 'src/constants';


@Controller(BASE_URL + '/interventions')
export class InterventionController {
  logger: any;
  reportService: any;
  constructor(
    private readonly interventionService: InterventionService) { }

  /*1*/  
  @Post('replaceOrCreate')
  @HttpCode(200) // Ceci force la réponse à être 200 OK au lieu de 201 Created
  async replaceOrCreate(@Body() createDto: CreateDto) {
    return this.interventionService.replaceOrCreate(createDto);
  }



  /*2*/
  @Post('replaceOrCreate2')
  @HttpCode(200) // Ceci force la réponse à être 200 OK au lieu de 201 Created
  async replaceOrCreate2(@Body() createDto: CreateDto) {
    return this.interventionService.replaceOrCreate2(createDto);
  }


  /*3*/
  @Get('')
  async findAll() {
    return this.interventionService.findAll();
  }

  /*4*/
  @Get('id')
  async GetById(@Query('id') id: string) {
    return this.interventionService.getById(id);
    //ex: http://192.168.101.60:4444/api/medibio-sav/v2/interventions/id?id=MED2555INT000000055
  }

  /*5*/
  @Delete('delete')
  deleteById(@Query('id') id: string) {
    return this.interventionService.deleteById(id);
    //ex: http://192.168.101.60:4444/api/interventions/delete?id=MED2555INT000000055
  }

  /*6*/
  @Get('/technician')
  async getInterventionsByTechnician(@Query('technicianname') technicienname: string): Promise<InterventionsModule[]> {
    if (!technicienname) {
      throw new NotFoundException('Le nom du technicien est requis');
    }
    return await this.interventionService.findByTechnicianRealName(technicienname);
    //ex: http://192.168.101.60:4444/api/medibio-sav/v2/interventions/technician?technicianname=TS
  }

  /*7*/
  @Post('send-intervention-to-sage')
  async sendInterventionWithParcsAndPdf(
    @Body() body: { intervention: any; pdfData: any }
  ) {
    try {

      if (!body || !body.intervention || !body.pdfData) {
        throw new BadRequestException('Invalid request body: intervention and pdfData are required.');
      }

      const { intervention, pdfData } = body;


      const response = await this.interventionService.sendInterventionWithParcsAndPdf(intervention, pdfData);

      return {
        message: 'Intervention and its parcs processed successfully.',
        data: response,
      };
    } catch (error) {
      console.error('Error in sendInterventionWithParcs controller:', error);

      throw new BadRequestException(error.message || 'An unexpected error occurred.');
    }
  }

  /*8*/
  @Patch('update')
  update(@Query('id') id: string, @Body() updateDto: UpdateDto) {
    return this.interventionService.updateIntervention(id, updateDto);
  }

  /*9*/
  @Patch('update-fcm/:nomTechnicien')
  updateCodesTechnicien(@Param('nomTechnicien') name: string) {
    return this.interventionService.updateCodesTechnicien(name);
  }


}

