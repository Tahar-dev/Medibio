// parc.schema.ts

import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema()
export class Article {
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
}

export const ArticleSchema = SchemaFactory.createForClass(Article);

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

  @Prop({ required: false, type: [ArticleSchema] }) // Utilisation du sous-document Article
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

export type ParcDocument = Parc & Document;

export const ParcSchema = SchemaFactory.createForClass(Parc);
