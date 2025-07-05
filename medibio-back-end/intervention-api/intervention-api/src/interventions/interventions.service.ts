import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateDto } from 'src/dto/create.dto';
import { UpdateDto } from 'src/dto/update.dto';
import { Intervention, InterventionDocument } from 'src/models/intervention.models';
import * as soap from 'soap';

import { SOAP_URL, USERNAME, PASSWORD } from 'src/constants';
import { NotificationsService } from 'src/notifications/notifications.service';
import { ParcService } from 'src/parcs/parcs.service';
import { TechnicienApiService } from 'src/services/technicien-api.service';



let parcsGroup;

@Injectable()
export class InterventionService {

  constructor(
    @InjectModel(Intervention.name, 'interventionsDB') // Ajout du nom de connexion
    private readonly interventionModel: Model<InterventionDocument>,
    private readonly notificationsService: NotificationsService,
    private readonly technicienApiService: TechnicienApiService,
    private readonly ParcService: ParcService,
  ) { }




/*1*/
async replaceOrCreate(createDto: CreateDto): Promise<Intervention> {
  console.debug('🔄 Replace or Create intervention:', createDto);

  try {
    // 1. Validation des IDs
    if (createDto._id !== createDto.id || createDto.id !== createDto.interventionId) {
      throw new Error("_id, id et interventionId doivent être identiques");
    }

    // 2. Récupération du technicien
    const technicien = await this.technicienApiService.getTechnicienByNom(createDto.technicienname);
    
    if (!technicien) {
      console.warn(`⚠️ Aucun technicien trouvé avec le nom "${createDto.technicienname}"`);
      throw new Error(`Technicien "${createDto.technicienname}" non trouvé`);
    }

    // 3. Préparation des données
    const updateData = {
      ...createDto,
      fcmlisttokens: technicien.data.fcmlist
    };

    // 4. Opération principale sur l'intervention
    const intervention = await this.interventionModel.findOneAndUpdate(
      { _id: createDto._id },
      updateData,
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    console.debug('✅ Intervention remplacée/créée avec succès:', intervention);

    // 5. Mise à jour des parcs associés (nouvelle partie)
    if (createDto.parcs && createDto.parcs.length > 0) {
      try {
        await this.ParcService.updateFromIntervention({
          interventionId: createDto.interventionId,
          technicienRealName: createDto.technicienRealName || createDto.technicienname,
          date: createDto.date,
          parcs: createDto.parcs.map(parc => ({
            id: parc.id || '',
            observation: parc.observation
          }))
        });
        console.debug('✅ Parcs mis à jour avec succès');
      } catch (parcError) {
        console.error('⚠️ Erreur lors de la mise à jour des parcs:', parcError);
        // On ne throw pas pour ne pas interrompre le flux principal
      }
    }

    // 6. Envoi des notifications (existant)
    if (technicien?.data?.fcmlist?.length > 0) {
      this.sendNotificationsAsync(
        technicien.data.fcmlist,
        createDto.date,
        createDto.technicienname
      ).catch(error => {
        console.error('Erreur lors de l\'envoi des notifications:', error);
      });
    }

    return intervention;

  } catch (error) {
    console.error('❌ Erreur lors du replaceOrCreate:', error);
    throw error;
  }
}
private async sendNotificationsAsync(
    fcmTokens: string[],
    interventionDate: string,
    technicienName: string
): Promise<void> {
    const formattedDate = interventionDate.replace(/^(\d{4})(\d{2})(\d{2})$/, '$3/$2/$1');
    
    await Promise.all(fcmTokens.map(async (fcmToken) => {
        try {
            await this.notificationsService.sendNotification(
                fcmToken,
                'MEDIBIO',
                `Intervention planifiée pour le ${formattedDate}`,
                technicienName
            );
            console.debug(`✅ Notification envoyée à ${fcmToken.substring(0, 10)}...`);
        } catch (error) {
            console.error(`❌ Échec pour ${fcmToken.substring(0, 10)}...:`, error.message);
        }
    }));
}
/*2*/
  /*2 createOrReplace sans notifcation pour mise à jours en interne technicien mobile-mobile*/
  async replaceOrCreate2(createDto: CreateDto): Promise<Intervention> {
    console.debug('🔄 Replace or Create intervention:', createDto);
  
    try {
      // 1. Validation des IDs
      if (createDto._id !== createDto.id || createDto.id !== createDto.interventionId) {
        throw new Error("_id, id et interventionId doivent être identiques");
      }
  
      // 2. Récupération du technicien
      const technicien = await this.technicienApiService.getTechnicienByNom(createDto.technicienname);
      
      if (!technicien) {
        console.warn(`⚠️ Aucun technicien trouvé avec le nom "${createDto.technicienname}"`);
        throw new Error(`Technicien "${createDto.technicienname}" non trouvé`);
      }
  
      // 3. Préparation des données
      const updateData = {
        ...createDto,
        fcmlisttokens: technicien.data.fcmlist
      };
  
      // 4. Opération principale sur l'intervention
      const intervention = await this.interventionModel.findOneAndUpdate(
        { _id: createDto._id },
        updateData,
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
  
      console.debug('✅ Intervention remplacée/créée avec succès:', intervention);
  
      // 5. Mise à jour des parcs associés (nouvelle partie)
      if (createDto.parcs && createDto.parcs.length > 0) {
        try {
          await this.ParcService.updateFromIntervention({
            interventionId: createDto.interventionId,
            technicienRealName: createDto.technicienRealName || createDto.technicienname,
            date: createDto.date,
            parcs: createDto.parcs.map(parc => ({
              id: parc.id || '',
              observation: parc.observation
            }))
          });
          console.debug('✅ Parcs mis à jour avec succès');
        } catch (parcError) {
          console.error('⚠️ Erreur lors de la mise à jour des parcs:', parcError);
          // On ne throw pas pour ne pas interrompre le flux principal
        }
      }
      return intervention;
  
    } catch (error) {
      console.error('❌ Erreur lors du replaceOrCreate:', error);
      throw error;
    }
  }

  /*3*/
  async findAll(): Promise<Intervention[]> {

    const interventions = await this.interventionModel.find().exec();

    return interventions;
  }

  /*4*/
  async getById(id: string): Promise<Intervention[]> {
    if (!id) {
      console.error('interventionId is required');
      throw new BadRequestException('interventionId is required');
    }
    //console.debug(`Fetching intervention with id: ${id}`);
    const interventions = await this.interventionModel.find({ id }).exec();
    return interventions;
  }

  /*5*/
  async deleteById(id: string): Promise<{ deletedCount: number }> {
    if (!id) {
      console.error('interventionId is required');
      throw new BadRequestException('interventionId is required');
    }
    console.debug(`Deleting intervention with id: ${id}`);
    const result = await this.interventionModel.deleteOne({ id }).exec();
    if (result.deletedCount === 0) {
      console.error(`Intervention with id ${id} not found.`);
      throw new NotFoundException(`Intervention with id ${id} not found`);
    }
    console.debug('Intervention deleted successfully:', result);
    return { deletedCount: result.deletedCount };
  }


  /*6*/
  async findByTechnicianRealName(technicienname: string): Promise<Intervention[]> {
    if (!technicienname) {
      console.error('Technician name is required');
      throw new BadRequestException('Le nom du technicien est requis');
    }

    console.debug(`Fetching interventions for technician: ${technicienname}`);
    const interventions = await this.interventionModel
      .find({ technicienname: technicienname })
      .exec();

    if (interventions.length === 0) {
      console.error(`No interventions found for technician ${technicienname}.`);
      throw new NotFoundException(`Aucune intervention trouvée pour le technicien ${technicienname}`);
    }

    console.debug('Found interventions:', interventions);
    return interventions;
  }

  /******************************************************************************************************************************/
  async processIntervention(intervention: any): Promise<any> {
    console.debug('Starting process for intervention with body:', JSON.stringify(intervention, null, 2));

    try {

      if (!intervention || !intervention.id) {
        throw new BadRequestException('Invalid intervention body: ID is required.');
      }


      console.info(`Intervention received with ID: ${intervention.id}`);




      const client = await this.createSoapClient(SOAP_URL, USERNAME, PASSWORD);


      const interventionData = this.prepareInterventionData(intervention);
      const args = {
        callContext: {
          codeLang: "FRA",
          poolAlias: "",
        },
        publicName: "YINTER",
        inputXml: `<![CDATA[${JSON.stringify(interventionData)}]]>`,
      };

      console.debug('Making SOAP call with arguments:', JSON.stringify(args, null, 2));
      return this.makeSoapCall(client, args);

    } catch (error) {
      console.error('Error in processIntervention:', error.message);
      throw new BadRequestException(error.message);
    }
  }

  private prepareInterventionData(intervention: any): any {
    parcsGroup = intervention.parcs.map((parc: any) => ({ YMAC: parc.id }));


    return {

      GRP1: {

        YINT: intervention.id,
        YDUREE: intervention.realduration,
        YDFR: intervention.realenddate,
        YHFR: intervention.realendtime,
        YDDR: intervention.realstartdate,
        YHDR: intervention.realstarttime,
        YUSR: "",

      },

      GRP2: parcsGroup,
      GRP3: [
        { YSATPARC: "" }
      ],
      GRP4: {
        YATITSAT: intervention.attitudeApparenceItv,
        YREASAT: intervention.qualityPrestationItv,
        YCOMSAT: intervention.communicationItv,
        YGLOBSAT: intervention.globlementItv,
      },
    };
  }

  private async createSoapClient(url: string, username: string, password: string): Promise<any> {
    try {
      console.debug('Creating SOAP client.');
      const client = await soap.createClientAsync(url, { wsdl_options: { timeout: 120000 } });
      client.setSecurity(new soap.BasicAuthSecurity(username, password));
      console.debug('SOAP client created successfully.');
      return client;
    } catch (error) {
      console.error('Error occurred while creating SOAP client:', error);
      throw new BadRequestException('Error occurred while creating SOAP client.');
    }
  }

  private async makeSoapCall(client: any, args: any): Promise<any> {
    return new Promise((resolve, reject) => {
      client.runAsync(args, (error: any, soapResponse: any) => {
        if (error) {
          console.error('SOAP call failed:', error);
          reject(new BadRequestException('SOAP call failed.'));
        } else {
          console.debug('SOAP call succeeded:', soapResponse);
          resolve(soapResponse);
        }
      });
    });
  }

  async processParcs(intervention: any): Promise<any[]> {
    console.debug('Processing parcs for intervention with ID: ${intervention.id}');

    console.debug(parcsGroup);

    try {

      if (!Array.isArray(intervention.parcs) || intervention.parcs.length === 0) {
        console.warn('No parcs found for this intervention.');
        return [];
      }


      const results = await Promise.all(
        intervention.parcs.map(async (parc: any, index: number) => {
          try {
            console.debug(`Processing parc #${index + 1} with ID: ${parc.id}`);


            const parcData = this.prepareParcData(intervention, parc);

            const soapPayload = {
              callContext: {
                codeLang: 'FRA',
                poolAlias: '',
              },
              publicName: 'YRAPCONS',
              inputXml: `<![CDATA[${JSON.stringify(parcData)}]]>`,
            };

            console.debug('SOAP payload for parc:', JSON.stringify(soapPayload, null, 2));


            const client = await this.createSoapClient(SOAP_URL, USERNAME, PASSWORD);
            return this.makeSoapCall(client, soapPayload);
          } catch (error) {
            console.error(`Error processing parc #${index + 1}:`, error.message);
            throw new BadRequestException(`Error processing parc #${index + 1}: ${error.message}`);
          }
        })
      );

      console.debug('All parcs processed successfully.');
      return results;
    } catch (error) {
      console.error('Error in processParcs:', error.message);
      throw new BadRequestException(error.message);
    }
  }


  private prepareParcData(intervention: any, parc: any): any {

    const articlesData = Array.isArray(parc.articles)
      ? parc.articles.map((article: any) => ({
        YQTY: article.quantity,
        YUS: article.us,
      }))
      : [];

    return {
      GRP1: {
        YINT: intervention.id,
        YMAC: parc.id,
        YCOMC: parc.clientComment,
        YCOMT: parc.techComment,
        YCOMT2: "",
        YINTITULE: parc.intitulé,
        YDATE: intervention.realstartdate,
      },
      GRP4: [
        { YITM: parc.article },
      ],
      GRP5: articlesData.map((item) => ({ YQTY: item.YQTY })),
      GRP7: articlesData.map((item) => ({ YUS: item.YUS })),
      GRP6: [
        { YDES: "" },
      ],
      GRP8: [
        { YREF: "" },

      ],
      GRP9: [
        { YTEXTE: parc.texte },

      ],

      GRP10: { YDESC: parc.descResumTrv },

      GRP11: [
        { "YCHOIX": parc.problemTypeList[0] },
        { "YCHOIX": parc.problemTypeList[1] },
        { "YCHOIX": parc.problemTypeList[2] },
        { "YCHOIX": parc.problemTypeList[3] },
        { "YCHOIX": parc.problemTypeList[4] },
        { "YCHOIX": parc.problemTypeList[5] },
        { "YCHOIX": parc.problemTypeList[6] }
      ],

      GRP12: { YVALEUR: parc.problemOtherType },

      GRP13: [
        { YNUML: "NUMLOT1" },

      ],
      GRP14: [
        { YNUMS: "NUMSORT1" },

      ],
      GRP15: [
        { YSTOM: "" },

      ],
    };
  }
  /******************************************************************************************************************************/


  async generatePDFAndSave(pdfData: any): Promise<any> {
    console.debug('Démarrage du processus de génération et d\'enregistrement du PDF...');
    pdfData = {
      GRP1: {
        YINT: pdfData.interventionId
      },
      GRP3: [
        {
          YFILE: pdfData.fileUrl
        }
      ]
    };

    const pdfArgs = {
      callContext: {
        codeLang: 'FRA',
        poolAlias: '',
      },
      publicName: 'YPDF',
      inputXml: `<![CDATA[${JSON.stringify(pdfData)}]]>`,
    };

    console.debug('Payload préparé pour la génération du PDF :', JSON.stringify(pdfArgs, null, 2));

    try {
      const client = await this.createSoapClient(SOAP_URL, USERNAME, PASSWORD);
      const pdfResult = await this.makeSoapCall(client, pdfArgs);

      console.info('Génération et enregistrement du PDF réussis :', pdfResult);
      return pdfResult;
    } catch (error) {
      console.error('Erreur pendant la génération ou l\'enregistrement du PDF :', error.message);
      throw new BadRequestException('Erreur pendant la génération ou l\'enregistrement du PDF.');
    }
  }

  /*7*/
  async sendInterventionWithParcsAndPdf(intervention: any, pdfData: any): Promise<any> {
    console.debug('Début du processus pour l\'intervention et ses parcs :', JSON.stringify(intervention, null, 2));

    try {

      if (!intervention || !intervention.id) {
        throw new BadRequestException('Le corps de l\'intervention est invalide : l\'ID est requis.');
      }


      console.info(`Envoi de l'intervention principale avec l'ID : ${intervention.id}`);
      const sendInterventionResult = await this.processIntervention(intervention);


      console.info('Traitement des parcs associés à l\'intervention...');
      const processParcsResults = await this.processParcs(intervention);



      console.info('Génération et enregistrement du PDF...');
      const pdfResults = await this.generatePDFAndSave(pdfData);


      console.debug('Intervention, parcs et PDF traités avec succès.');
      return {
        sendInterventionResult,
        processParcsResults,
        pdfResults,
      };

    } catch (error) {
      console.error('Erreur dans sendInterventionWithParcsAndPdf :', error.message);
      throw new BadRequestException(error.message);
    }

  }

/*8*/
async updateIntervention(
  id: string,
  updateDto: UpdateDto
): Promise<Intervention> {
  console.debug(`🔄 Mise à jour de l'intervention avec id: ${id}`, updateDto);

  try {
    // Récupération du technicien
    const technicien = await this.technicienApiService.getTechnicienByNom(updateDto.technicienname);
    
    if (!technicien) {
      console.warn(`⚠️ Aucun technicien trouvé avec le nom "${updateDto.technicienname}"`);
      throw new Error(`Technicien "${updateDto.technicienname}" non trouvé`);
    }

    // Mise à jour de l'intervention avec les tokens FCM
    const updatedIntervention = await this.interventionModel
      .findOneAndUpdate(
        { id },
        { 
          $set: {
            ...updateDto,
            fcmlisttokens: technicien.data.fcmlist
          } 
        },
        { new: true }
      )
      .lean() // Utilisation de lean() pour obtenir un objet JavaScript simple
      .exec();

    if (!updatedIntervention) {
      throw new NotFoundException(`Intervention ${id} introuvable`);
    }

    // Envoi des notifications en arrière-plan
    if (technicien?.data?.fcmlist?.length > 0) {
      this.sendNotificationsBackground(
        technicien.data.fcmlist,
        updatedIntervention.date,
        updateDto.technicienname
      );
    }

    return updatedIntervention; // Retourne directement l'objet intervention
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour:', error);
    throw error;
  }
}

private async sendNotificationsBackground(
  fcmTokens: string[],
  interventionDate: string,
  technicienName: string
): Promise<void> {
  try {
    const formattedDate = interventionDate.replace(/^(\d{4})(\d{2})(\d{2})$/, '$3/$2/$1');
    
    await Promise.all(fcmTokens.map(async (fcmToken) => {
      try {
        await this.notificationsService.sendNotification(
          fcmToken,
          'Affectation d\'intervention',
          `Nouvelle intervention prévue le ${formattedDate}`,
          technicienName
        );
        console.debug(`Notification envoyée à ${fcmToken.substring(0, 10)}...`);
      } catch (error) {
        console.error(`Échec envoi à ${fcmToken.substring(0, 10)}...:`, error.message);
      }
    }));
  } catch (error) {
    console.error('Erreur lors de l\'envoi des notifications:', error);
  }
}


  /*9*/
  async updateCodesTechnicien(name: string) {

    const technician = await this.technicienApiService.getTechnicienByNom(name);
    if (!technician) throw new Error('Technicien non trouvé');


    const result = await this.interventionModel.updateMany(
      { technicienname: name },
      { fcmlisttokens: technician.data.fcmlist }
    );

    if (result.modifiedCount === 0) {
      console.warn(`Aucune intervention trouvée pour le technicien "${name}"`);
      return { message: `Aucune intervention trouvée pour le technicien "${name}"` };
    }
    console.log(`${result.modifiedCount} interventions mises à jour pour "${name}" ✅`);
    return { message: `${result.modifiedCount} interventions mises à jour` };
  }

}



