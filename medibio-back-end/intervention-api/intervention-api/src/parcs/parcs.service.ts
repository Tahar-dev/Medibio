// Importation des modules nécessaires depuis NestJS, Mongoose, et autres
import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateDto } from 'src/dto/create.dto';
import { UpdateDto , ParcDto } from 'src/dto/update.dto';
import { Parc, ParcDocument} from 'src/models/parc.models';


@Injectable()
export class ParcService {
  constructor(
    @InjectModel(Parc.name, 'parcsDB') // Spécification de la connexion
    private readonly ParcModel: Model<Parc>
  ) {}

  async replaceOrCreate(parcDto: ParcDto): Promise<Parc> {
    // On utilise tout le DTO directement pour la mise à jour
    const documentData = {
      ...parcDto,
      // On s'assure que les tableaux sont bien initialisés
      interventions: parcDto.interventions || [],
      datesInterventions: parcDto.datesInterventions || [],
      techniciens: parcDto.techniciens || [],
      commentaires: parcDto.commentaires || [],
    };
  
    try {
      const updatedOrCreatedParc = await this.ParcModel.findOneAndUpdate(
        { id: parcDto.id },          // Recherche par ID
        { $set: documentData },       // Mise à jour avec toutes les données
        { 
          new: true,                  // Retourne le document après modif
          upsert: true,               // Crée si non trouvé
          setDefaultsOnInsert: true  // Applique les valeurs par défaut lors de la création
        }
      ).exec();
  
      return updatedOrCreatedParc;
    } catch (error) {
      console.error('❌ Erreur lors du replaceOrCreate :', error);
      throw new Error('Erreur lors du traitement du parc');
    }
  }

  
  async create(createDto: CreateDto): Promise<Parc> {
    const createdParc = new this.ParcModel(createDto);
    return createdParc.save();
  }


// parc.service.ts
async delete(id: string): Promise<boolean> {
  const deletedParc = await this.ParcModel.findOneAndDelete({ id }).exec();

  if (deletedParc) {
    console.log(`Parc with id ${id} is deleted`);
    return true;
  } else {
    console.log(`Parc with id ${id} not found`);
    return false;
  }
}



  async findAll(): Promise<Parc[]> {
    return this.ParcModel.find().exec();
  }

  async findOne(id: string): Promise<Parc> {
    return this.ParcModel.findById(id).exec();
  }


  async update(updateDto: ParcDto): Promise<Parc | null> {
    const { id, interventions, datesInterventions, techniciens, commentaires } = updateDto;
  
    // Vérification de l'ID
    if (!id || id.trim() === '') {
      console.warn('❌ Aucun ID de parc fourni.');
      return null;
    }
  
    // Construction de l'objet de mise à jour
    const updateFields: any = {};
    if (interventions) {
      updateFields.$set = {
        interventions,
        datesInterventions: datesInterventions || [],
        techniciens: techniciens || [],
        commentaires: commentaires || []
      };
    }
  
    try {
      return await this.ParcModel.findOneAndUpdate(
        { id }, // Filtre par l'ID du parc
        updateFields,
        {
          new: true,
          upsert: false
        }
      ).exec();
    } catch (error) {
      console.error('❌ Erreur lors de la mise à jour:', error);
      return null;
    }
  }
  
  async updateFromIntervention(interventionData: {
    interventionId: string;
    technicienRealName: string;
    date: string;
    parcs: Array<{ id: string; observation?: string }>;
  }): Promise<void> {
    const { interventionId, technicienRealName, date, parcs } = interventionData;

    // Validation des données d'entrée
    if (!interventionId?.trim()) {
      console.warn('❌ Aucun interventionId valide fourni');
      throw new Error('InterventionId est requis');
    }

    if (!parcs?.length) {
      console.debug('Aucun parc à mettre à jour');
      return;
    }

    try {
      // Préparation des données communes
      const commonUpdates = {
        datesInterventions: date,
        techniciens: technicienRealName,
      };

      // Exécution en parallèle pour tous les parcs
      const updatePromises = parcs.map(async (parc) => {
        const updateDoc = {
          $push: {  // Utilisation de $push pour accepter les doublons
            interventions: interventionId,
            ...commonUpdates,
            commentaires: parc.observation?.trim() || 'Aucun commentaire',
          },
        };

        const options = { 
          upsert: false,
          session: null // Peut être utilisé pour les transactions
        };

        await this.ParcModel.findOneAndUpdate(
          { id: parc.id },
          updateDoc,
          options
        ).exec();
      });

      await Promise.all(updatePromises);
      
      console.log(`✅ ${parcs.length} parcs mis à jour pour l'intervention ${interventionId}`);

    } catch (error) {
      console.error(`❌ Erreur lors de la mise à jour des parcs pour ${interventionId}:`, error);
      throw new Error(`Échec de la mise à jour des parcs: ${error.message}`);
    }
  }

  Search(intervention_ID: string) {
    if (!intervention_ID) {
      throw new Error('intervention_ID is required');
    }
    return this.ParcModel.find({ intervention_ID: intervention_ID });
  }



  //interventions == intervention_id (suit Sage X3)
async findParcsByInterventionId(interventions: string): Promise<Parc[]> {
  if (!interventions) {
    throw new BadRequestException('Parc Not Found');
  }
  
  const parcs = await this.ParcModel
    .find({ interventions: interventions })
    .exec();

  if (interventions.length === 0) {
    throw new NotFoundException(`Aucun Parc trouvé pour l'intervention' ${interventions}`);
  }

  return parcs;
}

 /* async updateParc(ParcId: string, parcId: string, updateDto: UpdateDto): Promise<Parc | null> {
    return this.ParcModel.findOneAndUpdate(
      {
        _id: ParcId,
        'parcs._id': parcId,
      },
      {
        $set: {
          'parcs.$.mark': updateDto.mark,
          'parcs.$.ref': updateDto.ref,
          'parcs.$.n_serie': updateDto.n_serie,
          'parcs.$.id_pce': updateDto.id_pce,
          'parcs.$.ref_pce': updateDto.ref_pce,
          'parcs.$.qte_pc': updateDto.qte_pc,
         
        },
      },
      { new: true },
    ).exec();
  }*/
}