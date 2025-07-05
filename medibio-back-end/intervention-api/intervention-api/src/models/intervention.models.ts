// intervention.schema.ts

import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export class Article {

  @Prop({ type: String })
  _id: string; // <-- ajoute ceci pour forcer un _id de type string !

  @Prop({ required: false })
  id: string;

  @Prop({ required: false })
  parcid: string;

  @Prop({ required: false })
  designation: string;

  @Prop({ required: false })
  us: string;

  @Prop({ required: false })
  quantity: string;

  @Prop({ required: false })
  type: string;

  @Prop({ required: false })
  ref: string;

  @Prop({ required: false })
  commentaire: string;
}


@Schema({
  toJSON: {
    transform: function(doc, ret) {
      const ordered = {};
      const fieldOrder = [
        '_id', 'id', 'designation', 'address', 'nserie', 'article',
        'marque', 'software', 'firmware', 'marque_designation',
        'client', 'localisation', 'designation_address',
        'probleme_type', 'articles', 'interventions',
        'datesInterventions', 'techniciens', 'commentaires', '__v'
      ];

      fieldOrder.forEach(key => {
        if (ret[key] !== undefined) {
          ordered[key] = ret[key];
        }
      });

      return ordered;
    }
  }
})
export class Parc {

@Prop({ type: String }) // <-- très important
  _id: string;
  
  @Prop({ required: false })
  id: string;

  @Prop({ required: false })
  designation: string;

  @Prop({ required: false })
  address: string;

  @Prop({ required: false })
  nserie: string;

  @Prop({ required: false })
  article: string;

  @Prop({ required: false })
  marque: string;

  @Prop({ required: false })
  software: string;

  @Prop({ required: false })
  firmware: string;

  @Prop({ required: false })
  marque_designation: string;

  @Prop({ required: false })
  client: string;

  @Prop({ required: false })
  localisation: string;

  @Prop({ required: false })
  designation_address: string;



  @Prop({ required: false, type: [String] })
  probleme_type: string[];

  @Prop({ required: false })
  resume: string;

  @Prop({ required: false })
  observation: string;

  @Prop({ required: false, type: [Article] }) // Utilisation du sous-document Article
  articles: Article[];

  //attitude et apparence - qualité de prestation -communication - globlement ---- problemType

@Prop({ required: false })
attitudeApparence: string;

@Prop({ required: false })
qualityPrestation: string;


@Prop({ required: false })
communication: string;

@Prop({ required: false })
globlement: string;

@Prop({ required: false })
problemType: string;



@Prop({ required: false })
intitule: string;

@Prop({ required: false })
codeRapport: string;


@Prop({ required: false, type: [String] })
interventions: string[];

@Prop({ required: false, type: [String] })
datesInterventions: string[];

@Prop({ required: false, type: [String] })
techniciens: string[];

@Prop({ required: false, type: [String] })
commentaires: string[];



}

@Schema()
export class Intervention {

  @Prop({ required: true })
  id?: string;

  @Prop({ required: false })
  description: string;

  @Prop({ required: false })
  technicienname: string;

  @Prop({ required: false })
  couvertureglobale: string;

  @Prop({ required: false })
  lieu: string;

  @Prop({ required: false })
  client: string;

  @Prop({ required: false })
  BL: string;

  @Prop({ required: false, type: [String] })
  BL_Article: string[]; 

  @Prop({ required: false })
  address: string;

  @Prop({ required: false, type: [String] })
  articleMissionExpense: string[];
  
  //fcmlist
  @Prop({ required: false, type: [String] })
  fcmlisttokens: string[];

  @Prop({ required: false })
  calendardate: string; 

  @Prop({ required: false })
  codeaddress: string;


  @Prop({ required: false })
  date: string; 

  @Prop({ required: false })
  debuteHour: string; 


  @Prop({ required: false })
  duration: string;

  @Prop({ required: false })
  email: string;
  
  @Prop({ required: false })
  enddate: string; 

  @Prop({ required: false })
  finishHour: string;


  @Prop({ required: true })
  _id?: string;

  @Prop({ required: false, type: [String] })
  idParcArray: string[]; 

  @Prop({ required: false })
  id_client: string;

  @Prop({ required: false })
  interventionId: string;

  @Prop({ required: false })
  isPlanified: boolean;

  @Prop({ required: false })
  isSaved: boolean;


  @Prop({ required: false })
  locationLatitude: string;

  @Prop({ required: false })
  locationLongitude: string;

  @Prop({ required: false })
  mobilestatus: string;

  @Prop({ required: false })
  npid: string;

  @Prop({ required: false, type: [Object] })
  parcs: Parc[]; 

  @Prop({ required: false, type: [String] })
  pausedChronoDataArray: string[]; 

  @Prop({ required: false })
  realdepartureDate: string;

  @Prop({ required: false })
  realdepartureTime: string;

  @Prop({ required: false })
  realduration: string;

  @Prop({ required: false })
  realenddate: string;

  @Prop({ required: false })
  realendtime: string;

  @Prop({ required: false })
  realstartdate: string;

  @Prop({ required: false })
  realstarttime: string;

  @Prop({ required: false, type: [String] })
  ressources: string[]; 

  @Prop({ required: false })
  satisfaction: string;

  @Prop({ required: false })
  state: string;

  @Prop({ required: false })
  technicienRealName: string;

  @Prop({ required: false })
  tel: string;

  @Prop({ required: false })
  type: string;

  @Prop({ required: false })
  urgency: string;

  @Prop({ required: false })
  user: string;

@Prop({ required: false })
attitudeApparenceItv: string;

@Prop({ required: false })
qualityPrestationItv: string;


@Prop({ required: false })
communicationItv: string;

@Prop({ required: false })
globlementItv: string;


@Prop({ required: false, type: [String] })
realstarttimelist: string[]; 


@Prop({ required: false, type: [String] })
realendtimelist: string[]; 


@Prop({ required: false, type: [String] })
realstartdaylist: string[]; 


}

export type InterventionDocument = Intervention & Document;

export const InterventionSchema = SchemaFactory.createForClass(Intervention);
